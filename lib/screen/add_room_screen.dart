import 'package:flutter/material.dart';
import '../models/room.dart';
import '../services/room_service.dart';

class AddRoomScreen extends StatefulWidget {
  @override
  _AddRoomScreenState createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedRoomType = 'Phòng khách';
  final RoomService _roomService = RoomService();
  
  final List<String> _roomTypes = [
    'Phòng khách',
    'Phòng ngủ',
    'Nhà bếp',
    'Phòng làm việc',
    'Phòng tắm',
    'Khác',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveRoom() {
    if (_formKey.currentState!.validate()) {
      // Tạo ID phòng mới (có thể dùng UUID trong thực tế)
      final newRoomId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Tạo phòng mới
      final newRoom = Room(
        id: newRoomId,
        name: _nameController.text.trim(),
        devices: [],
        temperature: 28.0, // Giá trị mặc định
        humidity: 65.0,    // Giá trị mặc định
      );
      
      // Thêm phòng mới vào service
      _roomService.addRoom(newRoom);
      
      // Hiển thị thông báo và quay lại màn hình trước
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã thêm phòng thành công')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm phòng mới'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề form
              Text(
                'Thông tin phòng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              
              // Trường nhập tên phòng
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên phòng',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.home),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên phòng';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Trường chọn loại phòng
              DropdownButtonFormField<String>(
                value: _selectedRoomType,
                decoration: InputDecoration(
                  labelText: 'Loại phòng',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _roomTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedRoomType = newValue;
                    });
                  }
                },
              ),
              
              // Spacer để đẩy nút xuống cuối
              Spacer(),
              
              // Nút lưu
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveRoom,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Lưu phòng',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}