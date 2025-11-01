import 'package:equatable/equatable.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';
import 'package:local_game/data/model/level_model.dart';

class WordLinkState extends Equatable {
  final BaseCubitState cubitState;
  final LevelModel? level;
  final int totalPoints;
  final int hintsCount;
  final int levelPoints;
  final int hintWordIndex;
  final bool isWordWrong;
  final bool isWordCorrect;
  final bool isLevelComplete;
  final bool wasWordEnteredBefore;
  final String hint;
  final String userId;
  final List<String> letters;
  final List<String> words;
  final List<String> filledWords;
  final List<String> currentWord;

  const WordLinkState({
    required this.cubitState,
    this.level,
    this.levelPoints = 0,
    this.hintsCount = 0,
    this.totalPoints = 0,
    this.hintWordIndex = 0,
    this.wasWordEnteredBefore = false,
    this.isLevelComplete = false,
    this.hint = '',
    this.userId = '',
    this.letters = const [],
    this.words = const [],
    this.filledWords = const [],
    this.currentWord = const [],
    this.isWordWrong = false,
    this.isWordCorrect = false,
  });

  WordLinkState copyWith({
    BaseCubitState? cubitState,
    int? hintsCount,
    int? totalPoints,
    int? levelPoints,
    int? hintWordIndex,
    LevelModel? level,
    bool? isLevelComplete,
    String? hint,
    List<String>? letters,
    List<String>? words,
    List<String>? currentWord,
    List<String>? filledWords,
    String? userId,
    bool? isWordWrong,
    bool? isWordCorrect,
    bool? wasWordEnteredBefore,
  }) {
    return WordLinkState(
      cubitState: cubitState ?? this.cubitState,
      level: level ?? this.level,
      letters: letters ?? this.letters,
      words: words ?? this.words,
      hintsCount: hintsCount ?? this.hintsCount,
      totalPoints: totalPoints ?? this.totalPoints,
      levelPoints: levelPoints ?? this.levelPoints,
      currentWord: currentWord ?? this.currentWord,
      filledWords: filledWords ?? this.filledWords,
      isWordCorrect: isWordCorrect ?? this.isWordCorrect,
      isWordWrong: isWordWrong ?? this.isWordWrong,
      isLevelComplete: isLevelComplete ?? this.isLevelComplete,
      wasWordEnteredBefore: wasWordEnteredBefore ?? this.wasWordEnteredBefore,
      hint: hint ?? this.hint,
      hintWordIndex: hintWordIndex ?? this.hintWordIndex,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [
    cubitState,
    level,
    letters,
    words,
    totalPoints,
    hintsCount,
    hint,
    hintWordIndex,
    currentWord,
    filledWords,
    isWordCorrect,
    isWordWrong,
    isLevelComplete,
    wasWordEnteredBefore,
    userId,
    levelPoints,
  ];
}
