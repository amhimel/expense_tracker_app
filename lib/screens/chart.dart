import 'package:expense_tracker/chart/MonthlyExpenseAreaChart.dart';
import 'package:expense_tracker/screens/monthly_expense_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  final uid = FirebaseAuth.instance.currentUser?.uid.toString();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MonthlyExpenseByCategoryChart(uid: uid!),
          const SizedBox(height: 10),
          MonthlyExpenseAreaChart(uid: uid!),
        ],
      ),
    );
  }
}
