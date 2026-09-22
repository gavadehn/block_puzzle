import 'package:flutter/material.dart';
import '../../logic/game_controller.dart';
import '../../models/block_shape.dart';
import '../../models/drag_data.dart';
import '../../services/locale_service.dart';
import 'block_widget.dart';

class HandTrayWidget extends StatelessWidget {
  final GameController controller;

  const HandTrayWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isEasyMode = controller.mode == GameMode.easy;
    final selectedIdx = controller.selectedHandIndex;

    return ListenableBuilder(
      listenable: LocaleService.instance,
      builder: (context, _) {
        final loc = LocaleService.instance;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Easy Mode: Rotation Controls & Hint
              if (isEasyMode)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: selectedIdx != null
                        ? Row(
                            key: const ValueKey('rotation_bar'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => controller.rotateSelectedBlockLeft(),
                                icon: const Icon(Icons.rotate_left_rounded, size: 20),
                                label: Text(
                                  loc.tr('rotate_left'),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E2536),
                                  foregroundColor: const Color(0xFF06D6A0),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(color: Color(0xFF06D6A0)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              ElevatedButton.icon(
                                onPressed: () => controller.rotateSelectedBlockRight(),
                                icon: const Icon(Icons.rotate_right_rounded, size: 20),
                                label: Text(
                                  loc.tr('rotate_right'),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E2536),
                                  foregroundColor: const Color(0xFFFFD166),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(color: Color(0xFFFFD166)),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(height: 38),
                  ),
                ),

              // 3 Candidate Slots
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (index) {
                  final shape = controller.hand[index];
                  if (shape == null) {
                    return const SizedBox(
                      width: 96,
                      height: 96,
                    );
                  }

                  final canFit = controller.canPlaceAnywhere(shape);
                  final isSelected = isEasyMode && (selectedIdx == index);
                  final dragData = DragBlockData(handIndex: index, shape: shape);

                  return GestureDetector(
                    onTap: () {
                      if (isEasyMode) {
                        controller.selectHandBlock(index);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1F2A3F) : const Color(0xFF131822),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF06D6A0)
                              : const Color(0xFF242D3E),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF06D6A0).withAlpha(120),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Draggable<DragBlockData>(
                        data: dragData,
                        dragAnchorStrategy: pointerDragAnchorStrategy,
                        onDragStarted: () {
                          if (isEasyMode && selectedIdx != index) {
                            controller.selectHandBlock(index);
                          }
                        },
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
                          child: Center(
                            child: FittedBox(
                              child: BlockShapeWidget(
                                shape: shape,
                                cellSize: 20,
                                spacing: 2,
                              ),
                            ),
                          ),
                        ),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: canFit ? 1.0 : 0.35,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FittedBox(
                                child: BlockShapeWidget(
                                  shape: shape,
                                  cellSize: 20,
                                  spacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
