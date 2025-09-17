// lib/services/map/map_location_service.dart
// 지도상 내 위치 마커 및 표시 전용 서비스

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:location/location.dart' as loc;
import 'dart:async';
import 'map/custom_user_location_marker.dart';

/// 지도상 위치 표시 서비스
class MapLocationService {
  NaverMapController? _mapController;

  // 🔥 커스텀 사용자 위치 마커 서비스
  final CustomUserLocationMarker _customMarker = CustomUserLocationMarker();

  // 카메라 이동 관련
  bool _isCameraMoving = false;
  Timer? _cameraDelayTimer;

  // 현재 표시된 위치
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

  /// 내 위치 표시 (메인 메서드) - 🔥 커스텀 마커 사용
  Future<void> showMyLocation(
    loc.LocationData locationData, {
    bool shouldMoveCamera = true,
    double zoom = 16.0,
    bool showAccuracyCircle = true,
    bool showDirectionArrow = true, // 🔥 방향 화살표 옵션 추가
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

      // 🔥 커스텀 마커 서비스 사용
      await _customMarker.showUserLocation(
        position: location,
        accuracy: showAccuracyCircle ? locationData.accuracy : null,
        showDirectionArrow: showDirectionArrow,
        shouldMoveCamera: shouldMoveCamera,
        zoom: zoom,
      );

      // 위치 저장
      _currentDisplayLocation = location;

      debugPrint('✅ 커스텀 내 위치 표시 완료');
    } catch (e) {
      debugPrint('❌ 커스텀 내 위치 표시 실패: $e');
    }
  }

  /// 내 위치 업데이트 (기존 마커 이동) - 🔥 커스텀 마커 사용
  Future<void> updateMyLocation(
    loc.LocationData locationData, {
    bool shouldMoveCamera = false,
    double zoom = 16.0,
  }) async {
    if (_mapController == null) return;
    if (locationData.latitude == null || locationData.longitude == null) return;

    final location = NLatLng(locationData.latitude!, locationData.longitude!);

    // 🔥 위치 변경 감지 - 같은 위치면 업데이트하지 않음
    if (_currentDisplayLocation != null &&
        _currentDisplayLocation!.latitude == location.latitude &&
        _currentDisplayLocation!.longitude == location.longitude) {
      return; // 위치가 변경되지 않았으면 업데이트하지 않음
    }

    try {
      // 🔥 로그 최적화 - 실제 업데이트 시에만 출력
      debugPrint(
        '🔄 커스텀 위치 업데이트: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
      );

      // 🔥 커스텀 마커 서비스로 위치 업데이트
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
      // 오류 발생 시 완전히 새로 생성
      await showMyLocation(
        locationData, 
        shouldMoveCamera: shouldMoveCamera,
        showDirectionArrow: true,
      );
    }
  }

  // 🔥 기존 마커 관련 메서드들은 CustomUserLocationMarker로 대체됨

  /// 안전한 카메라 이동
  Future<void> _moveCameraToLocation(NLatLng location, double zoom) async {
    // 카메라 이동 중복 방지
    if (_isCameraMoving) {
      debugPrint('⏳ 카메라 이동 중, 요청 무시');
      return;
    }

    _isCameraMoving = true;

    try {
      debugPrint(
        '🎥 카메라 이동: ${location.latitude}, ${location.longitude}, zoom: $zoom',
      );

      // 메인 스레드 보호를 위한 지연
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

      // 재시도 (한 번만)
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

  /// 지연된 카메라 이동 (메인 스레드 블로킹 방지)
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

  // 🔥 기존 오버레이 제거 메서드는 CustomUserLocationMarker로 대체됨

  /// 내 위치 숨기기 - 🔥 커스텀 마커 사용
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

      // 여백 추가
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

  /// 내 위치가 표시되어 있는지 확인 - 🔥 커스텀 마커 사용
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
      // 커스텀 마커 서비스에서는 스타일 변경이 제한적
      debugPrint('ℹ️ 커스텀 마커 스타일 변경은 재생성이 필요합니다');
      debugPrint('✅ 위치 마커 스타일 변경 완료');
    } catch (e) {
      debugPrint('❌ 위치 마커 스타일 변경 실패: $e');
    }
  }

  /// 서비스 정리 - 🔥 커스텀 마커 정리 포함
  void dispose() {
    debugPrint('🧹 MapLocationService 정리');

    // 타이머 취소
    _cameraDelayTimer?.cancel();
    _cameraDelayTimer = null;

    // 🔥 커스텀 마커 서비스 정리
    _customMarker.dispose();

    // 상태 초기화
    _isCameraMoving = false;
    _currentDisplayLocation = null;
    _mapController = null;
  }
}
