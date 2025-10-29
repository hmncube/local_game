import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_game/core/di/di.dart';
import 'package:local_game/core/routes.dart';
import 'package:local_game/presentation/widget/game_top_bar.dart';
import 'package:local_game/presentation/word_search/find_word_game_cubit.dart';
import 'package:local_game/presentation/word_search/find_word_game_state.dart';

import 'package:local_game/presentation/word_search/widgets/game_grid.dart';
import 'package:local_game/presentation/word_search/widgets/words_to_find.dart';

class FindWordGameScreen extends StatefulWidget {
  final int levelId;
  const FindWordGameScreen({super.key, required this.levelId});

  @override
  State<FindWordGameScreen> createState() => _FindWordGameScreenState();
}

class _FindWordGameScreenState extends State<FindWordGameScreen> {
  late final FindWordGameCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<FindWordGameCubit>();
    _cubit.initializeGame(level: widget.levelId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<FindWordGameCubit, FindWordGameState>(
        listener: (context, state) {
          if (state.newFoundWord.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Found: ${state.newFoundWord}!'),
                duration: const Duration(seconds: 1),
                backgroundColor: state.wordColors[state.newFoundWord],
              ),
            );
            _cubit.clearNewFoundWord();
          }

          if (state.hintError?.isNotEmpty == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.hintError ?? ''),
                duration: const Duration(seconds: 1),
                backgroundColor: state.wordColors[state.newFoundWord],
              ),
            );
          }

          if (state.isAllComplete) {
            context.go(Routes.levelCompleteScreen.toPath);
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    GameTopBar(
                      points: state.points,
                      hints: state.hints,
                      onHintClicked: () => _cubit.onHintClicked(),
                    ),
                    const SizedBox(height: 16),
                    GameGrid(
                      state: state,
                      cubit: _cubit,
                      hintPosition: state.hintPosition,
                    ),
                    const SizedBox(height: 16),
                    WordsToFind(state: state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
