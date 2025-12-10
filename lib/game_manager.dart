import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dev_cards/const.dart';
import 'package:dev_cards/game_card.dart';

class GameManager {
  static List<GameCard> allCardsMaster = [];
  static List<GameCard> userAlbum = [];
  static const String _albumKey = 'user_album_ids';
  static const String _langKey = 'user_language';
  static String currentLocale = 'en';

  static Future<void> initialize() async {
    if (allCardsMaster.isEmpty) {
      final List<dynamic> jsonList = json.decode(cardsJsonData);
      allCardsMaster = jsonList.map((json) => GameCard.fromJson(json)).toList();
    }

    // Load album & language
    final prefs = await SharedPreferences.getInstance();

    // Language
    currentLocale = prefs.getString(_langKey) ?? 'en';

    // Album
    final List<String>? savedIds = prefs.getStringList(_albumKey);

    if (savedIds != null) {
      userAlbum = savedIds.map((id) {
        // Find card by ID. If not found (e.g. removed), we might lose it or handle error.
        // For now, we fallback to first card or ignore.
        return allCardsMaster.firstWhere(
          (c) => c.id == id,
          orElse: () => allCardsMaster[0],
        );
      }).toList();
    }
  }

  static Future<void> addToAlbum(List<GameCard> newCards) async {
    userAlbum.addAll(newCards);
    await _saveAlbum();
  }

  static Future<void> setLocale(String code) async {
    currentLocale = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, code);
  }

  static Future<void> _saveAlbum() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> ids = userAlbum.map((c) => c.id).toList();
    await prefs.setStringList(_albumKey, ids);
  }
}
