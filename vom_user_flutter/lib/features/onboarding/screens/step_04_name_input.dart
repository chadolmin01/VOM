import 'package:flutter/material.dart';
import '../widgets/student_id_card.dart';
import '../widgets/floating_widget.dart';

/// [V.O.M 온보딩 - Step 4: 이름 입력 화면]
/// 특징: Voice First (음성 우선), Clear Exit (비상구), Micro-copy (대화형 문구)
class Step04NameInput extends StatefulWidget {
  final String currentName;
  final Function(String) onNameSubmitted;
  final VoidCallback onBack; // [Clear Exit] 뒤로가기 콜백 추가

  const Step04NameInput({
    super.key,
    required this.currentName,
    required this.onNameSubmitted,
    required this.onBack,
  });

  @override
  State<Step04NameInput> createState() => _Step04NameInputState();
}

class _Step04NameInputState extends State<Step04NameInput> with TickerProviderStateMixin {
  late TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();
  
  // 애니메이션 컨트롤러
  late AnimationController _micPulseController;
  
  // 상태 변수
  bool _isInputMode = false; // false: 음성 모드(기본), true: 키보드 모드
  double _buttonScale = 1.0;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.currentName);

    // 마이크 펄스 애니메이션 (숨 쉬는 듯한 효과)
    _micPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _micPulseController.dispose();
    super.dispose();
  }

  void _onConfirmTap() {
    setState(() => _buttonScale = 0.95);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _buttonScale = 1.0);
      widget.onNameSubmitted(_textController.text);
    });
  }

  // 음성 입력 시뮬레이션
  void _simulateStt() {
    // 실제로는 여기서 STT 리스닝 시작
    setState(() {
      _textController.text = "김봄이";
      _isInputMode = true; // 입력이 되면 확인 모드(키보드 모드와 유사 UI)로 전환
    });
  }

  @override
  Widget build(BuildContext context) {
    // 키보드 올라왔는지 확인
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardUp = bottomInset > 0;

    return PopScope(
      canPop: false, // 시스템 뒤로가기 제어
      onPopInvoked: (didPop) {
        if (!didPop) widget.onBack();
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              // --- [Clear Exit] 상단 네비게이션 ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF8B95A1)),
                  label: const Text(
                    "이전으로",
                    style: TextStyle(
                      fontSize: 16, 
                      color: Color(0xFF505967),
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),

              // --- [상단] 질문 영역 ---
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isKeyboardUp ? 0 : 80,
                curve: Curves.easeInOut,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Text(
                    _isInputMode ? "입력하신 성함이\n맞으신가요?" : "어머니의 성함을\n말씀해 주세요",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      color: Color(0xFF191F28),
                    ),
                  ),
                ),
              ),

              // --- [중앙] 메인 콘텐츠 (학생증 vs 초대형 마이크) ---
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 1. 학생증 (입력 모드일 때만 표시)
                        if (_isInputMode)
                          FloatingWidget(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: StudentIDCard(name: _textController.text),
                            ),
                          )
                        // 2. [Voice First] 초대형 마이크 버튼 (음성 모드일 때 표시)
                        else
                          GestureDetector(
                            onTap: _simulateStt,
                            child: AnimatedBuilder(
                              animation: _micPulseController,
                              builder: (context, child) {
                                final scale = 1.0 + (_micPulseController.value * 0.1);
                                return Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    width: 180,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF7E36).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFFF7E36).withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.mic_rounded,
                                        size: 80,
                                        color: Color(0xFFFF7E36),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        
                        const SizedBox(height: 32),

                        // 안내 문구
                        if (!_isInputMode)
                           const Text(
                            "\"김봄이\"\n처럼 말씀하시면 돼요", // 예시 제공
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF8B95A1),
                              height: 1.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- [하단] 버튼 영역 ---
              Container(
                padding: EdgeInsets.only(
                  left: 24, 
                  right: 24, 
                  bottom: isKeyboardUp ? 16 : 24,
                  top: 16
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8F1),
                  boxShadow: isKeyboardUp ? [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                  ] : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 입력 모드일 때: 수정 입력창 보여주기
                    if (_isInputMode) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFF7E36), width: 2),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(border: InputBorder.none),
                          onChanged: (val) => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 메인 액션 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isInputMode 
                            ? (_textController.text.length >= 2 ? _onConfirmTap : null)
                            : () {
                                // '글자로 쓸래요' 버튼 클릭 시
                                setState(() {
                                  _isInputMode = true;
                                });
                                // 약간의 딜레이 후 키보드 올리기
                                Future.delayed(const Duration(milliseconds: 100), () {
                                  _focusNode.requestFocus();
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isInputMode ? const Color(0xFFFF7E36) : Colors.white,
                          foregroundColor: _isInputMode ? Colors.white : const Color(0xFF4E5968),
                          elevation: 0,
                          side: _isInputMode ? BorderSide.none : const BorderSide(color: Color(0xFFE5E8EB), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          _isInputMode ? "네, 이 이름이 맞아요" : "글자로 쓸래요 ⌨️", // [Micro-copy]
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
