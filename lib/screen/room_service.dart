import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import '../screen/room.dart';

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
        Device(id: 'fan_1', name: 'Quạt trần', icon: 'fan'),
        Device(id: 'light_1', name: 'Đèn chính', icon: 'light'),
        Device(id: 'tv_1', name: 'TV', icon: 'tv'),
      ],
    ),
    Room(
      id: '2',
      name: 'Phòng ngủ',
      temperature: 26.0,
      humidity: 70.0,
      devices: [
        Device(id: 'fan_2', name: 'Quạt bàn', icon: 'fan'),
        Device(id: 'light_2', name: 'Đèn ngủ', icon: 'light'),
        Device(id: 'ac_1', name: 'Điều hòa', icon: 'ac'),
      ],
    ),
    Room(
      id: '3',
      name: 'Nhà bếp',
      temperature: 30.0,
      humidity: 60.0,
      devices: [
        Device(id: 'light_3', name: 'Đèn bếp', icon: 'light'),
        Device(id: 'fridge_1', name: 'Tủ lạnh', icon: 'fridge'),
        Device(id: 'oven_1', name: 'Lò vi sóng', icon: 'microwave'),
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
  void _handleMessage(String message) {
    try {
      final data = jsonDecode(message);
      
      if (data['type'] == 'room_data') {
        // Cập nhật thông tin phòng (nhiệt độ, độ ẩm)
        final String roomId = data['room_id'];
        final room = rooms.firstWhere((r) => r.id == roomId);
        
        if (data.containsKey('temperature')) {
          room.temperature = data['temperature'].toDouble();
        }
        
        if (data.containsKey('humidity')) {
          room.humidity = data['humidity'].toDouble();
        }
      } 
      else if (data['type'] == 'device_status') {
        // Cập nhật trạng thái thiết bị
        final String roomId = data['room_id'];
        final String deviceId = data['device_id'];
        final bool status = data['status'] == true;
        final double power = data.containsKey('power') ? data['power'].toDouble() : 0.0;
        
        final room = rooms.firstWhere((r) => r.id == roomId);
        final device = room.devices.firstWhere((d) => d.id == deviceId);
        
        device.isOn = status;
        device.powerConsumption = power;
      }
      
      // Thông báo thay đổi
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