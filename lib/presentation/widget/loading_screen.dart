import 'package:flutter/material.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/app/themes/app_theme.dart';
import 'package:local_game/core/constants/app_assets.dart';
import 'package:lottie/lottie.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.accentGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Lottie.asset(
                AppAssets.loadingAnimation,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
                repeat: true,
              ),
            const SizedBox(height: 32,),
            Text('LOADING ......', style: AppTextStyles.heading1.copyWith(
              color: Colors.white,
            ),),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}