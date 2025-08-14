// MapService 완전한 구현 - 실제 코드 기반

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/result.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_application_1/models/building.dart';
import 'package:flutter_application_1/models/category_marker_data.dart';
import 'package:flutter_application_1/repositories/building_repository.dart';
import 'package:flutter_application_1/generated/app_localizations.dart';
import 'map/building_marker_service.dart';
import 'map/category_marker_service.dart';
import 'map/route_rendering_service.dart';

class MapService {
  // 🔥 1. 모든 변수 선언 먼저
  NaverMapController? _mapController;

  // 서비스 인스턴스들
  final BuildingMarkerService _buildingMarkerService;
  final CategoryMarkerService _categoryMarkerService;
  final RouteRenderingService _routeRenderingService;

  // 🔥 BuildingRepository 인스턴스
  final BuildingRepository _buildingRepository = BuildingRepository();

  // Context 저장
  BuildContext? _context;

  // 카메라 이동 관련 상태 관리
  bool _isCameraMoving = false;
  Timer? _cameraDelayTimer;

  // 카테고리 매칭 콜백 및 상태 저장
  void Function(String, List<String>)? _onCategorySelected;
  String? _lastSelectedCategory;
  List<String>? _lastCategoryBuildingNames;

  // 🔥 데이터 변경 리스너 등록 상태
  bool _isDataChangeListenerRegistered = false;

  // 🔥 2. 생성자
  MapService({
    BuildingMarkerService? buildingMarkerService,
    CategoryMarkerService? categoryMarkerService,
    RouteRenderingService? routeRenderingService,
  }) : _buildingMarkerService =
           buildingMarkerService ?? BuildingMarkerService(),
       _categoryMarkerService =
           categoryMarkerService ?? CategoryMarkerService(),
       _routeRenderingService =
           routeRenderingService ?? RouteRenderingService();

  // 🔥 3. Getters
  BuildContext? get context => _context;
  bool get buildingMarkersVisible =>
      _buildingMarkerService.buildingMarkersVisible;
  List<NMarker> get buildingMarkers => _buildingMarkerService.buildingMarkers;
  NMarker? findMarkerForBuilding(Building building) =>
      _buildingMarkerService.findMarkerForBuilding(building);

  // 🔥 4. 메서드들

  void setController(NaverMapController controller) {
    _mapController = controller;
    _buildingMarkerService.setMapController(controller);
    _categoryMarkerService.setMapController(controller);
    _routeRenderingService.setMapController(controller);
    debugPrint('MapController 설정 완료');
  }

  /// 🔥 동기식 컨트롤러 getter (에러 해결용)
  NaverMapController? getController() {
    return _mapController;
  }

  /// 🔥 비동기식 컨트롤러 getter (기존 호환성 유지)
  Future<NaverMapController?> getControllerAsync() async {
    return _mapController;
  }

  void setContext(BuildContext context) {
    _context = context;
    debugPrint('MapService Context 설정 완료');

    // 🔥 카테고리 마커 아이콘 사전 생성
    _preGenerateCategoryIcons(context);
    
    // 🔥 다국어 텍스트 설정
    _setLocalizedTexts(context);
  }
  
  /// 🔥 다국어 텍스트 설정
  void _setLocalizedTexts(BuildContext context) {
    try {
      final l10n = AppLocalizations.of(context);
      if (l10n != null) {
        _routeRenderingService.setLocalizedTexts(
          departure: l10n.departure,
          destination: l10n.destination,
        );
      }
    } catch (e) {
      debugPrint('❌ 다국어 텍스트 설정 실패: $e');
    }
  }

  /// 🔥 카테고리 마커 아이콘 사전 생성
  Future<void> _preGenerateCategoryIcons(BuildContext context) async {
    try {
      await _categoryMarkerService.preGenerateMarkerIcons(context);
    } catch (e) {
      debugPrint('❌ 카테고리 마커 아이콘 사전 생성 실패: $e');
    }
  }

  Future<void> loadMarkerIcons() async {
    await _buildingMarkerService.loadMarkerIcons();
  }

  /// 전체 건물 데이터 가져오기 - BuildingRepository 사용 (동기식)
  List<Building> getAllBuildings() {
    return _buildingRepository.getAllBuildingsSync();
  }

  /// 비동기 건물 데이터 로딩 - Result 패턴
  Future<Result<List<Building>>> loadAllBuildings({
    bool forceRefresh = false,
  }) async {
    return await _buildingRepository.getAllBuildings(
      forceRefresh: forceRefresh,
    );
  }

  /// 안전한 카메라 이동
  Future<void> moveCamera(NLatLng location, {double zoom = 15}) async {
    debugPrint(
      '[MapService] moveCamera 호출 - 위치: (${location.latitude}, ${location.longitude}), zoom: $zoom',
    );

    if (_mapController == null) {
      debugPrint('[MapService] moveCamera: _mapController가 null입니다!');
      return;
    }

    if (_isCameraMoving) {
      debugPrint('[MapService] moveCamera: 이미 카메라 이동 중...');
      return;
    }

    _isCameraMoving = true;

    try {
      await Future.delayed(const Duration(milliseconds: 200));

      final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
        target: location,
        zoom: zoom,
      );

      await _mapController!
          .updateCamera(cameraUpdate)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint('[MapService] moveCamera: 카메라 이동 타임아웃');
              throw TimeoutException('카메라 이동 타임아웃', const Duration(seconds: 5));
            },
          );

      debugPrint(
        '[MapService] moveCamera 완료: ${location.latitude}, ${location.longitude}',
      );
    } catch (e) {
      debugPrint('[MapService] moveCamera 오류: $e');

      try {
        await Future.delayed(const Duration(milliseconds: 500));
        final retryUpdate = NCameraUpdate.scrollAndZoomTo(
          target: location,
          zoom: zoom,
        );
        await _mapController!
            .updateCamera(retryUpdate)
            .timeout(const Duration(seconds: 3));
        debugPrint('[MapService] moveCamera 재시도 성공');
      } catch (retryError) {
        debugPrint('[MapService] moveCamera 재시도 실패: $retryError');
      }
    } finally {
      _isCameraMoving = false;
    }
  }

  // 🔥 카테고리 관련 메서드들 - 서비스로 위임
  Future<void> showCategoryIconMarkers(
    List<CategoryMarkerData> categoryData,
    BuildContext context,
  ) async {
    await _categoryMarkerService.showCategoryIconMarkers(categoryData, context);
  }

  Future<void> clearCategoryMarkers() async {
    await _categoryMarkerService.clearCategoryMarkers();
  }

  // 🔥 건물 마커 관련 메서드들 - 서비스로 위임 (BuildingRepository 사용)
  Future<void> addBuildingMarkers(Function(NMarker, Building) onTap) async {
    // BuildingRepository에서 건물 데이터 로딩 (Result 패턴)
    final result = await _buildingRepository.getAllBuildings();
    final buildings = result.isSuccess
        ? result.data!
        : _buildingRepository.getAllBuildingsSync();
    await _buildingMarkerService.addBuildingMarkers(buildings, onTap);
  }

  Future<void> clearBuildingMarkers() async {
    await _buildingMarkerService.clearBuildingMarkers();
  }

  Future<void> clearAllBuildingMarkers() async {
    await _buildingMarkerService.clearAllMarkers();
  }

  Future<void> hideAllBuildingMarkers() async {
    await _buildingMarkerService.hideAllBuildingMarkers();
  }

  Future<void> showAllBuildingMarkers() async {
    await _buildingMarkerService.showAllBuildingMarkers();
  }

  Future<void> toggleBuildingMarkers() async {
    await _buildingMarkerService.toggleBuildingMarkers();
  }

  Future<void> highlightBuildingMarker(NMarker marker) async {
    await _buildingMarkerService.highlightBuildingMarker(marker);
  }

  Future<void> resetAllBuildingMarkers() async {
    await _buildingMarkerService.resetAllBuildingMarkers();
  }

  // 🔥 경로 관련 메서드들 - 서비스로 위임
  Future<void> drawPath(List<NLatLng> pathCoordinates, {double? pathWidth}) async {
    await _routeRenderingService.drawPath(pathCoordinates, pathWidth: pathWidth);
  }

  Future<void> moveCameraToPath(List<NLatLng> pathCoordinates) async {
    await _routeRenderingService.moveCameraToPath(pathCoordinates);
  }

  Future<void> clearPath() async {
    await _routeRenderingService.clearPath();
  }

  // 🔥 검색 관련 메서드들 - BuildingRepository로 위임
  Result<List<Building>> searchBuildings(String query) {
    return _buildingRepository.searchBuildings(query);
  }

  Result<List<Building>> getBuildingsByCategory(String category) {
    return _buildingRepository.getBuildingsByCategory(category);
  }

  // 🔥 운영 상태별 건물 가져오기 - BuildingRepository로 위임
  Result<List<Building>> getOperatingBuildings() {
    return _buildingRepository.getOperatingBuildings();
  }

  Result<List<Building>> getClosedBuildings() {
    return _buildingRepository.getClosedBuildings();
  }

  // 🔥 데이터 새로고침 - BuildingRepository로 위임
  Future<void> refreshBuildingData() async {
    await _buildingRepository.refresh();
  }

  // 카테고리 매칭 콜백 관련
  void setCategorySelectedCallback(
    void Function(String, List<String>) callback,
  ) {
    _onCategorySelected = callback;

    // 🔥 BuildingRepository의 데이터 변경 리스너 등록 (중복 방지)
    if (!_isDataChangeListenerRegistered) {
      _buildingRepository.addDataChangeListener(_onBuildingDataChanged);
      _isDataChangeListenerRegistered = true;
    }
  }

  /// 🔥 BuildingRepository 데이터 변경 리스너
  void _onBuildingDataChanged(List<Building> buildings) {
    // 서버 데이터 도착 후 카테고리 매칭 재실행
    if (_onCategorySelected != null && _lastSelectedCategory != null) {
      debugPrint('🔁 BuildingRepository 데이터 변경 - 카테고리 매칭 재실행!');
      final buildingNames = _lastCategoryBuildingNames ?? [];
      Future.microtask(
        () => _onCategorySelected!(_lastSelectedCategory!, buildingNames),
      );
    }
  }

  void saveLastCategorySelection(String category, List<String> buildingNames) {
    _lastSelectedCategory = category;
    _lastCategoryBuildingNames = buildingNames;
  }

  // 정리
  void dispose() {
    _cameraDelayTimer?.cancel();

    // 🔥 BuildingRepository 데이터 변경 리스너 해제
    if (_isDataChangeListenerRegistered) {
      _buildingRepository.removeDataChangeListener(_onBuildingDataChanged);
      _isDataChangeListenerRegistered = false;
    }

    _buildingMarkerService.dispose();
    _categoryMarkerService.dispose();
    _routeRenderingService.dispose();
    _buildingRepository.dispose();
    _mapController = null;
    debugPrint('MapService 정리 완료');
  }
}
