import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_state.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';

class SplashScreen extends StatefulWidget {
  final bool autoAdvance;
  const SplashScreen({super.key, this.autoAdvance = true});
  @override
  State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> {
  Timer? timer;
  @override
  void initState() {
    super.initState();
    if (widget.autoAdvance) {
      timer = Timer(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        final s = AppScope.of(context);
        Navigator.pushReplacementNamed(
          context,
          s.signedIn ? (s.onboarded ? '/home' : '/onboarding') : '/sign-in',
        );
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: DeliColors.sage,
    body: Stack(
      children: [
        const Positioned.fill(child: Pattern()),
        Center(child: photo('logo', width: 207)),
      ],
    ),
  );
}

class AuthScreen extends StatefulWidget {
  final bool signUp;
  final String initialPhone;
  const AuthScreen({super.key, this.signUp = false, this.initialPhone = ''});
  @override
  State<AuthScreen> createState() => _AuthState();
}

class _AuthState extends State<AuthScreen> {
  final form = GlobalKey<FormState>();
  late final phone = TextEditingController(text: widget.initialPhone);
  final name = TextEditingController();
  @override
  void dispose() {
    phone.dispose();
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: DeliColors.sage,
    body: LayoutBuilder(
      builder: (context, size) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: size.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              children: [
                Expanded(
                  child: SizedBox(
                    height: size.maxHeight * .58,
                    child: Stack(
                      children: [
                        const Positioned.fill(child: Pattern()),
                        Center(child: photo('logo', width: 165)),
                        Positioned(
                          top: MediaQuery.paddingOf(context).top + 8,
                          right: 16,
                          child: TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(
                              context,
                              widget.signUp ? '/sign-in' : '/sign-up',
                            ),
                            child: Text(
                              widget.signUp ? 'Sign in' : 'Sign up',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Form(
                      key: form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Heading(
                            widget.signUp ? 'Sign up' : 'Sign in',
                            size: 30,
                          ),
                          const SizedBox(height: 24),
                          if (widget.signUp)
                            LabeledField(
                              'Name',
                              name,
                              hint: 'Enter your name',
                              onChanged: (_) => setState(() {}),
                              validator: (v) =>
                                  v!.trim().isEmpty ? 'Enter your name' : null,
                            ),
                          LabeledField(
                            'Contact number',
                            phone,
                            hint: '+1 (205) XXX-XX-XX',
                            keyboard: TextInputType.phone,
                            onChanged: (_) => setState(() {}),
                            validator: (v) =>
                                v!.replaceAll(RegExp(r'\D'), '').length < 7
                                ? 'Enter a valid contact number'
                                : null,
                          ),
                          const SizedBox(height: 28),
                          PrimaryButton(
                            widget.signUp ? 'Sign up' : 'Sign in',
                            onPressed:
                                phone.text.trim().isEmpty ||
                                    (widget.signUp && name.text.trim().isEmpty)
                                ? null
                                : () {
                                    if (!form.currentState!.validate()) return;
                                    final s = AppScope.of(context);
                                    s.phone = phone.text.trim();
                                    if (widget.signUp) {
                                      s.name = name.text.trim();
                                    }
                                    s.save();
                                    Navigator.pushNamed(context, '/verify');
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class VerifyScreen extends StatefulWidget {
  final String initialCode;
  const VerifyScreen({super.key, this.initialCode = ''});
  @override
  State<VerifyScreen> createState() => _VerifyState();
}

class _VerifyState extends State<VerifyScreen> {
  late final code = TextEditingController(text: widget.initialCode);
  String? error;
  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: DeliColors.sage,
    body: Stack(
      children: [
        const Positioned.fill(child: Pattern()),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: Heading('Enter code')),
                  const SizedBox(height: 30),
                  Text(
                    'Please type the verification code sent to ${AppScope.of(context).phone}',
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    key: const ValueKey('verification-code'),
                    controller: code,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 25, letterSpacing: 22),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '• • • •',
                      errorText: error,
                    ),
                    onChanged: (_) => setState(() => error = null),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () =>
                            toast(context, 'Demo verification code: 1234'),
                        child: const Text('Resend code'),
                      ),
                    ],
                  ),
                  const Text(
                    'Demo code: 1234',
                    style: TextStyle(fontSize: 12, color: DeliColors.muted),
                  ),
                  const SizedBox(height: 22),
                  PrimaryButton(
                    'Confirm',
                    onPressed: code.text.length < 4
                        ? null
                        : () {
                            if (code.text != '1234') {
                              setState(() => error = 'Use demo code 1234');
                              return;
                            }
                            final s = AppScope.of(context);
                            s.signedIn = true;
                            s.save();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              s.onboarded ? '/home' : '/onboarding',
                              (r) => false,
                            );
                          },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class OnboardingScreen extends StatefulWidget {
  final int initialPage;
  const OnboardingScreen({super.key, this.initialPage = 0});
  @override
  State<OnboardingScreen> createState() => _OnboardingState();
}

class _OnboardingState extends State<OnboardingScreen> {
  late int page = widget.initialPage;
  void finish() {
    AppScope.of(context)
      ..onboarded = true
      ..save();
    Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: photo('onboarding_${page + 1}', fit: BoxFit.cover),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 26, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Heading(
                  [
                    'Order whatever you want',
                    'Save your time',
                    'Bad weather is not a barrier',
                  ][page],
                ),
                const SizedBox(height: 16),
                Text(
                  [
                    'With our application, you can order products of 6 different categories',
                    'Just reorder your favorite items in the Favorite Boxes',
                    'Our couriers are happy to help you deliver goods in any weather',
                  ][page],
                ),
                const SizedBox(height: 18),
                Row(
                  children: List.generate(
                    3,
                    (i) => Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: i == page ? DeliColors.sage : DeliColors.pale,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: finish, child: const Text('Skip')),
                    FilledButton(
                      onPressed: () {
                        if (page == 2) {
                          finish();
                        } else {
                          setState(() => page++);
                        }
                      },
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
