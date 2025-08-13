import 'package:equatable/equatable.dart';
import 'package:local_game/core/base/cubit/cubit_status.dart';

class SplashState extends Equatable {
  final BaseCubitState cubitState;
  final bool isOnboarded;

  const SplashState({required this.cubitState, this.isOnboarded = false});

  SplashState copyWith({BaseCubitState? cubitState, bool? isOnboarded}) {
    return SplashState(
      cubitState: cubitState ?? this.cubitState,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }

  @override
  List<Object?> get props => [cubitState, isOnboarded];
}
