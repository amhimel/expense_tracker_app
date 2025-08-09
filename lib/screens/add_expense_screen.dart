import 'package:flutter/material.dart';
import 'package:expense_tracker/model/expense_model.dart';
import 'package:expense_tracker/services/firebase_services.dart';
import 'package:lottie/lottie.dart';

class AddExpenseWidget extends StatefulWidget {
  const AddExpenseWidget({super.key, this.onExpenseAdded});

  final Function(ExpenseModel)? onExpenseAdded;

  @override
  State<AddExpenseWidget> createState() => _AddExpenseWidgetState();
}

class _AddExpenseWidgetState extends State<AddExpenseWidget> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedCategory = 'Food';

  final List<String> _categories = [
    'Food',
    'Transport',
    'Health',
    'Shopping',
    'Bills',
    'Other',
  ];

  bool _isLoading = false;

  void _saveExpense() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount != null && _selectedCategory.isNotEmpty) {
      setState(() => _isLoading = true);

      final expenseModel = ExpenseModel(
        amount: amount,
        category: _selectedCategory,
      );

      await FirebaseServices().addExpense(_selectedCategory, amount);

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added successfully')),
      );

      widget.onExpenseAdded?.call(expenseModel);

      _amountController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              //const SizedBox(height: 15),
              Lottie.asset("assets/animations/add_expenses.json",height: 200,width: 200),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
                decoration: const InputDecoration(labelText: "Select Category"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Enter Expense Amount",
                ),
              ),
              const SizedBox(height: 15 ),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveExpense,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Add Expense"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
