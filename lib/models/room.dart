class Room {
  final String id;
  final String name;
  final List<Device> devices;
  
  // Thông số từ cảm biến DHT22
  double temperature;
  double humidity;
  
  // Thông số điện năng
  double voltage;        // Điện áp (V)
  double current;        // Dòng điện (A)
  double power;          // Công suất tiêu thụ (W)
  double energyUsage;    // Số điện tiêu thụ (kWh)
  List<PowerData> powerHistory;    // Lịch sử dữ liệu công suất
  List<PowerData> voltageHistory;  // Lịch sử dữ liệu điện áp
  List<PowerData> currentHistory;  // Lịch sử dữ liệu dòng điện
  List<PowerData> energyHistory;   // Lịch sử dữ liệu điện năng
  
  Room({
    required this.id,
    required this.name,
    required this.devices,
    this.temperature = 0.0,
    this.humidity = 0.0,
    this.voltage = 0.0,
    this.current = 0.0,
    this.power = 0.0,
    this.energyUsage = 0.0,
    List<PowerData>? powerHistory,
    List<PowerData>? voltageHistory,
    List<PowerData>? currentHistory,
    List<PowerData>? energyHistory,
  }) : this.powerHistory = powerHistory ?? [],
       this.voltageHistory = voltageHistory ?? [],
       this.currentHistory = currentHistory ?? [],
       this.energyHistory = energyHistory ?? [];
}

class Device {
  final String id;
  final String name;
  final String icon;
  bool isOn;
  double powerConsumption; // Công suất tiêu thụ của thiết bị (W)
  
  Device({
    required this.id,
    required this.name,
    required this.icon,
    this.isOn = false,
    this.powerConsumption = 0.0,
  });
}

class PowerData {
  final DateTime time;
  final double value;
  
  PowerData({
    required this.time,
    required this.value,
  });
}