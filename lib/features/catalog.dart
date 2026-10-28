import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/catalog.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'home.dart';
import 'product.dart';

class PlacesScreen extends StatefulWidget {
  final String? initialDialog;
  final bool filtered;
  const PlacesScreen({super.key, this.initialDialog, this.filtered = false});
  @override
  State<PlacesScreen> createState() => _PlacesState();
}

class _PlacesState extends State<PlacesScreen> {
  String query = '', sort = 'Nearest me';
  final Set<String> cuisines = {}, diets = {};
  @override
  void initState() {
    super.initState();
    if (widget.filtered) {
      sort = 'Most popular';
      cuisines.add('English');
      diets.add('Gluten free');
    }
    if (widget.initialDialog != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => filter(widget.initialDialog!),
      );
    }
  }

  Future<void> filter(String kind) async {
    var nextSort = sort;
    final picked = {...(kind == 'Cuisine' ? cuisines : diets)};
    final values = kind == 'Sort by'
        ? ['Most popular', 'Nearest me', 'Rating']
        : kind == 'Diet'
        ? ['Vegetarian', 'Vegan', 'Gluten free', 'Lacto free']
        : [
            'All cuisine',
            'Arab',
            'Asian',
            'Chinese',
            'English',
            'French',
            'Georgian',
            'Indian',
            'European',
            'American',
            'Seafood',
          ];
    final applied = await showDialog<bool>(
      context: context,
      barrierColor: DeliColors.green.withValues(alpha: .36),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 50,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Heading(kind)),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
                const Divider(),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: values
                          .map(
                            (value) => InkWell(
                              onTap: () => update(() {
                                if (kind == 'Sort by') {
                                  nextSort = value;
                                } else if (value == 'All cuisine') {
                                  picked.clear();
                                } else if (!picked.remove(value)) {
                                  picked.add(value);
                                }
                              }),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      kind == 'Sort by'
                                          ? (nextSort == value
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_off)
                                          : (picked.contains(value) ||
                                                    value == 'All cuisine' &&
                                                        picked.isEmpty
                                                ? Icons.check_box
                                                : Icons
                                                      .check_box_outline_blank),
                                      color: DeliColors.sage,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(value),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => update(() {
                        picked.clear();
                        nextSort = 'Nearest me';
                      }),
                      child: const Text('Reset'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (applied == true && mounted) {
      setState(() {
        if (kind == 'Sort by') {
          sort = nextSort;
        } else {
          (kind == 'Cuisine' ? cuisines : diets)
            ..clear()
            ..addAll(picked);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = places
        .where(
          (p) =>
              p.name.toLowerCase().contains(query.toLowerCase()) &&
              (cuisines.isEmpty || p.cuisines.any(cuisines.contains)) &&
              (diets.isEmpty || p.diets.any(diets.contains)),
        )
        .toList();
    list.sort(
      (a, b) => sort == 'Nearest me'
          ? a.minutes.compareTo(b.minutes)
          : sort == 'Most popular'
          ? b.reviews.compareTo(a.reviews)
          : b.rating.compareTo(a.rating),
    );
    final active = query.isNotEmpty || cuisines.isNotEmpty || diets.isNotEmpty;
    return PageFrame(
      title: 'Cafes and restaurants',
      actions: const [CartIcon(), SizedBox(width: 10)],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'What are you looking for?',
              fillColor: DeliColors.cream,
            ),
            onChanged: (v) => setState(() => query = v),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              Tag(
                sort == 'Nearest me' ? 'Sort by' : sort,
                onTap: () => filter('Sort by'),
              ),
              Tag(
                cuisines.isEmpty ? 'Cuisine' : cuisines.join(', '),
                selected: cuisines.isNotEmpty,
                onTap: () => filter('Cuisine'),
              ),
              Tag(
                diets.isEmpty ? 'Diet' : diets.join(', '),
                selected: diets.isNotEmpty,
                onTap: () => filter('Diet'),
              ),
            ],
          ),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Text('No places match your search. Try another filter.'),
            ),
          SectionTitle(
            active ? 'Results (${list.length})' : 'Near you',
            onAll: active ? null : () => setState(() => query = ''),
          ),
          SizedBox(
            height: 337,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, i) => PlaceCard(list[i]),
            ),
          ),
          if (!active) ...[
            SectionTitle(
              'Popular',
              onAll: () => setState(() => sort = 'Most popular'),
            ),
            SizedBox(
              height: 337,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (_, i) => PlaceCard(places[i + 2]),
              ),
            ),
            const SectionTitle('Discover New'),
            ...places.skip(4).map((p) => PlaceCard(p, wide: true)),
          ],
        ],
      ),
    );
  }
}

class PlaceCard extends StatelessWidget {
  final Place place;
  final bool wide;
  const PlaceCard(this.place, {super.key, this.wide = false});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StoreScreen(place: place)),
    ),
    child: Container(
      width: wide ? double.infinity : 202,
      margin: EdgeInsets.only(bottom: wide ? 16 : 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DeliColors.cream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: photo(
              place.image,
              width: double.infinity,
              height: wide ? 170 : 180,
            ),
          ),
          const SizedBox(height: 12),
          Heading(place.name, size: 20),
          const SizedBox(height: 4),
          Text(
            place.kind,
            style: const TextStyle(color: DeliColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Text(
            '★ ${place.rating.toStringAsFixed(1)}  (${place.reviews})',
            style: const TextStyle(fontSize: 12),
          ),
          const Divider(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '◷ ${place.minutes}min',
                style: const TextStyle(fontSize: 12),
              ),
              Text(money(place.delivery), style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    ),
  );
}

class StoreScreen extends StatefulWidget {
  final bool supermarket, customOrder, showMenu;
  final Place? place;
  const StoreScreen({
    super.key,
    this.supermarket = false,
    this.customOrder = false,
    this.showMenu = false,
    this.place,
  });
  @override
  State<StoreScreen> createState() => _StoreState();
}

class _StoreState extends State<StoreScreen> {
  final request = TextEditingController();
  final menuKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    if (widget.showMenu) {
      WidgetsBinding.instance.addPostFrameCallback((_) => menu());
    }
  }

  @override
  void dispose() {
    request.dispose();
    super.dispose();
  }

  void menu() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Heading('Menu navigation'),
            const SizedBox(height: 16),
            ...[
              'Special offer',
              'Salads',
              'Pasta',
              'Burgers',
              'Coffee',
              'Cold drinks',
            ].map(
              (x) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(x),
                trailing: Text(
                  {'Salads': '9', 'Coffee': '10', 'Pasta': '7'}[x] ?? '2',
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  if (x == 'Salads' || x == 'Special offer') {
                    Scrollable.ensureVisible(
                      menuKey.currentContext!,
                      duration: const Duration(milliseconds: 300),
                    );
                  } else {
                    Navigator.pushNamed(context, '/products', arguments: x);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context),
        market = widget.supermarket || widget.customOrder;
    final title = widget.customOrder
        ? 'Rave'
        : widget.supermarket
        ? 'Silpo'
        : widget.place?.name ?? 'Mysteries of the Eat';
    return Scaffold(
      bottomNavigationBar: widget.customOrder
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PrimaryButton(
                  'Add to cart',
                  onPressed: () {
                    if (request.text.trim().isEmpty) {
                      toast(context, 'Enter the goods you need');
                      return;
                    }
                    s.add(
                      products.last,
                      note: 'Custom request: ${request.text.trim()}',
                    );
                    Navigator.pushNamed(context, '/cart');
                  },
                ),
              ),
            )
          : s.cart.isEmpty
          ? null
          : const CartBar(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 235,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  photo(
                    widget.customOrder
                        ? 'market'
                        : widget.supermarket
                        ? 'supermarket'
                        : 'cafe',
                  ),
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
                    child: const CartIcon(),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 32,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Tag('★ ${market ? '4.5 (78)' : '5.0 (136)'}'),
                        Tag('◷ ${market ? '10' : '25'}min'),
                        Tag(money(market ? 900 : 700)),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Heading(title),
                  const SizedBox(height: 8),
                  Text(
                    market ? 'Supermarket' : widget.place?.kind ?? 'Restaurant',
                    style: const TextStyle(
                      color: DeliColors.muted,
                      fontSize: 16,
                    ),
                  ),
                  if (!market) ...[
                    const SizedBox(height: 16),
                    const Wrap(
                      spacing: 12,
                      children: [
                        Tag('European'),
                        Tag('American'),
                        Tag('Seafood'),
                      ],
                    ),
                  ],
                  if (widget.customOrder) ...[
                    const SectionTitle('Order'),
                    TextField(
                      controller: request,
                      maxLines: 9,
                      decoration: const InputDecoration(
                        hintText: "Sorry, but we don't have a list of goods from this supermarket. Enter what you need and we will deliver it.",
                      ),
                    ),
                  ] else ...[
                    SectionTitle(
                      'Special offers',
                      onAll: () => Navigator.pushNamed(
                        context,
                        '/products',
                        arguments: 'Special offers',
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 164,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            photo(market ? 'offer_corn' : 'offer_lunch'),
                            Positioned(
                              right: 20,
                              top: 50,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    market ? 'Corn snacks' : 'Happy lunch',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const Heading('-50% off', size: 34),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        '●  ●  ●',
                        style: TextStyle(color: DeliColors.pale),
                      ),
                    ),
                    if (market) ...[
                      const SectionTitle('Categories'),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 8,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 164 / 133,
                            ),
                        itemBuilder: (_, i) => CategoryTile(
                          label: [
                            'Fruits&\nVegetables',
                            'Dairy&\nEggs',
                            'Meat',
                            'Fish',
                            'Bread&\nBake',
                            'Tea&\nCoffee',
                            'Household\nproducts',
                            'Hygiene',
                          ][i],
                          image: [
                            'fruit',
                            'dairy',
                            'meat',
                            'fish',
                            'bread',
                            'coffee',
                            'household',
                            'hygiene',
                          ][i],
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/products',
                            arguments: [
                              'Fruits & Vegetables',
                              'Dairy & Eggs',
                              'Meat',
                              'Fish',
                              'Bread & Bake',
                              'Tea & Coffee',
                              'Household products',
                              'Hygiene',
                            ][i],
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 26),
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: menu,
                          icon: const Icon(Icons.menu_book_outlined),
                          label: const Text('Menu navigation'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: DeliColors.pale,
                            minimumSize: const Size(236, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: const BorderSide(color: DeliColors.pale),
                          ),
                        ),
                      ),
                      SectionTitle('Salads', key: menuKey),
                      ...products.take(3).map((p) => ProductRow(p)),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartBar extends StatelessWidget {
  const CartBar({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 12),
      decoration: const BoxDecoration(
        color: DeliColors.green,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🛒  ${s.count.toStringAsFixed(0)} items',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Total: ${money(s.subtotal)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, '/cart'),
              style: FilledButton.styleFrom(
                backgroundColor: DeliColors.yellow,
                foregroundColor: DeliColors.ink,
                minimumSize: const Size(136, 44),
              ),
              child: const Text('View cart'),
            ),
          ],
        ),
      ),
    );
  }
}

class GoodsScreen extends StatelessWidget {
  final String category;
  const GoodsScreen({super.key, required this.category});
  @override
  Widget build(BuildContext context) {
    final grocery = category.contains('Fruits') || category.contains('Dairy');
    final available = grocery
        ? products.skip(5).toList()
        : products.take(5).toList();
    final unsupported = [
      'Medicines',
      'Flowers',
      'Beauty & Hygiene',
      'Meat',
      'Fish',
      'Bread & Bake',
      'Tea & Coffee',
      'Household products',
      'Hygiene',
    ].contains(category);
    return PageFrame(
      title: category,
      actions: const [CartIcon()],
      child: unsupported
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Heading(category),
                  const SizedBox(height: 16),
                  const Text(
                    'Send your shopping list to a nearby store. Our courier will pick it up for you.',
                  ),
                  const SizedBox(height: 30),
                  PrimaryButton(
                    'Create a delivery request',
                    onPressed: () => Navigator.pushNamed(context, '/courier'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: available.map((p) => ProductRow(p)).toList(),
            ),
    );
  }
}
