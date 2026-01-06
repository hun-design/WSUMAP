// lib/repositories/building_repository.dart - 완전 수정된 버전
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/building.dart';
import '../services/building_api_service.dart';
import '../services/building_data_service.dart';
import '../core/result.dart';
import '../core/app_logger.dart';

/// 건물 데이터의 단일 진실 공급원 (Single Source of Truth)
class BuildingRepository extends ChangeNotifier {
  static BuildingRepository? _instance;

  factory BuildingRepository() {
    // dispose된 인스턴스면 새로 생성
    if (_instance == null || _instance!._isDisposed) {
      _instance = BuildingRepository._internal();
    }
    return _instance!;
  }

  BuildingRepository._internal();

  // 🔥 단일 데이터 저장소
  List<Building> _allBuildings = [];
  bool _isLoaded = false;
  bool _isLoading = false;
  String? _lastError;
  DateTime? _lastLoadTime;
  bool _isDisposed = false;

  // 🔥 서비스 인스턴스들
  final BuildingDataService _buildingDataService = BuildingDataService();

  // 🔥 콜백 관리
  final List<Function(List<Building>)> _dataChangeListeners = [];

  // Getters
  List<Building> get allBuildings => List.unmodifiable(_allBuildings);
  bool get isLoaded => _isLoaded;
  bool get isLoading => _isLoading;
  bool get hasData => _allBuildings.isNotEmpty;
  String? get lastError => _lastError;
  DateTime? get lastLoadTime => _lastLoadTime;
  int get buildingCount => _allBuildings.length;
  bool get isDisposed => _isDisposed;

  /// 🔥 안전한 notifyListeners 호출
  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// 🔥 Repository 재초기화
  void _reinitialize() {
    if (_isDisposed) {
      AppLogger.info('BuildingRepository 재초기화', tag: 'REPO');
      _allBuildings.clear();
      _isLoaded = false;
      _isLoading = false;
      _lastError = null;
      _lastLoadTime = null;
      _dataChangeListeners.clear();
      _isDisposed = false;
    }
  }

  /// 🔥 새 세션을 위한 완전한 리셋
  void resetForNewSession() {
    debugPrint('🔄 BuildingRepository 새 세션 리셋');

    if (_isDisposed) {
      _reinitialize();
    }

    // 데이터 상태 완전 리셋
    _allBuildings.clear();
    _isLoaded = false;
    _isLoading = false;
    _lastError = null;
    _lastLoadTime = null;

    // 리스너들은 유지하되 알림
    _safeNotifyListeners();

    debugPrint('✅ BuildingRepository 리셋 완료');
  }

  /// 🔥 메인 데이터 로딩 메서드 - Result 패턴 완전 적용
  Future<Result<List<Building>>> getAllBuildings({
    bool forceRefresh = false,
  }) async {
    return await ResultHelper.runSafelyAsync(() async {
      // dispose 상태 확인 및 재초기화
      if (_isDisposed) {
        _reinitialize();
      }

      // 🔥 forceRefresh가 true면 캐시 무시하고 서버에서 가져오기
      if (forceRefresh) {
        debugPrint('🔄 forceRefresh=true - 캐시 무시하고 서버에서 가져오기');
        _isLoaded = false;
        _allBuildings.clear();
      }
      
      // 이미 로딩된 데이터가 있고 강제 새로고침이 아니면 캐시 반환
      if (_isLoaded && _allBuildings.isNotEmpty && !forceRefresh) {
        AppLogger.info(
          'BuildingRepository: 캐시된 데이터 반환 (${_allBuildings.length}개)',
          tag: 'REPO',
        );
        return _getCurrentBuildingsWithOperatingStatus();
      }

      // 현재 로딩 중이면 기다리기
      if (_isLoading) {
        AppLogger.debug('BuildingRepository: 이미 로딩 중, 대기...', tag: 'REPO');
        return await _waitForLoadingComplete();
      }

      return await _loadBuildingsFromServer();
    }, 'BuildingRepository.getAllBuildings');
  }

  /// 🔥 동기식 건물 데이터 반환 (기존 호환성 유지)
  List<Building> getAllBuildingsSync() {
    if (_isDisposed) {
      _reinitialize();
    }

    if (_isLoaded && _allBuildings.isNotEmpty) {
      return _getCurrentBuildingsWithOperatingStatus();
    }

    // 🔥 데이터가 없으면 빈 리스트 반환 (fallback 제거)
    debugPrint('⚠️ 동기식 건물 데이터 요청 시 데이터 없음 - 빈 리스트 반환');
    return [];
  }

  /// 🔥 서버에서 건물 데이터 로딩 - Result 패턴 적용
  Future<List<Building>> _loadBuildingsFromServer() async {
    _isLoading = true;
    _lastError = null;
    _safeNotifyListeners();

    try {
      List<Building> buildings = [];

      // 1단계: 일반 API 시도 (타임아웃 설정)
      debugPrint('🔄 건물 목록 API 호출 시작...');
      final apiResult = await ResultHelper.runSafelyAsync(() async {
        // 🔥 게스트 사용자도 API 호출 가능하도록 타임아웃 설정 (더 긴 타임아웃)
        return await BuildingApiService.getAllBuildings().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('⏰ 건물 API 호출 타임아웃 (10초)');
            throw Exception('API 호출 타임아웃');
          },
        );
      }, 'BuildingApiService.getAllBuildings').timeout(
        const Duration(seconds: 12),
        onTimeout: () {
          debugPrint('⏰ 건물 API 전체 프로세스 타임아웃 (12초)');
          return Result.failure<List<Building>>('API 호출 타임아웃');
        },
      );

      if (apiResult.isSuccess) {
        buildings = apiResult.data!;
        debugPrint('✅ 일반 API 성공: ${buildings.length}개');
        debugPrint(
          '🔍 API 응답 건물 목록: ${buildings.map((b) => b.name).join(', ')}',
        );
      } else {
        // 🔥 API 실패 시 예외 발생 (fallback 사용 안 함)
        debugPrint('❌ 일반 API 실패: ${apiResult.error}');
        debugPrint('❌ 에러 코드: ${apiResult.errorCode}');
        throw Exception('서버에서 건물 데이터를 가져올 수 없습니다: ${apiResult.error}');
      }

      // 🔥 데이터 검증 및 저장 (API에서만 가져옴)
      if (buildings.isEmpty) {
        throw Exception('서버에서 건물 데이터가 비어있습니다');
      }

      _allBuildings = buildings;
      _isLoaded = true;
      _lastLoadTime = DateTime.now();
      debugPrint('✅ 서버 데이터 저장 완료: ${buildings.length}개');

      // 🔥 수정: 올바른 메서드 호출 (언더스코어 제거)
      notifyDataChangeListeners();
    } catch (e) {
      // 🔥 API 실패 시 예외를 그대로 전파 (fallback 사용 안 함)
      _lastError = e.toString();
      _isLoaded = false;
      debugPrint('❌ 로딩 실패: $e');
      debugPrint('🔍 오류 내용: $e');

      // 🔥 수정: 올바른 메서드 호출 (언더스코어 제거)
      notifyDataChangeListeners();
      
      // 예외를 다시 throw하여 호출자가 처리할 수 있도록 함
      rethrow;
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }

    // API 성공 시에만 여기 도달
    return _getCurrentBuildingsWithOperatingStatus();
  }

  /// 🔥 현재 시간 기준 운영상태가 적용된 건물 목록 반환
  List<Building> _getCurrentBuildingsWithOperatingStatus() {
    return _allBuildings.map((building) {
      final autoStatus = _getAutoOperatingStatusWithoutContext(
        building.baseStatus,
      );
      return building.copyWith(baseStatus: autoStatus);
    }).toList();
  }

  // 🔥 Fallback 데이터 제거됨 - API만 사용

  /// 🔥 강제 데이터 새로고침 개선
  Future<void> forceRefresh() async {
    debugPrint('🔄 BuildingRepository 강제 새로고침');

    // 완전한 상태 리셋
    resetForNewSession();

    // 새로운 데이터 로딩
    await getAllBuildings(forceRefresh: true);

    if (_isLoaded && _allBuildings.isNotEmpty) {
      debugPrint('✅ 강제 새로고침 성공: ${_allBuildings.length}개 건물');
      notifyDataChangeListeners();
    } else {
      debugPrint('❌ 강제 새로고침 실패');
    }
  }

  /// 🔥 로딩 완료까지 대기 (타임아웃 강화)
  Future<List<Building>> _waitForLoadingComplete() async {
    int attempts = 0;
    const maxAttempts = 60; // 최대 6초 대기 (타임아웃과 맞춤)

    while (_isLoading && attempts < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    // 🔥 타임아웃 시 빈 리스트 반환 (fallback 제거)
    if (_isLoading) {
      debugPrint('⚠️ BuildingRepository 로딩 타임아웃 - 빈 리스트 반환');
      _isLoading = false;
      _allBuildings = [];
      _isLoaded = false;
      _lastError = '로딩 타임아웃';
      _safeNotifyListeners();
      notifyDataChangeListeners();
    }

    return _getCurrentBuildingsWithOperatingStatus();
  }

  /// 🔥 데이터 새로고침 - Result 패턴 적용 (MapService에서 호출)
  Future<Result<void>> refresh() async {
    return await ResultHelper.runSafelyAsync(() async {
      AppLogger.info('BuildingRepository: 강제 새로고침', tag: 'REPO');
      await forceRefresh();
    }, 'BuildingRepository.refresh');
  }

  /// 🔥 검색 기능 - Result 패턴 적용
  Result<List<Building>> searchBuildings(String query) {
    return ResultHelper.runSafely(() {
      if (query.isEmpty) {
        return _getCurrentBuildingsWithOperatingStatus();
      }

      final filtered = _allBuildings.where((building) {
        final q = query.toLowerCase();
        return building.name.toLowerCase().contains(q) ||
            building.info.toLowerCase().contains(q) ||
            building.category.toLowerCase().contains(q);
      }).toList();

      return filtered.map((b) {
        final autoStatus = _getAutoOperatingStatusWithoutContext(b.baseStatus);
        return b.copyWith(baseStatus: autoStatus);
      }).toList();
    }, 'BuildingRepository.searchBuildings');
  }

  /// 🔥 카테고리별 건물 필터링 - Result 패턴 적용
  Result<List<Building>> getBuildingsByCategory(String category) {
    return ResultHelper.runSafely(() {
      final filtered = _allBuildings.where((building) {
        return building.category == category;
      }).toList();

      return filtered.map((building) {
        final autoStatus = _getAutoOperatingStatusWithoutContext(
          building.baseStatus,
        );
        return building.copyWith(baseStatus: autoStatus);
      }).toList();
    }, 'BuildingRepository.getBuildingsByCategory');
  }

  /// 🔥 운영 상태별 건물 가져오기 - Result 패턴 적용
  Result<List<Building>> getOperatingBuildings() {
    return ResultHelper.runSafely(() {
      final current = _getCurrentBuildingsWithOperatingStatus();
      return current
          .where(
            (building) =>
                building.baseStatus == '운영중' || building.baseStatus == '24시간',
          )
          .toList();
    }, 'BuildingRepository.getOperatingBuildings');
  }

  Result<List<Building>> getClosedBuildings() {
    return ResultHelper.runSafely(() {
      final current = _getCurrentBuildingsWithOperatingStatus();
      return current
          .where(
            (building) =>
                building.baseStatus == '운영종료' || building.baseStatus == '임시휴무',
          )
          .toList();
    }, 'BuildingRepository.getClosedBuildings');
  }

  /// 🔥 특정 건물 찾기 - Result 패턴 적용
  Result<Building?> findBuildingByName(String name) {
    return ResultHelper.runSafely(() {
      try {
        final current = _getCurrentBuildingsWithOperatingStatus();
        return current.firstWhere(
          (building) =>
              building.name.toLowerCase().contains(name.toLowerCase()),
        );
      } catch (e) {
        return null;
      }
    }, 'BuildingRepository.findBuildingByName');
  }

  /// 🔥 거리 계산 (하버사인 공식)
  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371; // 지구 반지름 (km)

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLng = _degreesToRadians(lng2 - lng1);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// 🔥 도를 라디안으로 변환
  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// 🔥 근처 건물 찾기
  Result<List<Building>> getNearbyBuildings(
    double lat,
    double lng,
    double radiusKm,
  ) {
    return ResultHelper.runSafely(() {
      final current = _getCurrentBuildingsWithOperatingStatus();

      final nearby = current.where((building) {
        final distance = _calculateDistance(
          lat,
          lng,
          building.lat,
          building.lng,
        );
        return distance <= radiusKm;
      }).toList();

      // 거리순으로 정렬
      nearby.sort((a, b) {
        final distanceA = _calculateDistance(lat, lng, a.lat, a.lng);
        final distanceB = _calculateDistance(lat, lng, b.lat, b.lng);
        return distanceA.compareTo(distanceB);
      });

      return nearby;
    }, 'BuildingRepository.getNearbyBuildings');
  }

  /// 🔥 데이터 변경 리스너 관리
  void addDataChangeListener(Function(List<Building>) listener) {
    if (_isDisposed) return;

    _dataChangeListeners.add(listener);
    AppLogger.debug(
      '데이터 변경 리스너 추가 (총 ${_dataChangeListeners.length}개)',
      tag: 'REPO',
    );
  }

  void removeDataChangeListener(Function(List<Building>) listener) {
    if (_isDisposed) return;

    _dataChangeListeners.remove(listener);
    AppLogger.debug(
      '데이터 변경 리스너 제거 (총 ${_dataChangeListeners.length}개)',
      tag: 'REPO',
    );
  }

  /// 🔥 데이터 변경 리스너 알림 (public 메서드)
  void notifyDataChangeListeners() {
    if (_isDisposed) return;

    final currentBuildings = _getCurrentBuildingsWithOperatingStatus();
    AppLogger.debug(
      '데이터 변경 리스너들에게 알림 (${_dataChangeListeners.length}개)',
      tag: 'REPO',
    );

    for (final listener in _dataChangeListeners) {
      try {
        listener(currentBuildings);
      } catch (e) {
        AppLogger.info('데이터 변경 리스너 오류: $e', tag: 'REPO');
      }
    }
  }

  /// 🔥 캐시 무효화 - Result 패턴 적용
  Result<void> invalidateCache() {
    return ResultHelper.runSafely(() {
      AppLogger.info('BuildingRepository: 캐시 무효화', tag: 'REPO');
      _allBuildings.clear();
      _isLoaded = false;
      _lastLoadTime = null;
      _lastError = null;
      _safeNotifyListeners();
    }, 'BuildingRepository.invalidateCache');
  }

  /// 🔥 통계 정보 - Result 패턴 적용
  Result<Map<String, int>> getCategoryStats() {
    return ResultHelper.runSafely(() {
      final current = _getCurrentBuildingsWithOperatingStatus();
      final stats = <String, int>{};

      for (final building in current) {
        stats[building.category] = (stats[building.category] ?? 0) + 1;
      }

      AppLogger.debug('카테고리 통계: $stats', tag: 'REPO');
      return stats;
    }, 'BuildingRepository.getCategoryStats');
  }

  Result<Map<String, int>> getOperatingStats() {
    return ResultHelper.runSafely(() {
      final current = _getCurrentBuildingsWithOperatingStatus();
      final stats = <String, int>{};

      for (final building in current) {
        stats[building.baseStatus] = (stats[building.baseStatus] ?? 0) + 1;
      }

      AppLogger.debug('운영 상태 통계: $stats', tag: 'REPO');
      return stats;
    }, 'BuildingRepository.getOperatingStats');
  }

  /// 🔥 Repository 상태 정보
  Map<String, dynamic> getRepositoryStatus() {
    return {
      'isLoaded': _isLoaded,
      'isLoading': _isLoading,
      'buildingCount': _allBuildings.length,
      'lastError': _lastError,
      'lastLoadTime': _lastLoadTime?.toIso8601String(),
      'hasData': _allBuildings.isNotEmpty,
      'isDisposed': _isDisposed,
      'listenersCount': _dataChangeListeners.length,
    };
  }

  /// 🔥 Context 없이 운영상태 평가 (fallback 용)
  String _getAutoOperatingStatusWithoutContext(String baseStatus) {
    if (baseStatus == '24시간' || baseStatus == '임시휴무' || baseStatus == '휴무') {
      return baseStatus;
    }

    final now = DateTime.now().hour;
    return (now >= 9 && now < 18) ? '운영중' : '운영종료';
  }

  /// 🔥 Repository 정리 - 안전한 dispose
  @override
  void dispose() {
    if (_isDisposed) return;

    AppLogger.info('BuildingRepository 정리', tag: 'REPO');
    _isDisposed = true;
    _dataChangeListeners.clear();
    _allBuildings.clear();
    _buildingDataService.dispose();
    super.dispose();
  }
}
