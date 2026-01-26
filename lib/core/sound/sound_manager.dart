import 'package:audioplayers/audioplayers.dart';
import 'package:injectable/injectable.dart';
import 'package:local_game/core/constants/app_assets.dart';
import 'package:local_game/data/local_provider.dart';

@lazySingleton
class SoundManager {
  final AudioPlayer _backgroundMusicPlayer = AudioPlayer();
  final AudioPlayer _soundEffectPlayer = AudioPlayer();
  final LocalProvider _localProvider;

  SoundManager(this._localProvider);

  Future<void> playBackgroundMusic() async {
    final enabled = await _localProvider.getMusicEnabled();
    if (!enabled) return;

    final volume = await _localProvider.getVolume();
    await _backgroundMusicPlayer.play(
      AssetSource(AppAssets.backgroundSound),
      volume: volume,
    );
    _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> stopBackgroundMusic() async {
    await _backgroundMusicPlayer.stop();
  }

  Future<void> updateMusicSettings(bool enabled) async {
    if (enabled) {
      await playBackgroundMusic();
    } else {
      await stopBackgroundMusic();
    }
  }

  Future<void> updateVolume(double volume) async {
    await _backgroundMusicPlayer.setVolume(volume);
    await _soundEffectPlayer.setVolume(volume);
  }

  Future<void> playCorrectAnswerSound() async {
    final enabled = await _localProvider.getSfxEnabled();
    if (!enabled) return;

    final volume = await _localProvider.getVolume();
    await _soundEffectPlayer.play(
      AssetSource(AppAssets.correctSfx),
      volume: volume,
    );
  }

  Future<void> playWrongAnswerSound() async {
    final enabled = await _localProvider.getSfxEnabled();
    if (!enabled) return;

    final volume = await _localProvider.getVolume();
    await _soundEffectPlayer.play(
      AssetSource(AppAssets.wrongSfx),
      volume: volume,
    );
  }
}
