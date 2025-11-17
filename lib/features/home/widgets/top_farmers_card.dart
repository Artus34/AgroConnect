import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../controllers/farmer_provider.dart';

class TopFarmersCard extends StatelessWidget {
  const TopFarmersCard({super.key});

  // Define the very light brown color for the card background, matching the NewsPanel
  static const Color _lightBrownBackground = Color(0xFFF5F5DC); // Beige
  // Define the default black color for text
  static const Color _darkTextColor = Colors.black87;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // ⭐️ CHANGE: Set card color to light brown
      color: _lightBrownBackground,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Featured Farmers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                // ⭐️ CHANGE: Set title text color to dark
                color: _darkTextColor,
              ),
            ),
            const SizedBox(height: 12),
            
            Consumer<FarmerProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(color: AppColors.primaryGreen),
                    ),
                  );
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (provider.farmers.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('No farmers available right now.', style: TextStyle(color: _darkTextColor)),
                    ),
                  );
                }

                return _buildFarmersList(provider.farmers);
              },
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildFarmersList(List<UserModel> farmers) {
    return ListView.builder(
      
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: farmers.length,
      itemBuilder: (context, index) {
        final farmer = farmers[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          
          leading: CircleAvatar(
            backgroundColor: Colors.black,
            backgroundImage: farmer.profileImageUrl != null && farmer.profileImageUrl!.isNotEmpty
                ? NetworkImage(farmer.profileImageUrl!)
                : null,
            child: farmer.profileImageUrl == null || farmer.profileImageUrl!.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null, 
          ),
          title: Text(
            farmer.name,
            style: const TextStyle(fontWeight: FontWeight.w600, color: _darkTextColor), // ⭐️ CHANGE: Set title color to dark
          ),
          subtitle: const Text(
            'Farmer', 
            style: TextStyle(color: Colors.grey), // Using a slightly darker grey for better contrast on light brown
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), // Adjusted color for trailing icon
          onTap: () {
            
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Viewing ${farmer.name}\'s profile')),
            );
          },
        );
      },
    );
  }
}
