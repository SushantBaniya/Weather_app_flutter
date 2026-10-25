import 'package:flutter_riverpod/flutter_riverpod.dart';

class CityNotifier extends Notifier<String> {
  @override
  String build()  {
    return '';
  }

  void setCity(String city)  =>
    state = city;
}

final cityServiceProvider = NotifierProvider<CityNotifier, String>(
  () => CityNotifier(),
);
