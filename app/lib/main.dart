import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/strings.dart';
import 'core/theme.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(
    // ProviderScope is required at the root for Riverpod.
    const ProviderScope(child: PillSafeApp()),
  );
}

class PillSafeApp extends StatelessWidget {
  const PillSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appName,
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
