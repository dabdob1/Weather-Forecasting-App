import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/weather_data.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../screens/forecast_screen.dart';

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  WeatherData? currentWeather;
  bool isLoading = true;
  bool isCelsius = true;
  String errorMessage = '';
  List<dynamic> hourlyForecast = [];
  final TextEditingController searchController = TextEditingController();
  String lastRefreshTime = '';

  @override
  void initState() {
    super.initState();
    print('Initializing WeatherHomePage at ${DateTime.now()}');
    _getCurrentLocationWeather();
  }

  Future<void> _getCurrentLocationWeather() async {
    print('Starting _getCurrentLocationWeather at ${DateTime.now()}');
    setState(() {
      isLoading = true;
      errorMessage = '';
      currentWeather = null;
      hourlyForecast = [];
    });

    try {
      print('Determining position...');
      final position = await LocationService.determinePosition();
      print('Position acquired: lat=${position.latitude}, lon=${position.longitude}');
      print('Fetching weather...');
      final weather = await WeatherService.fetchWeather(position.latitude, position.longitude);
      print('Weather fetched: $weather');
      print('Fetching hourly forecast...');
      final forecast = await WeatherService.fetchHourlyForecast(position.latitude, position.longitude);
      print('Hourly forecast fetched: ${forecast.take(5)}');
      setState(() {
        currentWeather = weather;
        hourlyForecast = forecast;
        isLoading = false;
        lastRefreshTime = DateFormat('HH:mm:ss').format(DateTime.now());
        print('State updated at $lastRefreshTime');
      });
    } catch (e) {
      print('Error caught: $e');
      setState(() {
        errorMessage = 'Failed to get weather data: ${e.toString()}';
        isLoading = false;
        lastRefreshTime = DateFormat('HH:mm:ss').format(DateTime.now());
        print('Error state set at $lastRefreshTime');
      });
    }
  }

  Future<void> _searchWeather(String city) async {
    print('Starting _searchWeather for city=$city at ${DateTime.now()}');
    setState(() {
      isLoading = true;
      errorMessage = '';
      currentWeather = null;
      hourlyForecast = [];
    });

    try {
      print('Searching weather...');
      final weather = await WeatherService.searchWeather(city);
      print('Weather searched: $weather');
      print('Fetching hourly forecast for lat=${weather.lat}, lon=${weather.lon}...');
      final forecast = await WeatherService.fetchHourlyForecast(weather.lat, weather.lon);
      print('Hourly forecast fetched: ${forecast.take(5)}');
      setState(() {
        currentWeather = weather;
        hourlyForecast = forecast;
        isLoading = false;
        lastRefreshTime = DateFormat('HH:mm:ss').format(DateTime.now());
        print('State updated at $lastRefreshTime');
      });
    } catch (e) {
      print('Error caught: $e');
      setState(() {
        errorMessage = 'Failed to get weather data: ${e.toString()}';
        isLoading = false;
        lastRefreshTime = DateFormat('HH:mm:ss').format(DateTime.now());
        print('Error state set at $lastRefreshTime');
      });
    }
  }

  void _toggleTemperatureUnit() {
    setState(() {
      isCelsius = !isCelsius;
    });
  }

  String getBackgroundImageUrl(String weatherDescription) {
    if (weatherDescription.toLowerCase().contains('clear')) {
      return 'https://images.unsplash.com/photo-1641908528285-78e678e0bfe1?q=80&w=1631&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
    } else if (weatherDescription.toLowerCase().contains('cloud')) {
      return 'https://images.unsplash.com/photo-1699201720285-8e55b09a4bc6?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
    } else if (weatherDescription.toLowerCase().contains('rain')) {
      return 'https://images.unsplash.com/photo-1626286901654-dad28a60e744?q=80&w=1470&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
    } else if (weatherDescription.toLowerCase().contains('snow')) {
      return 'https://plus.unsplash.com/premium_photo-1706625699202-b559d88f579f?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
    } else {
      return 'https://images.unsplash.com/photo-1503264116251-35a269479413';
    }
  }

  Color _getTextColor() {
    final hour = DateTime.now().hour;
    return (hour >= 6 && hour < 18) ? Colors.black : Colors.white;
  }

  Widget _buildWeatherDetail(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 30, color: color),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: Color.alphaBlend(color, Colors.black.withAlpha(0x70)))),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = _getTextColor();
    final currentDate = DateFormat('EEEE, d MMM yyyy').format(DateTime.now());

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          currentDate,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isCelsius ? Icons.thermostat_outlined : Icons.thermostat,
              color: textColor,
            ),
            onPressed: _toggleTemperatureUnit,
          ),
        ],
      ),
      body: KeyedSubtree(
        key: ValueKey(lastRefreshTime), // Force rebuild on refresh
        child: currentWeather == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                getBackgroundImageUrl(currentWeather!.description),
                fit: BoxFit.cover,
              ),
            ),
            AnnotatedRegion<SystemUiOverlayStyle>(
              value: textColor == Colors.white ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
              child: SafeArea(
                child: isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
                    : errorMessage.isNotEmpty
                    ? Center(
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: textColor),
                  ),
                )
                    : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: searchController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Search city...',
                          hintStyle: TextStyle(color: Color.alphaBlend(textColor, Colors.black.withAlpha(0x70))),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search, color: textColor),
                            onPressed: () => _searchWeather(searchController.text),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: textColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: textColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: textColor),
                          ),
                        ),
                        onSubmitted: (value) => _searchWeather(value),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Last Refresh: $lastRefreshTime',
                        style: TextStyle(color: textColor, fontSize: 12),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.3,
                              alignment: Alignment.center,
                              child: Text(
                                '${isCelsius ? currentWeather!.temperature.round() : (currentWeather!.temperature * 9 / 5 + 32).round()}°${isCelsius ? 'C' : 'F'}',
                                style: TextStyle(
                                  fontSize: 80,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 120,
                              child: hourlyForecast.isEmpty
                                  ? const Center(child: Text("No hourly data available"))
                                  : ListView.builder(
                                key: UniqueKey(),
                                scrollDirection: Axis.horizontal,
                                itemCount: hourlyForecast.length > 10 ? 10 : hourlyForecast.length,
                                itemBuilder: (context, index) {
                                  final forecast = hourlyForecast[index];
                                  final time = DateTime.parse(forecast['dt_txt']);
                                  final temp = forecast['main']['temp'].round();
                                  final icon = forecast['weather'][0]['icon'];
                                  return Container(
                                    width: 80,
                                    margin: const EdgeInsets.symmetric(horizontal: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent.withAlpha(0x33),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('${time.hour}:00', style: const TextStyle(color: Colors.black)),
                                        Image.network(
                                          'https://openweathermap.org/img/wn/$icon.png',
                                          width: 40,
                                        ),
                                        Text('$temp°C', style: const TextStyle(color: Colors.black)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    currentWeather!.cityName,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    currentWeather!.description,
                                    style: TextStyle(fontSize: 18, color: textColor),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildWeatherDetail(
                                        'Humidity',
                                        '${currentWeather!.humidity}%',
                                        Icons.water_drop,
                                        textColor,
                                      ),
                                      _buildWeatherDetail(
                                        'Wind',
                                        '${currentWeather!.windSpeed.toStringAsFixed(2)} km/h',
                                        Icons.air,
                                        textColor,
                                      ),
                                      _buildWeatherDetail(
                                        'Feels Like',
                                        '${isCelsius ? currentWeather!.feelsLike.round() : (currentWeather!.feelsLike * 9 / 5 + 32).round()}°',
                                        Icons.thermostat,
                                        textColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[50],
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ForecastScreen(
                                        city: currentWeather!.cityName,
                                        lat: currentWeather!.lat,
                                        lon: currentWeather!.lon,
                                        isCelsius: isCelsius,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  '5-Day Forecast',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocationWeather,
        backgroundColor: Colors.blue[50],
        child: const Icon(Icons.refresh),
      ),
    );
  }
}