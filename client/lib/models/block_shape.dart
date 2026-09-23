import 'package:flutter/material.dart';

enum GameMode {
  hard, // Chế độ khó: Cổ điển, không xoay
  easy, // Chế độ dễ: Cho phép xoay hình
}

extension GameModeExtension on GameMode {
  String get displayName => this == GameMode.hard ? 'Khó' : 'Dễ';
  String get description => this == GameMode.hard ? 'Cố định không xoay' : 'Cho phép xoay hình';
  String get storageKey => this == GameMode.hard ? 'top_10_high_scores_hard' : 'top_10_high_scores_easy';
}

class BlockShape {
  final String id;
  final List<List<int>> matrix;
  final Color color;
  final Color glowColor;

  const BlockShape({
    required this.id,
    required this.matrix,
    required this.color,
    required this.glowColor,
  });

  int get rows => matrix.length;
  int get cols => matrix[0].length;

  int get tileCount {
    int count = 0;
    for (var r in matrix) {
      for (var cell in r) {
        if (cell == 1) count++;
      }
    }
    return count;
  }

  /// Rotates the shape matrix 90 degrees Clockwise
  BlockShape rotateClockwise() {
    final r = rows;
    final c = cols;
    final newMatrix = List.generate(c, (newR) {
      return List.generate(r, (newC) {
        return matrix[r - 1 - newC][newR];
      });
    });
    return BlockShape(
      id: '${id}_cw',
      matrix: newMatrix,
      color: color,
      glowColor: glowColor,
    );
  }

  /// Rotates the shape matrix 90 degrees Counter-Clockwise
  BlockShape rotateCounterClockwise() {
    final r = rows;
    final c = cols;
    final newMatrix = List.generate(c, (newR) {
      return List.generate(r, (newC) {
        return matrix[newC][c - 1 - newR];
      });
    });
    return BlockShape(
      id: '${id}_ccw',
      matrix: newMatrix,
      color: color,
      glowColor: glowColor,
    );
  }
}

class ShapeCatalog {
  static const List<BlockShape> allShapes = [
    // 1x1 Dot
    BlockShape(
      id: 'dot_1x1',
      matrix: [
        [1],
      ],
      color: Color(0xFFFFB703),
      glowColor: Color(0xFFFFD166),
    ),
    // 2x1 & 1x2 Horizontal & Vertical
    BlockShape(
      id: 'line_2x1_h',
      matrix: [
        [1, 1],
      ],
      color: Color(0xFF06D6A0),
      glowColor: Color(0xFF70F8D2),
    ),
    BlockShape(
      id: 'line_1x2_v',
      matrix: [
        [1],
        [1],
      ],
      color: Color(0xFF06D6A0),
      glowColor: Color(0xFF70F8D2),
    ),
    // 3x1 & 1x3
    BlockShape(
      id: 'line_3x1_h',
      matrix: [
        [1, 1, 1],
      ],
      color: Color(0xFF118AB2),
      glowColor: Color(0xFF56CCF2),
    ),
    BlockShape(
      id: 'line_1x3_v',
      matrix: [
        [1],
        [1],
        [1],
      ],
      color: Color(0xFF118AB2),
      glowColor: Color(0xFF56CCF2),
    ),
    // 4x1 & 1x4
    BlockShape(
      id: 'line_4x1_h',
      matrix: [
        [1, 1, 1, 1],
      ],
      color: Color(0xFF4361EE),
      glowColor: Color(0xFF8338EC),
    ),
    BlockShape(
      id: 'line_1x4_v',
      matrix: [
        [1],
        [1],
        [1],
        [1],
      ],
      color: Color(0xFF4361EE),
      glowColor: Color(0xFF8338EC),
    ),
    // 5x1 & 1x5
    BlockShape(
      id: 'line_5x1_h',
      matrix: [
        [1, 1, 1, 1, 1],
      ],
      color: Color(0xFF7209B7),
      glowColor: Color(0xFFB5179E),
    ),
    BlockShape(
      id: 'line_1x5_v',
      matrix: [
        [1],
        [1],
        [1],
        [1],
        [1],
      ],
      color: Color(0xFF7209B7),
      glowColor: Color(0xFFB5179E),
    ),
    // 2x2 Square
    BlockShape(
      id: 'square_2x2',
      matrix: [
        [1, 1],
        [1, 1],
      ],
      color: Color(0xFFEF476F),
      glowColor: Color(0xFFFF758F),
    ),
    // 3x3 Square
    BlockShape(
      id: 'square_3x3',
      matrix: [
        [1, 1, 1],
        [1, 1, 1],
        [1, 1, 1],
      ],
      color: Color(0xFFD90429),
      glowColor: Color(0xFFFF4D6D),
    ),
    // 2x2 Small Ls (Corner shapes - 3 ô)
    BlockShape(
      id: 'corner_2x2_1',
      matrix: [
        [1, 1],
        [1, 0],
      ],
      color: Color(0xFFF77F00),
      glowColor: Color(0xFFFCBF49),
    ),
    BlockShape(
      id: 'corner_2x2_2',
      matrix: [
        [1, 1],
        [0, 1],
      ],
      color: Color(0xFFF77F00),
      glowColor: Color(0xFFFCBF49),
    ),
    BlockShape(
      id: 'corner_2x2_3',
      matrix: [
        [1, 0],
        [1, 1],
      ],
      color: Color(0xFFF77F00),
      glowColor: Color(0xFFFCBF49),
    ),
    BlockShape(
      id: 'corner_2x2_4',
      matrix: [
        [0, 1],
        [1, 1],
      ],
      color: Color(0xFFF77F00),
      glowColor: Color(0xFFFCBF49),
    ),
    // 3x2 & 2x3 Classic L-shapes (4 ô)
    BlockShape(
      id: 'l_3x2_down_right',
      matrix: [
        [1, 0],
        [1, 0],
        [1, 1],
      ],
      color: Color(0xFFFF9E00),
      glowColor: Color(0xFFFFD000),
    ),
    BlockShape(
      id: 'l_3x2_down_left',
      matrix: [
        [0, 1],
        [0, 1],
        [1, 1],
      ],
      color: Color(0xFFFF9E00),
      glowColor: Color(0xFFFFD000),
    ),
    BlockShape(
      id: 'l_3x2_up_right',
      matrix: [
        [1, 1],
        [1, 0],
        [1, 0],
      ],
      color: Color(0xFFFF9E00),
      glowColor: Color(0xFFFFD000),
    ),
    BlockShape(
      id: 'l_3x2_up_left',
      matrix: [
        [1, 1],
        [0, 1],
        [0, 1],
      ],
      color: Color(0xFFFF9E00),
      glowColor: Color(0xFFFFD000),
    ),
    BlockShape(
      id: 'l_2x3_top_right',
      matrix: [
        [1, 1, 1],
        [1, 0, 0],
      ],
      color: Color(0xFFFF6B6B),
      glowColor: Color(0xFFFF8E8E),
    ),
    BlockShape(
      id: 'l_2x3_top_left',
      matrix: [
        [1, 1, 1],
        [0, 0, 1],
      ],
      color: Color(0xFFFF6B6B),
      glowColor: Color(0xFFFF8E8E),
    ),
    BlockShape(
      id: 'l_2x3_bottom_right',
      matrix: [
        [1, 0, 0],
        [1, 1, 1],
      ],
      color: Color(0xFFFF6B6B),
      glowColor: Color(0xFFFF8E8E),
    ),
    BlockShape(
      id: 'l_2x3_bottom_left',
      matrix: [
        [0, 0, 1],
        [1, 1, 1],
      ],
      color: Color(0xFFFF6B6B),
      glowColor: Color(0xFFFF8E8E),
    ),
    // 3x3 Large Ls (5 ô)
    BlockShape(
      id: 'corner_3x3_1',
      matrix: [
        [1, 0, 0],
        [1, 0, 0],
        [1, 1, 1],
      ],
      color: Color(0xFF3A86FF),
      glowColor: Color(0xFF80B3FF),
    ),
    BlockShape(
      id: 'corner_3x3_2',
      matrix: [
        [0, 0, 1],
        [0, 0, 1],
        [1, 1, 1],
      ],
      color: Color(0xFF3A86FF),
      glowColor: Color(0xFF80B3FF),
    ),
    BlockShape(
      id: 'corner_3x3_3',
      matrix: [
        [1, 1, 1],
        [1, 0, 0],
        [1, 0, 0],
      ],
      color: Color(0xFF3A86FF),
      glowColor: Color(0xFF80B3FF),
    ),
    BlockShape(
      id: 'corner_3x3_4',
      matrix: [
        [1, 1, 1],
        [0, 0, 1],
        [0, 0, 1],
      ],
      color: Color(0xFF3A86FF),
      glowColor: Color(0xFF80B3FF),
    ),
    // T Shapes
    BlockShape(
      id: 't_shape_up',
      matrix: [
        [1, 1, 1],
        [0, 1, 0],
      ],
      color: Color(0xFF9B5DE5),
      glowColor: Color(0xFFC77DFF),
    ),
    BlockShape(
      id: 't_shape_down',
      matrix: [
        [0, 1, 0],
        [1, 1, 1],
      ],
      color: Color(0xFF9B5DE5),
      glowColor: Color(0xFFC77DFF),
    ),
    BlockShape(
      id: 't_shape_left',
      matrix: [
        [1, 0],
        [1, 1],
        [1, 0],
      ],
      color: Color(0xFF9B5DE5),
      glowColor: Color(0xFFC77DFF),
    ),
    BlockShape(
      id: 't_shape_right',
      matrix: [
        [0, 1],
        [1, 1],
        [0, 1],
      ],
      color: Color(0xFF9B5DE5),
      glowColor: Color(0xFFC77DFF),
    ),
    // Z & S shapes
    BlockShape(
      id: 'z_shape',
      matrix: [
        [1, 1, 0],
        [0, 1, 1],
      ],
      color: Color(0xFF00BBF9),
      glowColor: Color(0xFF70E000),
    ),
    BlockShape(
      id: 's_shape',
      matrix: [
        [0, 1, 1],
        [1, 1, 0],
      ],
      color: Color(0xFF00BBF9),
      glowColor: Color(0xFF70E000),
    ),
  ];
}
