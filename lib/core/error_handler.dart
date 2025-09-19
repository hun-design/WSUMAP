// lib/core/error_handler.dart - 통합 에러 처리 시스템

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../generated/app_localizations.dart';

/// 에러 타입 정의
enum ErrorType {
  network,
  server,
  authentication,
  permission,
  validation,
  unknown,
}

/// 에러 정보 클래스
class AppError {
  final ErrorType type;
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppError({
    required this.type,
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  /// 네트워크 에러 생성
  factory AppError.network(String message, {dynamic originalError}) {
    return AppError(
      type: ErrorType.network,
      message: message,
      originalError: originalError,
    );
  }

  /// 서버 에러 생성
  factory AppError.server(String message, {String? code, dynamic originalError}) {
    return AppError(
      type: ErrorType.server,
      message: message,
      code: code,
      originalError: originalError,
    );
  }

  /// 인증 에러 생성
  factory AppError.authentication(String message, {dynamic originalError}) {
    return AppError(
      type: ErrorType.authentication,
      message: message,
      originalError: originalError,
    );
  }

  /// 권한 에러 생성
  factory AppError.permission(String message, {dynamic originalError}) {
    return AppError(
      type: ErrorType.permission,
      message: message,
      originalError: originalError,
    );
  }

  /// 유효성 검사 에러 생성
  factory AppError.validation(String message, {dynamic originalError}) {
    return AppError(
      type: ErrorType.validation,
      message: message,
      originalError: originalError,
    );
  }

  /// 알 수 없는 에러 생성
  factory AppError.unknown(String message, {dynamic originalError, StackTrace? stackTrace}) {
    return AppError(
      type: ErrorType.unknown,
      message: message,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() {
    return 'AppError(type: $type, message: $message, code: $code)';
  }
}

/// 에러 처리 유틸리티 클래스
class ErrorHandler {
  /// 예외를 AppError로 변환
  static AppError fromException(dynamic error, {StackTrace? stackTrace}) {
    if (error is AppError) {
      return error;
    }

    final String message = error?.toString() ?? 'Unknown error occurred';
    
    // 네트워크 관련 에러 감지
    if (message.contains('SocketException') || 
        message.contains('NetworkException') ||
        message.contains('Connection') ||
        message.contains('TimeoutException')) {
      return AppError.network(message, originalError: error);
    }

    // HTTP 상태 코드 기반 에러 분류
    if (message.contains('401') || message.contains('Unauthorized')) {
      return AppError.authentication(message, originalError: error);
    }

    if (message.contains('403') || message.contains('Forbidden')) {
      return AppError.permission(message, originalError: error);
    }

    if (message.contains('400') || message.contains('Bad Request')) {
      return AppError.validation(message, originalError: error);
    }

    if (message.contains('500') || message.contains('Internal Server Error')) {
      return AppError.server(message, originalError: error);
    }

    return AppError.unknown(message, originalError: error, stackTrace: stackTrace);
  }

  /// 사용자 친화적인 에러 메시지 생성
  static String getUserFriendlyMessage(AppError error, AppLocalizations l10n) {
    switch (error.type) {
      case ErrorType.network:
        return l10n.network_error;
      case ErrorType.server:
        return l10n.server_error;
      case ErrorType.authentication:
        return l10n.login_error;
      case ErrorType.permission:
        return l10n.locationPermissionRequired;
      case ErrorType.validation:
        return l10n.validation_error;
      case ErrorType.unknown:
        return l10n.unknown_error;
    }
  }

  /// 에러 로깅
  static void logError(AppError error, {String? context}) {
    final prefix = context != null ? '[$context] ' : '';
    debugPrint('❌ ${prefix}${error.type}: ${error.message}');
    
    if (error.originalError != null) {
      debugPrint('   Original: ${error.originalError}');
    }
    
    if (error.stackTrace != null) {
      debugPrint('   Stack: ${error.stackTrace}');
    }
  }

  /// 네트워크 연결 상태 확인
  static Future<bool> isNetworkAvailable() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return !connectivityResult.contains(ConnectivityResult.none);
    } catch (e) {
      debugPrint('네트워크 상태 확인 실패: $e');
      return false;
    }
  }

  /// 안전한 비동기 작업 실행
  static Future<T?> safeExecute<T>(
    Future<T> Function() operation, {
    String? context,
    T? fallback,
    bool logErrors = true,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      final appError = fromException(e, stackTrace: stackTrace);
      
      if (logErrors) {
        logError(appError, context: context);
      }
      
      return fallback;
    }
  }

  /// 에러 스낵바 표시
  static void showErrorSnackBar(
    BuildContext context,
    AppError error, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final l10n = AppLocalizations.of(context)!;
    final message = getUserFriendlyMessage(error, l10n);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        duration: duration,
        action: SnackBarAction(
          label: l10n.confirm,
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
