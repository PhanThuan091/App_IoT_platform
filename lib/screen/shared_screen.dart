import 'package:flutter/material.dart';

class SharedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Shared")),
      body: Center(child: Text("Shared Screen", style: TextStyle(fontSize: 20))),
    );
  }
}
