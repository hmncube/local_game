import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:local_game/core/constants/app_assets.dart';
import 'package:local_game/core/di/di.dart';
import 'package:local_game/core/routes.dart';
import 'package:local_game/presentation/splash/splash_cubit.dart';
import 'package:local_game/presentation/splash/splash_state.dart';
import '../../core/base/cubit/cubit_status.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mascotController;
  late Animation<double> _mascotBounce;
  late Animation<double> _mascotScale;

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
  }

  @override
  void dispose() {
    _mascotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const creamBackground = Color(0xFFFFF9E5);
    const darkBorderColor = Color(0xFF2B2118);

    return BlocProvider(
      create: (context) => getIt<SplashCubit>(),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state.cubitState is CubitSuccess) {
            context.go(Routes.mapScreen.toPath);
          }
        },
        child: Scaffold(
          backgroundColor: creamBackground,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _mascotController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _mascotBounce.value),
                      child: Transform.scale(
                        scale: _mascotScale.value,
                        child: SvgPicture.asset(
                          height: 300,
                          width: 300,
                          AppAssets.maskotSvg,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 48),
                const Text(
                  'MAVARA',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: darkBorderColor,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Zimbabwean Word Games',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: darkBorderColor,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
