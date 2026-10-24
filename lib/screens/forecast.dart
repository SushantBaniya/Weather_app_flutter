import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForecastScreen extends ConsumerWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [TopSection()],
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
  Widget build(BuildContext context) {
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
              backgroundColor: WidgetStatePropertyAll( Colors.white.withValues(alpha: 0.10)),
              onChanged: (value) {
                /* live typing */
              },
              onSubmitted: (value) {
                /* user pressed enter/search */
              },
            ),
          ),
        ],
      ),
    );
  }
}
