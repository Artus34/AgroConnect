import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import '../services/weather_service.dart'; // Import the service and its WeatherData class

class WeatherProvider with ChangeNotifier {
  WeatherData? _weatherData;
  WeatherData? get weatherData => _weatherData;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final WeatherService _weatherService = WeatherService();

  // --- State for Manual Location ---
  String _selectedLocation = ''; // Start empty or with a default city like 'Pune'
  static const String _locationPrefKey = 'selected_weather_location';

  /// Returns the currently selected manual location.
  String get selectedLocation => _selectedLocation;
  // --- END State ---

  WeatherProvider() {
    _loadSavedLocationAndFetchWeather(); // Load saved location on startup
  }

  // --- Load saved location ---
  Future<void> _loadSavedLocationAndFetchWeather() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocation = prefs.getString(_locationPrefKey);
      if (savedLocation != null && savedLocation.isNotEmpty) {
         _selectedLocation = savedLocation;
         // Fetch weather for the loaded location
         await fetchWeatherForecast(locationQuery: _selectedLocation, force: true);
      } else {
         _selectedLocation = ''; // Or set a default like 'Pune'
         // Don't fetch automatically if no location is saved/set
         _isLoading = false; // Stop loading if nothing to fetch
         notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading saved location: $e");
       _selectedLocation = ''; // Fallback to empty on error
       _isLoading = false; // Stop loading on error
       _errorMessage = "Could not load saved location.";
       notifyListeners();
    }
     // Loading state is handled within fetchWeatherForecast if called
  }

  // --- Method to update location from manual input ---
  Future<void> updateLocation(String newLocation) async {
    final locationToFetch = newLocation.trim();
    if (locationToFetch.isEmpty) {
        // Optionally set an error or just ignore empty input
        _setError("Please enter a location name.");
        return;
    };

    // Optimistically update the display name and start loading
    _selectedLocation = locationToFetch;
    _isLoading = true;
    _errorMessage = null; // Clear previous errors
    notifyListeners();

    // Save persistently
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_locationPrefKey, locationToFetch);
      debugPrint("Saved manual location: $locationToFetch");
    } catch (e) {
      debugPrint("Error saving location preference: $e");
      // Continue fetching anyway
    }

    // Fetch weather for the new location
    await fetchWeatherForecast(locationQuery: locationToFetch, force: true);
  }


  /// Fetches weather for the specified location (expects city name).
  Future<void> fetchWeatherForecast({required String locationQuery, bool force = false}) async {

    // Prevent fetching if already loading or if data exists for the same query and not forced
     if (_isLoading && !force) return; // Basic check to avoid concurrent fetches
     if (_weatherData != null && !force && locationQuery == _weatherData!.location.name) {
      return; // Data already loaded for this location
    }

    _isLoading = true;
    _errorMessage = null; // Clear previous errors on new fetch attempt
    notifyListeners();

    try {
      debugPrint("Fetching weather for manual query: $locationQuery");
      _weatherData = await _weatherService.fetchWeather(locationQuery);

      // Update the selected location name to match the API response exactly
      // (e.g., handles case differences or minor name variations)
      if (_weatherData != null) {
          _selectedLocation = _weatherData!.location.name;
      }

    } catch (e) {
      _errorMessage = "Failed to get weather for '$locationQuery'. Check connection or location name.";
      _weatherData = null; // Clear old data on error
      debugPrint("WeatherProvider Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI of final state (data loaded or error)
    }
  }

  // Helper to set error message
   void _setError(String message) {
    _errorMessage = message;
    _isLoading = false; // Stop loading on error
    if(kDebugMode) print("WeatherProvider Error: $message");
    notifyListeners(); // Notify UI about the error message change
  }
}

