import 'package:injectable/injectable.dart';
import 'package:local_game/core/base/cubit/base_cubit_wrapper.dart';
import 'package:local_game/data/dao/player_icon_dao.dart';
import 'package:local_game/data/dao/user_dao.dart';
import 'package:local_game/data/local_provider.dart';
import 'package:local_game/data/model/player_icon_model.dart';
import 'package:local_game/data/model/user_model.dart';
import 'package:local_game/presentation/onboarding/onboarding_state.dart';

import '../../core/base/cubit/cubit_status.dart';
import '../../data/database_provider.dart';

@injectable
class OnboardingCubit extends BaseCubitWrapper<OnboardingState> {
  final DatabaseProvider _databaseProvider;
  final LocalProvider _localProvider;
  final UserDao _userDao;
  final PlayerIconDao _playerIconDao;

  OnboardingCubit(
    this._playerIconDao,
    this._databaseProvider,
    this._userDao,
    this._localProvider,
  ) : super(
        OnboardingState(
          cubitState: CubitInitial(),
          playerIcons: const [],
          langauges: const [],
        ),
      ) {
    _init();
  }

  Future<void> _init() async {
    emit(state.copyWith(cubitState: CubitLoading()));
    await _databaseProvider.database;
    final playerIcons = await _playerIconDao.getAllPlayerIcons();
    emit(
      state.copyWith(
        playerIcons: playerIcons,
        langauges: Language.getAllLanguages(),
        cubitState: CubitSuccess(),
      ),
    );
  }

  Future<void> saveProfile() async {
    emit(state.copyWith(cubitState: CubitLoading()));
    if (!_checkIfCanProceed()) {
      return;
    }

    final user = UserModel(
      id: '1',
      username: state.nickname,
      playerIconId: state.selectedPlayerIcon?.id ?? 0,
      preferredLanguage:
          state.selectedLanguage?.map((lan) => lan.id).join(',') ?? '1',
      settings: {},
      createdAt: DateTime.now().millisecondsSinceEpoch,
      lastPlayed: 0,
      totalScore: 0,
      hints: 3,
    );
    await _userDao.insert(user);
    _localProvider.setIsUserOnboarded(true);
    emit(state.copyWith(cubitState: CubitSuccess(), navigateToMap: true));
  }

  @override
  void dispose() {}

  @override
  void initialize() {}

  void onIconSelected(PlayerIconModel playerIcon) {
    emit(
      state.copyWith(
        selectedPlayerIcon: playerIcon,
        canProceed: _checkIfCanProceed(),
      ),
    );
  }

  void onNicknameChanged(String text) {
    emit(state.copyWith(nickname: text, canProceed: _checkIfCanProceed()));
  }

  void onLanguageSelectedChanged(Language language) {
    List<Language> currentLaguages = List.from(state.selectedLanguage ?? []);
    if (currentLaguages.contains(language)) {
      currentLaguages.remove(language);
    } else {
      currentLaguages.add(language);
    }
    emit(
      state.copyWith(
        selectedLanguage: currentLaguages,
        canProceed: _checkIfCanProceed(),
      ),
    );
  }

  bool _checkIfCanProceed() {
    return state.nickname.isNotEmpty &&
        state.selectedPlayerIcon != null &&
        state.langauges.isNotEmpty;
  }
}
