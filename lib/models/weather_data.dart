import 'current_weather.dart';
import 'daily_forecast.dart';
import 'location_model.dart';

class WeatherData {
  final LocationModel location;
  final CurrentWeather current;
  final List<DailyForecast> daily;

  WeatherData({
    required this.location,
    required this.current,
    required this.daily,
  });

  factory WeatherData.fromJson({
    required LocationModel location,
    required Map<String, dynamic> json,
  }) {
    final currentJson = json['current'] as Map<String, dynamic>? ?? {};
    final dailyJson = json['daily'] as Map<String, dynamic>? ?? {};

    return WeatherData(
      location: location,
      current: CurrentWeather.fromJson(currentJson),
      daily: DailyForecast.fromJsonList(dailyJson),
    );
  }
}
