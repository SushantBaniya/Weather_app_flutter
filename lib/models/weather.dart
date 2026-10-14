class DailyForecast {
  final DateTime date;
  final double maxTemperature;
  final double minTemperature;
  final int code;
  DailyForecast({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.code,
  });
}

class Weather {
  final double temp, wind;
  final int code;
  final List<DailyForecast> daily;
  Weather({
    required this.temp,
    required this.wind,
    required this.code,
    required this.daily,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final c = json['current'];
    final d = json['daily'];
    final days = List.generate(
    (d['time'] as List).length, (i) => DailyForecast(
          date: DateTime.parse(d['time'][i]),
          maxTemperature: d['temperature_2m_max'][i],
          minTemperature: d['temperature_2m_min'][i],
          code: d['weathercode'][i],
        )
    );

    return Weather(
      temp: c['temperature_2m'],
      wind: c['wind_speed_10m'],
      code: c['weather_code'],
      daily: days,
    );
  }
}