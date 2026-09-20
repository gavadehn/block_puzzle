import 'dart:math';
import 'package:flutter/material.dart';
import '../../logic/game_controller.dart';
import '../../models/drag_data.dart';
import 'board_cell.dart';

class GameBoardWidget extends StatefulWidget {
  final GameController controller;

  const GameBoardWidget({
    super.key,
    required this.controller,
  });

  @override
  State<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends State<GameBoardWidget> {
  final GlobalKey _boardKey = GlobalKey();
  int? _hoverRow;
  int? _hoverCol;
  DragBlockData? _activeDrag;
  double _boardPx = 320.0;

  void _updateHover(Offset globalPosition, DragBlockData data) {
    final renderBox = _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final local = renderBox.globalToLocal(globalPosition);
    const padding = 12.0;
    const size = GameController.boardSize;
    const cellSpacing = DragConstants.cellSpacing;

    final availableSize = _boardPx - (padding * 2);
    final cellSize = ((availableSize - ((size - 1) * cellSpacing)) / size).clamp(16.0, 50.0);
    final totalCellStep = cellSize + cellSpacing;

    // Geometric Center of the currently dragged block on screen
    final shapeCenterX = local.dx;
    final shapeCenterY = local.dy - DragConstants.touchLift;

    final shapeWidth = data.shape.cols * totalCellStep - cellSpacing;
    final shapeHeight = data.shape.rows * totalCellStep - cellSpacing;

    // Top-left coordinate of the dragged block
    final shapeTopLeftX = shapeCenterX - (shapeWidth / 2);
    final shapeTopLeftY = shapeCenterY - (shapeHeight / 2);

    // Find the closest grid position (row, col)
    final closestCol = ((shapeTopLeftX - padding + (totalCellStep / 2)) / totalCellStep).floor();
    final closestRow = ((shapeTopLeftY - padding + (totalCellStep / 2)) / totalCellStep).floor();

    bool isSnapValid = false;
    int? validRow;
    int? validCol;

    if (widget.controller.canPlace(data.shape, closestRow, closestCol)) {
      // Geometric Center of the candidate target placement on the board
      final targetTopLeftX = padding + closestCol * totalCellStep;
      final targetTopLeftY = padding + closestRow * totalCellStep;
      final targetCenterX = targetTopLeftX + (shapeWidth / 2);
      final targetCenterY = targetTopLeftY + (shapeHeight / 2);

      // Calculate Euclidean distance between shape center and target placement center
      final dx = shapeCenterX - targetCenterX;
      final dy = shapeCenterY - targetCenterY;
      final distance = sqrt(dx * dx + dy * dy);

      // Only show preview when distance between 2 centers <= 1/2 unit cell size
      final maxAllowedDistance = cellSize * DragConstants.centerDistanceFactor;
      if (distance <= maxAllowedDistance) {
        isSnapValid = true;
        validRow = closestRow;
        validCol = closestCol;
      }
    }

    if (isSnapValid && validRow != null && validCol != null) {
      if (_hoverRow != validRow || _hoverCol != validCol || _activeDrag != data) {
        setState(() {
          _hoverRow = validRow;
          _hoverCol = validCol;
          _activeDrag = data;
        });
      }
    } else {
      if (_hoverRow != null || _hoverCol != null) {
        setState(() {
          _hoverRow = null;
          _hoverCol = null;
          _activeDrag = null;
        });
      }
    }
  }

  void _clearHover() {
    if (_hoverRow != null || _hoverCol != null || _activeDrag != null) {
      setState(() {
        _hoverRow = null;
        _hoverCol = null;
        _activeDrag = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const size = GameController.boardSize;
    const padding = 12.0;
    const cellSpacing = DragConstants.cellSpacing;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSide = min(constraints.maxWidth, constraints.maxHeight);
        final boardPx = maxSide.clamp(180.0, 420.0);
        _boardPx = boardPx;

        final availableSize = boardPx - (padding * 2);
        final cellSize = ((availableSize - ((size - 1) * cellSpacing)) / size).clamp(16.0, 50.0);

        return Center(
          child: DragTarget<DragBlockData>(
            onWillAcceptWithDetails: (details) {
              _updateHover(details.offset, details.data);
              return true;
            },
            onMove: (details) {
              _updateHover(details.offset, details.data);
            },
            onLeave: (_) {
              _clearHover();
            },
            onAcceptWithDetails: (details) {
              if (_hoverRow != null && _hoverCol != null) {
                widget.controller.placeBlock(
                  details.data.handIndex,
                  _hoverRow!,
                  _hoverCol!,
                );
              }
              _clearHover();
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                key: _boardKey,
                width: boardPx,
                height: boardPx,
                padding: const EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  color: const Color(0xFF131822),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF2C3549),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(120),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(size, (r) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(size, (c) {
                        final cellColor = widget.controller.board[r][c];

                        // Check if cell is in active preview
                        bool isPreview = false;
                        Color? previewColor;

                        if (_activeDrag != null &&
                            _hoverRow != null &&
                            _hoverCol != null) {
                          final shape = _activeDrag!.shape;
                          final shapeR = r - _hoverRow!;
                          final shapeC = c - _hoverCol!;

                          if (shapeR >= 0 &&
                              shapeR < shape.rows &&
                              shapeC >= 0 &&
                              shapeC < shape.cols) {
                            if (shape.matrix[shapeR][shapeC] == 1) {
                              isPreview = true;
                              previewColor = shape.color;
                            }
                          }
                        }

                        return BoardCellWidget(
                          size: cellSize,
                          color: cellColor,
                          isPreview: isPreview,
                          previewColor: previewColor,
                        );
                      }),
                    );
                  }),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
