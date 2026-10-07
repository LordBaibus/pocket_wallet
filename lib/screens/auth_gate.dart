import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

/// Shows Home when a Supabase session exists, Login otherwise.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    return StreamBuilder<AuthState>(
      stream: auth.authChanges,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? auth.session;
        return session == null ? const LoginScreen() : const HomeScreen();
      },
    );
  }
}
