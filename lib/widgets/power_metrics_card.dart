import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/room.dart';

class PowerMetricsCard extends StatelessWidget {
  final double voltage;
  final double current;
  final double frequency;
  final double power;
  final double energyUsage;
  final List<PowerData> powerHistory;

  const PowerMetricsCard({
    Key? key,
    required this.voltage,
    required this.current,
    required this.frequency,
    required this.power,
    required this.energyUsage,
    required this.powerHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Row(
              children: [
                Icon(Icons.bolt, color: Colors.amber, size: 18),
                SizedBox(width: 8),
                Text(
                  'Thông số điện năng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(height: 20),
            // Các thông số điện năng dạng Grid 2x2
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricBox(
                        label: 'Điện áp',
                        value: '${voltage.toStringAsFixed(1)} V',
                        icon: Icons.electric_bolt,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricBox(
                        label: 'Dòng điện',
                        value: '${current.toStringAsFixed(2)} A',
                        icon: Icons.waves,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricBox(
                        label: 'Tần số',
                        value: '${frequency.toStringAsFixed(1)} Hz',
                        icon: Icons.speed,
                        color: Colors.purple,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricBox(
                        label: 'Công suất tiêu thụ',
                        value: '${power.toStringAsFixed(1)} W',
                        icon: Icons.power,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricBox(
                        label: 'Điện năng tiêu thụ',
                        value: '${energyUsage.toStringAsFixed(2)} kWh',
                        icon: Icons.electric_meter,
                        color: Colors.green,
                      ),
                    ),
                    Expanded(child: Container()), // Để căn đều
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            // Tiêu đề biểu đồ
            Text(
              'Biểu đồ công suất tiêu thụ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            // Biểu đồ công suất
            Container(
              height: 180,
              child: powerHistory.length < 2 
                ? Center(child: Text('Chưa đủ dữ liệu'))
                : _buildPowerChart(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị cho một thông số
  Widget _buildMetricBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Biểu đồ công suất
  Widget _buildPowerChart() {
    final List<FlSpot> spots = [];
    if (powerHistory.isNotEmpty) {
      final firstTime = powerHistory.first.time.millisecondsSinceEpoch.toDouble();
      for (int i = 0; i < powerHistory.length; i++) {
        final time = powerHistory[i].time.millisecondsSinceEpoch.toDouble();
        final normalizedTime = (time - firstTime) / (60 * 1000); // Phút
        spots.add(FlSpot(normalizedTime, powerHistory[i].value));
      }
    }
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() % 5 != 0) {
                  return SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${value.toInt()} phút',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()} W',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 42,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        minX: 0,
        maxX: spots.isEmpty ? 60 : spots.last.x + 5,
        minY: 0,
        maxY: spots.isEmpty ? 1000 : (spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.2),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
} 