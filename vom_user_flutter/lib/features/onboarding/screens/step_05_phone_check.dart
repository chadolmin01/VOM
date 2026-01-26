import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 숫자 입력 포맷터용
import '../widgets/student_id_card.dart';
import '../widgets/floating_widget.dart';

/// [V.O.M 온보딩 - Step 5: 휴대폰 번호 확인]
/// 특징: 질문(상단) → 학생증(중앙) → 입력(하단) 구조, 청킹(Chunking) 입력창
class Step05PhoneCheck extends StatefulWidget {
  final String userName;
  final Function(String) onNext;
  final VoidCallback onBack; // 뒤로가기

  const Step05PhoneCheck({
    super.key,
    required this.userName,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Step05PhoneCheck> createState() => _Step05PhoneCheckState();
}

class _Step05PhoneCheckState extends State<Step05PhoneCheck> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  double _buttonScale = 1.0;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isKeyboardVisible = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onConfirmTap() {
    setState(() => _buttonScale = 0.95);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _buttonScale = 1.0);
      widget.onNext(_phoneController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardUp = bottomInset > 0;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) { if (!didPop) widget.onBack(); },
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
                  label: const Text("이전으로", style: TextStyle(fontSize: 16, color: Color(0xFF505967), fontWeight: FontWeight.w600)),
                  style: TextButton.styleFrom(padding: const EdgeInsets.all(12), backgroundColor: Colors.transparent),
                ),
              ),

              // --- [상단] 질문 영역 ---
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isKeyboardUp ? 0 : 60, // 키보드 올라오면 숨김
                curve: Curves.easeInOut,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: const Text(
                    "휴대폰 번호를\n입력해주세요",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold, height: 1.3, color: Color(0xFF191F28),
                    ),
                  ),
                ),
              ),

              // --- [중앙] 학생증 (Hero) ---
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: isKeyboardUp ? 0.85 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutBack,
                          child: FloatingWidget(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: StudentIDCard(
                                name: widget.userName,
                                // 입력 중인 번호를 실시간으로 보여줌 (없으면 '번호 입력 중...')
                                phone: _phoneController.text.isEmpty ? "번호 입력 중..." : _phoneController.text, 
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),

                        if (!isKeyboardUp)
                          const Text(
                            "입력하신 번호로\n인증 문자를 보내드려요 📩",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Color(0xFF8B95A1), height: 1.5),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- [하단] 입력창 & 버튼 ---
              Container(
                padding: EdgeInsets.only(left: 24, right: 24, bottom: isKeyboardUp ? 16 : 24, top: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8F1),
                  boxShadow: isKeyboardUp ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))] : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // [Chunking Input] 시각적으로 끊어주기
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _focusNode.hasFocus ? const Color(0xFFFF7E36) : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _focusNode.hasFocus ? const Color(0xFFFF7E36).withOpacity(0.15) : Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.smartphone_rounded, color: Color(0xFF8B95A1)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              focusNode: _focusNode,
                              keyboardType: TextInputType.number,
                              autofocus: true,
                              // 자동 하이픈 포맷터
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                _PhoneNumberFormatter(),
                              ],
                              style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Color(0xFF191F28),
                              ),
                              decoration: const InputDecoration(
                                hintText: "010-0000-0000",
                                hintStyle: TextStyle(color: Color(0xFFE5E8EB)),
                                border: InputBorder.none,
                              ),
                              onChanged: (val) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _phoneController.text.length >= 12 ? _onConfirmTap : null, // 010-XXXX-XXXX 대략 12자 이상
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7E36),
                          disabledBackgroundColor: const Color(0xFFF2F4F6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text("인증 문자 받기", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
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

// 간단한 하이픈(-) 자동 추가 포맷터
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.length > 13) return oldValue; // 길이 제한

    // 숫자만 추출
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    
    // 010-1234-5678 형태로 포맷팅
    String formatted = '';
    if (digitsOnly.length > 0) {
      if (digitsOnly.length <= 3) {
        formatted = digitsOnly;
      } else if (digitsOnly.length <= 7) {
        formatted = '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3)}';
      } else {
        formatted = '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 7)}-${digitsOnly.substring(7)}';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
