import 'package:flutter/material.dart';
import '../services/websocket_service.dart';
import '../widgets/room_summary_card.dart';
import '../models/room.dart';


class RoomsScreen extends StatefulWidget {
  @override
  _RoomsScreenState createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final WebSocketService _webSocketService = WebSocketService();
  String _sortBy = 'name'; // Options: name, temperature, power, devices

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phòng'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_by_alpha,
                      color: _sortBy == 'name' 
                          ? Theme.of(context).primaryColor 
                          : null,
                    ),
                    SizedBox(width: 8),
                    Text('Sort by Name'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'temperature',
                child: Row(
                  children: [
                    Icon(
                      Icons.thermostat,
                      color: _sortBy == 'temperature' 
                          ? Theme.of(context).primaryColor 
                          : null,
                    ),
                    SizedBox(width: 8),
                    Text('Sort by Temperature'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'power',
                child: Row(
                  children: [
                    Icon(
                      Icons.bolt,
                      color: _sortBy == 'power' 
                          ? Theme.of(context).primaryColor 
                          : null,
                    ),
                    SizedBox(width: 8),
                    Text('Sort by Power Consumption'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'devices',
                child: Row(
                  children: [
                    Icon(
                      Icons.devices,
                      color: _sortBy == 'devices' 
                          ? Theme.of(context).primaryColor 
                          : null,
                    ),
                    SizedBox(width: 8),
                    Text('Sort by Device Count'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (!_webSocketService.isConnected) {
            // Try to reconnect if not connected
            await _webSocketService.connect('ws://your-websocket-server-url/ws');
          } else {
            _webSocketService.sendMessage({
              'type': 'REQUEST_DATA',
              'data': {'request': 'ALL_ROOMS'}
            });
          }
        },
        child: ValueListenableBuilder<List<Room>>(
          valueListenable: _webSocketService.rooms,
          builder: (context, rooms, _) {
            // Sort rooms based on selected criteria
            final sortedRooms = List<Room>.from(rooms);
            switch (_sortBy) {
              case 'name':
                sortedRooms.sort((a, b) => a.name.compareTo(b.name));
                break;
              case 'temperature':
                sortedRooms.sort((a, b) => b.temperature.compareTo(a.temperature));
                break;
              case 'power':
                sortedRooms.sort((a, b) => b.getTotalPowerConsumption().compareTo(a.getTotalPowerConsumption()));
                break;
              case 'devices':
                sortedRooms.sort((a, b) => b.devices.length.compareTo(a.devices.length));
                break;
            }
            
            if (sortedRooms.isEmpty) {
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
              itemCount: sortedRooms.length,
              itemBuilder: (context, index) {
                final room = sortedRooms[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: RoomSummaryCard(
                    room: room,
                    onTap: () {
                      Navigator.pushNamed(
                        context, 
                        '/room_details',
                        arguments: room.id,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddRoomDialog();
        },
        child: Icon(Icons.add),
        tooltip: 'Add Room',
      ),
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