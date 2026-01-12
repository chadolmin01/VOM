import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage('ko-KR');
    // 속도: 0.4 (천천히, 또박또박) - 기존 0.5
    await _flutterTts.setSpeechRate(0.4);
    // 피치: 1.0 (자연스러운 톤) - 기존 1.1 (약간 높음)
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);

    _isInitialized = true;
  }

  Future<void> speak(String text) async {
    await init();
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  void setCompletionHandler(Function handler) {
    _flutterTts.setCompletionHandler(() {
      handler();
    });
  }
}
