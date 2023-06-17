import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
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
      ChangeNotifierProvider(
        create: (context) => ThemeManager(),
        child: EasyLocalization(
            supportedLocales: const [Locale('en', 'US'), Locale('de', 'DE')],
            path: 'lib/assets/translations',
            // <-- change the path of the translation files
            fallbackLocale: const Locale('en', 'US'),
            child: const FinancialPlannerApp()),
      ));
  }

ThemeManager _themeManager = ThemeManager();

class FinancialPlannerApp extends StatelessWidget {
  const FinancialPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: 'title'.tr(),
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: Provider.of<ThemeManager>(context).themeMode,
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
    _themeManager.addListener(themeListener);
    getCurrencyFromSharedPreferences("currency").then((value) {
      setState(() {});
    });
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

  Future<void> saveCurrencyToSharedPreferences(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'title'.tr(),
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme
                  .of(context)
                  .brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black87),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 9, bottom: 0),
            child: NeumorphicButton(
              margin: const EdgeInsets.only(bottom: 16),
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
                depth: 8,
                intensity: 0.9,
                shadowLightColor:
                Theme
                    .of(context)
                    .brightness == Brightness.light
                    ? const NeumorphicStyle().shadowLightColor
                    : Theme
                    .of(context)
                    .shadowColor,
                shadowDarkColor:
                Theme
                    .of(context)
                    .brightness == Brightness.dark
                    ? const NeumorphicStyle().shadowDarkColor
                    : grey400,
                color: Theme
                    .of(context)
                    .brightness == Brightness.light
                    ? grey200
                    : grey800,
              ),
              child: Icon(Icons.settings,
                  color: Theme
                      .of(context)
                      .unselectedWidgetColor),
            ),
          ),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onLongPress: () {
                  AwesomeDialog(
                    btnOkText: "Delete".tr(),
                    btnOkColor: Colors.lightGreen,
                    btnCancelColor: Theme
                        .of(context)
                        .shadowColor,
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
                    depth: 8,
                    intensity: 1,
                    shadowLightColor:
                    Theme
                        .of(context)
                        .brightness == Brightness.light
                        ? const NeumorphicStyle().shadowLightColor
                        : grey800,
                    shadowDarkColor:
                    Theme
                        .of(context)
                        .brightness == Brightness.dark
                        ? const NeumorphicStyle().shadowDarkColor
                        : Theme
                        .of(context)
                        .shadowColor,
                    color: Theme
                        .of(context)
                        .brightness == Brightness.light
                        ? grey200
                        : grey800,
                    boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
                  ),
                  child: ListTile(
                    title: Text(accounts[index].name),
                    subtitle: Text(
                        '${'balance'.tr()}: $_selectedCurrency${accounts[index]
                            .balance.toStringAsFixed(2)}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AccountDetailPage(
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
          )),
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
          shadowLightColor: Theme
              .of(context)
              .brightness == Brightness.light
              ? const NeumorphicStyle().shadowLightColor
              : Theme
              .of(context)
              .shadowColor,
          shadowDarkColor: Theme
              .of(context)
              .brightness == Brightness.dark
              ? const NeumorphicStyle().shadowDarkColor
              : grey400,
          color: Theme
              .of(context)
              .brightness == Brightness.light
              ? grey200
              : grey800,
          boxShape: const NeumorphicBoxShape.circle(),
        ),
        child: Icon(
          Icons.add,
          size: 60,
          color: Theme
              .of(context)
              .brightness == Brightness.light
              ? Colors.black12
              : Colors.white12,
        ),
      ),
    );
  }
}
