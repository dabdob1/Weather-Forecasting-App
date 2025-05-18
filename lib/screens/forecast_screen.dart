import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/daily_forecast.dart';
import '../widgets/weather_card.dart';
import '../constants/api_constants.dart';

class ForecastScreen extends StatefulWidget {
  final String city;
  final double lat;
  final double lon;
  final bool isCelsius;

  const ForecastScreen({
    super.key, // Changed to super parameter
    required this.city,
    required this.lat,
    required this.lon,
    required this.isCelsius,
  });

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  late Future<List<DailyForecast>> _forecastFuture;

  @override
  void initState() {
    super.initState();
    _forecastFuture = _fetchForecast();
  }

  Future<List<DailyForecast>> _fetchForecast() async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=${widget.lat}&lon=${widget.lon}&appid=${ApiConstants.apiKey}&units=metric',
    );
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load forecast data');
    }

    final data = json.decode(response.body);
    return _processForecastData(data['list']);
  }

  List<DailyForecast> _processForecastData(List<dynamic> list) {
    final Map<String, List<dynamic>> dailyData = {};
    for (final item in list) {
      final day = DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000));
      dailyData.putIfAbsent(day, () => []).add(item);
    }
    return dailyData.entries.take(5).map((entry) {
      final items = entry.value;
      final mid = items[items.length ~/ 2];
      return DailyForecast(
        date: DateTime.parse(entry.key),
        maxTemp: items.map((i) => i['main']['temp_max'] as num).reduce((a, b) => a > b ? a : b).toDouble(),
        minTemp: items.map((i) => i['main']['temp_min'] as num).reduce((a, b) => a < b ? a : b).toDouble(),
        icon: mid['weather'][0]['icon'],
        description: mid['weather'][0]['description'],
        humidity: mid['main']['humidity'].toDouble(),
        windSpeed: mid['wind']['speed'].toDouble(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('5-Day Forecast for ${widget.city}'),
        centerTitle: true,
        elevation: 4,
        backgroundColor: const Color.fromARGB(255, 3, 8, 73),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 3, 8, 73), Color.fromARGB(255, 196, 181, 250)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<DailyForecast>>(
          future: _forecastFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(snapshot.error.toString(), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() => _forecastFuture = _fetchForecast()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            final data = snapshot.data;
            if (data == null || data.isEmpty) {
              return const Center(child: Text('No forecast data available'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return AnimatedOpacity(
                  opacity: 1.0,
                  duration: Duration(milliseconds: 300 + index * 100),
                  child: WeatherCard(
                    forecast: data[index],
                    isCelsius: widget.isCelsius,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}