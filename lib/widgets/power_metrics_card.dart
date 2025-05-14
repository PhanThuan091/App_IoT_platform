import 'package:flutter/material.dart';
import '../models/room.dart';

class PowerMetricsCard extends StatelessWidget {
  final Room room;
  final bool showChart;
  final bool showDetailed;
  final String timeRange;

  const PowerMetricsCard({
    Key? key,
    required this.room,
    this.showChart = false,
    this.showDetailed = false,
    this.timeRange = '24h',
  }) : super(key: key);

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
              'Thông tin điện năng',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPowerInfo(
                  context,
                  'Tổng công suất',
                  '${room.getTotalPowerConsumption().toStringAsFixed(1)} W',
                  Icons.bolt,
                  Theme.of(context).primaryColor,
                ),
                _buildPowerInfo(
                  context,
                  'Thiết bị hoạt động',
                  '${room.getDevicesOnCount()}',
                  Icons.devices,
                  Colors.green,
                ),
              ],
            ),
            if (showDetailed) ...[
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailedPowerInfo(context, 'Điện áp', '${_getAverageVoltage()} V'),
                  _buildDetailedPowerInfo(context, 'Dòng điện', '${_getAverageCurrent()} A'),
                  _buildDetailedPowerInfo(context, 'Tần số', '${_getAverageFrequency()} Hz'),
                ],
              ),
              SizedBox(height: 16),
              _buildDetailedPowerInfo(context, 'Điện năng tiêu thụ', '${_getTotalEnergyUsage()} kWh'),
            ],
            if (showChart) ...[
              SizedBox(height: 16),
              _buildPowerChart(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPowerInfo(
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

  Widget _buildDetailedPowerInfo(
    BuildContext context,
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPowerChart(BuildContext context) {
    // Một biểu đồ đơn giản sử dụng CustomPaint để hiển thị công suất tiêu thụ
    return Container(
      height: 150,
      child: CustomPaint(
        size: Size(double.infinity, 150),
        painter: PowerChartPainter(
          currentPower: room.getTotalPowerConsumption(),
          timeRange: timeRange,
        ),
      ),
    );
  }

  // Tính điện áp trung bình từ tất cả thiết bị
  double _getAverageVoltage() {
    if (room.devices.isEmpty) return 0;
    double sum = 0;
    for (final device in room.devices) {
      sum += device.voltage;
    }
    return sum / room.devices.length;
  }

  // Tính dòng điện trung bình từ các thiết bị đang hoạt động
  double _getAverageCurrent() {
    final activeDevices = room.devices.where((device) => device.isOn).toList();
    if (activeDevices.isEmpty) return 0;
    double sum = 0;
    for (final device in activeDevices) {
      sum += device.current;
    }
    return sum / activeDevices.length;
  }

  // Tính tần số trung bình từ tất cả thiết bị
  double _getAverageFrequency() {
    if (room.devices.isEmpty) return 0;
    double sum = 0;
    for (final device in room.devices) {
      sum += device.frequency;
    }
    return sum / room.devices.length;
  }

  // Tính tổng điện năng tiêu thụ
  double _getTotalEnergyUsage() {
    double total = 0;
    for (final device in room.devices) {
      total += device.energyUsage;
    }
    return total;
  }
}

class PowerChartPainter extends CustomPainter {
  final double currentPower;
  final String timeRange;

  PowerChartPainter({
    required this.currentPower,
    required this.timeRange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Vẽ lưới
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (var i = 0; i <= 4; i++) {
      final y = i * (size.height / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    for (var i = 0; i <= 4; i++) {
      final x = i * (size.width / 4);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    // Vẽ đường công suất
    final powerPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Tạo một đường cong giả định cho công suất tiêu thụ
    // Đường cong sẽ dao động quanh giá trị hiện tại
    final maxPower = currentPower * 1.5;
    
    final powerPoints = [
      Offset(0, size.height * (1 - (currentPower * 0.8 / maxPower).clamp(0, 1))),
      Offset(size.width * 0.25, size.height * (1 - (currentPower * 0.9 / maxPower).clamp(0, 1))),
      Offset(size.width * 0.5, size.height * (1 - (currentPower / maxPower).clamp(0, 1))),
      Offset(size.width * 0.75, size.height * (1 - (currentPower * 1.1 / maxPower).clamp(0, 1))),
      Offset(size.width, size.height * (1 - (currentPower * 0.95 / maxPower).clamp(0, 1))),
    ];

    final powerPath = Path()..moveTo(powerPoints[0].dx, powerPoints[0].dy);
    for (var i = 0; i < powerPoints.length - 1; i++) {
      final control = Offset(
        (powerPoints[i].dx + powerPoints[i + 1].dx) / 2,
        powerPoints[i].dy,
      );
      final end = Offset(
        (powerPoints[i].dx + powerPoints[i + 1].dx) / 2,
        powerPoints[i + 1].dy,
      );
      powerPath.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
      powerPath.lineTo(powerPoints[i + 1].dx, powerPoints[i + 1].dy);
    }

    canvas.drawPath(powerPath, powerPaint);

    // Vẽ vùng dưới đường
    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final fillPath = Path()..moveTo(0, size.height);
    fillPath.lineTo(powerPoints[0].dx, powerPoints[0].dy);
    fillPath.addPath(powerPath, Offset.zero);
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);

    // Vẽ các nhãn thời gian trên trục X
    final textStyle = TextStyle(
      color: Colors.grey[600],
      fontSize: 10,
    );
    
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    String getTimeLabel(int index) {
      switch (timeRange) {
        case '24h':
          final hour = index * 6;
          return '$hour:00';
        case '7d':
          if (index == 0) return 'T2';
          if (index == 1) return 'T4';
          if (index == 2) return 'T6';
          if (index == 3) return 'CN';
          return '';
        case '30d':
          return 'Tuần ${index + 1}';
        case '1y':
          if (index == 0) return 'T1';
          if (index == 1) return 'T4';
          if (index == 2) return 'T7';
          if (index == 3) return 'T10';
          return '';
        default:
          return '';
      }
    }

    for (var i = 0; i <= 4; i++) {
      textPainter.text = TextSpan(
        text: getTimeLabel(i),
        style: textStyle,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          i * (size.width / 4) - textPainter.width / 2,
          size.height + 5,
        ),
      );
    }

    // Vẽ các giá trị công suất trên trục Y
    for (var i = 0; i <= 4; i++) {
      final value = (maxPower * (4 - i) / 4).round();
      textPainter.text = TextSpan(
        text: '$value W',
        style: textStyle,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          -textPainter.width - 5,
          i * (size.height / 4) - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(PowerChartPainter oldDelegate) {
    return oldDelegate.currentPower != currentPower || 
           oldDelegate.timeRange != timeRange;
  }
} 