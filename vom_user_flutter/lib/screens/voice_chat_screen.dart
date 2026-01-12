import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/ai_chat_service.dart';
import '../services/stt_service.dart';
import '../services/tts_service.dart';
import '../services/vibration_service.dart';

/// 음성 AI 채팅 화면
class VoiceChatScreen extends StatefulWidget {
  final String? cardName;
  final List<String>? cardScripts;

  const VoiceChatScreen({
    super.key,
    this.cardName,
    this.cardScripts,
  });

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen>
    with TickerProviderStateMixin {
  final AiChatService _aiService = AiChatService();
  final SttService _sttService = SttService();
  final TtsService _ttsService = TtsService();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isListening = false;
  bool _isProcessing = false;
  bool _isSpeaking = false;
  String _recognizedText = '';
  String _lastResponse = '';

  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initServices();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initServices() async {
    await _sttService.init();

    // 학습 컨텍스트 설정
    if (widget.cardName != null) {
      _aiService.setLearningContext(
        cardName: widget.cardName!,
        scripts: widget.cardScripts ?? [],
      );
    }

    // 시작 인사
    await Future.delayed(const Duration(milliseconds: 500));
    final greeting = widget.cardName != null
        ? '${widget.cardName}에 대해 궁금한 점이 있으신가요? 말씀해 주세요!'
        : '안녕하세요! 육아에 대해 궁금한 점을 물어보세요.';

    _addMessage(greeting, isUser: false);
    await _speak(greeting);
  }

  void _addMessage(String text, {required bool isUser}) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: isUser));
    });
  }

  Future<void> _speak(String text) async {
    setState(() => _isSpeaking = true);
    await _ttsService.speak(text);
    if (mounted) {
      setState(() => _isSpeaking = false);
    }
  }

  Future<void> _startListening() async {
    if (_isListening || _isProcessing || _isSpeaking) return;

    await VibrationService.tap();
    await _ttsService.stop();

    setState(() {
      _isListening = true;
      _recognizedText = '';
    });

    await _sttService.startListening(
      onResult: (text, isFinal) {
        setState(() {
          _recognizedText = text;
        });

        if (isFinal && text.isNotEmpty) {
          _processUserInput(text);
        }
      },
    );
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;

    await _sttService.stopListening();
    setState(() => _isListening = false);

    if (_recognizedText.isNotEmpty) {
      _processUserInput(_recognizedText);
    }
  }

  Future<void> _processUserInput(String text) async {
    setState(() {
      _isListening = false;
      _isProcessing = true;
    });

    // 사용자 메시지 추가
    _addMessage(text, isUser: true);

    // AI 응답 받기
    final response = await _aiService.chat(text);

    setState(() {
      _isProcessing = false;
      _lastResponse = response;
    });

    // AI 응답 추가 및 음성 출력
    _addMessage(response, isUser: false);
    await VibrationService.success();
    await _speak(response);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sttService.cancel();
    _ttsService.stop();
    _aiService.clearContext();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          widget.cardName != null ? '${widget.cardName} 도우미' : 'AI 도우미',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 채팅 메시지 목록
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[_messages.length - 1 - index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),

          // 인식 중인 텍스트
          if (_recognizedText.isNotEmpty && _isListening)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mic, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _recognizedText,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 하단 컨트롤
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.record_voice_over_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '마이크 버튼을 누르고\n말씀해 주세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: message.isUser ? const Radius.circular(4) : null,
            bottomLeft: !message.isUser ? const Radius.circular(4) : null,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!message.isUser) ...[
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : AppColors.textPrimary,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 상태 표시
            Text(
              _getStatusText(),
              style: TextStyle(
                color: _isListening ? AppColors.primary : AppColors.textSecondary,
                fontWeight: _isListening ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 16),

            // 마이크 버튼
            GestureDetector(
              onTapDown: (_) => _startListening(),
              onTapUp: (_) => _stopListening(),
              onTapCancel: () => _stopListening(),
              child: ScaleTransition(
                scale: _isListening ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _isListening
                        ? AppColors.primary
                        : (_isProcessing || _isSpeaking)
                            ? AppColors.divider
                            : AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: _isListening
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _isListening
                        ? Icons.mic
                        : _isProcessing
                            ? Icons.hourglass_top_rounded
                            : _isSpeaking
                                ? Icons.volume_up_rounded
                                : Icons.mic_none_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText() {
    if (_isListening) return '듣고 있어요...';
    if (_isProcessing) return '생각하는 중...';
    if (_isSpeaking) return '말하는 중...';
    return '버튼을 누르고 말해주세요';
  }
}

/// 채팅 메시지 모델
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
