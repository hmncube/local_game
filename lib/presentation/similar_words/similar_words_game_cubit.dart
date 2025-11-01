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

  SimilarWordsGameCubit(this._levelDao, this._userDao)
    : super(SimilarWordsGameState(cubitState: CubitInitial()));

  @override
  void dispose() {}

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

  Future<void> onWordDropped(String questionWord, String droppedWord) async {
    Map<String, String?> userAnswers = Map.from(state.userAnswers);
    Set<String> usedWords = Set.from(state.usedWords);

    if (userAnswers[questionWord] != null) {
      usedWords.remove(userAnswers[questionWord]!);
    }

    // Set new answer
    userAnswers[questionWord] = droppedWord;
    final isGameComplete = userAnswers.values.every((value) => value != null);
    if (isGameComplete) {
      final newLevel = state.level?.copyWith(
        points: state.levelPoints,
        finishedAt: DateTime.now().millisecondsSinceEpoch,
        status: AppValues.levelDone,
      );
      await _levelDao.updateLevel(newLevel);
    }
    usedWords.add(droppedWord);
    int totalPoints = state.score;
    int levelPoints = state.levelPoints;
    if (isCorrectAnswer(questionWord, droppedWord)) {
      final newPoints = PointsManagement.calculatePoints(droppedWord);
      totalPoints = totalPoints + newPoints;
      levelPoints = levelPoints + newPoints;
      _userDao.updateTotalScore(state.userId, totalPoints);
    }
    emit(
      state.copyWith(
        usedWords: usedWords,
        userAnswers: userAnswers,
        score: totalPoints,
        levelPoints: levelPoints,
        isGameComplete: isGameComplete,
      ),
    );
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
