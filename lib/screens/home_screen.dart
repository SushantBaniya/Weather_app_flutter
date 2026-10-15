import 'package:flutter/material.dart';

import '../models/weather.dart';
import '../services/weather_service.dart';

import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  Weather? weather;
  bool _isLoading = true;
  String? _errorMessage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/clouds.png', fit: BoxFit.cover),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(0, 0, 0, 0.25),
                  Color.fromRGBO(0, 0, 0, 0.7),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [Expanded(child: HeaderSection(weather: weather!))],
            ),
          ),
          const Center(
            child: Text(
              'Weather App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _location();
  }

  Future<void> _location() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    final position = await Geolocator.getCurrentPosition();
    debugPrint('Latitude: ${position.latitude}');
    debugPrint('Longitude: ${position.longitude}');
    debugPrint('Position: $position');
    final weather = await WeatherService().getWeather(
      position.latitude,
      position.longitude,
    );
    debugPrint('Weather result: $weather');
    setState(() {
      this.weather = weather;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class HeaderSection extends StatelessWidget {
  final Weather weather;
  const HeaderSection({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.menu, color: Colors.white),
              const SizedBox(width: 8),
              const Icon(Icons.location_on, color: Colors.white),
              Text(
                'Current Location',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(width: 25),
              const Icon(Icons.more_vert, color: Colors.white),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  describe(weather.code),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Icon(iconFor(weather.code), color: Colors.yellow, size: 140),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
