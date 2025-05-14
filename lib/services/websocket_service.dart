import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../models/room.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final ValueNotifier<bool> connectionStatus = ValueNotifier<bool>(false);
  final ValueNotifier<List<Room>> rooms = ValueNotifier<List<Room>>([]);
  
  static final WebSocketService _instance = WebSocketService._internal();
  
  factory WebSocketService() {
    return _instance;
  }
  
  WebSocketService._internal();
  
  bool get isConnected => connectionStatus.value;
  
  Future<bool> connect(String url) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      connectionStatus.value = true;
      
      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onDone: () {
          connectionStatus.value = false;
        },
        onError: (error) {
          print('WebSocket Error: $error');
          connectionStatus.value = false;
        },
      );
      
      // Yêu cầu dữ liệu phòng ban đầu
      sendMessage({
        'type': 'REQUEST_DATA',
        'data': {'request': 'ALL_ROOMS'}
      });
      
      return true;
    } catch (e) {
      print('WebSocket Connection Error: $e');
      connectionStatus.value = false;
      return false;
    }
  }
  
  void disconnect() {
    _channel?.sink.close();
    connectionStatus.value = false;
  }
  
  void sendMessage(Map<String, dynamic> message) {
    if (isConnected) {
      _channel?.sink.add(jsonEncode(message));
    }
  }
  
  void _handleMessage(dynamic message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message);
      final String type = data['type'];
      
      switch (type) {
        case 'ROOMS_DATA':
          _handleRoomsData(data['data']);
          break;
        case 'DEVICE_TOGGLED':
          _handleDeviceToggled(data['data']);
          break;
        case 'ROOM_ADDED':
          _handleRoomAdded(data['data']);
          break;
        case 'ROOM_REMOVED':
          _handleRoomRemoved(data['data']);
          break;
        case 'DEVICE_ADDED':
          _handleDeviceAdded(data['data']);
          break;
        case 'DEVICE_REMOVED':
          _handleDeviceRemoved(data['data']);
          break;
        case 'POWER_HISTORY':
          _handlePowerHistory(data['data']);
          break;
      }
    } catch (e) {
      print('Error handling message: $e');
    }
  }
  
  void _handleRoomsData(Map<String, dynamic> data) {
    final List<dynamic> roomsData = data['rooms'];
    final List<Room> updatedRooms = [];
    
    for (var roomData in roomsData) {
      final List<Device> devices = [];
      
      for (var deviceData in roomData['devices']) {
        devices.add(Device(
          id: deviceData['id'],
          name: deviceData['name'],
          type: deviceData['type'],
          isOn: deviceData['isOn'] ?? false,
          powerConsumption: deviceData['powerConsumption'] != null ? 
              double.parse(deviceData['powerConsumption'].toString()) : 0.0,
          voltage: deviceData['voltage'] != null ? 
              double.parse(deviceData['voltage'].toString()) : 220.0,
          current: deviceData['current'] != null ? 
              double.parse(deviceData['current'].toString()) : 0.0,
          frequency: deviceData['frequency'] != null ? 
              double.parse(deviceData['frequency'].toString()) : 50.0,
          energyUsage: deviceData['energyUsage'] != null ? 
              double.parse(deviceData['energyUsage'].toString()) : 0.0,
        ));
      }
      
      updatedRooms.add(Room(
        id: roomData['id'],
        name: roomData['name'],
        devices: devices,
        temperature: roomData['temperature'] != null ? 
            double.parse(roomData['temperature'].toString()) : 0.0,
        humidity: roomData['humidity'] != null ? 
            double.parse(roomData['humidity'].toString()) : 0.0,
      ));
    }
    
    rooms.value = updatedRooms;
  }
  
  void _handleDeviceToggled(Map<String, dynamic> data) {
    final String roomId = data['roomId'];
    final String deviceId = data['deviceId'];
    final bool isOn = data['isOn'];
    
    final List<Room> updatedRooms = List<Room>.from(rooms.value);
    for (int i = 0; i < updatedRooms.length; i++) {
      if (updatedRooms[i].id == roomId) {
        final List<Device> updatedDevices = List<Device>.from(updatedRooms[i].devices);
        for (int j = 0; j < updatedDevices.length; j++) {
          if (updatedDevices[j].id == deviceId) {
            final Device updatedDevice = Device(
              id: updatedDevices[j].id,
              name: updatedDevices[j].name,
              type: updatedDevices[j].type,
              isOn: isOn,
              powerConsumption: updatedDevices[j].powerConsumption,
              voltage: updatedDevices[j].voltage,
              current: updatedDevices[j].current,
              frequency: updatedDevices[j].frequency,
              energyUsage: updatedDevices[j].energyUsage,
            );
            updatedDevices[j] = updatedDevice;
            break;
          }
        }
        updatedRooms[i] = Room(
          id: updatedRooms[i].id,
          name: updatedRooms[i].name,
          devices: updatedDevices,
          temperature: updatedRooms[i].temperature,
          humidity: updatedRooms[i].humidity,
        );
        break;
      }
    }
    
    rooms.value = updatedRooms;
  }
  
  void _handleRoomAdded(Map<String, dynamic> data) {
    final Room newRoom = Room(
      id: data['id'],
      name: data['name'],
      devices: [],
      temperature: data['temperature'] != null ? 
          double.parse(data['temperature'].toString()) : 0.0,
      humidity: data['humidity'] != null ? 
          double.parse(data['humidity'].toString()) : 0.0,
    );
    
    final List<Room> updatedRooms = List<Room>.from(rooms.value)..add(newRoom);
    rooms.value = updatedRooms;
  }
  
  void _handleRoomRemoved(Map<String, dynamic> data) {
    final String roomId = data['roomId'];
    
    final List<Room> updatedRooms = List<Room>.from(rooms.value)
        .where((room) => room.id != roomId).toList();
    rooms.value = updatedRooms;
  }
  
  void _handleDeviceAdded(Map<String, dynamic> data) {
    final String roomId = data['roomId'];
    final Device newDevice = Device(
      id: data['device']['id'],
      name: data['device']['name'],
      type: data['device']['type'],
      isOn: data['device']['isOn'] ?? false,
      powerConsumption: data['device']['powerConsumption'] != null ? 
          double.parse(data['device']['powerConsumption'].toString()) : 0.0,
      voltage: data['device']['voltage'] != null ? 
          double.parse(data['device']['voltage'].toString()) : 220.0,
      current: data['device']['current'] != null ? 
          double.parse(data['device']['current'].toString()) : 0.0,
      frequency: data['device']['frequency'] != null ? 
          double.parse(data['device']['frequency'].toString()) : 50.0,
      energyUsage: data['device']['energyUsage'] != null ? 
          double.parse(data['device']['energyUsage'].toString()) : 0.0,
    );
    
    final List<Room> updatedRooms = List<Room>.from(rooms.value);
    for (int i = 0; i < updatedRooms.length; i++) {
      if (updatedRooms[i].id == roomId) {
        final List<Device> updatedDevices = List<Device>.from(updatedRooms[i].devices)..add(newDevice);
        updatedRooms[i] = Room(
          id: updatedRooms[i].id,
          name: updatedRooms[i].name,
          devices: updatedDevices,
          temperature: updatedRooms[i].temperature,
          humidity: updatedRooms[i].humidity,
        );
        break;
      }
    }
    
    rooms.value = updatedRooms;
  }
  
  void _handleDeviceRemoved(Map<String, dynamic> data) {
    final String roomId = data['roomId'];
    final String deviceId = data['deviceId'];
    
    final List<Room> updatedRooms = List<Room>.from(rooms.value);
    for (int i = 0; i < updatedRooms.length; i++) {
      if (updatedRooms[i].id == roomId) {
        final List<Device> updatedDevices = List<Device>.from(updatedRooms[i].devices)
            .where((device) => device.id != deviceId).toList();
        updatedRooms[i] = Room(
          id: updatedRooms[i].id,
          name: updatedRooms[i].name,
          devices: updatedDevices,
          temperature: updatedRooms[i].temperature,
          humidity: updatedRooms[i].humidity,
        );
        break;
      }
    }
    
    rooms.value = updatedRooms;
  }
  
  void _handlePowerHistory(Map<String, dynamic> data) {
    // Cập nhật lịch sử tiêu thụ điện
    // Phần này sẽ được xử lý sau khi dữ liệu biểu đồ được thêm vào
  }
  
  // Methods to interact with server
  
  void toggleDevice(String roomId, String deviceId) {
    sendMessage({
      'type': 'TOGGLE_DEVICE',
      'data': {
        'roomId': roomId,
        'deviceId': deviceId,
      }
    });
  }
  
  void addRoom(String name) {
    sendMessage({
      'type': 'ADD_ROOM',
      'data': {
        'name': name,
      }
    });
  }
  
  void removeRoom(String roomId) {
    sendMessage({
      'type': 'REMOVE_ROOM',
      'data': {
        'roomId': roomId,
      }
    });
  }
  
  void addDevice(String roomId, String name, String type) {
    sendMessage({
      'type': 'ADD_DEVICE',
      'data': {
        'roomId': roomId,
        'name': name,
        'type': type,
      }
    });
  }
  
  void removeDevice(String roomId, String deviceId) {
    sendMessage({
      'type': 'REMOVE_DEVICE',
      'data': {
        'roomId': roomId,
        'deviceId': deviceId,
      }
    });
  }
  
  void requestPowerHistory(String roomId, String timeRange) {
    sendMessage({
      'type': 'REQUEST_POWER_HISTORY',
      'data': {
        'roomId': roomId,
        'timeRange': timeRange,
      }
    });
  }
}

class PowerHistoryEntry {
  final DateTime timestamp;
  final double power;
  
  PowerHistoryEntry({
    required this.timestamp,
    required this.power,
  });
  
  factory PowerHistoryEntry.fromJson(Map<String, dynamic> json) {
    return PowerHistoryEntry(
      timestamp: DateTime.parse(json['timestamp']),
      power: (json['power'] ?? 0.0).toDouble(),
    );
  }
}