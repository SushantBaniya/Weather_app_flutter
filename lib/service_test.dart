import 'package:weather_app/services/weather_service.dart';

Future<void> main() async {
  final service = WeatherService();

  try {
    // Test 1: Find a city
    final city = await service.getCity('Kathmandu');

    if (city == null) {
      print('City not found');
      return;
    }

    print('City: ${city.name}');
    print('Latitude: ${city.lat}');
    print('Longitude: ${city.lon}');

    // Test 2: Fetch its weather
    final weather = await service.getWeather(city.lat, city.lon);

    if (weather == null) {
      print('Weather request failed');
      return;
    }

    print('Temperature: ${weather.temp}');
    print('Wind speed: ${weather.wind}');
    print('Weather code: ${weather.code}');
    for (final day in weather.daily) {
      print(
        'Date: ${day.date}, Max: ${day.maxTemperature}, Min: ${day.minTemperature}, Code: ${day.code}',
      );
    }
  } catch (e, stackTrace) {
    print('Error: $e');
    print(stackTrace);
  }
}
