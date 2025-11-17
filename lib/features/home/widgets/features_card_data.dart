import 'package:flutter/material.dart';

// This list now only contains data for the PREDICTION feature cards.
// It will be used by the PredictionsScreen.
final List<Map<String, dynamic>> featureCardsData = [
  {
    'icon': Icons.grass,
    'title': 'Predict Crop',
    'subtitle': 'Get AI-powered crop suggestions.'
    // Navigation is handled in PredictionsScreen
  },
  {
    'icon': Icons.trending_up,
    'title': 'Yield Prediction',
    'subtitle': 'Predict your crop yield.'
     // Navigation is handled in PredictionsScreen
  },
  // REMOVED 'Crop Analysis' card data
  // {
  //   'icon': Icons.show_chart,
  //   'title': 'Crop Analysis',
  //   'subtitle': 'View market and price trends.'
  // },
  {
    'icon': Icons.water_drop_outlined,
    'title': 'Predict Rainfall',
    'subtitle': 'Estimate annual rainfall.'
     // Navigation is handled in PredictionsScreen
  },
  {
    'icon': Icons.science_outlined,
    'title': 'Fertilizer Suggestion',
    'subtitle': 'Find the right fertilizer.'
     // Navigation is handled in PredictionsScreen
  },
  // REMOVED 'My Crops' card data
  // {
  //   'icon': Icons.checklist_rtl,
  //   'title': 'My Crops',
  //   'subtitle': 'Track your crop cycles and plans.'
  // },
];

