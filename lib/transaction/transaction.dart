import 'dart:convert';

class Transaction {
  String title;
  double amount;
  bool isExpense;
  DateTime date;

  Transaction({
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.date,
  });

  factory Transaction.fromJson(String json) {
    final Map<String, dynamic> map = jsonDecode(json);
    return Transaction(
      title: map['title'],
      amount: map['amount'],
      isExpense: map['isExpense'],
      date: DateTime.parse(map['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'isExpense': isExpense,
      'date': date.toString(),
    };
  }
}
