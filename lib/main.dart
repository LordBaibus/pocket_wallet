import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabasePublishableKey);
  await LiquidGlassWidgets.initialize();

  runApp(LiquidGlassWidgets.wrap(child: const PocketWalletApp()));
}

class PocketWalletApp extends StatelessWidget {
  const PocketWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Pocket Wallet',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF8E8CFF),
      ),
      home: AuthGate(),
    );
  }
}
