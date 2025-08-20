import 'package:injectable/injectable.dart';
import 'package:local_game/core/base/cubit/base_cubit_wrapper.dart';
import 'package:local_game/data/dao/level_dao.dart';
import 'package:local_game/presentation/map/map_state.dart';

import '../../core/base/cubit/cubit_status.dart';

@injectable
class MapCubit extends BaseCubitWrapper<MapState> {
  final LevelDao _levelDao;

  MapCubit(this._levelDao) : super(MapState(cubitState: CubitInitial()));

  @override
  void dispose() {}

  @override
  Future<void> initialize() async {
    emit(state.copyWith(cubitState: CubitLoading()));
    try {
      final levels = await _levelDao.getAllLevels();
      emit(state.copyWith(cubitState: CubitSuccess(), levels: levels));
    } catch (e) {
      emit(state.copyWith(cubitState: CubitError(message: e.toString())));
    }
  }
}
