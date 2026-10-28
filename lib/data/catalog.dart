class Product {
  final String id, name, image, detail, diet;
  final int cents;
  final bool weighed;
  const Product(
    this.id,
    this.name,
    this.image,
    this.cents,
    this.detail, {
    this.diet = '',
    this.weighed = false,
  });
}

const products = [
  Product(
    'tabule',
    'Raw Tabule with mash',
    'salad',
    900,
    'Mung beans, tomatoes, parsley, cucumbers, mint, peanut sauce',
    diet: 'Vegan',
  ),
  Product(
    'thai',
    'Thai salad',
    'thai_salad',
    700,
    'Funchoza, tofu, tomatoes, sesame seeds, olives, mint',
    diet: 'Gluten free',
  ),
  Product(
    'pasta',
    'Mushroom pasta',
    'pasta',
    1200,
    'Pasta, mushrooms, parmesan and fresh parsley',
  ),
  Product('pizza', 'Pizza', 'pizza', 1000, 'Tomatoes, mozzarella and basil'),
  Product(
    'nachos',
    'Nachos',
    'nachos',
    400,
    'Crispy corn chips and fresh salsa',
    diet: 'Vegan',
  ),
  Product('milk', 'Milk TM “Itambe”', 'milk', 800, '500ml'),
  Product('orange', 'Orange', 'oranges', 145, 'Spain', weighed: true),
  Product('eggs', 'Eggs', 'eggs', 200, '10 fresh eggs'),
  Product(
    'apple',
    'Apples',
    'apples',
    112,
    'Fresh seasonal apples',
    weighed: true,
  ),
  Product(
    'request',
    'Custom shopping list',
    'market',
    0,
    'Goods price will be confirmed by the store',
  ),
];
Product productById(String id) => products.firstWhere((p) => p.id == id);
String money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

class Place {
  int get reviews =>
      const {
        'No Name Restaurant': 126,
        'The Place': 136,
        'Hot Ones': 96,
        'Lettuce Eat': 136,
        'Mysteries of the Eat': 123,
        'Big Chef': 78,
      }[name] ??
      0;
  final String name, image, kind;
  final double rating;
  final int minutes, delivery;
  final List<String> cuisines, diets;
  const Place(
    this.name,
    this.image,
    this.kind,
    this.rating,
    this.minutes,
    this.delivery,
    this.cuisines,
    this.diets,
  );
}

const places = [
  Place(
    'No Name Restaurant',
    'cafe_one',
    'Restaurant',
    5,
    10,
    700,
    ['European', 'English'],
    ['Gluten free', 'Vegetarian'],
  ),
  Place(
    'The Place',
    'cafe_two',
    'Cafe',
    4,
    15,
    300,
    ['French', 'European'],
    ['Vegan', 'Lacto free'],
  ),
  Place(
    'Hot Ones',
    'cafe_three',
    'Grill Bar',
    5,
    20,
    300,
    ['American', 'Asian'],
    ['Gluten free'],
  ),
  Place(
    'Lettuce Eat',
    'cafe_four',
    'Restaurant',
    4.5,
    25,
    700,
    ['English', 'Indian'],
    ['Vegetarian', 'Vegan'],
  ),
  Place(
    'Mysteries of the Eat',
    'cafe',
    'Restaurant',
    4.5,
    15,
    800,
    ['European', 'American', 'Seafood'],
    ['Vegan', 'Gluten free'],
  ),
  Place(
    'Big Chef',
    'cafe_five',
    'Cafe',
    4,
    10,
    200,
    ['Chinese', 'Asian'],
    ['Vegetarian'],
  ),
];
