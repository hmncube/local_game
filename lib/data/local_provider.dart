import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class LocalProvider {
  static const String _isUserOnboardedKey = 'isUserOnboarded';
  static const String _musicEnabledKey = 'musicEnabled';
  static const String _sfxEnabledKey = 'sfxEnabled';
  static const String _volumeKey = 'volume';

  Future<void> setIsUserOnboarded(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isUserOnboardedKey, value);
  }

  Future<bool> getIsUserOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isUserOnboardedKey) ?? false;
  }

  Future<void> setMusicEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_musicEnabledKey, value);
  }

  Future<bool> getMusicEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_musicEnabledKey) ?? true;
  }

  Future<void> setSfxEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sfxEnabledKey, value);
  }

  Future<bool> getSfxEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sfxEnabledKey) ?? true;
  }

  Future<void> setVolume(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, value);
  }

  Future<double> getVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_volumeKey) ?? 0.5;
  }
}
