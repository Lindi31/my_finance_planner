import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {

  runApp(FinancialPlannerApp());
}

class FinancialPlannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Planner',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Account> accounts = [];

  @override
  void initState() {
    super.initState();
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accountList = prefs.getStringList('accounts') ?? [];

    setState(() {
      accounts = accountList.map((accountJson) => Account.fromJson(accountJson)).toList();
    });
  }

  Future<void> saveAccounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> accountJsonList = accounts.map((account) => json.encode(account.toJson())).toList();
    await prefs.setStringList('accounts', accountJsonList);
  }

  void addAccount(Account account) {
    setState(() {
      accounts.add(account);
      saveAccounts();
    });
  }

  void deleteAccount(Account account) {
    setState(() {
      accounts.remove(account);
      saveAccounts();
    });
  }

  void updateAccountBalance(Account account) {
    setState(() {
      saveAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Financial Planner'),
      ),
      body: ListView.builder(
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(accounts[index].name),
            subtitle: Text('Balance: \$${accounts[index].balance.toStringAsFixed(2)}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountDetailPage(
                    account: accounts[index],
                    updateAccountBalance: updateAccountBalance,
                  ),
                ),
              );
            },
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Delete Account'),
                      content: Text('Are you sure you want to delete this account?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            deleteAccount(accounts[index]);
                            Navigator.of(context).pop();
                          },
                          child: Text('Delete'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddAccountDialog(
                addAccount: addAccount,
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

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

class AddAccountDialog extends StatefulWidget {
  final Function addAccount;

  AddAccountDialog({required this.addAccount});

  @override
  _AddAccountDialogState createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<AddAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text.trim();
      double balance = double.parse(_balanceController.text.trim());

      Account account = Account(
        name: name,
        balance: balance,
      );
      widget.addAccount(account);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Account'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _balanceController,
              decoration: InputDecoration(labelText: 'Balance'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a balance';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: _submitForm,
          child: Text('Add'),
        ),
      ],
    );
  }
}


class AccountDetailPage extends StatefulWidget {
  final Account account;
  final Function(Account) updateAccountBalance;

  AccountDetailPage({required this.account, required this.updateAccountBalance});

  @override
  _AccountDetailPageState createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Transaction> transactions = [];
  List<Transaction> incomeTransactions = [];
  List<Transaction> expenseTransactions = [];
  List<ExpenseData> expenseData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void loadTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? transactionsJson = prefs.getString(widget.account.name);
    if (transactionsJson != null) {
      List<dynamic> decodedJson = jsonDecode(transactionsJson);
      setState(() {
        transactions = decodedJson.map((json) => Transaction.fromJson(json)).toList();
        incomeTransactions = transactions.where((transaction) => !transaction.isExpense).toList();
        expenseTransactions = transactions.where((transaction) => transaction.isExpense).toList();
        expenseData = calculateMonthlyExpenses();
      });
    }
  }

  void saveTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> transactionsJsonList = transactions.map((transaction) => json.encode(transaction.toJson())).toList();
    prefs.setString(widget.account.name, jsonEncode(transactionsJsonList));
  }

  void addTransaction(Transaction transaction) {
    setState(() {
      transactions.add(transaction);
      if (transaction.isExpense) {
        widget.account.balance -= transaction.amount;
        expenseTransactions.add(transaction);
      } else {
        widget.account.balance += transaction.amount;
        incomeTransactions.add(transaction);
      }
      saveTransactions();
      widget.updateAccountBalance(widget.account);
      expenseData = calculateMonthlyExpenses();
    });
  }

  void deleteTransaction(Transaction transaction) {
    setState(() {
      transactions.remove(transaction);
      if (transaction.isExpense) {
        widget.account.balance += transaction.amount;
        expenseTransactions.remove(transaction);
      } else {
        widget.account.balance -= transaction.amount;
        incomeTransactions.remove(transaction);
      }
      saveTransactions();
      widget.updateAccountBalance(widget.account);
      expenseData = calculateMonthlyExpenses();
    });
  }

  List<ExpenseData> calculateMonthlyExpenses() {
    Map<String, double> monthlyExpenses = {};
    for (var transaction in expenseTransactions) {
      String month = DateFormat('yyyy-MM').format(transaction.date);
      monthlyExpenses[month] = (monthlyExpenses[month] ?? 0) + transaction.amount;
    }
    List<ExpenseData> expenseData = [];
    monthlyExpenses.forEach((month, amount) {
      expenseData.add(ExpenseData(month: month, amount: amount));
    });
    return expenseData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account.name),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            tabs: [
              Tab(text: 'Einnahmen'),
              Tab(text: 'Ausgaben'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionsList(incomeTransactions),
                Column(
                  children: [
                    Expanded(child: _buildTransactionsList(expenseTransactions)),
                    if (expenseTransactions.isNotEmpty) _buildExpenseChart(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AddTransactionDialog(addTransaction: addTransaction),
        ),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransactionsList(List<Transaction> transactionsList) {
    return ListView.builder(
      itemCount: transactionsList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(transactionsList[index].title),
          subtitle: Text(transactionsList[index].title),
          trailing: Text(
            transactionsList[index].isExpense
                ? '-\$${transactionsList[index].amount.toStringAsFixed(2)}'
                : '+\$${transactionsList[index].amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: transactionsList[index].isExpense ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          onLongPress: () => deleteTransaction(transactionsList[index]),
        );
      },
    );
  }

  Widget _buildExpenseChart() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Card(
        elevation: 4.0,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: MonthlyExpensesChart(data: expenseData),
        ),
      ),
    );
  }
}


class ExpenseData {
  final String month;
  final double amount;

  ExpenseData({required this.month, required this.amount});
}




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

class AddTransactionDialog extends StatefulWidget {
  final Function addTransaction;

  AddTransactionDialog({required this.addTransaction});

  @override
  _AddTransactionDialogState createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isExpense = true;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String title = _titleController.text.trim();
      double amount = double.parse(_amountController.text.trim());

      Transaction transaction = Transaction(
        title: title,
        amount: amount,
        isExpense: _isExpense,
        date: DateTime.now(),
      );
      widget.addTransaction(transaction);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Transaction'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            Row(
              children: [
                Checkbox(
                  value: _isExpense,
                  onChanged: (value) {
                    setState(() {
                      _isExpense = value!;
                    });
                  },
                ),
                Text('Expense'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: _submitForm,
          child: Text('Add'),
        ),
      ],
    );
  }
}


class MonthlyExpensesChart extends StatelessWidget {
  final List<ExpenseData> data;

  MonthlyExpensesChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        series: <ChartSeries>[
          ColumnSeries<ExpenseData, String>(
            dataSource: data,
            xValueMapper: (ExpenseData expense, _) => expense.month,
            yValueMapper: (ExpenseData expense, _) => expense.amount,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}



