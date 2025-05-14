import 'package:flutter/material.dart';
import '../models/room.dart';

class PowerStatsCard extends StatelessWidget {
  final PowerStats powerStats;

  PowerStatsCard({required this.powerStats});

  @override
  Widget build(BuildContext context) {
    final double hourlyRate = 3000; // VND/kWh
    final double dailyCost = powerStats.power * 24 * hourlyRate / 1000;
    final double monthlyCost = dailyCost * 30;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thống kê điện năng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(Icons.electrical_services, 'Điện áp', '${powerStats.voltage.toStringAsFixed(1)} V', Colors.purple),
                _buildStat(Icons.bolt, 'Dòng điện', '${powerStats.current.toStringAsFixed(2)} A', Colors.green),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(Icons.waves, 'Tần số', '${powerStats.frequency.toStringAsFixed(1)} Hz', Colors.teal),
                _buildStat(Icons.power, 'Công suất', '${powerStats.power.toStringAsFixed(1)} W', Colors.orange),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(Icons.battery_charging_full, 'Điện năng', '${powerStats.energy.toStringAsFixed(2)} kWh', Colors.indigo),
                _buildStat(Icons.monetization_on, 'Chi phí', '${_formatCurrency(monthlyCost)} VND/tháng', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
}