import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
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
  late Timer _timer;
  late String _currentDate;
  MqttServerClient? _client; // Client MQTT
  bool _isConnected = false; // Trạng thái kết nối
  Map<String, bool> _deviceStatus = {}; // Trạng thái thiết bị (bật/tắt)

  @override
  void initState() {
    super.initState();
    _currentTime = _getCurrentTime();
    _greeting = _getGreeting();
    _currentDate = _getCurrentDate();
    _timer = Timer.periodic(Duration(seconds: 1), _updateTime);
    _connectToServer(); // Kết nối tới server khi khởi động
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

  // Kết nối tới server MQTT trên Raspberry Pi
  Future<void> _connectToServer() async {
    _client = MqttServerClient('192.168.79.91', 'flutter_client');
    _client!.port = 1883; // Cổng mặc định của MQTT
    _client!.logging(on: false);
    _client!.onConnected = _onConnected;
    _client!.onDisconnected = _onDisconnected;
    _client!.onSubscribed = _onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client!.connectionMessage = connMessage;

    try {
      await _client!.connect();
    } catch (e) {
      print('Kết nối thất bại: $e');
      _client!.disconnect();
    }

    // Lắng nghe dữ liệu từ server
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      setState(() {
        // Cập nhật trạng thái thiết bị từ dữ liệu nhận được
        if (payload.contains('device')) {
          final deviceName = payload.split(':')[1];
          final status = payload.split(':')[2] == 'ON';
          _deviceStatus[deviceName] = status;
        }
      });
    });

    // Đăng ký topic để nhận dữ liệu từ LoRa
    _client!.subscribe('lora/devices', MqttQos.atLeastOnce);
  }

  // Khi kết nối thành công
  void _onConnected() {
    setState(() {
      _isConnected = true;
    });
    print('Đã kết nối tới server');
  }

  // Khi mất kết nối
  void _onDisconnected() {
    setState(() {
      _isConnected = false;
    });
    print('Mất kết nối tới server');
  }

  // Khi đăng ký topic thành công
  void _onSubscribed(String topic) {
    print('Đã đăng ký topic: $topic');
  }

  // Gửi lệnh điều khiển thiết bị
  void _controlDevice(String deviceName, bool turnOn) {
    if (_client != null && _isConnected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString('device:$deviceName:${turnOn ? 'ON' : 'OFF'}');
      _client!.publishMessage('lora/control', MqttQos.atLeastOnce, builder.payload!);
      setState(() {
        _deviceStatus[deviceName] = turnOn;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chưa kết nối tới server')),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _client?.disconnect();
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