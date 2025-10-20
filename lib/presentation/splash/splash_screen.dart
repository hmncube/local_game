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

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mascotController;
  late AnimationController _mavaraController;
  late AnimationController _backgroundController;

  late Animation<double> _mascotBounce;
  late Animation<double> _mascotScale;
  late Animation<double> _mavaraFloat;
  late Animation<double> _mavaraRotate;
  late Animation<double> _backgroundPulse;

  @override
  void initState() {
    super.initState();

    _mascotController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _mascotBounce = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _mascotController, curve: Curves.easeInOut),
    );

    _mascotScale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _mascotController, curve: Curves.easeInOut),
    );

    _mavaraController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _mavaraFloat = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _mavaraController, curve: Curves.easeInOut),
    );

    _mavaraRotate = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _mavaraController, curve: Curves.easeInOut),
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundPulse = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _mascotController.dispose();
    _mavaraController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SplashCubit>(),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state.isOnboarded) {
            context.go(Routes.mapScreen.toPath);
          }
          if (!state.isOnboarded) {
            context.go(Routes.onboarding.toPath);
          }
        },
        child: Scaffold(
          backgroundColor: AppTheme.accentGreen,
          body: Stack(
            children: [
              AnimatedBuilder(
                animation: _backgroundPulse,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _backgroundPulse.value,
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: SvgPicture.asset(
                        fit: BoxFit.fill,
                        AppAssets.backgroundSvg,
                      ),
                    ),
                  );
                },
              ),

              AnimatedBuilder(
                animation: _mavaraController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _mavaraFloat.value),
                    child: Transform.rotate(
                      angle: _mavaraRotate.value,
                      child: SvgPicture.asset(AppAssets.mavaraSvg),
                    ),
                  );
                },
              ),

              Center(
                child: AnimatedBuilder(
                  animation: _mascotController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _mascotBounce.value),
                      child: Transform.scale(
                        scale: _mascotScale.value,
                        child: SvgPicture.asset(
                          height: 400,
                          width: 400,
                          AppAssets.maskotSvg,
                        ),
                      ),
                    );
                  },
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
