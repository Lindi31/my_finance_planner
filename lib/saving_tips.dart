import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:tests/theme/theme_constants.dart';

class SavingsTipsDialog extends StatelessWidget {
  final List<String> savingsTips = [
    'tip1'.tr(),
    'tip2'.tr(),
    'tip3'.tr(),
    'tip4'.tr(),
    'tip5'.tr(),
    'tip6'.tr(),
    'tip7'.tr(),
    'tip8'.tr(),
    'tip9'.tr(),
    'tip10'.tr(),
    'tip11'.tr(),
    'tip12'.tr(),
    'tip13'.tr(),
    'tip14'.tr(),
    'tip15'.tr(),
  ];

  SavingsTipsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CarouselSlider.builder(
              itemCount: savingsTips.length,
              itemBuilder: (BuildContext context, int index, int realIndex) {
                return Neumorphic(
                  margin: const EdgeInsets.fromLTRB(0, 11, 0, 7),
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
                        BorderRadius.circular(13.0)),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Theme.of(context).brightness == Brightness.dark
                            ? grey700
                            : grey200),
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          savingsTips[index],
                          style: const TextStyle(fontSize: 18.0),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                height: 250.0,
                enlargeCenterPage: true,
                viewportFraction: 0.76,
                initialPage: 0,
                enableInfiniteScroll: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 700),
                autoPlayCurve: Curves.fastOutSlowIn,
                pauseAutoPlayOnTouch: true,
              ),
            ),
            const SizedBox(height: 16.0),
            NeumorphicButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: NeumorphicStyle(
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
                depth: 10,
                intensity: 0.9,
                shape: NeumorphicShape.flat,
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(15.0)),
              ),
              child: Text(
                'close'.tr(),
                style: TextStyle(color: Theme.of(context).cardColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
