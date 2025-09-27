import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_game/app/themes/app_text_styles.dart';
import 'package:local_game/core/di/di.dart';
import 'package:local_game/presentation/similar_words/similar_words_game_cubit.dart';
import 'package:local_game/presentation/similar_words/similar_words_game_state.dart';

class SimilarWordsGameScreen extends StatefulWidget {
  const SimilarWordsGameScreen({super.key});

  @override
  State<SimilarWordsGameScreen> createState() => _SimilarWordsGameScreenState();
}

class _SimilarWordsGameScreenState extends State<SimilarWordsGameScreen> {
  late final SimilarWordsGameCubit _cubit;
  @override
  void initState() {
    super.initState();
    _cubit = getIt<SimilarWordsGameCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<SimilarWordsGameCubit, SimilarWordsGameState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Similar Words Game'),
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _cubit.resetGame,
                  tooltip: 'Reset Game',
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Score display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Score: ${state.score} / ${state.questionAnswers.length}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Instructions
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
                              border: Border.all(color: Colors.grey.shade300),
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
                                      String question = state.questionAnswers.keys
                                          .elementAt(index);
                                      String? userAnswer =
                                          state.userAnswers[question];
                                      bool isCorrect = _cubit.isCorrectAnswer(
                                        question,
                                        userAnswer,
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
                                              style: AppTextStyles.keyboardKey
                                                  .copyWith(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            DragTarget<String>(
                                              onAcceptWithDetails: (
                                                droppedWord,
                                              ) {
                                                _cubit.onWordDropped(
                                                  question,
                                                  droppedWord.data,
                                                );
                                              },
                                              builder: (
                                                context,
                                                candidateData,
                                                rejectedData,
                                              ) {
                                                return Container(
                                                  width: double.infinity,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        userAnswer != null
                                                            ? (isCorrect
                                                                ? Colors
                                                                    .green
                                                                    .shade100
                                                                : Colors
                                                                    .red
                                                                    .shade100)
                                                            : Colors.white,
                                                    border: Border.all(
                                                      color:
                                                          candidateData
                                                                  .isNotEmpty
                                                              ? Colors
                                                                  .blue
                                                                  .shade400
                                                              : Colors
                                                                  .grey
                                                                  .shade400,
                                                      width:
                                                          candidateData
                                                                  .isNotEmpty
                                                              ? 2
                                                              : 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child:
                                                      userAnswer != null
                                                          ? Row(
                                                            children: [
                                                              Expanded(
                                                                child: Center(
                                                                  child: Text(
                                                                    userAnswer,
                                                                    style: AppTextStyles.keyboardKey.copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
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
                                                              candidateData
                                                                      .isNotEmpty
                                                                  ? 'Drop here'
                                                                  : 'Drag word here',
                                                              style: AppTextStyles
                                                                  .keyboardKey
                                                                  .copyWith(
                                                                    color:
                                                                        Colors
                                                                            .grey
                                                                            .shade600,
                                                                    fontSize:
                                                                        12,
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
                              border: Border.all(color: Colors.orange.shade200),
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
                                    children:
                                        state.availableWords
                                            .where(
                                              (word) =>
                                                  !state.usedWords.contains(word),
                                            )
                                            .map(
                                              (word) => Draggable<String>(
                                                data: word,
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
                                                      color:
                                                          Colors.blue.shade400,
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
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade400,
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
                                                    color:
                                                        Colors.orange.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          Colors
                                                              .orange
                                                              .shade300,
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
                                              ),
                                            )
                                            .toList(),
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

                  // Check answers button
                  if (state.userAnswers.values.every((answer) => answer != null))
                    ElevatedButton.icon(
                      onPressed: () {
                        int score = state.score;
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Game Complete!'),
                                content: Text(
                                  'You got $score out of ${state.questionAnswers.length} correct!\n\n'
                                  '${score == state.questionAnswers.length ? 'Perfect score! 🎉' : 'Keep practicing to improve your score!'}',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _cubit.resetGame();
                                    },
                                    child: const Text('Play Again'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                        );
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Check Answers'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
