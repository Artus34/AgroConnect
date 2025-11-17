import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class YieldPredictionProvider with ChangeNotifier {
  String? _predictedYield;
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _states = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _crops = [];
  List<Map<String, dynamic>> _seasons = [];
  
  String? get predictedYield => _predictedYield;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  List<Map<String, dynamic>> get states => _states;
  List<Map<String, dynamic>> get districts => _districts;
  List<Map<String, dynamic>> get crops => _crops;
  List<Map<String, dynamic>> get seasons => _seasons;

  Map<String, dynamic>? _allCategoryData;

  static const String _apiBaseUrl = 'https://renderagro.onrender.com';

  YieldPredictionProvider() {
    _loadCategoriesFromAssets();
  }


  void resetPrediction() {
    _predictedYield = null;
    _errorMessage = null;
    notifyListeners();
  }


  void setErrorMessage(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadCategoriesFromAssets() async {
    _isLoading = true;
    notifyListeners();

    try {
      final String jsonString = await rootBundle.loadString('assets/category_mappings.json');
      _allCategoryData = json.decode(jsonString);

      _states = List<Map<String, dynamic>>.from(_allCategoryData!['states']);
      _crops = List<Map<String, dynamic>>.from(_allCategoryData!['crops']);
      _seasons = List<Map<String, dynamic>>.from(_allCategoryData!['seasons']);

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load categories from assets: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void fetchDistrictsByState(String stateName) {
    if (_allCategoryData == null) {
      _errorMessage = 'Category data is not loaded.';
      notifyListeners();
      return;
    }
    

    final stateId = _states.firstWhere(
      (element) => element['name'] == stateName,
      orElse: () => {'id': null},
    )['id'];

    if (stateId != null) {
      final districtsData = _allCategoryData!['districts_by_state'][stateId.toString()];
      if (districtsData != null) {
        _districts = List<Map<String, dynamic>>.from(districtsData);
      } else {
        _districts = []; 
      }
    } else {
      _districts = []; 
    }
    
    notifyListeners();
  }

  Future<void> predictYield({
    required int stateId,
    required int districtId,
    required int cropId,
    required int seasonId,
    required int year,
    required double area,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _predictedYield = null;
    notifyListeners();

    try {
      final Map<String, dynamic> requestBody = {
        'state_id': stateId,
        'district_id': districtId,
        'crop_id': cropId,
        'season_id': seasonId,
        'year': year,
        'area': area,
      };

      final http.Response response = await http.post(
        Uri.parse('$_apiBaseUrl/predict'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _predictedYield = data['predicted_yield'].toString();
        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to get a prediction. Status code: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}