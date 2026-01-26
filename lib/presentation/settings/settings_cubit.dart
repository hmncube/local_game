import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:local_game/core/sound/sound_manager.dart';
import 'package:local_game/data/local_provider.dart';
import 'package:local_game/presentation/settings/settings_state.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final LocalProvider _localProvider;
  final SoundManager _soundManager;

  SettingsCubit(this._localProvider, this._soundManager)
    : super(SettingsState.initial()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final musicEnabled = await _localProvider.getMusicEnabled();
    final sfxEnabled = await _localProvider.getSfxEnabled();
    final volume = await _localProvider.getVolume();

    emit(
      state.copyWith(
        musicEnabled: musicEnabled,
        sfxEnabled: sfxEnabled,
        volume: volume,
      ),
    );
  }

  Future<void> toggleMusic(bool enabled) async {
    await _localProvider.setMusicEnabled(enabled);
    await _soundManager.updateMusicSettings(enabled);
    emit(state.copyWith(musicEnabled: enabled));
  }

  Future<void> toggleSfx(bool enabled) async {
    await _localProvider.setSfxEnabled(enabled);
    emit(state.copyWith(sfxEnabled: enabled));
  }

  Future<void> setVolume(double volume) async {
    await _localProvider.setVolume(volume);
    await _soundManager.updateVolume(volume);
    emit(state.copyWith(volume: volume));
  }
}
