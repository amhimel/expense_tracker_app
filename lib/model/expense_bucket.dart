import 'package:expense_tracker/model/expense_model.dart';

class ExpenseBucket {
  factory ExpenseBucket.forCategory(
    List<ExpenseModel> allExpenses,
    String category,
  ) {
    return ExpenseBucket(
      category: category,
      expenses: allExpenses.where((exp) => exp.category == category).toList(),
    );
  }

  ExpenseBucket({required this.category, required this.expenses});

  final String category;
  final List<ExpenseModel> expenses;

  double get totalExpense {
    return expenses.fold(0.0, (sum, item) => sum + item.expense);
  }
}
