import 'package:flutter/material.dart';
import '../../models/block_shape.dart';

class BlockShapeWidget extends StatelessWidget {
  final BlockShape shape;
  final double cellSize;
  final double spacing;
  final bool isDimmed;

  const BlockShapeWidget({
    super.key,
    required this.shape,
    this.cellSize = 24.0,
    this.spacing = 2.0,
    this.isDimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDimmed ? 0.35 : 1.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(shape.rows, (r) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(shape.cols, (c) {
              final isFilled = shape.matrix[r][c] == 1;
              return Container(
                margin: EdgeInsets.all(spacing / 2),
                width: cellSize,
                height: cellSize,
                decoration: isFilled
                    ? BoxDecoration(
                        color: shape.color,
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            shape.color,
                            HSLColor.fromColor(shape.color)
                                .withLightness(
                                  (HSLColor.fromColor(shape.color).lightness *
                                          0.8)
                                      .clamp(0.0, 1.0),
                                )
                                .toColor(),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: shape.glowColor.withAlpha(80),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      )
                    : const BoxDecoration(
                        color: Colors.transparent,
                      ),
              );
            }),
          );
        }),
      ),
    );
  }
}
