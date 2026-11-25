import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/constants/weather_codes.dart';
import 'package:weather_app/models/current_weather.dart';
import 'package:weather_app/models/daily_forecast.dart';
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

    test('DailyForecast fromJsonList parses 7-day forecast correctly', () {
      final dailyJson = {
        'time': ['2026-11-25', '2026-11-26'],
        'temperature_2m_max': [32.3, 30.0],
        'temperature_2m_min': [25.6, 23.9],
        'precipitation_probability_max': [95, 80],
        'weather_code': [80, 61],
      };

      final forecasts = DailyForecast.fromJsonList(dailyJson);
      expect(forecasts.length, 2);
      expect(forecasts[0].dateString, '2026-11-25');
      expect(forecasts[0].maxTemperature, 32.3);
      expect(forecasts[0].minTemperature, 25.6);
      expect(forecasts[0].precipitationProbability, 95);
      expect(forecasts[0].weatherCode, 80);

      expect(forecasts[1].dateString, '2026-11-26');
      expect(forecasts[1].maxTemperature, 30.0);
      expect(forecasts[1].minTemperature, 23.9);
      expect(forecasts[1].precipitationProbability, 80);
      expect(forecasts[1].weatherCode, 61);
    });

    test('WeatherData fromJson combines location, current, and daily', () {
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
    });
  });

  group('Weather Codes WMO Mapping Tests', () {
    test('Code 0 returns Cerah', () {
      final condition = WeatherCodes.getCondition(0);
      expect(condition.description, 'Cerah');
    });

    test('Code 61 returns Hujan Ringan', () {
      final condition = WeatherCodes.getCondition(61);
      expect(condition.description, 'Hujan Ringan');
    });

    test('Code 95 returns Badai Petir', () {
      final condition = WeatherCodes.getCondition(95);
      expect(condition.description, 'Badai Petir');
    });

    test('Unknown code returns fallback condition', () {
      final condition = WeatherCodes.getCondition(999);
      expect(condition.description, 'Cerah Berawan');
    });
  });
}
