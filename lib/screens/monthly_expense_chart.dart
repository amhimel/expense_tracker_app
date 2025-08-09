import 'package:expense_tracker/chart/chart_bar.dart';
import 'package:expense_tracker/model/expense_bucket.dart';
import 'package:expense_tracker/model/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class MonthlyExpenseByCategoryChart extends StatelessWidget {

  const MonthlyExpenseByCategoryChart({super.key, required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) {
    final String currentMonthYear = DateFormat('MMMMyyyy').format(DateTime.now());

    return StreamBuilder(
      stream: FirebaseDatabase.instance
          .ref()
          .child('Expense')
          .child(uid)
          .child(currentMonthYear)
          .onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Center(child: Text("No expense data found"));
        }

        final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

        List<ExpenseModel> expenses = [];

        data.forEach((date, expensesMap) {
          (expensesMap as Map<dynamic, dynamic>).forEach((key, value) {
            expenses.add(
              ExpenseModel(
                expense: (value['amount'] ?? 0).toDouble(),
                category: value['category'] ?? '',
              ),
            );
          });
        });

        final categories = [
          'Food',
          'Transport',
          'Health',
          'Shopping',
          'Bills',
          'Other',
        ];

        final buckets = categories
            .map((cat) => ExpenseBucket.forCategory(expenses, cat))
            .toList();

        final maxTotalExpense = buckets.fold(
          0.0,
              (prev, bucket) =>
          bucket.totalExpense > prev ? bucket.totalExpense : prev,
        );

        final isDarkMode =
            MediaQuery.of(context).platformBrightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.3),
                Theme.of(context).colorScheme.primary.withOpacity(0.0),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final bucket in buckets)
                      ChartBar(
                        fill: bucket.totalExpense == 0
                            ? 0
                            : bucket.totalExpense / maxTotalExpense,
                      )
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: categories
                    .map(
                      (cat) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 9,
                          color: isDarkMode
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
                    .toList(),
              )
            ],
          ),
        );
      },
    );
  }
}
