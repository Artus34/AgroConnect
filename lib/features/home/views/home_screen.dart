import 'package:agrolink/features/home/controllers/farmer_provider.dart';
import 'package:agrolink/features/home/widgets/top_farmers_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui'; // ⬅️ IMPORTED for ImageFilter

import '../../../app/theme/app_colors.dart';
import '../../auth/controllers/auth_provider.dart';
import '../../crop_analysis/controllers/crop_analysis_provider.dart';
import '../../market_info/weather/controllers/weather_provider.dart';
import '../../market_info/news/controllers/news_provider.dart';
import '../../market_info/weather/views/weather_screen.dart';
import '../../crop_analysis/views/crop_analysis_screen.dart'; // Import target screen

import '../widgets/weather_display_card.dart';
import '../widgets/news_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final newsProvider = Provider.of<NewsProvider>(context, listen: false);
        final farmerProvider =
            Provider.of<FarmerProvider>(context, listen: false);
        
        if (newsProvider.articles.isEmpty) newsProvider.fetchArticles();
        if (newsProvider.videos.isEmpty) newsProvider.fetchVideos();
        if (farmerProvider.farmers.isEmpty) farmerProvider.fetchTopFarmers(); 
      }
    });
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.userModel?.name ?? 'Guest';

    return Stack(
      children: [
        // 1. Background Image
        Positioned.fill(
          child: Image.asset(
            'assets/doodles.png', // ⬅️ Doodles background image
            fit: BoxFit.cover,
            repeat: ImageRepeat.repeat,
          ),
        ),
        // 2. Blur Filter
        Positioned.fill(
          child: BackdropFilter(
            // ⬅️ Applied blur filter
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: Container(
              // Optional: Add a subtle overlay color to make text readable
              color: AppColors.lightScaffoldBackground.withOpacity(0.3), // Adjust opacity
            ),
          ),
        ),
        
        // 3. Foreground Content
        Material( 
          color: Colors.transparent, 
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                // ⬅️ The main column needs to stretch to allow child elements to be full width
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ⬅️ START: Welcome Message Box
                  Card( // Using Card for a box-like appearance
                    // ⬅️ CHANGED: Set width to infinity to stretch from left to right edge (minus padding)
                    margin: EdgeInsets.zero, // Remove default card margin
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Using Card for a box-like appearance
                    // ⬅️ CHANGED: Set width to infinity to stretch from left to right edge (minus padding)
                    child: SizedBox(
                      width: double.infinity, 
                      child: Container(
                        color: Color(0xFFF5F5DC), // Semi-transparent background
                        // We use a Container inside the SizedBox/Card to hold the color and padding
                        child: Padding( 
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back, $userName!',
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Here's an overview of your farm.",
                                style:
                                    TextStyle(fontSize: 16, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // ⬅️ END: Welcome Message Box
                  const SizedBox(height: 24),

                  // Weather Card (Clickable to WeatherScreen)
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WeatherScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: _buildWeatherCard(),
                  ),
                  const SizedBox(height: 24),

                  // Top Farmers Card
                  const TopFarmersCard(),
                  const SizedBox(height: 24),

                  // News Panel
                  NewsPanel(onLaunchUrl: _launchUrl),
                  const SizedBox(height: 24),
                  
                  // Live Market Prices Button (already full width due to minimumSize and Column stretch)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CropAnalysisScreen()),
                      );
                    },
                    icon: const Icon(Icons.trending_up, size: 24),
                    label: const Text('View Live Market Prices'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen, 
                      foregroundColor: Colors.white, 
                      minimumSize: const Size(double.infinity, 50), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0), 
                      ),
                    ),
                  ),

                  // Padding at the very end
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherCard() {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.weatherData == null) {
          return const Card(
              color: AppColors.lightCard,
            child: SizedBox(
              height: 150,
              child: Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
            ),
          );
        }
        if (provider.errorMessage != null && provider.weatherData == null) {
          return Card(
              color: AppColors.lightCard,
              child: Container(
                height: 150,
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.center,
                child: Text(
                  "Could not load weather data.\n${provider.errorMessage}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
          );
        }
        if (provider.weatherData != null) {
          return WeatherDisplayCard(weatherData: provider.weatherData!);
        }
          return Card(
              color: AppColors.lightCard,
              child: Container(
                height: 150,
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.center,
                child: const Text(
                  "Tap here to enter a location and see the weather forecast.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
          );
      },
    );
  }
}