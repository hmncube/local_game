import 'package:flutter/material.dart';
import 'package:local_game/app/themes/app_text_styles.dart';

import 'package:local_game/app/themes/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.accentGreen,
      body: Center(
        child: Text(
          'Learning Through Play,\nGrowing Through Games',
          style: AppTextStyles.heading1.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
