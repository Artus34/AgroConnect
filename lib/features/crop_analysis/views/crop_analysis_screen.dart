import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/crop_analysis_provider.dart';
import '../models/Price_data.dart'; 
import '../../../core/models/location_commodity.dart'; 

import '../../../app/theme/app_colors.dart'; 

class CropAnalysisScreen extends StatefulWidget {
  const CropAnalysisScreen({super.key});

  @override
  State<CropAnalysisScreen> createState() => _CropAnalysisScreenState();
}

class _CropAnalysisScreenState extends State<CropAnalysisScreen> {
  
  
  Widget _buildDropdown<T>({
    required T? selectedValue,
    required List<T> items,
    required void Function(T?) onChanged,
    required String hintText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.lightCard, 
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: selectedValue,
          hint: Text(hintText, style: const TextStyle(color: AppColors.textSecondary)),
          isExpanded: true,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16), 
          items: items.map<DropdownMenuItem<T>>((T value) {
            return DropdownMenuItem<T>(
              value: value,
              child: Text(value.toString()),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  
  Widget _buildMarketEntryCard(PriceData data) {
    return Card(
      elevation: 4,
      color: AppColors.lightCard, 
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.marketName, 
              
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
            ),
            const Divider(height: 10, color: AppColors.textSecondary),
            _buildPriceRow('Modal Price (per Quintal):', '₹${data.modalPrice}', AppColors.textPrimary),
            
            _buildPriceRow('Max Price (per Quintal):', '₹${data.maxPrice}', AppColors.errorRed),
            
            _buildPriceRow('Min Price (per Quintal):', '₹${data.minPrice}', AppColors.accentBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: AppColors.lightScaffoldBackground, 
      appBar: AppBar(
        title: const Text('Local Market Price Analysis', style: TextStyle(color: AppColors.fontPrimary)),
        
        backgroundColor: AppColors.primaryGreen,
        iconTheme: const IconThemeData(color: AppColors.fontPrimary),
      ),
      body: Consumer<CropAnalysisProvider>(
        builder: (context, provider, child) {
          
          Widget resultWidget;
          if (provider.isLoading && provider.marketPrices.isEmpty) {
            resultWidget = const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.primaryGreen)));
          } else if (provider.errorMessage != null) {
            
            resultWidget = Center(child: Padding(padding: const EdgeInsets.all(32.0), child: Text(provider.errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.errorRed))));
          } else if (provider.marketPrices.isEmpty) {
            
            resultWidget = const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text("No market data found for the selected filters.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary))));
          } else {
            resultWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
                  child: Text(
                    "Found ${provider.marketPrices.length} Market Entries:",
                    
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                ...provider.marketPrices.map(_buildMarketEntryCard).toList(),
              ],
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                _buildDropdown<Location>(
                  selectedValue: provider.selectedState,
                  items: provider.availableStates,
                  onChanged: provider.setSelectedState,
                  hintText: 'Select State',
                ),
                _buildDropdown<Location>(
                  selectedValue: provider.selectedDistrict,
                  items: provider.availableDistricts,
                  onChanged: provider.setSelectedDistrict,
                  hintText: 'Select District',
                ),
                _buildDropdown<Commodity>(
                  selectedValue: provider.selectedCommodity,
                  items: provider.availableCommodities,
                  onChanged: provider.setSelectedCommodity,
                  hintText: 'Select Commodity',
                ),
                
                const SizedBox(height: 20),
                
                resultWidget,
              ],
            ),
          );
        },
      ),
    );
  }
}