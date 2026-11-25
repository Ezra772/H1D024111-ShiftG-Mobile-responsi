import 'package:flutter/material.dart';

class WeatherCondition {
  final String description;
  final IconData icon;
  final Color iconColor;
  final LinearGradient gradient;
  final Color fadeBottomColor;
  final String assetPath;

  const WeatherCondition({
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.gradient,
    required this.fadeBottomColor,
    required this.assetPath,
  });
}

class WeatherCodes {
  static const LinearGradient _sunnyBgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4995D0), Color(0xFF4F87A8), Color(0xFF3E78A3)],
  );

  static const LinearGradient _rainyBgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4D6C7C), Color(0xFF3D5D6E), Color(0xFF2D4959)],
  );

  static const LinearGradient _nightBgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0E2038), Color(0xFF16304B), Color(0xFF1B3A57)],
  );

  static WeatherCondition getCondition(int code, {bool isNight = false}) {
    if (isNight) {
      final base = _getBaseCondition(code);
      return WeatherCondition(
        description: base.description,
        icon: code <= 1 ? Icons.nightlight_round : base.icon,
        iconColor: code <= 1 ? const Color(0xFFFDE68A) : base.iconColor,
        gradient: _nightBgGradient,
        fadeBottomColor: const Color(0xFF152E47),
        assetPath: 'assets/images/hero_night.jpg',
      );
    }
    return _getBaseCondition(code);
  }

  static WeatherCondition _getBaseCondition(int code) {
    switch (code) {
      case 0:
        return const WeatherCondition(
          description: 'Cerah',
          icon: Icons.wb_sunny_rounded,
          iconColor: Color(0xFFFBBF24),
          gradient: _sunnyBgGradient,
          fadeBottomColor: Color(0xFF4A8BB2),
          assetPath: 'assets/images/hero_sunny.jpg',
        );
      case 1:
        return const WeatherCondition(
          description: 'Sebagian Besar Cerah',
          icon: Icons.wb_sunny_rounded,
          iconColor: Color(0xFFFCD34D),
          gradient: _sunnyBgGradient,
          fadeBottomColor: Color(0xFF4A8BB2),
          assetPath: 'assets/images/hero_sunny.jpg',
        );
      case 2:
        return const WeatherCondition(
          description: 'Sebagian Berawan',
          icon: Icons.wb_cloudy_rounded,
          iconColor: Color(0xFFE2E8F0),
          gradient: _sunnyBgGradient,
          fadeBottomColor: Color(0xFF4A8BB2),
          assetPath: 'assets/images/hero_sunny.jpg',
        );
      case 3:
        return const WeatherCondition(
          description: 'Berawan Tebal',
          icon: Icons.cloud_rounded,
          iconColor: Color(0xFFCBD5E1),
          gradient: _rainyBgGradient,
          fadeBottomColor: Color(0xFF3E5E6F),
          assetPath: 'assets/images/hero_rainy.jpg',
        );
      case 45:
      case 48:
        return const WeatherCondition(
          description: 'Berkabut',
          icon: Icons.foggy,
          iconColor: Color(0xFFCBD5E1),
          gradient: _rainyBgGradient,
          fadeBottomColor: Color(0xFF3E5E6F),
          assetPath: 'assets/images/hero_rainy.jpg',
        );
      case 51:
      case 53:
      case 55:
        return const WeatherCondition(
          description: 'Gerimis',
          icon: Icons.grain_rounded,
          iconColor: Color(0xFF7DD3FC),
          gradient: _rainyBgGradient,
          fadeBottomColor: Color(0xFF3E5E6F),
          assetPath: 'assets/images/hero_rainy.jpg',
        );
      case 56:
      case 57:
        return const WeatherCondition(
          description: 'Gerimis Beku',
          icon: Icons.ac_unit_rounded,
          iconColor: Color(0xFFBAE6FD),
          gradient: _rainyBgGradient,
          fadeBottomColor: Color(0xFF3E5E6F),
          assetPath: 'assets/images/hero_rainy.jpg',
        );
      case 61:
        return const WeatherCondition(
          description: 'Hujan Ringan',
          icon: Icons.water_drop_rounded,
          iconColor: Color(0xFF7DD3FC),
          gradient: _rainyBgGradient,
          fadeBottomColor: Color(0xFF3E5E6F),
          assetPath: 'assets/images/hero_rainy.jpg',
        );
      case 63:
        return const WeatherCondition(
          description: 'Hujan Sedang',
          icon: Icons.water_drop_rounded,
          iconColor: Color(0xFF38BDF8),
          gradient: _rainyBgGradient,
          fadeBottomColor: Color(0xFF3E5E6F),
          assetPath: 'assets/images/hero_rainy.jpg',
        );
      case 65:
        return const WeatherCondition(
          description: 'Hujan Lebat',
          icon: Icons.thunderstorm_rounded,
          iconColor: Color(0xFFFACC15),
          gradient: _rainyBgGradient,
          fadeBottomColor: Color(0xFF3E5E6F),
          assetPath: 'assets/images/hero_rainy.jpg',
        );
      case 66:
      case 67:
        return const WeatherCondition(
          description: 'Hujan Dingin Beku',
          icon: Icons.ac_unit_rounded,
          iconColor: Color(0xFFBAE6FD),
          gradient: _rainyBgGradient,
          fadeBottomColor: Color(0xFF3E5E6F),
          assetPath: 'assets/images/hero_rainy.jpg',
        );
      case 71:
      case 73:
      case 75:
      case 77:
        return const WeatherCondition(
          description: 'Salju',
          icon: Icons.snowing,
          iconColor: Colors.white,
          gradient: _rainyBgGradient,
          fadeBottomColor: Color(0xFF3E5E6F),
          assetPath: 'assets/images/hero_rainy.jpg',
        );
      case 80:
      case 81:
      case 82:
        return const WeatherCondition(
          description: 'Hujan Lokal',
          icon: Icons.grain_rounded,
          iconColor: Color(0xFF7DD3FC),
          gradient: _rainyBgGradient,
          fadeBottomColor: Color(0xFF3E5E6F),
          assetPath: 'assets/images/hero_rainy.jpg',
        );
      case 85:
      case 86:
        return const WeatherCondition(
          description: 'Hujan Salju Lebat',
          icon: Icons.cloudy_snowing,
          iconColor: Colors.white,
          gradient: _rainyBgGradient,
          fadeBottomColor: Color(0xFF3E5E6F),
          assetPath: 'assets/images/hero_rainy.jpg',
        );
      case 95:
        return const WeatherCondition(
          description: 'Badai Petir',
          icon: Icons.thunderstorm_rounded,
          iconColor: Color(0xFFFACC15),
          gradient: _rainyBgGradient,
          fadeBottomColor: Color(0xFF3E5E6F),
          assetPath: 'assets/images/hero_rainy.jpg',
        );
      case 96:
      case 99:
        return const WeatherCondition(
          description: 'Badai Petir & Hujan Es',
          icon: Icons.flash_on_rounded,
          iconColor: Color(0xFFFACC15),
          gradient: _rainyBgGradient,
          fadeBottomColor: Color(0xFF3E5E6F),
          assetPath: 'assets/images/hero_rainy.jpg',
        );
      default:
        return const WeatherCondition(
          description: 'Cerah Berawan',
          icon: Icons.cloud_queue_rounded,
          iconColor: Colors.white,
          gradient: _sunnyBgGradient,
          fadeBottomColor: Color(0xFF4A8BB2),
          assetPath: 'assets/images/hero_sunny.jpg',
        );
    }
  }
}
