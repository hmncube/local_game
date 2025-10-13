import 'dart:math';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:local_game/core/base/cubit/base_cubit_wrapper.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';
import 'package:local_game/core/game_system/points_management.dart';
import 'package:local_game/data/dao/user_dao.dart';
import 'package:local_game/data/dao/word_dao.dart';
import 'package:local_game/presentation/word_search/find_word_game_state.dart';

@injectable
class FindWordGameCubit extends BaseCubitWrapper<FindWordGameState> {
  final WordDao _wordDao;
  final UserDao _userDao;

  FindWordGameCubit(this._wordDao, this._userDao)
    : super(FindWordGameState(cubitState: CubitInitial()));

  final List<Color> _availableColors = [
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.lime,
    Colors.deepOrange,
  ];

  @override
  void dispose() {}

  @override
  Future<void> initialize() async {
    initializeGame();
  }

  void initializeGame({int? gridSize}) async {
    emit(state.copyWith(cubitState: CubitLoading()));

    final newGridSize = gridSize ?? state.gridSize;
    var grid = List.generate(newGridSize, (_) => List.filled(newGridSize, ''));
    final wordsToFind =
        (await _wordDao.getRandomWords(
          'shona',
          1,
          6,
        )).map((w) => w.word.toUpperCase()).toList();
    final wordPositions = <String, List<Position>>{};

    _placeWords(wordsToFind, grid, newGridSize, wordPositions);
    _fillEmptyCells(grid, newGridSize);

    final user = await _userDao.getUser();

    emit(
      state.copyWith(
        cubitState: CubitSuccess(),
        gridSize: newGridSize,
        grid: grid,
        wordsToFind: wordsToFind,
        foundWords: [],
        selectedPositions: [],
        startPosition: const Position.invalid(),
        isDragging: false,
        wordPositions: wordPositions,
        wordColors: {},
        newFoundWord: '',
        points: user?.totalScore,
        hints: user?.hints,
        userId: user?.id,
      ),
    );
  }

  void _placeWords(
    List<String> wordsToFind,
    List<List<String>> grid,
    int gridSize,
    Map<String, List<Position>> wordPositions,
  ) {
    Random random = Random();
    for (String word in wordsToFind) {
      bool placed = false;
      int attempts = 0;
      while (!placed && attempts < 100) {
        int direction = random.nextInt(8);
        Position startPos = Position(
          random.nextInt(gridSize),
          random.nextInt(gridSize),
        );
        if (_canPlaceWord(word, startPos, direction, grid, gridSize)) {
          _placeWord(word, startPos, direction, grid, wordPositions);
          placed = true;
        }
        attempts++;
      }
    }
  }

  bool _canPlaceWord(
    String word,
    Position start,
    int direction,
    List<List<String>> grid,
    int gridSize,
  ) {
    List<int> dx = [-1, -1, -1, 0, 0, 1, 1, 1];
    List<int> dy = [-1, 0, 1, -1, 1, -1, 0, 1];
    for (int i = 0; i < word.length; i++) {
      int newX = start.row + (dx[direction] * i);
      int newY = start.col + (dy[direction] * i);
      if (newX < 0 || newX >= gridSize || newY < 0 || newY >= gridSize)
        return false;
      if (grid[newX][newY].isNotEmpty && grid[newX][newY] != word[i])
        return false;
    }
    return true;
  }

  void _placeWord(
    String word,
    Position start,
    int direction,
    List<List<String>> grid,
    Map<String, List<Position>> wordPositions,
  ) {
    List<int> dx = [-1, -1, -1, 0, 0, 1, 1, 1];
    List<int> dy = [-1, 0, 1, -1, 1, -1, 0, 1];
    List<Position> positions = [];
    for (int i = 0; i < word.length; i++) {
      int newX = start.row + (dx[direction] * i);
      int newY = start.col + (dy[direction] * i);
      grid[newX][newY] = word[i];
      positions.add(Position(newX, newY));
    }
    wordPositions[word] = positions;
  }

  void _fillEmptyCells(List<List<String>> grid, int gridSize) {
    Random random = Random();
    String letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j].isEmpty) {
          grid[i][j] = letters[random.nextInt(letters.length)];
        }
      }
    }
  }

  void onCellTap(int row, int col) {
    if (!state.isDragging) {
      emit(
        state.copyWith(
          startPosition: Position(row, col),
          selectedPositions: [Position(row, col)],
          isDragging: true,
        ),
      );
    }
  }

  void onCellDrag(int row, int col) {
    if (!state.isDragging || !state.startPosition.isValid) return;
    final selectedPositions = _getLinePositions(
      state.startPosition,
      Position(row, col),
    );
    emit(state.copyWith(selectedPositions: selectedPositions));
  }

  void onDragEnd() {
    String newFoundWord = '';
    var newFoundWords = state.foundWords;
    var newWordColors = state.wordColors;

    if (state.selectedPositions.length > 1) {
      String selectedWord = state.selectedPositions
          .map((pos) => state.grid[pos.row][pos.col])
          .join('');
      String reversedWord = selectedWord.split('').reversed.join('');
      String? matchedWord;

      if (state.wordsToFind.contains(selectedWord) &&
          !state.foundWords.contains(selectedWord)) {
        matchedWord = selectedWord;
      } else if (state.wordsToFind.contains(reversedWord) &&
          !state.foundWords.contains(reversedWord)) {
        matchedWord = reversedWord;
      }

      if (matchedWord != null) {
        newFoundWords = List<String>.from(state.foundWords)..add(matchedWord);
        newWordColors = Map<String, Color>.from(state.wordColors);
        int colorIndex = newFoundWords.length - 1;
        newWordColors[matchedWord] =
            _availableColors[colorIndex % _availableColors.length];
        newFoundWord = matchedWord;
      }
    }
    final points = PointsManagement().calculatePoints(newFoundWord);
    _updatePoints(points);
    emit(
      state.copyWith(
        selectedPositions: [],
        startPosition: const Position.invalid(),
        isDragging: false,
        foundWords: newFoundWords,
        wordColors: newWordColors,
        newFoundWord: newFoundWord,
        points: state.points + points,
      ),
    );
  }

  List<Position> _getLinePositions(Position start, Position end) {
    List<Position> positions = [];
    int dx = (end.row - start.row).sign;
    int dy = (end.col - start.col).sign;

    if (dx != 0 &&
        dy != 0 &&
        (end.row - start.row).abs() != (end.col - start.col).abs()) {
      return [start];
    }

    int currentRow = start.row;
    int currentCol = start.col;
    while (true) {
      if (currentRow >= 0 &&
          currentRow < state.gridSize &&
          currentCol >= 0 &&
          currentCol < state.gridSize) {
        positions.add(Position(currentRow, currentCol));
      }
      if (currentRow == end.row && currentCol == end.col) break;
      currentRow += dx;
      currentCol += dy;
    }
    return positions;
  }

  void clearNewFoundWord() {
    emit(state.copyWith(newFoundWord: ''));
  }

  void _updatePoints(int points) {
    _userDao.updateTotalScore(state.userId, points + state.points);
  }

  void onHintClicked() {
    if (state.hints == 0) {
      emit(state.copyWith(hintError: 'You are out of hints!'));
      return;
    }
    final remainingWords =
        state.wordsToFind
            .where((word) => !state.foundWords.contains(word))
            .toList();

    final wordPosition =
        state.wordPositions.entries
            .where((word) => remainingWords.contains(word.key))
            .first;
    final firstPosition = wordPosition.value.first;
    final hints = state.hints - 1;
    emit(state.copyWith(hintPosition: firstPosition, hints: hints));
    updateHintDb(hints);
  }

  void updateHintDb(int hints) {
    _userDao.updateHints(state.userId, hints);
  }
}
