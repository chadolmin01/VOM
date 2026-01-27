import 'package:vibration/vibration.dart';

class VibrationService {
  static bool? _hasVibrator;

  // 초기화
  static Future<void> init() async {
    _hasVibrator = await Vibration.hasVibrator();
  }

  // 짧은 진동 (탭 피드백)
  static Future<void> tap() async {
    _hasVibrator ??= await Vibration.hasVibrator();
    if (_hasVibrator == true) {
      await Vibration.vibrate(duration: 50);
    }
  }

  // 성공 진동
  static Future<void> success() async {
    _hasVibrator ??= await Vibration.hasVibrator();
    if (_hasVibrator == true) {
      await Vibration.vibrate(pattern: [0, 100, 50, 100]);
    }
  }

  // 오류 진동
  static Future<void> error() async {
    _hasVibrator ??= await Vibration.hasVibrator();
    if (_hasVibrator == true) {
      await Vibration.vibrate(pattern: [0, 200, 100, 200]);
    }
  }

  // 완료 축하 진동
  static Future<void> celebrate() async {
    _hasVibrator ??= await Vibration.hasVibrator();
    if (_hasVibrator == true) {
      await Vibration.vibrate(pattern: [0, 100, 50, 100, 50, 100]);
    }
  }

  // 녹음 시작/종료
  static Future<void> recordingToggle() async {
    _hasVibrator ??= await Vibration.hasVibrator();
    if (_hasVibrator == true) {
      await Vibration.vibrate(duration: 100);
    }
  }
}
