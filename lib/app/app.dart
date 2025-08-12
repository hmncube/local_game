import 'package:flutter/material.dart';
import 'package:local_game/app/themes/app_theme.dart';
import 'package:local_game/presentation/routing/app_route.dart';

class WordGameApp extends StatelessWidget {
  const WordGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Word Game',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoutes.router,
    );
  }
}
