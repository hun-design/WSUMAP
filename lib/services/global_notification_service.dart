// lib/services/global_notification_service.dart - 전역 알림 서비스
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 전역 알림 서비스 - 앱 전체에서 사용할 수 있는 알림 시스템
class GlobalNotificationService {
  static final GlobalNotificationService _instance = GlobalNotificationService._internal();
  factory GlobalNotificationService() => _instance;
  GlobalNotificationService._internal();

  static GlobalNotificationService get instance => _instance;

  /// 전역 알림 오버레이 표시
  static void showGlobalNotification(
    BuildContext context, {
    required String message,
    required NotificationType type,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    if (!context.mounted) return;

    // 🔥 플랫폼별 햅틱 피드백 최적화
    _triggerHapticFeedback(type);

    // 🔥 루트 컨텍스트를 찾아서 오버레이 표시 (모달 위에 표시되도록)
    final rootContext = _findRootContext(context);
    if (rootContext != null) {
      _showOverlayNotification(
        rootContext,
        message: message,
        type: type,
        duration: duration,
        onTap: onTap,
      );
    } else {
      // 루트 컨텍스트를 찾지 못한 경우 기존 방식 사용
      _showOverlayNotification(
        context,
        message: message,
        type: type,
        duration: duration,
        onTap: onTap,
      );
    }
  }

  /// 루트 컨텍스트 찾기 (모달 위에 오버레이 표시를 위해)
  static BuildContext? _findRootContext(BuildContext context) {
    try {
      // 🔥 루트 네비게이터의 컨텍스트 찾기 (모달 위에 표시되도록)
      final rootNavigator = Navigator.of(context, rootNavigator: true);
      return rootNavigator.context;
    } catch (e) {
      debugPrint('루트 컨텍스트 찾기 실패: $e');
      
      // 🔥 대안: MaterialApp의 컨텍스트 찾기
      try {
        final materialApp = context.findAncestorWidgetOfExactType<MaterialApp>();
        if (materialApp != null) {
          return materialApp.navigatorKey?.currentContext;
        }
      } catch (e2) {
        debugPrint('MaterialApp 컨텍스트 찾기 실패: $e2');
      }
      
      return null;
    }
  }

  /// 플랫폼별 햅틱 피드백 최적화
  static void _triggerHapticFeedback(NotificationType type) {
    try {
      if (Platform.isAndroid) {
        // Android에서 더 강한 햅틱 피드백
        switch (type) {
          case NotificationType.success:
            HapticFeedback.lightImpact();
            break;
          case NotificationType.error:
            HapticFeedback.heavyImpact();
            break;
          case NotificationType.warning:
            HapticFeedback.mediumImpact();
            break;
          case NotificationType.info:
            HapticFeedback.selectionClick();
            break;
        }
      } else if (Platform.isIOS) {
        // iOS에서 더 부드러운 햅틱 피드백
        switch (type) {
          case NotificationType.success:
            HapticFeedback.lightImpact();
            break;
          case NotificationType.error:
            HapticFeedback.mediumImpact(); // iOS에서는 heavy 대신 medium 사용
            break;
          case NotificationType.warning:
            HapticFeedback.lightImpact();
            break;
          case NotificationType.info:
            HapticFeedback.selectionClick();
            break;
        }
      } else {
        // 기타 플랫폼에서는 기본 햅틱 피드백
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      // 햅틱 피드백 실패 시 무시
      debugPrint('햅틱 피드백 실패: $e');
    }
  }

  /// 오버레이 알림 표시
  static void _showOverlayNotification(
    BuildContext context, {
    required String message,
    required NotificationType type,
    required Duration duration,
    VoidCallback? onTap,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    // 🔥 플랫폼별 최적화된 위치 및 스타일
    final topPadding = _getPlatformSpecificTopPadding(context);
    final horizontalPadding = _getPlatformSpecificHorizontalPadding();
    final borderRadius = _getPlatformSpecificBorderRadius();
    final shadowIntensity = _getPlatformSpecificShadowIntensity();

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: topPadding,
        left: horizontalPadding,
        right: horizontalPadding,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: GestureDetector(
              onTap: () {
                overlayEntry.remove();
                onTap?.call();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(type),
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: shadowIntensity),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: _getBorderColor(type),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIcon(type),
                      color: _getIconColor(type),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          color: _getTextColor(type),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.close,
                      color: _getIconColor(type).withValues(alpha: 0.7),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // 자동 제거
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  /// 플랫폼별 최적화된 상단 패딩
  static double _getPlatformSpecificTopPadding(BuildContext context) {
    if (Platform.isAndroid) {
      // Android에서는 상태바 높이 + 추가 패딩
      return MediaQuery.of(context).padding.top + 16;
    } else if (Platform.isIOS) {
      // iOS에서는 안전 영역 고려
      return MediaQuery.of(context).padding.top + 12;
    } else {
      // 기타 플랫폼
      return MediaQuery.of(context).padding.top + 10;
    }
  }

  /// 플랫폼별 최적화된 수평 패딩
  static double _getPlatformSpecificHorizontalPadding() {
    if (Platform.isAndroid) {
      return 16;
    } else if (Platform.isIOS) {
      return 20; // iOS에서는 더 넓은 패딩
    } else {
      return 16;
    }
  }

  /// 플랫폼별 최적화된 테두리 반경
  static double _getPlatformSpecificBorderRadius() {
    if (Platform.isAndroid) {
      return 12; // Material Design 스타일
    } else if (Platform.isIOS) {
      return 16; // iOS 스타일
    } else {
      return 12;
    }
  }

  /// 플랫폼별 최적화된 그림자 강도
  static double _getPlatformSpecificShadowIntensity() {
    if (Platform.isAndroid) {
      return 0.15; // Android에서는 더 강한 그림자
    } else if (Platform.isIOS) {
      return 0.1; // iOS에서는 더 부드러운 그림자
    } else {
      return 0.1;
    }
  }

  /// 알림 타입별 배경색
  static Color _getBackgroundColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return const Color(0xFF10B981).withValues(alpha: 0.95);
      case NotificationType.error:
        return const Color(0xFFEF4444).withValues(alpha: 0.95);
      case NotificationType.warning:
        return const Color(0xFFF59E0B).withValues(alpha: 0.95);
      case NotificationType.info:
        return const Color(0xFF3B82F6).withValues(alpha: 0.95);
    }
  }

  /// 알림 타입별 테두리색
  static Color _getBorderColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return const Color(0xFF10B981).withValues(alpha: 0.3);
      case NotificationType.error:
        return const Color(0xFFEF4444).withValues(alpha: 0.3);
      case NotificationType.warning:
        return const Color(0xFFF59E0B).withValues(alpha: 0.3);
      case NotificationType.info:
        return const Color(0xFF3B82F6).withValues(alpha: 0.3);
    }
  }

  /// 알림 타입별 아이콘색
  static Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Colors.white;
      case NotificationType.error:
        return Colors.white;
      case NotificationType.warning:
        return Colors.white;
      case NotificationType.info:
        return Colors.white;
    }
  }

  /// 알림 타입별 텍스트색
  static Color _getTextColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Colors.white;
      case NotificationType.error:
        return Colors.white;
      case NotificationType.warning:
        return Colors.white;
      case NotificationType.info:
        return Colors.white;
    }
  }

  /// 알림 타입별 아이콘
  static IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.warning:
        return Icons.warning_outlined;
      case NotificationType.info:
        return Icons.info_outline;
    }
  }

  /// 성공 알림 표시
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    showGlobalNotification(
      context,
      message: message,
      type: NotificationType.success,
      duration: duration,
      onTap: onTap,
    );
  }

  /// 에러 알림 표시
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    showGlobalNotification(
      context,
      message: message,
      type: NotificationType.error,
      duration: duration,
      onTap: onTap,
    );
  }

  /// 경고 알림 표시
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    showGlobalNotification(
      context,
      message: message,
      type: NotificationType.warning,
      duration: duration,
      onTap: onTap,
    );
  }

  /// 정보 알림 표시
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    showGlobalNotification(
      context,
      message: message,
      type: NotificationType.info,
      duration: duration,
      onTap: onTap,
    );
  }
}

/// 알림 타입 열거형
enum NotificationType {
  success,
  error,
  warning,
  info,
}
