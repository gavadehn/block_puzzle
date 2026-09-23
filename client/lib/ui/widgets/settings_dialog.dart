import 'package:flutter/material.dart';
import '../../services/audio_manager.dart';
import '../../services/locale_service.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([LocaleService.instance, AudioManager.instance]),
      builder: (context, _) {
        final loc = LocaleService.instance;
        final audio = AudioManager.instance;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF19202E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF333E5A), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(140),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.tr('settings_title'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 22),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 1. Language Selection Section
                  _buildSectionHeader(
                    icon: Icons.language_rounded,
                    title: loc.tr('language_section'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: AppLanguage.values.map((lang) {
                      final isSelected = loc.currentLanguage == lang;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: InkWell(
                            onTap: () => loc.setLanguage(lang),
                            borderRadius: BorderRadius.circular(14),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF243048) : const Color(0xFF10141D),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF06D6A0) : const Color(0xFF2C3549),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF06D6A0).withAlpha(60),
                                          blurRadius: 8,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    lang.flag,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    lang.label,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white60,
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),

                  // 2. BGM Playlist Selection Section
                  _buildSectionHeader(
                    icon: Icons.music_note_rounded,
                    title: loc.tr('bgm_section'),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.tr('bgm_hint'),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // BGM Track List
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF10141D),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2C3549)),
                    ),
                    child: Column(
                      children: List.generate(AudioManager.bgmPlaylist.length, (index) {
                        final trackKey = 'track_${index + 1}';
                        final trackName = loc.tr(trackKey);
                        final isEnabled = audio.isTrackEnabled(index);
                        final isLastItem = index == AudioManager.bgmPlaylist.length - 1;

                        return Container(
                          decoration: BoxDecoration(
                            border: isLastItem
                                ? null
                                : const Border(
                                    bottom: BorderSide(color: Color(0xFF1E2536), width: 1),
                                  ),
                          ),
                          child: InkWell(
                            onTap: () {
                              audio.toggleTrack(index, !isEnabled);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                              child: Row(
                                children: [
                                  // Track Index Badge
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isEnabled
                                          ? const Color(0xFF06D6A0).withAlpha(40)
                                          : const Color(0xFF1E2536),
                                      border: Border.all(
                                        color: isEnabled
                                            ? const Color(0xFF06D6A0)
                                            : const Color(0xFF333E5A),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: isEnabled ? const Color(0xFF06D6A0) : Colors.white38,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Track Title
                                  Expanded(
                                    child: Text(
                                      trackName,
                                      style: TextStyle(
                                        color: isEnabled ? Colors.white : Colors.white38,
                                        fontSize: 13,
                                        fontWeight: isEnabled ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ),

                                  // Checkbox Switch
                                  Transform.scale(
                                    scale: 0.9,
                                    child: Switch(
                                      value: isEnabled,
                                      activeThumbColor: const Color(0xFF06D6A0),
                                      activeTrackColor: const Color(0xFF06D6A0).withAlpha(80),
                                      inactiveThumbColor: Colors.white38,
                                      inactiveTrackColor: const Color(0xFF1E2536),
                                      onChanged: (val) {
                                        audio.toggleTrack(index, val);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Close Button
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF06D6A0),
                        foregroundColor: const Color(0xFF0D1B2A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        loc.tr('close'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFD166), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFFD166),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
