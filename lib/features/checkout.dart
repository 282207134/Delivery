import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/catalog.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';

Future<DateTime?> deliveryPicker(BuildContext context) async {
  final now = DateTime.now();
  var date = now.add(const Duration(hours: 2));
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Heading('Select delivery time'),
            const SizedBox(height: 18),
            SizedBox(
              height: 200,
              child: CupertinoDatePicker(
                minimumDate: now,
                maximumDate: now.add(const Duration(days: 30)),
                initialDateTime: date,
                onDateTimeChanged: (v) => date = v,
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton('Confirm', onPressed: () => Navigator.pop(ctx, date)),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

String dateLabel(DateTime date) =>
    '${date.month}/${date.day}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartState();
}

class _CartState extends State<CartScreen> {
  int payment = 0, discount = 0;
  DateTime? time;
  Future<void> promo() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Heading('Add promocode'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Try DELI10'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    if (!mounted || result == null) return;
    if (result.trim().toUpperCase() == 'DELI10') {
      setState(() => discount = 10);
      toast(context, '10% off items applied');
    } else {
      toast(context, 'Invalid code. Try DELI10');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context),
        reduction = (s.subtotal * discount / 100).round();
    return PageFrame(
      title: 'Cart',
      bottom: s.cart.isEmpty
          ? null
          : PrimaryButton(
              s.quoteRequired ? 'Submit request' : 'Checkout',
              onPressed: () {
                if (s.address.trim().isEmpty) {
                  toast(context, 'Add a delivery address');
                  return;
                }
                final order = s.checkout(
                  time: time == null
                      ? 'Today, as soon as possible'
                      : dateLabel(time!),
                  planned: time != null,
                  payment: payment == 0 || payment > s.cards.length
                      ? 'Cash'
                      : '${s.cards[payment - 1]['brand']} *${s.cards[payment - 1]['last4']}',
                  discount: reduction,
                );
                Navigator.pushReplacementNamed(
                  context,
                  '/order',
                  arguments: order,
                );
                toast(context, 'Order received. This is a local demo order.');
              },
            ),
      child: s.cart.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shopping_basket_outlined,
                      size: 64,
                      color: DeliColors.pale,
                    ),
                    const SizedBox(height: 24),
                    const Heading('Your cart is empty'),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      'Explore restaurants',
                      onPressed: () => Navigator.pushNamed(context, '/cafes'),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: DeliColors.sage,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your order from',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Heading(s.cartPlace, color: Colors.white, size: 30),
                    ],
                  ),
                ),
                if (s.quoteRequired)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Goods price pending store confirmation. The total below includes delivery and priced items only.',
                    ),
                  ),
                Row(
                  children: [
                    const Expanded(child: SectionTitle('Delivery address')),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/address'),
                      child: const Text('Change'),
                    ),
                  ],
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: DeliColors.sage,
                  ),
                  title: const Text('Current location:'),
                  subtitle: Text(s.address),
                ),
                const SectionTitle('Delivery time'),
                Wrap(
                  spacing: 12,
                  children: [
                    Tag(
                      'As soon as possible',
                      selected: time == null,
                      onTap: () => setState(() => time = null),
                    ),
                    Tag(
                      time == null ? 'Custom' : dateLabel(time!),
                      selected: time != null,
                      onTap: () async {
                        final picked = await deliveryPicker(context);
                        if (picked != null && mounted) {
                          setState(() => time = picked);
                        }
                      },
                    ),
                  ],
                ),
                SectionTitle('Items (${s.cart.length})'),
                ...s.cart.toList().map((line) => CartItem(line: line)),
                const SectionTitle('Summary'),
                PriceRow('Subtotal', money(s.subtotal)),
                PriceRow('Delivery', money(s.delivery)),
                if (discount > 0)
                  PriceRow('DELI10 · 10% off', '-${money(reduction)}'),
                const Divider(),
                PriceRow(
                  'Total',
                  money(s.subtotal + s.delivery - reduction),
                  total: true,
                ),
                TextButton.icon(
                  onPressed: promo,
                  icon: const Icon(Icons.local_offer_outlined, size: 20),
                  label: Text(
                    discount > 0 ? 'Change promocode' : 'Add promocode',
                  ),
                ),
                const SectionTitle('Payment method'),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Tag(
                        'Cash',
                        selected: payment == 0,
                        onTap: () => setState(() => payment = 0),
                      ),
                      ...s.cards.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Tag(
                            'Card *${entry.value['last4']}',
                            selected: payment == entry.key + 1,
                            onTap: () =>
                                setState(() => payment = entry.key + 1),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Add card',
                        onPressed: () =>
                            Navigator.pushNamed(context, '/add-card'),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class CartItem extends StatelessWidget {
  final CartLine line;
  final bool editable;
  const CartItem({super.key, required this.line, this.editable = true});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: photo(line.product.image, width: 80, height: 92),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Heading(line.product.name, size: 20),
              const SizedBox(height: 5),
              Text(money(line.total)),
              if (line.note.isNotEmpty)
                Text(
                  line.note,
                  style: const TextStyle(fontSize: 11, color: DeliColors.muted),
                ),
              if (editable)
                QuantityControl(
                  value: line.quantity,
                  step: line.product.weighed ? .1 : 1,
                  onDelta: (d) => AppScope.of(context).changeQuantity(line, d),
                )
              else
                Text(
                  '× ${line.quantity.toStringAsFixed(line.product.weighed ? 1 : 0)}',
                  style: const TextStyle(color: DeliColors.muted),
                ),
            ],
          ),
        ),
        if (editable)
          IconButton(
            tooltip: 'Remove item',
            onPressed: () =>
                AppScope.of(context).changeQuantity(line, -line.quantity),
            icon: const Icon(Icons.close, size: 18, color: DeliColors.coral),
          ),
      ],
    ),
  );
}

class CourierScreen extends StatefulWidget {
  final bool custom, showPicker;
  const CourierScreen({
    super.key,
    this.custom = false,
    this.showPicker = false,
  });
  @override
  State<CourierScreen> createState() => _CourierState();
}

class _CourierState extends State<CourierScreen> {
  final form = GlobalKey<FormState>();
  final description = TextEditingController(),
      receiver = TextEditingController(text: '697 Main Ave'),
      contact = TextEditingController();
  bool packing = true;
  int box = 0, day = 0;
  String payment = 'Cash';
  DateTime? date;
  @override
  void initState() {
    super.initState();
    if (widget.custom) {
      day = 2;
      date = DateTime.now().add(const Duration(days: 2));
    }
    if (widget.showPicker) {
      WidgetsBinding.instance.addPostFrameCallback((_) => pickTime());
    }
  }

  @override
  void dispose() {
    description.dispose();
    receiver.dispose();
    contact.dispose();
    super.dispose();
  }

  Future<void> pickTime() async {
    final picked = await deliveryPicker(context);
    if (picked != null && mounted) {
      setState(() {
        date = picked;
        day = 2;
      });
    }
  }

  int get price => 800 + (packing ? [200, 300, 500][box] : 0);
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return PageFrame(
      title: 'Send something',
      bottom: PrimaryButton(
        'Make order',
        onPressed: () {
          if (!form.currentState!.validate()) return;
          final order = DeliveryOrder(
            id: DateTime.now().millisecondsSinceEpoch.toString().substring(6),
            place: 'Courier delivery',
            payment: payment,
            details:
                '${description.text.trim()}\nPickup: ${s.address}\nContact: ${contact.text.trim()}',
            address: receiver.text.trim(),
            status: 'Received',
            time: date != null
                ? dateLabel(date!)
                : day == 0
                ? 'Today, 11 AM'
                : 'Tomorrow, 11 AM',
            planned: day > 0,
            subtotal: packing ? [200, 300, 500][box] : 0,
            delivery: 800,
            lines: [],
          );
          s.orders.insert(0, order);
          s.save();
          Navigator.pushReplacementNamed(context, '/order', arguments: order);
          toast(context, 'Delivery request received');
        },
      ),
      child: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            LabeledField(
              'Description',
              description,
              hint: 'What do you want to send?',
              maxLines: 3,
              validator: (v) =>
                  v!.trim().isEmpty ? 'Describe your parcel' : null,
            ),
            const SectionTitle('Pickup Location'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DeliColors.cream,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('◉  Pickup location:'),
                  const SizedBox(height: 8),
                  Text('Current: ${s.address}'),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/address'),
                    child: const Text('Change pickup address'),
                  ),
                  const Divider(),
                  LabeledField(
                    'Receiver location',
                    receiver,
                    validator: (v) =>
                        v!.trim().isEmpty ? 'Enter a receiver address' : null,
                  ),
                ],
              ),
            ),
            const SectionTitle('Delivery time'),
            Text(
              date == null
                  ? (day == 0 ? 'Today, 11 AM' : 'Tomorrow, 11 AM')
                  : dateLabel(date!),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              children: List.generate(
                3,
                (i) => Tag(
                  ['Today', 'Tomorrow', 'Custom'][i],
                  selected: day == i,
                  onTap: () {
                    if (i == 2) {
                      pickTime();
                    } else {
                      setState(() {
                        day = i;
                        date = null;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            LabeledField(
              'Contact number',
              contact,
              hint: '+1 (205) XXX-XX-XX',
              keyboard: TextInputType.phone,
              validator: (v) => v!.replaceAll(RegExp(r'\D'), '').length < 7
                  ? 'Enter a valid phone number'
                  : null,
            ),
            const Heading('Payment method', size: 22),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: payment,
              decoration: const InputDecoration(),
              items: [
                'Cash',
                ...s.cards.map((c) => '${c['brand']} *${c['last4']}'),
              ].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
              onChanged: (v) => payment = v!,
            ),
            const SectionTitle('Do you need packing?'),
            Wrap(
              spacing: 12,
              children: [
                Tag(
                  'Yes',
                  selected: packing,
                  onTap: () => setState(() => packing = true),
                ),
                Tag(
                  'No',
                  selected: !packing,
                  onTap: () => setState(() => packing = false),
                ),
              ],
            ),
            if (packing) ...[
              const SectionTitle('Choose box'),
              ...List.generate(
                3,
                (i) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.inventory_2_outlined,
                    color: i == box ? DeliColors.green : DeliColors.pale,
                    size: 36,
                  ),
                  title: Text(['Small', 'Medium', 'Large'][i]),
                  subtitle: Text(['27×4×31cm', '31×9×33cm', '54×54×54cm'][i]),
                  trailing: Text(money([200, 300, 500][i])),
                  selected: box == i,
                  selectedTileColor: DeliColors.cream,
                  onTap: () => setState(() => box = i),
                ),
              ),
            ],
            const Divider(),
            const PriceRow('Delivery price', '\$8.00'),
            if (packing) PriceRow('Packing', money([200, 300, 500][box])),
            PriceRow('Total', money(price), total: true),
          ],
        ),
      ),
    );
  }
}
