import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';
import '../models/weather_data.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String _geoBaseUrl = 'https://geocoding-api.open-meteo.com/v1/search';
  static const String _forecastBaseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Search locations by city name via Open-Meteo Geocoding API
  Future<List<LocationModel>> searchLocations(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final uri = Uri.parse(
      '$_geoBaseUrl?name=${Uri.encodeComponent(trimmed)}&count=10&language=id&format=json',
    );

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('results') && data['results'] is List) {
          final List<dynamic> results = data['results'];
          return results.map((item) => LocationModel.fromJson(item)).toList();
        }
        return [];
      } else {
        throw HttpException('Gagal memuat lokasi (Status ${response.statusCode})');
      }
    } on SocketException {
      throw const SocketException('Tidak ada koneksi internet. Silakan periksa jaringan Anda.');
    } catch (e) {
      if (e is SocketException || e is HttpException) rethrow;
      throw Exception('Terjadi kesalahan saat mencari lokasi: $e');
    }
  }

  /// Fetch weather forecast data by latitude & longitude via Open-Meteo Forecast API
  Future<WeatherData> getForecast(LocationModel location) async {
    final uri = Uri.parse(
      '$_forecastBaseUrl?'
      'latitude=${location.latitude}&'
      'longitude=${location.longitude}&'
      'current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m&'
      'daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,weather_code&'
      'timezone=auto',
    );

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return WeatherData.fromJson(location: location, json: data);
      } else {
        throw HttpException('Gagal memuat cuaca (Status ${response.statusCode})');
      }
    } on SocketException {
      throw const SocketException('Tidak ada koneksi internet. Silakan periksa jaringan Anda.');
    } catch (e) {
      if (e is SocketException || e is HttpException) rethrow;
      throw Exception('Terjadi kesalahan saat memuat data cuaca: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
