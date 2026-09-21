import 'package:flutter/material.dart';
import '../../models/block_shape.dart';
import '../../models/high_score_entry.dart';
import '../../services/high_score_service.dart';

class LeaderboardDialog extends StatefulWidget {
  final GameMode initialMode;

  const LeaderboardDialog({
    super.key,
    this.initialMode = GameMode.hard,
  });

  @override
  State<LeaderboardDialog> createState() => _LeaderboardDialogState();
}

class _LeaderboardDialogState extends State<LeaderboardDialog> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialMode == GameMode.hard ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: HighScoreService.instance,
      builder: (context, _) {
        final hardScores = HighScoreService.instance.hardScores;
        final easyScores = HighScoreService.instance.easyScores;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440, maxHeight: 620),
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
                const SizedBox(height: 12),

                // Dual Tab Selector (Khó vs Dễ)
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10141D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: const Color(0xFF1E2536),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF333E5A)),
                    ),
                    dividerColor: Colors.transparent,
                    labelColor: const Color(0xFFFFD166),
                    unselectedLabelColor: Colors.white60,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    tabs: const [
                      Tab(text: '🔥 CHẾ ĐỘ KHÓ'),
                      Tab(text: '✨ CHẾ ĐỘ DỄ'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildScoreList(hardScores, 'Chưa có kỷ lục Chế độ Khó!\nHãy chơi và ghi danh vào bảng vàng!'),
                      _buildScoreList(easyScores, 'Chưa có kỷ lục Chế độ Dễ!\nHãy chơi và ghi danh vào bảng vàng!'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

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

  Widget _buildScoreList(List<HighScoreEntry> scores, String emptyText) {
    if (scores.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.military_tech_rounded,
              size: 52,
              color: Colors.white24,
            ),
            const SizedBox(height: 10),
            Text(
              emptyText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: scores.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = scores[index];
        final rank = index + 1;
        return _buildRankItem(rank, entry);
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
