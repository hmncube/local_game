import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_game/core/constants/app_assets.dart';
import 'package:local_game/presentation/widget/animated_progress_bar.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _mascotController;
  late AnimationController _pulseController;

  late Animation<double> _mascotBounce;
  late Animation<double> _mascotScale;
  late Animation<double> _circlePulse;

  @override
  void initState() {
    super.initState();

    _mascotController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _mascotBounce = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: -15,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -15,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 50,
      ),
    ]).animate(_mascotController);

    _mascotScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.05,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.05,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 50,
      ),
    ]).animate(_mascotController);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _circlePulse = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _mascotController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const creamBackground = Color(0xFFFFF9E5);
    const darkBorderColor = Color(0xFF2B2118);
    const accentOrange = Color(0xFFE88328);

    return Scaffold(
      backgroundColor: creamBackground,
      body: Stack(
        children: [
          // Background Decorative Circles
          Center(
            child: AnimatedBuilder(
              animation: _circlePulse,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildDecorativeCircle(
                      300 * _circlePulse.value,
                      accentOrange.withOpacity(0.05),
                      darkBorderColor.withOpacity(0.1),
                    ),
                    _buildDecorativeCircle(
                      450 * _circlePulse.value,
                      accentOrange.withOpacity(0.03),
                      darkBorderColor.withOpacity(0.05),
                    ),
                    _buildDecorativeCircle(
                      600 * _circlePulse.value,
                      accentOrange.withOpacity(0.01),
                      darkBorderColor.withOpacity(0.02),
                    ),
                  ],
                );
              },
            ),
          ),

          // Main Content
          Center(
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
                          AppAssets.maskotSvg,
                          height: 280,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 48),
                const AnimatedProgressBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeCircle(double size, Color color, Color borderColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        color: color,
      ),
    );
  }
}
