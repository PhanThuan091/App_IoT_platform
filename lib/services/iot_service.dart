import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import '../models/room.dart';
import '../models/room_data.dart';

class IoTService {
  static final IoTService _instance = IoTService._internal();
  factory IoTService() => _instance;
  IoTService._internal();
  static const String _baseIpAddress = '196.169.5.109';
  IOWebSocketChannel? _channel;
  IOWebSocketChannel? _channelRoom1;
  IOWebSocketChannel? _channelRoom2;
  IOWebSocketChannel? _deviceControlChannel;
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
      // frequency: 50.0,
      power: 264.0,
      energyUsage: 1.5,
      powerHistory: _generateInitialPowerData(),
      devices: [
        // Device(id: 'room1_fan', name: 'Quạt trần', icon: 'fan'),
        // Device(id: 'room1_lamp1', name: 'Đèn chính', icon: 'light'),
        // Device(id: 'room1_tv', name: 'TV', icon: 'tv'),
        Device(id: 'room1_lamp1', name: 'Đèn chính', icon: 'light'),
        Device(id: 'room1_lamp2', name: 'Đèn phụ 1', icon: 'light'),
        Device(id: 'room1_lamp3', name: 'Đèn phụ 2', icon: 'light'),
        Device(id: 'room1_airConditioner', name: 'Máy lạnh', icon: 'ac'),
      ],
    ),
    Room(
      id: '2',
      name: 'Phòng 2',
      temperature: 26.0,
      humidity: 70.0,
      voltage: 220.0,
      current: 0.8,
      // frequency: 50.0,
      power: 176.0,
      energyUsage: 0.9,
      powerHistory: _generateInitialPowerData(),
      devices: [
        // Device(id: 'room2_fan', name: 'Quạt bàn', icon: 'fan'),
        // Device(id: 'room2_lamp1', name: 'Đèn ngủ', icon: 'light'),
        // Device(id: 'room2_airConditioner', name: 'Điều hòa', icon: 'ac'),
        Device(id: 'room2_lamp1', name: 'Đèn chính', icon: 'light'),
        Device(id: 'room2_lamp2', name: 'Đèn phụ 1', icon: 'light'),
        Device(id: 'room2_lamp3', name: 'Đèn phụ 2', icon: 'light'),
        Device(id: 'room2_airConditioner', name: 'Máy lạnh', icon: 'ac'),
      ],
    ),
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
          _handleMessage(message, '1');
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
  void _handleMessage(String message, String roomId) {
    try {
      // Parse dữ liệu từ message
      final List<dynamic> jsonData = jsonDecode(message);
      final List<RoomData> roomDataList = jsonData
          .map((data) => RoomData.fromJson(data as Map<String, dynamic>))
          .toList();
      
      // Tìm phòng dựa trên roomId
      int roomIndex = rooms.indexWhere((r) => r.id == roomId);

      if (roomIndex != -1) {
        final room = rooms[roomIndex];
        // Cập nhật dữ liệu cho phòng
        for (var roomData in roomDataList) {
          room.temperature = roomData.temperature;
          room.humidity = roomData.humidity;
          room.energyUsage = roomData.energy;

          // Lấy thời gian từ timeUpdate nếu có, nếu không thì lấy DateTime.now()
          DateTime now;
          if (roomData.timeUpdate != null) {
            try {
              now = DateTime.parse(roomData.timeUpdate!);
            } catch (_) {
              now = DateTime.now();
            }
          } else {
            now = DateTime.now();
          }

          // Lưu lịch sử điện áp
          if (roomData.voltage != null) {
            room.voltage = roomData.voltage!;
            room.voltageHistory.add(PowerData(
              time: now,
              value: room.voltage,
            ));
            if (room.voltageHistory.length > 500) {
              room.voltageHistory.removeAt(0);
            }
          }

          // Lưu lịch sử dòng điện
          if (roomData.current != null) {
            room.current = roomData.current!;
            room.currentHistory.add(PowerData(
              time: now,
              value: room.current,
            ));
            if (room.currentHistory.length > 500) {
              room.currentHistory.removeAt(0);
            }
          }

          // Lưu lịch sử công suất
          if (roomData.power != null) {
            room.power = roomData.power!;
            room.powerHistory.add(PowerData(
              time: now,
              value: room.power,
            ));
            if (room.powerHistory.length > 500) {
              room.powerHistory.removeAt(0);
            }
          }

          // Lưu lịch sử điện năng
          if (roomData.energy != null) {
            room.energyUsage = roomData.energy;
            room.energyHistory.add(PowerData(
              time: now,
              value: room.energyUsage,
            ));
            if (room.energyHistory.length > 500) {
              room.energyHistory.removeAt(0);
            }
          }
        }
      } else {
        print('Không tìm thấy phòng có id = $roomId');
      }
      
      // Thông báo cập nhật
      _roomsController.add(rooms);
      _mqttDataController.add(roomDataList);
    } catch (e) {
      print('Lỗi xử lý message: $e');
    }
  }
    // Kết nối đến kênh điều khiển thiết bị chung
  Future<void> connectDeviceControl(String url) async {
    try {
      _deviceControlChannel = IOWebSocketChannel.connect(url);
      
      _deviceControlChannel!.stream.listen(
        (message) {
          _handleDeviceControlMessage(message);
        },
        onDone: () {
          print('Device control channel disconnected');
          _roomsController.add(rooms);
        },
        onError: (error) {
          print('Lỗi kết nối kênh điều khiển thiết bị: $error');
        },
      );
      
      print('Đã kết nối thành công đến kênh điều khiển thiết bị');
    } catch (e) {
      print('Không thể kết nối đến kênh điều khiển thiết bị: $e');
    }
  }

   // Xử lý message từ kênh điều khiển thiết bị
  void _handleDeviceControlMessage(String message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message);
      // print('Nhận phản hồi điều khiển thiết bị: $data');
      
      for (var room in rooms) {
      for (var device in room.devices) {
        if (data.containsKey(device.id)) {
          device.isOn = data[device.id] == 1;
        }
      }
    }

    // Thông báo thay đổi để cập nhật giao diện
    _roomsController.add(rooms);
    } catch (e) {
      print('Lỗi xử lý message điều khiển thiết bị: $e');
    }
  }

  // Điều khiển thiết bị
  // Điều khiển thiết bị thông qua kênh /ws/devices
  void controlDevice(String roomId, String deviceId, bool turnOn) {
    if (_deviceControlChannel != null) {
      final message = jsonEncode({
        'type': 'control_device',
        'room_id': roomId,
        'device_id': deviceId,
        'action': turnOn ? 'ON' : 'OFF',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      print('Gửi lệnh điều khiển thiết bị: $message');
      _deviceControlChannel!.sink.add(message);
    } else {
      print('Kênh điều khiển thiết bị chưa được kết nối');
      
      // Thử kết nối lại kênh điều khiển thiết bị
      connectDeviceControl('ws://$_baseIpAddress:1880/ws/devices');
    }
    
    // Cập nhật trạng thái local (optimistic update)
    try {
      final room = rooms.firstWhere((r) => r.id == roomId);
      final device = room.devices.firstWhere((d) => d.id == deviceId);
      device.isOn = turnOn;
      
      // Thông báo thay đổi
      _roomsController.add(rooms);
    } catch (e) {
      print('Lỗi cập nhật trạng thái local: $e');
    }
  }

  // Đóng kết nối
  void dispose() {
    _channelRoom1?.sink.close();
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
  try {
    _channelRoom2 = IOWebSocketChannel.connect(url);
    print('Đang kết nối tới /ws/dataRoom2 tại $url...');
    _channelRoom2!.stream.listen(
      (message) {
        // print('Nhận dữ liệu từ /ws/dataRoom2: $message');
        _handleMessage(message, '2');
      },
      onDone: () {
        isConnected = false;
        _roomsController.add(rooms);
        print('Kết nối tới /ws/dataRoom2 đã đóng');
      },
      onError: (error) {
        print('Lỗi kết nối tới /ws/dataRoom2: $error');
        isConnected = false;
      },
    );
    isConnected = true;
    _roomsController.add(rooms);
    print('Đã kết nối thành công tới /ws/dataRoom2');
  } catch (e) {
    print('Không thể kết nối tới /ws/dataRoom2: $e');
    isConnected = false;
  }
}

  // Xử lý message từ WebSocket phòng cụ thể (/ws/room1, /ws/room2)
 void _handleRoomMessage(String message, String roomId) {
  try {
    final dynamic decodedData = jsonDecode(message);
    final room = rooms.firstWhere((r) => r.id == roomId);

    if (decodedData is List<dynamic>) {
      // Xử lý trường hợp dữ liệu là danh sách
      for (var item in decodedData) {
        if (item is Map<String, dynamic>) {
          _updateRoomFromMap(item, room);
        }
      }
    } else if (decodedData is Map<String, dynamic>) {
      // Xử lý trường hợp dữ liệu là một Map
      _updateRoomFromMap(decodedData, room);
    } else {
      print('Dữ liệu không hợp lệ từ phòng $roomId: $decodedData');
      return;
    }

    _roomsController.add(rooms);
  } catch (e) {
    print('Lỗi xử lý message từ phòng $roomId: $e');
  }
}

void _updateRoomFromMap(Map<String, dynamic> data, Room room) {
  final now = DateTime.now();
  
  if (data.containsKey('temperature')) {
    room.temperature = data['temperature'].toDouble();
  }
  if (data.containsKey('humidity')) {
    room.humidity = data['humidity'].toDouble();
  }
  if (data.containsKey('voltage')) {
    room.voltage = data['voltage'].toDouble();
    room.voltageHistory.add(PowerData(
      time: now,
      value: room.voltage,
    ));
    if (room.voltageHistory.length > 30) {
      room.voltageHistory.removeAt(0);
    }
  }
  if (data.containsKey('current')) {
    room.current = data['current'].toDouble();
    room.currentHistory.add(PowerData(
      time: now,
      value: room.current,
    ));
    if (room.currentHistory.length > 30) {
      room.currentHistory.removeAt(0);
    }
  }
  if (data.containsKey('power')) {
    room.power = data['power'].toDouble();
    room.powerHistory.add(PowerData(
      time: now,
      value: room.power,
    ));
    if (room.powerHistory.length > 30) {
      room.powerHistory.removeAt(0);
    }
  }
  if (data.containsKey('energy')) {
    room.energyUsage = data['energy'].toDouble();
    room.energyHistory.add(PowerData(
      time: now,
      value: room.energyUsage,
    ));
    if (room.energyHistory.length > 30) {
      room.energyHistory.removeAt(0);
    }
  }

  for (var device in room.devices) {
    if (data.containsKey(device.id)) {
      device.isOn = data[device.id] == 1;
    }
  }
}
} 


