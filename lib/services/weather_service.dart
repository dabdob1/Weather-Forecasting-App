import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';
import '../constants/api_constants.dart';

class WeatherService {
  static Future<WeatherData> fetchWeather(double lat, double lon) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    print('Fetching weather for lat=$lat, lon=$lon at $timestamp');
    final response = await http.get(
      Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=${ApiConstants.apiKey}&units=metric&t=$timestamp',
      ),
      headers: {'Cache-Control': 'no-cache'},
    );
    print('Weather API response status: ${response.statusCode}');
    print('Weather API response body: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WeatherData.fromJson(data);
    } else {
      throw 'Failed to load weather data: Status ${response.statusCode}';
    }
  }

  static Future<WeatherData> searchWeather(String city) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    print('Searching weather for city=$city at $timestamp');
    final response = await http.get(
      Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=${ApiConstants.apiKey}&units=metric&t=$timestamp',
      ),
      headers: {'Cache-Control': 'no-cache'},
    );
    print('Search API response status: ${response.statusCode}');
    print('Search API response body: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WeatherData.fromJson(data);
    } else {
      throw 'City not found: Status ${response.statusCode}';
    }
  }

  static Future<List<dynamic>> fetchHourlyForecast(double lat, double lon) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    print('Fetching hourly forecast for lat=$lat, lon=$lon at $timestamp');
    final response = await http.get(
      Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=${ApiConstants.apiKey}&units=metric&t=$timestamp',
      ),
      headers: {'Cache-Control': 'no-cache'},
    );
    print('Forecast API response status: ${response.statusCode}');
    print('Forecast API response body (first 5): ${json.decode(response.body)['list'].take(5)}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['list'];
    } else {
      throw 'Failed to load hourly forecast data: Status ${response.statusCode}';
    }
  }
}