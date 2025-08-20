import 'package:equatable/equatable.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';

class GameState extends Equatable {
  final BaseCubitState cubitState;
  final int level;

  const GameState({required this.cubitState, this.level = 0});

  GameState copyWith({
    BaseCubitState? cubitState,
    int? level,
  }) {
    return GameState(
      cubitState: cubitState ?? this.cubitState,
      level: level ?? this.level,
    );
  }

  @override
  List<Object?> get props => [cubitState, level];
}
