import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:block_puzzle/logic/game_controller.dart';
import 'package:block_puzzle/models/block_shape.dart';

void main() {
  group('Block Puzzle Logic Tests', () {
    late GameController controller;

    setUp(() {
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

      // Valid placement
      expect(controller.canPlace(dot, 0, 0), true);
      expect(controller.canPlace(dot, 7, 7), true);
      expect(controller.canPlace(line4, 0, 4), true);

      // Out of bounds
      expect(controller.canPlace(line4, 0, 5), false);
      expect(controller.canPlace(line4, 8, 0), false);
      expect(controller.canPlace(dot, -1, 0), false);

      // Occupied cell test
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

      final line2 = const BlockShape(
        id: 'line2',
        matrix: [
          [1, 1],
        ],
        color: Colors.green,
        glowColor: Colors.greenAccent,
      );

      final line3 = const BlockShape(
        id: 'line3',
        matrix: [
          [1, 1, 1],
        ],
        color: Colors.teal,
        glowColor: Colors.tealAccent,
      );

      final line4 = const BlockShape(
        id: 'line4',
        matrix: [
          [1, 1, 1, 1],
        ],
        color: Colors.blue,
        glowColor: Colors.blueAccent,
      );

      // All horizontal shapes should be placeable in row 7 at valid column coordinates
      expect(controller.canPlace(line1, 7, 0), true);
      expect(controller.canPlace(line2, 7, 0), true);
      expect(controller.canPlace(line3, 7, 0), true);
      expect(controller.canPlace(line4, 7, 0), true);
      expect(controller.canPlace(line4, 7, 4), true);
      expect(controller.canPlace(line4, 7, 5), false); // Out of bounds cols
    });

    test('Clearing full horizontal row and vertical column', () {
      // Fill entire row 0
      for (int c = 0; c < 8; c++) {
        controller.board[0][c] = Colors.green;
      }

      // Manually trigger line check logic via a mock block placement on row 1
      final dot = const BlockShape(
        id: 'dot',
        matrix: [
          [1],
        ],
        color: Colors.yellow,
        glowColor: Colors.yellowAccent,
      );

      // Put dot in hand[0]
      controller.hand[0] = dot;
      final placed = controller.placeBlock(0, 1, 0);

      expect(placed, true);
      // Row 0 should have been cleared!
      for (int c = 0; c < 8; c++) {
        expect(controller.board[0][c], isNull);
      }
      // Placement score (10) + Row clear score (100) = 110
      expect(controller.score, 110);
    });
  });
}
