import 'package:flutter/material.dart';
import '../../logic/game_controller.dart';
import '../widgets/game_board.dart';
import '../widgets/hand_tray.dart';
import '../widgets/score_board.dart';
import '../widgets/game_over_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GameController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D111A),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      children: [
                        // 1. Header & Scoreboard
                        ScoreBoardWidget(
                          score: _controller.score,
                          highScore: _controller.highScore,
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
                    highScore: _controller.highScore,
                    onRestart: () {
                      _controller.startNewGame();
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
