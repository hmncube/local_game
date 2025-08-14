import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class LocalProvider {
  static const String _isUserOnboardedKey = 'isUserOnboarded';

  Future<void> setIsUserOnboarded(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isUserOnboardedKey, value);
  }

  Future<bool> getIsUserOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isUserOnboardedKey) ?? false;
  }
}
