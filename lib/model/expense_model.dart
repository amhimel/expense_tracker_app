class ExpenseModel {

  ExpenseModel({required this.expense, required this.category});

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      expense: (map['expense'] ?? 0).toDouble(),
      category: map['category'] ?? '',
    );
  }
  double expense;
  String category;

  Map<String, dynamic> toMap() {
    return {
      'expense': expense,
      'category': category,
    };
  }
}
