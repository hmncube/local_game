import 'package:equatable/equatable.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';

class SimilarWordsGameState extends Equatable {
  final BaseCubitState cubitState;
  final Map<String, String> questionAnswers;
  final List<String> availableWords;
  final Map<String, String?> userAnswers;
  final Set<String> usedWords;
  final int score;
  final int hints;
  final String userId;
  final bool isGameComplete;

  const SimilarWordsGameState({
    required this.cubitState,
    this.questionAnswers = const {},
    this.availableWords = const [],
    this.userAnswers = const {},
    this.usedWords = const {},
    this.score = 0,
    this.hints = 0,
    this.userId = '',
    this.isGameComplete = false,
  });

  SimilarWordsGameState copyWith({
    BaseCubitState? cubitState,
    Map<String, String>? questionAnswers,
    List<String>? availableWords,
    Map<String, String?>? userAnswers,
    Set<String>? usedWords,
    int? score,
    int? hints,
    String? userId,
    bool? isGameComplete,
  }) {
    return SimilarWordsGameState(
      cubitState: cubitState ?? this.cubitState,
      questionAnswers: questionAnswers ?? this.questionAnswers,
      availableWords: availableWords ?? this.availableWords,
      userAnswers: userAnswers ?? this.userAnswers,
      usedWords: usedWords ?? this.usedWords,
      score: score ?? this.score,
      hints: hints ?? this.hints,
      userId: userId ?? this.userId,
      isGameComplete: isGameComplete ?? this.isGameComplete,
    );
  }

  @override
  List<Object?> get props => [
    cubitState,
    questionAnswers,
    availableWords,
    userAnswers,
    usedWords,
    score,
    hints,
    userId,
    isGameComplete,
  ];
}
