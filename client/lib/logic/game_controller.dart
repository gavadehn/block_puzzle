import 'dart:math';
import 'package:flutter/material.dart';
import '../models/block_shape.dart';
import '../services/audio_manager.dart';
import '../services/high_score_service.dart';

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

  GameMode _mode = GameMode.hard;
  // 8x8 Board: null means empty cell, Color means occupied
  late List<List<Color?>> _board;
  // 3 slots for candidate shapes
  late List<BlockShape?> _hand;

  int? _selectedHandIndex;
  int _score = 0;
  int _comboStreak = 0;
  bool _isGameOver = false;

  final Set<String> _clearingCells = {};
  final Random _random = Random();

  // Getters
  GameMode get mode => _mode;
  List<List<Color?>> get board => _board;
  List<BlockShape?> get hand => _hand;
  int? get selectedHandIndex => _selectedHandIndex;
  int get score => _score;
  int get highScore => max(_score, HighScoreService.instance.getHighestScore(_mode));
  int get comboStreak => _comboStreak;
  bool get isGameOver => _isGameOver;
  Set<String> get clearingCells => _clearingCells;

  GameController({GameMode initialMode = GameMode.hard}) {
    _mode = initialMode;
    startNewGame();
  }

  void setGameMode(GameMode newMode) {
    if (_mode == newMode) return;
    _mode = newMode;
    _selectedHandIndex = null;
    startNewGame();
  }

  void startNewGame() {
    _board = List.generate(boardSize, (_) => List.filled(boardSize, null));
    _hand = [null, null, null];
    _selectedHandIndex = null;
    _score = 0;
    _comboStreak = 0;
    _isGameOver = false;
    _clearingCells.clear();
    _spawnHand();
    notifyListeners();
  }

  void _spawnHand() {
    for (int i = 0; i < 3; i++) {
      _hand[i] = _getRandomShape();
    }
    _selectedHandIndex = null;
  }

  BlockShape _getRandomShape() {
    final list = ShapeCatalog.allShapes;
    return list[_random.nextInt(list.length)];
  }

  /// Selects a block in hand for rotation (only active in Easy mode)
  void selectHandBlock(int? index) {
    if (_mode != GameMode.easy) return;
    if (index != null && (index < 0 || index >= 3 || _hand[index] == null)) {
      _selectedHandIndex = null;
    } else {
      _selectedHandIndex = (_selectedHandIndex == index) ? null : index;
    }
    notifyListeners();
  }

  /// Rotates the currently selected block Counter-Clockwise (Left)
  void rotateSelectedBlockLeft() {
    if (_mode != GameMode.easy || _selectedHandIndex == null) return;
    final shape = _hand[_selectedHandIndex!];
    if (shape == null) return;

    _hand[_selectedHandIndex!] = shape.rotateCounterClockwise();
    AudioManager.instance.playDrop();
    _checkGameOver();
    notifyListeners();
  }

  /// Rotates the currently selected block Clockwise (Right)
  void rotateSelectedBlockRight() {
    if (_mode != GameMode.easy || _selectedHandIndex == null) return;
    final shape = _hand[_selectedHandIndex!];
    if (shape == null) return;

    _hand[_selectedHandIndex!] = shape.rotateClockwise();
    AudioManager.instance.playDrop();
    _checkGameOver();
    notifyListeners();
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

  /// Checks if a shape can fit anywhere on current board (considering rotation if in Easy mode)
  bool canPlaceAnywhere(BlockShape shape) {
    if (_mode == GameMode.easy) {
      // Check 4 orientations
      BlockShape s = shape;
      for (int rot = 0; rot < 4; rot++) {
        for (int r = 0; r <= boardSize - s.rows; r++) {
          for (int c = 0; c <= boardSize - s.cols; c++) {
            if (canPlace(s, r, c)) return true;
          }
        }
        s = s.rotateClockwise();
      }
      return false;
    } else {
      // Hard mode: exact orientation only
      for (int r = 0; r <= boardSize - shape.rows; r++) {
        for (int c = 0; c <= boardSize - shape.cols; c++) {
          if (canPlace(shape, r, c)) return true;
        }
      }
      return false;
    }
  }

  /// Places a block from hand slot [handIndex] to (targetRow, targetCol)
  bool placeBlock(int handIndex, int targetRow, int targetCol) {
    if (handIndex < 0 || handIndex >= 3) return false;
    final shape = _hand[handIndex];
    if (shape == null) return false;

    if (!canPlace(shape, targetRow, targetCol)) {
      return false;
    }

    // 1. Place shape on board
    for (int r = 0; r < shape.rows; r++) {
      for (int c = 0; c < shape.cols; c++) {
        if (shape.matrix[r][c] == 1) {
          _board[targetRow + r][targetCol + c] = shape.color;
        }
      }
    }

    // 2. Consume shape from hand and deselect
    _hand[handIndex] = null;
    if (_selectedHandIndex == handIndex) {
      _selectedHandIndex = null;
    }

    // 3. Add placement points (10 points per tile)
    _score += shape.tileCount * 10;

    // 4. Check & Clear full rows and columns
    final clearInfo = _checkAndClearLines();
    if (clearInfo.hasClear) {
      _score += clearInfo.pointsEarned;
      _comboStreak++;
      AudioManager.instance.playClear();
    } else {
      _comboStreak = 0;
      AudioManager.instance.playDrop();
    }

    // 5. Refill hand if all 3 used
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
      for (int r in fullRows) {
        for (int c = 0; c < boardSize; c++) {
          _board[r][c] = null;
        }
      }

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
