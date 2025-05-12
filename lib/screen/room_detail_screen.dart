import 'package:flutter/material.dart';
import '../screen/room.dart';
import '../screen/room_service.dart';
import '../screen/temperature_humidity_card.dart';
import '../screen/device_control_card.dart';
import 'add_device_screen.dart';

class RoomDetailScreen extends StatefulWidget {
  final String roomId;
  
  RoomDetailScreen({required this.roomId});
  
  @override
  _RoomDetailScreenState createState() => _RoomDetailScreenState();
} 

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  final RoomService _roomService = RoomService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Room>>(
      stream: _roomService.roomsStream,
      initialData: _roomService.rooms,
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
            actions: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddDeviceScreen(roomId: room.id),
                    ),
                  );
                },
                tooltip: 'Thêm thiết bị',
              ),
            ],
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
                          _roomService.controlDevice(room.id, device.id, value);
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
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddDeviceScreen(roomId: room.id),
                              ),
                            );
                          },
                          icon: Icon(Icons.add),
                          label: Text('Thêm thiết bị'),
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