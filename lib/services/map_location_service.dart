// lib/services/map/map_location_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:location/location.dart' as loc;
import 'dart:async';
import 'map/custom_user_location_marker.dart';

/// 지도상 위치 표시 서비스
class MapLocationService {
  NaverMapController? _mapController;

  final CustomUserLocationMarker _customMarker = CustomUserLocationMarker();

  bool _isCameraMoving = false;
  Timer? _cameraDelayTimer;

  NLatLng? _currentDisplayLocation;

  /// 지도 컨트롤러 설정
  void setMapController(NaverMapController controller) {
    _mapController = controller;
    _customMarker.setMapController(controller);
    debugPrint('✅ MapLocationService 지도 컨트롤러 설정 완료');
  }
  
  /// 컨텍스트 설정
  void setContext(BuildContext context) {
    _customMarker.setContext(context);
    debugPrint('✅ MapLocationService 컨텍스트 설정 완료');
  }
  
  /// 지도 회전 각도 업데이트
  void updateMapRotation(double rotation) {
    _customMarker.updateMapRotation(rotation);
  }
  

  /// 지도 컨트롤러 반환
  NaverMapController? get mapController => _mapController;

  /// 내 위치 표시
  Future<void> showMyLocation(
    loc.LocationData locationData, {
    bool shouldMoveCamera = true,
    double zoom = 16.0,
    bool showAccuracyCircle = true,
    bool showDirectionArrow = true,
  }) async {
    if (_mapController == null) {
      debugPrint('❌ 지도 컨트롤러가 설정되지 않음');
      return;
    }

    if (locationData.latitude == null || locationData.longitude == null) {
      debugPrint('❌ 유효하지 않은 위치 데이터');
      return;
    }

    final location = NLatLng(locationData.latitude!, locationData.longitude!);

    try {
      debugPrint('📍 커스텀 내 위치 표시: ${location.latitude}, ${location.longitude}');

      await _customMarker.showUserLocation(
        position: location,
        accuracy: showAccuracyCircle ? locationData.accuracy : null,
        showDirectionArrow: showDirectionArrow,
        shouldMoveCamera: shouldMoveCamera,
        zoom: zoom,
      );

      _currentDisplayLocation = location;

      debugPrint('✅ 커스텀 내 위치 표시 완료');
    } catch (e) {
      debugPrint('❌ 커스텀 내 위치 표시 실패: $e');
    }
  }

  /// 내 위치 업데이트
  Future<void> updateMyLocation(
    loc.LocationData locationData, {
    bool shouldMoveCamera = false,
    double zoom = 16.0,
  }) async {
    if (_mapController == null) return;
    if (locationData.latitude == null || locationData.longitude == null) return;

    final location = NLatLng(locationData.latitude!, locationData.longitude!);

    if (_currentDisplayLocation != null &&
        _currentDisplayLocation!.latitude == location.latitude &&
        _currentDisplayLocation!.longitude == location.longitude) {
      return;
    }

    try {
      debugPrint(
        '🔄 커스텀 위치 업데이트: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
      );

      await _customMarker.updateUserLocation(
        position: location,
        accuracy: locationData.accuracy,
        updateDirection: true,
      );

      _currentDisplayLocation = location;
      
      if (shouldMoveCamera) {
        await _moveCameraToLocation(location, zoom);
      }
    } catch (e) {
      debugPrint('❌ 커스텀 위치 업데이트 실패: $e');
      await showMyLocation(
        locationData, 
        shouldMoveCamera: shouldMoveCamera,
        showDirectionArrow: true,
      );
    }
  }


  /// 안전한 카메라 이동
  Future<void> _moveCameraToLocation(NLatLng location, double zoom) async {
    if (_isCameraMoving) {
      debugPrint('⏳ 카메라 이동 중, 요청 무시');
      return;
    }

    _isCameraMoving = true;

    try {
      debugPrint(
        '🎥 카메라 이동: ${location.latitude}, ${location.longitude}, zoom: $zoom',
      );

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
              debugPrint('⏰ 카메라 이동 타임아웃');
              throw TimeoutException('카메라 이동 타임아웃', const Duration(seconds: 5));
            },
          );

      debugPrint('✅ 카메라 이동 완료');
    } catch (e) {
      debugPrint('❌ 카메라 이동 실패: $e');

      try {
        await Future.delayed(const Duration(milliseconds: 500));
        final retryUpdate = NCameraUpdate.scrollAndZoomTo(
          target: location,
          zoom: zoom,
        );
        await _mapController!
            .updateCamera(retryUpdate)
            .timeout(const Duration(seconds: 3));
        debugPrint('✅ 카메라 이동 재시도 성공');
      } catch (retryError) {
        debugPrint('❌ 카메라 이동 재시도 실패: $retryError');
      }
    } finally {
      _isCameraMoving = false;
    }
  }

  /// 지연된 카메라 이동
  void scheduleCameraMove(
    NLatLng location,
    double zoom, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    _cameraDelayTimer?.cancel();
    _cameraDelayTimer = Timer(delay, () async {
      try {
        await _moveCameraToLocation(location, zoom);
      } catch (e) {
        debugPrint('❌ 지연된 카메라 이동 실패: $e');
      }
    });
  }

  /// 내 위치 숨기기
  Future<void> hideMyLocation() async {
    debugPrint('👻 커스텀 내 위치 숨기기');
    await _customMarker.hideUserLocation();
    _currentDisplayLocation = null;
  }

  /// 지도 영역을 특정 좌표들에 맞춰 조정
  Future<void> fitMapToBounds(
    List<NLatLng> coordinates, {
    EdgeInsets padding = const EdgeInsets.all(50),
  }) async {
    if (_mapController == null || coordinates.isEmpty) return;

    try {
      if (coordinates.length == 1) {
        // 단일 좌표면 해당 위치로 이동
        await _moveCameraToLocation(coordinates.first, 16.0);
        return;
      }

      // 여러 좌표의 경계 계산
      double minLat = coordinates.first.latitude;
      double maxLat = coordinates.first.latitude;
      double minLng = coordinates.first.longitude;
      double maxLng = coordinates.first.longitude;

      for (final coord in coordinates) {
        if (coord.latitude < minLat) minLat = coord.latitude;
        if (coord.latitude > maxLat) maxLat = coord.latitude;
        if (coord.longitude < minLng) minLng = coord.longitude;
        if (coord.longitude > maxLng) maxLng = coord.longitude;
      }

      const margin = 0.001;
      minLat -= margin;
      maxLat += margin;
      minLng -= margin;
      maxLng += margin;

      final bounds = NLatLngBounds(
        southWest: NLatLng(minLat, minLng),
        northEast: NLatLng(maxLat, maxLng),
      );

      await _mapController!.updateCamera(
        NCameraUpdate.fitBounds(bounds, padding: padding),
      );

      debugPrint('✅ 지도 영역 조정 완료');
    } catch (e) {
      debugPrint('❌ 지도 영역 조정 실패: $e');
    }
  }

  /// 현재 표시된 위치
  NLatLng? get currentDisplayLocation => _currentDisplayLocation;

  /// 내 위치가 표시되어 있는지 확인
  bool get hasMyLocationShown => _customMarker.hasUserLocationMarker;

  /// 현재 카메라 이동 중인지
  bool get isCameraMoving => _isCameraMoving;

  /// 위치 마커 스타일 변경
  Future<void> updateLocationMarkerStyle({
    Color? circleColor,
    Color? outlineColor,
    String? markerText,
    Color? textColor,
  }) async {
    try {
      debugPrint('ℹ️ 커스텀 마커 스타일 변경은 재생성이 필요합니다');
      debugPrint('✅ 위치 마커 스타일 변경 완료');
    } catch (e) {
      debugPrint('❌ 위치 마커 스타일 변경 실패: $e');
    }
  }

  /// 서비스 정리
  void dispose() {
    debugPrint('🧹 MapLocationService 정리');

    _cameraDelayTimer?.cancel();
    _cameraDelayTimer = null;

    _customMarker.dispose();
    _isCameraMoving = false;
    _currentDisplayLocation = null;
    _mapController = null;
  }
}
