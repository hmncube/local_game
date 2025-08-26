import 'package:equatable/equatable.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';

class GameState extends Equatable {
  final BaseCubitState cubitState;
  final int level;
  final bool isWordWrong;
  final bool isWordCorrect;
  final bool isLevelComplete;
  final bool wasWordEnteredBefore;
  final List<String> letters;
  final List<String> words;
  final List<String> filledWords;
  final List<String> currentWord;

  const GameState({
    required this.cubitState,
    this.level = 0,
    this.wasWordEnteredBefore = false,
    this.isLevelComplete = false,
    this.letters = const [],
    this.words = const [],
    this.filledWords = const [],
    this.currentWord = const [],
    this.isWordWrong = false,
    this.isWordCorrect = false,
  });

  GameState copyWith({
    BaseCubitState? cubitState,
    int? level,
    bool? isLevelComplete,
    List<String>? letters,
    List<String>? words,
    List<String>? currentWord,
    List<String>? filledWords,
    bool? isWordWrong,
    bool? isWordCorrect,
    bool? wasWordEnteredBefore,
  }) {
    return GameState(
      cubitState: cubitState ?? this.cubitState,
      level: level ?? this.level,
      letters: letters ?? this.letters,
      words: words ?? this.words,
      currentWord: currentWord ?? this.currentWord,
      filledWords: filledWords ?? this.filledWords,
      isWordCorrect: isWordCorrect ?? this.isWordCorrect,
      isWordWrong: isWordWrong ?? this.isWordWrong,
      isLevelComplete: isLevelComplete ?? this.isLevelComplete,
      wasWordEnteredBefore: wasWordEnteredBefore ?? this.wasWordEnteredBefore,
    );
  }

  @override
  List<Object?> get props => [
    cubitState,
    level,
    letters,
    words,
    currentWord,
    filledWords,
    isWordCorrect,
    isWordWrong,
    isLevelComplete,
    wasWordEnteredBefore,
  ];
}
