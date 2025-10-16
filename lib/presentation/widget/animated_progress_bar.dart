import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_game/app/themes/app_theme.dart';
import 'package:local_game/core/constants/app_assets.dart';

class AnimatedProgressBar extends StatefulWidget {
  const AnimatedProgressBar({super.key});

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        height: 60,
        child: Stack(
          children: [
            // Container with animated green progress
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(6.0), // Space for SVG border
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(27),
                      child: Stack(
                        children: [
                          // Animated green fill
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: 0.7 * _animation.value + 0.15,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.accentGreen.withOpacity(0.6),
                                      AppTheme.accentGreen,
                                      AppTheme.accentGreen.withOpacity(0.8),
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Shimmer effect
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                stops: [
                                  _animation.value - 0.3,
                                  _animation.value,
                                  _animation.value + 0.3,
                                ],
                                colors: const [
                                  Colors.transparent,
                                  Colors.white38,
                                  Colors.transparent,
                                ],
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.srcATop,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.greenAccent,
                                borderRadius: BorderRadius.circular(27),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            // SVG border overlay
            Positioned.fill(
              child: SvgPicture.asset(
                AppAssets.progressBarSvg,
                fit: BoxFit.fill,
              ),
            ),
          ],
        ),
      ),
    );
  }
}