import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../services/auth_service.dart';
import '../widgets/common.dart';
import '../widgets/dots.dart';

/// Password reset with an emailed code: email -> code + new password.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.email = ''});
  final String email;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final _email = TextEditingController(text: widget.email);
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      showError(context, 'Please enter your email.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      await AuthService.instance.resetPassword(email);
      if (mounted) {
        setState(() => _sent = true);
        showOk(context, 'Code sent. Check your inbox.');
      }
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reset() async {
    final code = _code.text.trim();
    if (code.length < 6) {
      showError(context, 'Enter the code from your email.');
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
      await AuthService.instance.confirmPasswordReset(
        email: _email.text.trim(),
        code: code,
        newPassword: _password.text,
      );
      if (!mounted) return;
      // The code signs the user in; AuthGate shows Home behind this screen.
      Navigator.of(context).popUntil((r) => r.isFirst);
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
          PocketHeader(
            title: 'Reset access',
            subtitle: "We'll email you a code",
            status: _sent ? 'Code sent' : 'Awaiting email',
          ),
          Tile(
            index: '01',
            title: 'Recover',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DotLine(),
                const SizedBox(height: 18),
                PocketField(
                  controller: _email,
                  placeholder: 'Email',
                  icon: CupertinoIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _send(),
                ),
                const SizedBox(height: 18),
                GlassAction(
                  label: _sent ? 'Resend code' : 'Send code',
                  primary: !_sent,
                  busy: _busy && !_sent,
                  onTap: _busy ? null : _send,
                ),
              ],
            ),
          ),
          if (_sent) ...[
            const SizedBox(height: 16),
            Tile(
              index: '02',
              title: 'New password',
              trailing: const StatusChip('Sent'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PocketField(
                    controller: _code,
                    placeholder: 'Code from email',
                    icon: CupertinoIcons.number,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    maxLength: 8,
                  ),
                  const SizedBox(height: 12),
                  PocketPasswordField(
                    controller: _password,
                    placeholder: 'New password',
                  ),
                  const SizedBox(height: 12),
                  PocketPasswordField(
                    controller: _confirm,
                    placeholder: 'Confirm new password',
                    onSubmitted: (_) => _reset(),
                  ),
                  const SizedBox(height: 18),
                  GlassAction(
                    label: 'Reset password',
                    busy: _busy,
                    onTap: _reset,
                  ),
                ],
              ),
            ),
          ],
          const Tagline('Back in seconds'),
        ],
      ),
    );
  }
}
