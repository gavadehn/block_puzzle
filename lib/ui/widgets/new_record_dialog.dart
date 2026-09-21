import 'package:flutter/material.dart';
import '../../models/block_shape.dart';
import '../../services/audio_manager.dart';
import '../../services/high_score_service.dart';

class NewRecordDialog extends StatefulWidget {
  final int score;
  final GameMode mode;
  final VoidCallback onSaved;

  const NewRecordDialog({
    super.key,
    required this.score,
    required this.mode,
    required this.onSaved,
  });

  @override
  State<NewRecordDialog> createState() => _NewRecordDialogState();
}

class _NewRecordDialogState extends State<NewRecordDialog> {
  late final TextEditingController _nameController;
  final FocusNode _focusNode = FocusNode();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: HighScoreService.instance.lastPlayerName,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioManager.instance.playNewRecord();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final name = _nameController.text.trim().isEmpty
        ? 'Người chơi'
        : _nameController.text.trim();

    await HighScoreService.instance.addScore(name, widget.score, widget.mode);
    if (mounted) {
      Navigator.of(context).pop();
      widget.onSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    final rank = HighScoreService.instance.getRankForScore(widget.score, widget.mode);
    final isTop1 = rank == 1;
    final modeLabel = widget.mode.displayName;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF19202E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isTop1 ? const Color(0xFFFFD166) : const Color(0xFF06D6A0),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isTop1 ? const Color(0xFFFFD166) : const Color(0xFF06D6A0))
                  .withAlpha(100),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy Header
            Icon(
              Icons.emoji_events_rounded,
              size: 56,
              color: isTop1 ? const Color(0xFFFFD166) : const Color(0xFF06D6A0),
            ),
            const SizedBox(height: 8),
            Text(
              isTop1 ? '🏆 KỶ LỤC MỚI VÔ ĐỊCH! 🏆' : '🎉 LỌT TOP 10 KỶ LỤC! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isTop1 ? const Color(0xFFFFD166) : const Color(0xFF06D6A0),
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Chế độ $modeLabel',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF10141D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'XẾP HẠNG #$rank',
                    style: const TextStyle(
                      color: Color(0xFFFFD166),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${widget.score} ĐIỂM',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Name Input Field
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tên người chơi:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              focusNode: _focusNode,
              autofocus: true,
              maxLength: 15,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'Nhập tên của bạn...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF10141D),
                counterStyle: const TextStyle(color: Colors.white38),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF333E5A)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isTop1 ? const Color(0xFFFFD166) : const Color(0xFF06D6A0),
                    width: 2,
                  ),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Icon(Icons.check_circle_rounded, size: 22),
                label: Text(
                  _isSaving ? 'ĐANG LƯU...' : 'LƯU VÀO BẢNG VÀNG',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isTop1 ? const Color(0xFFFFD166) : const Color(0xFF06D6A0),
                  foregroundColor: const Color(0xFF0D1B2A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
