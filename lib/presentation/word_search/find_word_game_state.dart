import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';
import 'package:local_game/data/model/level_model.dart';

class FindWordGameState extends Equatable {
  final BaseCubitState cubitState;
  final int gridSize;
  final LevelModel? level;
  final List<List<String>> grid;
  final List<String> wordsToFind;
  final List<String> foundWords;
  final List<Position> selectedPositions;
  final Position startPosition;
  final bool isDragging;
  final bool isAllComplete;
  final Map<String, List<Position>> wordPositions;
  final Map<String, Color> wordColors;
  final String newFoundWord;
  final int initialScore;
  final int points;
  final int hints;
  final int levelPoints;
  final int seconds;
  final int bonus;
  final double progressValue;
  final String userId;
  final String currentWord;
  final String? hintError;
  final Position? hintPosition;
  final bool isReplay;

  const FindWordGameState({
    required this.cubitState,
    this.level,
    this.gridSize = 8,
    this.grid = const [],
    this.wordsToFind = const [],
    this.foundWords = const [],
    this.selectedPositions = const [],
    this.startPosition = const Position.invalid(),
    this.isDragging = false,
    this.isAllComplete = false,
    this.wordPositions = const {},
    this.wordColors = const {},
    this.newFoundWord = '',
    this.initialScore = 0,
    this.points = 0,
    this.hints = 0,
    this.bonus = 0,
    this.levelPoints = 0,
    this.seconds = 0,
    this.progressValue = 0.0,
    this.userId = '',
    this.currentWord = '',
    this.hintError,
    this.hintPosition,
    this.isReplay = false,
  });

  FindWordGameState copyWith({
    BaseCubitState? cubitState,
    LevelModel? level,
    int? gridSize,
    List<List<String>>? grid,
    List<String>? wordsToFind,
    List<String>? foundWords,
    List<Position>? selectedPositions,
    Position? startPosition,
    bool? isDragging,
    bool? isAllComplete,
    Map<String, List<Position>>? wordPositions,
    Map<String, Color>? wordColors,
    String? newFoundWord,
    int? initialScore,
    int? points,
    int? hints,
    int? levelPoints,
    int? bonus,
    int? seconds,
    double? progressValue,
    String? userId,
    String? currentWord,
    String? hintError,
    Position? hintPosition,
    bool? isReplay,
  }) {
    return FindWordGameState(
      cubitState: cubitState ?? this.cubitState,
      gridSize: gridSize ?? this.gridSize,
      level: level ?? this.level,
      grid: grid ?? this.grid,
      wordsToFind: wordsToFind ?? this.wordsToFind,
      foundWords: foundWords ?? this.foundWords,
      selectedPositions: selectedPositions ?? this.selectedPositions,
      startPosition: startPosition ?? this.startPosition,
      isDragging: isDragging ?? this.isDragging,
      wordPositions: wordPositions ?? this.wordPositions,
      wordColors: wordColors ?? this.wordColors,
      newFoundWord: newFoundWord ?? this.newFoundWord,
      initialScore: initialScore ?? this.initialScore,
      points: points ?? this.points,
      bonus: bonus ?? this.bonus,
      userId: userId ?? this.userId,
      currentWord: currentWord ?? this.currentWord,
      seconds: seconds ?? this.seconds,
      progressValue: progressValue ?? this.progressValue,
      isAllComplete: isAllComplete ?? this.isAllComplete,
      hints: hints ?? this.hints,
      hintError: hintError ?? this.hintError,
      hintPosition: hintPosition ?? this.hintPosition,
      levelPoints: levelPoints ?? this.levelPoints,
      isReplay: isReplay ?? this.isReplay,
    );
  }

  @override
  List<Object?> get props => [
    cubitState,
    gridSize,
    grid,
    wordsToFind,
    foundWords,
    selectedPositions,
    startPosition,
    isDragging,
    wordPositions,
    wordColors,
    newFoundWord,
    initialScore,
    points,
    userId,
    currentWord,
    hints,
    bonus,
    hintPosition,
    isAllComplete,
    level,
    levelPoints,
    seconds,
    progressValue,
    isReplay,
  ];
}

class Position extends Equatable {
  final int row;
  final int col;

  const Position(this.row, this.col);

  const Position.invalid() : row = -1, col = -1;

  bool get isValid => row != -1 && col != -1;

  @override
  List<Object?> get props => [row, col];

  @override
  String toString() => 'Position($row, $col)';
}
