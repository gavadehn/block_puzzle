import 'dart:math';
import 'package:flutter/material.dart';
import '../models/block_shape.dart';
import '../services/audio_manager.dart';

class ClearedLineInfo {
  final List<int> rows;
  final List<int> cols;
  final int pointsEarned;
  final int combo;

  ClearedLineInfo({
    required this.rows,
    required this.cols,
    required this.pointsEarned,
    required this.combo,
  });

  bool get hasClear => rows.isNotEmpty || cols.isNotEmpty;
}

class GameController extends ChangeNotifier {
  static const int boardSize = 8;

  // 8x8 Board: null means empty cell, Color means occupied
  late List<List<Color?>> _board;
  // 3 slots for candidate shapes
  late List<BlockShape?> _hand;

  int _score = 0;
  int _highScore = 0;
  int _comboStreak = 0;
  bool _isGameOver = false;
  bool _hasCelebratedRecord = false;

  // Cells currently undergoing clearing animation
  final Set<String> _clearingCells = {};

  // Getters
  List<List<Color?>> get board => _board;
  List<BlockShape?> get hand => _hand;
  int get score => _score;
  int get highScore => _highScore;
  int get comboStreak => _comboStreak;
  bool get isGameOver => _isGameOver;
  Set<String> get clearingCells => _clearingCells;

  final Random _random = Random();

  GameController() {
    startNewGame();
  }

  void startNewGame() {
    _board = List.generate(boardSize, (_) => List.filled(boardSize, null));
    _hand = [null, null, null];
    _score = 0;
    _comboStreak = 0;
    _isGameOver = false;
    _hasCelebratedRecord = false;
    _clearingCells.clear();
    _spawnHand();
    notifyListeners();
  }

  void _spawnHand() {
    for (int i = 0; i < 3; i++) {
      _hand[i] = _getRandomShape();
    }
  }

  BlockShape _getRandomShape() {
    final list = ShapeCatalog.allShapes;
    return list[_random.nextInt(list.length)];
  }

  /// Checks if a shape can be placed at (targetRow, targetCol)
  bool canPlace(BlockShape shape, int targetRow, int targetCol) {
    if (targetRow < 0 || targetCol < 0) return false;
    if (targetRow + shape.rows > boardSize) return false;
    if (targetCol + shape.cols > boardSize) return false;

    for (int r = 0; r < shape.rows; r++) {
      for (int c = 0; c < shape.cols; c++) {
        if (shape.matrix[r][c] == 1) {
          int boardR = targetRow + r;
          int boardC = targetCol + c;
          if (_board[boardR][boardC] != null) {
            return false;
          }
        }
      }
    }
    return true;
  }

  /// Checks if a shape can fit anywhere on the current board
  bool canPlaceAnywhere(BlockShape shape) {
    for (int r = 0; r <= boardSize - shape.rows; r++) {
      for (int c = 0; c <= boardSize - shape.cols; c++) {
        if (canPlace(shape, r, c)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Places a block from hand slot [handIndex] to (targetRow, targetCol)
  bool placeBlock(int handIndex, int targetRow, int targetCol) {
    if (handIndex < 0 || handIndex >= 3) return false;
    final shape = _hand[handIndex];
    if (shape == null) return false;

    if (!canPlace(shape, targetRow, targetCol)) {
      return false;
    }

    final prevHighScore = _highScore;

    // 1. Place shape on board
    for (int r = 0; r < shape.rows; r++) {
      for (int c = 0; c < shape.cols; c++) {
        if (shape.matrix[r][c] == 1) {
          _board[targetRow + r][targetCol + c] = shape.color;
        }
      }
    }

    // 2. Consume shape from hand
    _hand[handIndex] = null;

    // 3. Add placement points (10 points per tile)
    _score += shape.tileCount * 10;

    // 4. Check & Clear full rows and columns
    final clearInfo = _checkAndClearLines();
    if (clearInfo.hasClear) {
      _score += clearInfo.pointsEarned;
      _comboStreak++;
      // Play line clear audio
      AudioManager.instance.playClear();
    } else {
      _comboStreak = 0;
      // Play block drop audio
      AudioManager.instance.playDrop();
    }

    // 5. Update High Score and trigger new record fanfare
    if (_score > _highScore) {
      _highScore = _score;
      if (prevHighScore > 0 && !_hasCelebratedRecord) {
        _hasCelebratedRecord = true;
        AudioManager.instance.playNewRecord();
      }
    }

    // 6. Refill hand if all 3 used
    if (_hand.every((s) => s == null)) {
      _spawnHand();
    }

    // 7. Check Game Over
    _checkGameOver();

    notifyListeners();
    return true;
  }

  ClearedLineInfo _checkAndClearLines() {
    List<int> fullRows = [];
    List<int> fullCols = [];

    // Scan rows
    for (int r = 0; r < boardSize; r++) {
      bool isFull = true;
      for (int c = 0; c < boardSize; c++) {
        if (_board[r][c] == null) {
          isFull = false;
          break;
        }
      }
      if (isFull) fullRows.add(r);
    }

    // Scan columns
    for (int c = 0; c < boardSize; c++) {
      bool isFull = true;
      for (int r = 0; r < boardSize; r++) {
        if (_board[r][c] == null) {
          isFull = false;
          break;
        }
      }
      if (isFull) fullCols.add(c);
    }

    int linesCleared = fullRows.length + fullCols.length;
    int pointsEarned = 0;

    if (linesCleared > 0) {
      // Clear rows
      for (int r in fullRows) {
        for (int c = 0; c < boardSize; c++) {
          _board[r][c] = null;
        }
      }

      // Clear columns
      for (int c in fullCols) {
        for (int r = 0; r < boardSize; r++) {
          _board[r][c] = null;
        }
      }

      int baseScore = linesCleared * 100;
      int multiBonus = (linesCleared > 1) ? (linesCleared * (linesCleared - 1) * 50) : 0;
      int comboBonus = _comboStreak * 50;

      pointsEarned = baseScore + multiBonus + comboBonus;
    }

    return ClearedLineInfo(
      rows: fullRows,
      cols: fullCols,
      pointsEarned: pointsEarned,
      combo: _comboStreak + (linesCleared > 0 ? 1 : 0),
    );
  }

  void _checkGameOver() {
    bool hasValidMove = false;
    for (final shape in _hand) {
      if (shape != null && canPlaceAnywhere(shape)) {
        hasValidMove = true;
        break;
      }
    }

    if (!hasValidMove) {
      _isGameOver = true;
    }
  }
}
