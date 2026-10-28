import 'package:flutter/material.dart';

import 'data/app_state.dart';
import 'data/catalog.dart';
import 'features/auth.dart';
import 'features/home.dart';
import 'features/catalog.dart';
import 'features/product.dart';
import 'features/checkout.dart';
import 'features/orders.dart';
import 'features/profile.dart';
import 'features/favorites.dart';
import 'ui/theme.dart';

class DeliwellApp extends StatelessWidget {
  final AppState state;
  final Widget? home;
  const DeliwellApp({super.key, required this.state, this.home});
  @override
  Widget build(BuildContext context) => AppScope(
    state: state,
    child: MaterialApp(
      title: 'DeliWell',
      debugShowCheckedModeBanner: false,
      theme: deliTheme(),
      home: home ?? const SplashScreen(),
      onGenerateRoute: (settings) {
        final page = switch (settings.name) {
          '/home' => const HomeScreen(),
          '/sign-in' => const AuthScreen(),
          '/sign-up' => const AuthScreen(signUp: true),
          '/verify' => const VerifyScreen(),
          '/onboarding' => const OnboardingScreen(),
          '/cafes' => const PlacesScreen(),
          '/cafe' => const StoreScreen(),
          '/supermarket' => const StoreScreen(supermarket: true),
          '/market' => const StoreScreen(customOrder: true),
          '/dish' => ProductScreen(
            product: settings.arguments as Product? ?? products[1],
          ),
          '/goods' => ProductScreen(
            product: settings.arguments as Product? ?? products[5],
          ),
          '/products' => GoodsScreen(
            category: settings.arguments as String? ?? 'Fruits & Vegetables',
          ),
          '/courier' => const CourierScreen(),
          '/cart' => const CartScreen(),
          '/orders' => const OrdersScreen(),
          '/order' => OrderScreen(order: settings.arguments as DeliveryOrder?),
          '/profile' => const ProfileScreen(),
          '/user' => const UserInfoScreen(),
          '/edit-profile' => const UserInfoScreen(edit: true),
          '/cards' => const CardsScreen(),
          '/add-card' => const AddCardScreen(),
          '/favorites' => const FavoritesScreen(),
          '/box' => FavoriteBoxScreen(index: settings.arguments as int? ?? 0),
          '/address' => const AddressScreen(),
          '/promos' => const InfoScreen(kind: 'Promocodes'),
          '/settings' => const InfoScreen(kind: 'Settings'),
          '/help' => const InfoScreen(kind: 'Help'),
          _ => const HomeScreen(),
        };
        return MaterialPageRoute(builder: (_) => page, settings: settings);
      },
    ),
  );
}
