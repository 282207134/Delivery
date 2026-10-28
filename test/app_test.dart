import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliwell/data/app_state.dart';
import 'package:deliwell/data/catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('weighted quantities and additions round in integer cents', () {
    final s = AppState()
      ..add(products[6], quantity: 1.5)
      ..add(products[1], quantity: 2, extra: 70, note: 'Parmesan');
    expect(s.subtotal, 1758);
    s.changeQuantity(s.cart.first, -.1);
    expect(s.cart.first.quantity, 1.4);
    expect(s.cart.first.total, 203);
    final o = s.checkout(discount: 100, planned: true);
    expect(o.total, 2343);
    expect(o.planned, true);
    expect(s.cart, isEmpty);
    expect(() => s.checkout(), throwsStateError);
  });
  test(
    'cart merges equal options but keeps different notes and prices separate',
    () {
      final s = AppState()
        ..add(products[1])
        ..add(products[1], quantity: 2)
        ..add(products[1], note: 'No sesame')
        ..add(products[1], extra: 70);
      expect(s.cart.length, 3);
      expect(s.cart.first.quantity, 3);
      expect(s.subtotal, 3570);
    },
  );
  test('removing the last item also removes the delivery charge', () {
    final s = AppState()..add(products[0]);
    s.changeQuantity(s.cart.single, -1);
    expect(s.cart, isEmpty);
    expect(s.subtotal + s.delivery, 0);
  });
  test('checkout snapshots do not change when a later cart is edited', () {
    final s = AppState()..add(products[0], quantity: 2);
    final o = s.checkout(payment: 'Visa *4242');
    s.add(products[0]);
    s.changeQuantity(s.cart.single, 1);
    expect(o.lines.single.quantity, 2);
    expect(o.total, 2500);
    expect(o.payment, 'Visa *4242');
    expect(o.lines.single, isNot(s.cart.single));
  });
  test('a custom request has pending goods prices and an honest delivery-only total', () {
    final s = AppState()..add(products.last, note: 'Bread and coffee');
    expect(s.quoteRequired, true);
    expect(s.subtotal, 0);
    final o = s.checkout();
    expect(o.place, 'Rave');
    expect(o.total, 700);
    expect(o.details, contains('pending'));
    expect(o.lines.single.note, 'Bread and coffee');
  });
  test(
    'profile, favorites, orders and card masks survive a local reload',
    () async {
      SharedPreferences.setMockInitialValues({});
      final s = await AppState.load();
      s.name = 'Alex';
      s.removedBoxes.add(0);
      s.address = '123 New Street';
      s.toggleFavorite('thai');
      s.add(products[0]);
      final order = s.checkout(payment: 'Visa *4242');
      await s.save();
      final restored = await AppState.load();
      expect(restored.name, 'Alex');
      expect(restored.removedBoxes, {0});
      expect(restored.address, '123 New Street');
      expect(restored.favorites, contains('thai'));
      expect(restored.orders.first.id, order.id);
      expect(restored.orders.first.payment, 'Visa *4242');
      expect(
        restored.cards.every(
          (c) => c.keys.toSet().difference({'brand', 'last4'}).isEmpty,
        ),
        true,
      );
    },
  );
  test('a damaged local snapshot falls back to the demo catalog', () async {
    SharedPreferences.setMockInitialValues({
      'deliwell.v1': '{"cart":invalid json}',
    });
    final restored = await AppState.load();
    expect(restored.name, 'Sarah');
    expect(restored.cart, isEmpty);
    expect(restored.orders.length, 5);
  });
}
