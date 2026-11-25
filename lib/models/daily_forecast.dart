class DailyForecast {
  final String dateString;
  final double maxTemperature;
  final double minTemperature;
  final int precipitationProbability;
  final int weatherCode;
  final String? sunrise;
  final String? sunset;

  DailyForecast({
    required this.dateString,
    required this.maxTemperature,
    required this.minTemperature,
    required this.precipitationProbability,
    required this.weatherCode,
    this.sunrise,
    this.sunset,
  });

  static List<DailyForecast> fromJsonList(Map<String, dynamic> json) {
    final times = (json['time'] as List<dynamic>?)?.cast<String>() ?? [];
    final maxTemps =
        (json['temperature_2m_max'] as List<dynamic>?)?.cast<num>() ?? [];
    final minTemps =
        (json['temperature_2m_min'] as List<dynamic>?)?.cast<num>() ?? [];
    final precipProbs =
        (json['precipitation_probability_max'] as List<dynamic>?)
                ?.cast<num>() ??
            [];
    final weatherCodes =
        (json['weather_code'] as List<dynamic>?)?.cast<num>() ?? [];
    final sunrises = (json['sunrise'] as List<dynamic>?)?.cast<String>() ?? [];
    final sunsets = (json['sunset'] as List<dynamic>?)?.cast<String>() ?? [];

    final List<DailyForecast> list = [];
    for (int i = 0; i < times.length; i++) {
      list.add(
        DailyForecast(
          dateString: times[i],
          maxTemperature:
              i < maxTemps.length ? maxTemps[i].toDouble() : 0.0,
          minTemperature:
              i < minTemps.length ? minTemps[i].toDouble() : 0.0,
          precipitationProbability:
              i < precipProbs.length ? precipProbs[i].toInt() : 0,
          weatherCode:
              i < weatherCodes.length ? weatherCodes[i].toInt() : 0,
          sunrise: i < sunrises.length ? sunrises[i] : null,
          sunset: i < sunsets.length ? sunsets[i] : null,
        ),
      );
    }
    return list;
  }
}
