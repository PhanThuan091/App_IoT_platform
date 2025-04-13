import 'package:flutter/material.dart';
import '../screen/unit_detail.dart';

class MyUnitsList extends StatelessWidget {
  final Map<String, bool> deviceStatus;
  final Function(String, bool) onControlDevice;

  MyUnitsList({required this.deviceStatus, required this.onControlDevice});

  final List<Map<String, dynamic>> units = [
    {'name': 'Quạt', 'icon': Icons.air_rounded, 'color': Colors.purple, 'location': 'Home'},
    {'name': 'Điều chỉnh công suất', 'icon': Icons.shield, 'color': Colors.grey, 'location': 'Home'},
    {'name': 'pzem004-t', 'icon': Icons.electrical_services, 'color': Colors.blue, 'location': 'Home'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: units.map((unit) {
        final deviceName = unit['name'];
        final isOn = deviceStatus[deviceName] ?? false;
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: unit['color'],
              child: Icon(unit['icon'], color: Colors.white),
            ),
            title: Text(unit['name'], style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(unit['location']),
            trailing: Switch(
              value: isOn,
              onChanged: (value) {
                onControlDevice(deviceName, value);
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UnitDetailScreen(
                    name: unit['name'],
                    icon: unit['icon'],
                    color: unit['color'],
                    location: unit['location'],
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}