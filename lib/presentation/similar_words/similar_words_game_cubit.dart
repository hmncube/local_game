import 'package:injectable/injectable.dart';
import 'package:local_game/core/base/cubit/base_cubit_wrapper.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';
import 'package:local_game/data/dao/word_dao.dart';
import 'package:local_game/presentation/similar_words/similar_words_game_state.dart';

@injectable
class SimilarWordsGameCubit extends BaseCubitWrapper<SimilarWordsGameState> {
  final WordDao _wordDao;
  SimilarWordsGameCubit(this._wordDao)
    : super(SimilarWordsGameState(cubitState: CubitInitial()));

  @override
  void dispose() {}

  @override
  Future<void> initialize() async {
    emit(state.copyWith(cubitState: CubitLoading()));
    final Map<String, String> questionAnswers = {
      'Happy': 'Joyful',
      'Big': 'Large',
      'Fast': 'Quick',
      'Smart': 'Intelligent',
    };

    List<String> availableWords = [
      'Joyful', 'Large', 'Quick', 'Intelligent', // Correct answers
      'Elephant', 'Purple', 'Swimming', // Random words
    ];

    Map<String, String?> userAnswers = {};
    for (String question in questionAnswers.keys) {
      userAnswers[question] = null;
    }
    // Shuffle the available words
    availableWords.shuffle();
  }

  void onWordDropped(String questionWord, String droppedWord) {
    final userAnswers = state.userAnswers;
    final usedWords = state.usedWords;

    if (userAnswers[questionWord] != null) {
      usedWords.remove(state.userAnswers[questionWord]!);
    }

    // Set new answer
    userAnswers[questionWord] = droppedWord;
    usedWords.add(droppedWord);

    emit(state.copyWith(usedWords: usedWords, userAnswers: userAnswers));
  }

  bool isCorrectAnswer(String question, String? answer) {
    return state.questionAnswers[question] == answer;
  }

  int _getScore() {
    int correct = 0;
    state.userAnswers.forEach((question, answer) {
      if (isCorrectAnswer(question, answer)) {
        correct++;
      }
    });
    return correct;
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
}
