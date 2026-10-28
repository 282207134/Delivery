import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:deliwell/app.dart';

import '../test/support/review_cases.dart';
import '../test/support/flows.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('capture every implemented Pixso state on Android', (
    tester,
  ) async {
    await binding.convertFlutterSurfaceToImage();
    for (final entry in reviewCases.entries) {
      await tester.pumpWidget(
        DeliwellApp(
          key: UniqueKey(),
          state: reviewState(),
          home: entry.value(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull, reason: entry.key);
      await binding.takeScreenshot(entry.key);
      if ([
        '03',
        '04',
        '08',
        '09',
        '10',
        '22',
        '23',
        '24',
        '27',
      ].contains(entry.key.substring(0, 2))) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -520));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '${entry.key} scrolled');
        await binding.takeScreenshot('${entry.key}_scrolled');
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    }
  });
  testWidgets('device: home to checkout', shoppingFlow);
  testWidgets('device: verification and onboarding', signInFlow);
  testWidgets('device: add a demo card', cardFlow);
  testWidgets('device: delete one saved box independently', savedBoxFlow);
}
