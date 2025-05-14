import 'package:flutter/material.dart';
import '../models/room.dart';

// Widget for displaying room environmental data (temperature and humidity)
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
              'Environmental Data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEnvironmentalInfo(
                  context,
                  'Temperature',
                  '${room.temperature.toStringAsFixed(1)}°C',
                  Icons.thermostat,
                  Colors.orange,
                ),
                _buildEnvironmentalInfo(
                  context,
                  'Humidity',
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
    return Container(
      height: 200,
      child: CustomPaint(
        size: Size(double.infinity, 200),
        painter: SimpleChartPainter(
          temperatureValue: room.temperature,
          humidityValue: room.humidity,
        ),
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
      text: 'Temperature',
      style: TextStyle(
        color: Colors.orange,
        fontSize: 10,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.1 + 10, size.height * 0.9 - 5));

    textPainter.text = TextSpan(
      text: 'Humidity',
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

// Widget for displaying power metrics
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
              'Power Metrics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPowerInfo(
                  context,
                  'Total Power',
                  '${room.getTotalPowerConsumption().toStringAsFixed(1)} W',
                  Icons.bolt,
                  Theme.of(context).primaryColor,
                ),
                _buildPowerInfo(
                  context,
                  'Active Devices',
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
                  _buildDetailedPowerInfo(context, 'Voltage', '${_getAverageVoltage()} V'),
                  _buildDetailedPowerInfo(context, 'Current', '${_getAverageCurrent()} A'),
                  _buildDetailedPowerInfo(context, 'Frequency', '${_getAverageFrequency()} Hz'),
                ],
              ),
              SizedBox(height: 16),
              _buildDetailedPowerInfo(context, 'Energy Consumption', '${_getTotalEnergyUsage()} kWh'),
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
    return Container(
      height: 200,
      child: CustomPaint(
        size: Size(double.infinity, 200),
        painter: PowerChartPainter(
          currentPower: room.getTotalPowerConsumption(),
          timeRange: timeRange,
        ),
      ),
    );
  }

  // Calculate average voltage from all devices
  double _getAverageVoltage() {
    if (room.devices.isEmpty) return 0;
    double sum = 0;
    for (final device in room.devices) {
      sum += device.voltage;
    }
    return sum / room.devices.length;
  }

  // Calculate average current from active devices
  double _getAverageCurrent() {
    final activeDevices = room.devices.where((device) => device.isOn).toList();
    if (activeDevices.isEmpty) return 0;
    double sum = 0;
    for (final device in activeDevices) {
      sum += device.current;
    }
    return sum / activeDevices.length;
  }

  // Calculate average frequency from all devices
  double _getAverageFrequency() {
    if (room.devices.isEmpty) return 0;
    double sum = 0;
    for (final device in room.devices) {
      sum += device.frequency;
    }
    return sum / room.devices.length;
  }

  // Calculate total energy usage
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
    final maxPower = currentPower > 0 ? currentPower * 1.5 : 100;
    
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
          if (index == 0) return 'Mon';
          if (index == 1) return 'Wed';
          if (index == 2) return 'Fri';
          if (index == 3) return 'Sun';
          return '';
        case '30d':
          return 'Week ${index + 1}';
        case '1y':
          if (index == 0) return 'Jan';
          if (index == 1) return 'Apr';
          if (index == 2) return 'Jul';
          if (index == 3) return 'Oct';
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

// Widget for displaying room summary card
class RoomSummaryCard extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;

  const RoomSummaryCard({
    Key? key,
    required this.room,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    room.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${room.devices.length} devices',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRoomInfo(
                    context,
                    'Temperature',
                    '${room.temperature.toStringAsFixed(1)}°C',
                    Icons.thermostat,
                    Colors.orange,
                  ),
                  _buildRoomInfo(
                    context,
                    'Humidity',
                    '${room.humidity.toStringAsFixed(1)}%',
                    Icons.water_drop,
                    Colors.blue,
                  ),
                  _buildRoomInfo(
                    context,
                    'Power',
                    '${room.getTotalPowerConsumption().toStringAsFixed(1)} W',
                    Icons.bolt,
                    Theme.of(context).primaryColor,
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Devices:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${room.getDevicesOnCount()}/${room.devices.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: room.devices.isEmpty
                    ? 0
                    : room.getDevicesOnCount() / room.devices.length,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomInfo(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Widget for displaying power consumption chart
class PowerConsumptionChart extends StatelessWidget {
  final List<Room> rooms;

  const PowerConsumptionChart({
    Key? key,
    required this.rooms,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: _buildSimpleBarChart(context),
    );
  }

  Widget _buildSimpleBarChart(BuildContext context) {
    double maxPower = _getMaxPower();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final double barWidth = (constraints.maxWidth - 40) / rooms.length;
        final double maxHeight = 150.0;
        
        return Column(
          children: [
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis labels
                SizedBox(
                  width: 40,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${maxPower.toInt()} W',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${(maxPower / 2).toInt()} W',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '0 W',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Chart content
                Expanded(
                  child: Container(
                    height: maxHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(
                        rooms.length,
                        (index) {
                          final room = rooms[index];
                          final power = room.getTotalPowerConsumption();
                          final double barHeight = maxPower > 0
                              ? (power / maxPower) * maxHeight
                              : 0;
                          
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: barWidth * 0.7,
                                height: barHeight > 0 ? barHeight.clamp(5.0, maxHeight) : 5.0,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // X-axis labels
            Row(
              children: [
                SizedBox(width: 40),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      rooms.length,
                      (index) => Container(
                        width: barWidth * 0.7,
                        child: Text(
                          rooms[index].name,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  double _getMaxPower() {
    if (rooms.isEmpty) return 100;
    
    double maxPower = 0;
    for (final room in rooms) {
      final power = room.getTotalPowerConsumption();
      if (power > maxPower) {
        maxPower = power;
      }
    }
    
    return maxPower + 50; // Adding margin to the top
  }
}