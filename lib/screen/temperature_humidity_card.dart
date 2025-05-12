import 'package:flutter/material.dart';

class TemperatureHumidityCard extends StatelessWidget {
  final double temperature;
  final double humidity;
  
  TemperatureHumidityCard({
    required this.temperature,
    required this.humidity,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Môi trường phòng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.autorenew, color: Colors.grey),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                // Thẻ nhiệt độ
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.thermostat,
                              color: Colors.orange,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Nhiệt độ',
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          '${temperature.toStringAsFixed(1)}°C',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        _getTemperatureStatus(temperature),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(width: 16),
                
                // Thẻ độ ẩm
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.water_drop,
                              color: Colors.blue,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Độ ẩm',
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          '${humidity.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        _getHumidityStatus(humidity),
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
  
  // Trả về widget trạng thái nhiệt độ
  Widget _getTemperatureStatus(double temp) {
    String status;
    Color color;
    
    if (temp < 18) {
      status = 'Lạnh';
      color = Colors.blue;
    } else if (temp < 24) {
      status = 'Mát mẻ';
      color = Colors.green;
    } else if (temp < 30) {
      status = 'Ấm áp';
      color = Colors.orange[400]!;
    } else {
      status = 'Nóng';
      color = Colors.red;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
  
  // Trả về widget trạng thái độ ẩm
  Widget _getHumidityStatus(double humidity) {
    String status;
    Color color;
    
    if (humidity < 30) {
      status = 'Khô';
      color = Colors.amber;
    } else if (humidity < 50) {
      status = 'Thoải mái';
      color = Colors.green;
    } else if (humidity < 70) {
      status = 'Ẩm';
      color = Colors.blue[400]!;
    } else {
      status = 'Rất ẩm';
      color = Colors.blue[800]!;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}