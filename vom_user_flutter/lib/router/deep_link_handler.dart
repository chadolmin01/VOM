import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/nfc_contents.dart';
import '../services/mission_repository.dart';
import '../services/vibration_service.dart';
import '../services/tts_service.dart';
import '../widgets/mission_error_bottom_sheet.dart';
import '../screens/learning_screen.dart';

/// 전역 네비게이터 키 (딥링크가 어디서 들어와도 사용)
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// vom://mission/{mission_id} 딥링크를 처리하는 핸들러
class DeepLinkHandler {
  DeepLinkHandler._internal();
  static final DeepLinkHandler instance = DeepLinkHandler._internal();

  final MissionRepository _missionRepository = MissionRepository();
  final TtsService _tts = TtsService();

  Uri? lastUri;
  String? lastMissionId;
  String? lastError;

  /// 앱 시작 시 한 번만 호출 (initial link)
  Future<void> handleInitialLink(AppLinks appLinks) async {
    try {
      // app_links 6.x 에서는 getInitialLink() 를 사용
      final uri = await appLinks.getInitialLink();
      if (uri != null) {
        await handleUri(uri);
      }
    } catch (e) {
      debugPrint('❌ DeepLinkHandler.handleInitialLink error: $e');
    }
  }

  /// 앱 실행 중 스트림으로 들어오는 딥링크 처리
  Future<void> handleUri(Uri uri) async {
    lastUri = uri;
    lastError = null;

    debugPrint('🔗 DeepLink received: $uri');

    if (uri.scheme != 'vom' || uri.host != 'mission') {
      lastError = 'invalid_scheme_or_host';
      debugPrint('❌ DeepLink invalid scheme/host: $uri');
      await _showError(
        title: '알 수 없는 링크예요',
        message: '지원하지 않는 주소입니다.',
      );
      return;
    }

    if (uri.pathSegments.isEmpty || uri.pathSegments.first.isEmpty) {
      lastError = 'missing_mission_id';
      debugPrint('❌ DeepLink missing mission id: $uri');
      await _showError(
        title: '잘못된 링크예요',
        message: '미션 ID가 비어 있어요.',
      );
      return;
    }

    final missionId = uri.pathSegments.first;
    lastMissionId = missionId;

    debugPrint('🎯 DeepLink missionId: $missionId');

    try {
      await VibrationService.tap();
      final card = await _missionRepository.loadByMissionId(missionId);

      if (card == null) {
        lastError = 'mission_not_found';
        debugPrint('❌ DeepLink mission not found: $missionId');
        await _tts.speak('이 미션을 찾을 수 없어요. 다시 태그해 주세요.');
        await _showError(
          title: '미션을 찾을 수 없어요',
          message: '링크에 해당하는 학습 카드를 찾지 못했어요.',
          idLabel: 'ID',
          idValue: missionId,
        );
        return;
      }

      debugPrint(
        '✅ DeepLink mission loaded: ${card.id} / ${card.name}',
      );

      await _tts.speak('${card.name} 학습을 시작합니다');

      final navigator = rootNavigatorKey.currentState;
      if (navigator == null) {
        debugPrint('❌ DeepLinkHandler: navigator is null');
        return;
      }

      navigator.push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              LearningScreen(card: card),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
        ),
      );
    } catch (e) {
      lastError = 'unexpected_error';
      debugPrint('❌ DeepLinkHandler.handleUri unexpected error: $e');
      await _tts.speak('잠시 후 다시 시도해 주세요.');
      await _showError(
        title: '문제가 발생했어요',
        message: '잠시 후 다시 시도해 주세요.',
      );
    }
  }

  Future<void> _showError({
    required String title,
    required String message,
    String? idLabel,
    String? idValue,
  }) async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      return;
    }
    await showMissionNotFoundBottomSheet(
      context,
      title: title,
      message: message,
      idLabel: idLabel,
      idValue: idValue,
      helpText: 'NFC 카드를 다시 태그하거나 QR코드를 다시 인식해 주세요.',
    );
  }

  /// 디버그용: 가상의 URI를 바로 테스트
  Future<void> triggerDebugTest({String missionId = 'debug_test'}) async {
    if (!kDebugMode) return;
    final uri = Uri.parse('vom://mission/$missionId');
    debugPrint('🐛 DeepLink debug trigger: $uri');
    await handleUri(uri);
  }
}

