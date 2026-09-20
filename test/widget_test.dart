import 'package:flutter_test/flutter_test.dart';
import 'package:block_puzzle/main.dart';

void main() {
  testWidgets('BlockPuzzleApp renders initial screen correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const BlockPuzzleApp());
    await tester.pumpAndSettle();

    // Verify Title / Scoreboard elements are present
    expect(find.text('KỶ LỤC'), findsOneWidget);
    expect(find.text('ĐIỂM SỐ'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2)); // High score and initial score
  });
}
