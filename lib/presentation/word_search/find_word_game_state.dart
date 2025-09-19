import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';

class FindWordGameState extends Equatable {
  final BaseCubitState cubitState;
  final int gridSize;
  final List<List<String>> grid;
  final List<String> wordsToFind;
  final List<String> foundWords;
  final List<Position> selectedPositions;
  final Position startPosition;
  final bool isDragging;
  final Map<String, List<Position>> wordPositions;
  final Map<String, Color> wordColors;
  final String newFoundWord;

  const FindWordGameState({
    required this.cubitState,
    this.gridSize = 10,
    this.grid = const [],
    this.wordsToFind = const [],
    this.foundWords = const [],
    this.selectedPositions = const [],
    this.startPosition = const Position.invalid(),
    this.isDragging = false,
    this.wordPositions = const {},
    this.wordColors = const {},
    this.newFoundWord = '',
  });

  FindWordGameState copyWith({
    BaseCubitState? cubitState,
    int? gridSize,
    List<List<String>>? grid,
    List<String>? wordsToFind,
    List<String>? foundWords,
    List<Position>? selectedPositions,
    Position? startPosition,
    bool? isDragging,
    Map<String, List<Position>>? wordPositions,
    Map<String, Color>? wordColors,
    String? newFoundWord,
  }) {
    return FindWordGameState(
      cubitState: cubitState ?? this.cubitState,
      gridSize: gridSize ?? this.gridSize,
      grid: grid ?? this.grid,
      wordsToFind: wordsToFind ?? this.wordsToFind,
      foundWords: foundWords ?? this.foundWords,
      selectedPositions: selectedPositions ?? this.selectedPositions,
      startPosition: startPosition ?? this.startPosition,
      isDragging: isDragging ?? this.isDragging,
      wordPositions: wordPositions ?? this.wordPositions,
      wordColors: wordColors ?? this.wordColors,
      newFoundWord: newFoundWord ?? this.newFoundWord,
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
      ];
}

class Position extends Equatable {
  final int row;
  final int col;

  const Position(this.row, this.col);

  const Position.invalid()
      : row = -1,
        col = -1;

  bool get isValid => row != -1 && col != -1;

  @override
  List<Object?> get props => [row, col];

  @override
  String toString() => 'Position($row, $col)';
}
