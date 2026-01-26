import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/core/constants/app_assets.dart';
import 'package:local_game/core/di/di.dart';
import 'package:local_game/core/routes.dart';
import 'package:local_game/core/sound/sound_manager.dart';
import 'package:local_game/presentation/models/points.dart';
import 'package:local_game/presentation/widget/neubrutalism_container.dart';
import 'package:lottie/lottie.dart';

class LevelCompleteScreen extends StatefulWidget {
  final Points points;

  const LevelCompleteScreen({super.key, required this.points});

  @override
  State<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen>
    with TickerProviderStateMixin {
  bool _showText = false;
  late final SoundManager _soundManager;
  late AnimationController _textController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  // Point animation controllers
  late AnimationController _pointsController;
  late Animation<int> _totalPointsAnimation;
  late Animation<int> _levelPointsAnimation;
  late Animation<int> _bonusPointsAnimation;

  int _displayTotal = 0;
  int _displayLevel = 0;
  int _displayBonus = 0;

  bool _showLevelPoints = false;
  bool _showBonusPoints = false;

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

    // Points animation controller
    _pointsController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _setupPointAnimations();
  }

  void _setupPointAnimations() {
    // Animate total points first (0 to 0.33)
    _totalPointsAnimation = IntTween(
      begin: 0,
      end: widget.points.totalPoints,
    ).animate(
      CurvedAnimation(
        parent: _pointsController,
        curve: const Interval(0.0, 0.33, curve: Curves.easeOut),
      ),
    )..addListener(() {
      setState(() {
        _displayTotal = _totalPointsAnimation.value;
      });
    });

    // Animate level points (0.33 to 0.66)
    _levelPointsAnimation = IntTween(
      begin: 0,
      end: widget.points.levelPoints,
    ).animate(
      CurvedAnimation(
        parent: _pointsController,
        curve: const Interval(0.33, 0.66, curve: Curves.easeOut),
      ),
    )..addListener(() {
      if (_pointsController.value >= 0.33) {
        setState(() {
          _showLevelPoints = true;
          _displayLevel = _levelPointsAnimation.value;
          _displayTotal = widget.points.totalPoints + _displayLevel;
        });
      }
    });

    // Animate bonus points (0.66 to 1.0)
    _bonusPointsAnimation = IntTween(
      begin: 0,
      end: widget.points.bonusPoints,
    ).animate(
      CurvedAnimation(
        parent: _pointsController,
        curve: const Interval(0.66, 1.0, curve: Curves.easeOut),
      ),
    )..addListener(() {
      if (_pointsController.value >= 0.66) {
        setState(() {
          _showBonusPoints = true;
          _displayBonus = _bonusPointsAnimation.value;
          _displayTotal =
              widget.points.totalPoints +
              widget.points.levelPoints +
              _displayBonus;
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  void _onAnimationComplete() {
    setState(() {
      _showText = true;
    });
    _textController.forward();
    // Start point animations after text appears
    Future.delayed(const Duration(milliseconds: 400), () {
      _pointsController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    const creamBackground = Color(0xFFFFF9E5);
    const darkBorderColor = Color(0xFF2B2118);
    const accentOrange = Color(0xFFE88328);

    return Scaffold(
      backgroundColor: creamBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_showText)
                      Expanded(
                        child: Lottie.asset(
                          AppAssets.celebrationsAnimation,
                          repeat: false,
                          onLoaded: (composition) {
                            Future.delayed(
                              composition.duration,
                              _onAnimationComplete,
                            );
                          },
                        ),
                      ),
                    if (_showText)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            children: [
                              const Text(
                                'Level Complete!',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: darkBorderColor,
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildPointsDisplay(darkBorderColor),
                              const SizedBox(height: 16),
                              Lottie.asset(
                                width: double.infinity,
                                height: 100,
                                AppAssets.fallingCoins,
                                repeat: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: GestureDetector(
                onTap: () => context.go(Routes.mapScreen.toPath),
                child: NeubrutalismContainer(
                  backgroundColor: accentOrange,
                  borderRadius: 50,
                  height: 80,
                  width: double.infinity,
                  child: const Center(
                    child: Text(
                      'Pfuurira Mberi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsDisplay(Color darkBorderColor) {
    return NeubrutalismContainer(
      borderRadius: 30,
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: Column(
        children: [
          Text(
            'Total Points',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkBorderColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _displayTotal.toString(),
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w900,
              color: darkBorderColor,
            ),
          ),
          if (_showLevelPoints || _showBonusPoints) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            if (_showLevelPoints)
              _buildPointRow('Level Points', _displayLevel, Colors.blue),
            if (_showBonusPoints) ...[
              const SizedBox(height: 12),
              _buildPointRow('Bonus Points', _displayBonus, Colors.green),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPointRow(String label, int points, Color color) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '+ $points',
            style: AppTextStyles.heading2.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
