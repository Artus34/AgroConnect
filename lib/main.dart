import 'package:agrolink/features/home/controllers/farmer_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/theme/app_colors.dart';
import 'firebase_options.dart';

import 'features/auth/controllers/auth_provider.dart';
import 'features/auth/views/login_screen.dart';
import 'features/auth/views/signup_screen.dart';
import 'features/auth/views/auth_wrapper.dart';

// --- ADDED IMPORT FOR MAIN NAVIGATION SCREEN ---
import 'features/main_navigation/views/main_navigation_screen.dart';
// --- END ADDED IMPORT ---

import 'features/home/views/home_screen.dart'; // Still needed for screen access

import 'features/predictions/crop_prediction/controllers/crop_prediction_provider.dart';
import 'features/predictions/yield_prediction/controllers/yield_prediction_provider.dart';
import 'features/predictions/rainfall_prediction/controllers/rainfall_prediction_provider.dart';
import 'features/predictions/fertilizer_recommendation/controllers/fertilizer_recommendation_provider.dart';
import 'features/predictions/crop_prediction/views/crop_prediction_screen.dart';
import 'features/predictions/yield_prediction/views/yield_prediction_screen.dart';
import 'features/predictions/rainfall_prediction/views/rainfall_prediction_screen.dart';

import 'features/market_info/weather/controllers/weather_provider.dart';
import 'features/market_info/news/controllers/news_provider.dart';

import 'features/crop_sales/controllers/sales_provider.dart';

import 'features/crop_analysis/controllers/crop_analysis_provider.dart';

import 'features/chat_bot/views/chatbot_screen.dart';

// --- IMPORT ADDED FOR NEW FEATURE ---
import 'features/my_crops/controllers/my_crops_provider.dart';
import 'core/services/notification_service.dart'; // <<< NEW
import 'core/services/navigation_provider.dart'; // <<< NEW

// --- Global instance of the Notification Service ---
late final NotificationService notificationService;

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 1. Initialize Navigation Provider (its logic will be handled via Provider)
    final navProvider = NavigationProvider();

    // 2. Initialize Notification Service and link its callback to the Navigation Provider
    notificationService = NotificationService(
      onNotificationTapped: navProvider.navigateToTabFromPayload,
    );
    await notificationService.initialize();

    // 3. Start the repeating timer for random notifications
    notificationService.startNotificationTimer();

    // Pass the initialized navigation provider to MyApp
    runApp(MyApp(navProvider: navProvider));
  } catch (e) {
    debugPrint('--- FATAL ERROR DURING APP INITIALIZATION ---');
    debugPrint('ERROR: $e');
    debugPrint('---------------------------------------------');
  }
}

class MyApp extends StatelessWidget {
  // Pass the already created Navigation Provider instance
  final NavigationProvider navProvider;

  const MyApp({super.key, required this.navProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // --- ADDED NAVIGATION PROVIDER ---
        ChangeNotifierProvider.value(value: navProvider), // <<< NEW
        // ---------------------------------
        
        // ⭐️ FIX: Reverting to standard Provider creation.
        // The AuthProvider constructor now handles the subscription automatically.
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        
        ChangeNotifierProxyProvider<AuthProvider, SalesProvider>(
          create: (context) => SalesProvider(),
          update: (context, authProvider, previousSalesProvider) =>
              previousSalesProvider!..update(authProvider),
        ),

        // --- PROVIDER ADDED FOR NEW FEATURE ---
        ChangeNotifierProxyProvider<AuthProvider, MyCropsProvider>(
          create: (context) => MyCropsProvider(),
          update: (context, authProvider, previousCropsProvider) =>
              previousCropsProvider!..update(authProvider),
        ),
        // --- END OF ADDED PROVIDER ---

        ChangeNotifierProvider(create: (context) => CropPredictionProvider()),
        ChangeNotifierProvider(create: (context) => YieldPredictionProvider()),
        ChangeNotifierProvider(create: (context) => RainfallPredictionProvider()),
        ChangeNotifierProvider(
            create: (context) => FertilizerRecommendationProvider()),
        ChangeNotifierProvider(create: (context) => WeatherProvider()),
        ChangeNotifierProvider(create: (context) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => CropAnalysisProvider()),
        ChangeNotifierProvider(create: (_) => FarmerProvider()),
      ],
      child: MaterialApp(
        title: 'Agrolink',
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: AppColors.lightScaffoldBackground,
          primaryColor: AppColors.primaryGreen,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: AppColors.lightScaffoldBackground,
            foregroundColor: AppColors.textPrimary,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/signup': (context) => const SignUpScreen(),
          '/chat-bot': (context) => const ChatbotScreen(),
          // Keep specific deep links for screens accessed via FeatureCards, as they bypass the bottom nav
          '/predict_crop': (context) => CropPredictionScreen(),
          '/predict_yield': (context) => YieldPredictionScreen(),
          '/predict_rainfall': (context) => const RainfallPredictionScreen(),
        },
      ),
    );
  }
}