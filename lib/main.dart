import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/api_service.dart';
import 'state/auth_state.dart';
import 'state/data_store.dart';
import 'state/nav_state.dart';
import 'theme/haven_theme.dart';
import 'widgets/phone_frame.dart';
import 'screens/auth_gate.dart';
import 'screens/home_shell.dart';

void main() {
  runApp(const HavenApp());
}

class HavenApp extends StatelessWidget {
  const HavenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider<AuthState>(
          create: (c) => AuthState(c.read<ApiService>())..bootstrap(),
        ),
        ChangeNotifierProvider<DataStore>(create: (c) => DataStore(c.read<ApiService>())),
        ChangeNotifierProvider<NavState>(create: (_) => NavState()),
      ],
      child: MaterialApp(
        title: 'Haven',
        debugShowCheckedModeBanner: false,
        theme: HavenTheme.build(),
        home: const _RootGate(),
      ),
    );
  }
}

/// Decides between splash → auth → the app, and renders all three inside the
/// centred phone frame so the experience matches the design at every stage.
class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();

    Widget body;
    if (!auth.ready) {
      body = const _Splash();
    } else if (auth.isAuthed) {
      body = const _AuthedApp();
    } else {
      body = const AuthGate();
    }

    return PhoneFrame(child: body);
  }
}

/// Once signed in, load the user's data once, then show the shell.
class _AuthedApp extends StatefulWidget {
  const _AuthedApp();

  @override
  State<_AuthedApp> createState() => _AuthedAppState();
}

class _AuthedAppState extends State<_AuthedApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NavState>().resetToHome();
      context.read<DataStore>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) => const HomeShell();
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HavenLogo(size: 70, radius: 22),
          const SizedBox(height: 22),
          Text('Haven', style: news(size: 34, color: HavenColors.ink)),
          const SizedBox(height: 18),
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: HavenColors.sageDeep),
          ),
        ],
      ),
    );
  }
}
