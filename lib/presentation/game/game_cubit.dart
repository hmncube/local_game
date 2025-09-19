import 'package:injectable/injectable.dart';
import 'package:local_game/core/base/cubit/base_cubit_wrapper.dart';
import 'package:local_game/core/sound/sound_manager.dart';
import 'package:local_game/data/dao/level_dao.dart';
import 'package:local_game/data/dao/user_dao.dart';
import 'package:local_game/presentation/game/game_state.dart';

import '../../core/base/cubit/cubit_status.dart';

@injectable
class GameCubit extends BaseCubitWrapper<GameState> {
  final LevelDao _levelDao;
  final UserDao _userDao;
  final SoundManager _soundManager;

  GameCubit(this._levelDao, this._userDao, this._soundManager)
    : super(GameState(cubitState: CubitInitial()));

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
      final words = levelModel.words.map((m) => m.word).toList();
      if (words.isNotEmpty) {
        emit(
          state.copyWith(
            cubitState: CubitSuccess(),
            level: levelId,
            words: words..sort((a, b) => a.length.compareTo(b.length)),
            hintsCount: user?.hints,
            points: user?.totalScore,
            levelModel: levelModel,
            filledWords: dashWords(words),
            letters: words.expand((word) => word.split('')).toSet().toList(),
          ),
        );
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

  List<String> dashWords(List<String> words) {
    String mask(String w) => List.filled(w.runes.length, '-').join();
    return words.map(mask).toList()
      ..sort((a, b) => a.length.compareTo(b.length));
  }

  void onCheckUserInput() {
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

      final points = _calculatePoints();

      bool isLevelComplete = handleCompleteLevel(newFilledWords, points);

      emit(
        state.copyWith(
          currentWord: [],
          filledWords: newFilledWords,
          isWordCorrect: true,
          points: isLevelComplete ? points + state.points : state.points,
          isLevelComplete: isLevelComplete,
          hint: '',
          hintWordIndex: -1,
        ),
      );
    } else {
        _soundManager.playWrongAnswerSound();
      emit(state.copyWith(currentWord: [state.hint], isWordWrong: true));
    }
  }

  void updateCurrentWord(String letter) {
    final word = state.currentWord;
    List<String> newWord = word + [letter];
    emit(state.copyWith(currentWord: newWord));
  }

  bool handleCompleteLevel(List<String> newFilledWords, int points) {
    bool isLevelComplete = newFilledWords.every((word) => !word.contains('-'));

    if (isLevelComplete) {
      final level = state.levelModel;
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

  int _calculatePoints() {
    final words = state.words;
    return words.fold(0, (total, word) => total + word.length);
  }

  void loadNextLevel() {
    init(level: state.level + 1);
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
    final points = _calculatePoints();

    final newFilledWords = filledWords..[firstWordIndex] = hintedWord;
    bool isLevelComplete = handleCompleteLevel(newFilledWords, points);
    emit(
      state.copyWith(
        hint: isWordComplete ? '' : newHint,
        hintWordIndex: isWordComplete ? -1 : firstWordIndex,
        filledWords: newFilledWords,
        currentWord: isWordComplete ? [] : [newHint],
        points: isLevelComplete ? points + state.points : state.points,
        isLevelComplete: isLevelComplete,
      ),
    );
  }
}
