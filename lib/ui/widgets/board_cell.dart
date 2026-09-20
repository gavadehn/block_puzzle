import 'package:flutter/material.dart';

class BoardCellWidget extends StatelessWidget {
  final Color? color;
  final bool isPreview;
  final Color? previewColor;
  final bool isClearing;
  final double size;

  const BoardCellWidget({
    super.key,
    required this.color,
    this.isPreview = false,
    this.previewColor,
    this.isClearing = false,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (color != null) {
      // Occupied cell
      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color!.withAlpha(255),
              HSLColor.fromColor(color!).withLightness(
                (HSLColor.fromColor(color!).lightness * 0.75).clamp(0.0, 1.0)
              ).toColor(),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(70),
              blurRadius: 3,
              offset: const Offset(1, 2),
            ),
            BoxShadow(
              color: Colors.white.withAlpha(50),
              blurRadius: 1,
              offset: const Offset(-1, -1),
            ),
          ],
        ),
      );
    } else if (isPreview && previewColor != null) {
      // Preview hover cell
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: previewColor!.withAlpha(120),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: previewColor!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: previewColor!.withAlpha(150),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
      );
    } else {
      // Empty cell
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF1E2430),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color(0xFF2B3345),
            width: 1,
          ),
        ),
      );
    }
  }
}
