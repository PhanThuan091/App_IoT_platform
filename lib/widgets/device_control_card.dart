import 'package:flutter/material.dart';
import '../models/room.dart';
import '../services/websocket_service.dart';

class DeviceControlCard extends StatelessWidget {
  final Device device;
  final String roomId;
  final WebSocketService webSocketService;

  const DeviceControlCard({
    Key? key,
    required this.device,
    required this.roomId,
    required this.webSocketService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: device.isOn 
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getDeviceIcon(),
                    color: device.isOn 
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    size: 24,
                  ),
                ),
                Switch(
                  value: device.isOn,
                  onChanged: (value) {
                    webSocketService.toggleDevice(roomId, device.id);
                  },
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              device.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              device.type.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Công suất:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${device.powerConsumption.toStringAsFixed(1)} W',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dòng điện:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${device.current.toStringAsFixed(2)} A',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Điện áp:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${device.voltage.toStringAsFixed(1)} V',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                _showDeviceDetailsDialog(context);
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Chi tiết',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDeviceIcon() {
    switch (device.type.toLowerCase()) {
      case 'light':
        return Icons.lightbulb;
      case 'fan':
        return Icons.air;
      case 'ac':
        return Icons.ac_unit;
      case 'tv':
        return Icons.tv;
      case 'refrigerator':
        return Icons.kitchen;
      case 'outlet':
        return Icons.power;
      default:
        return Icons.electrical_services;
    }
  }

  void _showDeviceDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(device.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Loại thiết bị', device.type.toUpperCase()),
            _buildDetailRow('Công suất', '${device.powerConsumption.toStringAsFixed(1)} W'),
            _buildDetailRow('Dòng điện', '${device.current.toStringAsFixed(2)} A'),
            _buildDetailRow('Điện áp', '${device.voltage.toStringAsFixed(1)} V'),
            _buildDetailRow('Tần số', '${device.frequency.toStringAsFixed(1)} Hz'),
            _buildDetailRow('Điện năng tiêu thụ', '${device.energyUsage.toStringAsFixed(2)} kWh'),
            _buildDetailRow('Trạng thái', device.isOn ? 'Đang bật' : 'Đã tắt'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Đóng'),
          ),
          TextButton(
            onPressed: () {
              // Hiển thị xác nhận xóa thiết bị
              Navigator.of(context).pop();
              _showDeleteDeviceConfirmation(context);
            },
            child: Text(
              'Xóa thiết bị',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _showDeleteDeviceConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa thiết bị'),
        content: Text('Bạn có chắc chắn muốn xóa ${device.name}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              webSocketService.removeDevice(roomId, device.id);
              Navigator.of(context).pop();
            },
            child: Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}