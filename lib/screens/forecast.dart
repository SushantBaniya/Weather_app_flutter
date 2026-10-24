import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../models/weather.dart';
import '../providers/city_service_provider.dart';
import '../providers/weather_provider.dart';
  
import '../services/weather_service.dart';

final cityWeatherProvider = FutureProvider<Weather?>((ref) async {
  final cityName = ref.watch(cityServiceProvider);
  final weatherService = ref.read(weatherServiceProvider);
  final location = await weatherService.getCity(cityName);
  if (location == null) return null;
  return await weatherService.getWeather(location.lat, location.lon);
});

class ForecastScreen extends ConsumerWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cityWeather = ref.watch(cityWeatherProvider);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/clouds.png', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(0, 0, 0, 0.25),
                  Color.fromRGBO(0, 0, 0, 0.7),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          SafeArea(
            child: cityWeather.when(
              data: (weather) {
                if (weather == null) {
                  return const Center(
                    child: Text(
                      'City not found',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  );
                }
                return Column(
                  children: [
                    const TopSection(),
                    MiddleSection(weather: weather),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Error: $error',
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopSection extends ConsumerStatefulWidget {
  const TopSection({super.key});

  @override
  ConsumerState<TopSection> createState() => _TopSectionState();
}

class _TopSectionState extends ConsumerState<TopSection> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SearchBar(
              controller: _controller,
              hintText: 'Search city',
              leading: const Icon(Icons.search, color: Colors.white),
              trailing: [
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () => _controller.clear(),
                ),
              ],
              backgroundColor: WidgetStatePropertyAll(
                Colors.white.withValues(alpha: 0.10),
              ),
              onSubmitted: (value) {
                ref.read(cityServiceProvider.notifier).setCity(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MiddleSection extends ConsumerStatefulWidget {
  const MiddleSection({super.key, required this.weather});
  final Weather weather;

  @override
  ConsumerState<MiddleSection> createState() => _MiddleSectionState();
}

class _MiddleSectionState extends ConsumerState<MiddleSection> {

  @override
  Widget build(BuildContext context) {
    final city = ref.watch(cityServiceProvider);
    final weather = widget.weather;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Forecast for $city',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 600,
            child: ListView.builder(
              itemCount: 7,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        height: 100,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${weather.daily[index].maxTemperature.toStringAsFixed(0)}°C',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
