import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/catalog.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'checkout.dart';

class FavoritesScreen extends StatefulWidget {
  final bool boxes, filtered;
  const FavoritesScreen({super.key, this.boxes = false, this.filtered = false});
  @override
  State<FavoritesScreen> createState() => _FavoritesState();
}

class _FavoritesState extends State<FavoritesScreen> {
  late bool boxes = widget.boxes, filtered = widget.filtered;
  bool placeOnly = false;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context),
        goods = products
            .where(
              (p) =>
                  s.favorites.contains(p.id) &&
                  (!filtered || products.indexOf(p) < 5) &&
                  (!placeOnly || products.indexOf(p) < 5),
            )
            .toList();
    return PageFrame(
      title: 'Favorites',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Tag(
                  '♥  Goods',
                  selected: !boxes,
                  onTap: () => setState(() => boxes = false),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Tag(
                  '▣  Box',
                  selected: boxes,
                  onTap: () => setState(() => boxes = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            children: [
              Tag(
                filtered ? 'Cafes & Restaurants ×' : 'Categories',
                selected: filtered,
                onTap: () => setState(() => filtered = !filtered),
              ),
              Tag(
                placeOnly ? 'Mysteries of the Eat ×' : 'Place',
                selected: placeOnly,
                onTap: () => setState(() => placeOnly = !placeOnly),
              ),
            ],
          ),
          const SizedBox(height: 28),
          if (boxes) ...[
            if (s.hasWeekBox)
              ...List.generate(
                2,
                (i) => s.removedBoxes.contains(i)
                    ? const SizedBox.shrink()
                    : InkWell(
                        onTap: () =>
                            Navigator.pushNamed(context, '/box', arguments: i),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0D384A4A),
                                blurRadius: 12,
                              ),
                            ],
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Heading(i == 0 ? 'Week box' : 'Week box#2'),
                              const SizedBox(height: 8),
                              Text(
                                i == 0
                                    ? 'Silpo · Supermarket'
                                    : 'Rave · Supermarket',
                                style: const TextStyle(color: DeliColors.muted),
                              ),
                              const SizedBox(height: 20),
                              const PriceRow('Items', '3'),
                              const PriceRow('Subtotal', '\$11.74'),
                              const PriceRow('Delivery', '\$7.00'),
                              const Divider(),
                              const PriceRow('Total', '\$18.74', total: true),
                            ],
                          ),
                        ),
                      ),
              ),
            if (!s.hasWeekBox || s.removedBoxes.length == 2)
              const Text('No saved boxes. Add goods to start a new order.'),
          ] else ...[
            if (goods.isEmpty)
              const Text(
                'No favorites yet. Tap the heart on a product to save it.',
              ),
            if (goods.isNotEmpty)
              const Heading('Mysteries of the Eat', size: 22),
            const SizedBox(height: 16),
            ...goods.map(
              (p) => InkWell(
                onTap: () =>
                    Navigator.pushNamed(context, '/dish', arguments: p),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: photo(p.image, width: 118, height: 100),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Heading(p.name, size: 20, color: DeliColors.green),
                            const SizedBox(height: 12),
                            Text(money(p.cents)),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove favorite',
                        onPressed: () => s.toggleFavorite(p.id),
                        icon: const Icon(
                          Icons.favorite,
                          color: DeliColors.coral,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FavoriteBoxScreen extends StatelessWidget {
  final int index;
  const FavoriteBoxScreen({super.key, this.index = 0});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context),
        lines = [
          CartLine('milk', 1, 800),
          CartLine('orange', 1.2, 145),
          CartLine('eggs', 1, 200),
        ];
    final subtotal = lines.fold(0, (sum, l) => sum + l.total);
    return PageFrame(
      title: index == 0 ? 'Week box' : 'Week box#2',
      actions: [
        TextButton(
          onPressed: () async {
            if (!await confirmAction(
              context,
              'Delete saved box?',
              'Remove this box from your local favorites?',
            )) {
              return;
            }
            s.removedBoxes.add(index);
            s.save();
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Delete'),
        ),
      ],
      bottom: PrimaryButton(
        'Reorder',
        onPressed: () {
          for (final line in lines) {
            s.add(line.product, quantity: line.quantity);
          }
          Navigator.pushNamed(context, '/cart');
        },
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: photo('supermarket', width: 82, height: 82),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Heading(index == 0 ? 'Silpo' : 'Rave'),
                  Text(
                    'Supermarket',
                    style: TextStyle(color: DeliColors.muted),
                  ),
                ],
              ),
            ],
          ),
          const SectionTitle('Items (3)'),
          ...lines.map((l) => CartItem(line: l, editable: false)),
          const SectionTitle('Summary'),
          PriceRow('Subtotal', money(subtotal)),
          const PriceRow('Delivery', '\$7.00'),
          const Divider(),
          PriceRow('Total', money(subtotal + 700), total: true),
        ],
      ),
    );
  }
}
