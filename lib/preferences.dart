import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Neumorphic(
            style: NeumorphicStyle(
              depth: 7,
              intensity: 1,
              shadowDarkColor: Colors.grey.shade300,
              color: Colors.grey.shade100,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
            ),
            child: ListTile(
              title: Text('darkmode'.tr()),
              trailing: NeumorphicSwitch(
                value: _themeManager.themeMode == ThemeMode.dark,
                onChanged: (bool value) {
                  setState(() {
                    _themeManager.toggleTheme(value);
                  });
                },
                style: NeumorphicSwitchStyle(
                  lightSource: LightSource.topLeft,
                  thumbShape: NeumorphicShape.concave,
                  trackDepth: 5,
                  activeTrackColor: Colors.lightGreen,
                  inactiveTrackColor: Colors.grey.shade300,
                  activeThumbColor: Colors.grey.shade100,
                  inactiveThumbColor: Colors.grey.shade200,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Neumorphic(
            style: NeumorphicStyle(
              depth: 7,
              intensity: 1,
              shadowDarkColor: Colors.grey.shade300,
              color: Colors.grey.shade100,
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
              shadowDarkColor: Colors.grey.shade300,
              color: Colors.grey.shade100,
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
                    saveCurrencyToSharedPreferences("currency", _selectedCurrency);
                  });
                },
                items: _currencies.map<DropdownMenuItem<String>>((String value) {
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
