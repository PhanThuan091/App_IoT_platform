import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/room.dart';

class PowerChartCard extends StatelessWidget {
  final List<PowerHistory> history;

  PowerChartCard({required this.history});

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
              'Biểu đồ tiêu thụ điện',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelStyle: TextStyle(fontSize: 10),
                  majorGridLines: MajorGridLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  labelFormat: '{value} W',
                  majorGridLines: MajorGridLines(width: 0.5),
                ),
                series: <ChartSeries>[
                  SplineSeries<PowerHistory, String>(
                    dataSource: history,
                    xValueMapper: (PowerHistory h, _) => '${h.time.hour}:${h.time.minute}',
                    yValueMapper: (PowerHistory h, _) => h.value,
                    color: Colors.blue,
                    width: 2,
                    markerSettings: MarkerSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}