import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../services/websocket_service.dart';
import '../widgets/room_summary_card.dart';
import '../widgets/power_consumption_chart.dart';
import '../models/room.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final WebSocketService _webSocketService = WebSocketService();
  late Timer _clockTimer;
  late String _currentTime;
  late String _currentDate;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _clockTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateDateTime();
    });
    
    // Connect to WebSocket if not already connected
    if (!_webSocketService.isConnected) {
      _connectToWebSocket();
    }
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(now);
      _currentDate = DateFormat('EEEE, d MMMM yyyy').format(now);
    });
  }

  Future<void> _connectToWebSocket() async {
    const String wsUrl = 'ws://your-websocket-server-url/ws';
    bool connected = await _webSocketService.connect(wsUrl);
    if (!connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect to server. Please check your network connection.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Home Dashboard'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (!_webSocketService.isConnected) {
            await _connectToWebSocket();
          } else {
            _webSocketService.sendMessage({
              'type': 'REQUEST_DATA',
              'data': {'request': 'ALL_ROOMS'}
            });
          }
        },
        child: Column(
          children: [
            _buildDateTimeHeader(),
            _buildConnectionStatus(),
            _buildTotalPowerConsumption(),
            Expanded(
              child: _buildRoomsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentDate,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 4),
              Text(
                _currentTime,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          Icon(
            Icons.access_time,
            size: 40,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return ValueListenableBuilder<bool>(
      valueListenable: _webSocketService.connectionStatus,
      builder: (context, isConnected, _) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isConnected ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isConnected ? Icons.wifi : Icons.wifi_off,
                color: isConnected ? Colors.green : Colors.red,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                isConnected ? 'Connected to server' : 'Disconnected from server',
                style: TextStyle(
                  color: isConnected ? Colors.green : Colors.red,
                ),
              ),
              Spacer(),
              if (!isConnected)
                TextButton(
                  onPressed: _connectToWebSocket,
                  child: Text('Reconnect'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalPowerConsumption() {
    return ValueListenableBuilder<List<Room>>(
      valueListenable: _webSocketService.rooms,
      builder: (context, rooms, _) {
        double totalPower = 0;
        int activeDevices = 0;
        
        for (final room in rooms) {
          totalPower += room.getTotalPowerConsumption();
          activeDevices += room.getDevicesOnCount();
        }
        
        return Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Power Consumption',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${totalPower.toStringAsFixed(2)} W',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              PowerConsumptionChart(rooms: rooms),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(
                    context, 
                    '${rooms.length}', 
                    'Rooms',
                    Icons.meeting_room,
                  ),
                  _buildInfoItem(
                    context, 
                    '$activeDevices', 
                    'Active Devices',
                    Icons.power,
                  ),
                  _buildInfoItem(
                    context, 
                    rooms.isEmpty 
                      ? '0.0 °C' 
                      : '${rooms.map((r) => r.temperature).reduce((a, b) => a + b) / rooms.length}°C', 
                    'Avg Temp',
                    Icons.thermostat,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(BuildContext context, String value, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsList() {
    return ValueListenableBuilder<List<Room>>(
      valueListenable: _webSocketService.rooms,
      builder: (context, rooms, _) {
        if (rooms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home_work_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No rooms available',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // Show dialog to add room
                    _showAddRoomDialog();
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add Room'),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return RoomSummaryCard(
              room: room,
              onTap: () {
                Navigator.pushNamed(
                  context, 
                  '/room_details',
                  arguments: room.id,
                );
              },
            );
          },
        );
      },
    );
  }

  void _showAddRoomDialog() {
    final TextEditingController nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Room'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Room Name',
            border: OutlineInputBorder(),
          ),
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
                _webSocketService.addRoom(name);
                Navigator.of(context).pop();
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}