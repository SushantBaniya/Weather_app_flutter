import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_provider.dart';
import '../services/weather_service.dart';
import '../models/weather.dart';

class CityNotifier extends Notifier<String> {
  @override
  build()  {
    return '';
  }

  String setCity(String city)  =>
    state = city;
}

final cityServiceProvider = NotifierProvider<CityNotifier, String>(
  () => CityNotifier(),
);
