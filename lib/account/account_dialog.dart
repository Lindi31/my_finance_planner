import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import '../theme/theme_constants.dart';
import 'account.dart';

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
        textAlign: TextAlign.center,
      ),
      titleTextStyle: TextStyle(
        fontSize: 20,
        color: Theme.of(context).brightness==Brightness.dark?Colors.white70:Colors.black87,
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
                shadowLightColor:
                    Theme.of(context).brightness == Brightness.light
                        ? const NeumorphicStyle().shadowLightColor
                        : Theme.of(context).shadowColor,
                shadowDarkColor: Theme.of(context).brightness == Brightness.dark
                    ? const NeumorphicStyle().shadowDarkColor
                    : grey400,
                color: Theme.of(context).brightness == Brightness.light
                    ? grey200
                    : grey800,
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(12),
                ),
              ),
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
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
            const SizedBox(height: 16),
            Neumorphic(
              style: NeumorphicStyle(
                depth: -5,
                intensity: 0.8,
                shadowLightColor:
                    Theme.of(context).brightness == Brightness.light
                        ? const NeumorphicStyle().shadowLightColor
                        : Theme.of(context).shadowColor,
                shadowDarkColor: Theme.of(context).brightness == Brightness.dark
                    ? const NeumorphicStyle().shadowDarkColor
                    : grey400,
                color: Theme.of(context).brightness == Brightness.light
                    ? grey200
                    : grey800,
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(12),
                ),
              ),
              child: TextFormField(
                controller: _balanceController,
                decoration: InputDecoration(
                  labelText: 'balance'.tr(),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(
            'cancel'.tr(),
            style: const TextStyle(
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(
            'add'.tr(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
