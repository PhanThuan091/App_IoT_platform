import 'package:flutter/material.dart';
import '../models/room.dart';

class PowerConsumptionChart extends StatelessWidget {
  final List<Room> rooms;

  const PowerConsumptionChart({
    Key? key,
    required this.rooms,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: _buildSimpleBarChart(context),
    );
  }

  Widget _buildSimpleBarChart(BuildContext context) {
    double maxPower = _getMaxPower();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final double barWidth = (constraints.maxWidth - 40) / rooms.length;
        final double maxHeight = 150.0;
        
        return Column(
          children: [
            SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis labels
                SizedBox(
                  width: 40,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${maxPower.toInt()} W',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${(maxPower / 2).toInt()} W',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '0 W',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Chart content
                Expanded(
                  child: Container(
                    height: maxHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(
                        rooms.length,
                        (index) {
                          final room = rooms[index];
                          final power = room.getTotalPowerConsumption();
                          final double barHeight = maxPower > 0
                              ? (power / maxPower) * maxHeight
                              : 0;
                          
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: barWidth * 0.7,
                                height: barHeight.clamp(5.0, maxHeight),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // X-axis labels
            Row(
              children: [
                SizedBox(width: 40),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      rooms.length,
                      (index) => Container(
                        width: barWidth * 0.7,
                        child: Text(
                          rooms[index].name,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  double _getMaxPower() {
    if (rooms.isEmpty) return 100;
    
    double maxPower = 0;
    for (final room in rooms) {
      final power = room.getTotalPowerConsumption();
      if (power > maxPower) {
        maxPower = power;
      }
    }
    
    return maxPower + (maxPower * 0.1); // Add 10% margin
  }
} 