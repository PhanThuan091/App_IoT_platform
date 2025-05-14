// room.dart
import 'package:flutter/material.dart';

class Room {
  final String id;
  final String name;
  final List<Device> devices;
  double temperature; // Nhiệt độ (°C) từ DHT22
  double humidity; // Độ ẩm (%) từ DHT22
  PowerStats powerStats; // Thống kê điện năng

  Room({
    required this.id,
    required this.name,
    this.devices = const [],
    this.temperature = 0.0,
    this.humidity = 0.0,
    PowerStats? powerStats,
  }) : this.powerStats = powerStats ?? PowerStats();

  int getDevicesOnCount() {
    return devices.where((device) => device.isOn).length;
  }
  
  double getTotalPowerConsumption() {
    double total = 0;
    for (var device in devices) {
      if (device.isOn) {
        total += device.powerConsumption;
      }
    }
    return total;
  }
}

class Device {
  final String id;
  final String name;
  final String type;
  bool isOn;
  double powerConsumption; // Công suất tiêu thụ (W)
  double voltage;
  double current;
  double frequency;
  double energyUsage;
  
  Device({
    required this.id,
    required this.name,
    required this.type,
    this.isOn = false,
    this.powerConsumption = 0.0,
    this.voltage = 220.0,
    this.current = 0.0,
    this.frequency = 50.0,
    this.energyUsage = 0.0,
  });
}

class PowerStats {
  double voltage; // Điện áp (V)
  double current; // Dòng điện (A)
  double frequency; // Tần số (Hz)
  double power; // Công suất tiêu thụ (W)
  double energy; // Điện năng tiêu thụ (kWh)
  List<PowerHistory> history; // Lịch sử tiêu thụ
  
  PowerStats({
    this.voltage = 220.0,
    this.current = 0.0,
    this.frequency = 50.0,
    this.power = 0.0,
    this.energy = 0.0,
    List<PowerHistory>? history,
  }) : this.history = history ?? [];
  
  // Thêm điểm dữ liệu mới vào lịch sử
  void addHistoryPoint(DateTime time, double value) {
    history.add(PowerHistory(time: time, value: value));
    // Giữ tối đa 100 điểm dữ liệu
    if (history.length > 100) {
      history.removeAt(0);
    }
  }
}

class PowerHistory {
  final DateTime time;
  final double value; // Giá trị công suất (W)
  
  PowerHistory({
    required this.time,
    required this.value,
  });
}