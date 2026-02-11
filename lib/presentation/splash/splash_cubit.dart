import 'package:injectable/injectable.dart';
import 'package:local_game/core/base/cubit/base_cubit_wrapper.dart';
import 'package:local_game/data/database_provider.dart';
import 'package:local_game/presentation/splash/splash_state.dart';

import '../../core/base/cubit/cubit_status.dart';
import 'package:local_game/data/model/user_model.dart';
import '../../data/dao/user_dao.dart';

@injectable
class SplashCubit extends BaseCubitWrapper<SplashState> {
  final UserDao _userDao;
  final DatabaseProvider _databaseProvider;

  SplashCubit(this._userDao, this._databaseProvider)
    : super(SplashState(cubitState: CubitInitial())) {
    _init();
  }

  Future<void> _init() async {
    await _databaseProvider.database;
    final user = await _userDao.getUser();
    if (user == null) {
      final defaultUser = UserModel(
        id: '1',
        username: 'Player 1',
        playerIconId: 1,
        preferredLanguage: '1',
        settings: {},
        createdAt: DateTime.now().millisecondsSinceEpoch,
        lastPlayed: 0,
        totalScore: 0,
        hints: 3,
      );
      await _userDao.insert(defaultUser);
    }
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(cubitState: CubitSuccess()));
  }

  @override
  void dispose() {}

  @override
  void initialize() {}
}
