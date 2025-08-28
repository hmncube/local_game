import 'package:injectable/injectable.dart';
import 'package:local_game/core/base/cubit/base_cubit_wrapper.dart';
import 'package:local_game/core/sound/sound_manager.dart';
import 'package:local_game/data/dao/level_dao.dart';
import 'package:local_game/data/dao/word_dao.dart';
import 'package:local_game/presentation/game/game_state.dart';

import '../../core/base/cubit/cubit_status.dart';

@injectable
class GameCubit extends BaseCubitWrapper<GameState> {
  final LevelDao _levelDao;
  final WordDao _wordDao;
  final SoundManager _soundManager;

  GameCubit(this._levelDao, this._wordDao, this._soundManager)
    : super(GameState(cubitState: CubitInitial()));

  @override
  void dispose() {}

  @override
  Future<void> initialize() async {}

  Future<void> init({int? level}) async {
    emit(state.copyWith(cubitState: CubitLoading()));

    final levelId = level ?? 1;
    final levelModel = await _levelDao.getLevelById(levelId);

    if (levelModel != null) {
      final words = levelModel.words.map((m) => m.word).toList();
      if (words.isNotEmpty) {
        emit(
          state.copyWith(
            cubitState: CubitSuccess(),
            words: words,
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

  void updateCurrentWord(String letter) {
    final word = state.currentWord;
    List<String> newWord = word + [letter];
    final nw = newWord.join('');

    if (state.filledWords.contains(nw)) {
      _soundManager.playWrongAnswerSound();
      emit(state.copyWith(currentWord: [], wasWordEnteredBefore: true));
      return;
    }

    if (state.words.contains(nw)) {
      _soundManager.playCorrectAnswerSound();
      List<String> newFilledWords = state.filledWords;
      final filledWords = state.filledWords;
      final filledWordIndex = filledWords.indexWhere(
        (word) => word.length == nw.length,
      );
      filledWords[filledWordIndex] = nw;
      newFilledWords = filledWords;
      newWord = [];

      bool isLevelComplete = newFilledWords.every(
        (word) => !word.contains('-'),
      );

      emit(
        state.copyWith(
          currentWord: newWord,
          filledWords: newFilledWords,
          isWordCorrect: true,
          isLevelComplete: isLevelComplete,
        ),
      );
    } else {
      final size = findLongestWord(state.words);
      bool isWordWrong = false;
      if (newWord.length == size) {
        _soundManager.playWrongAnswerSound();
        newWord = [];
        isWordWrong = true;
      }
      emit(state.copyWith(currentWord: newWord, isWordWrong: isWordWrong));
    }
  }

  int findLongestWord(List<String> words) {
    if (words.isEmpty) return 0;
    return words.reduce((a, b) => a.length >= b.length ? a : b).length;
  }

  void resetIsWordCorrect() {
    emit(state.copyWith(isWordCorrect: false));
  }

  void resetWasWordEnteredBefore() {
    emit(state.copyWith(wasWordEnteredBefore: false));
  }
}
