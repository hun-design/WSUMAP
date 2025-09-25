// lib/services/performance_monitor.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// 성능 모니터링 서비스
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, DateTime> _operationStartTimes = {};
  final Map<String, List<Duration>> _operationDurations = {};
  final Map<String, int> _operationCounts = {};

  /// 🔥 작업 시작 시간 기록
  void startOperation(String operationName) {
    _operationStartTimes[operationName] = DateTime.now();
    debugPrint('⏱️ 작업 시작: $operationName');
  }

  /// 🔥 작업 완료 시간 기록 및 성능 측정
  Duration endOperation(String operationName) {
    final startTime = _operationStartTimes.remove(operationName);
    if (startTime == null) {
      debugPrint('⚠️ 작업 시작 시간을 찾을 수 없음: $operationName');
      return Duration.zero;
    }

    final duration = DateTime.now().difference(startTime);
    
    // 성능 통계 업데이트
    _operationDurations.putIfAbsent(operationName, () => []).add(duration);
    _operationCounts[operationName] = (_operationCounts[operationName] ?? 0) + 1;

    debugPrint('⏱️ 작업 완료: $operationName - ${duration.inMilliseconds}ms');
    
    // 성능 경고 (느린 작업 감지)
    if (duration.inMilliseconds > 1000) {
      debugPrint('🐌 느린 작업 감지: $operationName - ${duration.inMilliseconds}ms');
    }

    return duration;
  }

  /// 🔥 평균 성능 통계 조회
  Map<String, dynamic> getPerformanceStats() {
    final stats = <String, dynamic>{};
    
    for (final operation in _operationDurations.keys) {
      final durations = _operationDurations[operation]!;
      final count = _operationCounts[operation] ?? 0;
      
      if (durations.isNotEmpty) {
        final totalMs = durations.fold<int>(0, (sum, duration) => sum + duration.inMilliseconds);
        final avgMs = totalMs / durations.length;
        final minMs = durations.map((d) => d.inMilliseconds).reduce((a, b) => a < b ? a : b);
        final maxMs = durations.map((d) => d.inMilliseconds).reduce((a, b) => a > b ? a : b);
        
        stats[operation] = {
          'count': count,
          'avgMs': avgMs.round(),
          'minMs': minMs,
          'maxMs': maxMs,
          'totalMs': totalMs,
        };
      }
    }
    
    return stats;
  }

  /// 🔥 성능 통계 출력
  void printPerformanceStats() {
    debugPrint('📊 === 성능 통계 ===');
    final stats = getPerformanceStats();
    
    if (stats.isEmpty) {
      debugPrint('📊 성능 데이터가 없습니다.');
      return;
    }
    
    for (final entry in stats.entries) {
      final operation = entry.key;
      final data = entry.value as Map<String, dynamic>;
      debugPrint('📊 $operation:');
      debugPrint('   실행 횟수: ${data['count']}');
      debugPrint('   평균 시간: ${data['avgMs']}ms');
      debugPrint('   최소 시간: ${data['minMs']}ms');
      debugPrint('   최대 시간: ${data['maxMs']}ms');
      debugPrint('   총 시간: ${data['totalMs']}ms');
    }
    debugPrint('📊 ================');
  }

  /// 🔥 느린 작업 감지 및 최적화 제안
  void analyzePerformance() {
    debugPrint('🔍 === 성능 분석 ===');
    final stats = getPerformanceStats();
    
    for (final entry in stats.entries) {
      final operation = entry.key;
      final data = entry.value as Map<String, dynamic>;
      final avgMs = data['avgMs'] as int;
      
      if (avgMs > 2000) {
        debugPrint('🐌 매우 느린 작업: $operation (평균 ${avgMs}ms)');
        debugPrint('💡 최적화 제안: 캐싱, 백그라운드 처리, 비동기 최적화');
      } else if (avgMs > 1000) {
        debugPrint('⚠️ 느린 작업: $operation (평균 ${avgMs}ms)');
        debugPrint('💡 최적화 제안: 네트워크 요청 최적화, UI 업데이트 최적화');
      } else if (avgMs > 500) {
        debugPrint('⚡ 보통 작업: $operation (평균 ${avgMs}ms)');
      } else {
        debugPrint('✅ 빠른 작업: $operation (평균 ${avgMs}ms)');
      }
    }
    debugPrint('🔍 ================');
  }

  /// 🔥 플랫폼별 성능 최적화 제안
  void suggestPlatformOptimizations() {
    debugPrint('🚀 === 플랫폼별 최적화 제안 ===');
    
    if (Platform.isAndroid) {
      debugPrint('🤖 Android 최적화:');
      debugPrint('   - ProGuard/R8 최적화 활성화');
      debugPrint('   - 네이티브 코드 최적화');
      debugPrint('   - 메모리 관리 최적화');
      debugPrint('   - 배터리 최적화 설정');
    } else if (Platform.isIOS) {
      debugPrint('🍎 iOS 최적화:');
      debugPrint('   - Metal 성능 최적화');
      debugPrint('   - Core Animation 최적화');
      debugPrint('   - 메모리 관리 최적화');
      debugPrint('   - 백그라운드 앱 새로고침 최적화');
    }
    
    debugPrint('🌐 공통 최적화:');
    debugPrint('   - 네트워크 요청 최적화');
    debugPrint('   - 이미지 캐싱 및 압축');
    debugPrint('   - 데이터베이스 쿼리 최적화');
    debugPrint('   - UI 렌더링 최적화');
    debugPrint('🚀 =========================');
  }

  /// 🔥 성능 데이터 초기화
  void clearStats() {
    _operationDurations.clear();
    _operationCounts.clear();
    debugPrint('🗑️ 성능 통계 초기화됨');
  }

  /// 🔥 메모리 사용량 모니터링
  void logMemoryUsage(String context) {
    if (kDebugMode) {
      debugPrint('💾 메모리 사용량 ($context): ${DateTime.now().toIso8601String()}');
      // 실제 메모리 사용량은 플랫폼별로 다르게 구현해야 함
    }
  }

  /// 🔥 네트워크 성능 모니터링
  void logNetworkPerformance(String operation, Duration duration, int? responseSize) {
    debugPrint('🌐 네트워크 성능:');
    debugPrint('   작업: $operation');
    debugPrint('   시간: ${duration.inMilliseconds}ms');
    if (responseSize != null) {
      debugPrint('   응답 크기: ${responseSize}bytes');
      final speed = responseSize / (duration.inMilliseconds / 1000);
      debugPrint('   속도: ${speed.toStringAsFixed(2)}bytes/s');
    }
  }
}
