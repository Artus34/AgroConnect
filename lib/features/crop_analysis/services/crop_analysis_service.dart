import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../models/Price_data.dart';
import '../../../core/models/location_commodity.dart'; 

class CropAnalysisService {
  static const String _jsonAssetPath = 'assets/comparison_prices.json';
  
  List<PriceData>? _allDataCache;
  
  
  List<Location> get availableStates => _extractUniqueLocations((p) => p.stateName);
  List<Location> get availableDistricts => _extractUniqueLocations((p) => p.districtName);
  List<Commodity> get availableCommodities => _extractUniqueCommodities((p) => p.commodityName);

  
  List<Location> _extractUniqueLocations(String Function(PriceData) getName) {
    if (_allDataCache == null) return [];
    
    final allNames = _allDataCache!.map(getName).toSet();
    return allNames.map((name) => Location(name.hashCode, name)).toList();
  }

  
  List<Commodity> _extractUniqueCommodities(String Function(PriceData) getName) {
    if (_allDataCache == null) return [];
    final allNames = _allDataCache!.map(getName).toSet();
    return allNames.map((name) => Commodity(name.hashCode, name)).toList();
  }

  
  Future<void> initializeData() async {
    if (_allDataCache != null) return; 

    try {
      final jsonString = await rootBundle.loadString(_jsonAssetPath);
      final List<dynamic> jsonList = jsonDecode(jsonString); 
      
      _allDataCache = jsonList.map(
          (json) => PriceData.fromJson(json as Map<String, dynamic>)
      ).toList();
      
    } catch (e) {
      print('Error loading or parsing JSON: $e');
      
      throw Exception('Failed to load local price data.'); 
    }
  }

  
  Future<List<PriceData>> fetchFilteredPriceData({
    required String commodityName,
    required String stateName,
    required String districtName,
  }) async {
    
    if (_allDataCache == null) {
      await initializeData();
    }
    
    
    return _allDataCache!.where(
      (p) => p.commodityName == commodityName && 
             p.stateName == stateName && 
             p.districtName == districtName
    ).toList();
  }
}