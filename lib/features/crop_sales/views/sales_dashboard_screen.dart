import 'package:agrolink/app/theme/app_colors.dart'; // Import AppColors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // Import for ImageFilter
import '../../auth/controllers/auth_provider.dart';
import '../controllers/sales_provider.dart';
import '../models/listing_model.dart';
import 'add_listing_screen.dart'; // Target screen for listing products
import 'view_listing_screen.dart';


class SalesDashboardScreen extends StatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> {
  @override
  void initState() {
    super.initState();

    // Fetch listings when the screen loads if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
            final provider = Provider.of<SalesProvider>(context, listen: false);
            if (provider.allListings.isEmpty) { // Fetch only if empty
                provider.fetchAllListings();
            }
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Check if the current user is a farmer
    final authProvider = context.watch<AuthProvider>();
    final bool isFarmer = authProvider.userModel?.role == 'farmer';

    // 2. Wrap the existing Scaffold in a Container for the background image
    return Container( 
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/doodles.png'), // ⬅️ Your background image
          fit: BoxFit.cover,
          repeat: ImageRepeat.repeat, // Repeat the pattern if desired
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // ⬅️ IMPORTANT: Keep Scaffold background transparent
        // 3. Wrap the body with BackdropFilter to apply blur
        body: BackdropFilter( 
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0), // ⬅️ Blurring the background
          child: Column(
            children: [

              // Search Bar Container (New Container added for white background)
              Container( 
                color: Colors.white, // ⬅️ ADDED: White background for the search bar area
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 8.0),
                  child: TextField(
                    decoration: InputDecoration( // Use themed decoration
                      labelText: 'Search Products',
                      hintText: 'e.g., Apple, Wheat, Tomato',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                        borderSide: BorderSide(color: AppColors.primaryGreen.withOpacity(0.5)), // Themed border
                      ),
                      focusedBorder: OutlineInputBorder( // Themed focused border
                          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                      ),
                    ),

                    onChanged: (value) {
                      // Debouncing could be added here for performance
                      Provider.of<SalesProvider>(context, listen: false).updateSearchQuery(value);
                    },
                  ),
                ),
              ),

              // Listings Grid (Remains the same)
              Expanded(
                child: Consumer<SalesProvider>(
                  builder: (context, provider, child) {

                    if (provider.isLoading && provider.allListings.isEmpty) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)); // Themed indicator
                    }

                    if (provider.errorMessage != null && provider.allListings.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            provider.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.errorRed), // Themed error color
                          ),
                        ),
                      );
                    }

                    if (provider.allListings.isNotEmpty && provider.filteredListings.isEmpty) {
                      return const Center(
                        child: Text(
                          'No products found matching your search.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: AppColors.textSecondary), // Themed text color
                        ),
                      );
                    }

                    if (provider.allListings.isEmpty) {
                      return const Center(
                        child: Text(
                          'No listings available at the moment.\nPlease check back later.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: AppColors.textSecondary), // Themed text color
                        ),
                      );
                    }

                    // Display the grid
                    return RefreshIndicator(
                      onRefresh: () => provider.fetchAllListings(),
                      color: AppColors.primaryGreen, // Themed refresh indicator
                      child: GridView.builder(
                        // Added top padding to separate from search bar, and bottom padding for FAB
                        padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 80.0), 
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2, // Responsive columns
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                          childAspectRatio: 0.75, // Adjust as needed for card appearance
                        ),

                        itemCount: provider.filteredListings.length,
                        itemBuilder: (context, index) {
                          final listing = provider.filteredListings[index];
                          return _ListingCard(listing: listing);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // 3. Conditional Floating Action Button
        floatingActionButton: isFarmer
            ? FloatingActionButton.extended(
                onPressed: () {
                  // Navigate to the Add Listing Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddListingScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('List Product'),
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 4,
              )
            : null, // Only show if the user is a farmer
      ),
    );
  }
}


// _ListingCard widget remains unchanged
class _ListingCard extends StatelessWidget {
  final ListingModel listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.lightCard, // Use AppColors
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewListingScreen(listing: listing),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: 'listing_image_${listing.listingId}',
                child: Image.network(
                  listing.imageUrl,
                  fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                    // Add loadingBuilder for better UX
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                          strokeWidth: 2,
                          color: AppColors.primaryGreen,
                      ));
                    },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary), // Themed text
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Available: ${listing.quantity} ${listing.unit}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13), // Themed text
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${listing.price.toStringAsFixed(2)} / ${listing.unit}',
                      style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600), // Themed price
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'by ${listing.sellerName}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}