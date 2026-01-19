import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:local_game/core/base/cubit/base_cubit_wrapper.dart';
import 'package:local_game/core/constants/app_values.dart';
import 'package:local_game/core/game_system/points_management.dart';
import 'package:local_game/core/sound/sound_manager.dart';
import 'package:local_game/data/dao/level_dao.dart';
import 'package:local_game/data/dao/user_dao.dart';
import 'package:local_game/presentation/word_link/word_link_state.dart';

import '../../core/base/cubit/cubit_status.dart';

@injectable
class WordLinkCubit extends BaseCubitWrapper<WordLinkState> {
  final LevelDao _levelDao;
  final UserDao _userDao;
  final SoundManager _soundManager;

  WordLinkCubit(this._levelDao, this._userDao, this._soundManager)
    : super(WordLinkState(cubitState: CubitInitial()));

  @override
  void dispose() {}

  @override
  Future<void> initialize() async {}

  Future<void> init({int? level}) async {
    emit(state.copyWith(cubitState: CubitLoading()));

    final levelId = level ?? 1;
    final levelModel = await _levelDao.getLevelById(levelId);

    final user = await _userDao.getUser();
    if (levelModel != null) {
       final words =
        levelModel.languageId == 1
            ? levelModel.wordsEn
            : levelModel.languageId == 2
            ? levelModel.wordsSn
            : levelModel.wordsNd;

      if (words.isNotEmpty) {
        Map<String, int> letterCount = getMaxLetterCount(words);
        List<String> letterList = createLetterList(letterCount);
        emit(
          state.copyWith(
            cubitState: CubitSuccess(),
            words: words..sort((a, b) => a.length.compareTo(b.length)),
            hintsCount: user?.hints,
            userId: user?.id,
            totalPoints: user?.totalScore,
            level: levelModel,
            filledWords: dashWords(words),
            letters: letterList,
          ),
        );
        startGame();
      } else {
        emit(
          state.copyWith(
            cubitState: CubitError(
              message: 'No words found for level $levelId',
            ),
          ),
        );
      }
    } else {
      emit(
        state.copyWith(
          cubitState: CubitError(message: 'Level $levelId not found'),
        ),
      );
    }
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

  List<String> dashWords(List<String> words) {
    String mask(String w) => List.filled(w.runes.length, '-').join();
    return words.map(mask).toList()
      ..sort((a, b) => a.length.compareTo(b.length));
  }

  void onCheckUserInput() async {
    final word = state.currentWord;
    final nw = word.join('');
    if (state.filledWords.contains(nw.toLowerCase())) {
      _soundManager.playWrongAnswerSound();
      emit(state.copyWith(currentWord: [], wasWordEnteredBefore: true));
      return;
    }

    if (state.words.contains(nw.toLowerCase())) {
      _soundManager.playCorrectAnswerSound();
      List<String> newFilledWords = state.filledWords;
      final filledWords = state.filledWords;
      final filledWordIndex = filledWords.indexWhere(
        (word) => (word.length == nw.length) && word.contains('-'),
      );
      filledWords[filledWordIndex] = nw;
      newFilledWords = filledWords;

      final points = _calculatePoints(nw);
      _updatePoints(points);

      bool isLevelComplete = handleCompleteLevel(newFilledWords, points);
      int bonus = 0;
      if (isLevelComplete) {
        bonus = _calculateBonus(AppValues.timerTime - state.seconds);
        final newLevel = state.level?.copyWith(
          points: state.levelPoints,
          finishedAt: DateTime.now().millisecondsSinceEpoch,
          status: AppValues.levelDone,
        );
        await _levelDao.updateLevel(newLevel);
      }
      emit(
        state.copyWith(
          currentWord: [],
          filledWords: newFilledWords,
          isWordCorrect: true,
          totalPoints: points + state.totalPoints,
          levelPoints: state.levelPoints + points,
          isLevelComplete: isLevelComplete,
          hint: '',
          bonus: bonus,
          hintWordIndex: -1,
        ),
      );
    } else {
      _soundManager.playWrongAnswerSound();
      emit(state.copyWith(currentWord: [state.hint], isWordWrong: true));
    }
  }

  void _updatePoints(int points) {
    _userDao.updateTotalScore(state.userId, points + state.totalPoints);
  }

  void updateCurrentWord(String letter) {
    final word = state.currentWord;
    List<String> newWord = word + [letter];
    emit(state.copyWith(currentWord: newWord));
  }

  bool handleCompleteLevel(List<String> newFilledWords, int points) {
    bool isLevelComplete = newFilledWords.every((word) => !word.contains('-'));

    if (isLevelComplete) {
      final level = state.level;
      _levelDao.updateLevel(
        level?.copyWith(
          status: 1,
          points: points,
          finishedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      _userDao.getUser().then((user) {
        if (user != null) {
          _userDao.update(
            user.copyWith(
              totalScore: user.totalScore + points,
              // currentStreak: user.currentStreak + 1,
              // longestStreak: user.currentStreak + 1 > user.longestStreak
              //     ? user.currentStreak + 1
              //     : user.longestStreak,
              lastPlayed: DateTime.now().millisecondsSinceEpoch,
            ),
          );
        }
      });
    }
    return isLevelComplete;
  }

  int findLongestWord(List<String> words) {
    if (words.isEmpty) return 0;
    return words.reduce((a, b) => a.length >= b.length ? a : b).length;
  }

  void resetIsWordCorrect() {
    emit(state.copyWith(isWordCorrect: false));
  }

  void resetIsLevelCorrect() {
    emit(state.copyWith(isLevelComplete: false));
  }

  void resetWasWordEnteredBefore() {
    emit(state.copyWith(wasWordEnteredBefore: false));
  }

  int _calculatePoints(String word) {
    return PointsManagement.calculatePoints(word);
  }

  void loadNextLevel() {
    init(level: (state.level?.id ?? 0) + 1);
  }

  void showHint() {
    int firstWordIndex = 0;
    if (state.hint.isEmpty) {
      firstWordIndex = state.filledWords.indexWhere((w) => w.startsWith('-'));
    } else {
      firstWordIndex = state.hintWordIndex;
    }
    final hint =
        state.words[firstWordIndex].split('')[state.hint.length].toUpperCase();
    final newHint = '${state.hint}$hint'.trim();
    final filledWords = state.filledWords;
    final hintedWord = newHint.padRight(
      filledWords[firstWordIndex].length,
      '-',
    );
    final isWordComplete = !hintedWord.contains('-');
    final points = _calculatePoints(hintedWord);

    final newFilledWords = filledWords..[firstWordIndex] = hintedWord;
    bool isLevelComplete = handleCompleteLevel(newFilledWords, points);
    emit(
      state.copyWith(
        hint: isWordComplete ? '' : newHint,
        hintWordIndex: isWordComplete ? -1 : firstWordIndex,
        filledWords: newFilledWords,
        currentWord: isWordComplete ? [] : [newHint],
        totalPoints:
            isLevelComplete ? points + state.totalPoints : state.totalPoints,
        isLevelComplete: isLevelComplete,
      ),
    );
  }

  Map<String, int> getMaxLetterCount(List<String> words) {
    Map<String, int> maxCount = {};

    for (String word in words) {
      // Count letters in current word
      Map<String, int> wordCount = {};
      for (int i = 0; i < word.length; i++) {
        String letter = word[i].toLowerCase();
        wordCount[letter] = (wordCount[letter] ?? 0) + 1;
      }

      // Update max count
      wordCount.forEach((letter, count) {
        if (!maxCount.containsKey(letter) || count > maxCount[letter]!) {
          maxCount[letter] = count;
        }
      });
    }
    return maxCount;
  }

  List<String> createLetterList(Map<String, int> letterCount) {
    List<String> result = [];

    letterCount.forEach((letter, count) {
      for (int i = 0; i < count; i++) {
        result.add(letter);
      }
    });

    return result;
  }

  int _calculateBonus(int timeLeft) {
    return PointsManagement.calculateTimeLeftPoints(timeLeft: timeLeft);
  }
}
