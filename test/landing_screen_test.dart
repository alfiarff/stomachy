import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stomachy/screens/landing_screen.dart';

void main() {
  testWidgets('LandingScreen renders properly with all elements', (WidgetTester tester) async {
    // Set typical mobile phone dimensions (390 x 850)
    tester.view.physicalSize = const Size(390 * 3, 850 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: LandingScreen(),
      ),
    );

    // Verify badge text
    expect(find.text('Skrining Risiko GERD dengan AI'), findsOneWidget);

    // Verify main headline texts
    expect(find.text('Sahabat Terbaik'), findsOneWidget);
    expect(find.text('Lambung Sehatmu'), findsOneWidget);

    // Verify statistics cards texts
    expect(find.text('10rb+'), findsOneWidget);
    expect(find.text('Pengguna'), findsOneWidget);
    expect(find.text('4.9'), findsOneWidget);
    expect(find.text('Penilaian'), findsOneWidget);
    expect(find.text('Medis'), findsOneWidget);
  });
}
