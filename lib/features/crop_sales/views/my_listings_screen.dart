import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/sales_provider.dart';
import '../../auth/controllers/auth_provider.dart'; 


class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
        
        final salesProvider = Provider.of<SalesProvider>(context, listen: false);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        
        
        salesProvider.update(authProvider);

        
        salesProvider.fetchMyListings();
    });
  }

  
  Future<void> _showDeleteConfirmationDialog(BuildContext context, String listingId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this listing?'),
                Text('This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); 
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                
                
                Provider.of<SalesProvider>(context, listen: false).deleteListing(listingId);
                Navigator.of(dialogContext).pop(); 
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'), 
      ),
      body: Consumer<SalesProvider>(
        builder: (context, provider, child) {
          
          if (provider.isLoading && provider.myListings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          
          if (provider.errorMessage != null && provider.myListings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            );
          }

          
          if (provider.myListings.isEmpty) {
            return const Center(
              child: Text(
                'You have not posted any listings yet.\nTap the "+" button on the dashboard to create one.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          
          return RefreshIndicator(
            onRefresh: () => provider.fetchMyListings(),
            child: ListView.builder(
              itemCount: provider.myListings.length,
              itemBuilder: (context, index) {
                final listing = provider.myListings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12.0),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        listing.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, size: 60),
                      ),
                    ),
                    title: Text(
                      listing.productName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    
                    
                    subtitle: Text(
                      'Available: ${listing.quantity} ${listing.unit} | Price: ₹${listing.price} / ${listing.unit}',
                    ),
                    
                    
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min, 
                      children: [
                        Chip(
                          label: Text(
                            listing.isAvailable ? 'Available' : 'Sold',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: listing.isAvailable ? AppColors.primaryGreen : Colors.grey,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          tooltip: 'Delete Listing',
                          onPressed: () {
                            
                            _showDeleteConfirmationDialog(context, listing.listingId);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}