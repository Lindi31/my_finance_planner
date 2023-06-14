import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tests/preferences.dart';
import 'package:tests/theme/theme_constants.dart';
import 'package:tests/theme/theme_manager.dart';
import "package:easy_localization/easy_localization.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(EasyLocalization(
      supportedLocales: [Locale('en', 'US'), Locale('de', 'DE')],
      path: 'lib/assets/translations', // <-- change the path of the translation files
      fallbackLocale: Locale('en', 'US'),
      child: const FinancialPlannerApp()
  ),);
}
ThemeManager _themeManager = ThemeManager();

class FinancialPlannerApp extends StatelessWidget {
  const FinancialPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: 'title'.tr(),
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeManager.themeMode,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Account> accounts = [];

  @override
  void initState() {
    super.initState();
    _themeManager.addListener(themeListener);
    loadAccounts();

  }
  @override
  void dispose() {
    _themeManager.removeListener(themeListener);
    super.dispose();
  }
  themeListener(){
    if(mounted){
      setState(() {

      });
    }
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
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'title'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 3, bottom: 7),
            child: NeumorphicButton(
              onPressed: () async {

                String value = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Settings()),
                );
                setState(() {

                });
              },
              style: NeumorphicStyle(
                shape: NeumorphicShape.convex,
                boxShape: NeumorphicBoxShape.circle(),
                depth: 6,
                intensity: 0.9,
                color: Colors.grey.shade100,
              ),
              child: Icon(Icons.settings, color: Colors.black38),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onLongPress: () {
              AwesomeDialog(
                btnOkText: "Delete".tr(),
              btnOkColor: Colors.lightGreen,
              btnCancelColor: Colors.grey,
              context: context,
              animType: AnimType.bottomSlide,
              dialogType: DialogType.info,
              title: 'deleteaccount'.tr(),
              headerAnimationLoop: false,
              desc: 'sure'.tr(),
              btnCancelOnPress: () {},
              btnOkOnPress: () {
                deleteAccount(accounts[index]);
              },
            ).show();

            },
            child: Neumorphic(
              margin: const EdgeInsets.all(16),
              style: NeumorphicStyle(
                depth: 7,
                intensity: 1,
                shadowDarkColor: Colors.grey.shade300,
                color: Colors.grey.shade100,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
              ),
              child: ListTile(
                title: Text(accounts[index].name),
                subtitle: Text('${'balance'.tr()}: \$${accounts[index].balance.toStringAsFixed(2)}'),
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
              ),
            ),
          );
        },
      ),
      floatingActionButton: NeumorphicButton(
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
        style: NeumorphicStyle(
          depth: 8,
          intensity: 1,
          shadowDarkColor: Colors.grey.shade400,
          color: Colors.grey.shade100,
          boxShape: const NeumorphicBoxShape.circle(),
        ),
        child: const Icon(Icons.add,size:60,color: Colors.black12,),
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

  const AddAccountDialog({super.key, required this.addAccount});

  @override
  AddAccountDialogState createState() => AddAccountDialogState();
}

class AddAccountDialogState extends State<AddAccountDialog> {
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Text(
        'addaccount'.tr(),
      ),
      titleTextStyle: TextStyle(
        color: Colors.black54,
        fontSize: 20,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Neumorphic(
              style: NeumorphicStyle(
                depth: -5,
                intensity: 0.8,
                color: Colors.grey.shade100,
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(12),
                ),
              ),
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.fromLTRB(12, 16, 12, 16),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'entername'.tr();
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 16),
            Neumorphic(
              style: NeumorphicStyle(
                depth: -5,
                intensity: 0.8,
                color: Colors.grey.shade100,
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(12),
                ),
              ),
              child: TextFormField(
                controller: _balanceController,
                decoration: InputDecoration(
                  labelText: 'balance'.tr(),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.fromLTRB(12, 16, 12, 16),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'enterbalance'.tr();
                  }
                  if (double.tryParse(value) == null) {
                    return 'entervalidnumber'.tr();
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        NeumorphicButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: NeumorphicStyle(
            shape: NeumorphicShape.concave,
            intensity: 0.9,
            depth: 9,
            boxShape: NeumorphicBoxShape.roundRect(
              BorderRadius.circular(12),
            ),
            color: Colors.grey.shade100,
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(
            'cancel'.tr(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        NeumorphicButton(
          onPressed: _submitForm,
          style: NeumorphicStyle(
            shape: NeumorphicShape.concave,
            intensity: 0.8,
            depth: 9,
            boxShape: NeumorphicBoxShape.roundRect(
              BorderRadius.circular(12),
            ),
            color: Colors.grey.shade100,
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(
            'add'.tr(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );

  }
}


class AccountDetailPage extends StatefulWidget {
  final Account account;
  final Function(Account) updateAccountBalance;

  const AccountDetailPage({super.key, required this.account, required this.updateAccountBalance});

  @override
  AccountDetailPageState createState() => AccountDetailPageState();
}

class AccountDetailPageState extends State<AccountDetailPage> with SingleTickerProviderStateMixin {
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        title: Text(
          widget.account.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        shadowColor: Colors.grey.shade300,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: NeumorphicButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.circle(),
              depth: 6,
              intensity: 0.9,
              color: Colors.grey.shade100,
            ),
            padding: EdgeInsets.all(10),
            child: Icon(Icons.arrow_back, color: Colors.black38),
          ),
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            tabs: [
              Tab(text: 'income'.tr()),
              Tab(text: 'expenditures'.tr()),
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
      floatingActionButton: NeumorphicButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AddTransactionDialog(addTransaction: addTransaction),
        ),
        style: NeumorphicStyle(
          depth: 8,
          intensity: 1,
          shadowDarkColor: Colors.grey.shade400,
          color: Colors.grey.shade100,
          boxShape: NeumorphicBoxShape.circle(),
        ),
        padding: EdgeInsets.all(16),
        child: Icon(
          Icons.add,
          size: 40,
          color: Colors.black12,
        ),
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
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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

  const AddTransactionDialog({super.key, required this.addTransaction});

  @override
  AddTransactionDialogState createState() => AddTransactionDialogState();
}

class AddTransactionDialogState extends State<AddTransactionDialog> {
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Text(
        'addtrans'.tr(),
        style: TextStyle(
          fontSize: 20,
          color: Colors.black54,
        ),
      ),
      content: Form(
    key: _formKey, // Hier wird das _formKey dem Form-Widget zugewiesen
    child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Neumorphic(
            style: NeumorphicStyle(
              depth: -5,
              intensity: 0.8,
              color: Colors.grey.shade100,
              boxShape: NeumorphicBoxShape.roundRect(
                BorderRadius.circular(12),
              ),
            ),
            child: TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'entertitle'.tr();
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 16),
          Neumorphic(
            style: NeumorphicStyle(
              depth: -5,
              intensity: 0.8,
              color: Colors.grey.shade100,
              boxShape: NeumorphicBoxShape.roundRect(
                BorderRadius.circular(12),
              ),
            ),
            child: TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'amount'.tr(),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'enteramount'.tr();
                }
                if (double.tryParse(value) == null) {
                  return 'entervalidnumber'.tr();
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              NeumorphicCheckbox(
                style: NeumorphicCheckboxStyle(selectedColor: Colors.lightGreen, disabledColor: Colors.grey.shade200,selectedDepth: -10, unselectedDepth: 8),
                value: _isExpense,
                onChanged: (value) {
                  setState(() {
                    _isExpense = value!;
                  });
                },
              ),
              SizedBox(width: 8),
              Text('expense'.tr(), style: TextStyle(color: Colors.black87),),
            ],
          ),
        ],
      )),
      actions: [
        NeumorphicButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: NeumorphicStyle(
            shape: NeumorphicShape.concave,
            intensity: 0.8,
            depth: 9,
            boxShape: NeumorphicBoxShape.roundRect(
              BorderRadius.circular(12),
            ),
            color: Colors.grey.shade100,
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(
            'cancel'.tr(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        NeumorphicButton(
          onPressed: _submitForm,
          style: NeumorphicStyle(
            shape: NeumorphicShape.concave,
            intensity: 0.8,
            depth: 9,
            boxShape: NeumorphicBoxShape.roundRect(
              BorderRadius.circular(12),
            ),
            color: Colors.grey.shade100,
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(
            'add'.tr(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );

  }
}


class MonthlyExpensesChart extends StatelessWidget {
  final List<ExpenseData> data;

  const MonthlyExpensesChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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



