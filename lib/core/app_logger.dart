// lib/core/app_logger.dart - 최적화된 버전
import 'package:flutter/foundation.dart';

/// 🔥 로그 레벨 enum
enum LogLevel {
  debug(0, '🐛', 'DEBUG'),
  info(1, 'ℹ️', 'INFO'),
  warning(2, '⚠️', 'WARN'),
  error(3, '❌', 'ERROR'),
  critical(4, '🚨', 'CRITICAL');
  
  const LogLevel(this.value, this.emoji, this.name);
  final int value;
  final String emoji;
  final String name;
}

/// 🔥 통합 로깅 시스템
class AppLogger {
  static const String _appName = 'WoosongMap';
  static bool _isEnabled = kDebugMode; // 디버그 모드에서만 기본 활성화
  static LogLevel _minimumLevel = LogLevel.debug;
  
  /// 로깅 설정
  static void configure({
    bool? enabled,
    LogLevel? minimumLevel,
  }) {
    _isEnabled = enabled ?? kDebugMode;
    _minimumLevel = minimumLevel ?? LogLevel.debug;
  }
  
  /// 디버그 로그
  static void debug(String message, {String? tag, Object? extra}) {
    _log(LogLevel.debug, message, tag: tag, extra: extra);
  }
  
  /// 정보 로그
  static void info(String message, {String? tag, Object? extra}) {
    _log(LogLevel.info, message, tag: tag, extra: extra);
  }
  
  /// 경고 로그
  static void warning(String message, {String? tag, Object? extra}) {
    _log(LogLevel.warning, message, tag: tag, extra: extra);
  }
  
  /// 에러 로그
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, extra: error);
    if (stackTrace != null && kDebugMode) {
      debugPrint('📍 Stack Trace: $stackTrace');
    }
  }
  
  /// 크리티컬 로그
  static void critical(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.critical, message, tag: tag, extra: error);
    if (stackTrace != null && kDebugMode) {
      debugPrint('📍 Stack Trace: $stackTrace');
    }
  }
  
  /// 메인 로그 메서드 (성능 최적화)
  static void _log(LogLevel level, String message, {String? tag, Object? extra}) {
    // 🔥 빠른 종료 조건 체크 (성능 최적화)
    if (!_isEnabled || level.value < _minimumLevel.value) {
      return;
    }
    
    // 🔥 문자열 생성 최적화 (불필요한 연산 제거)
    final logMessage = _buildLogMessage(level, message, tag, extra);
    
    if (kDebugMode) {
      debugPrint(logMessage);
    }
    
    // 프로덕션에서는 크리티컬 에러만 외부 로깅
    if (kReleaseMode && level == LogLevel.critical) {
      _sendToRemoteLogging(level, message, tag, extra);
    }
  }
  
  /// 로그 메시지 생성 (성능 최적화)
  static String _buildLogMessage(LogLevel level, String message, String? tag, Object? extra) {
    // 🔥 StringBuffer 사용으로 메모리 최적화
    final buffer = StringBuffer();
    buffer.write(level.emoji);
    buffer.write(' $_appName ${level.name} ');
    buffer.write(DateTime.now().toIso8601String());
    
    if (tag != null) {
      buffer.write(' [$tag]');
    }
    
    buffer.write(' $message');
    
    if (extra != null) {
      buffer.write(' | Extra: $extra');
    }
    
    return buffer.toString();
  }
  
  /// 원격 로깅 (프로덕션용)
  static void _sendToRemoteLogging(LogLevel level, String message, String? tag, Object? extra) {
    // Firebase Crashlytics, Sentry 등으로 전송
    // 현재는 구현하지 않음
  }
  
  /// Result<T> 전용 로깅 메서드
  static void logResult<T>(dynamic result, {String? tag, String? context}) {
    if (result == null) return;
    
    final resultStr = result.toString();
    if (resultStr.contains('Success')) {
      info('${context ?? 'Operation'} 성공', tag: tag);
    } else if (resultStr.contains('Failure')) {
      error('${context ?? 'Operation'} 실패', tag: tag);
    }
  }
  
  /// 비동기 Result 로깅
  static Future<T> logAsyncResult<T>(
    Future<T> futureResult, {
    String? tag,
    String? context,
  }) async {
    try {
      final result = await futureResult;
      logResult(result, tag: tag, context: context);
      return result;
    } catch (e, stackTrace) {
      error(
        '${context ?? 'Async operation'} 예외 발생: $e',
        tag: tag,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

/// 🔥 도메인별 로거 베이스 클래스 (중복 코드 제거)
abstract class DomainLogger {
  final String _tag;
  
  const DomainLogger(this._tag);
  
  void debug(String message, {Object? extra}) =>
      AppLogger.debug(message, tag: _tag, extra: extra);
  
  void info(String message, {Object? extra}) =>
      AppLogger.info(message, tag: _tag, extra: extra);
  
  void warning(String message, {Object? extra}) =>
      AppLogger.warning(message, tag: _tag, extra: extra);
  
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      AppLogger.error(message, tag: _tag, error: error, stackTrace: stackTrace);
}

/// 🔥 도메인별 로거들 (베이스 클래스 상속)
class MapLogger extends DomainLogger {
  const MapLogger() : super('MAP');
  
  void markerAdded(String markerType, int count) =>
      info('마커 추가: $markerType ($count개)');
  
  void cameraMove(double lat, double lng, double zoom) =>
      debug('카메라 이동: ($lat, $lng) zoom: $zoom');
  
  void overlayOperation(String operation, String overlayId, bool success) =>
      success 
          ? debug('오버레이 $operation 성공: $overlayId')
          : error('오버레이 $operation 실패: $overlayId');
}

class ApiLogger extends DomainLogger {
  const ApiLogger() : super('API');
  
  void request(String method, String url, {Map<String, dynamic>? params}) =>
      debug('$method $url', extra: params);
  
  void response(String url, int statusCode, {Object? data}) =>
      statusCode >= 200 && statusCode < 300
          ? debug('응답 성공: $url ($statusCode)')
          : error('응답 실패: $url ($statusCode)', error: data);
  
  void timeout(String url, Duration duration) =>
      warning('API 타임아웃: $url (${duration.inSeconds}초)');
}

class CategoryLogger extends DomainLogger {
  const CategoryLogger() : super('CATEGORY');
  
  void selection(String category, int buildingCount) =>
      info('카테고리 선택: $category (건물: ${buildingCount}개)');
  
  void iconGeneration(String category, bool success) =>
      success
          ? debug('카테고리 아이콘 생성 성공: $category')
          : error('카테고리 아이콘 생성 실패: $category');
}

class SearchLogger extends DomainLogger {
  const SearchLogger() : super('SEARCH');
  
  void query(String query, int resultCount, Duration duration) =>
      info('검색 완료: "$query" (결과: ${resultCount}개, ${duration.inMilliseconds}ms)');
  
  void indexBuild(int buildingCount, Duration duration) =>
      info('검색 인덱스 구축: ${buildingCount}개 건물 (${duration.inMilliseconds}ms)');
}

/// 🔥 Result와 Logger를 결합한 헬퍼
extension ResultLogging on dynamic {
  dynamic log({String? tag, String? context}) {
    AppLogger.logResult(this, tag: tag, context: context);
    return this;
  }
  
  dynamic logOnFailure({String? tag, String? context}) {
    if (toString().contains('Failure')) {
      AppLogger.error(
        '${context ?? 'Operation'} 실패',
        tag: tag,
      );
    }
    return this;
  }
  
  dynamic logOnSuccess({String? tag, String? context}) {
    if (toString().contains('Success')) {
      AppLogger.info(
        '${context ?? 'Operation'} 성공',
        tag: tag,
      );
    }
    return this;
  }
}

/// 🔥 성능 측정 헬퍼
class PerformanceLogger {
  static const String _tag = 'PERF';
  
  /// 함수 실행 시간 측정
  static Future<T> measureAsync<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await operation();
      stopwatch.stop();
      AppLogger.info(
        '$operationName 완료 (${stopwatch.elapsedMilliseconds}ms)',
        tag: _tag,
      );
      return result;
    } catch (e) {
      stopwatch.stop();
      AppLogger.error(
        '$operationName 실패 (${stopwatch.elapsedMilliseconds}ms): $e',
        tag: _tag,
        error: e,
      );
      rethrow;
    }
  }
  
  /// 동기 함수 실행 시간 측정
  static T measure<T>(
    String operationName,
    T Function() operation,
  ) {
    final stopwatch = Stopwatch()..start();
    try {
      final result = operation();
      stopwatch.stop();
      AppLogger.info(
        '$operationName 완료 (${stopwatch.elapsedMilliseconds}ms)',
        tag: _tag,
      );
      return result;
    } catch (e) {
      stopwatch.stop();
      AppLogger.error(
        '$operationName 실패 (${stopwatch.elapsedMilliseconds}ms): $e',
        tag: _tag,
        error: e,
      );
      rethrow;
    }
  }
}
