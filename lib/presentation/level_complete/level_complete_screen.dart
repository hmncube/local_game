import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_game/core/constants/app_assets.dart';
import 'package:local_game/core/di/di.dart';
import 'package:local_game/core/routes.dart';
import 'package:local_game/core/sound/sound_manager.dart';
import 'package:local_game/presentation/widget/app_button.dart';
import 'package:lottie/lottie.dart';

class LevelCompleteScreen extends StatefulWidget {
  const LevelCompleteScreen({super.key});

  @override
  State<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen>
    with SingleTickerProviderStateMixin {
  bool _showText = false;
  late final SoundManager _soundManager;
  late AnimationController _textController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _soundManager = getIt.get<SoundManager>();
    _soundManager.playCorrectAnswerSound();
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onAnimationComplete() {
    setState(() {
      _showText = true;
    });
    _textController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (!_showText)
            Lottie.asset(
              AppAssets.celebrationsAnimation,
              repeat: false,
              onLoaded: (composition) {
                Future.delayed(composition.duration, _onAnimationComplete);
              },
            ),
          if (_showText)
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.amberAccent,
                    child: Column(
                      children: [
                        Lottie.asset(
                          width: double.infinity,
                          height: 200,
                          AppAssets.fallingCoins,
                          repeat: false,
                        ),
                        const SizedBox(height: 32),

                        Lottie.asset(
                          width: double.infinity,
                          height: 200,
                          AppAssets.fallingCoins2,
                          repeat: false,
                        ),
                        const SizedBox(height: 32),

                        Lottie.asset(
                          width: double.infinity,
                          height: 200,
                          AppAssets.coinsChest,
                          repeat: false,
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AppButton(
                            title: 'Pfuurira Mberi',
                            onClick: () {
                              context.go(Routes.mapScreen.toPath);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
