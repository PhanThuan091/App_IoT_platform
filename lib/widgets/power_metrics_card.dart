import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/room.dart';

class PowerMetricsCard extends StatefulWidget {  
  final double voltage;
  final double current;
  final double power;
  final double energyUsage;
  final List<PowerData> powerHistory;
  final List<PowerData> voltageHistory;
  final List<PowerData> currentHistory;
  final List<PowerData> energyHistory;

  const PowerMetricsCard({
    Key? key,
    required this.voltage,
    required this.current,
    required this.power,
    required this.energyUsage,
    required this.powerHistory,
    this.voltageHistory = const [],
    this.currentHistory = const [],
    this.energyHistory = const [],
  }) : super(key: key);

  @override
  _PowerMetricsCardState createState() => _PowerMetricsCardState();
}

class _PowerMetricsCardState extends State<PowerMetricsCard> {
  DateTime _startDate = DateTime.now().subtract(Duration(days: 1));
  DateTime _endDate = DateTime.now();

   bool _showVoltage = true;
  bool _showCurrent = true;
  bool _showPower = true;
  bool _showEnergy = true;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với grid metrics
            _buildMetricsGrid(isDarkMode),
            SizedBox(height: 24),
            
            // Tiêu đề Visual chart
            Text(
              'Visual chart',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            
            // Date Range Selector
            Row(
              children: [
                Text(
                  'From',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildDateSelector(_startDate, true),
                ),
                SizedBox(width: 10),
                Text(
                  'to',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildDateSelector(_endDate, false),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Chart
            Container(
              height: 300,
              child: _buildMultiLineChart(),
            ),
            
            SizedBox(height: 20),
            
            // Legend
            _buildLegend(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(bool isDarkMode) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricBox(
                label: 'Điện áp',
                value: '${widget.voltage.toStringAsFixed(1)} V',
                icon: Icons.electric_bolt,
                color: Color(0xFFFF8C00),
                isDarkMode: isDarkMode,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildMetricBox(
                label: 'Dòng điện',
                value: '${widget.current.toStringAsFixed(2)} A',
                icon: Icons.waves,
                color: Color(0xFFE91E63),
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMetricBox(
                label: 'Công suất',
                value: '${widget.power.toStringAsFixed(1)} W',
                icon: Icons.power,
                color: Color(0xFF87CEEB),
                isDarkMode: isDarkMode,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildMetricBox(
                label: 'Điện năng',
                value: '${widget.energyUsage.toStringAsFixed(2)} kWh',
                icon: Icons.electric_meter,
                color: Color.fromARGB(255, 213, 32, 195),
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDarkMode,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(DateTime date, bool isStartDate) {
    return GestureDetector(
      onTap: () => _selectDate(context, isStartDate),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[50],
        ),
        child: Row(
          
          children: [
            Expanded(
              child: Text(
                '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ),
            Icon(
              Icons.calendar_today,
              size: 16,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isStartDate ? _startDate : _endDate),
      );
      
      if (time != null) {
        final DateTime newDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );
        
        setState(() {
          if (isStartDate) {
            _startDate = newDateTime;
            // Đảm bảo start date không sau end date
            if (_startDate.isAfter(_endDate)) {
              _endDate = _startDate.add(Duration(hours: 1));
            }
          } else {
            _endDate = newDateTime;
            // Đảm bảo end date không trước start date
            if (_endDate.isBefore(_startDate)) {
              _startDate = _endDate.subtract(Duration(hours: 1));
            }
          }
        });
      }
    }
  }

  List<PowerData> _getFilteredData(List<PowerData> data) {
    return data.where((item) => 
      item.time.isAfter(_startDate) && item.time.isBefore(_endDate)
    ).toList();
  }

  Widget _buildMultiLineChart() {
    final filteredPowerHistory = _getFilteredData(widget.powerHistory);
    final filteredVoltageHistory = _getFilteredData(widget.voltageHistory);
    final filteredCurrentHistory = _getFilteredData(widget.currentHistory);
    final filteredEnergyHistory = _getFilteredData(widget.energyHistory);
    // Kiểm tra xem có dữ liệu nào được hiển thị không
    bool hasVisibleData = (_showVoltage && filteredVoltageHistory.isNotEmpty) ||
                         (_showCurrent && filteredCurrentHistory.isNotEmpty) ||
                         (_showPower && filteredPowerHistory.isNotEmpty) ||
                         (_showEnergy && filteredEnergyHistory.isNotEmpty);

    if (!hasVisibleData) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart, size: 48, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'Không có dữ liệu hiển thị\nVui lòng chọn ít nhất một loại dữ liệu hoặc điều chỉnh khoảng thời gian',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[200],
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey[200],
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                interval: (_endDate.millisecondsSinceEpoch - _startDate.millisecondsSinceEpoch) / 6,
                getTitlesWidget: (value, meta) {
                  final DateTime time = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(0),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          lineBarsData: _buildLineChartBarData(
            filteredVoltageHistory,
            filteredCurrentHistory,
            filteredPowerHistory,
            filteredEnergyHistory,
          ),
          minX: _startDate.millisecondsSinceEpoch.toDouble(),
          maxX: _endDate.millisecondsSinceEpoch.toDouble(),
        ),
      ),
    );
  }

  List<LineChartBarData> _buildLineChartBarData(
    List<PowerData> voltageData,
    List<PowerData> currentData,
    List<PowerData> powerData,
    List<PowerData> energyData,
  ) {
    List<LineChartBarData> lines = [];

    if (_showVoltage && voltageData.isNotEmpty) {
      lines.add(LineChartBarData(
        spots: voltageData.map((data) => 
          FlSpot(data.time.millisecondsSinceEpoch.toDouble(), data.value)
        ).toList(),
        isCurved: true,
        color: Color(0xFFFF8C00),
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      ));
    }

    // Dòng điện (Pink) - chỉ thêm nếu được bật
    if (_showCurrent && currentData.isNotEmpty) {
      lines.add(LineChartBarData(
        spots: currentData.map((data) => 
          FlSpot(data.time.millisecondsSinceEpoch.toDouble(), data.value)
        ).toList(),
        isCurved: true,
        color: Color(0xFFE91E63),
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      ));
    }

    // Công suất (Light Blue) - chỉ thêm nếu được bật
    if (_showPower && powerData.isNotEmpty) {
      lines.add(LineChartBarData(
        spots: powerData.map((data) => 
          FlSpot(data.time.millisecondsSinceEpoch.toDouble(), data.value)
        ).toList(),
        isCurved: true,
        color: Color(0xFF87CEEB),
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      ));
    }

    // Điện năng (Light Pink) - chỉ thêm nếu được bật
    if (_showEnergy && energyData.isNotEmpty) {
      lines.add(LineChartBarData(
        spots: energyData.map((data) => 
          FlSpot(data.time.millisecondsSinceEpoch.toDouble(), data.value)
        ).toList(),
        isCurved: true,
        color: Color.fromARGB(255, 213, 32, 195),
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      ));
    }

    return lines;
  }

  Widget _buildLegend(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(
                'Điện áp', 
                const Color(0xFFFF8C00), 
                _showVoltage,
                () => setState(() => _showVoltage = !_showVoltage),
                isDarkMode: isDarkMode,
              ),
              _buildLegendItem(
                'Dòng điện', 
                const Color(0xFFE91E63), 
                _showCurrent,
                () => setState(() => _showCurrent = !_showCurrent),
                isDarkMode: isDarkMode,
              ),
              _buildLegendItem(
                'Công suất', 
                const Color(0xFF87CEEB), 
                _showPower,
                () => setState(() => _showPower = !_showPower),
                isDarkMode: isDarkMode,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                'Điện năng', 
                Color.fromARGB(255, 213, 32, 195), 
                _showEnergy,
                () => setState(() => _showEnergy = !_showEnergy),
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isVisible, VoidCallback onTap, {required bool isDarkMode}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 200),
        opacity: isVisible ? 1.0 : 0.4,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isVisible ? (isDarkMode ? Colors.grey[800] : Colors.white) : Colors.grey[100],
            border: Border.all(
              color: isVisible ? color.withOpacity(0.3) : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isVisible ? color : Colors.grey[400],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isVisible ? (isDarkMode ? Colors.white : Colors.grey[700]) : Colors.grey[500],
                  fontWeight: isVisible ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}