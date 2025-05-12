import 'package:flutter/material.dart';
import '../screen/room.dart';
import '../screen/room_service.dart';

class AddDeviceScreen extends StatefulWidget {
  final String roomId;
  
  AddDeviceScreen({required this.roomId});
  
  @override
  _AddDeviceScreenState createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final RoomService _roomService = RoomService();
  String _selectedDeviceType = 'light';
  double _powerConsumption = 0.0;
  
  final Map<String, String> _deviceTypes = {
    'light': 'Đèn',
    'fan': 'Quạt',
    'ac': 'Điều hòa',
    'tv': 'TV',
    'fridge': 'Tủ lạnh',
    'microwave': 'Lò vi sóng',
    'router': 'Router',
    'computer': 'Máy tính',
    'washer': 'Máy giặt',
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Lấy công suất mặc định cho thiết bị
  double _getDefaultPower(String deviceType) {
    switch (deviceType) {
      case 'light': return 10.0; // Đèn LED
      case 'fan': return 60.0;   // Quạt trần
      case 'ac': return 1500.0;  // Điều hòa
      case 'tv': return 120.0;   // TV
      case 'fridge': return 150.0; // Tủ lạnh
      case 'microwave': return 800.0; // Lò vi sóng
      case 'router': return 10.0;  // Router
      case 'computer': return 300.0; // Máy tính
      case 'washer': return 500.0;  // Máy giặt
      default: return 50.0;
    }
  }

  void _saveDevice() {
    if (_formKey.currentState!.validate()) {
      // Tạo ID thiết bị mới
      final newDeviceId = '${_selectedDeviceType}_${DateTime.now().millisecondsSinceEpoch}';
      
      // Tạo thiết bị mới
      final newDevice = Device(
        id: newDeviceId,
        name: _nameController.text.trim(),
        icon: _selectedDeviceType,
        isOn: false,
        powerConsumption: _powerConsumption,
      );
      
      // Thêm thiết bị vào phòng
      _roomService.addDeviceToRoom(widget.roomId, newDevice);
      
      // Hiển thị thông báo và quay lại màn hình chi tiết phòng
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã thêm thiết bị thành công')),
      );
      Navigator.pop(context);
    }
  }
  
  @override
  void initState() {
    super.initState();
    // Thiết lập công suất mặc định ban đầu
    _powerConsumption = _getDefaultPower(_selectedDeviceType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm thiết bị mới'),
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
                'Thông tin thiết bị',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              
              // Trường nhập tên thiết bị
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên thiết bị',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.devices),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên thiết bị';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Trường chọn loại thiết bị
              DropdownButtonFormField<String>(
                value: _selectedDeviceType,
                decoration: InputDecoration(
                  labelText: 'Loại thiết bị',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _deviceTypes.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedDeviceType = newValue;
                      // Cập nhật công suất mặc định khi loại thiết bị thay đổi
                      _powerConsumption = _getDefaultPower(newValue);
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              
              // Trường nhập công suất tiêu thụ
              Text(
                'Công suất tiêu thụ (W)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      min: 0,
                      max: 2000,
                      divisions: 200,
                      value: _powerConsumption,
                      label: '${_powerConsumption.toStringAsFixed(1)} W',
                      onChanged: (value) {
                        setState(() {
                          _powerConsumption = value;
                        });
                      },
                    ),
                  ),
                  Container(
                    width: 70,
                    child: Text(
                      '${_powerConsumption.toStringAsFixed(1)} W',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Hiển thị mô tả công suất
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _getPowerDescription(_powerConsumption),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              
              // Thêm dự đoán tiêu thụ điện
              Card(
                margin: EdgeInsets.symmetric(vertical: 16),
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bolt, color: Colors.amber, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Dự đoán tiêu thụ điện',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      _buildPowerEstimation(
                        'Một giờ',
                        (_powerConsumption / 1000 * 3000).toStringAsFixed(0),
                      ),
                      _buildPowerEstimation(
                        'Một ngày (8 giờ)',
                        (_powerConsumption / 1000 * 3000 * 8).toStringAsFixed(0),
                      ),
                      _buildPowerEstimation(
                        'Một tháng (30 ngày, 8 giờ/ngày)',
                        (_powerConsumption / 1000 * 3000 * 8 * 30).toStringAsFixed(0),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Spacer để đẩy nút xuống cuối
              Spacer(),
              
              // Nút lưu
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveDevice,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Lưu thiết bị',
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
  
  // Widget hiển thị ước tính tiêu thụ điện
  Widget _buildPowerEstimation(String period, String cost) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            period,
            style: TextStyle(fontSize: 14),
          ),
          Text(
            _formatCurrency(double.parse(cost)) + ' VND',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  // Định dạng tiền tệ
  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }
  
  // Lấy mô tả công suất
  String _getPowerDescription(double power) {
    if (power < 20) {
      return 'Tiêu thụ rất thấp - Phù hợp với thiết bị LED, sạc điện thoại';
    } else if (power < 100) {
      return 'Tiêu thụ thấp - Tương đương quạt bàn, đèn năng lượng thấp';
    } else if (power < 300) {
      return 'Tiêu thụ trung bình - Tương đương TV, máy tính';
    } else if (power < 1000) {
      return 'Tiêu thụ cao - Tương đương máy giặt, lò vi sóng';
    } else {
      return 'Tiêu thụ rất cao - Tương đương máy điều hòa, máy sưởi';
    }
  }
}