import 'package:injectable/injectable.dart';
import 'package:local_game/core/base/cubit/base_cubit_wrapper.dart';
import 'package:local_game/presentation/splash/splash_state.dart';

import '../../core/base/cubit/cubit_status.dart';
import '../../data/local_provider.dart';

@injectable
class MapCubit extends BaseCubitWrapper<SplashState> {
  MapCubit() : super(SplashState(cubitState: CubitInitial()));

  @override
  void dispose() {}

  @override
  void initialize() {}
}
