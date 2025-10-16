import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:local_game/app/themes/app_theme.dart';
import 'package:local_game/core/constants/app_assets.dart';
import 'package:local_game/core/di/di.dart';
import 'package:local_game/core/routes.dart';
import 'package:local_game/presentation/splash/splash_cubit.dart';
import 'package:local_game/presentation/splash/splash_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SplashCubit>(),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state.isOnboarded) {
            context.go(Routes.mapScreen.toPath);
          }
        },
        child: Scaffold(
          backgroundColor: AppTheme.accentGreen,
          body: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: SvgPicture.asset(
                  fit: BoxFit.fill,
                  AppAssets.backgroundSvg,
                ),
              ),
              SvgPicture.asset(
                  AppAssets.mavaraSvg,
                ),
              Center(
                child: SvgPicture.asset(
                  height: 400,
                  width: 400,
                    AppAssets.maskotSvg,
                  ),
              ),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: 
              SvgPicture.asset(
                 height: 60,
                width: double.infinity,
                    AppAssets.progressBarSvg,fit: BoxFit.fill,
                  ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/*
Center(
            child: Text(
              'Learning Through Play,\nGrowing Through Games',
              style: AppTextStyles.heading1.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
*/
