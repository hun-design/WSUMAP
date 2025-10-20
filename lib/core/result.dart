// lib/core/result.dart - 최적화된 버전
import 'package:flutter/material.dart';

/// 🔥 Result<T> 패턴 - 에러 처리 표준화
abstract class Result<T> {
  const Result();
  
  /// 성공 케이스
  bool get isSuccess => this is Success<T>;
  
  /// 실패 케이스
  bool get isFailure => this is Failure<T>;
  
  /// 성공 시 데이터 반환, 실패 시 null
  T? get data => isSuccess ? (this as Success<T>).data : null;
  
  /// 실패 시 에러 반환, 성공 시 null
  String? get error => isFailure ? (this as Failure<T>).error : null;
  
  /// 실패 시 에러 코드 반환, 성공 시 null
  String? get errorCode => isFailure ? (this as Failure<T>).errorCode : null;
  
  /// 성공 시 데이터 반환, 실패 시 기본값 반환
  T getOrElse(T defaultValue) => data ?? defaultValue;
  
  /// 성공 시 데이터 반환, 실패 시 예외 발생
  T getOrThrow() {
    if (isSuccess) return (this as Success<T>).data;
    throw Exception(error ?? 'Unknown error');
  }
  
  /// fold 패턴 - 성공/실패에 따른 다른 처리
  R fold<R>(
    R Function(T data) onSuccess,
    R Function(String error, String? errorCode) onFailure,
  ) {
    if (isSuccess) {
      return onSuccess((this as Success<T>).data);
    } else {
      final failure = this as Failure<T>;
      return onFailure(failure.error, failure.errorCode);
    }
  }
  
  /// map 패턴 - 성공 시에만 변환
  Result<R> map<R>(R Function(T data) transform) {
    if (isSuccess) {
      try {
        return Success(transform((this as Success<T>).data));
      } catch (e) {
        return Failure('Transform error: $e');
      }
    } else {
      final failure = this as Failure<T>;
      return Failure<R>(failure.error, failure.errorCode);
    }
  }
  
  /// flatMap 패턴 - 성공 시에만 변환 (Result 반환)
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    if (isSuccess) {
      try {
        return transform((this as Success<T>).data);
      } catch (e) {
        return Failure('FlatMap error: $e');
      }
    } else {
      final failure = this as Failure<T>;
      return Failure<R>(failure.error, failure.errorCode);
    }
  }
  
  /// 성공 케이스 생성자
  static Result<T> success<T>(T data) => Success<T>(data);
  
  /// 실패 케이스 생성자
  static Result<T> failure<T>(String error, [String? errorCode]) => 
      Failure<T>(error, errorCode);
}

/// 🔥 성공 케이스
class Success<T> extends Result<T> {
  final T data;
  
  const Success(this.data);
  
  @override
  String toString() => 'Success(data: $data)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> && 
      runtimeType == other.runtimeType &&
      data == other.data;
  
  @override
  int get hashCode => data.hashCode;
}

/// 🔥 실패 케이스
class Failure<T> extends Result<T> {
  final String _error;
  final String? _errorCode;
  final DateTime? timestamp;
  
  const Failure(this._error, [this._errorCode, this.timestamp]);
  
  Failure.withTimestamp(String error, [String? errorCode]) 
      : _error = error,
        _errorCode = errorCode,
        timestamp = DateTime.now();
  
  @override
  String get error => _error;
  
  @override
  String? get errorCode => _errorCode;
  
  @override
  String toString() => 'Failure(error: $error, errorCode: $errorCode)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> && 
      runtimeType == other.runtimeType &&
      error == other.error &&
      errorCode == other.errorCode;
  
  @override
  int get hashCode => error.hashCode ^ errorCode.hashCode;
}

/// 🔥 Result 확장 메서드들
extension ResultExtensions<T> on Result<T> {
  
  /// 성공 시에만 실행
  Result<T> onSuccess(void Function(T data) action) {
    if (isSuccess) {
      action((this as Success<T>).data);
    }
    return this;
  }
  
  /// 실패 시에만 실행
  Result<T> onFailure(void Function(String error, String? errorCode) action) {
    if (isFailure) {
      final failure = this as Failure<T>;
      action(failure.error, failure.errorCode);
    }
    return this;
  }
  
  /// 조건부 성공 검증
  Result<T> where(bool Function(T data) predicate, String errorMessage) {
    if (isSuccess) {
      final data = (this as Success<T>).data;
      if (predicate(data)) {
        return this;
      } else {
        return Failure<T>(errorMessage, 'VALIDATION_FAILED');
      }
    }
    return this;
  }
  
  /// 성공 시 데이터를 옵셔널로 반환
  T? get dataOrNull => data;
  
  /// 실패 시 에러를 옵셔널로 반환
  String? get errorOrNull => error;
}

/// 🔥 Future<Result<T>> 확장 메서드들
extension FutureResultExtensions<T> on Future<Result<T>> {
  
  /// Future<Result<T>>를 처리하는 헬퍼
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) transform) async {
    final result = await this;
    if (result.isSuccess) {
      try {
        final transformed = await transform(result.data!);
        return Success(transformed);
      } catch (e) {
        return Failure('Async transform error: $e');
      }
    } else {
      return Failure<R>(result.error!, result.errorCode);
    }
  }
  
  /// Future<Result<T>>를 flatMap으로 처리
  Future<Result<R>> flatMapAsync<R>(Future<Result<R>> Function(T data) transform) async {
    final result = await this;
    if (result.isSuccess) {
      try {
        return await transform(result.data!);
      } catch (e) {
        return Failure('Async flatMap error: $e');
      }
    } else {
      return Failure<R>(result.error!, result.errorCode);
    }
  }
  
  /// 성공 시에만 실행
  Future<Result<T>> onSuccessAsync(void Function(T data) action) async {
    final result = await this;
    if (result.isSuccess) {
      action(result.data!);
    }
    return result;
  }
  
  /// 실패 시에만 실행
  Future<Result<T>> onFailureAsync(void Function(String error, String? errorCode) action) async {
    final result = await this;
    if (result.isFailure) {
      action(result.error!, result.errorCode);
    }
    return result;
  }
}

/// 🔥 Result를 안전하게 실행하는 헬퍼 함수들
class ResultHelper {
  
  /// 동기 함수를 Result로 감싸기
  static Result<T> runSafely<T>(T Function() function, [String? errorContext]) {
    try {
      final result = function();
      return Success(result);
    } catch (e, stackTrace) {
      final context = errorContext != null ? '$errorContext: ' : '';
      debugPrint('❌ ${context}Sync error: $e\n$stackTrace');
      return Failure('${context}$e', 'SYNC_ERROR');
    }
  }
  
  /// 비동기 함수를 Result로 감싸기
  static Future<Result<T>> runSafelyAsync<T>(
    Future<T> Function() function, 
    [String? errorContext]
  ) async {
    try {
      final result = await function();
      return Success(result);
    } catch (e, stackTrace) {
      final context = errorContext != null ? '$errorContext: ' : '';
      debugPrint('❌ ${context}Async error: $e\n$stackTrace');
      return Failure('${context}$e', 'ASYNC_ERROR');
    }
  }
  
  /// 여러 Result를 결합하기
  static Result<List<T>> combine<T>(List<Result<T>> results) {
    final List<T> successData = [];
    
    for (final result in results) {
      if (result.isFailure) {
        return Failure<List<T>>(result.error!, result.errorCode);
      }
      successData.add(result.data!);
    }
    
    return Success(successData);
  }
  
  /// 첫 번째 성공한 Result 반환
  static Result<T> firstSuccess<T>(List<Result<T>> results) {
    for (final result in results) {
      if (result.isSuccess) {
        return result;
      }
    }
    
    // 모두 실패한 경우 마지막 실패 반환
    return results.isNotEmpty 
        ? results.last 
        : Failure<T>('No results provided', 'EMPTY_LIST');
  }
  
  /// 모든 Result가 성공인지 확인
  static bool allSuccess<T>(List<Result<T>> results) {
    return results.every((r) => r.isSuccess);
  }
  
  /// 하나라도 성공한 Result가 있는지 확인
  static bool anySuccess<T>(List<Result<T>> results) {
    return results.any((r) => r.isSuccess);
  }
}

/// 🔥 에러 코드 상수들
class ErrorCodes {
  // 기본 에러 코드
  static const String networkError = 'NETWORK_ERROR';
  static const String timeoutError = 'TIMEOUT_ERROR';
  static const String parseError = 'PARSE_ERROR';
  static const String validationError = 'VALIDATION_ERROR';
  static const String notFoundError = 'NOT_FOUND_ERROR';
  static const String permissionError = 'PERMISSION_ERROR';
  static const String cacheError = 'CACHE_ERROR';
  static const String apiError = 'API_ERROR';
  static const String unknownError = 'UNKNOWN_ERROR';
  
  // 도메인별 에러 코드
  static const String buildingNotFound = 'BUILDING_NOT_FOUND';
  static const String categoryNotFound = 'CATEGORY_NOT_FOUND';
  static const String locationPermissionDenied = 'LOCATION_PERMISSION_DENIED';
  static const String mapControllerNotReady = 'MAP_CONTROLLER_NOT_READY';
  static const String routeCalculationFailed = 'ROUTE_CALCULATION_FAILED';
}
