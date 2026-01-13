import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_colors.dart';
import '../services/supabase_service.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/app_widgets.dart';

class NfcReaderScreen extends StatefulWidget {
  const NfcReaderScreen({super.key});

  @override
  State<NfcReaderScreen> createState() => _NfcReaderScreenState();
}

class _NfcReaderScreenState extends State<NfcReaderScreen> {
  bool _isNfcAvailable = false;
  bool _isScanning = false;
  String? _lastTagId;
  List<Map<String, dynamic>> _mappings = [];
  List<Map<String, dynamic>> _cardContents = [];
  bool _isLoadingMappings = true;

  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
    _loadData();
  }

  @override
  void dispose() {
    FlutterNfcKit.finish().catchError((_) {});
    super.dispose();
  }

  Future<void> _loadData() async {
    final mappings = await SupabaseService().fetchMappingsWithContent();
    final contents = await SupabaseService().fetchCardContents();
    
    if (mounted) {
      setState(() {
        _mappings = mappings;
        _cardContents = contents;
        _isLoadingMappings = false;
      });
      
      // Supabase 연결 실패 시 알림
      if (contents.isEmpty && mappings.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Supabase 연결을 확인할 수 없습니다. 인터넷 연결과 Supabase 설정을 확인하세요.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _checkNfcAvailability() async {
    try {
      final availability = await FlutterNfcKit.nfcAvailability;
      if (mounted) {
        setState(() => _isNfcAvailable = availability == NFCAvailability.available);
        if (_isNfcAvailable) _startScanning();
      }
    } catch (e) {
      debugPrint('NFC 확인 오류: $e');
    }
  }

  Future<void> _startScanning() async {
    if (!_isNfcAvailable || _isScanning) return;
    setState(() => _isScanning = true);

    try {
      final tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 30),
        iosAlertMessage: "카드를 가까이 대주세요",
      );
      await FlutterNfcKit.finish();

      if (mounted) {
        setState(() {
          _lastTagId = tag.id;
          _isScanning = false;
        });
        _showUidConfirmModal(tag.id);
      }
    } catch (e) {
      await FlutterNfcKit.finish();
      if (mounted) {
        setState(() => _isScanning = false);
        if (e.toString().contains('timeout') || e.toString().contains('Timeout')) {
          _startScanning();
        }
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('UID 복사됨: $text'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// UID 확인 후 콘텐츠 선택 모달
  void _showUidConfirmModal(String tagId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // UID 표시 섹션
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.nfc, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'NFC 태그 UID',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _copyToClipboard(tagId),
                        icon: const Icon(Icons.copy, size: 20),
                        color: AppColors.primary,
                        tooltip: '복사',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      tagId,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: AppColors.textPrimary,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '연결할 콘텐츠 선택',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 콘텐츠 목록
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _cardContents.length,
                itemBuilder: (context, index) {
                  final content = _cardContents[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            content['icon'] ?? '📦',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      title: Text(
                        content['name'] ?? '알 수 없음',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'ID: ${content['id']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _saveMapping(tagId, content),
                    ),
                  );
                },
              ),
            ),

            // UID만 확인 버튼
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _startScanning();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.gray300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('UID만 확인 (등록 안함)'),
                ),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      if (mounted && !_isScanning) _startScanning();
    });
  }

  // ============================================================
  // 디버그 테스트용: 서버로 전송하는 공통 함수
  // ============================================================
  Future<Map<String, dynamic>> sendNfcDataToSupabase(
    String nfcTagId,
    Map<String, dynamic> content,
  ) async {
    debugPrint('🔄 [DEBUG] 서버로 전송 중: $nfcTagId -> ${content['name']}');
    debugPrint('📍 [DEBUG] 에러 발생 위치: Supabase 전송 단계');
    
    try {
      final success = await SupabaseService().saveNfcMappingV2(
        nfcTagId: nfcTagId,
        cardId: content['id'],
        label: 'vom-${content['id']}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      );

      if (success) {
        debugPrint('✅ [DEBUG] 전송 성공: $nfcTagId');
        return {
          'success': true,
          'message': '전송 성공',
          'error': null,
        };
      } else {
        debugPrint('❌ [DEBUG] 전송 실패: $nfcTagId (Supabase client is null)');
        return {
          'success': false,
          'message': 'Supabase 클라이언트가 초기화되지 않았습니다',
          'error': 'Supabase client is null',
        };
      }
    } on PostgrestException catch (e, stackTrace) {
      debugPrint('❌ [DEBUG] PostgrestException 발생');
      debugPrint('❌ [DEBUG] HTTP 상태 코드: ${e.code}');
      debugPrint('❌ [DEBUG] 에러 메시지: ${e.message}');
      debugPrint('❌ [DEBUG] 에러 상세: ${e.details}');
      debugPrint('❌ [DEBUG] 힌트: ${e.hint}');
      debugPrint('📚 [DEBUG] 스택 트레이스: $stackTrace');
      
      // Supabase 에러 파싱
      final errorInfo = SupabaseService().parseSupabaseError(e);
      
      return {
        'success': false,
        'message': errorInfo['userMessage'] ?? '전송 중 오류가 발생했습니다',
        'error': errorInfo['originalError'] ?? e.toString(),
        'errorType': errorInfo['errorType'],
        'statusCode': errorInfo['statusCode'],
        'errorCode': errorInfo['errorCode'],
        'errorMessage': errorInfo['errorMessage'],
        'stackTrace': stackTrace.toString(),
      };
    } catch (e, stackTrace) {
      debugPrint('❌ [DEBUG] 에러 발생 위치: Supabase 전송 단계');
      debugPrint('❌ [DEBUG] 에러 내용: $e');
      debugPrint('📚 [DEBUG] 스택 트레이스: $stackTrace');
      
      // Supabase 에러 파싱
      final errorInfo = SupabaseService().parseSupabaseError(e);
      
      return {
        'success': false,
        'message': errorInfo['userMessage'] ?? '전송 중 오류가 발생했습니다',
        'error': errorInfo['originalError'] ?? e.toString(),
        'errorType': errorInfo['errorType'],
        'statusCode': errorInfo['statusCode'],
        'errorCode': errorInfo['errorCode'],
        'errorMessage': errorInfo['errorMessage'],
        'stackTrace': stackTrace.toString(),
      };
    }
  }

  // ============================================================
  // Supabase 연결 테스트
  // ============================================================
  Future<void> _testSupabaseConnection() async {
    AppDialogs.showLoading(context, message: 'Supabase 연결 테스트 중...');

    final testResult = await SupabaseService().testConnection();

    if (mounted) {
      AppDialogs.hideLoading(context);

      final isSuccess = testResult['connectionTest'] == true;
      final error = testResult['error'] as String?;
      final details = testResult['details'] as Map<String, dynamic>;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error_outline,
                color: isSuccess ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isSuccess ? '연결 성공!' : '연결 실패',
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('URL: ${testResult['url']}'),
                const SizedBox(height: 8),
                Text('설정 완료: ${testResult['isConfigured'] ? '✅' : '❌'}'),
                Text('클라이언트 존재: ${testResult['clientExists'] ? '✅' : '❌'}'),
                Text('연결 테스트: ${testResult['connectionTest'] ? '✅' : '❌'}'),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  const Text(
                    '에러:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SelectableText(
                      error,
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ),
                ],
                if (details['suggestion'] != null) ...[
                  const SizedBox(height: 12),
                  const Text(
                    '💡 제안:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    details['suggestion'] as String,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
                if (testResult['connectionTest'] == true && details['testResponse'] != null) ...[
                  const SizedBox(height: 12),
                  const Text(
                    '테스트 응답:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SelectableText(
                      details['testResponse'].toString(),
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: testResult.toString()));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('테스트 결과가 클립보드에 복사되었습니다')),
                );
              },
              child: const Text('결과 복사'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  // ============================================================
  // 디버그 테스트용: 테스트 버튼 핸들러
  // ============================================================
  Future<void> _testSendFakeNfcData() async {
    if (_cardContents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('콘텐츠를 먼저 불러와주세요'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 첫 번째 콘텐츠를 테스트용으로 사용
    final testContent = _cardContents.first;
    final fakeTagId = 'TEST_TAG_${DateTime.now().millisecondsSinceEpoch}';

    AppDialogs.showLoading(context, message: '테스트 전송 중...');

    final result = await sendNfcDataToSupabase(fakeTagId, testContent);

    if (mounted) {
      AppDialogs.hideLoading(context);

      if (result['success'] == true) {
        _loadData();
        await AppDialogs.showSuccess(
          context,
          title: '테스트 전송 성공!',
          message: '${testContent['icon']} ${testContent['name']}에 연결되었습니다\n\n테스트 UID: $fakeTagId',
          onConfirm: () {},
        );
      } else {
        // 에러 상세 정보 표시
        await _showErrorDetails(
          title: '테스트 전송 실패',
          errorMessage: result['message'] as String,
          errorDetails: result['error'] as String?,
          errorType: result['errorType'] as String?,
          statusCode: result['statusCode'] as String?,
          errorCode: result['errorCode'] as String?,
          stackTrace: result['stackTrace'] as String?,
        );
      }
    }
  }

  Future<void> _saveMapping(String tagId, Map<String, dynamic> content) async {
    Navigator.pop(context);
    AppDialogs.showLoading(context, message: '저장 중...');

    // 공통 함수 사용
    final result = await sendNfcDataToSupabase(tagId, content);

    if (mounted) {
      AppDialogs.hideLoading(context);

      if (result['success'] == true) {
        _loadData();
        await AppDialogs.showSuccess(
          context,
          title: '등록 완료!',
          message: '${content['icon']} ${content['name']}에 연결되었습니다\n\nUID: $tagId',
          onConfirm: _startScanning,
        );
      } else {
        // 에러 상세 정보 표시
        await _showErrorDetails(
          title: '저장 실패',
          errorMessage: result['message'] as String,
          errorDetails: result['error'] as String?,
          errorType: result['errorType'] as String?,
          statusCode: result['statusCode'] as String?,
          errorCode: result['errorCode'] as String?,
          stackTrace: result['stackTrace'] as String?,
          onConfirm: _startScanning,
        );
      }
    }
  }

  // ============================================================
  // 에러 상세 정보 표시 다이얼로그
  // ============================================================
  Future<void> _showErrorDetails({
    required String title,
    required String errorMessage,
    String? errorDetails,
    String? errorType,
    String? statusCode,
    String? errorCode,
    String? stackTrace,
    VoidCallback? onConfirm,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                errorMessage,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              // HTTP 상태 코드 및 에러 타입 표시
              if (statusCode != null || errorType != null || errorCode != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (statusCode != null && statusCode != 'Unknown')
                        Text('HTTP 상태 코드: $statusCode', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      if (errorCode != null && errorCode != 'Unknown')
                        Text('에러 코드: $errorCode', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      if (errorType != null)
                        Text('에러 타입: $errorType', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
              // 원본 에러 메시지 (터미널 에러 내용 그대로)
              if (errorDetails != null && errorDetails.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  '📋 원본 에러 (터미널 출력):',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SelectableText(
                    errorDetails,
                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.black87),
                  ),
                ),
              ],
              if (stackTrace != null) ...[
                const SizedBox(height: 12),
                const Text(
                  '스택 트레이스:',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  height: 150,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      stackTrace,
                      style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const Text(
                '💡 터미널에서 "flutter logs" 명령어로 더 자세한 로그를 확인할 수 있습니다.',
                style: TextStyle(fontSize: 11, color: Colors.blue),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              String fullError = '제목: $title\n\n에러 메시지: $errorMessage\n';
              if (statusCode != null) fullError += 'HTTP 상태 코드: $statusCode\n';
              if (errorCode != null) fullError += '에러 코드: $errorCode\n';
              if (errorType != null) fullError += '에러 타입: $errorType\n';
              if (errorDetails != null) fullError += '\n원본 에러:\n$errorDetails\n';
              if (stackTrace != null) fullError += '\n스택 트레이스:\n$stackTrace';
              
              Clipboard.setData(ClipboardData(text: fullError));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('에러 정보가 클립보드에 복사되었습니다')),
              );
            },
            child: const Text('에러 복사'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm?.call();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMapping(Map<String, dynamic> item) async {
    final confirmed = await AppDialogs.showConfirm(
      context,
      title: '연결 해제',
      message: 'UID: ${item['nfc_tag_id']}\n\n이 매핑을 삭제하시겠습니까?',
      confirmText: '삭제',
      cancelText: '취소',
      isDangerous: true,
    );

    if (confirmed && mounted) {
      AppDialogs.showLoading(context);
      final success = await SupabaseService().deleteMapping(item['id'].toString());

      if (mounted) {
        AppDialogs.hideLoading(context);
        if (success) {
          _loadData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('삭제되었습니다')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // NFC 불가 시
    if (!_isNfcAvailable && !_isLoadingMappings) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('NFC 카드 등록')),
        body: FeatureUnavailableWidget(
          icon: Icons.nfc,
          title: 'NFC를 사용할 수 없습니다',
          subtitle: '기기에서 NFC를 켜주세요',
          onRetry: _checkNfcAvailability,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('NFC 카드 등록'),
        actions: [
          // Supabase 연결 테스트 버튼
          IconButton(
            onPressed: _testSupabaseConnection,
            icon: const Icon(Icons.cloud),
            tooltip: 'Supabase 연결 테스트',
          ),
          // 디버그 테스트 버튼
          IconButton(
            onPressed: _testSendFakeNfcData,
            icon: const Icon(Icons.bug_report),
            tooltip: '테스트 데이터 전송 (디버그)',
          ),
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
          ),
        ],
      ),
      body: Column(
        children: [
          // 스캔 상태 카드 (UID 표시 포함)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isScanning)
                      const SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.primary,
                        ),
                      ),
                    Icon(
                      Icons.nfc,
                      size: 40,
                      color: _isScanning ? AppColors.primary : AppColors.textTertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _isScanning ? 'NFC 카드를 스캔하세요' : '대기 중',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isScanning ? '카드의 UID를 자동으로 읽습니다' : '스캔이 일시 중지되었습니다',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),

                // 마지막 스캔된 UID 표시
                if (_lastTagId != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _copyToClipboard(_lastTagId!),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.gray50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '마지막 UID: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            _lastTagId!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.copy, size: 14, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 등록된 매핑 목록
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '등록된 매핑',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_mappings.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_mappings.length}개',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _isLoadingMappings
                        ? const Center(child: CircularProgressIndicator())
                        : _mappings.isEmpty
                            ? const EmptyStateWidget(
                                icon: Icons.link_off,
                                title: '등록된 매핑이 없습니다',
                                subtitle: 'NFC 태그를 스캔하여 콘텐츠와 연결하세요',
                              )
                            : ListView.separated(
                                itemCount: _mappings.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final item = _mappings[index];
                                  return _buildMappingItem(item);
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMappingItem(Map<String, dynamic> item) {
    final content = item['card_contents'] as Map<String, dynamic>?;
    final cardName = content?['name'] ?? item['card_id'] ?? '알 수 없음';
    final cardIcon = content?['icon'] ?? '📦';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                cardIcon,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cardName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.nfc, size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item['nfc_tag_id'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (item['label'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    item['label'],
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error,
            onPressed: () => _deleteMapping(item),
          ),
        ],
      ),
    );
  }
}
