import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Thông báo',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                // IconButton(
                //   icon: Icon(Icons.more_vert),
                //   onPressed: () {},
                // ),
              ],
            ),
            SizedBox(height: 16),
            
            // Tab lọc thông báo
            // Container(
            //   height: 40,
            //   decoration: BoxDecoration(
            //     color: Colors.grey[200],
            //     borderRadius: BorderRadius.circular(20),
            //   ),
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: Container(
            //           decoration: BoxDecoration(
            //             color: Colors.blue,
            //             borderRadius: BorderRadius.circular(20),
            //           ),
            //           alignment: Alignment.center,
            //           child: Text(
            //             'Tất cả',
            //             style: TextStyle(
            //               color: Colors.white,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            //         ),
            //       ),
            //       Expanded(
            //         child: Container(
            //           alignment: Alignment.center,
            //           child: Text(
            //             'Chưa đọc',
            //             style: TextStyle(
            //               color: Colors.grey[700],
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            SizedBox(height: 24),
            
            // Danh sách thông báo
            Text(
              'Hôm nay',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white: Colors.grey[850],
              ),
            ),
            SizedBox(height: 12),
            
            // Hiển thị các thông báo
            _buildNotificationItem(
              title: 'Cảnh báo công suất', 
              message: 'Công suất tiêu đạt mức cao!',
              time: '10:30',
              icon: Icons.power,
              color: Colors.red,
            ),
            
            
            SizedBox(height: 24),
            
            Text(
              'Hôm qua',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white: Colors.grey[850],
              ),
            ),
            SizedBox(height: 12),
            
            _buildNotificationItem(
              title: 'Kết nối thiết bị mới', 
              message: 'Đèn đã được kết nối thành công',
              time: '14:20',
              icon: Icons.device_hub,
              color: Colors.green,
            ),
           
          ],
        ),
      ),
    );
  }
  
  Widget _buildNotificationItem({
    required String title,
    required String message,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.18 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                message,
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ),
            onTap: () {},
          ),
        );
      },
    );
  }
}