// lib/friends/friends_utils.dart - 최적화된 버전

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application_1/generated/app_localizations.dart';

/// 친구 화면에서 사용되는 유틸리티 함수들
class FriendsUtils {
  
  /// 사용자 ID 마스킹 함수
  static String maskUserId(String userId) {
    if (userId.length <= 4) return userId;
    return userId.substring(0, 4) + '*' * (userId.length - 4);
  }

  /// 성공 메시지 표시
  static void showSuccessMessage(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 에러 메시지 표시
  static void showErrorMessage(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// 전화번호 처리 함수
  static Future<void> handlePhone(BuildContext context, String phone) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse('tel:$phone');
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(AppLocalizations.of(context)!.phone_app_error),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  /// 친구 추가 에러 메시지 처리
  static String getAddFriendErrorMessage(BuildContext context, dynamic error) {
    final l10n = AppLocalizations.of(context)!;
    final errorString = error.toString();

    // 에러 타입별 메시지 매핑
    if (_containsAny(errorString, ['존재하지 않는 사용자'])) {
      return l10n.user_not_found;
    } else if (_containsAny(errorString, ['이미 친구'])) {
      return l10n.already_friend;
    } else if (_containsAny(errorString, ['이미 요청'])) {
      return l10n.already_requested;
    } else if (_containsAny(errorString, ['자기 자신'])) {
      return l10n.cannot_add_self;
    } else if (_containsAny(errorString, ['잘못된'])) {
      return l10n.invalid_user_id;
    } else if (_containsAny(errorString, ['서버 오류'])) {
      return l10n.server_error_retry;
    } else {
      return errorString.replaceAll('Exception: ', '');
    }
  }

  /// 여러 문자열 중 하나라도 포함되어 있는지 확인
  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }
}
