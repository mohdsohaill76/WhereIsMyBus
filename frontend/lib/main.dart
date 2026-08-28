import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/app_shell.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
  runApp(const WhereIsMyBusApp());
}

class WhereIsMyBusApp extends StatelessWidget {
  const WhereIsMyBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhereIsMyBus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const AppShell(),
    );
  }
}
