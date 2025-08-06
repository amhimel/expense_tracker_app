class IncomeModel {

  factory IncomeModel.fromMap(Map<String, dynamic> map) {
    return IncomeModel(
      income: (map['income'] as num).toDouble(),
    );
  }
  IncomeModel({required this.income});

  double income;

  Map<String, dynamic> toMap() {
    return {'income': income};
  }
}
