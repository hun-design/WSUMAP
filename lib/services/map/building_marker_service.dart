// lib/services/map/building_marker_service.dart - mapController getter 추가 완전 버전
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../models/building.dart';
import '../building_api_service.dart';

class BuildingMarkerService {
  NaverMapController? _mapController;
  NOverlayImage? _blueBuildingIcon;

  // 건물 마커 관리
  final List<NMarker> _buildingMarkers = [];
  final Set<String> _buildingMarkerIds = {};
  bool _buildingMarkersVisible = true;

  // 마커 클릭 콜백
  Function(NMarker, Building)? _onBuildingMarkerTap;

  // API 로딩 상태 관리
  bool _isLoadingFromApi = false;
  String? _lastApiError;

  // Getters - mapController getter 추가
  bool get buildingMarkersVisible => _buildingMarkersVisible;
  List<NMarker> get buildingMarkers => _buildingMarkers;
  bool get isLoadingFromApi => _isLoadingFromApi;
  String? get lastApiError => _lastApiError;

  // 🔥 누락된 mapController getter 추가
  NaverMapController? get mapController => _mapController;

  /// 지도 컨트롤러 설정
  void setMapController(NaverMapController controller) {
    _mapController = controller;
    debugPrint('✅ BuildingMarkerService 지도 컨트롤러 설정 완료');
  }

  /// 모든 건물 마커 완전 제거 (지도에서 삭제 + 리스트 초기화)
  Future<void> clearAllMarkers() async {
    if (_mapController == null) {
      debugPrint('⚠️ MapController가 null - 마커 정리 건너뜀');
      return;
    }

    try {
      debugPrint('🔄 모든 건물 마커 완전 제거 시작: ${_buildingMarkers.length}개');

      final markersToRemove = Set<NMarker>.from(_buildingMarkers);

      // 배치 제거 - 한 번에 모든 마커 제거
      final removeOperations = markersToRemove.map((marker) async {
        try {
          await _mapController!.deleteOverlay(marker.info);
        } catch (e) {
          debugPrint('⚠️ 마커 제거 실패 (이미 제거됨): ${marker.info.id}');
        }
      });

      // 병렬 제거 처리
      await Future.wait(removeOperations);

      _buildingMarkers.clear();
      _buildingMarkerIds.clear();

      debugPrint('✅ 모든 건물 마커 완전 제거 완료');
    } catch (e) {
      debugPrint('❌ 모든 건물 마커 완전 제거 중 오류: $e');

      _buildingMarkers.clear();
      _buildingMarkerIds.clear();
    }
  }

  /// 기본 건물 마커들 로드 - API 연동 버전 (배치 처리)
  Future<void> loadDefaultBuildingMarkers(
    NaverMapController? mapController,
  ) async {
    if (mapController == null) {
      debugPrint('⚠️ MapController가 null이어서 마커 로드 불가');
      return;
    }

    if (_isLoadingFromApi) {
      debugPrint('⚠️ 이미 API에서 건물 데이터 로딩 중 - 요청 무시');
      return;
    }

    _isLoadingFromApi = true;
    _lastApiError = null;

    try {
      debugPrint('🔄 API에서 기본 건물 마커 로드 시작 (배치 처리)');

      final List<Building> defaultBuildings =
          await BuildingApiService.getAllBuildings();

      debugPrint('✅ API에서 건물 데이터 ${defaultBuildings.length}개 수신');

      if (defaultBuildings.isEmpty) {
        debugPrint('⚠️ API에서 받은 건물 데이터가 없음');
        _lastApiError = '서버에서 건물 데이터를 찾을 수 없습니다';
        return;
      }

      await clearAllMarkers();

      // 배치로 한 번에 모든 마커 생성 및 추가
      await _addBuildingMarkersBatch(mapController, defaultBuildings);

      debugPrint('✅ API 기본 건물 마커 배치 로드 완료: ${_buildingMarkers.length}개');
    } catch (e) {
      debugPrint('❌ API 기본 마커 로드 오류: $e');
      _lastApiError = 'API 연결 실패: $e';
    } finally {
      _isLoadingFromApi = false;
    }
  }

  /// 배치로 건물 마커들 추가 - 깜빡임 방지
  Future<void> _addBuildingMarkersBatch(
    NaverMapController mapController,
    List<Building> buildings,
  ) async {
    try {
      debugPrint('🏢 건물 마커 배치 추가 시작: ${buildings.length}개');

      // 1. 모든 마커 객체를 미리 생성
      final List<NMarker> markersToAdd = [];
      final List<String> markerIds = [];

      for (final building in buildings) {
        final markerId =
            'building_${building.hashCode}_${DateTime.now().millisecondsSinceEpoch}_${markersToAdd.length}';

        final marker = NMarker(
          id: markerId,
          position: NLatLng(building.lat, building.lng),
          icon: _getBuildingMarkerIcon(building),
        );

        // 마커 탭 리스너 설정
        if (_onBuildingMarkerTap != null) {
          marker.setOnTapListener(
            (NMarker marker) => _onBuildingMarkerTap!(marker, building),
          );
        }

        markersToAdd.add(marker);
        markerIds.add(markerId);
      }

      debugPrint('🔄 ${markersToAdd.length}개 마커 객체 생성 완료 - 지도에 일괄 추가 시작');

      // 2. 배치 크기 설정 (한 번에 너무 많이 추가하면 성능 문제 발생 가능)
      const int batchSize = 20;
      int successCount = 0;
      int failCount = 0;

      // 3. 배치 단위로 마커 추가
      for (int i = 0; i < markersToAdd.length; i += batchSize) {
        final int endIndex = (i + batchSize > markersToAdd.length)
            ? markersToAdd.length
            : i + batchSize;
        final List<NMarker> batch = markersToAdd.sublist(i, endIndex);
        final List<String> batchIds = markerIds.sublist(i, endIndex);

        debugPrint(
          '📍 배치 ${(i / batchSize + 1).ceil()}/${(markersToAdd.length / batchSize).ceil()}: ${batch.length}개 마커 추가',
        );

        // 4. 배치 내 마커들을 병렬로 추가
        final addOperations = batch.asMap().entries.map((entry) async {
          final index = entry.key;
          final marker = entry.value;

          try {
            await mapController.addOverlay(marker);
            return index; // 성공한 인덱스 반환
          } catch (e) {
            // 🔥 MissingPluginException 오류는 조용히 처리 (플러그인 미지원 가능성)
            if (e.toString().contains('MissingPluginException') || 
                e.toString().contains('No implementation found')) {
              // 조용히 무시
            } else {
              debugPrint('❌ 마커 추가 실패: ${batchIds[index]} - $e');
            }
            return -1; // 실패 표시
          }
        });

        // 5. 배치 내 모든 마커 추가 완료 대기
        final results = await Future.wait(addOperations);

        // 6. 성공한 마커들만 리스트에 추가
        for (int j = 0; j < results.length; j++) {
          if (results[j] != -1) {
            _buildingMarkers.add(batch[j]);
            _buildingMarkerIds.add(batchIds[j]);
            successCount++;
          } else {
            failCount++;
          }
        }

        // 7. 배치 간 짧은 휴식 (UI 응답성 유지)
        if (i + batchSize < markersToAdd.length) {
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }

      debugPrint('✅ 건물 마커 배치 추가 완료: 성공 $successCount개, 실패 $failCount개');
    } catch (e) {
      debugPrint('❌ 건물 마커 배치 추가 실패: $e');
      rethrow;
    }
  }

  /// API 재시도 메서드
  Future<void> retryLoadFromApi(NaverMapController? mapController) async {
    debugPrint('🔄 API 재시도 요청');
    _lastApiError = null;
    await loadDefaultBuildingMarkers(mapController);
  }

  /// 특정 건물 이름으로 마커 추가 (API 사용)
  Future<void> addBuildingMarkerByName(
    NaverMapController mapController,
    String buildingName,
  ) async {
    try {
      debugPrint('🔍 API에서 특정 건물 검색: $buildingName');

      final Building? building = await BuildingApiService.getBuildingByName(
        buildingName,
      );

      if (building != null) {
        await addBuildingMarker(mapController, building);
        debugPrint('✅ API에서 검색된 건물 마커 추가: ${building.name}');
      } else {
        debugPrint('⚠️ API에서 건물을 찾을 수 없음: $buildingName');
      }
    } catch (e) {
      debugPrint('❌ API 건물 검색 실패: $buildingName - $e');
    }
  }

  /// 개별 건물 마커 추가
  Future<void> addBuildingMarker(
    NaverMapController mapController,
    Building building,
  ) async {
    try {
      final markerId =
          'building_${building.hashCode}_${DateTime.now().millisecondsSinceEpoch}';

      final marker = NMarker(
        id: markerId,
        position: NLatLng(building.lat, building.lng),
        icon: _getBuildingMarkerIcon(building),
      );

      if (_onBuildingMarkerTap != null) {
        marker.setOnTapListener(
          (NMarker marker) => _onBuildingMarkerTap!(marker, building),
        );
      }

      await mapController.addOverlay(marker);
      _buildingMarkers.add(marker);
      _buildingMarkerIds.add(markerId);

      debugPrint('✅ 건물 마커 추가 완료: ${building.name}');
    } catch (e) {
      // 🔥 MissingPluginException 오류는 조용히 처리
      if (e.toString().contains('MissingPluginException') || 
          e.toString().contains('No implementation found')) {
        // 조용히 무시
      } else {
        debugPrint('❌ 건물 마커 추가 실패: ${building.name} - $e');
        rethrow;
      }
    }
  }

  /// 마커 아이콘 로딩
  Future<void> loadMarkerIcons() async {
    try {
      _blueBuildingIcon = const NOverlayImage.fromAssetImage(
        'lib/asset/building_marker_blue.png',
      );
      debugPrint('BuildingMarkerService: 마커 아이콘 로딩 완료');
    } catch (e) {
      debugPrint('BuildingMarkerService: 마커 아이콘 로딩 실패 (기본 마커 사용): $e');
      _blueBuildingIcon = null;
    }
  }

  /// 건물 마커들 추가 - 배치 처리 버전
  Future<void> addBuildingMarkers(
    List<Building> buildings,
    Function(NMarker, Building) onTap,
  ) async {
    try {
      if (_mapController == null) {
        debugPrint('❌ 지도 컨트롤러가 없음');
        return;
      }

      _onBuildingMarkerTap = onTap;

      List<Building> buildingsToAdd = buildings;

      if (buildings.isEmpty) {
        debugPrint('🔄 빈 건물 리스트 - API에서 데이터 가져오기');
        try {
          buildingsToAdd = await BuildingApiService.getAllBuildings();
          debugPrint('✅ API에서 건물 데이터 ${buildingsToAdd.length}개 로드');
        } catch (e) {
          debugPrint('❌ API에서 건물 데이터 로드 실패: $e');
          return;
        }
      }

      if (buildingsToAdd.isEmpty) {
        debugPrint('❌ 추가할 건물 데이터가 없음');
        return;
      }

      debugPrint('🏢 건물 마커 배치 추가 시작: ${buildingsToAdd.length}개');

      if (_buildingMarkers.isNotEmpty || _buildingMarkerIds.isNotEmpty) {
        await clearBuildingMarkers();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // 배치 처리로 한 번에 추가
      await _addBuildingMarkersBatch(_mapController!, buildingsToAdd);

      _buildingMarkersVisible = true;
      debugPrint('✅ 건물 마커 배치 추가 완료: ${_buildingMarkers.length}개');
    } catch (e) {
      debugPrint('❌ 건물 마커 배치 추가 실패: $e');
    }
  }

  /// 건물 마커 아이콘 가져오기
  NOverlayImage? _getBuildingMarkerIcon(Building building) {
    return _blueBuildingIcon;
  }

  /// 안전한 건물 마커 제거
  Future<void> clearBuildingMarkers() async {
    if (_mapController == null) return;

    try {
      debugPrint('기존 건물 마커 제거 시작: ${_buildingMarkers.length}개');

      final markersToRemove = Set<NMarker>.from(_buildingMarkers);

      // 병렬 제거
      final removeOperations = markersToRemove.map((marker) async {
        try {
          await _mapController!.deleteOverlay(marker.info);
        } catch (e) {
          // 이미 제거된 마커는 무시
        }
      });

      await Future.wait(removeOperations);

      _buildingMarkers.clear();
      _buildingMarkerIds.clear();

      debugPrint('건물 마커 제거 완료');
    } catch (e) {
      debugPrint('건물 마커 제거 중 오류: $e');
      _buildingMarkers.clear();
      _buildingMarkerIds.clear();
    }
  }

  /// 건물 마커 표시/숨기기 토글
  Future<void> toggleBuildingMarkers() async {
    _buildingMarkersVisible = !_buildingMarkersVisible;

    if (_buildingMarkersVisible) {
      // 배치로 마커 다시 표시
      final showOperations = _buildingMarkers.map((marker) async {
        try {
          await _mapController?.addOverlay(marker);
        } catch (e) {
          debugPrint('마커 표시 오류: ${marker.info.id} - $e');
        }
      });

      await Future.wait(showOperations);
      debugPrint('건물 마커 표시됨');
    } else {
      // 배치로 마커 숨기기
      final hideOperations = _buildingMarkers.map((marker) async {
        try {
          await _mapController?.deleteOverlay(marker.info);
        } catch (e) {
          debugPrint('마커 숨기기 오류: ${marker.info.id} - $e');
        }
      });

      await Future.wait(hideOperations);
      debugPrint('건물 마커 숨겨짐');
    }
  }

  /// 모든 건물 마커 숨기기
  Future<void> hideAllBuildingMarkers() async {
    debugPrint('모든 건물 마커 숨기기 시작: ${_buildingMarkers.length}개');

    for (NMarker marker in _buildingMarkers) {
      marker.setIsVisible(false);
    }

    debugPrint('✅ 모든 건물 마커 숨기기 완료');
  }

  /// 모든 건물 마커 다시 표시
  Future<void> showAllBuildingMarkers() async {
    debugPrint('=== 모든 건물 마커 다시 표시 시작 ===');
    debugPrint('현재 마커 개수: ${_buildingMarkers.length}개');

    // 마커가 없다면 다시 로드
    if (_buildingMarkers.isEmpty) {
      debugPrint('⚠️ 마커가 없음 - 기본 마커 다시 로드');
      if (_mapController != null) {
        await loadDefaultBuildingMarkers(_mapController);
        debugPrint('✅ 기본 마커 로드 완료');
      } else {
        debugPrint('❌ MapController가 null - 마커 로드 불가');
      }
    } else {
      // 기존 마커들의 가시성만 변경
      for (NMarker marker in _buildingMarkers) {
        marker.setIsVisible(true);
      }
      debugPrint('✅ 기존 마커 가시성 변경 완료');
    }

    debugPrint('=== 모든 건물 마커 다시 표시 완료 ===');
  }

  /// 선택된 건물 마커 강조
  Future<void> highlightBuildingMarker(NMarker marker) async {
    await resetAllBuildingMarkers();

    marker.setIcon(
      const NOverlayImage.fromAssetImage('lib/asset/building_marker_blue.png'),
    );
    marker.setSize(const Size(110, 110));
  }

  /// 모든 건물 마커 스타일 초기화
  Future<void> resetAllBuildingMarkers() async {
    for (final marker in _buildingMarkers) {
      marker.setIcon(_blueBuildingIcon);
      marker.setSize(const Size(40, 40));
    }
  }

  /// 재로그인 시 마커 재초기화
  Future<void> reinitializeForNewUser() async {
    try {
      debugPrint('🔄 새 사용자를 위한 BuildingMarkerService 재초기화 (배치 처리)');

      await clearAllMarkers();
      _lastApiError = null;

      await Future.delayed(const Duration(milliseconds: 300));

      if (_mapController != null) {
        await loadDefaultBuildingMarkers(_mapController);
        debugPrint('✅ 새 사용자용 마커 재초기화 완료 (배치 기반)');
      }
    } catch (e) {
      debugPrint('❌ 새 사용자용 마커 재초기화 실패: $e');
      _lastApiError = '재초기화 실패: $e';
    }
  }

  /// 마커 초기화 상태 확인
  bool get hasMarkers => _buildingMarkers.isNotEmpty;

  /// 마커 개수 반환
  int get markerCount => _buildingMarkers.length;

  /// 특정 건물의 마커 찾기
  NMarker? findMarkerForBuilding(Building building) {
    debugPrint(
      '🔍 건물 마커 찾기 시작: ${building.name} (hashCode: ${building.hashCode})',
    );
    debugPrint('🔍 전체 마커 수: ${_buildingMarkers.length}');

    // 1차: hashCode로 정확한 매칭
    for (int i = 0; i < _buildingMarkers.length; i++) {
      final marker = _buildingMarkers[i];
      final markerId = marker.info.id;
      final searchPattern = 'building_${building.hashCode}';

      debugPrint('🔍 마커 $i: $markerId');
      debugPrint('🔍 검색 패턴: $searchPattern');

      if (markerId.contains(searchPattern)) {
        debugPrint('✅ hashCode로 마커 찾음: $markerId');
        return marker;
      }
    }

    // 2차: 좌표 기반 가장 가까운 마커 찾기
    debugPrint('🔍 좌표 기반 마커 찾기 시작: (${building.lat}, ${building.lng})');
    NMarker? closestMarker;
    double closestDistance = double.infinity;

    for (int i = 0; i < _buildingMarkers.length; i++) {
      final marker = _buildingMarkers[i];
      final markerPosition = marker.position;

      final distance = _calculateDistance(
        building.lat,
        building.lng,
        markerPosition.latitude,
        markerPosition.longitude,
      );

      debugPrint(
        '🔍 마커 $i: (${markerPosition.latitude}, ${markerPosition.longitude}) - 거리: ${distance.toStringAsFixed(6)}',
      );

      if (distance < closestDistance) {
        closestDistance = distance;
        closestMarker = marker;
      }
    }

    if (closestMarker != null && closestDistance < 0.000001) {
      // 약 1미터 이내 (제곱 거리)
      debugPrint('✅ 좌표 기반으로 마커 찾음: 거리 ${closestDistance.toStringAsFixed(6)}');
      return closestMarker;
    }

    debugPrint('❌ 마커를 찾을 수 없음: ${building.name}');
    return null;
  }

  /// 두 좌표 간의 거리 계산 (간단한 유클리드 거리)
  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final dLat = lat1 - lat2;
    final dLng = lng1 - lng2;
    return dLat * dLat + dLng * dLng; // 제곱근 없이 제곱 거리 사용
  }

  /// API 연결 상태 확인
  Future<bool> checkApiConnection() async {
    try {
      final buildings = await BuildingApiService.getAllBuildings();
      return buildings.isNotEmpty;
    } catch (e) {
      debugPrint('API 연결 확인 실패: $e');
      return false;
    }
  }

  /// 서비스 정리
  void dispose() {
    debugPrint('🧹 BuildingMarkerService 정리');
    _buildingMarkers.clear();
    _buildingMarkerIds.clear();
    _onBuildingMarkerTap = null;
    _mapController = null;
    _isLoadingFromApi = false;
    _lastApiError = null;
  }
}
