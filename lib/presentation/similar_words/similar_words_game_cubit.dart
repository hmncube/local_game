import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:local_game/core/base/cubit/base_cubit_wrapper.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';
import 'package:local_game/core/constants/app_values.dart';
import 'package:local_game/core/game_system/points_management.dart';
import 'package:local_game/data/dao/level_dao.dart';
import 'package:local_game/data/dao/user_dao.dart';
import 'package:local_game/data/dao/save_state_dao.dart';
import 'package:local_game/data/model/game_save_state.dart';
import 'package:local_game/presentation/similar_words/similar_words_game_state.dart';

@injectable
class SimilarWordsGameCubit extends BaseCubitWrapper<SimilarWordsGameState> {
  final LevelDao _levelDao;
  final UserDao _userDao;
  final SaveStateDao _saveStateDao;
  Timer? _timer;

  SimilarWordsGameCubit(this._levelDao, this._userDao, this._saveStateDao)
    : super(SimilarWordsGameState(cubitState: CubitInitial()));

  @override
  void dispose() {
    _timer?.cancel();
  }

  Future<void> initializeGame({required int levelId}) async {
    emit(state.copyWith(cubitState: CubitLoading()));
    final level = await _levelDao.getLevelById(levelId);

    final savedState = await _saveStateDao.loadSimilarWordsState(levelId);
    if (savedState != null && level?.status != AppValues.levelDone) {
      final user = await _userDao.getUser();

      emit(
        state.copyWith(
          cubitState: CubitSuccess(),
          availableWords: savedState.availableWords,
          userAnswers: savedState.userAnswers,
          questionAnswers: savedState.questionAnswers,
          usedWords: savedState.usedWords,
          seconds: savedState.seconds,
          score: savedState.score,
          levelPoints: savedState.levelPoints,
          bonus: savedState.bonus,
          hints: user?.hints,
          initialScore: savedState.score - savedState.levelPoints,
          userId: user?.id ?? '',
          level: level,
          isReplay: level?.status == AppValues.levelDone,
        ),
      );
      startGame(resume: true);
      return;
    }

    final questions = level?.wordsEn ?? [];
    final answers =
        level?.languageId == 1
            ? level?.wordsEn ?? []
            : level?.languageId == 2
            ? level?.wordsSn ?? []
            : level?.wordsNd ?? [];

    Map<String, String> questionAnswers = {};
    List<String> availableWords = [];
    for (int i = 0; i < questions.length; i++) {
      if (i < answers.length) {
        questionAnswers[questions[i]] = answers[i];
        availableWords.add(answers[i]);
      }
    }

    // get random words (distractors)
    final distractorLevelId = levelId > 1 ? levelId - 1 : levelId + 1;
    final random = await _levelDao.getLevelById(distractorLevelId);
    final randomWords =
        level?.languageId == 1
            ? random?.wordsEn ?? []
            : level?.languageId == 2
            ? random?.wordsSn ?? []
            : random?.wordsNd ?? [];

    // Combine available words and distractors without using Set.from to preserve duplicates
    availableWords.addAll(randomWords);

    // Remove duplicates if any (only if they are exact same string from distractors)
    // but keep those intended for multiple questions if they exist.
    // For now, let's just use the list as is to ensure all answers are present.

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
        initialScore: user?.totalScore ?? 0,
        score: user?.totalScore,
        userId: user?.id ?? '',
        level: level,
        isReplay: level?.status == AppValues.levelDone,
        cubitState: CubitSuccess(),
      ),
    );
  }

  void startGame({bool resume = false}) {
    _timer?.cancel();
    if (!resume) {
      emit(state.copyWith(seconds: 0));
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      emit(state.copyWith(seconds: state.seconds + 1));
    });
  }

  Future<void> saveProgress() async {
    if (state.isGameComplete || state.level == null || state.isReplay) return;

    final saveState = SimilarWordsSaveState(
      levelId: state.level!.id,
      availableWords: state.availableWords,
      userAnswers: state.userAnswers,
      usedWords: state.usedWords,
      questionAnswers: state.questionAnswers,
      seconds: state.seconds,
      score: state.score,
      levelPoints: state.levelPoints,
      bonus: state.bonus,
    );
    await _saveStateDao.saveSimilarWordsState(saveState);
  }

  Future<void> onWordDropped(String questionWord, String wordKey) async {
    final userAnswers = _updateUserAnswers(questionWord, wordKey);
    final usedWords = _updateUsedWords(questionWord, wordKey);

    // Check if the game is complete (all answers present AND all correct)
    bool allCorrect = true;
    for (var entry in userAnswers.entries) {
      if (!isCorrectAnswer(entry.key, entry.value)) {
        allCorrect = false;
        break;
      }
    }
    final isGameComplete =
        allCorrect && userAnswers.length == state.questionAnswers.length;

    if (isGameComplete) {
      await _completeLevel();
    }

    final droppedWord = wordKey.split('-').first;
    final points = await _updatePoints(droppedWord);

    emit(
      state.copyWith(
        usedWords: usedWords,
        userAnswers: userAnswers,
        score: points.totalScore,
        levelPoints: points.levelScore,
        bonus: state.bonus + points.bonus,
        isGameComplete: isGameComplete,
      ),
    );
    if (!isGameComplete) {
      await saveProgress();
    }
  }

  Future<({int totalScore, int levelScore, int bonus})> _updatePoints(
    String droppedWord,
  ) async {
    final earnedPoints = PointsManagement.calculatePoints(droppedWord);

    final bonus = PointsManagement.calculateTimeBonus(state.seconds);
    final totalScore = state.score + earnedPoints;
    final levelScore = state.levelPoints + earnedPoints;

    if (!state.isReplay) {
      await _userDao.updateTotalScore(state.userId, totalScore);
    }

    return (totalScore: totalScore, levelScore: levelScore, bonus: bonus);
  }

  Map<String, String?> _updateUserAnswers(
    String questionWord,
    String droppedWord,
  ) {
    final userAnswers = Map<String, String?>.from(state.userAnswers);
    userAnswers[questionWord] = droppedWord;
    return userAnswers;
  }

  Set<String> _updateUsedWords(String questionWord, String wordKey) {
    final usedWords = Set<String>.from(state.usedWords);

    final previousWordKey = state.userAnswers[questionWord];
    if (previousWordKey != null) {
      usedWords.remove(previousWordKey);
    }

    usedWords.add(wordKey);
    return usedWords;
  }

  Future<void> _completeLevel() async {
    _timer?.cancel();
    final currentBest = state.level?.points ?? 0;
    final currentTotalScore = state.levelPoints + state.bonus;

    if (state.isReplay) {
      if (currentTotalScore > currentBest) {
        final difference = currentTotalScore - currentBest;
        final user = await _userDao.getUser();
        if (user != null) {
          await _userDao.updateTotalScore(
            state.userId,
            user.totalScore + difference,
          );
        }

        final completedLevel = state.level?.copyWith(
          points: currentTotalScore,
          finishedAt: DateTime.now().millisecondsSinceEpoch,
        );
        await _levelDao.updateLevel(completedLevel);
      }
    } else {
      if (state.bonus > 0) {
        final user = await _userDao.getUser();
        if (user != null) {
          await _userDao.updateTotalScore(
            state.userId,
            user.totalScore + state.bonus,
          );
        }
      }

      final completedLevel = state.level?.copyWith(
        points: currentTotalScore,
        finishedAt: DateTime.now().millisecondsSinceEpoch,
        status: AppValues.levelDone,
      );
      await _levelDao.updateLevel(completedLevel);
    }
    await _saveStateDao.clearState(state.level!.id, 2);
  }

  bool isCorrectAnswer(String question, String? answerKey) {
    final answer = answerKey?.split('-').first;
    return state.questionAnswers[question] == answer;
  }

  void resetGame() {
    Map<String, String?> userAnswers = {};
    for (String question in state.questionAnswers.keys) {
      userAnswers[question] = null;
    }
    final availableWords = List<String>.from(state.availableWords);
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
  Future<void> initialize() async {}
}
