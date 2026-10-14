import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class City {
  final String name;
  final double lat, lon;
  City({
    required this.name,
    required this.lat,
    required this.lon,
  });
}

class WeatherService {
  Future<City?> getCity(String cityName) async {
    final url = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {'name': cityName, 'count': 1});
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        final cityData = data['results'][0];
        return City(
          name: cityData['name'],
          lat: cityData['latitude'],
          lon: cityData['longitude'],
        );
      }
    }
    return null;
  }

  Future<Weather?> getWeather(double lat, double lon) async {
    final url = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': lat.toString(),
      'longitude': lon.toString(),
      'current_weather': 'true',
      'daily': 'temperature_2m_max,temperature_2m_min,weathercode',
      'timezone': 'auto',
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Weather.fromJson(data);
    }
    return null;
  }
}