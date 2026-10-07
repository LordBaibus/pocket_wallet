import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../services/auth_service.dart';
import '../widgets/common.dart';
import '../widgets/dots.dart';
import 'verify_email_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _mobile.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final mobile = _mobile.text.trim();
    if (name.isEmpty || email.isEmpty || mobile.isEmpty) {
      showError(context, 'Please fill in your name, email and mobile number.');
      return;
    }
    if (_password.text.length < 6) {
      showError(context, 'Password must be at least 6 characters.');
      return;
    }
    if (_password.text != _confirm.text) {
      showError(context, 'Passwords do not match.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      final signedIn = await AuthService.instance
          .signUp(
          email: email,
          password: _password.text,
          fullName: name,
          mobile: mobile);
      if (!mounted) return;
      if (signedIn) {
        // Session exists: AuthGate shows Home; drop this pushed screen.
        Navigator.of(context).popUntil((r) => r.isFirst);
      } else {
        // Email confirmation is on: ask for the 6-digit code from the email.
        Navigator.of(context).pushReplacement(CupertinoPageRoute(
          builder: (_) => VerifyEmailScreen(email: email),
        ));
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      background: const PocketBackground(),
      appBar: GlassAppBar(leading: backButton(context)),
      body: ListView(
        padding: pagePadding(context),
        children: [
          const PocketHeader(
            title: 'New member',
            subtitle: 'Create your wallet',
            status: 'Cards sync across devices',
          ),
          Tile(
            index: '01',
            title: 'Profile',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DotWave(height: 44, columns: 30, seed: 3),
                const SizedBox(height: 18),
                PocketField(
                  controller: _name,
                  placeholder: 'Full name',
                  icon: CupertinoIcons.person,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                PocketField(
                  controller: _email,
                  placeholder: 'Email',
                  icon: CupertinoIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                PocketField(
                  controller: _mobile,
                  placeholder: 'Mobile number',
                  icon: CupertinoIcons.phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Tile(
            index: '02',
            title: 'Security',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PocketPasswordField(controller: _password),
                const SizedBox(height: 12),
                PocketPasswordField(
                  controller: _confirm,
                  placeholder: 'Confirm password',
                  onSubmitted: (_) => _register(),
                ),
                const SizedBox(height: 18),
                GlassAction(label: 'Sign up', busy: _busy, onTap: _register),
              ],
            ),
          ),
          const Tagline('Build your pocket'),
        ],
      ),
    );
  }
}
