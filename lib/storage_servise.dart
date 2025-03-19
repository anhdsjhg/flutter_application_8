import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<int> loadScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('player_score') ?? 0;
  }

  static Future<void> saveScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('player_score', score);
  }
}
