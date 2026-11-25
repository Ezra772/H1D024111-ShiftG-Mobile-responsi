import 'package:flutter/material.dart';

class AppColors {
  // Primary gradients for weather states
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color secondaryBlue = Color(0xFF64B5F6);
  static const Color darkBlue = Color(0xFF0D47A1);

  // Background gradients
  static const LinearGradient clearSkyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2196F3), Color(0xFF64B5F6), Color(0xFFBBDEFB)],
  );

  static const LinearGradient cloudyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF455A64), Color(0xFF78909C), Color(0xFFCFD8DC)],
  );

  static const LinearGradient rainyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF263238), Color(0xFF37474F), Color(0xFF546E7A)],
  );

  static const LinearGradient nightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
  );

  // Card & accents
  static const Color cardBackground = Colors.white;
  static const Color cardBackgroundDark = Color(0xFF1E293B);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color accentOrange = Color(0xFFFF9800);
}
