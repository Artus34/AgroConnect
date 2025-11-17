import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrolink/features/auth/controllers/auth_provider.dart'; 
import 'package:agrolink/features/auth/views/profile_screen.dart';     

class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        
        return GestureDetector(
          onTap: () {
            
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          child: Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCardContent(context, authProvider),
              ),
            ),
          ),
        );
      },
    );
  }

  
  Widget _buildCardContent(BuildContext context, AuthProvider authProvider) {
    
    if (authProvider.isLoading && authProvider.userModel == null) {
      return const Center(
        key: ValueKey('loading'),
        child: SizedBox(
          height: 50,
          child: CircularProgressIndicator(),
        ),
      );
    }

    
    if (authProvider.userModel != null) {
      final user = authProvider.userModel!;
      return Row(
        key: const ValueKey('userLoggedIn'),
        children: [
          const Icon(Icons.account_circle, size: 40, color: Colors.blueAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name, 
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  user.email, 
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        ],
      );
    }

    
    return const Row(
      key: ValueKey('userLoggedOut'),
      children: [
        Icon(Icons.person_off, size: 40, color: Colors.grey),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Guest',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Tap to log in or sign up'),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios, color: Colors.grey),
      ],
    );
  }
}