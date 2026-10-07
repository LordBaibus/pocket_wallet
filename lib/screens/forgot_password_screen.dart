import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../services/auth_service.dart';
import '../widgets/common.dart';
import '../widgets/dots.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.email = ''});
  final String email;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final _email = TextEditingController(text: widget.email);
  bool _busy = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
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
      if (mounted) setState(() => _sent = true);
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
            subtitle: "We'll email you a reset link",
            status: _sent ? 'Link sent' : 'Awaiting email',
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
                    label: 'Send reset link', busy: _busy, onTap: _send),
              ],
            ),
          ),
          if (_sent) ...[
            const SizedBox(height: 16),
            Tile(
              index: '02',
              title: 'Status',
              trailing: const StatusChip('Sent'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CHECK INBOX', style: dot(26)),
                  const SizedBox(height: 6),
                  Text(_email.text.trim(), style: mono(12, color: kMuted)),
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
