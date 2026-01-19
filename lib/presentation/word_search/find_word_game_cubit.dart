import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:local_game/core/base/cubit/base_cubit_wrapper.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';
import 'package:local_game/core/constants/app_values.dart';
import 'package:local_game/core/game_system/points_management.dart';
import 'package:local_game/data/dao/level_dao.dart';
import 'package:local_game/data/dao/user_dao.dart';
import 'package:local_game/presentation/word_search/find_word_game_state.dart';

@injectable
class FindWordGameCubit extends BaseCubitWrapper<FindWordGameState> {
  final UserDao _userDao;
  final LevelDao _levelDao;

  FindWordGameCubit(this._userDao, this._levelDao)
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
  Future<void> initialize() async {}

  void initializeGame({required int level, int? gridSize}) async {
    emit(state.copyWith(cubitState: CubitLoading()));

    final newGridSize = gridSize ?? state.gridSize;
    var grid = List.generate(newGridSize, (_) => List.filled(newGridSize, ''));
    final levelModel = (await _levelDao.getLevelById(level));

    final words =
        levelModel?.languageId == 1
            ? levelModel?.wordsEn
            : levelModel?.languageId == 2
            ? levelModel?.wordsSn
            : levelModel?.wordsNd;

    final wordsToFind = words?.map((w) => w.toUpperCase()).toList() ?? [];
    final wordPositions = <String, List<Position>>{};

    _placeWords(wordsToFind, grid, newGridSize, wordPositions);
    _fillEmptyCells(grid, newGridSize);

    final user = await _userDao.getUser();

    emit(
      state.copyWith(
        cubitState: CubitSuccess(),
        level: levelModel,
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
    startGame();
  }

  Timer? _timer;
  void startGame() {
    _timer?.cancel();
    emit(state.copyWith(seconds: AppValues.timerTime));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      emit(
        state.copyWith(
          seconds: state.seconds - 1,
          progressValue: (state.seconds - 1) / AppValues.timerTime,
        ),
      );
      if (state.seconds <= 0) {
        _timer?.cancel();
      }
    });
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

  Future<void> onDragEnd() async {
    final selectedWord = _getSelectedWord();
    final matchedWord = _findMatchedWord(selectedWord);

    if (matchedWord != null) {
      final updatedFoundWords = _addFoundWord(matchedWord);
      final wordColor = _assignColorToWord(
        matchedWord,
        updatedFoundWords.length,
      );
      final points = _calculatePoints(word: matchedWord);
      final isComplete = _isLevelComplete(updatedFoundWords);
      int bonus = 0;
      if (isComplete) {
        bonus = _calculateBonus(AppValues.timerTime - state.seconds);
        await _completeLevel();
      }
      _updatePoints(points + bonus);
      await _updateTotalScore(points);

      _emitStateWithFoundWord(
        matchedWord: matchedWord,
        foundWords: updatedFoundWords,
        wordColor: wordColor,
        points: points,
        isComplete: isComplete,
        bonus: bonus,
      );
    } else {
      _emitStateWithoutMatch();
    }
  }

  String _getSelectedWord() {
    return state.selectedPositions
        .map((pos) => state.grid[pos.row][pos.col])
        .join('');
  }

  String? _findMatchedWord(String selectedWord) {
    if (state.selectedPositions.length <= 1) {
      return null;
    }

    if (_isValidWord(selectedWord)) {
      return selectedWord;
    }

    final reversedWord = _reverseWord(selectedWord);
    if (_isValidWord(reversedWord)) {
      return reversedWord;
    }

    return null;
  }

  bool _isValidWord(String word) {
    return state.wordsToFind.contains(word) && !state.foundWords.contains(word);
  }

  String _reverseWord(String word) {
    return word.split('').reversed.join('');
  }

  List<String> _addFoundWord(String word) {
    return List<String>.from(state.foundWords)..add(word);
  }

  Color _assignColorToWord(String word, int foundWordsCount) {
    final colorIndex = foundWordsCount - 1;
    return _availableColors[colorIndex % _availableColors.length];
  }

  int _calculatePoints({required String word}) {
    return PointsManagement.calculatePoints(word);
  }

  bool _isLevelComplete(List<String> foundWords) {
    return foundWords.length == state.wordsToFind.length;
  }

  Future<void> _completeLevel() async {
    final completedLevel = state.level?.copyWith(
      points: state.levelPoints,
      finishedAt: DateTime.now().millisecondsSinceEpoch,
      status: AppValues.levelDone,
    );
    await _levelDao.updateLevel(completedLevel);
  }

  Future<void> _updateTotalScore(int points) async {
    await _userDao.updateTotalScore(state.userId, state.points + points);
  }

  void _emitStateWithFoundWord({
    required String matchedWord,
    required List<String> foundWords,
    required Color wordColor,
    required int points,
    required int bonus,
    required bool isComplete,
  }) {
    final updatedWordColors = Map<String, Color>.from(state.wordColors);
    updatedWordColors[matchedWord] = wordColor;

    emit(
      state.copyWith(
        selectedPositions: [],
        startPosition: const Position.invalid(),
        isDragging: false,
        foundWords: foundWords,
        isAllComplete: isComplete,
        wordColors: updatedWordColors,
        newFoundWord: matchedWord,
        bonus: bonus,
        points: state.points + points,
        levelPoints: state.levelPoints + points,
      ),
    );
  }

  void _emitStateWithoutMatch() {
    emit(
      state.copyWith(
        selectedPositions: [],
        startPosition: const Position.invalid(),
        isDragging: false,
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

  int _calculateBonus(int timeLeft) {
    return PointsManagement.calculateTimeLeftPoints(timeLeft: timeLeft);
  }
}
