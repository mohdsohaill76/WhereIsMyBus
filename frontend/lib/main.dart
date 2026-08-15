import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const WhereIsMyBusApp());
}

class WhereIsMyBusApp extends StatelessWidget {
  const WhereIsMyBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhereIsMyBus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
