import 'package:injectable/injectable.dart';
import 'package:local_game/data/model/game_save_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class SaveStateDao {
  static const String _wordSearchPrefix = 'word_search_save_';
  static const String _similarWordsPrefix = 'similar_words_save_';
  static const String _wordLinkPrefix = 'word_link_save_';

  Future<void> saveWordSearchState(WordSearchSaveState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_wordSearchPrefix}${state.levelId}',
      state.toJson(),
    );
  }

  Future<WordSearchSaveState?> loadWordSearchState(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('${_wordSearchPrefix}$levelId');
    if (json == null) return null;
    try {
      return WordSearchSaveState.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveSimilarWordsState(SimilarWordsSaveState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_similarWordsPrefix}${state.levelId}',
      state.toJson(),
    );
  }

  Future<SimilarWordsSaveState?> loadSimilarWordsState(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('${_similarWordsPrefix}$levelId');
    if (json == null) return null;
    try {
      return SimilarWordsSaveState.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveWordLinkState(WordLinkSaveState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_wordLinkPrefix}${state.levelId}', state.toJson());
  }

  Future<WordLinkSaveState?> loadWordLinkState(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('${_wordLinkPrefix}$levelId');
    if (json == null) return null;
    try {
      return WordLinkSaveState.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearState(int levelId, int gameType) async {
    final prefs = await SharedPreferences.getInstance();
    String? prefix;
    switch (gameType) {
      case 1:
        prefix = _wordSearchPrefix;
        break;
      case 2:
        prefix = _similarWordsPrefix;
        break;
      case 3:
        prefix = _wordLinkPrefix;
        break;
    }
    if (prefix != null) {
      await prefs.remove('${prefix}$levelId');
    }
  }
}
