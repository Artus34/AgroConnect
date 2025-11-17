import 'package:agrolink/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_provider.dart';
import 'login_screen.dart';
import '../../main_navigation/views/main_navigation_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // ⭐️ NEW STATE: Controls the minimum duration the loading screen is visible.
  bool _showMinimumLoading = true;
  
  @override
  void initState() {
    super.initState();
    
    // Enforce a minimum 1.5 second duration for the initial screen transition.
    // This matches the delay we added to the login function.
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showMinimumLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use select to optimize rebuilds, listening only to what's necessary
    final authProvider = context.watch<AuthProvider>();
    final authState = authProvider.authState;
    final isAuthCheckPending = authProvider.isCheckingInitialAuth;
    final isActionLoading = authProvider.isLoading;

    // 1. CRITICAL LOADING STATE CHECK
    // Show spinner if:
    // a) The AuthProvider is still checking Firebase state (first app load).
    // b) We are enforcing the minimum 1.5s delay AND the AuthProvider is not yet ready.
    // c) An action like Login or Signup is currently active (`isActionLoading`).
    if (isAuthCheckPending || (_showMinimumLoading && authState == AuthState.unknown) || isActionLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E272E), // Using dark background color for a smoother transition
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }
    
    // 2. Final destination determination (Only reached when all loading is complete)
    switch (authState) {
      case AuthState.loggedIn:
        return const MainNavigationScreen();

      case AuthState.loggedOut:
      case AuthState.unknown: // Should be equivalent to loggedOut at this point
        return LoginScreen();
    }
  }
}
