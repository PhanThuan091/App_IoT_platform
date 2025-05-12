class Room {
  final String id;
  final String name;
  final List<Device> devices;
  double temperature;
  double humidity;
  
  Room({
    required this.id,
    required this.name,
    required this.devices,
    this.temperature = 0.0,
    this.humidity = 0.0,
  });
}

class Device {
  final String id;
  final String name;
  final String icon;
  bool isOn;
  double powerConsumption; // Công suất tiêu thụ (W)
  
  Device({
    required this.id,
    required this.name,
    required this.icon,
    this.isOn = false,
    this.powerConsumption = 0.0,
  });
}