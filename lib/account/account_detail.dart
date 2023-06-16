import 'dart:convert';
import 'package:circular_seek_bar/circular_seek_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tests/saving_tips.dart';
import 'package:tests/transaction/transaction_dialog.dart';
import 'package:tests/transaction/transaction.dart';
import '../main.dart';
import 'account.dart';
import '../chart/expense_chart.dart';
import '../chart/expense_data.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

class AccountDetailPage extends StatefulWidget {
  final Account account;
  final Function(Account) updateAccountBalance;

  const AccountDetailPage(
      {super.key, required this.account, required this.updateAccountBalance});

  @override
  AccountDetailPageState createState() => AccountDetailPageState();
}

class AccountDetailPageState extends State<AccountDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Transaction> transactions = [];
  List<Transaction> incomeTransactions = [];
  List<Transaction> expenseTransactions = [];
  List<ExpenseData> expenseData = [];
  String _selectedCurrency="€";

  Future<String> getCurrencyFromSharedPreferences(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString(key)=="Euro"){
      _selectedCurrency="€";
    }
    if (prefs.getString(key)=="Dollar"){
      _selectedCurrency=r"$";
    }
    if (prefs.getString(key)=="CHF"){
      _selectedCurrency="CHF";
    }

    return prefs.getString(key) ?? 'Euro';
  }
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    getCurrencyFromSharedPreferences("currency").then((value) {
      setState(() {

      });
    });
    loadTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void loadTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? transactionsJson = prefs.getString(widget.account.name);
    if (transactionsJson != null) {
      List<dynamic> decodedJson = jsonDecode(transactionsJson);
      setState(() {
        transactions =
            decodedJson.map((json) => Transaction.fromJson(json)).toList();
        incomeTransactions = transactions
            .where((transaction) => !transaction.isExpense)
            .toList();
        expenseTransactions =
            transactions.where((transaction) => transaction.isExpense).toList();
        expenseData = calculateMonthlyExpenses();
      });
    }
  }

  void saveTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> transactionsJsonList = transactions
        .map((transaction) => json.encode(transaction.toJson()))
        .toList();
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
      monthlyExpenses[month] =
          (monthlyExpenses[month] ?? 0) + transaction.amount;
    }
    List<ExpenseData> expenseData = [];
    monthlyExpenses.forEach((month, amount) {
      expenseData.add(ExpenseData(month: month, amount: amount));
    });
    return expenseData;
  }

  final _budgetController = TextEditingController();
  double progress = 0;

  double submitbudget() {
    return progress = double.parse(_budgetController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: const Icon(
                Icons.info,
                color: Colors.grey,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => SavingsTipsDialog(),
                );
              },
            ),
          ),
        ],
        toolbarHeight: 80,
        title: Text(
          widget.account.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
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
              Navigator.pop(context); // Zurück zur vorherigen Seite
              Navigator.pushReplacement( // Neue Seite öffnen und vorherige Seite ersetzen
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: const NeumorphicBoxShape.circle(),
              depth: 6,
              intensity: 0.9,
              color: Colors.grey.shade100,
            ),
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.arrow_back, color: Colors.black38),
          ),
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            labelStyle: const TextStyle(fontSize: 14),
            unselectedLabelColor: Colors.black54,
            indicator: MaterialIndicator(
              height: 4,
              color: Colors.black54,
              topLeftRadius: 8,
              topRightRadius: 8,
              horizontalPadding: 45,
              tabPosition: TabPosition.bottom,
            ),
            tabs: [
              Tab(text: 'income'.tr()),
              Tab(text: 'expenditures'.tr()),
              Tab(text: 'budget'.tr())
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionsList(incomeTransactions),
                Column(
                  children: [
                    Expanded(
                        child: _buildTransactionsList(expenseTransactions)),
                    if (expenseTransactions.isNotEmpty) _buildExpenseChart(),
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    monthlybudgetplanner(),
                    Neumorphic(
                      margin: const EdgeInsets.all(14),
                      style: NeumorphicStyle(
                        color: Colors.grey.shade100,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(15)),
                        depth: -5,
                        intensity: 0.8,
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'enteramount'.tr(),
                          contentPadding: const EdgeInsets.only(
                              left: 16, bottom: 8, top: 8),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    NeumorphicButton(
                      onPressed: () {
                        progress = submitbudget();
                      },
                      style: NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(12),
                        ),
                        color: Colors.grey.shade100,
                        depth: 8,
                        intensity: 0.9,
                      ),
                      child: Text('add'.tr()),
                    ),
                  ],
                )
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
          boxShape: const NeumorphicBoxShape.circle(),
        ),
        padding: const EdgeInsets.all(16),
        child: const Icon(
          Icons.add,
          size: 40,
          color: Colors.black12,
        ),
      ),
    );
  }

  final ValueNotifier<double> _valueNotifier = ValueNotifier(0);

  Widget monthlybudgetplanner() {
    return CircularSeekBar(
      width: double.infinity,
      height: 300,
      trackColor: Colors.black12,
      progress: 500,
      minProgress: 0,
      maxProgress: 800,
      barWidth: 17,
      startAngle: 45,
      sweepAngle: 270,
      strokeCap: StrokeCap.butt,
      progressGradientColors: const [
        Colors.lightGreenAccent,
        Colors.lightGreen,
        Colors.green,
        Colors.yellowAccent,
        Colors.yellow,
        Colors.orangeAccent,
        Colors.orange,
        Colors.deepOrangeAccent,
        Colors.deepOrange,
        Colors.redAccent,
        Colors.red
      ],
      innerThumbRadius: 0,
      innerThumbStrokeWidth: 12,
      innerThumbColor: Colors.white,
      outerThumbRadius: 0,
      outerThumbStrokeWidth: 15,
      outerThumbColor: Colors.blueAccent,
      dashWidth: 1.5,
      dashGap: 1.9,
      animation: true,
      animDurationMillis: 2200,
      curves: Curves.fastOutSlowIn,
      valueNotifier: _valueNotifier,
      child: Center(
        child: ValueListenableBuilder(
            valueListenable: _valueNotifier,
            builder: (_, double value, __) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${value.round()}$_selectedCurrency',
                    ),
                    Text(
                      'progress'.tr(),
                    ),
                  ],
                )),
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
                ? '-$_selectedCurrency${transactionsList[index].amount.toStringAsFixed(2)}'
                : '+$_selectedCurrency${transactionsList[index].amount.toStringAsFixed(2)}',
            style: TextStyle(
              color:
                  transactionsList[index].isExpense ? Colors.red : Colors.green,
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
