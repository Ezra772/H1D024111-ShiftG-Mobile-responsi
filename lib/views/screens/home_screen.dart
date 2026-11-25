import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/weather_codes.dart';
import '../../models/weather_data.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../widgets/daily_forecast_card.dart';
import '../widgets/error_state_view.dart';
import '../widgets/glass_card.dart';
import '../widgets/hourly_forecast_card.dart';
import '../widgets/hourly_precipitation_card.dart';
import '../widgets/weather_stat_chip.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherViewModel>().init();
    });
  }

  Future<void> _navigateToSearch({required bool autofocusSearch}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchScreen(autofocusSearch: autofocusSearch),
      ),
    );
    if (mounted) {
      context.read<WeatherViewModel>().updateFavoriteStatus();
    }
  }

  bool _isNightTime(WeatherData? weather) {
    if (weather == null) return false;
    final currentDt = DateTime.tryParse(weather.current.time);
    if (currentDt == null) return false;
    return currentDt.hour >= 18 || currentDt.hour < 5;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Consumer<WeatherViewModel>(
        builder: (context, vm, child) {
          final weather = vm.weatherData;
          final currentCode = weather?.current.weatherCode ?? 1;
          final isNight = _isNightTime(weather);
          final condition = WeatherCodes.getCondition(
            currentCode,
            isNight: isNight,
          );

          return Scaffold(
            backgroundColor: condition.fadeBottomColor,
            body: Stack(
              children: [
                // 1. Atmospheric Base Gradient
                Container(
                  decoration: BoxDecoration(gradient: condition.gradient),
                ),

                // 2. Scenic Hero Background Illustration fading smoothly into gradient
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 460,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        condition.assetPath,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                      // Subtle top vignette for crisp white typography
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.35, 0.7, 1.0],
                            colors: [
                              Colors.black.withAlpha(45),
                              Colors.transparent,
                              condition.fadeBottomColor.withAlpha(90),
                              condition.fadeBottomColor,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Main Content Body
                SafeArea(
                  bottom: false,
                  child: _buildBody(vm, weather, condition),
                ),

                // 4. Floating Bottom Action Bar (List/Favorites left, Search right)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      18,
                      20,
                      MediaQuery.of(context).padding.bottom + 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          condition.fadeBottomColor.withAlpha(0),
                          condition.fadeBottomColor.withAlpha(215),
                          condition.fadeBottomColor,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _BottomActionIcon(
                          icon: Icons.playlist_add_check_rounded,
                          tooltip: 'Lokasi Favorit & Riwayat',
                          onTap: () => _navigateToSearch(autofocusSearch: false),
                        ),
                        _BottomActionIcon(
                          icon: Icons.search_rounded,
                          tooltip: 'Cari Kota',
                          onTap: () => _navigateToSearch(autofocusSearch: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    WeatherViewModel vm,
    WeatherData? weather,
    WeatherCondition condition,
  ) {
    if (vm.state == WeatherViewState.loading && weather == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'Memuat data cuaca...',
              style: TextStyle(
                color: Colors.white.withAlpha(230),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (vm.state == WeatherViewState.error && weather == null) {
      return ErrorStateView(
        message: vm.errorMessage ?? 'Gagal memuat data cuaca.',
        onRetry: () => vm.init(),
      );
    }

    if (weather == null) {
      return const SizedBox.shrink();
    }

    final location = weather.location;
    final current = weather.current;
    final daily = weather.daily;
    final upcomingHourly = weather.upcomingHours(maxHours: 48);

    double weekMin = 100.0;
    double weekMax = -100.0;
    for (final d in daily) {
      if (d.minTemperature < weekMin) weekMin = d.minTemperature;
      if (d.maxTemperature > weekMax) weekMax = d.maxTemperature;
    }

    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: const Color(0xFF1E3A4C),
      onRefresh: () => vm.refreshWeather(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.of(context).padding.bottom + 84,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Location Row + Favorite Toggle
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (location.country != null &&
                          location.country!.isNotEmpty)
                        Text(
                          location.admin1 != null &&
                                  location.admin1!.isNotEmpty &&
                                  location.admin1 != location.name
                              ? '${location.admin1}, ${location.country}'
                              : location.country!,
                          style: TextStyle(
                            color: Colors.white.withAlpha(210),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            shadows: const [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: vm.isFavorite
                      ? 'Hapus dari Favorit'
                      : 'Simpan ke Favorit',
                  icon: Icon(
                    vm.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: vm.isFavorite ? const Color(0xFFFF6B6B) : Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    final wasFav = vm.isFavorite;
                    vm.toggleFavorite();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          wasFav
                              ? '${location.name} dihapus dari Favorit'
                              : '${location.name} ditambahkan ke Favorit',
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Giant Hero Temperature
            Text(
              '${current.temperature.round()}°',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 80,
                fontWeight: FontWeight.w300,
                height: 1.0,
                letterSpacing: -2,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Weather Condition Description
            Text(
              condition.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Colors.black38,
                    blurRadius: 8,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 44),

            // Daily Min/Max & Apparent Temperature (Terasa seperti)
            if (daily.isNotEmpty)
              Text(
                '↑ ${daily.first.maxTemperature.round()}° / ↓ ${daily.first.minTemperature.round()}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      blurRadius: 6,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 2),
            Text(
              'Terasa seperti ${current.apparentTemperature.round()}°',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Colors.black38,
                    blurRadius: 6,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Card 1: Hourly Forecast + Temperature Line Curve + Senja/Terbit
            if (upcomingHourly.isNotEmpty) ...[
              HourlyForecastCard(
                hourly: upcomingHourly,
                daily: daily,
                currentDescription: condition.description,
              ),
              const SizedBox(height: 14),
            ],

            // Card 2: Hourly Precipitation mm Area Chart
            if (upcomingHourly.isNotEmpty) ...[
              SizedBox(
                height: 185,
                child: HourlyPrecipitationCard(hourly: upcomingHourly),
              ),
              const SizedBox(height: 14),
            ],

            // Card 3: 7-Day Forecast Glass Card
            if (daily.isNotEmpty) ...[
              GlassCard(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: Colors.white.withAlpha(200),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Perkiraan Beberapa Hari ke Depan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${daily.length} Hari',
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(color: Colors.white.withAlpha(30), height: 1),
                    const SizedBox(height: 4),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: daily.length,
                      separatorBuilder: (_, _) => Divider(
                        color: Colors.white.withAlpha(20),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        return DailyForecastCard(
                          forecast: daily[index],
                          isToday: index == 0,
                          weekMinTemp: weekMin,
                          weekMaxTemp: weekMax,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Card 4: Additional Weather Metrics Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: [
                WeatherStatChip(
                  icon: Icons.water_drop_rounded,
                  label: 'Kelembapan',
                  value: '${current.relativeHumidity}%',
                  iconColor: const Color(0xFF7DD3FC),
                ),
                WeatherStatChip(
                  icon: Icons.air_rounded,
                  label: 'Kecepatan Angin',
                  value: '${current.windSpeed} km/j',
                  iconColor: const Color(0xFF99F6E4),
                ),
                WeatherStatChip(
                  icon: Icons.umbrella_rounded,
                  label: 'Peluang Hujan',
                  value: daily.isNotEmpty
                      ? '${daily.first.precipitationProbability}%'
                      : '0%',
                  iconColor: const Color(0xFFA5B4FC),
                ),
                WeatherStatChip(
                  icon: Icons.grain_rounded,
                  label: 'Curah Hujan',
                  value: '${current.precipitation} mm',
                  iconColor: const Color(0xFFBAE6FD),
                ),
                WeatherStatChip(
                  icon: Icons.thermostat_rounded,
                  label: 'Suhu Terasa',
                  value: '${current.apparentTemperature.round()}°C',
                  iconColor: const Color(0xFFFCD34D),
                ),
                WeatherStatChip(
                  icon: Icons.wb_twilight_rounded,
                  label: 'Kode Cuaca',
                  value: 'WMO ${current.weatherCode}',
                  iconColor: const Color(0xFFFCA5A5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActionIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _BottomActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Tooltip(
          message: tooltip,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withAlpha(35),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
