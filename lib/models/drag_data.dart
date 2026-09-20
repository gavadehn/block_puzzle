import '../models/block_shape.dart';

class DragConstants {
  /// Vertical lift distance above pointer to prevent finger from obscuring the dragged block
  static const double touchLift = 50.0;
  static const double cellSize = 34.0;
  static const double cellSpacing = 4.0;
  static const double totalCellStep = cellSize + cellSpacing;

  /// Maximum center-to-center distance ratio (0.5 = 1/2 of unit cell length)
  static const double centerDistanceFactor = 0.50;
}

class DragBlockData {
  final int handIndex;
  final BlockShape shape;

  const DragBlockData({
    required this.handIndex,
    required this.shape,
  });

  double get totalWidth => shape.cols * DragConstants.totalCellStep - DragConstants.cellSpacing;
  double get totalHeight => shape.rows * DragConstants.totalCellStep - DragConstants.cellSpacing;
}
