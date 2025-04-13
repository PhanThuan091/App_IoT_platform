import 'package:flutter/material.dart';

class WeatherDetail extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  WeatherDetail({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(fontSize: 14, color: color ?? Colors.black)),
      ],
    );
  }
}
