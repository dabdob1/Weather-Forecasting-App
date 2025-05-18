class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final String icon;
  final String description;
  final double humidity;
  final double windSpeed;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.icon,
    required this.description,
    required this.humidity,
    required this.windSpeed,
  });
}