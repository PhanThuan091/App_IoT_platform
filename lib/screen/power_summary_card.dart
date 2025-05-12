import 'package:flutter/material.dart';

class PowerSummaryCard extends StatelessWidget {
  final double totalPower; // Tổng công suất tiêu thụ (Watt)
  
  PowerSummaryCard({required this.totalPower});
  
  @override
  Widget build(BuildContext context) {
    // Chuyển đổi sang kW nếu > 1000W
    final String powerDisplay = totalPower > 1000 
        ? '${(totalPower / 1000).toStringAsFixed(2)} kW'
        : '${totalPower.toStringAsFixed(1)} W';
    
    // Ước tính chi phí điện (giả sử 3000 VND/kWh)
    final double hourlyRate = 3000; // VND/kWh
    final double dailyCost = totalPower * 24 * hourlyRate / 1000;
    final double monthlyCost = dailyCost * 30;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A6572), Color(0xFF344955)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tiêu thụ điện năng',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.bolt,
                  color: Colors.amber,
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      powerDisplay,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Công suất hiện tại',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEstimateColumn(
                  'Ngày',
                  '${_formatCurrency(dailyCost)} VND',
                  Icons.today,
                ),
                _buildDivider(),
                _buildEstimateColumn(
                  'Tháng',
                  '${_formatCurrency(monthlyCost)} VND',
                  Icons.calendar_month,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEstimateColumn(String title, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white24,
    );
  }
  
  String _formatCurrency(double value) {
    // Định dạng số tiền
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}