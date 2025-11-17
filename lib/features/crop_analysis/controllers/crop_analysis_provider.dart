import 'package:flutter/material.dart';
import '../services/crop_analysis_service.dart';
import '../models/Price_data.dart';
import '../../../core/models/location_commodity.dart'; 

class CropAnalysisProvider with ChangeNotifier {
  final CropAnalysisService _service = CropAnalysisService();

  
  List<PriceData> _marketPrices = []; 
  bool _isLoading = false;
  String? _errorMessage;

  
  List<Location> _availableStates = [];
  List<Location> _availableDistricts = [];
  List<Commodity> _availableCommodities = [];

  Location? _selectedState;
  Location? _selectedDistrict;
  Commodity? _selectedCommodity;
  
  
  List<PriceData> get marketPrices => _marketPrices; 
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Location> get availableStates => _availableStates;
  List<Location> get availableDistricts => _availableDistricts;
  List<Commodity> get availableCommodities => _availableCommodities;

  Location? get selectedState => _selectedState;
  Location? get selectedDistrict => _selectedDistrict;
  Commodity? get selectedCommodity => _selectedCommodity;


  CropAnalysisProvider() {
    _initializeFilters();
  }

  Future<void> _initializeFilters() async {
    _isLoading = true;
    notifyListeners();

    try {
      
      await _service.initializeData();

      
      _availableStates = _service.availableStates;
      _availableDistricts = _service.availableDistricts;
      _availableCommodities = _service.availableCommodities;
      
      
      if (_availableStates.isNotEmpty) _selectedState = _availableStates.first;
      if (_availableDistricts.isNotEmpty) _selectedDistrict = _availableDistricts.first;
      if (_availableCommodities.isNotEmpty) _selectedCommodity = _availableCommodities.first;
      
      _isLoading = false;
      notifyListeners();
      
      
      if (_selectedState != null && _selectedDistrict != null && _selectedCommodity != null) {
        fetchMarketPrices();
      }

    } catch (e) {
      _errorMessage = 'Initialization Error: Data could not be loaded. Check JSON file and path.';
      _isLoading = false;
      notifyListeners();
    }
  }

  
  void setSelectedState(Location? state) {
    if (_selectedState != state) {
      _selectedState = state;
      
      notifyListeners();
      fetchMarketPrices();
    }
  }
  
  void setSelectedDistrict(Location? district) {
    if (_selectedDistrict != district) {
      _selectedDistrict = district;
      notifyListeners();
      fetchMarketPrices();
    }
  }
  
  void setSelectedCommodity(Commodity? commodity) {
    if (_selectedCommodity != commodity) {
      _selectedCommodity = commodity;
      notifyListeners();
      fetchMarketPrices();
    }
  }

  
  Future<void> fetchMarketPrices() async {
    if (_selectedCommodity == null || _selectedState == null || _selectedDistrict == null) return;

    _isLoading = true;
    _errorMessage = null;
    _marketPrices = [];
    notifyListeners();

    try {
      final fetchedData = await _service.fetchFilteredPriceData(
        commodityName: _selectedCommodity!.name,
        stateName: _selectedState!.name,
        districtName: _selectedDistrict!.name,
      );
      
      _marketPrices = fetchedData;
      
    } catch (e) {
      _errorMessage = 'Error fetching market data: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}