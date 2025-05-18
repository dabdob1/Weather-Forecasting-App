class WeatherData {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final double lat;
  final double lon;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.lat,
    required this.lon,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble() * 3.6, // Convert m/s to km/h
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      lat: json['coord']['lat'].toDouble(),
      lon: json['coord']['lon'].toDouble(),
    );
  }
}