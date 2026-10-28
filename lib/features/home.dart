import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      backgroundColor: DeliColors.sage,
      bottomNavigationBar: const BottomTabs(0),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 182,
              child: Stack(
                children: [
                  const Positioned.fill(child: Pattern()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () =>
                                    Navigator.pushNamed(context, '/address'),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        s.address,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.expand_more,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const CartIcon(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Heading(
                          'Welcome ${s.name}',
                          size: 40,
                          color: DeliColors.cream,
                        ),
                        const SizedBox(height: 14),
                        InkWell(
                          onTap: () => Navigator.pushNamed(context, '/cafes'),
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: DeliColors.pale,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: .6),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: DeliColors.muted,
                                  size: 22,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'What are you looking for?',
                                  style: TextStyle(
                                    color: DeliColors.muted,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 26, 16, 18),
                  children: [
                    const Heading('Categories'),
                    const SizedBox(height: 20),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 6,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 164 / 133,
                          ),
                      itemBuilder: (context, i) => CategoryTile(
                        label: [
                          'Cafes&\nRestaurants',
                          'Supermarket',
                          'Medicines',
                          'Courier',
                          'Flowers',
                          'Beauty&\nHygiene',
                        ][i],
                        image: [
                          'category_cafe',
                          'category_supermarket',
                          'category_medicine',
                          'category_courier',
                          'category_flowers',
                          'category_beauty',
                        ][i],
                        onTap: () => Navigator.pushNamed(
                          context,
                          [
                            '/cafes',
                            '/supermarket',
                            '/products',
                            '/courier',
                            '/products',
                            '/products',
                          ][i],
                          arguments: [
                            null,
                            null,
                            'Medicines',
                            null,
                            'Flowers',
                            'Beauty & Hygiene',
                          ][i],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final String label, image;
  final VoidCallback onTap;
  const CategoryTile({
    super.key,
    required this.label,
    required this.image,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          photo(image),
          Container(color: Colors.black.withValues(alpha: .22)),
          Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
