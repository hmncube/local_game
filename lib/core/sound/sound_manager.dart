
import 'package:audioplayers/audioplayers.dart';
import 'package:injectable/injectable.dart';
import 'package:local_game/core/constants/app_assets.dart';

@lazySingleton
class SoundManager {
  final AudioPlayer _backgroundMusicPlayer = AudioPlayer();
  final AudioPlayer _soundEffectPlayer = AudioPlayer();

  Future<void> playBackgroundMusic() async {
    await _backgroundMusicPlayer.play(AssetSource(AppAssets.backgroundSound), volume: 0.5);
    _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> stopBackgroundMusic() async {
    await _backgroundMusicPlayer.stop();
  }

  Future<void> playCorrectAnswerSound() async {
    await _soundEffectPlayer.play(AssetSource(AppAssets.correctSfx));
  }

  Future<void> playWrongAnswerSound() async {
    await _soundEffectPlayer.play(AssetSource(AppAssets.wrongSfx));
  }
}
