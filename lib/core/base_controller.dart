// lib/core/base_controller.dart - 최적화된 기본 컨트롤러

import 'package:flutter/material.dart';
import '../utils/performance_utils.dart';
import 'error_handler.dart';

/// 모든 컨트롤러의 기본 클래스
abstract class BaseController extends ChangeNotifier {
  bool _disposed = false;
  bool _isLoading = false;
  AppError? _lastError;
  
  final Debouncer _notifyDebouncer = Debouncer(
    delay: const Duration(milliseconds: 16), // 60fps에 맞춤
  );

  /// 로딩 상태
  bool get isLoading => _isLoading;

  /// 마지막 에러
  AppError? get lastError => _lastError;

  /// Dispose 상태
  bool get disposed => _disposed;

  /// 안전한 상태 변경
  void safeSetState(VoidCallback callback) {
    if (!_disposed) {
      callback();
      _notifyDebouncer.call(() {
        if (!_disposed) {
          notifyListeners();
        }
      });
    }
  }

  /// 로딩 상태 설정
  void setLoading(bool loading) {
    safeSetState(() {
      _isLoading = loading;
      if (loading) {
        _lastError = null; // 로딩 시작 시 이전 에러 클리어
      }
    });
  }

  /// 에러 설정
  void setError(AppError error) {
    ErrorHandler.logError(error, context: runtimeType.toString());
    safeSetState(() {
      _lastError = error;
      _isLoading = false;
    });
  }

  /// 에러 클리어
  void clearError() {
    safeSetState(() {
      _lastError = null;
    });
  }

  /// 안전한 비동기 작업 실행
  Future<T?> executeAsync<T>(
    Future<T> Function() operation, {
    bool showLoading = true,
    String? operationName,
  }) async {
    if (_disposed) return null;

    try {
      if (showLoading) setLoading(true);
      
      if (operationName != null) {
        PerformanceProfiler.start(operationName);
      }

      final result = await operation();
      
      if (operationName != null) {
        PerformanceProfiler.end(operationName);
      }

      if (showLoading) setLoading(false);
      return result;
      
    } catch (e, stackTrace) {
      final appError = ErrorHandler.fromException(e, stackTrace: stackTrace);
      setError(appError);
      
      if (operationName != null) {
        PerformanceProfiler.end(operationName);
      }
      
      return null;
    }
  }

  /// 재시도 가능한 작업 실행
  Future<T?> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    bool showLoading = true,
    String? operationName,
  }) async {
    if (_disposed) return null;

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        if (showLoading && attempt == 0) setLoading(true);
        
        final result = await operation();
        
        if (showLoading) setLoading(false);
        clearError();
        return result;
        
      } catch (e, stackTrace) {
        if (attempt == maxRetries) {
          // 최종 시도 실패
          final appError = ErrorHandler.fromException(e, stackTrace: stackTrace);
          setError(appError);
          return null;
        } else {
          // 재시도 대기
          debugPrint('재시도 ${attempt + 1}/$maxRetries - ${operationName ?? 'operation'}');
          await Future.delayed(retryDelay);
        }
      }
    }
    
    return null;
  }

  /// 배치 상태 업데이트
  void batchUpdate(VoidCallback updates) {
    if (!_disposed) {
      updates();
      _notifyDebouncer.call(() {
        if (!_disposed) {
          notifyListeners();
        }
      });
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _notifyDebouncer.dispose();
    super.dispose();
  }
}

/// 리스트 기반 컨트롤러의 기본 클래스
abstract class BaseListController<T> extends BaseController {
  final MemoryEfficientList<T> _items = MemoryEfficientList<T>();
  
  /// 아이템 목록
  List<T> get items => _items.items;

  /// 아이템 개수
  int get itemCount => _items.length;

  /// 비어있는지 확인
  bool get isEmpty => _items.isEmpty;

  /// 비어있지 않은지 확인
  bool get isNotEmpty => _items.isNotEmpty;

  /// 아이템 추가
  void addItem(T item) {
    safeSetState(() {
      _items.add(item);
    });
  }

  /// 여러 아이템 추가
  void addItems(List<T> items) {
    safeSetState(() {
      _items.addAll(items);
    });
  }

  /// 아이템 클리어
  void clearItems() {
    safeSetState(() {
      _items.clear();
    });
  }

  /// 아이템 필터링
  List<T> filterItems(bool Function(T) predicate) {
    return _items.items.where(predicate).toList();
  }

  /// 페이지네이션 지원
  List<T> getPaginatedItems(int page, int pageSize) {
    final startIndex = page * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, _items.length);
    
    if (startIndex >= _items.length) return [];
    
    return _items.items.sublist(startIndex, endIndex);
  }

  @override
  void dispose() {
    _items.clear();
    super.dispose();
  }
}

/// 캐시 기능이 있는 컨트롤러
abstract class BaseCachedController<T> extends BaseController {
  final Map<String, T> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheExpiry;

  BaseCachedController({
    Duration cacheExpiry = const Duration(minutes: 10),
  }) : _cacheExpiry = cacheExpiry;

  /// 캐시에서 데이터 가져오기
  T? getCached(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp != null) {
      final age = DateTime.now().difference(timestamp);
      if (age > _cacheExpiry) {
        _cache.remove(key);
        _cacheTimestamps.remove(key);
        return null;
      }
    }
    return _cache[key];
  }

  /// 캐시에 데이터 저장
  void setCached(String key, T data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// 캐시 삭제
  void removeCached(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
  }

  /// 캐시 클리어
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// 만료된 캐시 정리
  void cleanExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) > _cacheExpiry) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  @override
  void dispose() {
    clearCache();
    super.dispose();
  }
}
