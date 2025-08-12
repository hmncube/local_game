import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_game/presentation/splash/splash_state.dart';

import '../../data/local_provider.dart';

class SplashCubit extends Cubit<SplashState> {
  final LocalProvider _localProvider;

  SplashCubit(this._localProvider) : super(const SplashState(isUserOnboarded: false)) {
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final isUserOnboarded = await _localProvider.getIsUserOnboarded();
    emit(state.copyWith(isUserOnboarded: isUserOnboarded));
  }
}
