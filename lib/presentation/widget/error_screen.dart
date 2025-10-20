import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/core/constants/app_assets.dart';
import 'package:local_game/core/routes.dart';
import 'package:local_game/presentation/widget/app_btn.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(AppAssets.mascotSadSvg),
              SizedBox(height: 24),
              Text(
                'Oops, \n something went wrong,\n lets go back and try again!',
                style: AppTextStyles.heading2.copyWith(color: Colors.brown),
              ),
              SizedBox(height: 24),
              AppBtn(
                onClick: () {
                  context.go(Routes.mapScreen.toPath);
                },
                title: 'Go home',
                isEnabled: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
