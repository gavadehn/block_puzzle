import 'dart:math';
import 'package:flutter/material.dart';
import '../../logic/game_controller.dart';
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
    _controller = GameController();
    _controller.addListener(_onGameStateChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioManager.instance.startBgm();
    });
  }

  void _onGameStateChanged() {
    if (_controller.isGameOver && !_hasPromptedRecord) {
      final score = _controller.score;
      if (HighScoreService.instance.isTop10Score(score)) {
        _hasPromptedRecord = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _promptNewRecord(score);
        });
      }
    } else if (!_controller.isGameOver) {
      _hasPromptedRecord = false;
    }
  }

  void _promptNewRecord(int score) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => NewRecordDialog(
        score: score,
        onSaved: () {
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (_) => const LeaderboardDialog(),
          );
        },
      ),
    );
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
              final bestScore = max(_controller.highScore, HighScoreService.instance.highestScore);

              return Stack(
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Column(
                        children: [
                          // 1. Header & Scoreboard with Mute/Unmute and Leaderboard buttons
                          ScoreBoardWidget(
                            score: _controller.score,
                            highScore: bestScore,
                            combo: _controller.comboStreak,
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

                          // 3. Hand Spawner Tray (3 draggable blocks)
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
