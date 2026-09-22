import 'package:flutter/material.dart';
import '../../models/block_shape.dart';
import '../../services/audio_manager.dart';
import '../../services/locale_service.dart';
import 'leaderboard_dialog.dart';

class GameOverOverlay extends StatefulWidget {
  final int score;
  final int highScore;
  final GameMode mode;
  final VoidCallback onRestart;

  const GameOverOverlay({
    super.key,
    required this.score,
    required this.highScore,
    required this.mode,
    required this.onRestart,
  });

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  @override
  void initState() {
    super.initState();
    final isNewRecord = widget.score >= widget.highScore && widget.score > 0;
    if (isNewRecord) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AudioManager.instance.playNewRecord();
      });
    }
  }

  void _showLeaderboard(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => LeaderboardDialog(initialMode: widget.mode),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = LocaleService.instance;
    final isNewRecord = widget.score >= widget.highScore && widget.score > 0;
    final modeName = widget.mode == GameMode.hard ? loc.tr('hard') : loc.tr('easy');

    return Container(
      color: Colors.black.withAlpha(200),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF19202E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isNewRecord ? const Color(0xFFFFD166) : const Color(0xFF323D57),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isNewRecord ? const Color(0xFFFFD166) : Colors.black).withAlpha(100),
                blurRadius: 25,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isNewRecord ? loc.tr('champion_record') : loc.tr('game_over'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isNewRecord ? const Color(0xFFFFD166) : Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${loc.tr('mode')} $modeName',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10141D),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      loc.tr('this_game_score'),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.score}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Restart Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: widget.onRestart,
                  icon: const Icon(Icons.replay_rounded, size: 22),
                  label: Text(
                    loc.tr('play_again'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06D6A0),
                    foregroundColor: const Color(0xFF0D1B2A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Leaderboard Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () => _showLeaderboard(context),
                  icon: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD166), size: 20),
                  label: Text(
                    loc.tr('view_leaderboard_mode', {'mode': modeName.toUpperCase()}),
                    style: const TextStyle(
                      color: Color(0xFFFFD166),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF433B23)),
                    backgroundColor: const Color(0xFF221F18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
