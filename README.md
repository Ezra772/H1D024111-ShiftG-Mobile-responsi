# Aplikasi Cuaca (Open-Meteo Weather App)

Proyek Responsi Pemrograman Aplikasi Mobile (Flutter) yang mengimplementasikan aplikasi prakiraan cuaca terkini dan beberapa hari ke depan menggunakan REST API dari **Open-Meteo**, arsitektur **Model-View-ViewModel (MVVM)**, serta **Local Storage** untuk menyimpan lokasi favorit dan riwayat pencarian.

---

## 📌 Fitur Utama

1. **Home / Weather Screen**:
   - Menampilkan nama kota, provinsi/administrasi, dan negara yang sedang dipilih.
   - Menampilkan kondisi cuaca terkini (dilengkapi dengan ikon cuaca adaptif dan deskripsi cuaca dalam Bahasa Indonesia berdasarkan kode WMO).
   - Menampilkan suhu saat ini (`current.temperature_2m`).
   - Menampilkan metrik cuaca tambahan:
     - **Kelembapan udara** (`current.relative_humidity_2m`)
     - **Kecepatan angin** (`current.wind_speed_10m`)
     - **Peluang hujan** (`daily.precipitation_probability_max`)
     - **Suhu yang dirasakan** (`current.apparent_temperature`)
     - **Curah hujan** (`current.precipitation`)
     - **Rentang suhu harian** (Min & Max harian)
   - Menampilkan perkiraan cuaca harian (7 hari ke depan) secara responsif.
   - Fitur *Pull-to-Refresh* untuk memperbarui data cuaca langsung dari API.
   - Tombol toggle untuk menandai/menghapus lokasi favorit langsung dari layar utama.

2. **Search / Location Screen**:
   - Kolom pencarian interaktif untuk mencari nama kota di seluruh dunia via Open-Meteo Geocoding API.
   - Dilengkapi *debouncing* (500ms) untuk efisiensi request ke API.
   - Menampilkan daftar hasil pencarian lengkap dengan nama wilayah, negara, serta koordinat.
   - Memilih lokasi dari hasil pencarian langsung mengarahkan kembali ke Home Screen dan memuat data cuaca lokasi tersebut.
   - **Lokasi Favorit**: Daftar lokasi yang telah disimpan ke Local Storage, dapat diklik langsung atau dihapus.
   - **Riwayat Pencarian**: Daftar kota yang baru-baru ini dibuka, dengan opsi "Hapus Semua".

3. **Manajemen Kondisi (States)**:
   - **Loading State**: Animasi indikator progres saat mengambil data dari jaringan.
   - **Empty State**: Tampilan informatif ketika hasil pencarian tidak ditemukan atau belum ada data tersimpan.
   - **Error State**: Tampilan pesan galat yang informatif (misal koneksi terputus) disertai tombol **Coba Lagi (Retry)**.

---

## 🏗️ Penerapan Arsitektur MVVM (Model-View-ViewModel)

Aplikasi ini dibangun menggunakan arsitektur **MVVM** yang memisahkan tanggung jawab (Separation of Concerns) secara bersih dan terstruktur:

```
┌────────────────────────────────────────────────────────┐
│                        VIEW                            │
│  - HomeScreen                 - SearchScreen           │
│  - DailyForecastCard          - WeatherStatChip        │
│  - ErrorStateView             - EmptyStateView         │
└───────────────────────────▲────────────────────────────┘
                            │ (Mendengarkan State / Notifikasi)
                            ▼
┌────────────────────────────────────────────────────────┐
│                      VIEWMODEL                         │
│  - WeatherViewModel (ChangeNotifier)                  │
│  - SearchViewModel  (ChangeNotifier)                  │
│    (Mengelola state UI, memicu pembaruan via notify)  │
└───────────────▲────────────────────────▲───────────────┘
                │                        │
                ▼                        ▼
┌───────────────────────────────┐ ┌──────────────────────┐
│           SERVICES            │ │        MODELS        │
│ - ApiService (HTTP Client)    │ │ - WeatherData        │
│ - StorageService (SharedPrefs)│ │ - CurrentWeather     │
└───────────────────────────────┘ │ - DailyForecast      │
                                  │ - LocationModel      │
                                  └──────────────────────┘
```

1. **Model** (`lib/models/`):
   - Merepresentasikan entitas data murni tanpa dependensi ke UI.
   - `LocationModel`: Berisi `id`, `name`, `latitude`, `longitude`, `country`, `admin1`, dan metode serialisasi JSON.
   - `CurrentWeather`: Berisi metrik cuaca saat ini dari Open-Meteo.
   - `DailyForecast`: Berisi data perkiraan cuaca per hari (suhu min/max, peluang hujan, kode cuaca WMO).
   - `WeatherData`: Model agregat yang menggabungkan lokasi, cuaca saat ini, dan perkiraan harian.

2. **ViewModel** (`lib/viewmodels/`):
   - Bertindak sebagai jembatan antara Model/Service dan View.
   - Menggunakan package **`provider`** dengan basis `ChangeNotifier`.
   - `WeatherViewModel`: Mengelola state pemuatan cuaca (`initial`, `loading`, `loaded`, `error`), menyimpan lokasi aktif, serta mengelola status favorit.
   - `SearchViewModel`: Mengelola state pencarian kota (`idle`, `searching`, `success`, `empty`, `error`), memproses query dengan debounce, dan mengelola daftar favorit & riwayat.

3. **View** (`lib/views/`):
   - Hanya bertanggung jawab untuk rendering antarmuka pengguna (UI).
   - Tidak melakukan HTTP request atau manipulasi storage secara langsung, melainkan memanggil metode di ViewModel melalui `context.read<T>()` dan me-render ulang menggunakan `Consumer<T>` atau `context.watch<T>()`.

4. **Service** (`lib/services/`):
   - `ApiService`: Menangani komunikasi HTTP GET ke REST API Open-Meteo dengan penanganan timeout dan exception yang aman.
   - `StorageService`: Menangani persistensi data lokal menggunakan `shared_preferences`.

---

## 🌐 Implementasi REST API Open-Meteo

Aplikasi ini menggunakan 2 REST API publik dari Open-Meteo tanpa memerlukan API Key:

### 1. Geocoding API
- **Endpoint**: `https://geocoding-api.open-meteo.com/v1/search`
- **Method**: `GET`
- **Parameter**:
  - `name`: Nama kota yang dicari
  - `count`: Jumlah hasil maksimum (10)
  - `language`: Bahasa hasil nama lokasi (`id`/`en`)
  - `format`: Format respons (`json`)

### 2. Weather Forecast API
- **Endpoint**: `https://api.open-meteo.com/v1/forecast`
- **Method**: `GET`
- **Parameter Penting**:
  - `latitude`: Koordinat lintang lokasi
  - `longitude`: Koordinat bujur lokasi
  - `current`: `temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m`
  - `daily`: `temperature_2m_max,temperature_2m_min,precipitation_probability_max,weather_code`
  - `timezone`: `auto`

### Pemetaan Data API ke Tampilan:
| Data yang Ditampilkan | Field API Open-Meteo | Keterangan |
| :--- | :--- | :--- |
| Suhu saat ini | `current.temperature_2m` | Format derajat Celsius (°C) |
| Kelembapan | `current.relative_humidity_2m` | Persentase kelembapan udara (%) |
| Suhu yang dirasakan | `current.apparent_temperature` | Format derajat Celsius (°C) |
| Curah hujan | `current.precipitation` | Satuan milimeter (mm) |
| Kode kondisi cuaca | `current.weather_code` | Dikonversi ke teks dan ikon WMO |
| Kecepatan angin | `current.wind_speed_10m` | Satuan km/jam (km/h) |
| Suhu maksimum harian | `daily.temperature_2m_max` | Suhu tertinggi pada hari perkiraan |
| Suhu minimum harian | `daily.temperature_2m_min` | Suhu terendah pada hari perkiraan |
| Peluang hujan maksimum | `daily.precipitation_probability_max` | Persentase peluang hujan (%) |

---

## 💾 Implementasi Local Storage

Aplikasi menggunakan library **`shared_preferences`** untuk menyimpan data secara persisten di perangkat:

1. **Lokasi Terakhir Dipilih (`weather_app_last_selected`)**:
   - Ketika pengguna memilih kota, data kota tersebut disimpan secara otomatis.
   - Saat aplikasi dibuka kembali, aplikasi langsung memuat cuaca kota terakhir yang dipilih (default: Jakarta jika baru pertama kali dipasang).
2. **Daftar Lokasi Favorit (`weather_app_favorites`)**:
   - Pengguna dapat menandai kota favorit dengan menekan tombol hati.
   - Disimpan dalam bentuk daftar JSON serializable dan dapat diakses cepat dari layar pencarian.
3. **Riwayat Pencarian (`weather_app_recents`)**:
   - Menyimpan hingga 10 lokasi terakhir yang pernah dibuka.
   - Dilengkapi tombol untuk menghapus seluruh riwayat sekaligus.

---

## 📁 Struktur Direktori Proyek

```
lib/
├── constants/
│   ├── app_colors.dart         # Palet warna & gradien latar belakang cuaca
│   ├── app_theme.dart          # Konfigurasi ThemeData Material 3 & tipografi
│   └── weather_codes.dart      # Pemetaan kode cuaca WMO (deskripsi, ikon, gradien)
├── models/
│   ├── current_weather.dart    # Model data cuaca terkini
│   ├── daily_forecast.dart     # Model perkiraan cuaca harian
│   ├── location_model.dart     # Model data lokasi / kota
│   └── weather_data.dart       # Model agregator cuaca lengkap
├── services/
│   ├── api_service.dart        # HTTP Client untuk Open-Meteo REST API
│   └── storage_service.dart    # Client SharedPreferences (favorit, riwayat, sesi)
├── viewmodels/
│   ├── weather_viewmodel.dart  # ViewModel untuk Home / Layar Cuaca (State: MVVM)
│   └── search_viewmodel.dart   # ViewModel untuk Layar Pencarian & Favorit
├── views/
│   ├── screens/
│   │   ├── home_screen.dart    # Screen 1: Home / Weather Screen
│   │   └── search_screen.dart  # Screen 2: Search & Favorites Screen
│   └── widgets/
│       ├── daily_forecast_card.dart  # Widget kartu perkiraan cuaca per hari
│       ├── weather_stat_chip.dart    # Widget chip metrik cuaca (kelembapan, angin, dll.)
│       ├── error_state_view.dart     # Tampilan pesan error dengan tombol retry
│       └── empty_state_view.dart     # Tampilan placeholder data kosong
└── main.dart                   # Entry point aplikasi & inisialisasi MultiProvider
```

---

## 📱 Tangkapan Layar (Screenshots)

Berikut adalah referensi tangkapan layar antarmuka aplikasi:

| 1. Home / Weather Screen | 2. Search & Location Screen | 3. Lokasi Favorit & Riwayat |
| :---: | :---: | :---: |
| ![Home Screen](screenshots/home_screen.png) | ![Search Screen](screenshots/search_screen.png) | ![Favorites Screen](screenshots/favorites_screen.png) |
| *Menampilkan cuaca terkini, metrik lengkap, dan perkiraan 7 hari ke depan.* | *Pencarian kota secara langsung menggunakan Geocoding API.* | *Daftar lokasi favorit dan riwayat pencarian yang tersimpan lokal.* |

*(Catatan: Letakkan file gambar screenshot pada folder `screenshots/` sesuai nama file di atas).*

---

## 🚀 Panduan Menjalankan Aplikasi

### 1. Prasyarat
- Flutter SDK versi 3.13 ke atas
- Dart SDK versi 3.0 ke atas
- Perangkat Android fisik, Emulator Android, atau Google Chrome / Windows Desktop

### 2. Instalasi Dependensi
Jalankan perintah berikut di terminal:
```bash
flutter pub get
```

### 3. Menjalankan Pengujian (Unit & Widget Tests)
Aplikasi dilengkapi pengujian unit lengkap untuk memastikan parsing API dan logika model berjalan sempurna:
```bash
flutter test
```

### 4. Menjalankan Analisis Kode
Pastikan tidak ada lint warning atau kesalahan sintaks:
```bash
flutter analyze
```

### 5. Menjalankan Aplikasi
```bash
flutter run
```

---

## 📦 Paket Dependensi yang Digunakan

- **`http: ^1.6.0`**: Menangani permintaan HTTP GET ke REST API Open-Meteo.
- **`provider: ^6.1.5+1`**: Pengelolaan state reaktif dan penerapan arsitektur MVVM.
- **`shared_preferences: ^2.5.6`**: Penyimpanan lokal untuk favorit, riwayat, dan preferensi lokasi.
- **`intl: ^0.20.3`**: Pemformatan tanggal dan waktu lokal Bahasa Indonesia (`id_ID`).
- **`cupertino_icons: ^1.0.8`**: Ikon tambahan untuk kompatibilitas multi-platform.

---

## 📹 Video Penjelasan Kode Aplikasi
Panduan alur penjelasan kode untuk video presentasi responsi:
1. **Pendahuluan**: Menjelaskan tujuan aplikasi cuaca berbasis Open-Meteo.
2. **Arsitektur MVVM**: Menjelaskan pemisahan file `models`, `services`, `viewmodels`, dan `views`.
3. **Panggilan API & Parsing**: Menjelaskan `ApiService.dart` (Geocoding & Forecast) serta konversi data JSON ke model Dart.
4. **Local Storage**: Menjelaskan implementasi `SharedPreferences` pada `StorageService.dart` untuk menyimpan riwayat dan daftar favorit.
5. **State Management**: Menjelaskan bagaimana `WeatherViewModel` dan `SearchViewModel` memperbarui UI secara reaktif melalui `notifyListeners()` dan `Consumer`.
6. **Demo Aplikasi**: Menunjukkan alur pencarian kota, melihat detail cuaca, menyimpan favorit, serta penanganan kondisi error/offline.
