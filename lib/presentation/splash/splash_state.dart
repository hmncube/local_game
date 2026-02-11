import 'package:equatable/equatable.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';

class SplashState extends Equatable {
  final BaseCubitState cubitState;

  const SplashState({required this.cubitState});

  SplashState copyWith({BaseCubitState? cubitState}) {
    return SplashState(cubitState: cubitState ?? this.cubitState);
  }

  @override
  List<Object?> get props => [cubitState];
}
