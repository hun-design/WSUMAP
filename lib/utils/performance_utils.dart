// lib/utils/performance_utils.dart - 성능 최적화 유틸리티

import 'dart:async';
import 'package:flutter/material.dart';

/// Debouncer 클래스 - 빈번한 호출을 제한
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void call(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Throttler 클래스 - 일정 간격으로만 실행
class Throttler {
  final Duration interval;
  DateTime? _lastExecutionTime;

  Throttler({required this.interval});

  bool execute(VoidCallback callback) {
    final now = DateTime.now();
    
    if (_lastExecutionTime == null || 
        now.difference(_lastExecutionTime!) >= interval) {
      _lastExecutionTime = now;
      callback();
      return true;
    }
    
    return false;
  }
}

/// 메모리 효율적인 리스트 관리
class MemoryEfficientList<T> {
  final List<T> _items = [];
  final int maxSize;

  MemoryEfficientList({this.maxSize = 1000});

  void add(T item) {
    _items.add(item);
    if (_items.length > maxSize) {
      _items.removeAt(0); // FIFO 방식으로 오래된 항목 제거
    }
  }

  void addAll(Iterable<T> items) {
    for (final item in items) {
      add(item);
    }
  }

  List<T> get items => List.unmodifiable(_items);
  int get length => _items.length;
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  void clear() => _items.clear();
}

/// 위젯 리빌드 최적화 도우미
class RebuildOptimizer {
  static final Map<String, dynamic> _cache = {};

  /// 값이 변경된 경우에만 true 반환
  static bool shouldRebuild<T>(String key, T newValue) {
    final oldValue = _cache[key];
    final shouldUpdate = oldValue != newValue;
    
    if (shouldUpdate) {
      _cache[key] = newValue;
    }
    
    return shouldUpdate;
  }

  /// 캐시 초기화
  static void clearCache() {
    _cache.clear();
  }

  /// 특정 키의 캐시 제거
  static void removeFromCache(String key) {
    _cache.remove(key);
  }
}

/// 배치 처리 유틸리티
class BatchProcessor<T> {
  final int batchSize;
  final Duration delay;
  final Function(List<T>) processor;
  
  final List<T> _pending = [];
  Timer? _timer;

  BatchProcessor({
    required this.batchSize,
    required this.delay,
    required this.processor,
  });

  void add(T item) {
    _pending.add(item);
    
    if (_pending.length >= batchSize) {
      _processBatch();
    } else {
      _scheduleProcessing();
    }
  }

  void _scheduleProcessing() {
    _timer?.cancel();
    _timer = Timer(delay, _processBatch);
  }

  void _processBatch() {
    if (_pending.isNotEmpty) {
      final batch = List<T>.from(_pending);
      _pending.clear();
      _timer?.cancel();
      
      try {
        processor(batch);
      } catch (e) {
        debugPrint('배치 처리 중 오류: $e');
      }
    }
  }

  void flush() {
    _processBatch();
  }

  void dispose() {
    _timer?.cancel();
    _pending.clear();
  }
}

/// 리소스 관리 도우미
class ResourceManager {
  static final Map<String, dynamic> _resources = {};
  static final Map<String, Timer> _timers = {};

  /// 리소스 등록
  static void register<T>(String key, T resource) {
    _resources[key] = resource;
  }

  /// 리소스 가져오기
  static T? get<T>(String key) {
    return _resources[key] as T?;
  }

  /// 리소스 제거
  static void remove(String key) {
    _resources.remove(key);
    _timers[key]?.cancel();
    _timers.remove(key);
  }

  /// 자동 만료 리소스 등록
  static void registerWithExpiry<T>(
    String key, 
    T resource, 
    Duration expiry,
  ) {
    register(key, resource);
    
    _timers[key]?.cancel();
    _timers[key] = Timer(expiry, () {
      remove(key);
    });
  }

  /// 모든 리소스 정리
  static void clear() {
    _resources.clear();
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }
}

/// 성능 측정 도우미
class PerformanceProfiler {
  static final Map<String, DateTime> _startTimes = {};
  static final Map<String, List<Duration>> _measurements = {};

  /// 측정 시작
  static void start(String operation) {
    _startTimes[operation] = DateTime.now();
  }

  /// 측정 종료 및 결과 반환
  static Duration? end(String operation) {
    final startTime = _startTimes.remove(operation);
    if (startTime == null) return null;

    final duration = DateTime.now().difference(startTime);
    
    _measurements.putIfAbsent(operation, () => []).add(duration);
    
    // 최근 100개 측정값만 유지
    final measurements = _measurements[operation]!;
    if (measurements.length > 100) {
      measurements.removeAt(0);
    }

    debugPrint('⏱️ $operation: ${duration.inMilliseconds}ms');
    return duration;
  }

  /// 평균 실행 시간 계산
  static Duration? getAverageTime(String operation) {
    final measurements = _measurements[operation];
    if (measurements == null || measurements.isEmpty) return null;

    final totalMs = measurements
        .map((d) => d.inMilliseconds)
        .reduce((a, b) => a + b);
    
    return Duration(milliseconds: totalMs ~/ measurements.length);
  }

  /// 모든 측정 결과 출력
  static void printSummary() {
    debugPrint('=== Performance Summary ===');
    for (final operation in _measurements.keys) {
      final avg = getAverageTime(operation);
      final count = _measurements[operation]!.length;
      debugPrint('$operation: ${avg?.inMilliseconds}ms (avg over $count calls)');
    }
    debugPrint('==========================');
  }

  /// 측정 데이터 초기화
  static void clear() {
    _startTimes.clear();
    _measurements.clear();
  }
}

/// 메모리 사용량 모니터링
class MemoryMonitor {
  static void logMemoryUsage(String context) {
    try {
      // 기본적인 메모리 정보 로깅
      debugPrint('🧠 Memory check at $context');
      
      // Flutter에서 직접적인 메모리 사용량 측정은 제한적이므로
      // 여기서는 로깅만 수행하고, 필요시 플랫폼별 구현을 추가할 수 있음
    } catch (e) {
      debugPrint('메모리 모니터링 오류: $e');
    }
  }
}
