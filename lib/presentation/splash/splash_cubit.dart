import 'package:injectable/injectable.dart';
import 'package:local_game/core/base/cubit/base_cubit_wrapper.dart';
import 'package:local_game/presentation/splash/splash_state.dart';

import '../../core/base/cubit/cubit_status.dart';
import '../../data/database_provider.dart';
import '../../data/local_provider.dart';

@injectable
class SplashCubit extends BaseCubitWrapper<SplashState> {
  final LocalProvider _localProvider;
  final DatabaseProvider _databaseProvider;

  SplashCubit(this._localProvider, this._databaseProvider)
      : super(SplashState(cubitState: CubitInitial())) {
    _init();
  }

  Future<void> _init() async {
    await _databaseProvider.database;
    final isUserOnboarded = await _localProvider.getIsUserOnboarded();
    emit(state.copyWith(isOnboarded: true));
  }

  @override
  void dispose() {}

  @override
  void initialize() {}
}
