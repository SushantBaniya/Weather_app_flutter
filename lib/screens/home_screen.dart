import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/weather.dart';
import '../providers/weather_provider.dart';

import 'package:geolocator/geolocator.dart';

import 'forecast.dart';

final permisionProvider = FutureProvider<Position>((ref) async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    throw Exception(
      'Location permissions are permanently denied, we cannot request permissions.',
    );
  }

  final location = await Geolocator.getCurrentPosition();
  return location;
});

final locationProvider = FutureProvider<Weather>((ref) async {
  final position = ref.watch(permisionProvider.future);
  final weatherService = ref.watch(weatherServiceProvider);

  final weather = await position.then(
    (pos) => weatherService.getWeather(pos.latitude, pos.longitude),
  );
  if (weather == null) {
    throw Exception('Failed to fetch weather data');
  }
  return weather;
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends ConsumerState<HomeScreen> {
  Weather? weather;
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final weatherAsyncValue = ref.watch(locationProvider);
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
            child: weatherAsyncValue.when(
              data: (data) {
                weather = data;
                return Column(
                  children: [
                    HeaderSection(weather: data),
                    MiddleSection(weather: data),
                    OtherCity(weather: data),
                    DailyForecast(weather: data),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text(error.toString())),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: WeatherBottomNavBar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
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
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                describe(weather.code),
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Icon(iconFor(weather.code), color: const Color.fromARGB(255, 222, 221, 214), size: 140),
            ],
          ),
        ],
      ),
    );
  }
}

class MiddleSection extends StatelessWidget {
  final Weather weather;
  const MiddleSection({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          height: 120,
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${weather.temp.toStringAsFixed(0)}°C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                describe(weather.code),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  const Icon(Icons.air, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Wind ${weather.wind.toStringAsFixed(1)} km/h',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OtherCity extends StatelessWidget {
  final Weather weather;
  const OtherCity({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Other City:',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 18,
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 2,
            itemBuilder: (context, index) {
              return Container(
                width: 200,
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'City ${index + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Icon(iconFor(weather.code), color: const Color.fromARGB(255, 221, 220, 216), size: 40),
                    const SizedBox(height: 8),
                    Text(
                      '${weather.temp.toStringAsFixed(0)}°C',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class DailyForecast extends StatelessWidget {
  final Weather weather;
  const DailyForecast({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Forecast:',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForecastScreen()),
                );
              },
              child: const Text(
                '7-day forecast',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (context, index) {
              return Container(
                width: 100,
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${weather.daily[index].date.day}/${weather.daily[index].date.month}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      iconFor(weather.daily[index].code),
                      color: const Color.fromARGB(255, 245, 244, 238),
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${weather.daily[index].maxTemperature.toStringAsFixed(0)}°C',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class WeatherBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const WeatherBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  static const items = [
    Icons.home_rounded,
    Icons.location_on_rounded,
    Icons.calendar_month_rounded,
    Icons.settings_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = selectedIndex == index;

          return IconButton(
            onPressed: () => onItemSelected(index),
            icon: Icon(
              items[index],
              color: isSelected ? Colors.white : Colors.white60,
            ),
            style: IconButton.styleFrom(
              backgroundColor: isSelected
                  ? Colors.white.withValues(alpha: 0.16)
                  : Colors.transparent,
            ),
          );
        }),
      ),
    );
  }
}
