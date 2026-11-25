import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/weather_codes.dart';
import '../../models/daily_forecast.dart';

class DailyForecastCard extends StatelessWidget {
  final DailyForecast forecast;
  final bool isToday;
  final double weekMinTemp;
  final double weekMaxTemp;

  const DailyForecastCard({
    super.key,
    required this.forecast,
    this.isToday = false,
    this.weekMinTemp = 18.0,
    this.weekMaxTemp = 36.0,
  });

  String _formatDate(String dateString) {
    if (isToday) return 'Hari ini';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final condition = WeatherCodes.getCondition(forecast.weatherCode);
    final totalSpan = (weekMaxTemp - weekMinTemp).abs() < 1.0
        ? 1.0
        : (weekMaxTemp - weekMinTemp);
    final startFraction =
        ((forecast.minTemperature - weekMinTemp) / totalSpan).clamp(0.0, 0.85);
    final widthFraction =
        ((forecast.maxTemperature - forecast.minTemperature) / totalSpan)
            .clamp(0.15, 1.0 - startFraction);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Day Name
          Expanded(
            flex: 3,
            child: Text(
              _formatDate(forecast.dateString),
              style: TextStyle(
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                fontSize: 15,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Rain Probability Badge
          SizedBox(
            width: 52,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.water_drop_rounded,
                  size: 13,
                  color: const Color(0xFF93C5FD),
                ),
                const SizedBox(width: 3),
                Text(
                  '${forecast.precipitationProbability}%',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Weather Condition Icon
          Icon(
            condition.icon,
            color: condition.iconColor,
            size: 22,
          ),
          const SizedBox(width: 14),

          // Min Temp
          SizedBox(
            width: 32,
            child: Text(
              '${forecast.minTemperature.round()}°',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withAlpha(180),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Temperature Range Bar
          Expanded(
            flex: 3,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barWidth = constraints.maxWidth;
                return Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: barWidth * startFraction,
                        width: barWidth * widthFraction,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF67E8F9),
                                Color(0xFFFDE047),
                                Color(0xFFFB923C),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),

          // Max Temp
          SizedBox(
            width: 32,
            child: Text(
              '${forecast.maxTemperature.round()}°',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
