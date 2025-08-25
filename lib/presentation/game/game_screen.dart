import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/app/themes/app_theme.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';
import 'package:local_game/core/di/di.dart';
import 'package:local_game/presentation/game/game_cubit.dart';
import 'package:local_game/presentation/game/game_state.dart';
import 'package:local_game/presentation/game/widgets/letter_container.dart';
import 'package:local_game/presentation/game/widgets/letters_keyboard.dart';
import 'package:local_game/presentation/game/widgets/text_display.dart';
import 'package:local_game/presentation/widget/life_widget.dart';
import 'package:local_game/presentation/widget/loading_screen.dart';
import 'package:local_game/presentation/widget/money_widget.dart';

class GameScreen extends StatefulWidget {
  final int level;
  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt.get<GameCubit>()..init(level: widget.level);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameCubit, GameState>(
      bloc: _cubit,
      listener: (context, state) {
        print('pundez listener ${state}');
      },
      builder: (context, state) {
        if (state.cubitState is CubitLoading ||
            state.cubitState is CubitInitial) {
          return LoadingScreen();
        }
        return Scaffold(
          backgroundColor: AppTheme.accentGreen,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(children: [LifeWidget(), Spacer(), MoneyWidget()]),
                  const SizedBox(height: 60),
                  TextDisplay(words: state.filledWords,),
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
                        child: Text(state.currentWord.join('') , style: AppTextStyles.heading1),
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
        );
      },
    );
  }
}
