import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class SavingsTipsDialog extends StatelessWidget {
  final List<String> savingsTips = [
    'Spare jeden Monat einen festen Betrag.',
    'Vergleiche Preise, bevor du etwas kaufst.',
    'Vermeide unnötige Ausgaben.',
    'Setze dir konkrete Sparziele.',
    'Überprüfe regelmäßig deine Ausgaben.',
    'Verkaufe Dinge, die du nicht mehr brauchst.',
    'Nutze Cashback-Programme beim Einkaufen.',
    'Koche selbst anstatt auswärts zu essen.',
    'Nutze kostenlose Angebote und Gutscheine.',
    'Vermeide Impulskäufe und schlafe vor größeren Ausgaben eine Nacht darüber.',
    'Fahre mit dem Fahrrad oder öffentlichen Verkehrsmitteln anstatt mit dem Auto.',
    'Plane deine Mahlzeiten im Voraus, um Lebensmittelverschwendung zu vermeiden.',
    'Vergleiche Versicherungen und Verträge, um Geld zu sparen.',
    'Mache deine eigenen Reinigungsmittel statt teure Produkte zu kaufen.',
    'Nutze kostenlose Online-Ressourcen für Weiterbildung und Hobbys.',
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
                    margin: const EdgeInsets.only(bottom: 5),
                    style: NeumorphicStyle(
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(13.0)),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.grey
                            .shade100, // Setze die Hintergrundfarbe auf rot
                      ),
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
                autoPlayInterval: const Duration(seconds: 4),
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
                color: Colors.grey.shade100,
                depth: 10,
                intensity: 0.9,
                shape: NeumorphicShape.flat,
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(15.0)),
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
