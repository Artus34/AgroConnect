// lib/core/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math';
import 'dart:async'; // Needed for Timer

// 1. Define possible navigation targets
enum PayloadKey {
  home, // Main Screen
  marketplace, // Crop Sales
  myCrops, // Crop Cycle Tracking
  predictions, // Predictions Screen
  none,
}

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  final Function(PayloadKey) onNotificationTapped;
  Timer? _timer;

  NotificationService({required this.onNotificationTapped});

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Use your app's icon

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          final payload = response.payload!;
          // Convert the string payload back to the enum key
          PayloadKey target = PayloadKey.values.firstWhere(
              (e) => e.toString().split('.').last == payload,
              orElse: () => PayloadKey.none);
          
          // Execute the external navigation callback
          onNotificationTapped(target);
        }
      },
    );
  }

  // --- 2. Define All 20 Targeted Notifications ---
  final Map<PayloadKey, List<Map<String, String>>> _notificationTemplates = {
    // Index 3 in main_navigation_screen
    PayloadKey.predictions: [
      {'title': '🌦 Rainfall Update:', 'body': 'New rain prediction available—tap to check impact on your crops.'},
      {'title': '🧪 Fertilizer Guide Ready:', 'body': 'Recommended fertilizer dose updated for your field.'},
      {'title': '🌾 Crop Suggestion Available:', 'body': 'Based on current soil and weather, new crop match found.'},
      {'title': '📈 Yield Forecast Updated:', 'body': 'Your estimated harvest has changed—view details now.'},
      {'title': '🔍 New Predictions Ready!', 'body': 'Tap to view rainfall, yield, crop, and fertilizer insights.'},
    ],
    // Index 0 in main_navigation_screen
    PayloadKey.home: [
      {'title': '👋 Welcome back!', 'body': 'Check today’s farming tasks to stay on schedule.'},
      {'title': '📌 Quick reminder:', 'body': 'Update your farm activity today for better tracking.'},
      {'title': '🌱 Tip of the Day:', 'body': 'Early morning irrigation reduces evaporation loss.'},
      {'title': '🚜 You have unread insights —', 'body': 'tap to continue improving your farm decisions.'},
      {'title': '📊 Your farm dashboard has new updates —', 'body': 'tap to view progress.'},
    ],
    // Index 2 in main_navigation_screen (Assuming My Crops is index 2)
    PayloadKey.myCrops: [
      {'title': '🌱 Sowing Stage:', 'body': 'Time to record seed variety and planting details.'},
      {'title': '🌿 Growth Check:', 'body': 'Update watering, pesticides, or field activity.'},
      {'title': '🌻 Mid-Season Alert:', 'body': 'Fertilizer or inspection may be due.'},
      {'title': '🌾 Harvest Window:', 'body': 'Estimated harvest date is approaching — prepare tools.'},
      {'title': '📘 Record Reminder:', 'body': 'Your crop cycle log needs an update for accuracy.'},
    ],
    // Index 1 in main_navigation_screen (Assuming Marketplace is index 1)
    PayloadKey.marketplace: [
      {'title': '💰 New Buyers Are Looking For Produce —', 'body': 'list your items now.'},
      {'title': '🛒 Marketplace Update:', 'body': 'Prices for wheat and pulses have changed.'},
      {'title': '📦 Order Alert:', 'body': 'Someone is interested in your listed item — tap to review.'},
      {'title': '🧑‍🌾 Fresh Listings Available:', 'body': 'Check new seeds, tools, and crops in the marketplace.'},
      {'title': '📜 Reminder:', 'body': 'Update your product availability to stay visible to buyers.'},
    ],
  };

  // --- 3. Scheduling Logic ---
  void startNotificationTimer() {
    // 10 minutes * 60 seconds = 600 seconds
    const duration = Duration(minutes: 10); 
    
    // Clear any existing timer to prevent duplicates
    _timer?.cancel(); 
    
    _timer = Timer.periodic(duration, (Timer t) {
      scheduleRandomNotification();
    });
  }

  void stopNotificationTimer() {
    _timer?.cancel();
  }

  Future<void> scheduleRandomNotification() async {
    final List<PayloadKey> allKeys = _notificationTemplates.keys.toList();
    final randomKey = allKeys[Random().nextInt(allKeys.length)];
    
    final notificationsForGroup = _notificationTemplates[randomKey]!;
    final notificationData = notificationsForGroup[Random().nextInt(notificationsForGroup.length)];

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'agro_reminders_channel',
      'Agri Reminders and Tips',
      channelDescription: 'Targeted notifications for farming activities and market updates.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _plugin.show(
      Random().nextInt(1000000), // Unique ID for the notification
      notificationData['title'],
      notificationData['body'],
      platformDetails,
      payload: randomKey.toString().split('.').last, // The navigation key
    );
  }
}