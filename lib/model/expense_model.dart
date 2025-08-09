class ExpenseModel {

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      amount: (map['amount'] is int)
          ? (map['amount'] as int).toDouble()
          : (map['amount'] is double)
          ? map['amount']
          : double.tryParse(map['amount'].toString()) ?? 0.0,
      category: map['category'] ?? '',
    );
  }

  ExpenseModel({
    required this.amount,
    required this.category,
  });
  double amount;
  String category;

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
    };
  }
}
