import 'package:flutter_test/flutter_test.dart';
import 'package:block_puzzle/main.dart';
import 'package:block_puzzle/services/audio_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AudioManager.enableAudio = false;

  testWidgets('BlockPuzzleApp renders initial screen correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const BlockPuzzleApp());
    await tester.pumpAndSettle();

    // Verify Title / Scoreboard elements are present
    expect(find.textContaining('KỶ LỤC'), findsWidgets);
    expect(find.text('ĐIỂM SỐ'), findsOneWidget);
    expect(find.text('0'), findsWidgets);
  });
}
