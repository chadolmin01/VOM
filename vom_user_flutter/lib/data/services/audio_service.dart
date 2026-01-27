import 'dart:async';
import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  String? _currentRecordingPath;
  bool _isRecording = false;
  Timer? _recordingTimer;
  int _recordingDuration = 0;

  bool get isRecording => _isRecording;
  int get recordingDuration => _recordingDuration;

  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> startRecording() async {
    if (_isRecording) return false;

    final hasPermission = await requestPermission();
    if (!hasPermission) return false;

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _currentRecordingPath = '${directory.path}/recording_$timestamp.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: _currentRecordingPath!,
    );

    _isRecording = true;
    _recordingDuration = 0;
    _startTimer();

    return true;
  }

  void _startTimer() {
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingDuration++;
    });
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    _recordingTimer?.cancel();
    _recordingTimer = null;

    final path = await _recorder.stop();
    _isRecording = false;

    return path;
  }

  Future<void> playRecording(String path) async {
    await _player.play(DeviceFileSource(path));
  }

  Future<void> stopPlayback() async {
    await _player.stop();
  }

  // 성공 사운드 재생 (비프음)
  Future<void> playSuccessSound() async {
    // 간단한 비프음 효과
    await _player.play(
      AssetSource('sounds/success.mp3'),
      volume: 0.5,
    );
  }

  // 파일 삭제
  Future<void> deleteRecording(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  void dispose() {
    _recordingTimer?.cancel();
    _recorder.dispose();
    _player.dispose();
  }
}
