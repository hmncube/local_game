import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/app/themes/app_theme.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';
import 'package:local_game/core/constants/app_assets.dart';
import 'package:local_game/core/di/di.dart';
import 'package:local_game/core/routes.dart';
import 'package:local_game/presentation/word_link/word_link_cubit.dart';
import 'package:local_game/presentation/word_link/word_link_state.dart';
import 'package:local_game/presentation/word_link/widgets/swipe_keyboard.dart';
import 'package:local_game/presentation/word_link/widgets/text_display.dart';
import 'package:local_game/presentation/widget/app_button.dart';
import 'package:local_game/presentation/widget/loading_screen.dart';
import 'package:local_game/presentation/widget/game_top_bar.dart';

import 'package:lottie/lottie.dart';

class WordLinkScreen extends StatefulWidget {
  final int level;
  const WordLinkScreen({super.key, required this.level});

  @override
  State<WordLinkScreen> createState() => _WordLinkScreenState();
}

class _WordLinkScreenState extends State<WordLinkScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late final WordLinkCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt.get<WordLinkCubit>()..init(level: widget.level);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _cubit.close();
    super.dispose();
  }

  void _showCorrectOverlay() {
    _controller.forward(from: 0);
  }

  bool _showAlreadyEntered = false;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WordLinkCubit, WordLinkState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state.isLevelComplete) {
          _showCorrectOverlay();
        }

        if (state.wasWordEnteredBefore) {
          setState(() => _showAlreadyEntered = true);

          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              _cubit.resetWasWordEnteredBefore();
              setState(() => _showAlreadyEntered = false);
            }
          });
        }

        if (state.isLevelComplete) {
          context.go(Routes.levelCompleteScreen.toPath);
        }
      },
      builder: (context, state) {
        if (state.cubitState is CubitLoading ||
            state.cubitState is CubitInitial) {
          return LoadingScreen();
        }
        return Scaffold(
          backgroundColor: AppTheme.accentGreen,
          body: Stack(
            children: [
              // Main game content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      GameTopBar(
                        points: state.totalPoints,
                        hints: state.hintsCount,
                        onHintClicked: () {},
                      ),
                      const SizedBox(height: 60),
                      TextDisplay(words: state.filledWords),
                      Spacer(),
                      AnimatedOpacity(
                        opacity: _showAlreadyEntered ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 800),
                        child: Text(
                          'Shoko iri ratopinda kare',
                          style: AppTextStyles.heading1.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Spacer(),
                      Stack(
                        children: [
                          Positioned.fill(
                            child: SvgPicture.asset(
                              AppAssets.inputSvg,
                              fit: BoxFit.fill,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                state.currentWord.join(''),
                                style: AppTextStyles.heading1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwipeKeyboard(
                        enabledLetters: state.letters,
                        onKeyPressed: (letter) {
                          _cubit.updateCurrentWord(letter);
                        },
                        onCheckUserInput: () {
                          _cubit.onCheckUserInput();
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              if (state.isLevelComplete) Center(child: _buildLevelComplete()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLevelComplete() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Image.asset(AppAssets.wagona),
            Spacer(),
            SlideTransition(
              position: _slideAnimation,
              child: Lottie.asset(
                AppAssets.fallingCoins,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
                repeat: true,
              ),
            ),
            const SizedBox(height: 32),
            Lottie.asset(
              AppAssets.coinsChest,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
              repeat: false,
            ),
            Spacer(),
            AppButton(
              title: 'Pfuurira Mberi',
              onClick: () {
                _cubit.resetIsLevelCorrect();
                _cubit.loadNextLevel();
              },
            ),
          ],
        ),
      ),
    );
  }
}
