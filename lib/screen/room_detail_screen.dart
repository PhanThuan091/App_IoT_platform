import 'package:flutter/material.dart';
import '../services/websocket_service.dart';
import '../models/room.dart';
import '../widgets/device_control_card.dart';
import '../widgets/room_environmental_card.dart';
import '../widgets/power_metrics_card.dart';


class RoomDetailScreen extends StatefulWidget {
  final String roomId;

  const RoomDetailScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  _RoomDetailScreenState createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  final WebSocketService _webSocketService = WebSocketService();
  String _selectedTimeRange = '24h';

  @override
  void initState() {
    super.initState();
    // Request power history data
    _webSocketService.requestPowerHistory(widget.roomId, _selectedTimeRange);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<List<Room>>(
          valueListenable: _webSocketService.rooms,
          builder: (context, rooms, _) {
            final room = rooms.firstWhere(
              (r) => r.id == widget.roomId,
              orElse: () => Room(
                id: widget.roomId,
                name: 'Loading...',
                temperature: 0,
                humidity: 0,
                devices: [],
              ),
            );
            return Text(room.name);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _webSocketService.requestPowerHistory(widget.roomId, _selectedTimeRange);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Refreshing data...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _showDeleteRoomDialog();
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Room>>(
        valueListenable: _webSocketService.rooms,
        builder: (context, rooms, _) {
          final room = rooms.firstWhere(
            (r) => r.id == widget.roomId,
            orElse: () => Room(
              id: widget.roomId,
              name: 'Unknown Room',
              temperature: 0,
              humidity: 0,
              devices: [],
            ),
          );
          
          if (room.name == 'Unknown Room') {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              _webSocketService.requestPowerHistory(widget.roomId, _selectedTimeRange);
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room Environmental Data
                  RoomEnvironmentalCard(room: room),
                  SizedBox(height: 16),
                  
                  // Power Metrics
                  _buildPowerMetricsSection(room),
                  SizedBox(height: 16),
                  
                  // Devices Section
                  _buildDevicesSection(room),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDeviceDialog();
        },
        child: Icon(Icons.add),
        tooltip: 'Add Device',
      ),
    );
  }

  Widget _buildPowerMetricsSection(Room room) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Power Metrics',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              DropdownButton<String>(
                value: _selectedTimeRange,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedTimeRange = newValue;
                    });
                    _webSocketService.requestPowerHistory(widget.roomId, newValue);
                  }
                },
                items: ['24h', '7d', '30d', '1y']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        PowerMetricsCard(
          room: room,
          showChart: true,
          showDetailed: true,
          timeRange: _selectedTimeRange,
        ),
      ],
    );
  }

  Widget _buildDevicesSection(Room room) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Devices (${room.devices.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(height: 8),
        if (room.devices.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.devices_other,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No devices in this room',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddDeviceDialog();
                    },
                    icon: Icon(Icons.add),
                    label: Text('Add Device'),
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: room.devices.length,
            itemBuilder: (context, index) {
              final device = room.devices[index];
              return DeviceControlCard(
                device: device,
                roomId: room.id,
                webSocketService: _webSocketService,
              );
            },
          ),
      ],
    );
  }

  void _showAddDeviceDialog() {
    final TextEditingController nameController = TextEditingController();
    String selectedType = 'light';
    
    final deviceTypes = [
      'light',
      'fan',
      'ac',
      'tv',
      'refrigerator',
      'outlet',
      'other',
    ];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Add New Device'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Device Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Device Type',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedType = newValue;
                      });
                    }
                  },
                  items: deviceTypes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.toUpperCase()),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final String name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    _webSocketService.addDevice(widget.roomId, name, selectedType);
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Add'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showDeleteRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Room'),
        content: Text('Are you sure you want to delete this room? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _webSocketService.removeRoom(widget.roomId);
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous screen
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}