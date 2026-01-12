import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

/// 음성 인식 (Speech-to-Text) 서비스
class SttService {
  static final SttService _instance = SttService._internal();
  factory SttService() => _instance;
  SttService._internal();

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  bool get isListening => _isListening;
  bool get isAvailable => _isInitialized;

  /// 초기화
  Future<bool> init() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onError: (error) => debugPrint('STT Error: $error'),
        onStatus: (status) => debugPrint('STT Status: $status'),
      );
      debugPrint('STT initialized: $_isInitialized');
      return _isInitialized;
    } catch (e) {
      debugPrint('STT init error: $e');
      return false;
    }
  }

  /// 음성 인식 시작
  Future<void> startListening({
    required Function(String text, bool isFinal) onResult,
    String localeId = 'ko_KR',
  }) async {
    if (!_isInitialized) {
      await init();
    }

    if (_isListening) {
      await stopListening();
    }

    _isListening = true;

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        onResult(result.recognizedWords, result.finalResult);
        if (result.finalResult) {
          _isListening = false;
        }
      },
      localeId: localeId,
      listenMode: ListenMode.confirmation,
      cancelOnError: true,
      partialResults: true,
    );
  }

  /// 음성 인식 중지
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  /// 음성 인식 취소
  Future<void> cancel() async {
    await _speech.cancel();
    _isListening = false;
  }
}
