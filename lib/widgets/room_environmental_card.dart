import 'package:flutter/material.dart';
import '../models/room.dart';

class RoomEnvironmentalCard extends StatelessWidget {
  final Room room;

  const RoomEnvironmentalCard({Key? key, required this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin môi trường',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEnvironmentalInfo(
                  context,
                  'Nhiệt độ',
                  '${room.temperature.toStringAsFixed(1)}°C',
                  Icons.thermostat,
                  Colors.orange,
                ),
                _buildEnvironmentalInfo(
                  context,
                  'Độ ẩm',
                  '${room.humidity.toStringAsFixed(1)}%',
                  Icons.water_drop,
                  Colors.blue,
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildEnvironmentalChart(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentalInfo(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEnvironmentalChart(BuildContext context) {
    // Đơn giản hóa biểu đồ, chỉ hiển thị 2 đường thẳng cho nhiệt độ và độ ẩm
    return Container(
      height: 150,
      child: _buildSimpleLineChart(context),
    );
  }

  Widget _buildSimpleLineChart(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, 150),
      painter: SimpleChartPainter(
        temperatureValue: room.temperature,
        humidityValue: room.humidity,
      ),
    );
  }
}

class SimpleChartPainter extends CustomPainter {
  final double temperatureValue;
  final double humidityValue;

  SimpleChartPainter({
    required this.temperatureValue,
    required this.humidityValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Vẽ lưới
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (var i = 0; i < 5; i++) {
      final y = i * (size.height / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    for (var i = 0; i < 5; i++) {
      final x = i * (size.width / 4);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    // Vẽ đường nhiệt độ
    final tempPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Giả định nhiệt độ có thể từ 10-40°C
    final normalizedTemp = (temperatureValue.clamp(10, 40) - 10) / 30;

    // Tạo các điểm dao động nhẹ quanh giá trị hiện tại
    final tempPoints = [
      Offset(0, size.height * (1 - (normalizedTemp - 0.05).clamp(0, 1))),
      Offset(size.width * 0.25, size.height * (1 - (normalizedTemp - 0.02).clamp(0, 1))),
      Offset(size.width * 0.5, size.height * (1 - normalizedTemp.clamp(0, 1))),
      Offset(size.width * 0.75, size.height * (1 - (normalizedTemp + 0.03).clamp(0, 1))),
      Offset(size.width, size.height * (1 - (normalizedTemp - 0.01).clamp(0, 1))),
    ];

    final tempPath = Path()..moveTo(tempPoints[0].dx, tempPoints[0].dy);
    for (var i = 1; i < tempPoints.length; i++) {
      tempPath.lineTo(tempPoints[i].dx, tempPoints[i].dy);
    }

    canvas.drawPath(tempPath, tempPaint);

    // Vẽ đường độ ẩm
    final humidPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Giả định độ ẩm từ 0-100%
    final normalizedHumid = humidityValue / 100;

    // Tạo các điểm dao động nhẹ quanh giá trị hiện tại
    final humidPoints = [
      Offset(0, size.height * (1 - (normalizedHumid + 0.03).clamp(0, 1))),
      Offset(size.width * 0.25, size.height * (1 - (normalizedHumid - 0.04).clamp(0, 1))),
      Offset(size.width * 0.5, size.height * (1 - normalizedHumid.clamp(0, 1))),
      Offset(size.width * 0.75, size.height * (1 - (normalizedHumid + 0.05).clamp(0, 1))),
      Offset(size.width, size.height * (1 - (normalizedHumid + 0.02).clamp(0, 1))),
    ];

    final humidPath = Path()..moveTo(humidPoints[0].dx, humidPoints[0].dy);
    for (var i = 1; i < humidPoints.length; i++) {
      humidPath.lineTo(humidPoints[i].dx, humidPoints[i].dy);
    }

    canvas.drawPath(humidPath, humidPaint);

    // Vẽ chú thích
    final tempLegendPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
    
    final humidLegendPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.9), 4, tempLegendPaint);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.9), 4, humidLegendPaint);

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    textPainter.text = TextSpan(
      text: 'Nhiệt độ',
      style: TextStyle(
        color: Colors.orange,
        fontSize: 10,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.1 + 10, size.height * 0.9 - 5));

    textPainter.text = TextSpan(
      text: 'Độ ẩm',
      style: TextStyle(
        color: Colors.blue,
        fontSize: 10,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.6 + 10, size.height * 0.9 - 5));
  }

  @override
  bool shouldRepaint(SimpleChartPainter oldDelegate) {
    return oldDelegate.temperatureValue != temperatureValue ||
           oldDelegate.humidityValue != humidityValue;
  }
} 