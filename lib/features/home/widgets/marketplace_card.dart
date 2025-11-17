import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class MarketplaceCard extends StatelessWidget {
  final VoidCallback onTap;

  const MarketplaceCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      
      color: AppColors.botBubble, 
      elevation: 1,
      shadowColor: AppColors.primaryGreen.withOpacity(0.1),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Row(
            children: [
              
              Icon(
                Icons.storefront_outlined,
                size: 40,
                color: AppColors.primaryGreen,
              ),
              SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Marketplace',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Buy and sell farm produce directly.',
                      style: TextStyle(
                        fontSize: 14,
                        
                        color: AppColors.textSecondary, 
                      ),
                    ),
                  ],
                ),
              ),
              
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: AppColors.primaryGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}