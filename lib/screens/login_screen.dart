import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../services/auth_service.dart';
import '../widgets/common.dart';
import '../widgets/dots.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();

  int _mode = 0; // 0 = password, 1 = OTP
  bool _otpSent = false;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() job) async {
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      await job();
      // On success the AuthGate swaps this screen for Home automatically.
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  bool _needEmail() {
    if (_email.text.trim().isEmpty) {
      showError(context, 'Please enter your email.');
      return false;
    }
    return true;
  }

  Future<void> _signInPassword() async {
    if (!_needEmail()) return;
    if (_password.text.isEmpty) {
      showError(context, 'Please enter your password.');
      return;
    }
    await _run(() => AuthService.instance
        .signInWithPassword(_email.text.trim(), _password.text));
  }

  Future<void> _sendOtp() async {
    if (!_needEmail()) return;
    await _run(() async {
      await AuthService.instance.sendOtp(_email.text.trim());
      if (!mounted) return;
      setState(() => _otpSent = true);
      showOk(context, 'Code sent. Check your email.');
    });
  }

  Future<void> _verifyOtp() async {
    if (_code.text.trim().length < 6) {
      showError(context, 'Enter the code from your email.');
      return;
    }
    await _run(() =>
        AuthService.instance.verifyOtp(_email.text.trim(), _code.text.trim()));
  }

  Future<void> _apple() => _run(AuthService.instance.signInWithApple);

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      background: const PocketBackground(),
      body: ListView(
        padding: pagePadding(context, appBar: false),
        children: [
          const PocketHeader(
            title: 'Pocket Wallet',
            subtitle: 'Digital ID & card wallet',
            status: 'Sign in to continue',
          ),
          Tile(
            index: '01',
            title: 'Sign in',
            trailing: const StatusChip('Secure'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: DotRing(size: 96)),
                const SizedBox(height: 18),
                GlassSegmentedControl(
                  segments: const [
                    GlassSegment(label: 'PASSWORD'),
                    GlassSegment(label: 'EMAIL CODE'),
                  ],
                  selectedIndex: _mode,
                  useOwnLayer: true,
                  height: 40,
                  backgroundColor: kTileHi,
                  indicatorColor: const Color(0x55FF4A1C),
                  selectedTextStyle: mono(11, color: kInk, spacing: 1)
                      .copyWith(fontWeight: FontWeight.w700),
                  unselectedTextStyle: mono(11, color: kMuted, spacing: 1),
                  onSegmentSelected: (i) => setState(() {
                    _mode = i;
                    _otpSent = false;
                    _code.clear();
                  }),
                ),
                const SizedBox(height: 16),
                PocketField(
                  controller: _email,
                  placeholder: 'Email',
                  icon: CupertinoIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                if (_mode == 0) ...[
                  PocketPasswordField(
                    controller: _password,
                    onSubmitted: (_) => _signInPassword(),
                  ),
                  const SizedBox(height: 18),
                  GlassAction(
                      label: 'Sign in', busy: _busy, onTap: _signInPassword),
                  LinkText(
                    'Forgot password?',
                    onTap: () => Navigator.of(context).push(CupertinoPageRoute(
                      builder: (_) => ForgotPasswordScreen(email: _email.text),
                    )),
                  ),
                ] else if (_otpSent) ...[
                  PocketField(
                    controller: _code,
                    placeholder: 'Code from email',
                    icon: CupertinoIcons.number,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    onSubmitted: (_) => _verifyOtp(),
                  ),
                  const SizedBox(height: 18),
                  GlassAction(
                      label: 'Verify & sign in',
                      busy: _busy,
                      onTap: _verifyOtp),
                  LinkText('Resend code', onTap: _sendOtp),
                ] else ...[
                  const SizedBox(height: 6),
                  GlassAction(label: 'Send code', busy: _busy, onTap: _sendOtp),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Tile(
            index: '02',
            title: 'Quick access',
            child: GlassAction(
              label: 'Continue with Apple',
              icon: Icons.apple,
              primary: false,
              onTap: _busy ? null : _apple,
            ),
          ),
          const SizedBox(height: 16),
          Tile(
            index: '03',
            title: 'New here',
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => const RegisterScreen()),
            ),
            trailing: const Icon(CupertinoIcons.arrow_right,
                size: 16, color: kAccent),
            child: Text('Create account', style: dot(24)),
          ),
          const Tagline('Your cards. One pocket.'),
        ],
      ),
    );
  }
}
