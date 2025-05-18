import 'package:flutter/material.dart';

class TemperatureHumidityCard extends StatelessWidget {
  final double temperature;
  final double humidity;

  const TemperatureHumidityCard({
    Key? key,
    required this.temperature,
    required this.humidity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Row(
              children: [
                Icon(Icons.thermostat_outlined, color: Colors.blue, size: 18),
                SizedBox(width: 8),
                Text(
                  'Thông số môi trường',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            Divider(height: 24),
            
            // Các thông số
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Nhiệt độ
                _buildMetricColumn(
                  icon: Icons.thermostat,
                  color: _getTemperatureColor(temperature),
                  value: temperature.toStringAsFixed(1),
                  unit: '°C',
                  label: 'Nhiệt độ',
                ),
                
                // Đường kẻ dọc giữa
                Container(
                  height: 80,
                  width: 1,
                  color: Colors.grey[300],
                ),
                
                // Độ ẩm
                _buildMetricColumn(
                  icon: Icons.water_drop_outlined, 
                  color: _getHumidityColor(humidity),
                  value: humidity.toStringAsFixed(1),
                  unit: '%',
                  label: 'Độ ẩm',
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            // Mô tả trạng thái
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị thông số
  Widget _buildMetricColumn({
    required IconData icon,
    required Color color,
    required String value,
    required String unit,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            children: [
              TextSpan(text: value),
              TextSpan(
                text: unit,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  // Màu sắc dựa vào nhiệt độ
  Color _getTemperatureColor(double temp) {
    if (temp < 18) return Colors.blue;
    if (temp < 24) return Colors.green;
    if (temp < 30) return Colors.orange;
    return Colors.red;
  }

  // Màu sắc dựa vào độ ẩm
  Color _getHumidityColor(double humidity) {
    if (humidity < 30) return Colors.orange;
    if (humidity < 50) return Colors.green;
    if (humidity < 70) return Colors.blue;
    return Colors.indigo;
  }

  // Trạng thái tổng hợp
  Color _getStatusColor() {
    if (temperature > 30 || humidity > 80) return Colors.red;
    if (temperature > 28 || humidity > 70 || humidity < 40) return Colors.orange;
    return Colors.green;
  }

  // Thông báo trạng thái
  String _getStatusText() {
    if (temperature > 30) {
      return 'Nhiệt độ cao, nên bật điều hòa';
    } else if (temperature < 20) {
      return 'Nhiệt độ thấp, cẩn thận cảm lạnh';
    } else if (humidity > 80) {
      return 'Độ ẩm cao, cần giảm độ ẩm';
    } else if (humidity < 40) {
      return 'Độ ẩm thấp, không khí khô';
    } else if (temperature >= 24 && temperature <= 28 && humidity >= 50 && humidity <= 70) {
      return 'Điều kiện môi trường tốt';
    } else {
      return 'Điều kiện môi trường bình thường';
    }
  }
} 