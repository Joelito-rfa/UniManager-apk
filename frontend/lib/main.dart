import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/router_config.dart';
import 'config/theme_config.dart';
import 'config/app_config.dart';
import 'providers/auth_provider.dart';
import 'providers/preferences_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await initializeDateFormatting('fr_FR', null);
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const UniManagerApp(),
    ),
  );
}

class UniManagerApp extends ConsumerStatefulWidget {
  const UniManagerApp({super.key});

  @override
  ConsumerState<UniManagerApp> createState() => _UniManagerAppState();
}

class _UniManagerAppState extends ConsumerState<UniManagerApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
