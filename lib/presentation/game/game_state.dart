import 'package:equatable/equatable.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';

class GameState extends Equatable {
  final BaseCubitState cubitState;
  final int level;
  final List<String> letters;
  final List<String> words;
  final List<String> currentWord;

  const GameState({
    required this.cubitState,
    this.level = 0,
    this.letters = const [],
    this.words = const [],
    this.currentWord = const [],
  });

  GameState copyWith({
    BaseCubitState? cubitState,
    int? level,
    List<String>? letters,
    List<String>? words,
    List<String>? currentWord,
  }) {
    return GameState(
      cubitState: cubitState ?? this.cubitState,
      level: level ?? this.level,
      letters: letters ?? this.letters,
      words: words ?? this.words,
      currentWord: currentWord ?? this.currentWord,
    );
  }

  @override
  List<Object?> get props => [cubitState, level, letters, words, currentWord];
}
