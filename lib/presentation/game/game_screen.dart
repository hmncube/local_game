import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/app/themes/app_theme.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';
import 'package:local_game/core/constants/app_assets.dart';
import 'package:local_game/core/di/di.dart';
import 'package:local_game/presentation/game/game_cubit.dart';
import 'package:local_game/presentation/game/game_state.dart';
import 'package:local_game/presentation/game/widgets/letters_keyboard.dart';
import 'package:local_game/presentation/game/widgets/text_display.dart';
import 'package:local_game/presentation/widget/life_widget.dart';
import 'package:local_game/presentation/widget/loading_screen.dart';
import 'package:local_game/presentation/widget/money_widget.dart';

import 'package:lottie/lottie.dart';

class GameScreen extends StatefulWidget {
  final int level;
  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late final GameCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt.get<GameCubit>()..init(level: widget.level);
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
    print('pundez word is correct');
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameCubit, GameState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state.isWordCorrect) {
          _showCorrectOverlay();
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
                      Row(children: [LifeWidget(), Spacer(), MoneyWidget()]),
                      const SizedBox(height: 60),
                      TextDisplay(words: state.filledWords),
                      Spacer(),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              state.currentWord.join(''),
                              style: AppTextStyles.heading1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      LettersKeyboard(
                        enabledLetters: state.letters,
                        onKeyPressed: (letter) {
                          _cubit.updateCurrentWord(letter);
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              // Centered overlay for correct answer
              if (state.isWordCorrect)
                Center(
                  child: _buildCorrectWidget(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCorrectWidget() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SlideTransition(
          position: _slideAnimation,
          child: Lottie.asset(
            AppAssets.correctAnimation,
            width: 150,
            height: 150,
            fit: BoxFit.cover,
            repeat: false,
            onLoaded: (composition) {
              Future.delayed(composition.duration, () {
                _cubit.resetIsWordCorrect(false);
              });
            },
          ),
        ),
      ),
    );
  }
}
