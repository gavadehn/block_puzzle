import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:block_puzzle/models/block_shape.dart';
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

    test('Initial high scores for Hard and Easy modes are 0 and empty', () {
      expect(service.getHighestScore(GameMode.hard), 0);
      expect(service.getHighestScore(GameMode.easy), 0);
      expect(service.getTopScores(GameMode.hard).isEmpty, true);
      expect(service.getTopScores(GameMode.easy).isEmpty, true);
    });

    test('Adding scores separates Hard and Easy leaderboards', () async {
      // Add score to Hard mode
      await service.addScore('Hard Player', 500, GameMode.hard);
      // Add score to Easy mode
      await service.addScore('Easy Player', 800, GameMode.easy);

      expect(service.getHighestScore(GameMode.hard), 500);
      expect(service.getHighestScore(GameMode.easy), 800);

      expect(service.getTopScores(GameMode.hard).length, 1);
      expect(service.getTopScores(GameMode.easy).length, 1);
      expect(service.getTopScores(GameMode.hard).first.name, 'Hard Player');
      expect(service.getTopScores(GameMode.easy).first.name, 'Easy Player');
    });
  });
}
