import 'package:flutter/material.dart';
import '../../models/high_score_entry.dart';
import '../../services/high_score_service.dart';

class LeaderboardDialog extends StatelessWidget {
  const LeaderboardDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: HighScoreService.instance,
      builder: (context, _) {
        final scores = HighScoreService.instance.topScores;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440, maxHeight: 600),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF161C28),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF333E5A),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(160),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.emoji_events_rounded,
                          color: Color(0xFFFFD166),
                          size: 28,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'BẢNG VÀNG KỶ LỤC',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: Colors.white60),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF10141D),
                        padding: const EdgeInsets.all(6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Top 10 List or Empty State
                Expanded(
                  child: scores.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.military_tech_rounded,
                                size: 56,
                                color: Colors.white24,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Chưa có kỷ lục nào!\nHãy chơi và ghi tên vào bảng vàng!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: scores.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final entry = scores[index];
                            final rank = index + 1;
                            return _buildRankItem(rank, entry);
                          },
                        ),
                ),
                const SizedBox(height: 16),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E2536),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFF333E5A)),
                      ),
                    ),
                    child: const Text(
                      'ĐÓNG',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRankItem(int rank, HighScoreEntry entry) {
    Color rankColor;
    Color bgColor;
    Widget rankBadge;

    if (rank == 1) {
      rankColor = const Color(0xFFFFD166);
      bgColor = const Color(0xFF2C2411);
      rankBadge = const Text('🥇', style: TextStyle(fontSize: 20));
    } else if (rank == 2) {
      rankColor = const Color(0xFFE0E1DD);
      bgColor = const Color(0xFF222631);
      rankBadge = const Text('🥈', style: TextStyle(fontSize: 20));
    } else if (rank == 3) {
      rankColor = const Color(0xFFE29578);
      bgColor = const Color(0xFF261C18);
      rankBadge = const Text('🥉', style: TextStyle(fontSize: 20));
    } else {
      rankColor = Colors.white54;
      bgColor = const Color(0xFF10141D);
      rankBadge = Text(
        '#$rank',
        style: TextStyle(
          color: rankColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: rank <= 3 ? rankColor.withAlpha(120) : const Color(0xFF242C3E),
          width: rank <= 3 ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank Badge
          SizedBox(
            width: 32,
            child: Center(child: rankBadge),
          ),
          const SizedBox(width: 10),

          // Player Name & Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: rank <= 3 ? Colors.white : Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  entry.formattedDate,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Score
          Text(
            '${entry.score}',
            style: TextStyle(
              color: rankColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
