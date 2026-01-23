import 'package:flutter/material.dart';
import 'dart:async';

/// [V.O.M 온보딩 - Step 6: 인증번호 입력]
/// 핵심 포인트: 6개의 박스, 키보드 자동 실행, 타이머
class Step06OtpInput extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback onNext;

  const Step06OtpInput({
    super.key,
    required this.phoneNumber,
    required this.onNext,
  });

  @override
  State<Step06OtpInput> createState() => _Step06OtpInputState();
}

class _Step06OtpInputState extends State<Step06OtpInput> {
  // 실제 입력값을 담는 컨트롤러 (화면엔 숨김)
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  // 타이머 관련
  int _timeLeft = 180; // 3분
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // 화면 진입 시 키보드 올리기
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // "03:00" 형식으로 변환
  String get _timerString {
    final minutes = (_timeLeft / 60).floor().toString().padLeft(2, '0');
    final seconds = (_timeLeft % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            // 1. 안내 문구
            Text(
              "${widget.phoneNumber}로\n보낸 숫자를 입력해주세요",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                height: 1.4,
                color: Color(0xFF191F28),
              ),
            ),
            const SizedBox(height: 40),

            // 2. OTP 입력 UI (Stack으로 숨겨진 TextField와 보이는 UI 겹치기)
            Stack(
              children: [
                // 보이는 박스들 (Visual)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    final code = _otpController.text;
                    final isFilled = index < code.length;
                    final isFocused = index == code.length;
                    
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isFilled ? Colors.white : const Color(0xFFF2F4F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          // 포커스 되거나 입력되면 오렌지색
                          color: isFocused || isFilled 
                              ? const Color(0xFFFF7E36) 
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: isFocused
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFF7E36).withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        isFilled ? code[index] : "",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF191F28),
                        ),
                      ),
                    );
                  }),
                ),
                
                // 실제 입력받는 투명 TextField (Logic)
                Opacity(
                  opacity: 0.0,
                  child: TextField(
                    controller: _otpController,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    onChanged: (value) {
                      setState(() {});
                      if (value.length == 6) {
                        // 6자리 다 차면 자동 완료 처리
                        widget.onNext(); 
                      }
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            // 3. 타이머 및 재전송
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF8B95A1)),
                const SizedBox(width: 4),
                Text(
                  _timerString,
                  style: const TextStyle(
                    color: Color(0xFF8B95A1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    // 재전송 로직
                    setState(() => _timeLeft = 180);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("인증번호를 다시 보냈어요")),
                      );
                    }
                  },
                  child: const Text(
                    "문자 다시 받기",
                    style: TextStyle(
                      color: Color(0xFF4E5968),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
