import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import '../screen/room.dart';
import '../screen/room_service.dart';
import 'room_detail_screen.dart';
import 'add_room_screen.dart';
import '../screen/power_summary_card.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late String _currentTime;
  late String _greeting;
  late String _currentDate;
  late Timer _timer;
  final RoomService _roomService = RoomService();
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _currentTime = _getCurrentTime();
    _greeting = _getGreeting();
    _currentDate = _getCurrentDate();
    _timer = Timer.periodic(Duration(seconds: 1), _updateTime);
    
    // Kiểm tra trạng thái kết nối ban đầu
    _isConnected = _roomService.isConnected;
    
    // Khởi tạo kết nối nếu chưa kết nối
    if (!_isConnected) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _connectToServer();
      });
    }
  }

  // Lấy thời gian hiện tại
  String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  // Lấy ngày hiện tại
  String _getCurrentDate() {
    final now = DateTime.now();
    final weekdays = ['Chủ Nhật', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy'];
    return "${weekdays[now.weekday % 7]}, ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
  }

  // Lấy lời chào
  String _getGreeting() {
    final now = DateTime.now();
    if (now.hour < 12) return "Chào buổi sáng";
    else if (now.hour < 18) return "Chào buổi chiều";
    else return "Chào buổi tối";
  }

  // Cập nhật thời gian
  void _updateTime(Timer timer) {
    setState(() {
      _currentTime = _getCurrentTime();
      _greeting = _getGreeting();
    });
  }

  // Kết nối tới server WebSocket
  Future<void> _connectToServer() async {
    if (_roomService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã kết nối tới server')),
      );
      return;
    }
    
    // Thay thế URL bằng địa chỉ thực của server
    final success = await _roomService.connect('ws://192.168.79.92:1880/ws/smart_home');//lab huy
    // final success = await _roomService.connect('ws://192.168.100.74:1880/ws/smart_home');// home thuan
    setState(() {
      _isConnected = success;
    });
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kết nối thành công')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể kết nối tới server')),
      );
    }
  }

  // Tính toán tổng công suất tiêu thụ
  double _calculateTotalPower() {
    double total = 0;
    for (var room in _roomService.rooms) {
      for (var device in room.devices) {
        if (device.isOn) {
          total += device.powerConsumption;
        }
      }
    }
    return total;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<List<Room>>(
        stream: _roomService.roomsStream,
        initialData: _roomService.rooms,
        builder: (context, snapshot) {
          final rooms = snapshot.data ?? [];
          final totalPower = _calculateTotalPower();
          
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '$_currentDate',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isConnected ? Colors.green[100] : Colors.red[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isConnected ? Icons.wifi : Icons.wifi_off,
                              size: 16,
                              color: _isConnected ? Colors.green[700] : Colors.red[700],
                            ),
                            SizedBox(width: 4),
                            Text(
                              _isConnected ? 'Đã kết nối' : 'Mất kết nối',
                              style: TextStyle(
                                fontSize: 12,
                                color: _isConnected ? Colors.green[700] : Colors.red[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Thẻ tổng quan tiêu thụ điện
                  PowerSummaryCard(totalPower: totalPower),
                  
                  SizedBox(height: 20),
                  
                  // Tiêu đề danh sách phòng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Danh sách phòng',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddRoomScreen()),
                          );
                        },
                        icon: Icon(Icons.add, size: 18),
                        label: Text("Thêm phòng"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Danh sách phòng
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      // Đếm số thiết bị đang bật
                      final devicesOn = room.devices.where((d) => d.isOn).length;
                      
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 1,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RoomDetailScreen(roomId: room.id),
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Icon phòng
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getRoomIcon(room.name),
                                    color: Colors.blue,
                                    size: 30,
                                  ),
                                ),
                                SizedBox(width: 16),
                                // Thông tin phòng
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        room.name,
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.device_hub, size: 14, color: Colors.grey[600]),
                                          SizedBox(width: 4),
                                          Text(
                                            '${room.devices.length} thiết bị',
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                          SizedBox(width: 8),
                                          Container(
                                            width: 4,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[400],
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.power, size: 14, color: Colors.grey[600]),
                                          SizedBox(width: 4),
                                          Text(
                                            '$devicesOn đang hoạt động',
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.thermostat, size: 14, color: Colors.orange),
                                          SizedBox(width: 4),
                                          Text(
                                            '${room.temperature.toStringAsFixed(1)}°C',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          SizedBox(width: 16),
                                          Icon(Icons.water_drop, size: 14, color: Colors.blue),
                                          SizedBox(width: 4),
                                          Text(
                                            '${room.humidity.toStringAsFixed(1)}%',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Mũi tên chỉ hướng
                                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Nút kết nối nếu chưa kết nối
                  if (!_isConnected)
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _connectToServer,
                        icon: Icon(Icons.wifi_find),
                        label: Text('Kết nối lại'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  // Lấy icon tương ứng cho từng loại phòng
  IconData _getRoomIcon(String roomName) {
    final name = roomName.toLowerCase();
    
    if (name.contains('khách')) return Icons.weekend;
    if (name.contains('ngủ')) return Icons.bed;
    if (name.contains('bếp')) return Icons.kitchen;
    if (name.contains('làm việc')) return Icons.computer;
    if (name.contains('tắm')) return Icons.shower;
    
    return Icons.home;
  }
}