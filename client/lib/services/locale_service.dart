import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  vi('vi', 'Tiếng Việt', '🇻🇳'),
  en('en', 'English', '🇬🇧'),
  ja('ja', '日本語', '🇯🇵');

  final String code;
  final String label;
  final String flag;

  const AppLanguage(this.code, this.label, this.flag);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (e) => e.code == code,
      orElse: () => AppLanguage.vi,
    );
  }
}

class LocaleService extends ChangeNotifier {
  static final LocaleService instance = LocaleService._internal();

  factory LocaleService() => instance;

  LocaleService._internal() {
    loadLanguage();
  }

  static const String _prefKey = 'selected_app_language';
  AppLanguage _currentLanguage = AppLanguage.vi;

  AppLanguage get currentLanguage => _currentLanguage;
  String get languageCode => _currentLanguage.code;
  Locale get currentLocale => Locale(_currentLanguage.code);

  Future<void> loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey) ?? 'vi';
      _currentLanguage = AppLanguage.fromCode(code);
      notifyListeners();
    } catch (e) {
      debugPrint('LocaleService load error: $e');
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;
    _currentLanguage = language;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, language.code);
    } catch (e) {
      debugPrint('LocaleService save error: $e');
    }
  }

  String tr(String key, [Map<String, String>? params]) {
    final lang = _currentLanguage.code;
    String text = _translations[lang]?[key] ??
        _translations['en']?[key] ??
        _translations['vi']?[key] ??
        key;

    if (params != null) {
      params.forEach((k, v) {
        text = text.replaceAll('{$k}', v);
      });
    }
    return text;
  }

  static const Map<String, Map<String, String>> _translations = {
    'vi': {
      // Header & Score
      'high_score': 'KỶ LỤC',
      'score': 'ĐIỂM SỐ',
      'combo': 'COMBO',
      'hard': 'Khó',
      'easy': 'Dễ',
      'mode': 'Chế độ',
      'mode_hard_desc': 'Cố định không xoay',
      'mode_easy_desc': 'Cho phép xoay hình',
      'change_mode_title': 'Đổi chế độ chơi?',
      'change_mode_content': 'Chuyển sang Chế độ {mode} ({desc}) sẽ bắt đầu một ván chơi mới. Bạn có chắc chắn?',
      'cancel': 'HỦY',
      'confirm': 'ĐỒNG Ý',

      // Actions & Controls
      'play_again': 'CHƠI LẠI',
      'game_over': 'HẾT LƯỢT ĐI',
      'this_game_score': 'ĐIỂM TRẬN NÀY',
      'view_leaderboard': 'BẢNG VÀNG 🏆',
      'view_leaderboard_mode': 'BẢNG VÀNG ({mode}) 🏆',
      'rotate_left': 'Xoay trái',
      'rotate_right': 'Xoay phải',
      'music_on': 'Bật nhạc nền',
      'music_off': 'Tắt nhạc nền',
      'settings': 'Cài đặt',

      // Leaderboard
      'leaderboard_title': '🏆 BẢNG VÀNG KỶ LỤC 🏆',
      'tab_hard': '🔥 Chế độ Khó',
      'tab_easy': '✨ Chế độ Dễ',
      'no_records': 'Chưa có kỷ lục nào.\nHãy chơi để ghi danh vào bảng vàng!',
      'pts': 'ĐIỂM',
      'rank': 'HẠNG',

      // New Record Dialog
      'champion_record': '🏆 KỶ LỤC MỚI VÔ ĐỊCH! 🏆',
      'top_10_record': '🎉 LỌT TOP 10 KỶ LỤC! 🎉',
      'player_name': 'Tên người chơi:',
      'enter_name_hint': 'Nhập tên của bạn...',
      'save_to_leaderboard': 'LƯU VÀO BẢNG VÀNG',
      'saving': 'ĐANG LƯU...',
      'default_player': 'Người chơi',

      // Settings Dialog
      'settings_title': '⚙️ CÀI ĐẶT',
      'language_section': 'Ngôn ngữ',
      'bgm_section': 'Danh sách nhạc nền (BGM)',
      'bgm_hint': 'Chọn những bài hát bạn muốn phát trong lúc chơi:',
      'track_1': 'Giai điệu 1 (Thư giãn)',
      'track_2': 'Giai điệu 2 (Vui tươi)',
      'track_3': 'Giai điệu 3 (Năng động)',
      'track_4': 'Giai điệu 4 (Sâu lắng)',
      'track_5': 'Giai điệu 5 (Hùng tráng)',
      'close': 'ĐÓNG',
    },
    'en': {
      // Header & Score
      'high_score': 'HIGH SCORE',
      'score': 'SCORE',
      'combo': 'COMBO',
      'hard': 'Hard',
      'easy': 'Easy',
      'mode': 'Mode',
      'mode_hard_desc': 'Fixed blocks (Classic)',
      'mode_easy_desc': 'Rotatable blocks',
      'change_mode_title': 'Change Game Mode?',
      'change_mode_content': 'Switching to {mode} Mode ({desc}) will restart the game. Are you sure?',
      'cancel': 'CANCEL',
      'confirm': 'CONFIRM',

      // Actions & Controls
      'play_again': 'PLAY AGAIN',
      'game_over': 'GAME OVER',
      'this_game_score': 'CURRENT SCORE',
      'view_leaderboard': 'LEADERBOARD 🏆',
      'view_leaderboard_mode': 'LEADERBOARD ({mode}) 🏆',
      'rotate_left': 'Rotate Left',
      'rotate_right': 'Rotate Right',
      'music_on': 'Music ON',
      'music_off': 'Music OFF',
      'settings': 'Settings',

      // Leaderboard
      'leaderboard_title': '🏆 TOP 10 LEADERBOARD 🏆',
      'tab_hard': '🔥 Hard Mode',
      'tab_easy': '✨ Easy Mode',
      'no_records': 'No records yet.\nPlay a game to claim your spot!',
      'pts': 'PTS',
      'rank': 'RANK',

      // New Record Dialog
      'champion_record': '🏆 NEW CHAMPION RECORD! 🏆',
      'top_10_record': '🎉 TOP 10 RECORD REACHED! 🎉',
      'player_name': 'Player Name:',
      'enter_name_hint': 'Enter your name...',
      'save_to_leaderboard': 'SAVE TO LEADERBOARD',
      'saving': 'SAVING...',
      'default_player': 'Player',

      // Settings Dialog
      'settings_title': '⚙️ SETTINGS',
      'language_section': 'Language',
      'bgm_section': 'Background Music (BGM)',
      'bgm_hint': 'Select tracks to include in playback playlist:',
      'track_1': 'Track 1 (Relaxing)',
      'track_2': 'Track 2 (Cheerful)',
      'track_3': 'Track 3 (Energetic)',
      'track_4': 'Track 4 (Gentle)',
      'track_5': 'Track 5 (Epic)',
      'close': 'CLOSE',
    },
    'ja': {
      // Header & Score
      'high_score': 'ハイスコア',
      'score': 'スコア',
      'combo': 'コンボ',
      'hard': 'ハード',
      'easy': 'イージー',
      'mode': 'モード',
      'mode_hard_desc': 'ブロック固定（クラシック）',
      'mode_easy_desc': 'ブロック回転可能',
      'change_mode_title': 'モードを変更しますか？',
      'change_mode_content': '{mode}モード（{desc}）に変更すると新しいゲームが始まります。よろしいですか？',
      'cancel': 'キャンセル',
      'confirm': '変更する',

      // Actions & Controls
      'play_again': 'もう一度遊ぶ',
      'game_over': 'ゲームオーバー',
      'this_game_score': '今回のスコア',
      'view_leaderboard': 'ランキング 🏆',
      'view_leaderboard_mode': 'ランキング ({mode}) 🏆',
      'rotate_left': '左回転',
      'rotate_right': '右回転',
      'music_on': 'BGM オン',
      'music_off': 'BGM オフ',
      'settings': '設定',

      // Leaderboard
      'leaderboard_title': '🏆 殿堂入りランキング 🏆',
      'tab_hard': '🔥 ハードモード',
      'tab_easy': '✨ イージーモード',
      'no_records': 'まだ記録がありません。\nゲームをプレイしてランキングを目指しましょう！',
      'pts': '点',
      'rank': '順位',

      // New Record Dialog
      'champion_record': '🏆 歴代最高新記録達成！ 🏆',
      'top_10_record': '🎉 トップ10ランクイン！ 🎉',
      'player_name': 'プレイヤー名:',
      'enter_name_hint': '名前を入力...',
      'save_to_leaderboard': 'ランキングに保存',
      'saving': '保存中...',
      'default_player': 'プレイヤー',

      // Settings Dialog
      'settings_title': '⚙️ 設定',
      'language_section': '言語 (Language)',
      'bgm_section': 'BGMプレイリスト設定',
      'bgm_hint': '再生するBGMを選択してください：',
      'track_1': 'トラック1（リラックス）',
      'track_2': 'トラック2（明るい）',
      'track_3': 'トラック3（軽快）',
      'track_4': 'トラック4（おだやか）',
      'track_5': 'トラック5（壮大）',
      'close': '閉じる',
    },
  };
}
