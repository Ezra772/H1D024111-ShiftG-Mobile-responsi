class HourlyForecast {
  final DateTime time;
  final double temperature;
  final int precipitationProbability;
  final double precipitation;
  final int weatherCode;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.precipitationProbability,
    required this.precipitation,
    required this.weatherCode,
  });

  String get formattedHour {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h.$m';
  }

  static List<HourlyForecast> fromJsonList(Map<String, dynamic> json) {
    final times = (json['time'] as List<dynamic>?)?.cast<String>() ?? [];
    final temps =
        (json['temperature_2m'] as List<dynamic>?)?.cast<num>() ?? [];
    final precipProbs =
        (json['precipitation_probability'] as List<dynamic>?)?.cast<num>() ??
            [];
    final precips =
        (json['precipitation'] as List<dynamic>?)?.cast<num>() ?? [];
    final weatherCodes =
        (json['weather_code'] as List<dynamic>?)?.cast<num>() ?? [];

    final List<HourlyForecast> list = [];
    for (int i = 0; i < times.length; i++) {
      final parsedTime = DateTime.tryParse(times[i]);
      if (parsedTime == null) continue;

      list.add(
        HourlyForecast(
          time: parsedTime,
          temperature: i < temps.length ? temps[i].toDouble() : 0.0,
          precipitationProbability:
              i < precipProbs.length ? precipProbs[i].toInt() : 0,
          precipitation: i < precips.length ? precips[i].toDouble() : 0.0,
          weatherCode: i < weatherCodes.length ? weatherCodes[i].toInt() : 0,
        ),
      );
    }
    return list;
  }
}
