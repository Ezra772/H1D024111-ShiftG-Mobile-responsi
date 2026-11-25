import 'package:flutter/material.dart';

class WeatherCondition {
  final String description;
  final IconData icon;
  final LinearGradient gradient;

  const WeatherCondition({
    required this.description,
    required this.icon,
    required this.gradient,
  });
}

class WeatherCodes {
  static WeatherCondition getCondition(int code) {
    switch (code) {
      case 0:
        return const WeatherCondition(
          description: 'Cerah',
          icon: Icons.wb_sunny_rounded,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2196F3), Color(0xFF64B5F6), Color(0xFFFFB74D)],
          ),
        );
      case 1:
        return const WeatherCondition(
          description: 'Sebagian Besar Cerah',
          icon: Icons.wb_sunny_outlined,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E88E5), Color(0xFF90CAF9)],
          ),
        );
      case 2:
        return const WeatherCondition(
          description: 'Sebagian Berawan',
          icon: Icons.cloud_queue_rounded,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1976D2), Color(0xFF78909C)],
          ),
        );
      case 3:
        return const WeatherCondition(
          description: 'Berawan Tebal',
          icon: Icons.cloud_rounded,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF455A64), Color(0xFF90A4AE)],
          ),
        );
      case 45:
      case 48:
        return const WeatherCondition(
          description: 'Berkabut',
          icon: Icons.foggy,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF546E7A), Color(0xFFB0BEC5)],
          ),
        );
      case 51:
      case 53:
      case 55:
        return const WeatherCondition(
          description: 'Gerimis',
          icon: Icons.grain_rounded,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF37474F), Color(0xFF78909C)],
          ),
        );
      case 56:
      case 57:
        return const WeatherCondition(
          description: 'Gerimis Beku',
          icon: Icons.ac_unit_rounded,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF37474F), Color(0xFF81D4FA)],
          ),
        );
      case 61:
        return const WeatherCondition(
          description: 'Hujan Ringan',
          icon: Icons.water_drop_outlined,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF263238), Color(0xFF546E7A)],
          ),
        );
      case 63:
        return const WeatherCondition(
          description: 'Hujan Sedang',
          icon: Icons.water_drop_rounded,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF263238), Color(0xFF455A64)],
          ),
        );
      case 65:
        return const WeatherCondition(
          description: 'Hujan Lebat',
          icon: Icons.thunderstorm_rounded,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF37474F)],
          ),
        );
      case 66:
      case 67:
        return const WeatherCondition(
          description: 'Hujan Dingin Beku',
          icon: Icons.ac_unit_rounded,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF263238), Color(0xFF4FC3F7)],
          ),
        );
      case 71:
      case 73:
      case 75:
      case 77:
        return const WeatherCondition(
          description: 'Salju',
          icon: Icons.snowing,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF37474F), Color(0xFFB0BEC5)],
          ),
        );
      case 80:
      case 81:
      case 82:
        return const WeatherCondition(
          description: 'Hujan Lokal',
          icon: Icons.grain_rounded,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF263238), Color(0xFF607D8B)],
          ),
        );
      case 85:
      case 86:
        return const WeatherCondition(
          description: 'Hujan Salju Lebat',
          icon: Icons.cloudy_snowing,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF263238), Color(0xFF90A4AE)],
          ),
        );
      case 95:
        return const WeatherCondition(
          description: 'Badai Petir',
          icon: Icons.bolt_rounded,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF102027), Color(0xFF37474F)],
          ),
        );
      case 96:
      case 99:
        return const WeatherCondition(
          description: 'Badai Petir & Hujan Es',
          icon: Icons.flash_on_rounded,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
          ),
        );
      default:
        return const WeatherCondition(
          description: 'Cerah Berawan',
          icon: Icons.cloud_outlined,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E88E5), Color(0xFF64B5F6)],
          ),
        );
    }
  }
}
