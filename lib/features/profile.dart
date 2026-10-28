import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_state.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      backgroundColor: DeliColors.sage,
      bottomNavigationBar: const BottomTabs(2),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 202,
              child: Stack(
                children: [
                  const Positioned.fill(child: Pattern()),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 44,
                          backgroundColor: DeliColors.pale,
                          backgroundImage: AssetImage(
                            'assets/images/avatar.webp',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Heading(s.name, size: 32, color: Colors.white),
                        const SizedBox(height: 6),
                        Text(
                          s.phone,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Material(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...List.generate(
                      7,
                      (i) => Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              [
                                Icons.person_outline,
                                Icons.credit_card,
                                Icons.location_on_outlined,
                                Icons.favorite_border,
                                Icons.local_offer_outlined,
                                Icons.settings_outlined,
                                Icons.help_outline,
                              ][i],
                              color: DeliColors.sage,
                              size: 23,
                            ),
                            title: Text(
                              [
                                'User info',
                                'My cards',
                                'My address',
                                'Favorites',
                                'Promocodes',
                                'Settings',
                                'Help',
                              ][i],
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: DeliColors.muted,
                            ),
                            onTap: () => Navigator.pushNamed(
                              context,
                              [
                                '/user',
                                '/cards',
                                '/address',
                                '/favorites',
                                '/promos',
                                '/settings',
                                '/help',
                              ][i],
                            ),
                          ),
                          const Divider(height: 1),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.logout, color: DeliColors.sage),
                      title: const Text('Log out'),
                      onTap: () {
                        s.signedIn = false;
                        s.save();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/sign-in',
                          (r) => false,
                        );
                      },
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

class UserInfoScreen extends StatefulWidget {
  final bool edit;
  const UserInfoScreen({super.key, this.edit = false});
  @override
  State<UserInfoScreen> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfoScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      email = TextEditingController(),
      phone = TextEditingController();
  bool initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = AppScope.of(context);
    if (!initialized || !widget.edit) {
      name.text = s.name;
      email.text = s.email;
      phone.text = s.phone;
      initialized = true;
    }
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: widget.edit ? 'Edit profile' : 'User info',
    actions: widget.edit
        ? null
        : [
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
              child: const Text('Edit'),
            ),
          ],
    bottom: PrimaryButton(
      widget.edit ? 'Save' : 'Remove account',
      outlined: !widget.edit,
      onPressed: () async {
        final s = AppScope.of(context);
        if (widget.edit) {
          if (!form.currentState!.validate()) return;
          s.name = name.text.trim();
          s.email = email.text.trim();
          s.phone = phone.text.trim();
          s.save();
          Navigator.pop(context);
        } else if (await confirmAction(
          context,
          'Remove local account?',
          'This clears your local profile, cart, cards, favorites and orders.',
        )) {
          await s.storage?.remove('deliwell.v1');
          s.name = 'Sarah';
          s.email = '';
          s.phone = '';
          s.signedIn = false;
          s.onboarded = false;
          s.cart.clear();
          s.cards.clear();
          s.favorites.clear();
          s.orders.clear();
          s.hasWeekBox = false;
          s.save();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/sign-up',
              (r) => false,
            );
          }
        }
      },
    ),
    child: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 112,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: DeliColors.sage,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/images/avatar.webp'),
              ),
            ),
          ),
          LabeledField(
            'Name',
            name,
            readOnly: !widget.edit,
            validator: (v) => v!.trim().isEmpty ? 'Enter your name' : null,
          ),
          LabeledField(
            'Email',
            email,
            readOnly: !widget.edit,
            keyboard: TextInputType.emailAddress,
            validator: (v) =>
                RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v ?? '')
                ? null
                : 'Enter a valid email',
          ),
          LabeledField(
            'Phone number',
            phone,
            readOnly: !widget.edit,
            keyboard: TextInputType.phone,
            validator: (v) => v!.replaceAll(RegExp(r'\D'), '').length < 7
                ? 'Enter a valid phone number'
                : null,
          ),
        ],
      ),
    ),
  );
}

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'My cards',
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...AppScope.of(context).cards.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CardVisual(
              color: [
                DeliColors.sage,
                DeliColors.yellow,
                DeliColors.coral,
              ][entry.key % 3],
              brand: entry.value['brand']!,
              last4: entry.value['last4']!,
            ),
          ),
        ),
        const SizedBox(height: 4),
        PrimaryButton(
          'Add card',
          onPressed: () => Navigator.pushNamed(context, '/add-card'),
        ),
        const SizedBox(height: 20),
        const Text(
          'Demo cards · only the card brand and last four digits are saved.',
          style: TextStyle(fontSize: 12, color: DeliColors.muted),
        ),
      ],
    ),
  );
}

class CardVisual extends StatelessWidget {
  final String brand, last4, holder, expiry;
  final Color color;
  final bool expanded;
  const CardVisual({
    super.key,
    this.brand = 'Mastercard',
    this.last4 = '••••',
    this.holder = 'Name Surname',
    this.expiry = 'mm/yy',
    this.color = DeliColors.sage,
    this.expanded = false,
  });
  @override
  Widget build(BuildContext context) => Container(
    height: expanded ? 164 : 74,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Stack(
      children: [
        const Positioned.fill(child: Pattern()),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (expanded)
              Text(
                brand,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            Row(
              children: [
                if (!expanded)
                  Expanded(
                    child: Text(
                      brand,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                Text(
                  expanded ? '••••  ••••  ••••  $last4' : '•••• $last4',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: expanded ? 21 : 15,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            if (expanded)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Cardholder name\n$holder',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                  Text(
                    'Expiry\n$expiry',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
          ],
        ),
      ],
    ),
  );
}

class AddCardScreen extends StatefulWidget {
  final bool prefilled;
  const AddCardScreen({super.key, this.prefilled = false});
  @override
  State<AddCardScreen> createState() => _AddCardState();
}

class _AddCardState extends State<AddCardScreen> {
  final form = GlobalKey<FormState>();
  late final number = TextEditingController(
    text: widget.prefilled ? '4242 4242 4242 4242' : '',
  );
  late final holder = TextEditingController(
    text: widget.prefilled ? 'Sarah Smith' : '',
  );
  late final expiry = TextEditingController(
    text: widget.prefilled ? '12/30' : '',
  );
  late final cvv = TextEditingController(text: widget.prefilled ? '123' : '');
  @override
  void dispose() {
    number.dispose();
    holder.dispose();
    expiry.dispose();
    cvv.dispose();
    super.dispose();
  }

  bool validNumber(String input) {
    final v = input.replaceAll(' ', '');
    if (!RegExp(r'^\d{13,19}$').hasMatch(v)) return false;
    var sum = 0;
    for (var i = 0; i < v.length; i++) {
      var n = int.parse(v[v.length - 1 - i]);
      if (i.isOdd) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
    }
    return sum % 10 == 0;
  }

  @override
  Widget build(BuildContext context) {
    final digits = number.text.replaceAll(' ', '');
    return PageFrame(
      title: 'Add new card',
      bottom: PrimaryButton(
        'Add card',
        onPressed:
            digits.isEmpty ||
                holder.text.trim().isEmpty ||
                expiry.text.isEmpty ||
                cvv.text.isEmpty
            ? null
            : () {
                if (!form.currentState!.validate()) return;
                AppScope.of(context)
                  ..cards.add({
                    'brand': digits.startsWith('4') ? 'Visa' : 'Mastercard',
                    'last4': digits.substring(digits.length - 4),
                  })
                  ..save();
                Navigator.pop(context);
                toast(context, 'Demo card added');
              },
      ),
      child: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CardVisual(
              expanded: true,
              last4: digits.length >= 4
                  ? digits.substring(digits.length - 4)
                  : '••••',
              holder: holder.text.isEmpty ? 'Name Surname' : holder.text,
              expiry: expiry.text.isEmpty ? 'mm/yy' : expiry.text,
            ),
            const SizedBox(height: 28),
            LabeledField(
              'Card number',
              number,
              hint: '•••• •••• •••• ••••',
              keyboard: TextInputType.number,
              onChanged: (_) => setState(() {}),
              validator: (v) =>
                  validNumber(v!) ? null : 'Enter a valid demo card number',
            ),
            LabeledField(
              'Cardholder name',
              holder,
              hint: 'Name Surname',
              onChanged: (_) => setState(() {}),
              validator: (v) =>
                  v!.trim().isEmpty ? 'Enter cardholder name' : null,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LabeledField(
                    'Expiration date',
                    expiry,
                    hint: 'MM/YY',
                    keyboard: TextInputType.datetime,
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      final match = RegExp(r'^(0[1-9]|1[0-2])/(\d{2})$')
                          .firstMatch(v ?? '');
                      if (match == null) return 'Use MM/YY';
                      final end = DateTime(
                        2000 + int.parse(match[2]!),
                        int.parse(match[1]!) + 1,
                      );
                      return end.isAfter(DateTime.now())
                          ? null
                          : 'Card has expired';
                    },
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: LabeledField(
                    'CVV',
                    cvv,
                    hint: '•••',
                    keyboard: TextInputType.number,
                    obscure: true,
                    onChanged: (_) => setState(() {}),
                    validator: (v) => RegExp(r'^\d{3,4}$').hasMatch(v ?? '')
                        ? null
                        : 'Use 3–4 digits',
                  ),
                ),
              ],
            ),
            const Text(
              'Local demo only. Use test number 4242 4242 4242 4242. Full card details and CVV are never saved.',
              style: TextStyle(fontSize: 12, color: DeliColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});
  @override
  State<AddressScreen> createState() => _AddressState();
}

class _AddressState extends State<AddressScreen> {
  final address = TextEditingController();
  bool initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      address.text = AppScope.of(context).address;
      initialized = true;
    }
  }

  @override
  void dispose() {
    address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'My address',
    bottom: PrimaryButton(
      'Save address',
      onPressed: () {
        if (address.text.trim().isEmpty) {
          toast(context, 'Enter an address');
          return;
        }
        AppScope.of(context)
          ..address = address.text.trim()
          ..save();
        Navigator.pop(context);
      },
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: LabeledField(
        'Delivery address',
        address,
        hint: 'Street, building and apartment',
        maxLines: 3,
      ),
    ),
  );
}

class InfoScreen extends StatelessWidget {
  final String kind;
  const InfoScreen({super.key, required this.kind});
  @override
  Widget build(BuildContext context) => PageFrame(
    title: kind,
    child: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Heading(kind, size: 32),
        const SizedBox(height: 24),
        if (kind == 'Promocodes') ...[
          const Heading('DELI10'),
          const SizedBox(height: 12),
          const Text(
            'Get 10% off items in your cart. Apply DELI10 before checkout.',
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            'Copy code',
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: 'DELI10'));
              toast(context, 'Promocode copied');
            },
          ),
        ] else if (kind == 'Settings') ...[
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Language'),
            subtitle: Text('English · follows the Pixso reference'),
          ),
          const Divider(),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Currency'),
            subtitle: Text('USD'),
          ),
          const Divider(),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('DeliWell'),
            subtitle: Text('Version 1.0.0 · local demo'),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            'View introduction',
            onPressed: () => Navigator.pushNamed(context, '/onboarding'),
          ),
        ] else ...[
          const Heading('How do I place an order?'),
          const SizedBox(height: 12),
          const Text(
            'Choose a restaurant, open a dish and add it to your cart. Review the address and delivery time, then tap Checkout.',
          ),
          const SizedBox(height: 26),
          const Heading('How do I send a parcel?'),
          const SizedBox(height: 12),
          const Text(
            'Open Courier from Home. Enter your parcel details, receiver address and contact number, then choose packing and submit.',
          ),
          const SizedBox(height: 26),
          const Heading('About this demo'),
          const SizedBox(height: 12),
          const Text(
            'Verification code: 1234. Orders, payments and courier tracking use local demonstration data. No real payment or delivery is submitted.',
          ),
        ],
      ],
    ),
  );
}
