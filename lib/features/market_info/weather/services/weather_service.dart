import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';


class WeatherService {

  static const String _baseUrl = 'https://api.weatherapi.com/v1/forecast.json';

  Future<WeatherData> fetchWeather(String location) async {

    final apiKey = dotenv.env['WEATHER_API_KEY'];


    if (apiKey == null || apiKey.isEmpty) {
      debugPrint("API Key is missing from .env file.");
      throw Exception("API Key is not configured.");
    }

    final url = '$_baseUrl?key=$apiKey&q=$location&days=3&aqi=no&alerts=no';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedJson = json.decode(response.body);
        return WeatherData.fromJson(decodedJson);
      } else {
        debugPrint("API Error Response: ${response.body}");
        throw Exception(
          'Failed to load weather data. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint("Error fetching weather: $e");
      throw Exception('Failed to connect to the weather service.');
    }
  }
}


class WeatherData {
  final Location location;
  final Current current;
  final List<ForecastDay> forecastDays;

  WeatherData({
    required this.location,
    required this.current,
    required this.forecastDays,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    var forecastList = json['forecast']['forecastday'] as List;
    List<ForecastDay> days =
        forecastList.map((i) => ForecastDay.fromJson(i)).toList();

    return WeatherData(
      location: Location.fromJson(json['location']),
      current: Current.fromJson(json['current']),
      forecastDays: days,
    );
  }
}


class Location {
  final String name;
  final String region;
  final String country;

  Location({required this.name, required this.region, required this.country});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'] ?? 'Unknown Location',
      region: json['region'] ?? '',
      country: json['country'] ?? '',
    );
  }
}

class Current {
  final double tempC;
  final String conditionText;
  final String iconUrl;
  final double windKph;
  final int humidity;
  final double precipMm;
  final double feelslikeC;

  Current({
    required this.tempC,
    required this.conditionText,
    required this.iconUrl,
    required this.windKph,
    required this.humidity,
    required this.precipMm,
    required this.feelslikeC,
  });

  factory Current.fromJson(Map<String, dynamic> json) {
    return Current(
      tempC: (json['temp_c'] as num?)?.toDouble() ?? 0.0,
      conditionText: json['condition']['text'] ?? 'N/A',

      iconUrl: json['condition']['icon'] ?? '',
      windKph: (json['wind_kph'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['humidity'] as num?)?.toInt() ?? 0,
      precipMm: (json['precip_mm'] as num?)?.toDouble() ?? 0.0,
      feelslikeC: (json['feelslike_c'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ForecastDay {
  final DateTime date;
  final double maxTempC;
  final double minTempC;
  final String conditionText;
  final String iconUrl;
  final int chanceOfRain;

  ForecastDay({
    required this.date,
    required this.maxTempC,
    required this.minTempC,
    required this.conditionText,
    required this.iconUrl,
    required this.chanceOfRain,
  });


  String get dayOfWeek => DateFormat('EEEE').format(date);

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    final dayData = json['day'] ?? {};
    return ForecastDay(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      maxTempC: (dayData['maxtemp_c'] as num?)?.toDouble() ?? 0.0,
      minTempC: (dayData['mintemp_c'] as num?)?.toDouble() ?? 0.0,
      conditionText: dayData['condition']['text'] ?? 'N/A',
 
      iconUrl: dayData['condition']['icon'] ?? '',
      chanceOfRain: (dayData['daily_chance_of_rain'] as num?)?.toInt() ?? 0,
    );
  }
}