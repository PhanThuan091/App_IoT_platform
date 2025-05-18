class RoomData {
  final String stt;
  final double temperature;
  final double humidity;
  final double energy;
  final String? timeUpdate;
  final double? current;
  final double? voltage;
  final double? power;

  RoomData({
    required this.stt,
    required this.temperature,
    required this.humidity,
    required this.energy,
    this.timeUpdate,
    this.current,
    this.voltage,
    this.power,
  });

  factory RoomData.fromJson(Map<String, dynamic> json) {
    return RoomData(
      stt: json['STT']?.toString() ?? '',
      temperature: double.tryParse(json['Temperature']?.toString() ?? '0') ?? 0.0,
      humidity: double.tryParse(json['Humidity']?.toString() ?? '0') ?? 0.0,
      energy: double.tryParse(json['Energy']?.toString() ?? '0') ?? 0.0,
      timeUpdate: json['TimeUpdate']?.toString(),
      current: double.tryParse(json['Current']?.toString() ?? '0'),
      voltage: double.tryParse(json['Voltage']?.toString() ?? '0'),
      power: double.tryParse(json['Power']?.toString() ?? '0'),
    );
  }
} 