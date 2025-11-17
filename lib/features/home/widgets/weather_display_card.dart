import 'package:agrolink/features/market_info/weather/services/weather_service.dart';
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

import '../../market_info/weather/views/weather_screen.dart';

class WeatherDisplayCard extends StatelessWidget {
  final WeatherData weatherData;
  const WeatherDisplayCard({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    final current = weatherData.current;
    final location = weatherData.location;

    return Card(
      elevation: 4.0,
      // Remove color: AppColors.lightCard here, as the gradient will take over
      // color: AppColors.lightCard, // ⬅️ REMOVE THIS LINE
      shadowColor: AppColors.primaryGreen.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WeatherScreen()),
          );
        },
        // ⬅️ Wrap your existing Padding with a Container for the gradient
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(16)), // Match Card's border radius
            gradient: LinearGradient(
              colors: [
                Color(0xFF07936F), // R: 7 G: 147 B: 111 (Deep Sea Green)
                Color(0xFF0E888D), // R: 14 G: 136 B: 141 (Teal/Dark Cyan)
                Color(0xFF1974BD), // R: 25 G: 116 B: 189 (Vibrant Blue)
                Color(0xFF2269DD), // R: 34 G: 105 B: 221 (Richer Blue)
              ],
              begin: Alignment.topLeft, // You can adjust this direction if you prefer
              end: Alignment.bottomRight, // Like Alignment.topCenter / bottomCenter
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${current.tempC.round()}°C',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                          color: Colors.white, // ⬅️ Changed text color for contrast
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location.name,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70, // ⬅️ Changed text color for contrast
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https:${current.iconUrl}',
                      width: 70,
                      height: 70,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.cloud_off, color: Colors.white70, size: 70), // ⬅️ Changed icon color for contrast
                    ),
                    Text(
                      current.conditionText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.white), // ⬅️ Changed text color for contrast
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}