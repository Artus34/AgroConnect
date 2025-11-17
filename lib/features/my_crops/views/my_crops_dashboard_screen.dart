import 'package:agrolink/app/theme/app_colors.dart'; // Import AppColors
import 'package:agrolink/features/my_crops/models/crop_cycle_model.dart';
import 'package:agrolink/features/my_crops/views/add_crop_cycle_screen.dart';
import 'package:agrolink/features/my_crops/views/crop_cycle_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:agrolink/features/my_crops/controllers/my_crops_provider.dart';
import 'dart:ui'; // ⬅️ IMPORTED for ImageFilter

class MyCropsDashboardScreen extends StatefulWidget {
  const MyCropsDashboardScreen({super.key});

  @override
  State<MyCropsDashboardScreen> createState() => _MyCropsDashboardScreenState();
}

class _MyCropsDashboardScreenState extends State<MyCropsDashboardScreen> {
  // ❌ REMOVED initState: The initial data fetch is now handled by 
  // MainNavigationScreen whenever the 'My Crops' tab is selected.
  
  // ❌ REMOVED _fetchDataIfNeeded() / _fetchData() methods.

  @override
  Widget build(BuildContext context) {
    // This screen is responsible for its own Scaffold, AppBar, and FAB
    return Scaffold(
      // Set Scaffold background to transparent so the image/gradient can show through
      backgroundColor: Colors.transparent, 
      // ⬅️ AppBar REMOVED entirely to eliminate the empty space at the top.
      
      // Wrap the Consumer (which contains the body content) with a Container for the gradient
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage( // ⬅️ ADDED: Background Image
            image: AssetImage('assets/doodles.png'), // Replace with your image asset path
            fit: BoxFit.cover,
          ),
          // Gradient is now below the image if both are present.
          // If you want the gradient *over* the image, you'd stack them.
          // For now, it will apply the gradient first, then the image.
          // If the image fully covers, the gradient won't be seen.
          // If you want to see both, consider blending or reducing image opacity.
          // For this request, I will assume the image is the primary background.
          // I'm commenting out the gradient for clarity as per the request "add image" 
          // implying it replaces or overlays, and usually image is primary if present.
          // If you want both visible, let me know.
          // gradient: LinearGradient(
          //   colors: [
          //     Color(0xFF222222), // Dark Grey/Near Black (Top)
          //     Color(0xFFBBBBBB), // Medium Light Grey/White (Middle)
          //     Color(0xFF000000), // Pure Black (Bottom)
          //   ],
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          // ),
        ),
        child: BackdropFilter( // ⬅️ ADDED: BackdropFilter for blur effect
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0), // Adjust sigmaX/Y for desired blur strength
          child: Consumer<MyCropsProvider>(
            builder: (context, provider, child) {
              // If the provider is loading AND the list is empty, show spinner
              if (provider.isLoading && provider.myCycles.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Colors.white)); // Themed color for contrast
              }

              if (provider.errorMessage != null && provider.myCycles.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error: ${provider.errorMessage}',
                      style: const TextStyle(color: AppColors.errorRed), // Themed
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (provider.myCycles.isEmpty) {
                return const Center(
                  child: Text(
                    'You have no crop cycles yet.\nPress the "+" button to start one.',
                    textAlign: TextAlign.center,
                    // Changed text color to white for contrast
                    style: TextStyle(fontSize: 16, color: Colors.white70), 
                  ),
                );
              }

              // Main list of crop cycles
              return RefreshIndicator(
                onRefresh: () => provider.fetchMyCropCycles(), // Manual refresh still works
                color: AppColors.primaryGreen, // Themed
                child: ListView.builder(
                  // The ListView now starts immediately from the top of the screen's body.
                  padding: const EdgeInsets.only(top: 8, bottom: 80), // Added top padding for a slight offset from the screen edge
                  itemCount: provider.myCycles.length,
                  itemBuilder: (context, index) {
                    final cycle = provider.myCycles[index];
                    // Card color is still AppColors.lightCard, which will make 
                    // the card pop against the dark gradient.
                    return _buildCycleCard(context, cycle); 
                  },
                ),
              );
            },
          ),
        ),
      ),
      // --- FloatingActionButton is retained here ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigating to Add screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCropCycleScreen(),
            ),
          ).then((_) {
              // ⭐️ Optional: Force a fetch after the Add screen closes to immediately show the new cycle.
              Provider.of<MyCropsProvider>(context, listen: false).fetchMyCropCycles();
          });
        },
        backgroundColor: AppColors.primaryGreen, // Themed
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- _buildCycleCard remains the same ---
  Widget _buildCycleCard(BuildContext context, CropCycleModel cycle) {
    final DateFormat formatter = DateFormat('dd MMM, yyyy');
    final String plantingDate = formatter.format(cycle.plantingDate.toDate());

    // Calculate progress
    final totalSteps = cycle.planProgress.length;
    final completedSteps =
        cycle.planProgress.where((step) => step['isCompleted'] == true).length;
    final double progress = totalSteps > 0 ? (completedSteps / totalSteps) : 0;

    return Card(
      color: AppColors.lightCard, // Themed
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Consistent rounding
      clipBehavior: Clip.antiAlias, // Ensures InkWell respects border radius
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CropCycleDetailScreen(cycle: cycle),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cycle.displayName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary), // Themed
              ),
              const SizedBox(height: 4),
              Text(
                'Plant: ${cycle.plantType}',
                style: const TextStyle(fontSize: 16, color: AppColors.textSecondary), // Themed
              ),
              const SizedBox(height: 4),
              Text(
                'Planted on: $plantingDate',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progress: $completedSteps / $totalSteps steps', style: const TextStyle(color: AppColors.textSecondary)), // Themed
                  Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(color: AppColors.textSecondary)), // Themed
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.primaryGreen.withOpacity(0.2), // Themed background
                color: AppColors.primaryGreen, // Themed foreground
                  minHeight: 6, // Make slightly thicker
                  borderRadius: BorderRadius.circular(3), // Rounded corners
              ),
            ],
          ),
        ),
      ),
    );
  }
}