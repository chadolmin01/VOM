import 'package:flutter/material.dart';

/// 학생증 UI
/// 상태를 가지지 않고 (Stateless), 부모가 주는 데이터만 그립니다.
class StudentIDCard extends StatelessWidget {
  final String name;
  final String? phone;
  final bool isFinal;

  const StudentIDCard({
    super.key,
    this.name = "",
    this.phone,
    this.isFinal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 배경 패턴
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.school_rounded,
              size: 100,
              color: const Color(0xFFFF7E36).withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                // 사진 영역
                Container(
                  width: 100,
                  height: 130,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.person_rounded, size: 60, color: Colors.white),
                ),
                const SizedBox(width: 20),
                // 정보 영역
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("성명"),
                      const SizedBox(height: 4),
                      Text(
                        name.isEmpty ? "........" : name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: name.isEmpty ? const Color(0xFFE5E8EB) : const Color(0xFF191F28),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel("소속"),
                      const SizedBox(height: 4),
                      const Text("봄 학교 입학 예정", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(color: Color(0xFF8B95A1), fontSize: 14));
  }
}
