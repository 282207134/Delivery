import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/catalog.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';

class ProductScreen extends StatefulWidget {
  final Product product;
  final bool expanded;
  const ProductScreen({
    super.key,
    required this.product,
    this.expanded = false,
  });
  @override
  State<ProductScreen> createState() => _ProductState();
}

class _ProductState extends State<ProductScreen> {
  late bool expanded = widget.expanded;
  late double quantity = widget.product.weighed ? 1.5 : 1;
  final Set<int> extras = {};
  final note = TextEditingController();
  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  int get extra => extras.fold(0, (sum, i) => sum + [70, 25, 50][i]);
  @override
  Widget build(BuildContext context) {
    final p = widget.product,
        s = AppScope.of(context),
        dish = products.indexOf(widget.product) < 5;
    return Scaffold(
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: PrimaryButton(
            'Add to cart',
            onPressed: () {
              final additions = extras
                  .map((i) => ['Parmesan', 'Parsley', 'Peanut sauce'][i])
                  .join(', ');
              s.add(
                p,
                quantity: quantity,
                extra: extra,
                note: [
                  additions,
                  note.text.trim(),
                ].where((x) => x.isNotEmpty).join(' · '),
              );
              toast(context, '${p.name} added to cart');
            },
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: dish ? 350 : 410,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  photo(p.image),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: RoundedPhotoEdge(),
                  ),
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + 8,
                    left: 16,
                    child: IconButton.filled(
                      tooltip: 'Back',
                      style: IconButton.styleFrom(
                        backgroundColor: DeliColors.cream,
                        foregroundColor: DeliColors.ink,
                      ),
                      onPressed: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.chevron_left),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + 8,
                    right: 16,
                    child: Row(
                      children: [
                        IconButton.filled(
                          tooltip: 'Favorite',
                          style: IconButton.styleFrom(
                            backgroundColor: DeliColors.coral,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => s.toggleFavorite(p.id),
                          icon: Icon(
                            s.favorites.contains(p.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const CartIcon(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -22, 0),
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Material(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: Heading(p.name, size: 28)),
                        if (p.weighed)
                          Text(
                            '${money(p.cents)}/kg',
                            style: const TextStyle(color: DeliColors.green),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      dish ? '175g • 76cal' : p.detail,
                      style: const TextStyle(color: DeliColors.muted),
                    ),
                    if (dish) ...[
                      const SizedBox(height: 20),
                      Text(p.detail),
                      const SizedBox(height: 14),
                      if (p.diet.isNotEmpty) Tag('♧ ${p.diet}'),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Add on'),
                        trailing: Icon(
                          expanded ? Icons.expand_less : Icons.expand_more,
                        ),
                        onTap: () => setState(() => expanded = !expanded),
                      ),
                      if (expanded)
                        ...List.generate(
                          3,
                          (i) => CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                            title: Text(
                              ['Parmesan', 'Parsley', 'Peanut sauce'][i],
                            ),
                            secondary: Text('+${money([70, 25, 50][i])}'),
                            value: extras.contains(i),
                            onChanged: (_) => setState(() {
                              if (!extras.remove(i)) extras.add(i);
                            }),
                          ),
                        ),
                      LabeledField(
                        'Add details',
                        note,
                        hint: 'Any special requests?',
                      ),
                    ] else
                      const SizedBox(height: 60),
                    const Divider(),
                    if (p.weighed)
                      Center(
                        child: QuantityControl(
                          value: quantity,
                          step: .1,
                          onDelta: (d) => setState(
                            () => quantity =
                                ((quantity + d).clamp(.1, 20) * 10).round() /
                                10,
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Price: ${money(((p.cents + extra) * quantity).round())}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        if (!p.weighed)
                          QuantityControl(
                            value: quantity,
                            onDelta: (d) => setState(
                              () => quantity = (quantity + d).clamp(1, 99),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductRow extends StatelessWidget {
  final Product product;
  final bool details;
  const ProductRow(this.product, {super.key, this.details = true});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => Navigator.pushNamed(context, '/dish', arguments: product),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: photo(
              product.image,
              width: details ? 126 : 80,
              height: details ? 135 : 92,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Heading(product.name, size: 21, color: DeliColors.green),
                const SizedBox(height: 10),
                if (details)
                  Text(
                    product.detail,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                const SizedBox(height: 10),
                Text(
                  '${money(product.cents)}${product.weighed ? '/kg' : ''}',
                  style: const TextStyle(fontSize: 17),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
