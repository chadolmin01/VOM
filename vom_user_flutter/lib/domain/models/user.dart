/// 사용자 모델 (Supabase 스키마와 1:1 매핑)
class User {
  final String id;
  final String deviceId;
  final String? name;
  final String userType;
  final String region;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? lastActiveAt;

  const User({
    required this.id,
    required this.deviceId,
    this.name,
    this.userType = '일반',
    this.region = '미상',
    this.phone,
    this.createdAt,
    this.lastActiveAt,
  });

  /// Supabase JSON에서 생성
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      deviceId: json['device_id']?.toString() ?? '',
      name: json['name']?.toString(),
      userType: json['user_type']?.toString() ?? '일반',
      region: json['region']?.toString() ?? '미상',
      phone: json['phone']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'].toString())
          : null,
    );
  }

  /// Supabase에 저장할 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      if (name != null) 'name': name,
      'user_type': userType,
      'region': region,
      if (phone != null) 'phone': phone,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (lastActiveAt != null)
        'last_active_at': lastActiveAt!.toIso8601String(),
    };
  }
}
