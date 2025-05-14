import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import '../models/room.dart';

class RoomService {
  static final RoomService _instance = RoomService._internal();
  factory RoomService() => _instance;
  RoomService._internal();

  IOWebSocketChannel? _channel;
  bool isConnected = false;
  
  // Danh sách các phòng
  List<Room> rooms = [
    Room(
      id: '1',
      name: 'Phòng khách',
      temperature: 28.5,
      humidity: 65.0,
      devices: [
        Device(id: 'fan_1', name: 'Quạt trần', type: 'fan'),
        Device(id: 'light_1', name: 'Đèn chính', type: 'light'),
        Device(id: 'tv_1', name: 'TV', type: 'tv'),
      ],
    ),
    Room(
      id: '2',
      name: 'Phòng ngủ',
      temperature: 26.0,
      humidity: 70.0,
      devices: [
        Device(id: 'fan_2', name: 'Quạt bàn', type: 'fan'),
        Device(id: 'light_2', name: 'Đèn ngủ', type: 'light'),
        Device(id: 'ac_1', name: 'Điều hòa', type: 'ac'),
      ],
    ),
    Room(
      id: '3',
      name: 'Nhà bếp',
      temperature: 30.0,
      humidity: 60.0,
      devices: [
        Device(id: 'light_3', name: 'Đèn bếp', type: 'light'),
        Device(id: 'fridge_1', name: 'Tủ lạnh', type: 'fridge'),
        Device(id: 'oven_1', name: 'Lò vi sóng', type: 'microwave'),
      ],
    ),
  ];

  // Stream controllers để phát sự kiện khi dữ liệu thay đổi
  final _roomsController = StreamController<List<Room>>.broadcast();
  Stream<List<Room>> get roomsStream => _roomsController.stream;

  // Kết nối tới WebSocket
  Future<bool> connect(String url) async {
    try {
      _channel = IOWebSocketChannel.connect(url);
      
      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onDone: () {
          isConnected = false;
          _roomsController.add(rooms); // Cập nhật UI
        },
        onError: (error) {
          isConnected = false;
          _roomsController.add(rooms); // Cập nhật UI
        },
      );
      
      isConnected = true;
      _roomsController.add(rooms); // Cập nhật UI
      return true;
    } catch (e) {
      isConnected = false;
      return false;
    }
  }

  // Xử lý message từ WebSocket
 void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      if (data['type'] == 'room_data') {
        final String roomId = data['room_id'];
        final room = rooms.firstWhere((r) => r.id == roomId);
        room.temperature = data['temperature']?.toDouble() ?? room.temperature;
        room.humidity = data['humidity']?.toDouble() ?? room.humidity;
        // Cập nhật thông số điện năng
        room.powerStats.voltage = data['voltage']?.toDouble() ?? room.powerStats.voltage;
        room.powerStats.current = data['current']?.toDouble() ?? room.powerStats.current;
        room.powerStats.frequency = data['frequency']?.toDouble() ?? room.powerStats.frequency;
        room.powerStats.power = data['power']?.toDouble() ?? room.powerStats.power;
        room.powerStats.energy = data['energy']?.toDouble() ?? room.powerStats.energy;
        if (data['history'] != null) {
          room.powerStats.addHistoryPoint(DateTime.now(), data['history'].toDouble());
        }
      } else if (data['type'] == 'device_status') {
        final String roomId = data['room_id'];
        final String deviceId = data['device_id'];
        final room = rooms.firstWhere((r) => r.id == roomId);
        final device = room.devices.firstWhere((d) => d.id == deviceId);
        device.isOn = data['status'] == true;
        device.powerConsumption = data['power']?.toDouble() ?? 0.0;
      }
      _roomsController.add(rooms);
    } catch (e) {
      print('Lỗi xử lý message: $e');
    }
  }

  // Điều khiển thiết bị
  void controlDevice(String roomId, String deviceId, bool turnOn) {
    if (_channel != null && isConnected) {
      final message = jsonEncode({
        'type': 'control_device',
        'room_id': roomId,
        'device_id': deviceId,
        'action': turnOn ? 'ON' : 'OFF'
      });
      
      _channel!.sink.add(message);
      
      // Cập nhật trạng thái local (optimistic update)
      final room = rooms.firstWhere((r) => r.id == roomId);
      final device = room.devices.firstWhere((d) => d.id == deviceId);
      device.isOn = turnOn;
      
      // Thông báo thay đổi
      _roomsController.add(rooms);
    }
  }

  // Thêm phòng mới
  void addRoom(Room room) {
    rooms.add(room);
    _roomsController.add(rooms);
  }

  // Thêm thiết bị vào phòng
  void addDeviceToRoom(String roomId, Device device) {
    final room = rooms.firstWhere((r) => r.id == roomId);
    room.devices.add(device);
    _roomsController.add(rooms);
  }

  // Đóng kết nối
  void dispose() {
    _channel?.sink.close();
    _roomsController.close();
  }
}