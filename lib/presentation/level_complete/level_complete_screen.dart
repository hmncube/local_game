import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/core/constants/app_assets.dart';
import 'package:local_game/core/di/di.dart';
import 'package:local_game/core/routes.dart';
import 'package:local_game/core/sound/sound_manager.dart';
import 'package:local_game/presentation/models/points.dart';
import 'package:local_game/presentation/widget/app_btn.dart';
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
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(AppAssets.backgroundSvg, fit: BoxFit.fill),
          ),
          Positioned.fill(child: SvgPicture.asset(AppAssets.celebrationSvg)),
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
                  child: Column(
                    children: [
                      Lottie.asset(
                        width: double.infinity,
                        height: 200,
                        AppAssets.fallingCoins,
                        repeat: false,
                      ),                      
                      // Points Display
                      _buildPointsDisplay(),

                      Lottie.asset(
                        width: double.infinity,
                        height: 200,
                        AppAssets.coinsChest,
                        repeat: false,
                      ),
                      const SizedBox(height: 32),
                      AppBtn(
                        title: 'Pfuurira Mberi',
                        onClick: () {
                          context.go(Routes.mapScreen.toPath);
                        },
                        isEnabled: true,
                        width: 300
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPointsDisplay() {
    return Stack(
      children: [
        Positioned(
          child: SizedBox(
            height: 400,
            child: SvgPicture.asset(AppAssets.inputSvg, fit: BoxFit.fill),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 64.0, left: 32, right: 32),
          child: Column(
            children: [
              // Total Points (large display)
              Text(
                'Total Points',
                style: AppTextStyles.heading2.copyWith(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _displayTotal.toString(),
                style: AppTextStyles.heading2.copyWith(
                  fontSize: 56,
                ),
              ),
              const SizedBox(height: 24),

              // Breakdown
              if (_showLevelPoints)
                _buildPointRow('Level Points', _displayLevel, Colors.blue),

              if (_showLevelPoints) const SizedBox(height: 12),

              if (_showBonusPoints)
                _buildPointRow('Bonus Points', _displayBonus, Colors.green),
            ],
          ),
        ),
      ],
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
