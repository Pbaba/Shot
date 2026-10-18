import 'package:flutter/material.dart';
import 'theme/theme.dart';
import 'router.dart';

class ShotApp extends StatelessWidget {
  const ShotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Shot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
