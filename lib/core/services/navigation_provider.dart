// lib/core/services/navigation_provider.dart

import 'package:flutter/material.dart';
import 'package:agrolink/core/services/notification_service.dart'; // Import PayloadKey

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  // Method called by the BottomNavigationBar
  void setIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  // Method called by the NotificationService
  void navigateToTabFromPayload(PayloadKey target) {
    int newIndex;
    switch (target) {
      case PayloadKey.home:
        newIndex = 0;
        break;
      case PayloadKey.marketplace:
        newIndex = 2; // Matches your current SalesDashboardScreen index
        break;
      case PayloadKey.myCrops:
        newIndex = 3; // Matches your current MyCropsDashboardScreen index
        break;
      case PayloadKey.predictions:
        newIndex = 1; // Matches your current PredictionsScreen index
        break;
      case PayloadKey.none:
      default:
        return;
    }
    setIndex(newIndex);
  }
}