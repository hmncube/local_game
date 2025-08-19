import 'package:equatable/equatable.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';

class MapState extends Equatable {
  final BaseCubitState cubitState;

  const MapState({required this.cubitState,});

  MapState copyWith({BaseCubitState? cubitState, bool? isOnboarded}) {
    return MapState(
      cubitState: cubitState ?? this.cubitState,
    );
  }

  @override
  List<Object?> get props => [cubitState,];
}
