import 'package:flutter/material.dart';

import '../data/app_state.dart';
import 'theme.dart';

Widget photo(
  String name, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) => Image.asset(
  'assets/images/$name.webp',
  width: width,
  height: height,
  fit: fit,
);

class Heading extends StatelessWidget {
  final String text;
  final double size;
  final Color? color;
  const Heading(this.text, {super.key, this.size = 26, this.color});
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontFamily: 'Yrsa',
      fontSize: size,
      height: 1.1,
      fontWeight: FontWeight.w500,
      color: color ?? DeliColors.ink,
    ),
  );
}

class RoundedPhotoEdge extends StatelessWidget {
  const RoundedPhotoEdge({super.key});
  @override
  Widget build(BuildContext context) => Container(
    height: 24,
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
  );
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool yellow, outlined;
  const PrimaryButton(
    this.label, {
    super.key,
    this.onPressed,
    this.yellow = false,
    this.outlined = false,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: outlined
        ? OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(48, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(label),
          )
        : FilledButton(
            onPressed: onPressed,
            style: yellow
                ? FilledButton.styleFrom(
                    backgroundColor: DeliColors.yellow,
                    foregroundColor: DeliColors.ink,
                  )
                : null,
            child: Text(label),
          ),
  );
}

class PageFrame extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? bottom;
  final List<Widget>? actions;
  const PageFrame({
    super.key,
    required this.title,
    required this.child,
    this.bottom,
    this.actions,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title),
      leading: IconButton(
        tooltip: 'Back',
        icon: const Icon(Icons.chevron_left),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
      ),
      actions: actions,
    ),
    body: SafeArea(top: false, child: child),
    bottomNavigationBar: bottom == null
        ? null
        : SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: bottom,
            ),
          ),
  );
}

class BottomTabs extends StatelessWidget {
  final int selected;
  const BottomTabs(this.selected, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      boxShadow: [
        BoxShadow(
          color: Color(0x0C384A4A),
          blurRadius: 12,
          offset: Offset(0, -3),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 64,
        child: Row(
          children: List.generate(
            3,
            (i) => Expanded(
              child: InkWell(
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  ['/home', '/orders', '/profile'][i],
                  (r) => false,
                ),
                child: SizedBox(
                  height: 64,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        [
                          Icons.home_rounded,
                          Icons.receipt_long,
                          Icons.person,
                        ][i],
                        color: selected == i
                            ? DeliColors.green
                            : DeliColors.pale,
                        size: 23,
                      ),
                      if (selected == i) ...[
                        const SizedBox(width: 8),
                        Text(
                          ['Home', 'Orders', 'Profile'][i],
                          style: const TextStyle(
                            color: DeliColors.green,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class CartIcon extends StatelessWidget {
  const CartIcon({super.key});
  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      IconButton.filled(
        tooltip: 'Cart',
        style: IconButton.styleFrom(
          backgroundColor: DeliColors.yellow,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        onPressed: () => Navigator.pushNamed(context, '/cart'),
        icon: const Icon(Icons.shopping_cart_outlined, size: 22),
      ),
      if (AppScope.of(context).cart.isNotEmpty)
        Positioned(
          right: 3,
          top: 2,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: DeliColors.coral,
              shape: BoxShape.circle,
            ),
          ),
        ),
    ],
  );
}

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onAll;
  const SectionTitle(this.title, {super.key, this.onAll});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 18),
    child: Row(
      children: [
        Expanded(child: Heading(title)),
        if (onAll != null)
          TextButton(
            onPressed: onAll,
            child: const Text(
              'Show all',
              style: TextStyle(color: DeliColors.muted),
            ),
          ),
      ],
    ),
  );
}

class Tag extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback? onTap;
  const Tag(this.text, {super.key, this.selected = false, this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? DeliColors.green : DeliColors.cream,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.white : DeliColors.ink,
          fontSize: 12,
        ),
      ),
    ),
  );
}

class LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboard;
  final bool readOnly, obscure;
  final int maxLines;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  const LabeledField(
    this.label,
    this.controller, {
    super.key,
    this.hint,
    this.keyboard,
    this.readOnly = false,
    this.obscure = false,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Heading(label, size: 20),
        const SizedBox(height: 10),
        TextFormField(
          key: ValueKey(label),
          controller: controller,
          readOnly: readOnly,
          obscureText: obscure,
          maxLines: maxLines,
          keyboardType: keyboard,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    ),
  );
}

class QuantityControl extends StatelessWidget {
  final double value, step;
  final ValueChanged<double> onDelta;
  const QuantityControl({
    super.key,
    required this.value,
    required this.onDelta,
    this.step = 1,
  });
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        tooltip: 'Decrease quantity',
        onPressed: () => onDelta(-step),
        icon: const Icon(Icons.remove, size: 18),
        style: IconButton.styleFrom(
          backgroundColor: DeliColors.yellow.withValues(alpha: .45),
          minimumSize: const Size(36, 36),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          value == value.roundToDouble()
              ? value.toInt().toString()
              : value.toStringAsFixed(1),
        ),
      ),
      IconButton(
        tooltip: 'Increase quantity',
        onPressed: () => onDelta(step),
        icon: const Icon(Icons.add, size: 18),
        style: IconButton.styleFrom(
          backgroundColor: DeliColors.yellow.withValues(alpha: .45),
          minimumSize: const Size(36, 36),
        ),
      ),
    ],
  );
}

class PriceRow extends StatelessWidget {
  final String label, value;
  final bool total;
  const PriceRow(this.label, this.value, {super.key, this.total = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: total ? DeliColors.green : DeliColors.muted,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: total ? FontWeight.w800 : FontWeight.w500,
            color: total ? DeliColors.green : DeliColors.ink,
            fontSize: total ? 18 : 14,
          ),
        ),
      ],
    ),
  );
}

class Pattern extends StatelessWidget {
  const Pattern({super.key});
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Opacity(
      opacity: .32,
      child: Stack(
        children: [
          Positioned(
            left: -10,
            top: 35,
            child: photo('pattern_bag', width: 95),
          ),
          Positioned(
            right: 24,
            top: 62,
            child: photo('pattern_medicine', width: 58),
          ),
          Positioned(
            right: -24,
            bottom: 20,
            child: photo('pattern_box', width: 148),
          ),
          Positioned(
            left: 12,
            bottom: 55,
            child: photo('pattern_pizza', width: 84),
          ),
        ],
      ),
    ),
  );
}

void toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
}

Future<bool> confirmAction(
  BuildContext context,
  String title,
  String text,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Heading(title),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ??
    false;
