import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _isEmployeurKey = 'isEmployeur';

  Future<void> setEmployeurStatus(bool isEmployeur) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isEmployeurKey, isEmployeur);
  }

  Future<bool> getEmployeurStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isEmployeurKey) ?? false;
  }
}
