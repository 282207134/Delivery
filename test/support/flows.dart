import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deliwell/app.dart';
import 'package:deliwell/data/app_state.dart';
import 'package:deliwell/features/auth.dart';
import 'package:deliwell/features/home.dart';
import 'package:deliwell/features/profile.dart';
import 'package:deliwell/features/favorites.dart';

Future<void> shoppingFlow(WidgetTester tester) async {
  final s = AppState();
  await tester.pumpWidget(
    DeliwellApp(key: UniqueKey(), state: s, home: const HomeScreen()),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Cafes&\nRestaurants'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('No Name Restaurant').first);
  await tester.pumpAndSettle();
  await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Raw Tabule with mash').first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Add to cart'));
  await tester.pumpAndSettle();
  expect(s.cart.length, 1);
  expect(s.subtotal, 900);
  await tester.tap(find.byTooltip('Cart'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Checkout'));
  await tester.pumpAndSettle();
  expect(s.cart, isEmpty);
  expect(s.orders.first.total, 1600);
  expect(find.text('Order Received'), findsOneWidget);
  expect(tester.takeException(), isNull);
}

Future<void> signInFlow(WidgetTester tester) async {
  final s = AppState();
  await tester.pumpWidget(
    DeliwellApp(
      key: UniqueKey(),
      state: s,
      home: const AuthScreen(initialPhone: '+1 205 123 4567'),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const ValueKey('verification-code')),
    '1235',
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Confirm'));
  await tester.pumpAndSettle();
  expect(s.signedIn, false);
  expect(find.text('Use demo code 1234'), findsOneWidget);
  await tester.enterText(
    find.byKey(const ValueKey('verification-code')),
    '1234',
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Confirm'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Skip'));
  await tester.pumpAndSettle();
  expect(s.signedIn && s.onboarded, true);
  expect(find.text('Welcome Sarah'), findsOneWidget);
  expect(tester.takeException(), isNull);
}

Future<void> cardFlow(WidgetTester tester) async {
  final s = AppState();
  await tester.pumpWidget(
    DeliwellApp(key: UniqueKey(), state: s, home: const CardsScreen()),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Add card'));
  await tester.pumpAndSettle();
  for (final field in {
    'Card number': '4242 4242 4242 4242',
    'Cardholder name': 'Sarah Smith',
    'Expiration date': '12/30',
    'CVV': '123',
  }.entries) {
    final finder = find.byKey(ValueKey(field.key));
    await tester.ensureVisible(finder);
    await tester.enterText(finder, field.value);
    await tester.pumpAndSettle();
  }
  // Close the IME so the same tap works on a real Android device.
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, 'Add card'));
  await tester.pumpAndSettle();
  expect(s.cards.length, 4);
  expect(s.cards.last, {'brand': 'Visa', 'last4': '4242'});
  expect(tester.takeException(), isNull);
}

Future<void> savedBoxFlow(WidgetTester tester) async {
  final s = AppState();
  await tester.pumpWidget(
    DeliwellApp(
      key: UniqueKey(),
      state: s,
      home: const FavoritesScreen(boxes: true),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Week box'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Delete'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Confirm'));
  await tester.pumpAndSettle();
  expect(s.removedBoxes, {0});
  expect(find.text('Week box'), findsNothing);
  expect(find.text('Week box#2'), findsOneWidget);
  expect(tester.takeException(), isNull);
}
