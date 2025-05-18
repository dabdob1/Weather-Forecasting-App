import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/widgets/weather_detail.dart';
import '../models/daily_forecast.dart';
import '../utils/extensions.dart';

class WeatherCard extends StatelessWidget {
  final DailyForecast forecast;
  final bool isCelsius;

  const WeatherCard({
    super.key,
    required this.forecast,
    required this.isCelsius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double convertTemp(double temp) => isCelsius ? temp : (temp * 9 / 5) + 32;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.black12,
      color: const Color.fromARGB(255, 3, 8, 73).withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE').format(forecast.date),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, yyyy').format(forecast.date),
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://openweathermap.org/img/wn/${forecast.icon}@2x.png',
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.wb_sunny, size: 40),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              forecast.description.capitalize(),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 400) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.thermostat, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            '${convertTemp(forecast.maxTemp).round()}° / ${convertTemp(forecast.minTemp).round()}°',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          const SizedBox(width: 4),
                          Text(isCelsius ? 'C' : 'F', style: const TextStyle(fontSize: 14, color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          WeatherDetail(icon: Icons.water_drop, label: 'Humidity', value: '${forecast.humidity.round()}%'),
                          const SizedBox(width: 12),
                          WeatherDetail(icon: Icons.air, label: 'Wind', value: '${forecast.windSpeed.round()} km/h'),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.thermostat, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            '${convertTemp(forecast.maxTemp).round()}° / ${convertTemp(forecast.minTemp).round()}°',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          const SizedBox(width: 4),
                          Text(isCelsius ? 'C' : 'F', style: const TextStyle(fontSize: 14, color: Colors.white)),
                        ],
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              WeatherDetail(icon: Icons.water_drop, label: 'Humidity', value: '${forecast.humidity.round()}%'),
                              const SizedBox(width: 12),
                              WeatherDetail(icon: Icons.air, label: 'Wind', value: '${forecast.windSpeed.round()} km/h'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}