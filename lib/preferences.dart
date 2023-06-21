import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tests/theme/theme_constants.dart';
import 'package:tests/theme/theme_manager.dart';
import 'main.dart';

ThemeManager _themeManager = ThemeManager();

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'Euro';
  final List<String> _languages = ['English', 'Deutsch'];
  final List<String> _currencies = ['Euro', 'Dollar', 'CHF'];

  void checkForLanguage(BuildContext context) {
    String language = context.locale.toString();
    if (kDebugMode) {
      print(language);
    }
    switch (language) {
      case "en_US":
        _selectedLanguage = "English";
        break;
      case "de_DE":
        _selectedLanguage = "Deutsch";
        break;
    }
  }

  @override
  void dispose() {
    _themeManager.removeListener(themeListener);
    super.dispose();
  }

  Future<void> saveCurrencyToSharedPreferences(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> saveThemeToSharedPreferences(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<String> getCurrencyFromSharedPreferences(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? 'Euro';
  }

  themeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    getCurrencyFromSharedPreferences("currency").then((value) {
      setState(() {
        _selectedCurrency = value;
      });
    });
    _themeManager.addListener(themeListener);
  }

  @override
  Widget build(BuildContext context) {
    checkForLanguage(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        title: Text(
          'settings'.tr(),
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
        shadowColor: Theme.of(context).shadowColor,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: NeumorphicButton(
            onPressed: () {
              Navigator.pop(context); // Zurück zur vorherigen Seite
              Navigator.pushReplacement(
                // Neue Seite öffnen und vorherige Seite ersetzen
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: const NeumorphicBoxShape.circle(),
              depth: 7,
              intensity: 0.9,
              shadowLightColor: Theme.of(context).brightness == Brightness.light
                  ? const NeumorphicStyle().shadowLightColor
                  : Theme.of(context).shadowColor,
              shadowDarkColor: Theme.of(context).brightness == Brightness.dark
                  ? const NeumorphicStyle().shadowDarkColor
                  : grey400,
              color: Theme.of(context).brightness == Brightness.light
                  ? grey200
                  : grey800,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(Icons.arrow_back,
                color: Theme.of(context).unselectedWidgetColor),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Neumorphic(
            style: NeumorphicStyle(
              depth: 7,
              intensity: 1,
              shadowLightColor: Theme.of(context).brightness == Brightness.light
                  ? const NeumorphicStyle().shadowLightColor
                  : grey800,
              shadowDarkColor: Theme.of(context).brightness == Brightness.dark
                  ? const NeumorphicStyle().shadowDarkColor
                  : Theme.of(context).shadowColor,
              color: Theme.of(context).brightness == Brightness.light
                  ? grey200
                  : grey800,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
            ),
            child: ListTile(
                title: Text('darkmode'.tr()),
                trailing:
                    Consumer<ThemeManager>(builder: (context, themeManager, _) {
                  return NeumorphicSwitch(
                    value: themeManager.themeMode == ThemeMode.dark,
                    onChanged: (bool value) {
                      setState(() {
                        themeManager.toggleTheme(value);
                      });
                    },
                    style: NeumorphicSwitchStyle(
                      lightSource: LightSource.topLeft,
                      thumbShape: NeumorphicShape.concave,
                      trackDepth: 5,
                      activeTrackColor: Colors.lightGreen,
                      inactiveTrackColor: Theme.of(context).shadowColor,
                      activeThumbColor:
                          Theme.of(context).brightness == Brightness.light
                              ? grey200
                              : grey800,
                      inactiveThumbColor: Theme.of(context).shadowColor,
                    ),
                  );
                })),
          ),
          const SizedBox(height: 16),
          Neumorphic(
            style: NeumorphicStyle(
              depth: 7,
              intensity: 1,
              shadowLightColor: Theme.of(context).brightness == Brightness.light
                  ? const NeumorphicStyle().shadowLightColor
                  : grey800,
              shadowDarkColor: Theme.of(context).brightness == Brightness.dark
                  ? const NeumorphicStyle().shadowDarkColor
                  : Theme.of(context).shadowColor,
              color: Theme.of(context).brightness == Brightness.light
                  ? grey200
                  : grey800,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
            ),
            child: ListTile(
              title: Text('language'.tr()),
              trailing: DropdownButton<String>(
                icon: const Icon(Icons.expand_more),
                underline: const SizedBox(),
                iconSize: 20,
                borderRadius: BorderRadius.circular(15),
                value: _selectedLanguage,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLanguage = newValue!;
                    switch (_selectedLanguage) {
                      case "English":
                        context.setLocale(const Locale('en', 'US'));
                        break;
                      case "Deutsch":
                        context.setLocale(const Locale('de', 'DE'));
                        break;
                    }
                  });
                },
                items: _languages.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Neumorphic(
            style: NeumorphicStyle(
              depth: 7,
              intensity: 1,
              shadowLightColor: Theme.of(context).brightness == Brightness.light
                  ? const NeumorphicStyle().shadowLightColor
                  : grey800,
              shadowDarkColor: Theme.of(context).brightness == Brightness.dark
                  ? const NeumorphicStyle().shadowDarkColor
                  : Theme.of(context).shadowColor,
              color: Theme.of(context).brightness == Brightness.light
                  ? grey200
                  : grey800,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
            ),
            child: ListTile(
              title: Text('currency'.tr()),
              trailing: DropdownButton<String>(
                borderRadius: BorderRadius.circular(15),
                underline: const SizedBox(),
                iconSize: 20,
                icon: const Icon(Icons.expand_more),
                value: _selectedCurrency,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCurrency = newValue!;
                    saveCurrencyToSharedPreferences(
                        "currency", _selectedCurrency);
                  });
                },
                items:
                    _currencies.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
