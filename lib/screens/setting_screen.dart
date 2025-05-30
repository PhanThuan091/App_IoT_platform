import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDarkMode = themeService.themeMode == ThemeMode.dark;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Cài đặt',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            
            // Phần cài đặt tài khoản
            _buildSectionTitle('Tài khoản', Icons.person),
            SizedBox(height: 8),
            _buildSettingItem(
              icon: Icons.person_outline,
              title: 'Thông tin cá nhân',
              subtitle: 'Xem và chỉnh sửa thông tin tài khoản',
              onTap: () {},
            ),
                                 
            SizedBox(height: 24),
            
            // Phần cài đặt hệ thống
            _buildSectionTitle('Hệ thống', Icons.settings),
            SizedBox(height: 8),
            _buildSettingItem(
              icon: Icons.dark_mode,
              title: 'Giao diện',
              subtitle: isDarkMode ? 'Chế độ tối' : 'Chế độ sáng',
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  themeService.toggleTheme();
                },
                activeColor: Colors.blue,
              ),
              onTap: () {},
            ),
            // _buildSettingItem(
            //   icon: Icons.update,
            //   title: 'Cập nhật',
            //   subtitle: 'Kiểm tra phiên bản mới',
            //   onTap: () {},
            // ),
            
            SizedBox(height: 24),
            
            // Phần cài đặt thiết bị
            // _buildSectionTitle('Thiết bị', Icons.devices),
            // SizedBox(height: 8),
            // _buildSettingItem(
            //   icon: Icons.router,
            //   title: 'Kết nối',
            //   subtitle: 'Cài đặt kết nối mạng và WiFi',
            //   onTap: () {},
            // ),
            
            // _buildSettingItem(
            //   icon: Icons.device_hub,
            //   title: 'Quản lý thiết bị',
            //   subtitle: 'Thêm và quản lý thiết bị thông minh',
            //   onTap: () {},
            // ),
            
            // SizedBox(height: 24),
            
            // Phần thông tin
            _buildSectionTitle('Thông tin', Icons.info),
            SizedBox(height: 8),
            
            _buildSettingItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Chính sách riêng tư',
              subtitle: 'Xem chính sách riêng tư của ứng dụng',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.info_outline,
              title: 'Thông tin ứng dụng',
              subtitle: 'Phiên bản 1.0.0',
              onTap: () {},
            ),
            
            SizedBox(height: 24),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  // Widget tiêu đề mục cài đặt
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
  
  // Widget item cài đặt
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}