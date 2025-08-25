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
  Future<void> initialize() async {}

  Future<void> init({int? level}) async {
    emit(state.copyWith(cubitState: CubitLoading()));
    await Future.delayed(Duration.zero);
    final words = ['MABHUKU', 'BHUKU', 'HUKU', 'UKU'];
    emit(
      state.copyWith(
        cubitState: CubitSuccess(),
        words: words,
        letters: words.expand((word) => word.split('')).toSet().toList(),
      ),
    );
  }
}
