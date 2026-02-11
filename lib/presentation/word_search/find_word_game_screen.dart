import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';
import 'package:local_game/core/di/di.dart';
import 'package:local_game/core/routes.dart';
import 'package:local_game/presentation/models/points.dart';
import 'package:local_game/presentation/widget/animated_timer_bar.dart';
import 'package:local_game/presentation/widget/game_top_bar.dart';
import 'package:local_game/presentation/widget/neubrutalism_container.dart';
import 'package:local_game/presentation/widget/neubrutalism_toast.dart';
import 'package:local_game/presentation/word_search/find_word_game_cubit.dart';
import 'package:local_game/presentation/word_search/find_word_game_state.dart';

import 'package:local_game/presentation/word_search/widgets/game_grid.dart';
import 'package:local_game/presentation/word_search/widgets/words_to_find.dart';

import 'package:local_game/presentation/widget/loading_screen.dart';

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
    const creamBackground = Color(0xFFFFF9E5);
    const darkBorderColor = Color(0xFF2B2118);
    const accentOrange = Color(0xFFE88328);

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<FindWordGameCubit, FindWordGameState>(
        listener: (context, state) {
          if (state.newFoundWord.isNotEmpty) {
            NeubrutalismToast.show(
              context,
              message: 'BRAVO: ${state.newFoundWord.toUpperCase()}!',
              backgroundColor:
                  state.wordColors[state.newFoundWord] ?? accentOrange,
            );
            _cubit.clearNewFoundWord();
          }

          if (state.hintError?.isNotEmpty == true) {
            NeubrutalismToast.show(
              context,
              message: state.hintError!,
              backgroundColor: Colors.red,
              icon: Icons.error_outline,
            );
          }

          if (state.isAllComplete) {
            context.go(
              Routes.levelCompleteScreen.toPath,
              extra: Points(
                initialTotalPoints: state.initialScore,
                runPoints: state.levelPoints,
                bonusPoints: state.bonus,
                addedPoints:
                    state.isReplay
                        ? (state.levelPoints + state.bonus >
                                (state.level?.points ?? 0)
                            ? (state.levelPoints +
                                state.bonus -
                                (state.level?.points ?? 0))
                            : 0)
                        : (state.levelPoints + state.bonus),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.cubitState is CubitLoading) {
            return const LoadingScreen();
          }

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                context.go(Routes.mapScreen.toPath);
              }
            },
            child: Scaffold(
              backgroundColor: creamBackground,
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      GameTopBar(
                        points: state.points,
                        hints: state.hints,
                        onHintClicked: () => _cubit.onHintClicked(),
                      ),
                      const SizedBox(height: 24),

                      // Current Word HUD
                      NeubrutalismContainer(
                        height: 64,
                        borderRadius: 20,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Center(
                          child: Text(
                            state.currentWord,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: accentOrange,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      GameGrid(
                        state: state,
                        cubit: _cubit,
                        hintPosition: state.hintPosition,
                        darkBorderColor: darkBorderColor,
                        accentOrange: accentOrange,
                      ),
                      const SizedBox(height: 24),
                      WordsToFind(
                        state: state,
                        darkBorderColor: darkBorderColor,
                        accentOrange: accentOrange,
                      ),
                    ],
                  ),
                ),
              ),
              floatingActionButton:
                  state.seconds > 0
                      ? FloatingActionButton.extended(
                        onPressed: null,
                        backgroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                            color: darkBorderColor,
                            width: 3,
                          ),
                        ),
                        label: Row(
                          children: [
                            const Icon(Icons.timer, color: darkBorderColor),
                            const SizedBox(width: 8),
                            Text(
                              '${state.seconds}s',
                              style: const TextStyle(
                                color: darkBorderColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      )
                      : null,
            ),
          );
        },
      ),
    );
  }
}
