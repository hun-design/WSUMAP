// lib/services/map/route_rendering_service.dart (새로 생성)
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'dart:math';

class RouteRenderingService {
  NaverMapController? _mapController;

  // 경로 관련 오버레이 관리
  final List<String> _pathOverlayIds = [];
  final List<String> _routeMarkerIds = [];
  
  // 다국어 지원을 위한 텍스트
  String _departureText = '출발지';
  String _destinationText = '도착지';
  
  /// 다국어 텍스트 설정
  void setLocalizedTexts({required String departure, required String destination}) {
    _departureText = departure;
    _destinationText = destination;
  }

  // Getters
  List<String> get pathOverlayIds => _pathOverlayIds;
  List<String> get routeMarkerIds => _routeMarkerIds;

  /// 지도 컨트롤러 설정
  void setMapController(NaverMapController controller) {
    _mapController = controller;
    debugPrint('✅ RouteRenderingService 지도 컨트롤러 설정 완료');
  }

  /// 경로 그리기 (map_service.dart에서 이동)
  Future<void> drawPath(List<NLatLng> pathCoordinates, {double? pathWidth}) async {
    if (_mapController == null || pathCoordinates.isEmpty) return;

    try {
      await clearPath();

      // 🔥 동적 경로 두께 계산
      final dynamicWidth = _calculateDynamicPathWidth(pathCoordinates, pathWidth);
      
      final pathOverlayId =
          'route_path_${DateTime.now().millisecondsSinceEpoch}';
      final pathOverlay = NPolylineOverlay(
        id: pathOverlayId,
        coords: pathCoordinates,
        color: const Color(0xFF1E3A8A),
        width: dynamicWidth,
      );

      await _mapController!.addOverlay(pathOverlay);
      _pathOverlayIds.add(pathOverlayId);

      await _addSimpleRouteMarkers(pathCoordinates);
    } catch (e) {
      debugPrint('경로 그리기 오류: $e');
    }
  }

  /// 🔥 동적 경로 두께 계산
  double _calculateDynamicPathWidth(List<NLatLng> pathCoordinates, double? customWidth) {
    if (customWidth != null) {
      return customWidth;
    }

    // 경로 길이에 따른 동적 두께 계산
    final pathLength = _calculatePathLength(pathCoordinates);
    
    if (pathLength < 100) {
      return 8.0; // 짧은 경로: 두꺼운 선
    } else if (pathLength < 300) {
      return 6.0; // 중간 경로: 보통 두께
    } else if (pathLength < 500) {
      return 5.0; // 긴 경로: 얇은 선
    } else {
      return 4.0; // 매우 긴 경로: 가장 얇은 선
    }
  }

  /// 🔥 경로 길이 계산 (미터 단위)
  double _calculatePathLength(List<NLatLng> coordinates) {
    if (coordinates.length < 2) return 0.0;
    
    double totalDistance = 0.0;
    for (int i = 0; i < coordinates.length - 1; i++) {
      totalDistance += _calculateDistance(
        coordinates[i].latitude, coordinates[i].longitude,
        coordinates[i + 1].latitude, coordinates[i + 1].longitude,
      );
    }
    return totalDistance;
  }

  /// 🔥 두 좌표 간 거리 계산 (미터 단위)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // 지구 반지름 (미터)
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// 🔥 도를 라디안으로 변환
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// 🔥 출발지와 도착지 마커 추가 (서로 다른 이미지 사용)
  Future<void> _addSimpleRouteMarkers(List<NLatLng> path) async {
    if (path.length < 2) return;

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // 🔥 출발점 마커 (start_marker.png 사용)
      final startMarkerId = 'route_start_$timestamp';
      final startMarker = NMarker(
        id: startMarkerId,
        position: path.first,
        icon: NOverlayImage.fromAssetImage(
          'lib/asset/start_marker.png',
        ),
        size: const Size(48, 48),
        caption: NOverlayCaption(
          text: _departureText,
          color: Colors.white,
          haloColor: const Color(0xFF3B82F6),
          textSize: 14,
        ),
      );

      // 🔥 도착점 마커 (end_marker.png 사용)
      final endMarkerId = 'route_end_$timestamp';
      final endMarker = NMarker(
        id: endMarkerId,
        position: path.last,
        icon: NOverlayImage.fromAssetImage(
          'lib/asset/end_marker.png',
        ),
        size: const Size(48, 48),
        caption: NOverlayCaption(
          text: _destinationText,
          color: Colors.white,
          haloColor: const Color(0xFFEF4444),
          textSize: 14,
        ),
      );

      await _mapController!.addOverlay(startMarker);
      await _mapController!.addOverlay(endMarker);

      _routeMarkerIds.add(startMarkerId);
      _routeMarkerIds.add(endMarkerId);

      debugPrint('✅ 경로 마커 추가 완료 (출발지: start_marker.png, 도착지: end_marker.png)');
    } catch (e) {
      debugPrint('❌ 경로 마커 추가 오류: $e');
      // 🔥 폴백: 기본 마커로 대체
      await _addFallbackRouteMarkers(path);
    }
  }

  /// 🔥 폴백: 기본 마커 (아이콘 로드 실패 시)
  Future<void> _addFallbackRouteMarkers(List<NLatLng> path) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // 출발점 마커 (파란색 원)
      final startMarkerId = 'route_start_$timestamp';
      final startMarker = NMarker(
        id: startMarkerId,
        position: path.first,
        size: const Size(48, 48),
        caption: NOverlayCaption(
          text: _departureText,
          color: Colors.white,
          haloColor: const Color(0xFF3B82F6),
          textSize: 14,
        ),
      );

      // 도착점 마커 (빨간색 원)
      final endMarkerId = 'route_end_$timestamp';
      final endMarker = NMarker(
        id: endMarkerId,
        position: path.last,
        size: const Size(48, 48),
        caption: NOverlayCaption(
          text: _destinationText,
          color: Colors.white,
          haloColor: const Color(0xFFEF4444),
          textSize: 14,
        ),
      );

      await _mapController!.addOverlay(startMarker);
      await _mapController!.addOverlay(endMarker);

      _routeMarkerIds.add(startMarkerId);
      _routeMarkerIds.add(endMarkerId);

      debugPrint('✅ 폴백 경로 마커 추가 완료 (색상으로 구분)');
    } catch (e) {
      debugPrint('❌ 폴백 마커 추가도 실패: $e');
    }
  }

  /// 경로에 맞춰 카메라 이동
  Future<void> moveCameraToPath(List<NLatLng> pathCoordinates) async {
    debugPrint(
      '[RouteRenderingService] moveCameraToPath 호출 - 좌표 개수: ${pathCoordinates.length}',
    );
    if (_mapController == null || pathCoordinates.isEmpty) return;

    try {
      if (pathCoordinates.length == 1) {
        // 단일 좌표면 해당 위치로 이동
        await _moveCamera(pathCoordinates.first, zoom: 16);
      } else {
        // 여러 좌표의 경계 계산
        double minLat = pathCoordinates.first.latitude;
        double maxLat = pathCoordinates.first.latitude;
        double minLng = pathCoordinates.first.longitude;
        double maxLng = pathCoordinates.first.longitude;

        for (final coord in pathCoordinates) {
          minLat = min(minLat, coord.latitude);
          maxLat = max(maxLat, coord.latitude);
          minLng = min(minLng, coord.longitude);
          maxLng = max(maxLng, coord.longitude);
        }

        final latPadding = (maxLat - minLat) * 0.1;
        final lngPadding = (maxLng - minLng) * 0.1;

        final bounds = NLatLngBounds(
          southWest: NLatLng(minLat - latPadding, minLng - lngPadding),
          northEast: NLatLng(maxLat + latPadding, maxLng + lngPadding),
        );

        await Future.delayed(const Duration(milliseconds: 500));

        try {
          await _mapController!
              .updateCamera(
                NCameraUpdate.fitBounds(
                  bounds,
                  padding: const EdgeInsets.all(50),
                ),
              )
              .timeout(const Duration(seconds: 5));
          debugPrint('[RouteRenderingService] moveCameraToPath 완료');
        } catch (e) {
          debugPrint('[RouteRenderingService] moveCameraToPath 오류: $e');
        }
      }
    } catch (e) {
      debugPrint('[RouteRenderingService] moveCameraToPath 전체 오류: $e');
    }
  }

  /// 카메라 이동 헬퍼 메서드
  Future<void> _moveCamera(NLatLng location, {double zoom = 15}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));

      final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
        target: location,
        zoom: zoom,
      );

      await _mapController!
          .updateCamera(cameraUpdate)
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('[RouteRenderingService] 카메라 이동 오류: $e');
    }
  }

  /// 경로 제거
  Future<void> clearPath() async {
    if (_mapController == null) return;

    try {
      // 폴리라인 제거
      for (final overlayId in _pathOverlayIds) {
        try {
          await _mapController!.deleteOverlay(
            NOverlayInfo(type: NOverlayType.polylineOverlay, id: overlayId),
          );
        } catch (e) {
          debugPrint('폴리라인 제거 오류 (무시): $overlayId - $e');
        }
      }
      _pathOverlayIds.clear();

      // 경로 마커 제거
      for (final markerId in _routeMarkerIds) {
        try {
          await _mapController!.deleteOverlay(
            NOverlayInfo(type: NOverlayType.marker, id: markerId),
          );
        } catch (e) {
          debugPrint('경로 마커 제거 오류 (무시): $markerId - $e');
        }
      }
      _routeMarkerIds.clear();
    } catch (e) {
      debugPrint('경로 제거 중 오류: $e');
    }
  }

  /// 서비스 정리
  void dispose() {
    debugPrint('🧹 RouteRenderingService 정리');
    _pathOverlayIds.clear();
    _routeMarkerIds.clear();
    _mapController = null;
  }
}
