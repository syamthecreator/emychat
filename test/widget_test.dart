import 'package:emychat/features/landing/screens/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:emychat/app/app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'AurenConnectApp renders public SaaS landing entry page with branding and CTAs',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const EmeyChat());
      await tester.pump(const Duration(milliseconds: 100));
      tester.takeException();

      // Verify that the public SaaS landing entry page is displayed initially
      expect(find.byType(LandingScreen), findsOneWidget);
      expect(
        find.text('Automate Conversations.\nGrow Your Business.'),
        findsOneWidget,
      );
      expect(find.text('Get Started Free'), findsOneWidget);
      expect(find.text('View Pricing Plans'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    },
  );
}
