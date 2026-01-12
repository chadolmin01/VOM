class LearningLog {
  final String id;
  final String deviceId;
  final String cardName;
  final String cardIcon;
  final String? speechText;
  final bool? quizCorrect;
  final List<String>? riskKeywords;
  final DateTime completedAt;

  LearningLog({
    required this.id,
    required this.deviceId,
    required this.cardName,
    required this.cardIcon,
    this.speechText,
    this.quizCorrect,
    this.riskKeywords,
    required this.completedAt,
  });

  factory LearningLog.fromJson(Map<String, dynamic> json) {
    return LearningLog(
      id: json['id'] ?? '',
      deviceId: json['device_id'] ?? '',
      cardName: json['card_name'] ?? '',
      cardIcon: json['card_icon'] ?? '📋',
      speechText: json['speech_text'],
      quizCorrect: json['quiz_correct'],
      riskKeywords: json['risk_keywords'] != null
          ? List<String>.from(json['risk_keywords'])
          : null,
      completedAt: DateTime.parse(json['completed_at']),
    );
  }

  bool get hasRisk => riskKeywords != null && riskKeywords!.isNotEmpty;

  /// device_id 기반으로 사용자 이름 반환
  String get userName => getUserFromDeviceId(deviceId).name;

  String get formattedTime {
    final hour = completedAt.hour.toString().padLeft(2, '0');
    final minute = completedAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get formattedDate {
    return '${completedAt.month}/${completedAt.day} $formattedTime';
  }
}

// 더미 사용자 데이터 (device_id 기반 매핑용)
class DummyUser {
  final String id;
  final String name;
  final String type;
  final String region;
  final String phone;

  const DummyUser({
    required this.id,
    required this.name,
    required this.type,
    required this.region,
    required this.phone,
  });
}

const List<DummyUser> dummyUsers = [
  DummyUser(id: 'USER_001', name: '김*미', type: '다문화', region: '수원시', phone: '010-****-1234'),
  DummyUser(id: 'USER_002', name: '이*진', type: '한부모', region: '화성시', phone: '010-****-5678'),
  DummyUser(id: 'USER_003', name: 'Nguyen', type: '다문화', region: '안산시', phone: '010-****-9012'),
  DummyUser(id: 'USER_004', name: '박*수', type: '경계선', region: '수원시', phone: '010-****-3456'),
];

DummyUser getUserFromDeviceId(String deviceId) {
  final hash = deviceId.codeUnits.fold<int>(0, (a, b) => a + b);
  return dummyUsers[hash % dummyUsers.length];
}
