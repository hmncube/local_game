import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/core/di/di.dart';
import 'package:local_game/core/extensions/time_extension.dart';
import 'package:local_game/core/routes.dart';
import 'package:local_game/presentation/models/points.dart';
import 'package:local_game/presentation/similar_words/similar_words_game_cubit.dart';
import 'package:local_game/presentation/similar_words/similar_words_game_state.dart';
import 'package:local_game/presentation/widget/game_top_bar.dart';

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
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Instructions
                      GameTopBar(
                        points: state.score,
                        hints: state.hints,
                        onHintClicked: () {},
                      ),
                      const SizedBox(height: 20),
                      Stack(
                        children: [
                          Text(
                            state.seconds.toTimeString(),
                            style: AppTextStyles.keyboardKey.copyWith(
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Drag words from the selection list to match them with similar words below:',
                        style: AppTextStyles.keyboardKey.copyWith(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      Expanded(
                        child: Row(
                          children: [
                            // Questions side (left)
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Find Similar Words:',
                                      style: AppTextStyles.keyboardKey.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
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

                                          return Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  question,
                                                  style: AppTextStyles
                                                      .keyboardKey
                                                      .copyWith(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                                const SizedBox(height: 8),
                                                DragTarget<String>(
                                                  onWillAcceptWithDetails: (
                                                    droppedWordKey,
                                                  ) {
                                                    return true;
                                                  },
                                                  onAcceptWithDetails: (
                                                    droppedWordKey,
                                                  ) {
                                                    _cubit.onWordDropped(
                                                      question,
                                                      droppedWordKey.data,
                                                    );
                                                  },
                                                  builder: (
                                                    context,
                                                    candidateData,
                                                    rejectedData,
                                                  ) {
                                                    final bool hasRejectedData =
                                                        rejectedData.isNotEmpty;

                                                    return Container(
                                                      width: double.infinity,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            userAnswerKey !=
                                                                    null
                                                                ? (isCorrect
                                                                    ? Colors
                                                                        .green
                                                                        .shade100
                                                                    : Colors
                                                                        .red
                                                                        .shade100)
                                                                : (hasRejectedData
                                                                    ? Colors
                                                                        .red
                                                                        .shade50
                                                                    : Colors
                                                                        .white),
                                                        border: Border.all(
                                                          color:
                                                              hasRejectedData
                                                                  ? Colors
                                                                      .red
                                                                      .shade400
                                                                  : (candidateData
                                                                          .isNotEmpty
                                                                      ? Colors
                                                                          .blue
                                                                          .shade400
                                                                      : Colors
                                                                          .grey
                                                                          .shade400),
                                                          width:
                                                              candidateData
                                                                          .isNotEmpty ||
                                                                      hasRejectedData
                                                                  ? 2
                                                                  : 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child:
                                                          userAnswerKey != null
                                                              ? Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Center(
                                                                      child: Text(
                                                                        userAnswer ??
                                                                            '',
                                                                        style: AppTextStyles.keyboardKey.copyWith(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              isCorrect
                                                                                  ? Colors.green.shade700
                                                                                  : Colors.red.shade700,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                              : Center(
                                                                child: Text(
                                                                  hasRejectedData
                                                                      ? 'Wrong answer!'
                                                                      : (candidateData
                                                                              .isNotEmpty
                                                                          ? 'Drop here'
                                                                          : 'Drag word here'),
                                                                  style: AppTextStyles.keyboardKey.copyWith(
                                                                    color:
                                                                        hasRejectedData
                                                                            ? Colors.red.shade700
                                                                            : Colors.grey.shade600,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        hasRejectedData
                                                                            ? FontWeight.bold
                                                                            : FontWeight.normal,
                                                                  ),
                                                                ),
                                                              ),
                                                    );
                                                  },
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
                            const SizedBox(width: 16),

                            // Selection words side (right)
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange.shade200,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selection Words:',
                                      style: AppTextStyles.keyboardKey.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Expanded(
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
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
                                                elevation: 4,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade400,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    word,
                                                    style: AppTextStyles
                                                        .keyboardKey
                                                        .copyWith(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              childWhenDragging: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.grey.shade400,
                                                  ),
                                                ),
                                                child: Text(
                                                  word,
                                                  style: AppTextStyles
                                                      .keyboardKey
                                                      .copyWith(
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade600,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                ),
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange.shade200,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color:
                                                        Colors.orange.shade300,
                                                  ),
                                                ),
                                                child: Text(
                                                  word,
                                                  style: AppTextStyles
                                                      .keyboardKey
                                                      .copyWith(
                                                        color: Colors.black87,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                ),
                                              ),
                                            );
                                          },
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

                      const SizedBox(height: 20),
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
}
