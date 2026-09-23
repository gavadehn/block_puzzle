import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/block_shape.dart';
import '../models/high_score_entry.dart';

class HighScoreService extends ChangeNotifier {
  static final HighScoreService instance = HighScoreService._internal();

  factory HighScoreService() => instance;

  HighScoreService._internal() {
    loadScores();
  }

  static const String _legacyKey = 'top_10_high_scores';
  static const String _hardKey = 'top_10_high_scores_hard';
  static const String _easyKey = 'top_10_high_scores_easy';
  static const String _lastNameKey = 'last_player_name';
  static const int maxEntries = 10;

  List<HighScoreEntry> _hardScores = [];
  List<HighScoreEntry> _easyScores = [];
  String _lastPlayerName = 'Người chơi';
  bool _isLoaded = false;

  List<HighScoreEntry> get hardScores => List.unmodifiable(_hardScores);
  List<HighScoreEntry> get easyScores => List.unmodifiable(_easyScores);
  String get lastPlayerName => _lastPlayerName;
  bool get isLoaded => _isLoaded;

  List<HighScoreEntry> getTopScores(GameMode mode) =>
      mode == GameMode.hard ? hardScores : easyScores;

  int getHighestScore(GameMode mode) {
    final list = getTopScores(mode);
    return list.isNotEmpty ? list.first.score : 0;
  }

  /// Loads Top 10 scores for both Hard and Easy modes
  Future<void> loadScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastPlayerName = prefs.getString(_lastNameKey) ?? 'Người chơi';

      _hardScores = _loadList(prefs, _hardKey);
      _easyScores = _loadList(prefs, _easyKey);

      // Backward compatibility with legacy storage key
      if (_hardScores.isEmpty) {
        final legacy = _loadList(prefs, _legacyKey);
        if (legacy.isNotEmpty) {
          _hardScores = legacy;
          await _saveList(prefs, _hardKey, _hardScores);
        }
      }
    } catch (e) {
      debugPrint('HighScoreService loadScores error: $e');
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  List<HighScoreEntry> _loadList(SharedPreferences prefs, String key) {
    final jsonStringList = prefs.getStringList(key);
    if (jsonStringList == null) return [];

    final list = jsonStringList
        .map((item) {
          try {
            return HighScoreEntry.fromJson(jsonDecode(item) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<HighScoreEntry>()
        .toList();

    list.sort((a, b) => b.score.compareTo(a.score));
    return list.length > maxEntries ? list.sublist(0, maxEntries) : list;
  }

  Future<void> _saveList(SharedPreferences prefs, String key, List<HighScoreEntry> list) async {
    final jsonStringList = list.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(key, jsonStringList);
  }

  /// Checks if [score] qualifies for Top 10 in the specified [mode]
  bool isTop10Score(int score, GameMode mode) {
    if (score <= 0) return false;
    final list = getTopScores(mode);
    if (list.length < maxEntries) return true;
    return score > list.last.score;
  }

  /// Predicts the rank (1-10) for a given [score] in the specified [mode]
  int getRankForScore(int score, GameMode mode) {
    final list = getTopScores(mode);
    for (int i = 0; i < list.length; i++) {
      if (score >= list[i].score) {
        return i + 1;
      }
    }
    return (list.length < maxEntries) ? list.length + 1 : maxEntries;
  }

  /// Adds a new score with player name for [mode] and persists to storage
  Future<void> addScore(String name, int score, GameMode mode) async {
    final sanitizedName = name.trim().isEmpty ? 'Người chơi' : name.trim();
    _lastPlayerName = sanitizedName;

    final newEntry = HighScoreEntry(
      name: sanitizedName,
      score: score,
      date: DateTime.now(),
    );

    if (mode == GameMode.hard) {
      _hardScores.add(newEntry);
      _hardScores.sort((a, b) => b.score.compareTo(a.score));
      if (_hardScores.length > maxEntries) {
        _hardScores = _hardScores.sublist(0, maxEntries);
      }
    } else {
      _easyScores.add(newEntry);
      _easyScores.sort((a, b) => b.score.compareTo(a.score));
      if (_easyScores.length > maxEntries) {
        _easyScores = _easyScores.sublist(0, maxEntries);
      }
    }

    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastNameKey, sanitizedName);
      final key = mode == GameMode.hard ? _hardKey : _easyKey;
      final targetList = mode == GameMode.hard ? _hardScores : _easyScores;
      await _saveList(prefs, key, targetList);
    } catch (e) {
      debugPrint('HighScoreService saveScores error: $e');
    }
  }
}
