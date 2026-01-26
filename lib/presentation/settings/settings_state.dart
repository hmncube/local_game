import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final bool musicEnabled;
  final bool sfxEnabled;
  final double volume;

  const SettingsState({
    required this.musicEnabled,
    required this.sfxEnabled,
    required this.volume,
  });

  factory SettingsState.initial() {
    return const SettingsState(
      musicEnabled: true,
      sfxEnabled: true,
      volume: 0.5,
    );
  }

  SettingsState copyWith({
    bool? musicEnabled,
    bool? sfxEnabled,
    double? volume,
  }) {
    return SettingsState(
      musicEnabled: musicEnabled ?? this.musicEnabled,
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
      volume: volume ?? this.volume,
    );
  }

  @override
  List<Object?> get props => [musicEnabled, sfxEnabled, volume];
}
