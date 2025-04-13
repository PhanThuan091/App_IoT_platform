import 'package:flutter/material.dart';

class SmartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Smart")),
      body: Center(child: Text("Smart Screen", style: TextStyle(fontSize: 20))),
    );
  }
}
