import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:block_puzzle/services/high_score_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HighScoreService Tests', () {
    late HighScoreService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = HighScoreService();
      await service.loadScores();
    });

    test('Initial high score is 0 and empty list', () {
      expect(service.highestScore, 0);
      expect(service.topScores.isEmpty, true);
      expect(service.isTop10Score(100), true);
      expect(service.isTop10Score(0), false);
    });

    test('Adding scores maintains sorted descending order and max 10 entries', () async {
      // Add 12 scores
      for (int i = 1; i <= 12; i++) {
        await service.addScore('Player $i', i * 100);
      }

      expect(service.topScores.length, 10);
      expect(service.highestScore, 1200);
      expect(service.topScores.first.name, 'Player 12');
      expect(service.topScores.first.score, 1200);
      expect(service.topScores.last.score, 300);

      // Score 200 should not qualify for Top 10 (since lowest is 300)
      expect(service.isTop10Score(200), false);
      // Score 350 should qualify
      expect(service.isTop10Score(350), true);
      expect(service.getRankForScore(350), 10);
      expect(service.getRankForScore(1300), 1);
    });
  });
}
