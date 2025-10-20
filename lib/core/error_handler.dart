// lib/core/error_handler.dart - 최적화된 버전

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
  final DateTime timestamp;

  AppError({
    required this.type,
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime(0);

  /// 네트워크 에러 생성
  factory AppError.network(String message, {dynamic originalError}) {
    return AppError(
      type: ErrorType.network,
      message: message,
      originalError: originalError,
      timestamp: DateTime.now(),
    );
  }

  /// 서버 에러 생성
  factory AppError.server(String message, {String? code, dynamic originalError}) {
    return AppError(
      type: ErrorType.server,
      message: message,
      code: code,
      originalError: originalError,
      timestamp: DateTime.now(),
    );
  }

  /// 인증 에러 생성
  factory AppError.authentication(String message, {dynamic originalError}) {
    return AppError(
      type: ErrorType.authentication,
      message: message,
      originalError: originalError,
      timestamp: DateTime.now(),
    );
  }

  /// 권한 에러 생성
  factory AppError.permission(String message, {dynamic originalError}) {
    return AppError(
      type: ErrorType.permission,
      message: message,
      originalError: originalError,
      timestamp: DateTime.now(),
    );
  }

  /// 유효성 검사 에러 생성
  factory AppError.validation(String message, {dynamic originalError}) {
    return AppError(
      type: ErrorType.validation,
      message: message,
      originalError: originalError,
      timestamp: DateTime.now(),
    );
  }

  /// 알 수 없는 에러 생성
  factory AppError.unknown(String message, {dynamic originalError, StackTrace? stackTrace}) {
    return AppError(
      type: ErrorType.unknown,
      message: message,
      originalError: originalError,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'AppError(type: $type, message: $message, code: $code)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppError &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => type.hashCode ^ message.hashCode ^ (code?.hashCode ?? 0);
}

/// 에러 처리 유틸리티 클래스
class ErrorHandler {
  /// 예외를 AppError로 변환
  static AppError fromException(dynamic error, {StackTrace? stackTrace}) {
    if (error is AppError) {
      return error;
    }

    final String message = error?.toString() ?? 'Unknown error occurred';
    
    // 🔥 에러 타입 감지 최적화 (정규식 사용)
    if (_isNetworkError(message)) {
      return AppError.network(message, originalError: error);
    }

    if (_isAuthError(message)) {
      return AppError.authentication(message, originalError: error);
    }

    if (_isPermissionError(message)) {
      return AppError.permission(message, originalError: error);
    }

    if (_isValidationError(message)) {
      return AppError.validation(message, originalError: error);
    }

    if (_isServerError(message)) {
      return AppError.server(message, originalError: error);
    }

    return AppError.unknown(message, originalError: error, stackTrace: stackTrace);
  }

  /// 네트워크 에러 감지
  static bool _isNetworkError(String message) {
    return message.contains('SocketException') || 
           message.contains('NetworkException') ||
           message.contains('Connection') ||
           message.contains('TimeoutException') ||
           message.contains('Failed host lookup');
  }

  /// 인증 에러 감지
  static bool _isAuthError(String message) {
    return message.contains('401') || 
           message.contains('Unauthorized') ||
           message.contains('인증') ||
           message.contains('Authentication');
  }

  /// 권한 에러 감지
  static bool _isPermissionError(String message) {
    return message.contains('403') || 
           message.contains('Forbidden') ||
           message.contains('권한') ||
           message.contains('Permission');
  }

  /// 유효성 검사 에러 감지
  static bool _isValidationError(String message) {
    return message.contains('400') || 
           message.contains('Bad Request') ||
           message.contains('검증') ||
           message.contains('Validation');
  }

  /// 서버 에러 감지
  static bool _isServerError(String message) {
    return message.contains('500') || 
           message.contains('Internal Server Error') ||
           message.contains('서버');
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
