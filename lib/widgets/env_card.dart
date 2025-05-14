import 'package:flutter/material.dart';

class EnvCard extends StatelessWidget {
  final double temperature;
  final double humidity;

  EnvCard({required this.temperature, required this.humidity});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Môi trường phòng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.thermostat, color: Colors.orange, size: 24),
                        SizedBox(height: 8),
                        Text(
                          '${temperature.toStringAsFixed(1)}°C',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange[800]),
                        ),
                        SizedBox(height: 8),
                        _buildStatus(_getTemperatureStatus(temperature), Colors.orange),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.water_drop, color: Colors.blue, size: 24),
                        SizedBox(height: 8),
                        Text(
                          '${humidity.toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                        ),
                        SizedBox(height: 8),
                        _buildStatus(_getHumidityStatus(humidity), Colors.blue),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTemperatureStatus(double temp) {
    if (temp < 18) return 'Lạnh';
    if (temp < 24) return 'Mát';
    if (temp < 30) return 'Ấm';
    return 'Nóng';
  }

  String _getHumidityStatus(double humidity) {
    if (humidity < 30) return 'Khô';
    if (humidity < 50) return 'Thoải mái';
    if (humidity < 70) return 'Ẩm';
    return 'Rất ẩm';
  }

  Widget _buildStatus(String status, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}