import 'package:flutter/material.dart';

class UnitDetailScreen extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final String location;

  UnitDetailScreen({
    required this.name,
    required this.icon,
    required this.color,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100, color: color),
            SizedBox(height: 20),
            Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Location: $location", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
