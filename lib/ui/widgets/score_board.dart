import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/block_shape.dart';
import '../../services/audio_manager.dart';
import '../../services/high_score_service.dart';
import 'leaderboard_dialog.dart';

class ScoreBoardWidget extends StatelessWidget {
  final int score;
  final int highScore;
  final int combo;
  final GameMode mode;
  final ValueChanged<GameMode> onModeChanged;
  final VoidCallback onRestart;

  const ScoreBoardWidget({
    super.key,
    required this.score,
    required this.highScore,
    required this.combo,
    required this.mode,
    required this.onModeChanged,
    required this.onRestart,
  });

  void _showLeaderboard(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => LeaderboardDialog(initialMode: mode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Row 1: High Score + Mode Selector + Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // High Score Card (Clickable to open Leaderboard)
              ListenableBuilder(
                listenable: HighScoreService.instance,
                builder: (context, _) {
                  final bestScore = max(highScore, HighScoreService.instance.getHighestScore(mode));
                  return InkWell(
                    onTap: () => _showLeaderboard(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'KỶ LỤC (${mode.displayName.toUpperCase()})',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                '$bestScore',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
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

              // Mode Selector (🔥 Khó | ✨ Dễ)
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10141D),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2C3549)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModeButton(
                      title: 'Khó',
                      icon: '🔥',
                      isSelected: mode == GameMode.hard,
                      onTap: () => onModeChanged(GameMode.hard),
                    ),
                    _buildModeButton(
                      title: 'Dễ',
                      icon: '✨',
                      isSelected: mode == GameMode.easy,
                      onTap: () => onModeChanged(GameMode.easy),
                    ),
                  ],
                ),
              ),

              // Action Buttons: Leaderboard, Audio, Restart
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
                        icon: const Icon(Icons.leaderboard_rounded, size: 18),
                        color: const Color(0xFFFFD166),
                        tooltip: 'Bảng vàng kỷ lục',
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2536),
                          padding: const EdgeInsets.all(6),
                          minimumSize: const Size(34, 34),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Music Toggle Button
                      IconButton(
                        onPressed: () => audio.toggleMusic(),
                        icon: Icon(
                          audio.isMusicEnabled ? Icons.music_note_rounded : Icons.music_off_rounded,
                          size: 18,
                        ),
                        color: audio.isMusicEnabled ? const Color(0xFF06D6A0) : Colors.white38,
                        tooltip: audio.isMusicEnabled ? 'Tắt nhạc nền' : 'Bật nhạc nền',
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2536),
                          padding: const EdgeInsets.all(6),
                          minimumSize: const Size(34, 34),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Restart Button
                      IconButton(
                        onPressed: onRestart,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        color: Colors.white70,
                        tooltip: 'Chơi lại',
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2536),
                          padding: const EdgeInsets.all(6),
                          minimumSize: const Size(34, 34),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Current Score with Miki Mascot
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Miki Mascot Avatar
              Tooltip(
                message: 'Miki Mascot',
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF19202E),
                    border: Border.all(
                      color: const Color(0xFFFFD166),
                      width: 2.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD166).withAlpha(80),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/image/miki.png',
                      fit: BoxFit.cover,
                      alignment: const Alignment(0.0, -0.85),
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.pets_rounded,
                        color: Color(0xFFFFD166),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Score Details
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'ĐIỂM SỐ',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
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
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            height: 1.1,
                          ),
                        ),
                      ),
                      if (combo > 1) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF007F), Color(0xFFFF758F)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF007F).withAlpha(120),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Text(
                            'x$combo 🔥',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String title,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E2536) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: const Color(0xFF06D6A0).withAlpha(180))
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF06D6A0).withAlpha(80),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
