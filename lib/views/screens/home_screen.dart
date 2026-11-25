import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/weather_codes.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../widgets/daily_forecast_card.dart';
import '../widgets/error_state_view.dart';
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

  void _navigateToSearch() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
    if (mounted) {
      context.read<WeatherViewModel>().updateFavoriteStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherViewModel>(
      builder: (context, vm, child) {
        final location = vm.currentLocation;
        final weather = vm.weatherData;

        return Scaffold(
          appBar: AppBar(
            title: location != null
                ? Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 18,
                            color: Color(0xFF1E88E5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            location.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      if (location.country != null && location.country!.isNotEmpty)
                        Text(
                          location.admin1 != null && location.admin1!.isNotEmpty
                              ? '${location.admin1}, ${location.country}'
                              : location.country!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  )
                : const Text('Cuaca Terkini'),
            actions: [
              if (location != null)
                IconButton(
                  tooltip: vm.isFavorite ? 'Hapus dari Favorit' : 'Simpan ke Favorit',
                  icon: Icon(
                    vm.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: vm.isFavorite ? Colors.redAccent : Colors.grey.shade700,
                  ),
                  onPressed: () {
                    vm.toggleFavorite();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          vm.isFavorite
                              ? '${location.name} dihapus dari Favorit'
                              : '${location.name} ditambahkan ke Favorit',
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              IconButton(
                tooltip: 'Cari Kota',
                icon: const Icon(Icons.search_rounded),
                onPressed: _navigateToSearch,
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: _buildBody(vm, weather),
        );
      },
    );
  }

  Widget _buildBody(WeatherViewModel vm, dynamic weather) {
    if (vm.state == WeatherViewState.loading && weather == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Memuat data cuaca...',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
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

    final current = weather.current;
    final daily = weather.daily;
    final condition = WeatherCodes.getCondition(current.weatherCode);

    return RefreshIndicator(
      onRefresh: () => vm.refreshWeather(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Weather Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                gradient: condition.gradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Weather Icon and Condition description
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        condition.icon,
                        size: 32,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        condition.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Current Temperature
                  Text(
                    '${current.temperature.round()}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 68,
                      fontWeight: FontWeight.w200,
                      letterSpacing: -2,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                  // Apparent Temperature (Suhu yang dirasakan)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Terasa seperti ${current.apparentTemperature.round()}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  if (daily.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Maks: ${daily.first.maxTemperature.round()}°C  •  Min: ${daily.first.minTemperature.round()}°C',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Additional Information Section (Info Tambahan)
            const Text(
              'Informasi Cuaca Tambahan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),

            // 2x3 Grid of Weather Metrics
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
                  iconColor: Colors.blue.shade600,
                ),
                WeatherStatChip(
                  icon: Icons.air_rounded,
                  label: 'Kecepatan Angin',
                  value: '${current.windSpeed} km/j',
                  iconColor: Colors.teal.shade600,
                ),
                WeatherStatChip(
                  icon: Icons.umbrella_rounded,
                  label: 'Peluang Hujan',
                  value: daily.isNotEmpty
                      ? '${daily.first.precipitationProbability}%'
                      : '0%',
                  iconColor: Colors.indigo.shade600,
                ),
                WeatherStatChip(
                  icon: Icons.grain_rounded,
                  label: 'Curah Hujan',
                  value: '${current.precipitation} mm',
                  iconColor: Colors.lightBlue.shade600,
                ),
                WeatherStatChip(
                  icon: Icons.thermostat_rounded,
                  label: 'Suhu Terasa',
                  value: '${current.apparentTemperature.round()}°C',
                  iconColor: Colors.orange.shade600,
                ),
                WeatherStatChip(
                  icon: Icons.compress_rounded,
                  label: 'Kode Cuaca',
                  value: 'WMO ${current.weatherCode}',
                  iconColor: Colors.deepPurple.shade600,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 7-Day Forecast Section (Perkiraan Harian)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Perkiraan Beberapa Hari ke Depan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '${daily.length} Hari',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Daily Forecast Cards List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: daily.length,
              itemBuilder: (context, index) {
                return DailyForecastCard(
                  forecast: daily[index],
                  isToday: index == 0,
                );
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
