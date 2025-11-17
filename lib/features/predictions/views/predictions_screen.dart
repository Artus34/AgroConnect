import 'package:agrolink/app/theme/app_colors.dart';
import 'package:agrolink/features/home/widgets/feature_card.dart';
import 'package:agrolink/features/home/widgets/features_card_data.dart';
import 'package:flutter/material.dart';
import 'dart:ui'; // Import for ImageFilter

// Import the specific prediction screens for navigation
import '../../predictions/crop_prediction/views/crop_prediction_screen.dart';
import '../../predictions/yield_prediction/views/yield_prediction_screen.dart';
import '../../predictions/fertilizer_recommendation/views/fertilizer_recommendation_screen.dart';
import '../../predictions/rainfall_prediction/views/rainfall_prediction_screen.dart';

class PredictionsScreen extends StatelessWidget {
  const PredictionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the light green color for all boxes
    const Color lightGreenBoxColor = Colors.lightGreen; 

    // We use the full list directly as it now ONLY contains prediction cards
    final List<Map<String, dynamic>> predictionCards = featureCardsData;

    // Wrap the content in a Container to apply the background image
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/doodles.png'), // ⬅️ Doodles background image
          fit: BoxFit.cover,
          repeat: ImageRepeat.repeat, // Repeat the pattern
        ),
      ),
      child: BackdropFilter( // Add BackdropFilter for blur effect
        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0), // Adjust sigmaX/Y for desired blur strength
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    // Align the main column back to the start (left)
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      Container(
                        // **CHANGE:** This line makes the box stretch full width
                        width: double.infinity, 
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: lightGreenBoxColor, 
                          borderRadius: BorderRadius.circular(12), 
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        ),
                        child: Column(
                          // Align the text inside the header box back to the start (left)
                          crossAxisAlignment: CrossAxisAlignment.start, 
                          children: [
                            const Text(
                              'Farming Predictions',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary), 
                            ),
                            const SizedBox(height: 4), 
                            const Text(
                              "AI-powered tools to help you plan.",
                              style:
                                  TextStyle(fontSize: 16, color: AppColors.textSecondary), 
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24), 

                      // Feature Cards Grid for Predictions
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final itemWidth = (constraints.maxWidth - 16.0) / 2;
                          
                          return Wrap(
                            spacing: 16, 
                            runSpacing: 16, 
                            children: predictionCards.map((cardData) {
                              return SizedBox(
                                width: itemWidth, 
                                child: FeatureCard(
                                  icon: cardData['icon'],
                                  title: cardData['title'],
                                  subtitle: cardData['title'], 
                                  onTap: () {
                                    final String title = cardData['title'];
                                    if (title == 'Predict Crop') {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => CropPredictionScreen()));
                                    } else if (title == 'Yield Prediction') {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => YieldPredictionScreen()));
                                    } else if (title == 'Predict Rainfall') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const RainfallPredictionScreen()),
                                      );
                                    } else if (title == 'Fertilizer Suggestion') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const FertilizerRecommendationScreen()),
                                      );
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          );
                        }
                      ),
                      const SizedBox(height: 80), 
                    ],
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}