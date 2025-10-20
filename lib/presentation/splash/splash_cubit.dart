import 'package:injectable/injectable.dart';
import 'package:local_game/core/base/cubit/base_cubit_wrapper.dart';
import 'package:local_game/presentation/splash/splash_state.dart';

import '../../core/base/cubit/cubit_status.dart';
import '../../data/local_provider.dart';

@injectable
class SplashCubit extends BaseCubitWrapper<SplashState> {
  final LocalProvider _localProvider;
  SplashCubit(this._localProvider, )
    : super(SplashState(cubitState: CubitInitial())) {
    _init();
  }

  Future<void> _init() async {
    final isUserOnboarded = await _localProvider.getIsUserOnboarded();
    await Future.delayed(Duration(seconds: 2));
    emit(state.copyWith(isOnboarded: isUserOnboarded));
  }

  @override
  void dispose() {}

  @override
  void initialize() {}
}
