import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_game/core/di/di.dart';
import 'package:local_game/core/extensions/time_extension.dart';
import 'package:local_game/core/routes.dart';
import 'package:local_game/presentation/models/points.dart';
import 'package:local_game/presentation/similar_words/similar_words_game_cubit.dart';
import 'package:local_game/presentation/similar_words/similar_words_game_state.dart';
import 'package:local_game/presentation/widget/game_top_bar.dart';
import 'package:local_game/presentation/widget/neubrutalism_container.dart';

class SimilarWordsGameScreen extends StatefulWidget {
  final int levelId;
  const SimilarWordsGameScreen({super.key, required this.levelId});

  @override
  State<SimilarWordsGameScreen> createState() => _SimilarWordsGameScreenState();
}

class _SimilarWordsGameScreenState extends State<SimilarWordsGameScreen> {
  late final SimilarWordsGameCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<SimilarWordsGameCubit>();
    _cubit.initializeGame(levelId: widget.levelId);
    _cubit.startGame();
  }

  @override
  Widget build(BuildContext context) {
    const creamBackground = Color(0xFFFFF9E5);
    const darkBorderColor = Color(0xFF2B2118);
    const accentOrange = Color(0xFFE88328);

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<SimilarWordsGameCubit, SimilarWordsGameState>(
        listener: (context, state) {
          if (state.isGameComplete) {
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
                        points: state.score,
                        hints: state.hints,
                        onHintClicked: () {},
                      ),
                      const SizedBox(height: 24),

                      // Timer and Instructions
                      NeubrutalismContainer(
                        borderRadius: 20,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 20,
                              color: darkBorderColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              state.seconds.toTimeString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: darkBorderColor,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Match words by dragging them over!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: darkBorderColor.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      Expanded(
                        child: Row(
                          children: [
                            // Questions side (left)
                            Expanded(
                              flex: 1,
                              child: NeubrutalismContainer(
                                borderRadius: 20,
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    const Text(
                                      'SIMILAR WORDS',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.blue,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(height: 1),
                                    const SizedBox(height: 16),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: state.questionAnswers.length,
                                        itemBuilder: (context, index) {
                                          String question = state
                                              .questionAnswers
                                              .keys
                                              .elementAt(index);
                                          String? userAnswerKey =
                                              state.userAnswers[question];
                                          String? userAnswer =
                                              userAnswerKey?.split('-').first;
                                          bool isCorrect = _cubit
                                              .isCorrectAnswer(
                                                question,
                                                userAnswerKey,
                                              );

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 16,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  question.toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w900,
                                                    color: darkBorderColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                _buildDropTarget(
                                                  question,
                                                  userAnswer,
                                                  userAnswerKey,
                                                  isCorrect,
                                                  darkBorderColor,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),

                            // Selection words side (right)
                            Expanded(
                              flex: 1,
                              child: NeubrutalismContainer(
                                borderRadius: 20,
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text(
                                      'SELECTION',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: accentOrange,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(height: 1),
                                    const SizedBox(height: 16),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Wrap(
                                          spacing: 12,
                                          runSpacing: 12,
                                          alignment: WrapAlignment.center,
                                          children: List.generate(
                                            state.availableWords.length,
                                            (index) {
                                              final word =
                                                  state.availableWords[index];
                                              final wordKey = '$word-$index';

                                              if (state.usedWords.contains(
                                                wordKey,
                                              )) {
                                                return const SizedBox.shrink();
                                              }

                                              return Draggable<String>(
                                                data: wordKey,
                                                feedback: Material(
                                                  color: Colors.transparent,
                                                  child: NeubrutalismContainer(
                                                    borderRadius: 12,
                                                    backgroundColor:
                                                        Colors.blue,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                          vertical: 8,
                                                        ),
                                                    child: Text(
                                                      word,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                childWhenDragging: Opacity(
                                                  opacity: 0.3,
                                                  child: _buildWordChip(
                                                    word,
                                                    darkBorderColor,
                                                  ),
                                                ),
                                                child: _buildWordChip(
                                                  word,
                                                  darkBorderColor,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWordChip(String word, Color darkBorderColor) {
    return NeubrutalismContainer(
      borderRadius: 12,
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Text(
        word,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: darkBorderColor,
        ),
      ),
    );
  }

  Widget _buildDropTarget(
    String question,
    String? userAnswer,
    String? userAnswerKey,
    bool isCorrect,
    Color darkBorderColor,
  ) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (droppedWordKey) {
        return true;
      },
      onAcceptWithDetails: (droppedWordKey) {
        _cubit.onWordDropped(question, droppedWordKey.data);
      },
      builder: (context, candidateData, rejectedData) {
        final bool isBeingHovered = candidateData.isNotEmpty;
        final bool isRejected = rejectedData.isNotEmpty;

        Color targetBg = Colors.white;
        Color targetBorder = darkBorderColor.withOpacity(0.2);
        double borderWidth = 1.5;

        if (userAnswerKey != null) {
          targetBg =
              isCorrect
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1);
          targetBorder = isCorrect ? Colors.green : Colors.red;
          borderWidth = 2.0;
        } else if (isBeingHovered) {
          targetBg = Colors.blue.withOpacity(0.05);
          targetBorder = Colors.blue;
          borderWidth = 2.5;
        } else if (isRejected) {
          targetBg = Colors.red.withOpacity(0.05);
          targetBorder = Colors.red;
          borderWidth = 2.0;
        }

        return Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: targetBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: targetBorder, width: borderWidth),
          ),
          child: Center(
            child:
                userAnswer != null
                    ? Text(
                      userAnswer,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                    )
                    : Text(
                      isRejected ? '!' : (isBeingHovered ? 'DROP' : '...'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color:
                            isRejected
                                ? Colors.red
                                : darkBorderColor.withOpacity(0.3),
                      ),
                    ),
          ),
        );
      },
    );
  }
}
