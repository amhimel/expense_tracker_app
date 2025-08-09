import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class MonthlyExpenseAreaChart extends StatelessWidget {
  MonthlyExpenseAreaChart({super.key, required this.uid});

  final String uid;

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final String currentMonthYear = DateFormat('MMMMyyyy').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _dbRef.child("Expense/$uid/$currentMonthYear").onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return const Center(child: Text("No expense data"));
        }

        final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

        Map<int, double> dailyTotals = {};
        data.forEach((dateKey, expenseMap) {
          double totalForDay = 0;
          (expenseMap as Map<dynamic, dynamic>).forEach((_, categoryData) {
            if (categoryData is Map && categoryData['amount'] != null) {
              totalForDay +=
                  double.tryParse(categoryData['amount'].toString()) ?? 0;
            }
          });

          int day = int.parse(dateKey.split('-')[0]); // "08" → 8
          dailyTotals[day] = totalForDay;
        });

        final sortedDays = dailyTotals.keys.toList()..sort();

        List<FlSpot> spots = [];
        double runningTotal = 0;
        for (var day in sortedDays) {
          runningTotal += dailyTotals[day]!;
          spots.add(FlSpot(day.toDouble(), runningTotal));
        }

        // Prevent empty data crash
        if (spots.isEmpty) {
          spots.add(const FlSpot(1, 0));
        }

        // Find max Y safely
        final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
        final safeMaxY = dailyTotals.isNotEmpty
            ? dailyTotals.values.reduce((a, b) => a > b ? a : b).toDouble()
            : 0.0;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 250, // Fixed height for chart
            child: LineChart(
              LineChartData(
                minX: 1,
                maxX: sortedDays.isNotEmpty ? sortedDays.last.toDouble() : 30,
                minY: 0,
                maxY: safeMaxY.isFinite ? safeMaxY.toDouble() : 0.0,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50, // more space so text doesn't wrap
                      getTitlesWidget: (value, meta) {
                        String text;
                        if (value >= 1000) {
                          text = '${(value / 1000).toStringAsFixed(1)}K'; // 52.5K
                        } else {
                          text = value.toStringAsFixed(1);
                        }
                        return Text(
                          text,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.left,
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          String text;
                          if (value >= 1000) {
                            text = '${(value / 1000).toStringAsFixed(1)}K'; // 52.5K
                          } else {
                            text = value.toStringAsFixed(0);
                          }
                          return Text(
                            text,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.left,
                          );
                        },
                      )
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) =>
                          Text(value.toInt().toString()),
                    ),
                  ),
                ),
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.3),
                    ),
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
