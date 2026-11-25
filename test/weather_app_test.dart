import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/constants/weather_codes.dart';
import 'package:weather_app/models/current_weather.dart';
import 'package:weather_app/models/daily_forecast.dart';
import 'package:weather_app/models/hourly_forecast.dart';
import 'package:weather_app/models/location_model.dart';
import 'package:weather_app/models/weather_data.dart';

void main() {
  group('Model Tests', () {
    test('LocationModel fromJson & toJson', () {
      final json = {
        'id': 1642911,
        'name': 'Jakarta',
        'latitude': -6.21462,
        'longitude': 106.84513,
        'country': 'Indonesia',
        'admin1': 'DKI Jakarta',
        'timezone': 'Asia/Jakarta',
      };

      final location = LocationModel.fromJson(json);
      expect(location.id, 1642911);
      expect(location.name, 'Jakarta');
      expect(location.latitude, -6.21462);
      expect(location.longitude, 106.84513);
      expect(location.country, 'Indonesia');
      expect(location.admin1, 'DKI Jakarta');
      expect(location.displayName, 'Jakarta, DKI Jakarta, Indonesia');

      final serialized = location.toJson();
      expect(serialized['id'], 1642911);
      expect(serialized['name'], 'Jakarta');
    });

    test('CurrentWeather fromJson parses correctly', () {
      final json = {
        'time': '2026-11-25T13:00',
        'interval': 900,
        'temperature_2m': 30.7,
        'relative_humidity_2m': 71,
        'apparent_temperature': 36.7,
        'precipitation': 0.20,
        'weather_code': 53,
        'wind_speed_10m': 8.8,
      };

      final current = CurrentWeather.fromJson(json);
      expect(current.temperature, 30.7);
      expect(current.relativeHumidity, 71);
      expect(current.apparentTemperature, 36.7);
      expect(current.precipitation, 0.20);
      expect(current.weatherCode, 53);
      expect(current.windSpeed, 8.8);
      expect(current.time, '2026-11-25T13:00');
    });

    test('DailyForecast fromJsonList parses forecast and sunrise/sunset', () {
      final dailyJson = {
        'time': ['2026-11-25', '2026-11-26'],
        'temperature_2m_max': [32.3, 30.0],
        'temperature_2m_min': [25.6, 23.9],
        'precipitation_probability_max': [95, 80],
        'weather_code': [80, 61],
        'sunrise': ['2026-11-25T05:26', '2026-11-26T05:26'],
        'sunset': ['2026-11-25T17:52', '2026-11-26T17:53'],
      };

      final forecasts = DailyForecast.fromJsonList(dailyJson);
      expect(forecasts.length, 2);
      expect(forecasts[0].dateString, '2026-11-25');
      expect(forecasts[0].maxTemperature, 32.3);
      expect(forecasts[0].minTemperature, 25.6);
      expect(forecasts[0].precipitationProbability, 95);
      expect(forecasts[0].weatherCode, 80);
      expect(forecasts[0].sunrise, '2026-11-25T05:26');
      expect(forecasts[0].sunset, '2026-11-25T17:52');

      expect(forecasts[1].dateString, '2026-11-26');
      expect(forecasts[1].maxTemperature, 30.0);
      expect(forecasts[1].minTemperature, 23.9);
      expect(forecasts[1].precipitationProbability, 80);
      expect(forecasts[1].weatherCode, 61);
    });

    test('HourlyForecast fromJsonList parses hourly data correctly', () {
      final hourlyJson = {
        'time': ['2026-11-25T13:00', '2026-11-25T14:00', '2026-11-25T15:00'],
        'temperature_2m': [31.0, 30.2, 29.1],
        'precipitation_probability': [40, 51, 35],
        'precipitation': [0.0, 0.2, 0.8],
        'weather_code': [2, 95, 53],
      };

      final hourly = HourlyForecast.fromJsonList(hourlyJson);
      expect(hourly.length, 3);
      expect(hourly[0].formattedHour, '13.00');
      expect(hourly[1].temperature, 30.2);
      expect(hourly[1].precipitationProbability, 51);
      expect(hourly[1].precipitation, 0.2);
      expect(hourly[1].weatherCode, 95);
    });

    test('WeatherData fromJson combines location, current, daily, and hourly', () {
      final location = LocationModel(
        id: 1,
        name: 'Bandung',
        latitude: -6.9175,
        longitude: 107.6191,
      );

      final fullJson = {
        'current': {
          'temperature_2m': 24.5,
          'relative_humidity_2m': 85,
          'apparent_temperature': 25.1,
          'precipitation': 1.5,
          'weather_code': 61,
          'wind_speed_10m': 5.2,
          'time': '2026-11-25T13:00',
        },
        'hourly': {
          'time': ['2026-11-25T12:00', '2026-11-25T13:00', '2026-11-25T14:00'],
          'temperature_2m': [24.0, 24.5, 25.0],
          'precipitation_probability': [60, 70, 50],
          'precipitation': [0.5, 1.5, 0.2],
          'weather_code': [61, 61, 51],
        },
        'daily': {
          'time': ['2026-11-25'],
          'temperature_2m_max': [27.0],
          'temperature_2m_min': [19.0],
          'precipitation_probability_max': [70],
          'weather_code': [61],
        },
      };

      final weatherData = WeatherData.fromJson(location: location, json: fullJson);
      expect(weatherData.location.name, 'Bandung');
      expect(weatherData.current.temperature, 24.5);
      expect(weatherData.daily.length, 1);
      expect(weatherData.hourly.length, 3);

      final upcoming = weatherData.upcomingHours();
      expect(upcoming.length, 2);
      expect(upcoming.first.formattedHour, '13.00');
    });
  });

  group('Weather Codes WMO Mapping Tests', () {
    test('Code 0 returns Cerah', () {
      final condition = WeatherCodes.getCondition(0);
      expect(condition.description, 'Cerah');
      expect(condition.assetPath, 'assets/images/hero_sunny.jpg');
    });

    test('Code 61 returns Hujan Ringan', () {
      final condition = WeatherCodes.getCondition(61);
      expect(condition.description, 'Hujan Ringan');
      expect(condition.assetPath, 'assets/images/hero_rainy.jpg');
    });

    test('Code 95 returns Badai Petir', () {
      final condition = WeatherCodes.getCondition(95);
      expect(condition.description, 'Badai Petir');
    });

    test('Night condition returns hero_night asset', () {
      final condition = WeatherCodes.getCondition(0, isNight: true);
      expect(condition.assetPath, 'assets/images/hero_night.jpg');
    });

    test('Unknown code returns fallback condition', () {
      final condition = WeatherCodes.getCondition(999);
      expect(condition.description, 'Cerah Berawan');
    });
  });
}
