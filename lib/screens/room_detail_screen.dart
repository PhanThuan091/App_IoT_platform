import 'package:flutter/material.dart';
import '../models/room.dart';
import '../services/iot_service.dart';
import '../widgets/temperature_humidity_card.dart';
import '../widgets/power_metrics_card.dart';
import '../widgets/device_control_card.dart';

class RoomDetailScreen extends StatefulWidget {
  final String roomId;
  
  RoomDetailScreen({required this.roomId});
  
  @override
  _RoomDetailScreenState createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  final IoTService _iotService = IoTService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Room>>(
      stream: _iotService.roomsStream,
      initialData: _iotService.rooms,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text('Chi tiết phòng')),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final room = snapshot.data!.firstWhere((r) => r.id == widget.roomId);
        
        return Scaffold(
          appBar: AppBar(
            title: Text(room.name),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thẻ hiển thị nhiệt độ và độ ẩm
                TemperatureHumidityCard(
                  temperature: room.temperature,
                  humidity: room.humidity,
                ),
                
                SizedBox(height: 16),
                
                // Thẻ hiển thị thông số điện năng
                PowerMetricsCard(
                  voltage: room.voltage,
                  current: room.current,
                  frequency: room.frequency,
                  power: room.power,
                  energyUsage: room.energyUsage,
                  powerHistory: room.powerHistory,
                ),
                
                SizedBox(height: 24),
                
                // Tiêu đề danh sách thiết bị
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Thiết bị trong phòng',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${room.devices.length} thiết bị',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Danh sách thiết bị
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: room.devices.length,
                  itemBuilder: (context, index) {
                    final device = room.devices[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: DeviceControlCard(
                        device: device,
                        roomId: room.id,
                        onToggle: (value) {
                          _iotService.controlDevice(room.id, device.id, value);
                        },
                      ),
                    );
                  },
                ),
                
                // Thông báo nếu không có thiết bị
                if (room.devices.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        SizedBox(height: 32),
                        Icon(
                          Icons.devices_other,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Chưa có thiết bị nào',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
} 