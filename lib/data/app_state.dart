import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'catalog.dart';

class CartLine {
  final String productId, note;
  final int unitCents;
  double quantity;
  CartLine(this.productId, this.quantity, this.unitCents, {this.note = ''});
  Product get product => productById(productId);
  int get total => (quantity * unitCents).round();
  Map<String, dynamic> toJson() => {
    'id': productId,
    'q': quantity,
    'price': unitCents,
    'note': note,
  };
  factory CartLine.fromJson(Map<String, dynamic> j) => CartLine(
    j['id'],
    (j['q'] as num).toDouble(),
    j['price'],
    note: j['note'] ?? '',
  );
}

class DeliveryOrder {
  final String id, place, address, status, time, details, payment;
  final bool planned;
  final int subtotal, delivery;
  final List<CartLine> lines;
  DeliveryOrder({
    this.details = '',
    this.payment = 'Cash',
    required this.id,
    required this.place,
    required this.address,
    required this.status,
    required this.time,
    this.planned = false,
    required this.subtotal,
    required this.delivery,
    required this.lines,
  });
  int get total => subtotal + delivery;
  Map<String, dynamic> toJson() => {
    'details': details,
    'payment': payment,
    'id': id,
    'place': place,
    'address': address,
    'status': status,
    'time': time,
    'planned': planned,
    'subtotal': subtotal,
    'delivery': delivery,
    'lines': lines.map((e) => e.toJson()).toList(),
  };
  factory DeliveryOrder.fromJson(Map<String, dynamic> j) => DeliveryOrder(
    details: j['details'] ?? '',
    payment: j['payment'] ?? 'Cash',
    id: j['id'],
    place: j['place'],
    address: j['address'],
    status: j['status'],
    time: j['time'],
    planned: j['planned'],
    subtotal: j['subtotal'],
    delivery: j['delivery'],
    lines: (j['lines'] as List).map((e) => CartLine.fromJson(e)).toList(),
  );
}

class AppState extends ChangeNotifier {
  final SharedPreferences? storage;
  String name = 'Sarah',
      email = 'sarah@gmail.com',
      phone = '+1 908 333 44 44',
      address = '765 St Marks Ave';
  bool signedIn = false, onboarded = false, hasWeekBox = true;
  final Set<int> removedBoxes = {};
  final List<CartLine> cart = [];
  final Set<String> favorites = {'tabule', 'nachos', 'pizza', 'apple'};
  final List<Map<String, String>> cards = [
    {'brand': 'Mastercard', 'last4': '0823'},
    {'brand': 'Visa', 'last4': '2388'},
    {'brand': 'Visa', 'last4': '0097'},
  ];
  final List<DeliveryOrder> orders = [];
  AppState({this.storage}) {
    for (var i = 0; i < 5; i++) {
      orders.add(
        DeliveryOrder(
          id: ['004441', '2300113', '2323444', '0133897', '2113342'][i],
          place: i.isEven ? 'Silpo' : 'Rave',
          address: address,
          status: i == 0
              ? 'Prepared'
              : i < 3
              ? 'On the way'
              : 'Received',
          time: i < 3 ? 'Today, 02:40 PM' : 'Tomorrow, 10:20 AM',
          planned: i > 2,
          subtotal: 4000,
          delivery: 700,
          lines: [
            CartLine('tabule', 2, 900),
            CartLine('pasta', 1, 1200),
            CartLine('pizza', 1, 1000),
          ],
        ),
      );
    }
  }
  static Future<AppState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final s = AppState(storage: prefs), raw = prefs.getString('deliwell.v1');
    if (raw == null) return s;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      final cart = (j['cart'] as List)
          .map((e) => CartLine.fromJson(e))
          .toList();
      final orders = (j['orders'] as List)
          .map((e) => DeliveryOrder.fromJson(e))
          .toList();
      s.name = j['name'];
      s.email = j['email'];
      s.phone = j['phone'];
      s.address = j['address'];
      s.signedIn = j['signedIn'];
      s.onboarded = j['onboarded'];
      s.hasWeekBox = j['hasWeekBox'] ?? true;
      s.removedBoxes.addAll((j['removedBoxes'] as List? ?? []).cast<int>());
      s.cart.addAll(cart);
      s.orders
        ..clear()
        ..addAll(orders);
      s.favorites
        ..clear()
        ..addAll((j['favorites'] as List).cast<String>());
      s.cards
        ..clear()
        ..addAll((j['cards'] as List).map((e) => Map<String, String>.from(e)));
    } on Object {
      return AppState(storage: prefs);
    }
    return s;
  }

  int get subtotal => cart.fold(0, (sum, l) => sum + l.total);
  bool get quoteRequired => cart.any((l) => l.productId == 'request');
  String get cartPlace => quoteRequired
      ? 'Rave'
      : cart.every((l) => products.indexOf(l.product) >= 5)
      ? 'Silpo'
      : 'Mysteries of the Eat';
  int get delivery => cart.isEmpty ? 0 : 700;
  double get count => cart.fold(0, (sum, l) => sum + l.quantity);
  Future<void> save() async {
    notifyListeners();
    await storage?.setString(
      'deliwell.v1',
      jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'signedIn': signedIn,
        'onboarded': onboarded,
        'hasWeekBox': hasWeekBox,
        'removedBoxes': removedBoxes.toList(),
        'cart': cart.map((e) => e.toJson()).toList(),
        'favorites': favorites.toList(),
        'cards': cards,
        'orders': orders.map((e) => e.toJson()).toList(),
      }),
    );
  }

  void add(Product p, {double quantity = 1, int extra = 0, String note = ''}) {
    final price = p.cents + extra;
    final found = cart.where(
      (l) => l.productId == p.id && l.note == note && l.unitCents == price,
    );
    if (found.isEmpty) {
      cart.add(CartLine(p.id, quantity, price, note: note));
    } else {
      found.first.quantity += quantity;
    }
    save();
  }

  void changeQuantity(CartLine line, double delta) {
    line.quantity = ((line.quantity + delta) * 10).round() / 10;
    if (line.quantity <= 0) cart.remove(line);
    save();
  }

  void toggleFavorite(String id) {
    if (!favorites.remove(id)) favorites.add(id);
    save();
  }

  DeliveryOrder checkout({
    String payment = 'Cash',
    String time = 'Today, as soon as possible',
    bool planned = false,
    int discount = 0,
  }) {
    if (cart.isEmpty) throw StateError('Your cart is empty');
    final order = DeliveryOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString().substring(6),
      place: cartPlace,
      payment: payment,
      details: quoteRequired
          ? 'Goods price pending store confirmation. Total shown covers delivery and priced items only.'
          : '',
      address: address,
      status: 'Received',
      time: time,
      planned: planned,
      subtotal: (subtotal - discount).clamp(0, subtotal),
      delivery: delivery,
      lines: cart
          .map(
            (l) => CartLine(l.productId, l.quantity, l.unitCents, note: l.note),
          )
          .toList(),
    );
    orders.insert(0, order);
    cart.clear();
    save();
    return order;
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
