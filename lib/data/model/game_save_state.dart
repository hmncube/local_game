import 'dart:convert';
import 'package:local_game/presentation/word_search/find_word_game_state.dart';

class WordSearchSaveState {
  final int levelId;
  final List<List<String>> grid;
  final List<String> wordsToFind;
  final List<String> foundWords;
  final Map<String, List<Position>> wordPositions;
  final Map<String, int> wordColors; // ARGB int values
  final int seconds;
  final int points;
  final int levelPoints;
  final int gridSize;

  WordSearchSaveState({
    required this.levelId,
    required this.grid,
    required this.wordsToFind,
    required this.foundWords,
    required this.wordPositions,
    required this.wordColors,
    required this.seconds,
    required this.points,
    required this.levelPoints,
    required this.gridSize,
  });

  Map<String, dynamic> toMap() {
    return {
      'levelId': levelId,
      'grid': grid,
      'wordsToFind': wordsToFind,
      'foundWords': foundWords,
      'wordPositions': wordPositions.map(
        (key, value) => MapEntry(
          key,
          value.map((p) => {'row': p.row, 'col': p.col}).toList(),
        ),
      ),
      'wordColors': wordColors,
      'seconds': seconds,
      'points': points,
      'levelPoints': levelPoints,
      'gridSize': gridSize,
    };
  }

  factory WordSearchSaveState.fromMap(Map<String, dynamic> map) {
    return WordSearchSaveState(
      levelId: map['levelId'],
      grid:
          (map['grid'] as List)
              .map((row) => (row as List).cast<String>())
              .toList(),
      wordsToFind: (map['wordsToFind'] as List).cast<String>(),
      foundWords: (map['foundWords'] as List).cast<String>(),
      wordPositions: (map['wordPositions'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as List).map((p) => Position(p['row'], p['col'])).toList(),
        ),
      ),
      wordColors:
          (map['wordColors'] as Map<String, dynamic>).cast<String, int>(),
      seconds: map['seconds'],
      points: map['points'],
      levelPoints: map['levelPoints'],
      gridSize: map['gridSize'],
    );
  }

  String toJson() => jsonEncode(toMap());
  factory WordSearchSaveState.fromJson(String source) =>
      WordSearchSaveState.fromMap(jsonDecode(source));
}

class SimilarWordsSaveState {
  final int levelId;
  final List<String> availableWords;
  final Map<String, String?> userAnswers;
  final Set<String> usedWords;
  final Map<String, String> questionAnswers;
  final int seconds;
  final int score;
  final int levelPoints;
  final int bonus;

  SimilarWordsSaveState({
    required this.levelId,
    required this.availableWords,
    required this.userAnswers,
    required this.usedWords,
    required this.questionAnswers,
    required this.seconds,
    required this.score,
    required this.levelPoints,
    required this.bonus,
  });

  Map<String, dynamic> toMap() {
    return {
      'levelId': levelId,
      'availableWords': availableWords,
      'userAnswers': userAnswers,
      'usedWords': usedWords.toList(),
      'questionAnswers': questionAnswers,
      'seconds': seconds,
      'score': score,
      'levelPoints': levelPoints,
      'bonus': bonus,
    };
  }

  factory SimilarWordsSaveState.fromMap(Map<String, dynamic> map) {
    return SimilarWordsSaveState(
      levelId: map['levelId'],
      availableWords: (map['availableWords'] as List).cast<String>(),
      userAnswers:
          (map['userAnswers'] as Map<String, dynamic>).cast<String, String?>(),
      usedWords: (map['usedWords'] as List).cast<String>().toSet(),
      questionAnswers:
          (map['questionAnswers'] as Map<String, dynamic>)
              .cast<String, String>(),
      seconds: map['seconds'],
      score: map['score'],
      levelPoints: map['levelPoints'],
      bonus: map['bonus'],
    );
  }

  String toJson() => jsonEncode(toMap());
  factory SimilarWordsSaveState.fromJson(String source) =>
      SimilarWordsSaveState.fromMap(jsonDecode(source));
}

class WordLinkSaveState {
  final int levelId;
  final List<String> letters;
  final List<String> words;
  final List<String> filledWords;
  final int seconds;
  final int totalPoints;
  final int levelPoints;
  final int bonus;
  final int hintsCount;

  WordLinkSaveState({
    required this.levelId,
    required this.letters,
    required this.words,
    required this.filledWords,
    required this.seconds,
    required this.totalPoints,
    required this.levelPoints,
    required this.bonus,
    required this.hintsCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'levelId': levelId,
      'letters': letters,
      'words': words,
      'filledWords': filledWords,
      'seconds': seconds,
      'totalPoints': totalPoints,
      'levelPoints': levelPoints,
      'bonus': bonus,
      'hintsCount': hintsCount,
    };
  }

  factory WordLinkSaveState.fromMap(Map<String, dynamic> map) {
    return WordLinkSaveState(
      levelId: map['levelId'],
      letters: (map['letters'] as List).cast<String>(),
      words: (map['words'] as List).cast<String>(),
      filledWords: (map['filledWords'] as List).cast<String>(),
      seconds: map['seconds'],
      totalPoints: map['totalPoints'],
      levelPoints: map['levelPoints'],
      bonus: map['bonus'],
      hintsCount: map['hintsCount'],
    );
  }

  String toJson() => jsonEncode(toMap());
  factory WordLinkSaveState.fromJson(String source) =>
      WordLinkSaveState.fromMap(jsonDecode(source));
}
