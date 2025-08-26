import 'package:injectable/injectable.dart';
import 'package:local_game/core/base/cubit/base_cubit_wrapper.dart';
import 'package:local_game/core/sound/sound_manager.dart';
import 'package:local_game/data/dao/level_dao.dart';
import 'package:local_game/presentation/game/game_state.dart';

import '../../core/base/cubit/cubit_status.dart';

@injectable
class GameCubit extends BaseCubitWrapper<GameState> {
  final LevelDao _levelDao;
  final SoundManager _soundManager;

  GameCubit(this._levelDao, this._soundManager)
      : super(GameState(cubitState: CubitInitial()));

  @override
  void dispose() {}

  @override
  Future<void> initialize() async {}

  Future<void> init({int? level}) async {
    emit(state.copyWith(cubitState: CubitLoading()));
    await Future.delayed(Duration.zero);
    final words = ['UKU', 'HUKU', 'BHUKU', 'MABHUKU'];

    emit(
      state.copyWith(
        cubitState: CubitSuccess(),
        words: words,
        filledWords: dashWords(words),
        letters: words.expand((word) => word.split('')).toSet().toList(),
      ),
    );
  }

  List<String> dashWords(List<String> words) {
    String mask(String w) => List.filled(w.runes.length, '-').join();
    return words.map(mask).toList();
  }

  void updateCurrentWord(String letter) {
    final word = state.currentWord;
    List<String> newWord = word + [letter];
    final nw = newWord.join('');

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
      emit(
        state.copyWith(
          currentWord: newWord,
          filledWords: newFilledWords,
          isWordCorrect: true,
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

  void resetIsWordCorrect(bool bool) {
    emit(state.copyWith(isWordCorrect: bool));
  }
}
