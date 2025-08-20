import 'package:equatable/equatable.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';
import 'package:local_game/data/model/level_model.dart';

class MapState extends Equatable {
  final BaseCubitState cubitState;
  final List<LevelModel> levels;

  const MapState({required this.cubitState, this.levels = const []});

  MapState copyWith({
    BaseCubitState? cubitState,
    List<LevelModel>? levels,
  }) {
    return MapState(
      cubitState: cubitState ?? this.cubitState,
      levels: levels ?? this.levels,
    );
  }

  @override
  List<Object?> get props => [cubitState, levels];
}
