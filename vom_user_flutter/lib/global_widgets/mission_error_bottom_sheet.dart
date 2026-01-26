import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// 미션/NFC/QR를 찾지 못했을 때 공통으로 사용하는 바텀시트
Future<void> showMissionNotFoundBottomSheet(
  BuildContext context, {
  required String title,
  required String message,
  String? idLabel,
  String? idValue,
  String? helpText,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    builder: (context) => Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🤔', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          if (idLabel != null && idValue != null) ...[
            const SizedBox(height: 8),
            Text(
              '$idLabel: $idValue',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
                fontFamily: 'monospace',
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (helpText != null)
            Text(
              helpText,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('다시 시도하기'),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

