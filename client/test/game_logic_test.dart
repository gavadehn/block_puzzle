import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:block_puzzle/logic/game_controller.dart';
import 'package:block_puzzle/models/block_shape.dart';
import 'package:block_puzzle/services/audio_manager.dart';
import 'package:block_puzzle/services/high_score_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  AudioManager.enableAudio = false;

  group('Block Puzzle Logic Tests', () {
    late GameController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await HighScoreService.instance.loadScores();
      controller = GameController();
    });

    test('Initial board is empty (8x8)', () {
      expect(controller.board.length, 8);
      for (var row in controller.board) {
        expect(row.length, 8);
        for (var cell in row) {
          expect(cell, isNull);
        }
      }
      expect(controller.score, 0);
      expect(controller.isGameOver, false);
      expect(controller.hand.length, 3);
    });

    test('Matrix 90-degree rotation Clockwise and Counter-Clockwise', () {
      final line3v = const BlockShape(
        id: 'line_3v',
        matrix: [
          [1],
          [1],
          [1],
        ],
        color: Colors.blue,
        glowColor: Colors.blueAccent,
      );

      final line3h = line3v.rotateClockwise();
      expect(line3h.rows, 1);
      expect(line3h.cols, 3);
      expect(line3h.matrix, [
        [1, 1, 1],
      ]);

      final line3vAgain = line3h.rotateCounterClockwise();
      expect(line3vAgain.rows, 3);
      expect(line3vAgain.cols, 1);
      expect(line3vAgain.matrix, [
        [1],
        [1],
        [1],
      ]);
    });

    test('Easy mode block selection and rotation', () {
      controller.setGameMode(GameMode.easy);
      expect(controller.mode, GameMode.easy);

      final line3v = const BlockShape(
        id: 'line_3v',
        matrix: [
          [1],
          [1],
          [1],
        ],
        color: Colors.blue,
        glowColor: Colors.blueAccent,
      );

      controller.hand[0] = line3v;
      controller.selectHandBlock(0);
      expect(controller.selectedHandIndex, 0);

      controller.rotateSelectedBlockRight();
      expect(controller.hand[0]!.rows, 1);
      expect(controller.hand[0]!.cols, 3);

      controller.rotateSelectedBlockLeft();
      expect(controller.hand[0]!.rows, 3);
      expect(controller.hand[0]!.cols, 1);
    });

    test('canPlace correctly checks boundaries and occupancy', () {
      final dot = const BlockShape(
        id: 'dot',
        matrix: [
          [1],
        ],
        color: Colors.red,
        glowColor: Colors.redAccent,
      );

      final line4 = const BlockShape(
        id: 'line4',
        matrix: [
          [1, 1, 1, 1],
        ],
        color: Colors.blue,
        glowColor: Colors.blueAccent,
      );

      expect(controller.canPlace(dot, 0, 0), true);
      expect(controller.canPlace(dot, 7, 7), true);
      expect(controller.canPlace(line4, 0, 4), true);

      expect(controller.canPlace(line4, 0, 5), false);
      expect(controller.canPlace(line4, 8, 0), false);
      expect(controller.canPlace(dot, -1, 0), false);

      controller.board[0][0] = Colors.red;
      expect(controller.canPlace(dot, 0, 0), false);
      expect(controller.canPlace(line4, 0, 0), false);
      expect(controller.canPlace(line4, 1, 0), true);
    });

    test('Placing horizontal shapes (1x1, 1x2, 1x3, 1x4, 1x5) into row 7 (last row)', () {
      final line1 = const BlockShape(
        id: 'line1',
        matrix: [
          [1],
        ],
        color: Colors.yellow,
        glowColor: Colors.yellowAccent,
      );

      final line4 = const BlockShape(
        id: 'line4',
        matrix: [
          [1, 1, 1, 1],
        ],
        color: Colors.blue,
        glowColor: Colors.blueAccent,
      );

      expect(controller.canPlace(line1, 7, 0), true);
      expect(controller.canPlace(line4, 7, 0), true);
      expect(controller.canPlace(line4, 7, 4), true);
      expect(controller.canPlace(line4, 7, 5), false);
    });

    test('Clearing full horizontal row and vertical column', () {
      for (int c = 0; c < 8; c++) {
        controller.board[0][c] = Colors.green;
      }

      final dot = const BlockShape(
        id: 'dot',
        matrix: [
          [1],
        ],
        color: Colors.yellow,
        glowColor: Colors.yellowAccent,
      );

      controller.hand[0] = dot;
      final placed = controller.placeBlock(0, 1, 0);

      expect(placed, true);
      for (int c = 0; c < 8; c++) {
        expect(controller.board[0][c], isNull);
      }
      expect(controller.score, 110);
    });

    test('High score is mode-specific and separates Hard and Easy modes', () async {
      await HighScoreService.instance.addScore('Hard Pro', 3000, GameMode.hard);

      controller.setGameMode(GameMode.hard);
      expect(controller.highScore, 3000);

      controller.setGameMode(GameMode.easy);
      expect(controller.highScore, 0);
    });
  });
}
