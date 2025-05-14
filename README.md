# kltn_app

A IoT platform

## Getting Started

This project is a starting point for a Flutter application.
lib/
├── main.dart                     # Điểm vào ứng dụng
├── models/
│   └── room.dart                # Định nghĩa các model (Room, Device, PowerStats, PowerHistory)
├── services/
│   └── room_service.dart        # Quản lý kết nối WebSocket và dữ liệu phòng
├── screens/
│   ├── dashboard_screen.dart    # Màn hình chính
│   ├── room_detail_screen.dart  # Màn hình chi tiết phòng
├── widgets/
│   ├── home_status_card.dart    # Card tổng quan ngôi nhà
│   ├── env_card.dart            # Card nhiệt độ và độ ẩm
│   ├── power_stats_card.dart    # Card thống kê điện năng
│   ├── power_chart_card.dart    # Card biểu đồ tiêu thụ điện
│   ├── device_control_card.dart # Card điều khiển thiết bị