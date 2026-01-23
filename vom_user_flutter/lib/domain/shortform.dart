class Shortform {
  final String id;
  final String title;
  final String category; // 예: 요리, 목욕, 놀이
  final String videoUrl;
  final String? nfcTagCode; // NFC 스티커와 매핑할 코드

  const Shortform({
    required this.id,
    required this.title,
    required this.category,
    required this.videoUrl,
    this.nfcTagCode,
  });
}

