import 'package:injectable/injectable.dart';
import 'package:local_game/core/base/cubit/base_cubit_wrapper.dart';
import 'package:local_game/data/dao/level_dao.dart';
import 'package:local_game/presentation/game/game_state.dart';

import '../../core/base/cubit/cubit_status.dart';

@injectable
class GameCubit extends BaseCubitWrapper<GameState> {
  final LevelDao _levelDao;

  GameCubit(this._levelDao) : super(GameState(cubitState: CubitInitial()));

  @override
  void dispose() {}

  @override
  Future<void> initialize() async {
    emit(state.copyWith(cubitState: CubitLoading()));
    try {
      
      emit(state.copyWith(cubitState: CubitSuccess(),));
    } catch (e) {
      emit(state.copyWith(cubitState: CubitError(message: e.toString())));
    }
  }
}
