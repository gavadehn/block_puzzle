import 'package:flutter/material.dart';
import '../../logic/game_controller.dart';
import '../../models/drag_data.dart';
import 'block_widget.dart';

class HandTrayWidget extends StatelessWidget {
  final GameController controller;

  const HandTrayWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          final shape = controller.hand[index];
          if (shape == null) {
            return const SizedBox(
              width: 90,
              height: 90,
            );
          }

          final canFit = controller.canPlaceAnywhere(shape);
          final dragData = DragBlockData(handIndex: index, shape: shape);

          return SizedBox(
            width: 100,
            height: 100,
            child: Center(
              child: Draggable<DragBlockData>(
                data: dragData,
                dragAnchorStrategy: pointerDragAnchorStrategy,
                feedback: Material(
                  color: Colors.transparent,
                  child: Transform.translate(
                    offset: Offset(
                      -dragData.totalWidth / 2,
                      -dragData.totalHeight / 2 - DragConstants.touchLift,
                    ),
                    child: BlockShapeWidget(
                      shape: shape,
                      cellSize: DragConstants.cellSize,
                      spacing: DragConstants.cellSpacing,
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.2,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: BlockShapeWidget(
                      shape: shape,
                      cellSize: 18.0,
                      spacing: 2.0,
                    ),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: BlockShapeWidget(
                    shape: shape,
                    cellSize: 18.0,
                    spacing: 2.0,
                    isDimmed: !canFit,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
