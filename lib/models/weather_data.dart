import 'current_weather.dart';
import 'daily_forecast.dart';
import 'hourly_forecast.dart';
import 'location_model.dart';

class WeatherData {
  final LocationModel location;
  final CurrentWeather current;
  final List<DailyForecast> daily;
  final List<HourlyForecast> hourly;

  WeatherData({
    required this.location,
    required this.current,
    required this.daily,
    this.hourly = const [],
  });

  /// Returns up to 48 hours of forecast starting from the current local hour
  List<HourlyForecast> upcomingHours({int maxHours = 48}) {
    if (hourly.isEmpty) return [];
    final refTime = DateTime.tryParse(current.time) ?? DateTime.now();
    final refHour = DateTime(refTime.year, refTime.month, refTime.day, refTime.hour);

    final filtered = hourly.where((h) => !h.time.isBefore(refHour)).toList();
    if (filtered.isEmpty) return hourly.take(maxHours).toList();
    return filtered.take(maxHours).toList();
  }

  factory WeatherData.fromJson({
    required LocationModel location,
    required Map<String, dynamic> json,
  }) {
    final currentJson = json['current'] as Map<String, dynamic>? ?? {};
    final dailyJson = json['daily'] as Map<String, dynamic>? ?? {};
    final hourlyJson = json['hourly'] as Map<String, dynamic>? ?? {};

    return WeatherData(
      location: location,
      current: CurrentWeather.fromJson(currentJson),
      daily: DailyForecast.fromJsonList(dailyJson),
      hourly: HourlyForecast.fromJsonList(hourlyJson),
    );
  }
}
