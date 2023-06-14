import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:tests/theme/theme_manager.dart';

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

  void checkForLanguage(BuildContext context){
    String language = context.locale.toString();
    print(language);
    switch(language){
      case "en_US": _selectedLanguage = "English"; break;
      case "de_DE": _selectedLanguage = "Deutsch"; break;
    }
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

    @override
    void initState() {
      super.initState();

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
              Navigator.pop(context, "Change");

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
                  // Weitere Style-Eigenschaften hier anpassen
                  // Um den Switch heller zu machen, kannst du die Farben anpassen
                  activeTrackColor: Colors.lightGreen, // Farbe für den aktiven Track
                  inactiveTrackColor: Colors.grey.shade300, // Farbe für den inaktiven Track
                  activeThumbColor: Colors.grey.shade100, // Farbe für den aktiven Thumb
                  inactiveThumbColor: Colors.grey.shade200, // Farbe für den inaktiven Thumb
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
                value: _selectedLanguage,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLanguage = newValue!;
                    switch(_selectedLanguage){
                      case "English": context.setLocale(Locale('en', 'US')); break;
                      case "Deutsch": context.setLocale(Locale('de', 'DE')); break;
                    }

                    // Hier kannst du die Spracheinstellung entsprechend anpassen
                    // z.B. mit einer Funktion, die die App-Sprache ändert.
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
                value: _selectedCurrency,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCurrency = newValue!;
                    // Hier kannst du die Währungseinstellung entsprechend anpassen
                    // z.B. mit einer Funktion, die die Währung ändert.
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
