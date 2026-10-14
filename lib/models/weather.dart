import 'package:flutter/material.dart';

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


String describe(int code) {
  if (code == 0) return 'Clear sky';
  if (code <= 3) return 'Partly cloudy';
  if (code <= 48) return 'Fog';
  if (code <= 67) return 'Rain';
  if (code <= 77) return 'Snow';
  if (code <= 82) return 'Showers';
  return 'Thunderstorm';
}

IconData iconFor(int code) {
  if (code == 0) return Icons.wb_sunny;
  if (code <= 3) return Icons.wb_cloudy;
  if (code <= 48) return Icons.foggy;
  if (code <= 82) return Icons.water_drop;
  return Icons.thunderstorm;
}