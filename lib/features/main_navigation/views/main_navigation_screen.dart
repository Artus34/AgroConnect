import 'package:agrolink/app/theme/app_colors.dart';
import 'package:agrolink/features/auth/views/profile_screen.dart';
import 'package:agrolink/features/crop_sales/views/sales_dashboard_screen.dart';
import 'package:agrolink/features/home/views/home_screen.dart';
import 'package:agrolink/features/my_crops/views/my_crops_dashboard_screen.dart';
import 'package:agrolink/features/predictions/views/predictions_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrolink/features/auth/controllers/auth_provider.dart';
import 'package:agrolink/features/my_crops/controllers/my_crops_provider.dart';
import 'package:agrolink/core/services/navigation_provider.dart'; // <<< NEW IMPORT
import 'package:agrolink/core/services/notification_service.dart'; // <<< NEW IMPORT (for initialization)

import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  // ❌ REMOVE: int _selectedIndex = 0; 
  
  static const int _myCropsIndex = 3;

  static const Color _lightGreenNavColor = Color.fromARGB(255, 192, 222, 160);

  // Define the screens corresponding to the indices:
  // 0: Home, 1: Predictions, 2: Sales, 3: My Crops
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    PredictionsScreen(),
    SalesDashboardScreen(),
    MyCropsDashboardScreen(),
  ];

  static const List<String> _widgetTitles = <String>[
    'AgroConnect',
    'Predictions',
    'Marketplace',
    'My Crops',
  ];

  static const List<Icon> _navBarIcons = [
    Icon(Icons.home, size: 30, color: Colors.black),
    Icon(Icons.online_prediction, size: 30, color: Colors.black),
    Icon(Icons.storefront, size: 30, color: Colors.black),
    Icon(Icons.grass, size: 30, color: Colors.black),
  ];

  @override
  void initState() {
    super.initState();
    // This is the cleanest place to ensure the notification service 
    // is initialized after the providers and context are available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get the navigation provider
      final navProvider = Provider.of<NavigationProvider>(context, listen: false);

      // Initialize the NotificationService, passing the provider's redirection method.
      // This service instance should ideally be created in main.dart
      // and passed down or accessed via a Singleton.
      
      // Assuming a simple setup where the service is a Singleton or managed:
      // For demonstration, let's assume we can create it here for linking:
      final notificationService = NotificationService(
          onNotificationTapped: navProvider.navigateToTabFromPayload
      );
      notificationService.initialize();
      notificationService.startNotificationTimer(); 
    });
  }


  void _onItemTapped(int index, NavigationProvider navProvider) {
    // 1. Update the index via the Provider
    navProvider.setIndex(index);
    
    // 2. Conditional data fetch logic
    if (index == _myCropsIndex) {
      final myCropsProvider = Provider.of<MyCropsProvider>(context, listen: false);
      myCropsProvider.fetchMyCropCycles();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the index from the NavigationProvider
    final navProvider = context.watch<NavigationProvider>();
    final _selectedIndex = navProvider.selectedIndex;
    
    // The rest of the user data logic remains the same
    final userModel = context.watch<AuthProvider>().userModel;
    final userImageUrl = userModel?.profileImageUrl;
    final userName = userModel?.name ?? 'User';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _widgetTitles[_selectedIndex],
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _lightGreenNavColor,
        elevation: 1,

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: CircleAvatar(
                backgroundColor: AppColors.primaryGreen,
                backgroundImage:
                    (userImageUrl != null && userImageUrl.isNotEmpty)
                        ? NetworkImage(userImageUrl!)
                        : null,
                child: (userImageUrl == null || userImageUrl.isEmpty)
                    ? Text(userInitial, style: const TextStyle(color: Colors.white))
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
      ),

      floatingActionButton: _selectedIndex == 0 ? FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, '/chat-bot'),
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            child: const Icon(Icons.support_agent_sharp),
          ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _selectedIndex,
        height: 60.0,
        items: _navBarIcons,

        color: _lightGreenNavColor,
        buttonBackgroundColor: AppColors.primaryGreen,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        // --- MODIFIED: Pass the navProvider to the onTap handler ---
        onTap: (index) => _onItemTapped(index, navProvider),
        // ----------------------------------------------------------

        letIndexChange: (index) => true,

      ),
    );
  }
}