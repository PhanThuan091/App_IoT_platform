import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import '../models/room.dart';
import '../models/room_data.dart';
import '../services/iot_service.dart';
import '../services/theme_service.dart';
import 'package:provider/provider.dart';
import 'room_detail_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const String _baseIpAddress = '196.169.5.109';
  late String _currentTime;
  late String _greeting;
  late String _currentDate;
  late Timer _timer;
  final IoTService _iotService = IoTService();
  bool _isConnected = false;
  List<RoomData> _mqttData = [];

  @override
  void initState() {
    super.initState();
    _currentTime = _getCurrentTime();
    _greeting = _getGreeting();
    _currentDate = _getCurrentDate();
    // _timer = Timer.periodic(Duration(seconds: 1), _updateTime);
    // Kiểm tra trạng thái kết nối ban đầu
    _isConnected = _iotService.isConnected;    
    // Khởi tạo kết nối nếu chưa kết nối
    if (!_isConnected) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _connectToServer();
        // _iotService.connectRoom2('ws://192.168.79.91:1880/ws/dataRoom2');
        _iotService.connectRoom2('ws://$_baseIpAddress:1880/ws/dataRoom2');
        if (!_iotService.isConnected) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể kết nối tới /ws/dataRoom2')),
          );
        }
      });
    }
    _reconnectToServer();

    // Kết  nối 2 phòng
    // _iotService.connectRoom1('ws://192.168.79.92:1880/ws/room1');
    // _iotService.connectRoom2('ws://192.168.79.92:1880/ws/room2');
    //wifi home
    _iotService.connectDeviceControl('ws://$_baseIpAddress:1880/ws/devices');
    
  }

  void _reconnectToServer() {
  if (!_iotService.isConnected) {
    Timer.periodic(Duration(seconds: 5), (timer) async {
      if (!_iotService.isConnected) {
        await _connectToServer();
      } else {
        timer.cancel();
      }
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
    if (now.hour < 12) return "Good morning, Phan Thành Thuận";
    else if (now.hour < 18) return "Good afternoon, Phan Thành Thuận";
    else return "Good evening, Phan Thành Thuận";
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
    if (_iotService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã kết nối tới server')),
      );
      return;
    }
    
    // Thay thế URL bằng địa chỉ thực của server
    // final success = await _iotService.connect('ws://192.168.100.74:1880/ws/smart_home');
    // final success = await _iotService.connect('ws://192.168.79.91:1880/ws/smart_home');
    // final success = await _iotService.connect('ws://196.169.7.206:1880/ws/smart_home');

    final success = await _iotService.connect('ws://$_baseIpAddress:1880/ws/smart_home');
    
    
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
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDarkMode = themeService.themeMode == ThemeMode.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45,
              height: 45,
              margin: EdgeInsets.only(right: 20, top: 8, bottom: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'lib/image/feee.png', // Thay đổi tên file theo ảnh thực tế
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.blue,
                      child: Icon(Icons.home, color: Colors.white, size: 20),
                    );
                  },
                ),
              ),
            ),
            Text(
              'My Dashboard',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            Container(
              width: 40,
              height: 50,
              margin: EdgeInsets.only(left: 16),
              child: ClipRRect(
                // borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'lib/image/ute.png', // Thay đổi tên file theo ảnh thực tế
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.green,
                      child: Icon(Icons.dashboard, color: Colors.white, size: 20),
                    );
                  },
                ),
              ),
            ),
          ],
        ),),
      body: StreamBuilder<List<RoomData>>(
        stream: _iotService.mqttDataStream,
        builder: (context, mqttSnapshot) {
          if (mqttSnapshot.hasData) {
            _mqttData = mqttSnapshot.data!;
          }
          
          return StreamBuilder<List<Room>>(
            stream: _iotService.roomsStream,
            initialData: _iotService.rooms,
            builder: (context, snapshot) {
              final rooms = snapshot.data ?? [];
              return SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header với thông tin thời tiết
                      _buildWeatherHeader(isDarkMode),
                      SizedBox(height: 24),
                      // Tiêu đề danh sách phòng
                      Text(
                        'Danh sách phòng',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      // Danh sách phòng
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          final room = rooms[index];
                          // Tìm dữ liệu MQTT tương ứng
                          final mqttRoom = _mqttData.firstWhere(
                            (r) => r.stt == room.id,
                            orElse: () => RoomData(
                              stt: room.id,
                              temperature: room.temperature,
                              humidity: room.humidity,
                              energy: room.energyUsage,
                            ),
                          );
                          // Đếm số thiết bị đang bật
                          final devicesOn = room.devices.where((d) => d.isOn).length;
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
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
                                        borderRadius: BorderRadius.circular(16),
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
                                                  color: Colors.red[400],
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
                                          // Wrap(
                                          //   spacing: 16,
                                          //   runSpacing: 4,
                                          //   children: [
                                          //     Row(
                                          //       mainAxisSize: MainAxisSize.min,
                                          //       children: [
                                          //         Icon(Icons.thermostat, size: 14, color: Colors.orange),
                                          //         SizedBox(width: 4),
                                          //         Text('${mqttRoom.temperature.toStringAsFixed(1)}°C', style: TextStyle(fontSize: 12)),
                                          //       ],
                                          //     ),
                                          //     Row(
                                          //       mainAxisSize: MainAxisSize.min,
                                          //       children: [
                                          //         Icon(Icons.water_drop, size: 14, color: Colors.blue),
                                          //         SizedBox(width: 4),
                                          //         Text('${mqttRoom.humidity.toStringAsFixed(1)}%', style: TextStyle(fontSize: 12)),
                                          //       ],
                                          //     ),
                                          //     Row(
                                          //       mainAxisSize: MainAxisSize.min,
                                          //       children: [
                                          //         Icon(Icons.bolt, size: 14, color: Colors.red),
                                          //         SizedBox(width: 4),
                                          //         Text('${mqttRoom.power?.toStringAsFixed(1) ?? '0.0'} W', style: TextStyle(fontSize: 12)),
                                          //       ],
                                          //     ),
                                          //     Row(
                                          //       mainAxisSize: MainAxisSize.min,
                                          //       children: [
                                          //         Icon(Icons.electric_meter, size: 14, color: Colors.green),
                                          //         SizedBox(width: 4),
                                          //         Text('${mqttRoom.energy.toStringAsFixed(1)} kWh', style: TextStyle(fontSize: 12)),
                                          //       ],
                                          //     ),
                                          //   ],
                                          // ),
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
                      if (!_isConnected)
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _connectToServer,
                            icon: Icon(Icons.wifi_find),
                            label: Text('Kết nối lại'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  // Widget header với thông tin thời tiết
  Widget _buildWeatherHeader(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề khóa luận
          Center(
            child: Text(
              'Khóa luận tốt nghiệp',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          // SizedBox(height: 8),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Expanded(
          //       child: Text(
          //         'Xây dựng nền tảng IoT quản lý năng lượng cho phòng trọ',
          //         style: TextStyle(
          //           fontSize: 16,
          //           fontWeight: FontWeight.bold,
          //           color: isDarkMode ? Colors.white : Colors.black87,
          //         ),
          //         textAlign: TextAlign.center,
          //       ),
          //     ),
          //   ],
          // ),
          SizedBox(height: 16),
          // Lời chào và nhiệt độ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _greeting,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Thông tin vị trí và thời tiết
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              SizedBox(width: 4),
              Text(
                'TP. Hồ Chí Minh, Việt Nam',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              SizedBox(width: 8),
              Text(
                '🌤',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          
          // SizedBox(height: 10),
          
          // Thông tin chi tiết thời tiết
        ],
      ),
    );
  }
  
  // Widget tổng quan tiêu thụ điện
  Widget _buildPowerSummaryCard(double power, double energy) {
    // Định dạng tiền tệ (VND)
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    
    // Tính toán chi phí điện (giả sử giá điện là 3,000 VND/kWh)
    final cost = energy * 3000;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.electric_meter, color: Colors.blue, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Tổng quan điện năng',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[100]!),
                  ),
                  child: Text(
                    'Hôm nay',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Thông tin điện năng
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Công suất tiêu thụ
                  Column(
                    children: [
                      Text(
                        'Công suất',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            power.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              ' W',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Đường kẻ dọc
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.blue[200],
                  ),
                  
                  // Điện năng tiêu thụ
                  Column(
                    children: [
                      Text(
                        'Điện năng',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            energy.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              ' kWh',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Chi phí tiêu thụ
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.monetization_on, color: Colors.green),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chi phí ước tính',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        currencyFormat.format(cost),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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