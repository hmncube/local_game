import 'package:equatable/equatable.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';
import 'package:local_game/data/model/level_model.dart';

class GameState extends Equatable {
  final BaseCubitState cubitState;
  final int level;
  final int points;
  final int hintsCount;
  final bool isWordWrong;
  final bool isWordCorrect;
  final bool isLevelComplete;
  final bool wasWordEnteredBefore;
  final LevelModel? levelModel;
  final String hint;
  final List<String> letters;
  final List<String> words;
  final List<String> filledWords;
  final List<String> currentWord;

  const GameState({
    required this.cubitState,
    this.level = 0,
    this.hintsCount = 0,
    this.points = 0,
    this.levelModel,
    this.wasWordEnteredBefore = false,
    this.isLevelComplete = false,
    this.hint = '',
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
    int? hintsCount,
    int? points,
    LevelModel? levelModel,
    bool? isLevelComplete,
    String? hint,
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
      hintsCount: hintsCount ?? this.hintsCount,
      points: points ?? this.points,
      levelModel: levelModel ?? this.levelModel,
      currentWord: currentWord ?? this.currentWord,
      filledWords: filledWords ?? this.filledWords,
      isWordCorrect: isWordCorrect ?? this.isWordCorrect,
      isWordWrong: isWordWrong ?? this.isWordWrong,
      isLevelComplete: isLevelComplete ?? this.isLevelComplete,
      wasWordEnteredBefore: wasWordEnteredBefore ?? this.wasWordEnteredBefore,
      hint: hint ?? this.hint,
    );
  }

  @override
  List<Object?> get props => [
    cubitState,
    level,
    letters,
    words,
    points,
    hintsCount,
    hint,
    levelModel,
    currentWord,
    filledWords,
    isWordCorrect,
    isWordWrong,
    isLevelComplete,
    wasWordEnteredBefore,
  ];
}
