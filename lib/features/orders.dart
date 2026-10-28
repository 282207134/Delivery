import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/catalog.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'checkout.dart';

class OrdersScreen extends StatefulWidget {
  final int initialTab;
  const OrdersScreen({super.key, this.initialTab = 0});
  @override
  State<OrdersScreen> createState() => _OrdersState();
}

class _OrdersState extends State<OrdersScreen> {
  late int tab = widget.initialTab;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context),
        list = s.orders
            .where(
              (o) => tab == 2
                  ? o.status == 'Cancelled' || o.status == 'Delivered'
                  : o.status != 'Cancelled' &&
                        o.status != 'Delivered' &&
                        o.planned == (tab == 1),
            )
            .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text('Orders'),
        ),
      ),
      bottomNavigationBar: const BottomTabs(1),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: InkWell(
                    onTap: () => setState(() => tab = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: tab == i ? DeliColors.green : Colors.white,
                        border: Border.all(color: DeliColors.pale),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ['Current', 'Planned', 'History'][i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: tab == i ? Colors.white : DeliColors.muted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('No orders here yet'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final o = list[i];
                      return InkWell(
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/order',
                          arguments: o,
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0D384A4A),
                                blurRadius: 12,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Heading('Order #${o.id}', size: 21),
                                  ),
                                  Text(
                                    '• ${o.status}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: DeliColors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                o.place,
                                style: const TextStyle(color: DeliColors.muted),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                '♧  ${o.address}',
                                style: const TextStyle(color: DeliColors.muted),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '◷  ${o.time}',
                                style: const TextStyle(color: DeliColors.muted),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class OrderScreen extends StatelessWidget {
  final DeliveryOrder? order;
  final bool planned;
  const OrderScreen({super.key, this.order, this.planned = false});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context),
        o = order ?? s.orders.firstWhere((o) => o.planned == planned);
    final stage = switch (o.status) {
      'Received' => 0,
      'Prepared' => 1,
      'On the way' => 2,
      'Delivered' => 3,
      _ => -1,
    };
    return PageFrame(
      title: 'Order',
      actions: [
        if (o.planned && stage >= 0 && stage < 2)
          TextButton(
            onPressed: () async {
              if (!await confirmAction(
                context,
                'Cancel order?',
                'Your planned demo delivery will be moved to History.',
              )) {
                return;
              }
              s.orders[s.orders.indexOf(o)] = DeliveryOrder(
                id: o.id,
                place: o.place,
                address: o.address,
                status: 'Cancelled',
                time: o.time,
                planned: o.planned,
                details: o.details,
                payment: o.payment,
                subtotal: o.subtotal,
                delivery: o.delivery,
                lines: o.lines,
              );
              s.save();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: photo(
                  o.place == 'Courier delivery' ? 'category_courier' : 'cafe',
                  width: 82,
                  height: 82,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Heading(o.place, size: 22),
                    const SizedBox(height: 8),
                    Text(
                      'Order #${o.id}',
                      style: const TextStyle(color: DeliColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('♧  ${o.address}'),
          const SizedBox(height: 12),
          Text('◷  Delivery ${o.time}'),
          if (!o.planned) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DeliColors.cream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: const AssetImage(
                      'assets/images/courier_avatar.webp',
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Heading('Louis Mark', size: 20),
                        Text(
                          'Your deliveryman',
                          style: TextStyle(
                            color: DeliColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Call courier',
                    onPressed: () =>
                        toast(context, 'Demo courier · +1 205 555 0100'),
                    icon: const Icon(Icons.call, color: DeliColors.green),
                  ),
                ],
              ),
            ),
          ],
          const SectionTitle('Order status'),
          if (o.details.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(o.details),
            ),
          if (stage == -1)
            const Text('Cancelled')
          else
            ...List.generate(
              4,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    Icon(
                      i <= stage
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: i <= stage ? DeliColors.sage : DeliColors.pale,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        [
                          'Order Received',
                          'Order Prepared',
                          'On the way',
                          'Delivered',
                        ][i],
                        style: TextStyle(
                          color: i <= stage ? DeliColors.ink : DeliColors.muted,
                        ),
                      ),
                    ),
                    if (i == 3)
                      const Text(
                        'Estimated',
                        style: TextStyle(fontSize: 11, color: DeliColors.muted),
                      ),
                  ],
                ),
              ),
            ),
          SectionTitle('Items (${o.lines.length})'),
          if (o.lines.isEmpty)
            const Text('Parcel delivery · packing and delivery service'),
          ...o.lines.map((line) => CartItem(line: line, editable: false)),
          const SectionTitle('Summary'),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: DeliColors.pale),
            ),
            child: Column(
              children: [
                PriceRow('Subtotal', money(o.subtotal)),
                PriceRow('Delivery', money(o.delivery)),
                const Divider(),
                PriceRow('Total', money(o.total), total: true),
                const SizedBox(height: 16),
                Tag('${o.payment} · demo'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
