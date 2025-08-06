import 'package:flutter/material.dart';

class AddIncomeDialogWidget extends StatefulWidget {
  const AddIncomeDialogWidget({super.key});

  @override
  State<AddIncomeDialogWidget> createState() => _AddIncomeDialogWidgetState();
}

class _AddIncomeDialogWidgetState extends State<AddIncomeDialogWidget> {
  final TextEditingController _incomeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Income"),
      content: TextField(
        controller: _incomeController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: "Enter income amount",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final income = double.tryParse(_incomeController.text.trim());
            if (income != null) {
              Navigator.pop(context, income); // Send income back
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
