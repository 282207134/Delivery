import 'package:flutter/material.dart';
import 'package:deliwell/data/app_state.dart';
import 'package:deliwell/data/catalog.dart';
import 'package:deliwell/features/auth.dart';
import 'package:deliwell/features/home.dart';
import 'package:deliwell/features/catalog.dart';
import 'package:deliwell/features/product.dart';
import 'package:deliwell/features/checkout.dart';
import 'package:deliwell/features/orders.dart';
import 'package:deliwell/features/profile.dart';
import 'package:deliwell/features/favorites.dart';

AppState reviewState() => AppState()
  ..add(products[0], quantity: 2)
  ..add(products[2])
  ..add(products[3]);
final reviewCases = <String, Widget Function()>{
  '01_selected_goods': () => ProductScreen(product: products[5]),
  '02_selected_goods_loose': () => ProductScreen(product: products[6]),
  '03_courier_order_customtime': () => const CourierScreen(custom: true),
  '04_courier_order_today': () => const CourierScreen(),
  '05_courier_order_today_data_picker': () =>
      const CourierScreen(showPicker: true),
  '06_orders_current': () => const OrdersScreen(),
  '07_orders_planned': () => const OrdersScreen(initialTab: 1),
  '08_current_order': () => OrderScreen(order: reviewState().orders[1]),
  '09_planned_order': () => const OrderScreen(planned: true),
  '10_cart': () => const CartScreen(),
  '11_profile': () => const ProfileScreen(),
  '12_user_info': () => const UserInfoScreen(),
  '13_user_info_edit': () => const UserInfoScreen(edit: true),
  '14_credit_card': () => const CardsScreen(),
  '15_add_card_empty': () => const AddCardScreen(),
  '16_add_card': () => const AddCardScreen(prefilled: true),
  '17_favorites_box': () => const FavoritesScreen(boxes: true),
  '18_favoritesgoods_filter_appled': () =>
      const FavoritesScreen(filtered: true),
  '19_favoritesgoods': () => const FavoritesScreen(),
  '20_selected_favorites_box': () => const FavoriteBoxScreen(),
  '21_selected_dish': () => ProductScreen(product: products[1]),
  '22_selected_dish_with_optional_info': () =>
      ProductScreen(product: products[1], expanded: true),
  '23_selected_cafe': () => const StoreScreen(),
  '24_selected_supermarket': () => const StoreScreen(supermarket: true),
  '25_selected_market_without_list_of_goods': () =>
      const StoreScreen(customOrder: true),
  '26_menu': () => const StoreScreen(showMenu: true),
  '27_list_of_cafe': () => const PlacesScreen(),
  '28_list_of_cafe_filter_applied': () => const PlacesScreen(filtered: true),
  '29_home': () => const HomeScreen(),
  '30_onboarding_screen_3': () => const OnboardingScreen(initialPage: 2),
  '31_onboarding_screen_2': () => const OnboardingScreen(initialPage: 1),
  '32_onboarding_screen_1': () => const OnboardingScreen(),
  '33_sign_in_emty': () => const AuthScreen(),
  '34_sign_in': () => const AuthScreen(initialPhone: '+1 (205) 123-22-45'),
  '35_entercode_empty': () => const VerifyScreen(),
  '36_splash_screen': () => const SplashScreen(autoAdvance: false),
  '37_entercode': () => const VerifyScreen(initialCode: '1234'),
  '38_sign_up': () => const AuthScreen(signUp: true),
  '39_filter_sort_by': () => const PlacesScreen(initialDialog: 'Sort by'),
  '40_filter_diet': () => const PlacesScreen(initialDialog: 'Diet'),
  '41_filter_cuisine': () => const PlacesScreen(initialDialog: 'Cuisine'),
  '42_orders_history': () => const OrdersScreen(initialTab: 2),
  '43_address': () => const AddressScreen(),
  '44_promocodes': () => const InfoScreen(kind: 'Promocodes'),
  '45_settings': () => const InfoScreen(kind: 'Settings'),
  '46_help': () => const InfoScreen(kind: 'Help'),
  '47_products': () => const GoodsScreen(category: 'Fruits & Vegetables'),
};
