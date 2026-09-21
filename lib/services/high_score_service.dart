import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/high_score_entry.dart';

class HighScoreService extends ChangeNotifier {
  static final HighScoreService instance = HighScoreService._internal();

  factory HighScoreService() => instance;

  HighScoreService._internal() {
    loadScores();
  }

  static const String _storageKey = 'top_10_high_scores';
  static const String _lastNameKey = 'last_player_name';
  static const int maxEntries = 10;

  List<HighScoreEntry> _topScores = [];
  String _lastPlayerName = 'Người chơi';
  bool _isLoaded = false;

  List<HighScoreEntry> get topScores => List.unmodifiable(_topScores);
  String get lastPlayerName => _lastPlayerName;
  bool get isLoaded => _isLoaded;

  int get highestScore => _topScores.isNotEmpty ? _topScores.first.score : 0;

  /// Loads Top 10 scores from SharedPreferences
  Future<void> loadScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastPlayerName = prefs.getString(_lastNameKey) ?? 'Người chơi';

      final jsonStringList = prefs.getStringList(_storageKey);
      if (jsonStringList != null) {
        _topScores = jsonStringList
            .map((item) {
              try {
                return HighScoreEntry.fromJson(jsonDecode(item) as Map<String, dynamic>);
              } catch (_) {
                return null;
              }
            })
            .whereType<HighScoreEntry>()
            .toList();

        _topScores.sort((a, b) => b.score.compareTo(a.score));
        if (_topScores.length > maxEntries) {
          _topScores = _topScores.sublist(0, maxEntries);
        }
      }
    } catch (e) {
      debugPrint('HighScoreService loadScores error: $e');
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// Checks if [score] qualifies to enter the Top 10
  bool isTop10Score(int score) {
    if (score <= 0) return false;
    if (_topScores.length < maxEntries) return true;
    return score > _topScores.last.score;
  }

  /// Predicts the rank (1-10) for a given [score]
  int getRankForScore(int score) {
    for (int i = 0; i < _topScores.length; i++) {
      if (score >= _topScores[i].score) {
        return i + 1;
      }
    }
    return (_topScores.length < maxEntries) ? _topScores.length + 1 : maxEntries;
  }

  /// Adds a new score with player name, saves persistently, and truncates to top 10
  Future<void> addScore(String name, int score) async {
    final sanitizedName = name.trim().isEmpty ? 'Người chơi' : name.trim();
    _lastPlayerName = sanitizedName;

    final newEntry = HighScoreEntry(
      name: sanitizedName,
      score: score,
      date: DateTime.now(),
    );

    _topScores.add(newEntry);
    _topScores.sort((a, b) => b.score.compareTo(a.score));
    if (_topScores.length > maxEntries) {
      _topScores = _topScores.sublist(0, maxEntries);
    }

    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastNameKey, sanitizedName);
      final jsonStringList = _topScores.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(_storageKey, jsonStringList);
    } catch (e) {
      debugPrint('HighScoreService saveScores error: $e');
    }
  }
}
