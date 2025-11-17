import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrolink/features/crop_sales/controllers/sales_provider.dart';
import 'package:agrolink/features/crop_sales/views/sales_dashboard_screen.dart';

class SalesDashboardCard extends StatefulWidget {
  const SalesDashboardCard({super.key});

  @override
  State<SalesDashboardCard> createState() => _SalesDashboardCardState();
}

class _SalesDashboardCardState extends State<SalesDashboardCard> {
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      
      
      Provider.of<SalesProvider>(context, listen: false).fetchMyListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Consumer<SalesProvider>(
      builder: (context, salesProvider, child) {
        return GestureDetector(
          onTap: () {
            
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SalesDashboardScreen()),
            );
          },
          child: Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildCardContent(salesProvider), 
            ),
          ),
        );
      },
    );
  }

  
  Widget _buildCardContent(SalesProvider provider) {
    
    final activeListingsCount = provider.myListings.where((listing) => listing.isAvailable).length;

    
    final String message = activeListingsCount == 1
        ? 'You have 1 active listing'
        : 'You have $activeListingsCount active listings';

    return Row(
      children: [
        const Icon(Icons.storefront, size: 40, color: Colors.green),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Marketplace',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              if (provider.isLoading && provider.myListings.isEmpty)
                const Text('Loading your listings...')
              else
                Text(message),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios, color: Colors.grey),
      ],
    );
  }
}