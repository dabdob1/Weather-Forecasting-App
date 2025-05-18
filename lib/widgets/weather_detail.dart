import 'package:flutter/material.dart';

class WeatherDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const WeatherDetail({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    const color = Colors.white;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(color: color)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: color)),
      ],
    );
  }
}