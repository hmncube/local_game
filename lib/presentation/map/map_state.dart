import 'package:equatable/equatable.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';
import 'package:local_game/data/model/level_model.dart';
import 'package:local_game/data/model/user_model.dart';

class MapState extends Equatable {
  final BaseCubitState cubitState;
  final List<LevelModel> levels;
  final UserModel? userModel;

  const MapState({
    required this.cubitState,
    this.levels = const [],
    this.userModel,
  });

  MapState copyWith({
    BaseCubitState? cubitState,
    List<LevelModel>? levels,
    UserModel? userModel,
  }) {
    return MapState(
      cubitState: cubitState ?? this.cubitState,
      levels: levels ?? this.levels,
      userModel: userModel ?? this.userModel,
    );
  }

  @override
  List<Object?> get props => [cubitState, levels, userModel];
}
