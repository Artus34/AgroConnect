import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FertilizerRecommendationProvider extends ChangeNotifier {
  static const String _apiBaseUrl = 'https://agrofertilizer.onrender.com';

  bool _isCategoryLoading = false;
  bool _isRecommendationLoading = false;

  String? _errorMessage;
  String? _recommendation;

  List<Map<String, dynamic>> _soilTypes = [];
  List<Map<String, dynamic>> _cropTypes = [];

  bool get isCategoryLoading => _isCategoryLoading;
  bool get isRecommendationLoading => _isRecommendationLoading;
  String? get errorMessage => _errorMessage;
  String? get recommendation => _recommendation;
  List<Map<String, dynamic>> get soilTypes => _soilTypes;
  List<Map<String, dynamic>> get cropTypes => _cropTypes;

  Future<void> fetchCategories() async {
    _isCategoryLoading = true;
    _clearError();
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$_apiBaseUrl/categories'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _soilTypes = List<Map<String, dynamic>>.from(data['soil_types']);
        _cropTypes = List<Map<String, dynamic>>.from(data['crop_types']);
      } else {
        _setErrorMessage('Failed to load categories. Please try again.');
      }
    } catch (e) {
      _setErrorMessage(
          'Network error: Check your internet connection or server status.');
    } finally {
      _isCategoryLoading = false;
      notifyListeners();
    }
  }

  Future<void> getFertilizerRecommendation(Map<String, dynamic> data) async {
    _isRecommendationLoading = true;
    _clearError();
    _resetRecommendation();
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/recommend'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _recommendation = responseData['recommended_fertilizer'];
      } else {
        final errorData = json.decode(response.body);
        _setErrorMessage(
            errorData['detail'] ?? 'Failed to get recommendation.');
      }
    } catch (e) {
      _setErrorMessage('Network error: Could not connect to the server.');
    } finally {
      _isRecommendationLoading = false;
      notifyListeners();
    }
  }

  void _setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void resetRecommendation() {
    _recommendation = null;
    notifyListeners();
  }

  void _resetRecommendation() {
    _recommendation = null;
  }
}
