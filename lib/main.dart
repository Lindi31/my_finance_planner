import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tests/preferences.dart';
import 'package:tests/theme/theme_constants.dart';
import 'package:tests/theme/theme_manager.dart';
import "package:easy_localization/easy_localization.dart";
import 'account/account_dialog.dart';
import 'account/account.dart';
import 'account/account_detail.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('de', 'DE')],
        path: 'lib/assets/translations',
        // <-- change the path of the translation files
        fallbackLocale: const Locale('en', 'US'),
        child: const FinancialPlannerApp()),
  );
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

  themeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> loadAccounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accountList = prefs.getStringList('accounts') ?? [];

    setState(() {
      accounts = accountList
          .map((accountJson) => Account.fromJson(accountJson))
          .toList();
    });
  }

  Future<void> saveAccounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> accountJsonList =
        accounts.map((account) => json.encode(account.toJson())).toList();
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
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Settings()),
                );
                setState(() {});
              },
              style: NeumorphicStyle(
                shape: NeumorphicShape.convex,
                boxShape: const NeumorphicBoxShape.circle(),
                depth: 6,
                intensity: 0.9,
                color: Colors.grey.shade100,
              ),
              child: const Icon(Icons.settings, color: Colors.black38),
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
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
              ),
              child: ListTile(
                title: Text(accounts[index].name),
                subtitle: Text(
                    '${'balance'.tr()}: \$${accounts[index].balance.toStringAsFixed(2)}'),
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
        child: const Icon(
          Icons.add,
          size: 60,
          color: Colors.black12,
        ),
      ),
    );
  }
}
