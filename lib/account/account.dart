import 'dart:convert';

class Account {
  String name;
  double balance;

  Account({
    required this.name,
    required this.balance,
  });

  factory Account.fromJson(String json) {
    final Map<String, dynamic> map = jsonDecode(json);
    return Account(
      name: map['name'],
      balance: map['balance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'balance': balance,
    };
  }
}
