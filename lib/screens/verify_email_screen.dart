import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../services/auth_service.dart';
import '../widgets/common.dart';
import '../widgets/dots.dart';

/// Confirms a new account with the 6-digit code from the signup email.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});
  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _code = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _code.text.trim();
    if (code.length < 6) {
      showError(context, 'Enter the code from your email.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      await AuthService.instance.verifySignupCode(widget.email, code);
      // Session is created: AuthGate shows Home; drop pushed screens.
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    try {
      await AuthService.instance.resendSignupCode(widget.email);
      if (mounted) showOk(context, 'New code sent.');
    } catch (e) {
      if (mounted) showError(context, e);
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
            title: 'Verify email',
            subtitle: 'Enter the code we sent you',
            status: 'Awaiting confirmation',
          ),
          Tile(
            index: '01',
            title: 'Confirm',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DotLine(),
                const SizedBox(height: 14),
                Text(widget.email, style: mono(12, color: kMuted)),
                const SizedBox(height: 14),
                PocketField(
                  controller: _code,
                  placeholder: 'Code from email',
                  icon: CupertinoIcons.number,
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  onSubmitted: (_) => _verify(),
                ),
                const SizedBox(height: 18),
                GlassAction(label: 'Verify', busy: _busy, onTap: _verify),
                LinkText('Resend code', onTap: _resend),
              ],
            ),
          ),
          const Tagline('Almost there'),
        ],
      ),
    );
  }
}
