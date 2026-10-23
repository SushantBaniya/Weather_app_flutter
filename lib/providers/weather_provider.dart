import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/weather_service.dart';

final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});
