import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Thêm để sử dụng SchedulerBinding
import 'dart:async';
import 'package:web_socket_channel/io.dart';
import '../widgets/weather_card.dart';
import '../widgets/my_units_list.dart';
import 'edit_units_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late String _currentTime;
  late String _greeting;
  late String _currentDate;
  late Timer _timer;
  IOWebSocketChannel? _channel; // WebSocket channel
  bool _isConnected = false; // Trạng thái kết nối
  Map<String, bool> _deviceStatus = {'Fan': false, 'Light': false}; // Trạng thái thiết bị

  @override
  void initState() {
    super.initState();
    _currentTime = _getCurrentTime();
    _greeting = _getGreeting();
    _currentDate = _getCurrentDate();
    _timer = Timer.periodic(Duration(seconds: 1), _updateTime);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Khởi tạo WebSocket trong didChangeDependencies
    if (_channel == null) {
      _initializeWebSocket();
    }
  }

  // Khởi tạo WebSocket
  void _initializeWebSocket() {
    try {
      _channel = IOWebSocketChannel.connect('ws://192.168.79.92:1880/ws/devices');
      // _channel = IOWebSocketChannel.connect('ws://192.168.100.74:1880/ws/devices');
      _channel!.stream.listen(
        (message) {
          print('Nhận được dữ liệu: $message');
          _handleReceivedMessage(message);
        },
        onDone: () {
          print('Kết nối WebSocket bị đóng');
          setState(() {
            _isConnected = false;
          });
          // Dùng post-frame callback để hiển thị SnackBar
          SchedulerBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Mất kết nối tới server')),
            );
          });
        },
        onError: (error) {
          print('Lỗi WebSocket: $error');
          setState(() {
            _isConnected = false;
          });
          // Dùng post-frame callback để hiển thị SnackBar
          SchedulerBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi kết nối tới server')),
            );
          });
        },
      );
      setState(() {
        _isConnected = true;
      });
      print('Đã kết nối tới WebSocket server');
    } catch (e) {
      print('Lỗi khởi tạo WebSocket: $e');
      setState(() {
        _isConnected = false;
      });
      // Dùng post-frame callback để hiển thị SnackBar
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể kết nối tới server')),
        );
      });
    }
  }

  // Xử lý dữ liệu nhận được từ WebSocket
  void _handleReceivedMessage(String message) {
    if (message.contains('device')) {
      final parts = message.split(':');
      if (parts.length == 3) {
        final deviceName = parts[1];
        final status = parts[2] == 'ON';
        setState(() {
          _deviceStatus[deviceName] = status;
        });
      }
    }
  }

  // Lấy thời gian hiện tại
  String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
  }

  // Lấy ngày hiện tại
  String _getCurrentDate() {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
  }

  // Lấy lời chào
  String _getGreeting() {
    final now = DateTime.now();
    if (now.hour < 12) return "Good morning";
    else if (now.hour < 18) return "Good afternoon";
    else return "Good evening";
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
    if (_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã kết nối tới server')),
      );
      return;
    }
    _initializeWebSocket();
  }

  // Gửi lệnh điều khiển thiết bị
  void _controlDevice(String deviceName, bool turnOn) {
    if (_channel != null && _isConnected) {
      final message = 'device:$deviceName:${turnOn ? 'ON' : 'OFF'}';
      _channel!.sink.add(message);
      setState(() {
        _deviceStatus[deviceName] = turnOn;
      });
      print('Gửi lệnh: $message');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chưa kết nối tới server')),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              '$_greeting, Phan Thành Thuận',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              '$_currentTime , $_currentDate',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trạng thái server:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  _isConnected ? 'Đã kết nối' : 'Chưa kết nối',
                  style: TextStyle(
                    fontSize: 16,
                    color: _isConnected ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _connectToServer,
              child: Text(_isConnected ? 'Đã kết nối' : 'Kết nối WebSocket'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isConnected ? Colors.grey : Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            WeatherCard(),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Units',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditUnitsScreen()),
                    );
                  },
                  child: Text("Edit"),
                ),
              ],
            ),
            SizedBox(height: 12),
            MyUnitsList(
              deviceStatus: _deviceStatus,
              onControlDevice: _controlDevice, // Truyền hàm điều khiển
            ),
          ],
        ),
      ),
    );
  }
}