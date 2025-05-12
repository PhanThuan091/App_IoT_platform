import 'package:flutter/material.dart';
import '../screen/room.dart';

class DeviceControlCard extends StatelessWidget {
  final Device device;
  final String roomId;
  final Function(bool) onToggle;
  
  DeviceControlCard({
    required this.device,
    required this.roomId,
    required this.onToggle,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icon thiết bị
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: device.isOn 
                    ? _getDeviceColor(device.name).withOpacity(0.2)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getDeviceIcon(device.icon),
                color: device.isOn ? _getDeviceColor(device.name) : Colors.grey,
                size: 24,
              ),
            ),
            
            SizedBox(width: 16),
            
            // Thông tin thiết bị
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: device.isOn ? Colors.black : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.power,
                        size: 14,
                        color: device.isOn ? Colors.green : Colors.grey,
                      ),
                      SizedBox(width: 4),
                      Text(
                        device.isOn ? 'Đang hoạt động' : 'Đã tắt',
                        style: TextStyle(
                          fontSize: 12,
                          color: device.isOn ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (device.isOn && device.powerConsumption > 0)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.bolt,
                            size: 14,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${device.powerConsumption.toStringAsFixed(1)} W',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // Switch điều khiển
            Switch(
              value: device.isOn,
              onChanged: onToggle,
              activeColor: _getDeviceColor(device.name),
            ),
          ],
        ),
      ),
    );
  }
  
  // Lấy icon cho thiết bị
  IconData _getDeviceIcon(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'fan':
        return Icons.air;
      case 'light':
        return Icons.lightbulb;
      case 'ac':
        return Icons.ac_unit;
      case 'tv':
        return Icons.tv;
      case 'fridge':
        return Icons.kitchen;
      case 'microwave':
        return Icons.microwave;
      case 'router':
        return Icons.router;
      case 'computer':
        return Icons.computer;
      case 'washer':
        return Icons.local_laundry_service;
      default:
        return Icons.electrical_services;
    }
  }
  
  // Lấy màu sắc cho thiết bị
  Color _getDeviceColor(String deviceName) {
    final name = deviceName.toLowerCase();
    
    if (name.contains('fan') || name.contains('quạt')) return Colors.blue;
    if (name.contains('light') || name.contains('đèn')) return Colors.amber;
    if (name.contains('ac') || name.contains('điều hòa')) return Colors.lightBlue;
    if (name.contains('tv') || name.contains('tivi')) return Colors.red;
    if (name.contains('fridge') || name.contains('tủ lạnh')) return Colors.indigo;
    if (name.contains('microwave') || name.contains('lò')) return Colors.deepOrange;
    if (name.contains('router') || name.contains('wifi')) return Colors.purple;
    if (name.contains('computer') || name.contains('máy tính')) return Colors.teal;
    if (name.contains('washer') || name.contains('máy giặt')) return Colors.cyan;
    
    return Colors.blue;
  }
}