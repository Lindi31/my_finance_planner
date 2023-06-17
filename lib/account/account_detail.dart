import 'dart:convert';
import 'package:circular_seek_bar/circular_seek_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tests/saving_tips.dart';
import 'package:tests/theme/theme_constants.dart';
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
  String _selectedCurrency = "€";

  Future<String> getCurrencyFromSharedPreferences(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString(key) == "Euro") {
      _selectedCurrency = "€";
    }
    if (prefs.getString(key) == "Dollar") {
      _selectedCurrency = r"$";
    }
    if (prefs.getString(key) == "CHF") {
      _selectedCurrency = "CHF";
    }

    return prefs.getString(key) ?? 'Euro';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    getCurrencyFromSharedPreferences("currency").then((value) {
      setState(() {});
    });
    loadMaxProgress();
    loadTransactions();
  }

  void loadMaxProgress() async {
    double storedMaxProgress = await getMaxProgress();
    setState(() {
      maxProgress = storedMaxProgress;
    });
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

  double submitBudget() {
    if (_budgetController.text.isNotEmpty) {
      double budgetValue = double.parse(_budgetController.text);
      SharedPreferences.getInstance().then((prefs) {
        prefs.setDouble("maxProgress", budgetValue);
      });
      setState(() {
        maxProgress = budgetValue;
      });
      return budgetValue;
    }
    return 0;
  }

  Future<double> getMaxProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double maxProgress = prefs.getDouble('maxProgress') ?? 1000;
    return maxProgress;
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
              icon: Icon(
                Icons.info,
                color: Theme.of(context).unselectedWidgetColor,
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
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black87),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: NeumorphicButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: const NeumorphicBoxShape.circle(),
              depth: 6,
              shadowLightColor: Theme.of(context).brightness == Brightness.light
                  ? const NeumorphicStyle().shadowLightColor
                  : Theme.of(context).shadowColor,
              shadowDarkColor: Theme.of(context).brightness == Brightness.dark
                  ? const NeumorphicStyle().shadowDarkColor
                  : grey400,
              color: Theme.of(context).brightness == Brightness.light
                  ? grey200
                  : grey800,
              intensity: 0.9,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(Icons.arrow_back,
                color: Theme.of(context).unselectedWidgetColor),
          ),
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).cardColor,
            labelStyle: const TextStyle(fontSize: 14),
            unselectedLabelColor: Theme.of(context).unselectedWidgetColor,
            indicator: MaterialIndicator(
              height: 4,
              color: Theme.of(context).unselectedWidgetColor,
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
                        shadowLightColor:
                            Theme.of(context).brightness == Brightness.light
                                ? const NeumorphicStyle().shadowLightColor
                                : Theme.of(context).shadowColor,
                        shadowDarkColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? const NeumorphicStyle().shadowDarkColor
                                : grey400,
                        color: Theme.of(context).brightness == Brightness.light
                            ? grey200
                            : grey800,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(15)),
                        depth: -5,
                        intensity: 0.8,
                      ),
                      child: TextFormField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'enterbudget'.tr(),
                          contentPadding: const EdgeInsets.only(
                              left: 16, bottom: 8, top: 8),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    NeumorphicButton(
                      onPressed: () {
                        setState(() {
                          submitBudget();
                        });
                      },
                      style: NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(12),
                        ),
                        shadowLightColor:
                            Theme.of(context).brightness == Brightness.light
                                ? const NeumorphicStyle().shadowLightColor
                                : Theme.of(context).shadowColor,
                        shadowDarkColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? const NeumorphicStyle().shadowDarkColor
                                : grey400,
                        color: Theme.of(context).brightness == Brightness.light
                            ? grey200
                            : grey800,
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
          shadowLightColor: Theme.of(context).brightness == Brightness.light
              ? const NeumorphicStyle().shadowLightColor
              : Theme.of(context).shadowColor,
          shadowDarkColor: Theme.of(context).brightness == Brightness.dark
              ? const NeumorphicStyle().shadowDarkColor
              : grey400,
          color: Theme.of(context).brightness == Brightness.light
              ? grey200
              : grey800,
          boxShape: const NeumorphicBoxShape.circle(),
        ),
        child: Icon(
          Icons.add,
          size: 60,
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black12
              : Colors.white12,
        ),
      ),
    );
  }

  final ValueNotifier<double> _valueNotifier = ValueNotifier(0);

  double maxProgress = 500;

  Widget monthlybudgetplanner() {
    return CircularSeekBar(
      width: double.infinity,
      height: 300,
      trackColor: Theme.of(context).brightness == Brightness.light
          ? Colors.black12
          : Colors.white12,
      progress: calculateMonthlyExpensesTotal(),
      minProgress: 0,
      maxProgress: calculateMonthlyExpensesTotal() > maxProgress
          ? calculateMonthlyExpensesTotal()
          : maxProgress,
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
      innerThumbColor: Theme.of(context).cardColor,
      outerThumbRadius: 0,
      outerThumbStrokeWidth: 15,
      dashWidth: 1.5,
      dashGap: 1.9,
      animation: true,
      animDurationMillis: 2200,
      curves: Curves.fastOutSlowIn,
      valueNotifier: _valueNotifier,
      child: Center(
        child: ValueListenableBuilder(
          valueListenable: _valueNotifier,
          builder: (_, double value, __) {
            final isMaxProgressReached = value >= maxProgress;
            final textStyle = TextStyle(
              fontSize: 15,
              fontWeight:
                  isMaxProgressReached ? FontWeight.w600 : FontWeight.w300,
            );

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMaxProgressReached)
                  Text(
                    "budgetmax".tr(),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).cardColor),
                  )
                else
                  Text(
                    '${value.round()}$_selectedCurrency',
                    style: TextStyle(
                        fontSize: 24, color: Theme.of(context).cardColor),
                  ),
                const SizedBox(
                  height: 10,
                ),
                isMaxProgressReached
                    ? Text('hint'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).cardColor))
                    : Text('progress'.tr(),
                        style: TextStyle(color: Theme.of(context).cardColor)),
                const SizedBox(height: 10),
                isMaxProgressReached
                    ? Container()
                    : Text(
                        'Budget: $maxProgress',
                        style: textStyle,
                      ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransactionsList(List<Transaction> transactionsList) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
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

  double calculateMonthlyExpensesTotal() {
    double total = 0;
    for (var transaction in expenseTransactions) {
      String month = DateFormat('yyyy-MM').format(transaction.date);
      if (month == DateFormat('yyyy-MM').format(DateTime.now())) {
        total += transaction.amount;
      }
    }
    return total;
  }

  Widget _buildExpenseChart() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Theme.of(context).brightness == Brightness.light
            ? grey400
            : grey800,
        elevation: 6.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: MonthlyExpensesChart(data: expenseData),
        ),
      ),
    );
  }
}
