import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/weather_codes.dart';
import '../../models/daily_forecast.dart';

class DailyForecastCard extends StatelessWidget {
  final DailyForecast forecast;
  final bool isToday;

  const DailyForecastCard({
    super.key,
    required this.forecast,
    this.isToday = false,
  });

  String _formatDate(String dateString) {
    if (isToday) return 'Hari ini';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE, d MMM', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final condition = WeatherCodes.getCondition(forecast.weatherCode);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isToday ? Theme.of(context).primaryColor.withAlpha(20) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isToday
            ? Border.all(
                color: Theme.of(context).primaryColor.withAlpha(60),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Date & Condition description
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(forecast.dateString),
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 14,
                    color: isToday
                        ? Theme.of(context).primaryColor
                        : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  condition.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Weather Icon
          Icon(
            condition.icon,
            color: Colors.orange.shade700,
            size: 26,
          ),
          const SizedBox(width: 14),

          // Rain Probability Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.water_drop,
                  size: 13,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 3),
                Text(
                  '${forecast.precipitationProbability}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Min / Max Temperature
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${forecast.minTemperature.round()}°',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
              const Text(
                ' / ',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                '${forecast.maxTemperature.round()}°',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
