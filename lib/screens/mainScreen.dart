import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'notification_screen.dart';
import 'setting_screen.dart';
import 'bottom_navigation.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    DashboardScreen(),
    NotificationScreen(),
    SettingsScreen(),
  ];
  
  final List<String> _titles = [
    'Trang chủ',
    'Thông báo',
    'Cài đặt',
  ];
  
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}