import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 앱 전체에서 사용하는 다이얼로그/알림 모음
class AppDialogs {
  AppDialogs._();

  /// 성공 다이얼로그
  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = '확인',
    VoidCallback? onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => _ResultDialog(
        icon: Icons.check_circle,
        iconColor: AppColors.success,
        iconBgColor: AppColors.successLight,
        title: title,
        message: message,
        buttonText: buttonText,
        onConfirm: onConfirm,
      ),
    );
  }

  /// 에러 다이얼로그
  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = '확인',
    VoidCallback? onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => _ResultDialog(
        icon: Icons.error_outline,
        iconColor: AppColors.error,
        iconBgColor: AppColors.errorLight,
        title: title,
        message: message,
        buttonText: buttonText,
        onConfirm: onConfirm,
      ),
    );
  }

  /// 확인 다이얼로그 (예/아니오)
  static Future<bool> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = '확인',
    String cancelText = '취소',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message, style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText, style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmText,
              style: TextStyle(color: isDangerous ? AppColors.error : AppColors.primary),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 로딩 다이얼로그
  static void showLoading(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(message, style: TextStyle(color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 로딩 닫기
  static void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

/// 결과 다이얼로그 (성공/에러 공용)
class _ResultDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onConfirm;

  const _ResultDialog({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.message,
    required this.buttonText,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(buttonText),
          ),
        ),
      ],
    );
  }
}
