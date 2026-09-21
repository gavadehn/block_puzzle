import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/audio_manager.dart';
import '../../services/high_score_service.dart';
import 'leaderboard_dialog.dart';

class ScoreBoardWidget extends StatelessWidget {
  final int score;
  final int highScore;
  final int combo;
  final VoidCallback onRestart;

  const ScoreBoardWidget({
    super.key,
    required this.score,
    required this.highScore,
    required this.combo,
    required this.onRestart,
  });

  void _showLeaderboard(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const LeaderboardDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // High Score Card (Clickable to open Leaderboard)
              ListenableBuilder(
                listenable: HighScoreService.instance,
                builder: (context, _) {
                  final bestScore = max(highScore, HighScoreService.instance.highestScore);
                  return InkWell(
                    onTap: () => _showLeaderboard(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2536),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF333E5A)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.emoji_events_rounded,
                            color: Color(0xFFFFD166),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Text(
                                    'KỶ LỤC',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.white38,
                                    size: 8,
                                  ),
                                ],
                              ),
                              Text(
                                '$bestScore',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Action Buttons: Leaderboard, Music, Sound, Restart
              ListenableBuilder(
                listenable: AudioManager.instance,
                builder: (context, _) {
                  final audio = AudioManager.instance;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Leaderboard Button
                      IconButton(
                        onPressed: () => _showLeaderboard(context),
                        icon: const Icon(
                          Icons.leaderboard_rounded,
                          size: 20,
                        ),
                        color: const Color(0xFFFFD166),
                        tooltip: 'Bảng vàng kỷ lục',
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2536),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Music Toggle Button
                      IconButton(
                        onPressed: () => audio.toggleMusic(),
                        icon: Icon(
                          audio.isMusicEnabled
                              ? Icons.music_note_rounded
                              : Icons.music_off_rounded,
                          size: 20,
                        ),
                        color: audio.isMusicEnabled ? const Color(0xFF06D6A0) : Colors.white38,
                        tooltip: audio.isMusicEnabled ? 'Tắt nhạc nền' : 'Bật nhạc nền',
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2536),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Sound Effects Toggle Button
                      IconButton(
                        onPressed: () => audio.toggleSound(),
                        icon: Icon(
                          audio.isSoundEnabled
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          size: 20,
                        ),
                        color: audio.isSoundEnabled ? const Color(0xFFFFD166) : Colors.white38,
                        tooltip: audio.isSoundEnabled ? 'Tắt hiệu ứng âm thanh' : 'Bật hiệu ứng âm thanh',
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2536),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Restart Button
                      IconButton(
                        onPressed: onRestart,
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        color: Colors.white70,
                        tooltip: 'Chơi lại',
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2536),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Current Score
          Column(
            children: [
              const Text(
                'ĐIỂM SỐ',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: Text(
                  '$score',
                  key: ValueKey<int>(score),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
              ),
              if (combo > 1) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF007F), Color(0xFFFF758F)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF007F).withAlpha(120),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Text(
                    'COMBO x$combo 🔥',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
