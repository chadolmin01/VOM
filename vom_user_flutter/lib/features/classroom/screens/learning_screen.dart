import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/nfc_contents.dart';
import '../../../data/services/tts_service.dart';
import '../../../data/services/audio_service.dart';
import '../../../data/services/vibration_service.dart';
import '../../../data/services/supabase_service.dart';
import '../../../data/services/learning_session_tracker.dart';
import '../../home/screens/tag_wait_screen.dart';
import '../../community/screens/voice_chat_screen.dart';

enum LearningStage { loading, playing, recording, quiz, complete }

class LearningScreen extends StatefulWidget {
  final CardContent card;

  const LearningScreen({super.key, required this.card});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen>
    with TickerProviderStateMixin {
  final TtsService _tts = TtsService();
  final AudioService _audio = AudioService();
  final LearningSessionTracker _sessionTracker = LearningSessionTracker();

  late CardContent _card;
  LearningStage _stage = LearningStage.loading;
  int _currentScriptIndex = 0;
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  int? _selectedQuizAnswer;
  bool? _isQuizCorrect;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _card = widget.card;

    // 학습 화면 진입 시점을 태그 시각으로 기록
    _sessionTracker.recordTagged();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startLearning();
  }

  Future<void> _startLearning() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _stage = LearningStage.playing);
    _playScript();
  }

  Future<void> _playScript() async {
    if (_currentScriptIndex >= _card.scripts.length) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _stage = LearningStage.recording);
      await _tts.speak('이제 따라 말해보세요. 마이크 버튼을 누르세요.');
      return;
    }
    await _tts.speak(_card.scripts[_currentScriptIndex]);
    _tts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() => _currentScriptIndex++);
      Future.delayed(const Duration(milliseconds: 500), _playScript);
    });
  }

  void _toggleRecording() async {
    if (_isRecording) {
      _recordingTimer?.cancel();
      await _audio.stopRecording();
      if (!mounted) return;
      setState(() => _isRecording = false);

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      // 퀴즈가 있으면 퀴즈로, 없으면 완료로
      if (_card.hasQuiz) {
        setState(() => _stage = LearningStage.quiz);
        await _tts.speak(_card.quizQuestion!);
      } else {
        setState(() => _stage = LearningStage.complete);
        _sendLearningLog();
      }
    } else {
      final started = await _audio.startRecording();
      if (!started) return;

      await VibrationService.tap();
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return timer.cancel();
        setState(() => _recordingSeconds++);
      });
    }
  }

  void _selectQuizAnswer(int index) async {
    if (_selectedQuizAnswer != null || _card.quizOptions == null) return;
    final isCorrect = index == _card.quizCorrectIndex;

    setState(() {
      _selectedQuizAnswer = index;
      _isQuizCorrect = isCorrect;
    });

    if (isCorrect) {
      await VibrationService.success();
      await _tts.speak('정답이에요!');
    } else {
      await VibrationService.error();
      await _tts.speak('아쉬워요. 정답은 ${_card.quizOptions![_card.quizCorrectIndex]}입니다.');
    }

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _stage = LearningStage.complete);
    _sendLearningLog();
  }

  Future<void> _sendLearningLog() async {
    // 완료 시각 기록
    _sessionTracker.recordCompleted();

    // 데모용 발화 텍스트 (실제로는 STT 결과 사용)
    const demoSpeechTexts = [
      '버튼을 누르고 겨드랑이에 넣어요',
      '약을 흔들어서 스포이드로 빨아요',
      '콩알만큼 짜서 위아래로 닦아요',
      '아이가 열이 나요',
      '사랑해 우리 아가',
    ];
    final speechText = demoSpeechTexts[DateTime.now().second % demoSpeechTexts.length];

    // 위험 키워드 감지
    final riskKeywordList = detectRiskKeywords(speechText);
    _sessionTracker.addRiskKeywords(riskKeywordList);

    // 위기 지수 계산
    final riskScore = _sessionTracker.calculateRiskScore();

    await SupabaseService().sendLearningLog(
      cardName: _card.name,
      cardIcon: _card.icon,
      cardId: _card.id,
      speechText: speechText,
      quizCorrect: _isQuizCorrect,
      riskKeywords: riskKeywordList.isNotEmpty ? riskKeywordList : null,
      reactionTime: _sessionTracker.reactionTime,
      retryCount: _sessionTracker.retryCount,
      riskScore: riskScore,
      taggedAt: _sessionTracker.taggedAt,
      completedAt: _sessionTracker.completedAt,
    );
  }

  void _skipToNextStage() async {
    await _tts.stop();
    setState(() {
      if (_stage == LearningStage.playing) _stage = LearningStage.recording;
      else if (_stage == LearningStage.recording) {
        if (_card.hasQuiz) {
          _stage = LearningStage.quiz;
        } else {
          _stage = LearningStage.complete;
        }
      }
      else if (_stage == LearningStage.quiz) _stage = LearningStage.complete;
      else Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _recordingTimer?.cancel();
    _tts.stop();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          _stage == LearningStage.complete ? '학습 완료' : _card.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // AI 도우미 버튼
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VoiceChatScreen(
                    cardName: _card.name,
                    cardScripts: _card.scripts,
                  ),
                ),
              );
            },
          ),
          if (_stage != LearningStage.complete && _stage != LearningStage.loading)
            TextButton(
              onPressed: _skipToNextStage,
              child: const Text('건너뛰기', style: TextStyle(color: AppColors.textSecondary)),
            )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 20,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    int step = 0;
    if (_stage == LearningStage.recording) step = 1;
    if (_stage == LearningStage.quiz) step = 2;
    if (_stage == LearningStage.complete) step = 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: index <= step ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContent() {
    switch (_stage) {
      case LearningStage.loading: return _buildLoading();
      case LearningStage.playing: return _buildPlaying();
      case LearningStage.recording: return _buildRecording();
      case LearningStage.quiz: return _buildQuiz();
      case LearningStage.complete: return _buildComplete();
    }
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Text(_card.icon, style: const TextStyle(fontSize: 80)),
          ),
          const SizedBox(height: 24),
          const Text(
            '학습을 준비하고 있어요',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaying() {
    final currentScript = _currentScriptIndex < _card.scripts.length
        ? _card.scripts[_currentScriptIndex]
        : '듣기 완료!';

    return Column(
      children: [
        // 큰 아이콘 애니메이션
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                _card.icon,
                style: const TextStyle(fontSize: 80),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 단계 표시
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                '${_currentScriptIndex + 1} / ${_card.scripts.length}단계',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 스크립트 텍스트 (말풍선 스타일)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            currentScript,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.6,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        const Spacer(),

        // 시각적 가이드 (단계별 일러스트)
        _buildStepIllustration(),

        const Spacer(),
      ],
    );
  }

  /// 단계별 일러스트 (이모지 기반)
  Widget _buildStepIllustration() {
    // 체온계 예시: 단계별 이모지
    final stepEmojis = _getStepEmojis();
    if (stepEmojis.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(stepEmojis.length, (index) {
        final isActive = index == _currentScriptIndex;
        final isPassed = index < _currentScriptIndex;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 60 : 50,
                height: isActive ? 60 : 50,
                decoration: BoxDecoration(
                  color: isPassed
                      ? AppColors.success.withOpacity(0.1)
                      : isActive
                          ? AppColors.primary.withOpacity(0.2)
                          : AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isPassed
                        ? AppColors.success
                        : isActive
                            ? AppColors.primary
                            : AppColors.divider,
                    width: isActive ? 3 : 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    stepEmojis[index],
                    style: TextStyle(fontSize: isActive ? 28 : 24),
                  ),
                ),
              ),
              if (isPassed)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(Icons.check_circle, color: AppColors.success, size: 16),
                ),
            ],
          ),
        );
      }),
    );
  }

  /// 카드별 단계 이모지 정의
  List<String> _getStepEmojis() {
    switch (_card.name) {
      case '체온계':
        return ['🌡️', '💪', '⏱️', '✅'];
      case '기저귀':
        return ['🔓', '🧷', '👶', '✅'];
      case '분유':
        return ['🍼', '💧', '🔥', '👶'];
      case '손 소독제':
        return ['✋', '💧', '🙌', '✨'];
      default:
        return [];
    }
  }

  Widget _buildRecording() {
    return Column(
      children: [
        const Spacer(),
        const Text(
          '방금 들은 내용을\n따라 말해보세요',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _toggleRecording,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _isRecording ? AppColors.error : AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isRecording ? AppColors.error : AppColors.primary).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: _isRecording ? 10 : 0,
                ),
              ],
            ),
            child: Icon(
              _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (_isRecording)
          Text(
            '녹음 중... ${_recordingSeconds}s',
            style: const TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          )
        else
          const Text(
            '버튼을 눌러 녹음 시작',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        const Spacer(),
      ],
    );
  }

  Widget _buildQuiz() {
    if (!_card.hasQuiz) {
      return const Center(child: Text('퀴즈가 없습니다'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('퀴즈', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(
          _card.quizQuestion!,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),
        ...List.generate(_card.quizOptions!.length, (index) {
          final isSelected = _selectedQuizAnswer == index;
          final isCorrect = index == _card.quizCorrectIndex;

          Color bgColor = AppColors.background;
          Color borderColor = Colors.transparent;

          if (_selectedQuizAnswer != null) {
            if (isCorrect) {
              bgColor = AppColors.success.withOpacity(0.1);
              borderColor = AppColors.success;
            } else if (isSelected) {
              bgColor = AppColors.error.withOpacity(0.1);
              borderColor = AppColors.error;
            }
          }

          return GestureDetector(
            onTap: () => _selectQuizAnswer(index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Row(
                children: [
                  Text(
                    _card.quizOptions![index],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (_selectedQuizAnswer != null && isCorrect)
                    const Icon(Icons.check_circle, color: AppColors.success),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildComplete() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified_rounded, size: 80, color: AppColors.primary),
          const SizedBox(height: 24),
          const Text(
            '학습 완료!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            '${_card.name} 카드를 마스터했어요',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const TagWaitScreen()),
                );
              },
              child: const Text('확인'),
            ),
          ),
        ],
      ),
    );
  }
}
