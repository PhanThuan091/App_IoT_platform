import 'package:flutter/material.dart';

class EditUnitsScreen extends StatefulWidget {
  @override
  _EditUnitsScreenState createState() => _EditUnitsScreenState();
}

class _EditUnitsScreenState extends State<EditUnitsScreen> {
  List<String> _devices = [];  // To store added devices

  void _addDevice() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController deviceController = TextEditingController();
        return AlertDialog(
          title: Text("Add New Device"),
          content: TextField(
            controller: deviceController,
            decoration: InputDecoration(hintText: "Enter device name"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  if (deviceController.text.isNotEmpty) {
                    _devices.add(deviceController.text); // Add device to the list
                  }
                });
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Units")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _addDevice,
              child: Text("Add Device"),
            ),
            SizedBox(height: 12),
            Text(
              'Added Devices:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_devices[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
