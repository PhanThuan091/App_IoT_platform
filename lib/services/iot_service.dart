import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import '../models/room.dart';
import '../models/room_data.dart';

class IoTService {
  static final IoTService _instance = IoTService._internal();
  factory IoTService() => _instance;
  IoTService._internal();

  IOWebSocketChannel? _channel;
  IOWebSocketChannel? _channelRoom1;
  IOWebSocketChannel? _channelRoom2;
  bool isConnected = false;
  
  // Danh sách các phòng
  List<Room> rooms = [
    Room(
      id: '1',
      name: 'Phòng 1',
      temperature: 28.5,
      humidity: 65.0,
      voltage: 220.0,
      current: 1.2,
      frequency: 50.0,
      power: 264.0,
      energyUsage: 1.5,
      powerHistory: _generateInitialPowerData(),
      devices: [
        Device(id: 'fan_1', name: 'Quạt trần', icon: 'fan'),
        Device(id: 'light_1', name: 'Đèn chính', icon: 'light'),
        Device(id: 'tv_1', name: 'TV', icon: 'tv'),
      ],
    ),
    Room(
      id: '2',
      name: 'Phòng 2',
      temperature: 26.0,
      humidity: 70.0,
      voltage: 220.0,
      current: 0.8,
      frequency: 50.0,
      power: 176.0,
      energyUsage: 0.9,
      powerHistory: _generateInitialPowerData(),
      devices: [
        Device(id: 'fan_2', name: 'Quạt bàn', icon: 'fan'),
        Device(id: 'light_2', name: 'Đèn ngủ', icon: 'light'),
        Device(id: 'ac_1', name: 'Điều hòa', icon: 'ac'),
      ],
    ),
    // Room(
    //   id: '3',
    //   name: 'Nhà bếp',
    //   temperature: 30.0,
    //   humidity: 60.0,
    //   voltage: 220.0,
    //   current: 2.5,
    //   frequency: 50.0,
    //   power: 550.0,
    //   energyUsage: 2.8,
    //   powerHistory: _generateInitialPowerData(),
    //   devices: [
    //     Device(id: 'light_3', name: 'Đèn bếp', icon: 'light'),
    //     Device(id: 'fridge_1', name: 'Tủ lạnh', icon: 'fridge'),
    //     Device(id: 'oven_1', name: 'Lò vi sóng', icon: 'microwave'),
    //   ],
    // ),
  ];

  // Stream controllers để phát sự kiện khi dữ liệu thay đổi
  final _roomsController = StreamController<List<Room>>.broadcast();
  Stream<List<Room>> get roomsStream => _roomsController.stream;

  // Stream controller cho dữ liệu MQTT
  final _mqttDataController = StreamController<List<RoomData>>.broadcast();
  Stream<List<RoomData>> get mqttDataStream => _mqttDataController.stream;

  // Tạo dữ liệu sơ bộ cho biểu đồ
  static List<PowerData> _generateInitialPowerData() {
    final now = DateTime.now();
    List<PowerData> data = [];
    
    for (int i = 15; i >= 0; i--) {
      data.add(
        PowerData(
          time: now.subtract(Duration(minutes: i * 10)),
          value: 150 + (i % 3) * 50 + (i % 5) * 20,
        )
      );
    }
    
    return data;
  }

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
          _roomsController.add(rooms);
        },
        onError: (error) {
          isConnected = false;
          _roomsController.add(rooms);
        },
      );
      
      isConnected = true;
      _roomsController.add(rooms);
      
      return true;
    } catch (e) {
      isConnected = false;
      return false;
    }
  }

  // Xử lý message từ WebSocket
  void _handleMessage(String message) {
    try {
      // Parse dữ liệu MQTT
      final List<dynamic> jsonData = jsonDecode(message);
      final List<RoomData> roomDataList = jsonData
          .map((data) => RoomData.fromJson(data as Map<String, dynamic>))
          .toList();
      
      for (var roomData in roomDataList) {
        // Tìm phòng theo STT, nếu không có thì cập nhật cho phòng 1
        int roomIndex = rooms.indexWhere((r) => r.id == roomData.stt);
        if (roomIndex == -1) {
          // Nếu không tìm thấy phòng, cập nhật cho phòng 1
          roomIndex = rooms.indexWhere((r) => r.id == '1');
        }
        if (roomIndex != -1) {
          final room = rooms[roomIndex];
          room.temperature = roomData.temperature;
          room.humidity = roomData.humidity;
          room.energyUsage = roomData.energy;
          if (roomData.voltage != null) room.voltage = roomData.voltage!;
          if (roomData.current != null) room.current = roomData.current!;
          if (roomData.power != null) {
            room.power = roomData.power!;
            room.powerHistory.add(PowerData(
              time: DateTime.now(),
              value: room.power,
            ));
            if (room.powerHistory.length > 30) {
              room.powerHistory.removeAt(0);
            }
          }
        }
      }
      // Thông báo thay đổi
      _roomsController.add(rooms);
      _mqttDataController.add(roomDataList);
    } catch (e) {
      print('Lỗi xử lý message: $e');
    }
  }

  // Điều khiển thiết bị
  void controlDevice(String roomId, String deviceId, bool turnOn) {
    if (_channelRoom1 != null && isConnected) {
      final message = jsonEncode({
        'type': 'control_device',
        'room_id': roomId,
        'device_id': deviceId,
        'action': turnOn ? 'ON' : 'OFF'
      });
      print('Sending to channelRoom1: $message');
      _channelRoom1!.sink.add(message);
    }
    
    // Cập nhật trạng thái local (optimistic update)
    final room = rooms.firstWhere((r) => r.id == roomId);
    final device = room.devices.firstWhere((d) => d.id == deviceId);
    device.isOn = turnOn;
    
    // Thông báo thay đổi
    _roomsController.add(rooms);
  }

  // Đóng kết nối
  void dispose() {
    _channel?.sink.close();
    _roomsController.close();
    _mqttDataController.close();
  }

  Future<void> connectRoom1(String url) async {
    _channelRoom1 = IOWebSocketChannel.connect(url);
    _channelRoom1!.stream.listen(
      (message) => _handleRoomMessage(message, '1'),
      onDone: () {
        _roomsController.add(rooms);
      },
      onError: (error) {
        _roomsController.add(rooms);
      },
    );
  }

  Future<void> connectRoom2(String url) async {
    _channelRoom2 = IOWebSocketChannel.connect(url);
    _channelRoom2!.stream.listen(
      (message) => _handleRoomMessage(message, '2'),
      onDone: () {
        _roomsController.add(rooms);
      },
      onError: (error) {
        _roomsController.add(rooms);
      },
    );
  }

  void _handleRoomMessage(String message, String roomId) {
    try {
      final data = jsonDecode(message);
      final List<dynamic> dataList = data is List ? data : [data];
      for (var item in dataList) {
        final roomData = RoomData.fromJson(item as Map<String, dynamic>);
        final room = rooms.firstWhere((r) => r.id == roomId, orElse: () => rooms[0]);
        room.temperature = roomData.temperature;
        room.humidity = roomData.humidity;
        room.energyUsage = roomData.energy;
        if (roomData.voltage != null) room.voltage = roomData.voltage!;
        if (roomData.current != null) room.current = roomData.current!;
        if (roomData.power != null) {
          room.power = roomData.power!;
          room.powerHistory.add(PowerData(
            time: DateTime.now(),
            value: room.power,
          ));
          if (room.powerHistory.length > 30) {
            room.powerHistory.removeAt(0);
          }
        }
      }
      _roomsController.add(rooms);
    } catch (e) {
      print('Lỗi xử lý message phòng $roomId: $e');
    }
  }
} 


