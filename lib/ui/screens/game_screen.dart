import 'dart:math';
import 'package:flutter/material.dart';
import '../../logic/game_controller.dart';
import '../../models/block_shape.dart';
import '../../services/audio_manager.dart';
import '../../services/high_score_service.dart';
import '../widgets/game_board.dart';
import '../widgets/hand_tray.dart';
import '../widgets/score_board.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/new_record_dialog.dart';
import '../widgets/leaderboard_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameController _controller;
  bool _hasPromptedRecord = false;

  @override
  void initState() {
    super.initState();
    _controller = GameController(initialMode: GameMode.hard);
    _controller.addListener(_onGameStateChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioManager.instance.startBgm();
    });
  }

  void _onGameStateChanged() {
    if (_controller.isGameOver && !_hasPromptedRecord) {
      final score = _controller.score;
      final mode = _controller.mode;
      if (HighScoreService.instance.isTop10Score(score, mode)) {
        _hasPromptedRecord = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _promptNewRecord(score, mode);
        });
      }
    } else if (!_controller.isGameOver) {
      _hasPromptedRecord = false;
    }
  }

  void _promptNewRecord(int score, GameMode mode) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => NewRecordDialog(
        score: score,
        mode: mode,
        onSaved: () {
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (_) => LeaderboardDialog(initialMode: mode),
          );
        },
      ),
    );
  }

  void _handleModeChange(GameMode newMode) {
    if (_controller.mode == newMode) return;
    if (_controller.score > 0 && !_controller.isGameOver) {
      // Prompt confirmation before switching mode if game is active
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF19202E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF333E5A)),
          ),
          title: const Text(
            'Đổi chế độ chơi?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Chuyển sang Chế độ ${newMode.displayName} (${newMode.description}) sẽ bắt đầu một ván chơi mới. Bạn có chắc chắn?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('HỦY', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _controller.setGameMode(newMode);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06D6A0),
                foregroundColor: const Color(0xFF0D1B2A),
              ),
              child: const Text('ĐỒNG Ý', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      _controller.setGameMode(newMode);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onGameStateChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Ensure web browser audio unlocks on first user tap
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => AudioManager.instance.startBgm(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0D111A),
        body: SafeArea(
          child: AnimatedBuilder(
            animation: Listenable.merge([_controller, HighScoreService.instance]),
            builder: (context, _) {
              final mode = _controller.mode;
              final bestScore = max(
                _controller.highScore,
                HighScoreService.instance.getHighestScore(mode),
              );

              return Stack(
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Column(
                        children: [
                          // 1. Header & Scoreboard with Mode Switcher
                          ScoreBoardWidget(
                            score: _controller.score,
                            highScore: bestScore,
                            combo: _controller.comboStreak,
                            mode: mode,
                            onModeChanged: _handleModeChange,
                            onRestart: () {
                              _controller.startNewGame();
                            },
                          ),

                          // 2. Game Board Grid (Flexible & Square)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: GameBoardWidget(
                                controller: _controller,
                              ),
                            ),
                          ),

                          // 3. Hand Spawner Tray (with rotation controls in Easy mode)
                          HandTrayWidget(
                            controller: _controller,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. Game Over Overlay
                  if (_controller.isGameOver)
                    GameOverOverlay(
                      score: _controller.score,
                      highScore: bestScore,
                      mode: mode,
                      onRestart: () {
                        _controller.startNewGame();
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
