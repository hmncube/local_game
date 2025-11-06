import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:local_game/core/base/cubit/base_cubit_wrapper.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';
import 'package:local_game/core/constants/app_values.dart';
import 'package:local_game/core/game_system/points_management.dart';
import 'package:local_game/data/dao/level_dao.dart';
import 'package:local_game/data/dao/user_dao.dart';
import 'package:local_game/presentation/similar_words/similar_words_game_state.dart';

@injectable
class SimilarWordsGameCubit extends BaseCubitWrapper<SimilarWordsGameState> {
  final LevelDao _levelDao;
  final UserDao _userDao;
  Timer? _timer;

  SimilarWordsGameCubit(this._levelDao, this._userDao)
    : super(SimilarWordsGameState(cubitState: CubitInitial()));

  @override
  void dispose() {
    _timer?.cancel();
  }

  Future<void> initializeGame({required int levelId}) async {
    emit(state.copyWith(cubitState: CubitLoading()));
    final level = await _levelDao.getLevelById(levelId);
    final words = level?.wordsEn ?? [];

    Map<String, String> questionAnswers = {};
    List<String> availableWords = List.empty(growable: true);
    for (int i = 0; i < words.length; i += 2) {
      questionAnswers[words[i]] = words[i + 1];
      availableWords.add(words[i + 1]);
    }

    // get random words
    final random = await _levelDao.getLevelById(levelId - 1);
    final randomWords = random?.wordsEn ?? [];

    final set = Set.from(availableWords);
    set.addAll(randomWords);

    availableWords = List.from(set);

    Map<String, String?> userAnswers = {};
    for (String question in questionAnswers.keys) {
      userAnswers[question] = null;
    }
    // Shuffle the available words
    availableWords.shuffle();

    final user = await _userDao.getUser();

    emit(
      state.copyWith(
        availableWords: availableWords,
        userAnswers: userAnswers,
        questionAnswers: questionAnswers,
        hints: user?.hints,
        score: user?.totalScore,
        userId: user?.id,
        level: level,
      ),
    );
  }

  void startGame() {
    _timer?.cancel();
    emit(state.copyWith(seconds: 0));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      emit(state.copyWith(seconds: state.seconds + 1));
    });
  }

  Future<void> onWordDropped(String questionWord, String droppedWord) async {
    final userAnswers = _updateUserAnswers(questionWord, droppedWord);
    final usedWords = _updateUsedWords(questionWord, droppedWord);
    final isGameComplete = _isGameComplete(userAnswers);

    if (isGameComplete) {
      await _completeLevel();
    }

    final points = await _updatePoints(droppedWord);

    emit(
      state.copyWith(
        usedWords: usedWords,
        userAnswers: userAnswers,
        score: points.totalScore,
        levelPoints: points.levelScore,
        isGameComplete: isGameComplete,
      ),
    );
    startGame();
  }

  Future<({int totalScore, int levelScore})> _updatePoints(
    String droppedWord,
  ) async {
    final earnedPoints = PointsManagement.calculateTimePoints(
      droppedWord,
      seconds: state.seconds,
    );
    final totalScore = state.score + earnedPoints;
    final levelScore = state.levelPoints + earnedPoints;

    await _userDao.updateTotalScore(state.userId, totalScore);

    return (totalScore: totalScore, levelScore: levelScore);
  }

  Map<String, String?> _updateUserAnswers(
    String questionWord,
    String droppedWord,
  ) {
    final userAnswers = Map<String, String?>.from(state.userAnswers);
    userAnswers[questionWord] = droppedWord;
    return userAnswers;
  }

  Set<String> _updateUsedWords(String questionWord, String droppedWord) {
    final usedWords = Set<String>.from(state.usedWords);

    final previousAnswer = state.userAnswers[questionWord];
    if (previousAnswer != null) {
      usedWords.remove(previousAnswer);
    }

    usedWords.add(droppedWord);
    return usedWords;
  }

  bool _isGameComplete(Map<String, String?> userAnswers) {
    return userAnswers.values.every((value) => value != null);
  }

  Future<void> _completeLevel() async {
    _timer?.cancel();
    final completedLevel = state.level?.copyWith(
      points: state.levelPoints,
      finishedAt: DateTime.now().millisecondsSinceEpoch,
      status: AppValues.levelDone,
    );
    await _levelDao.updateLevel(completedLevel);
  }

  Future<({int totalScore, int levelScore})> _calculateAndUpdatePoints(
    String questionWord,
    String droppedWord,
  ) async {
    int totalScore = state.score;
    int levelScore = state.levelPoints;

    if (isCorrectAnswer(questionWord, droppedWord)) {
      final earnedPoints = PointsManagement.calculatePoints(droppedWord);
      totalScore += earnedPoints;
      levelScore += earnedPoints;
      await _userDao.updateTotalScore(state.userId, totalScore);
    }

    return (totalScore: totalScore, levelScore: levelScore);
  }

  bool isCorrectAnswer(String question, String? answer) {
    return state.questionAnswers[question] == answer;
  }

  void resetGame() {
    Map<String, String?> userAnswers = {};
    for (String question in state.questionAnswers.keys) {
      userAnswers[question] = null;
    }
    final availableWords = state.availableWords;
    availableWords.shuffle();
    emit(
      state.copyWith(
        userAnswers: userAnswers,
        usedWords: {},
        availableWords: availableWords,
      ),
    );
  }

  @override
  void initialize() {}
}
