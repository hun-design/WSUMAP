// lib/services/route_service.dart - 최적화된 버전

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'dart:math' as math;

/// 경로 서비스
class RouteService {
  static const double _earthRadius = 6371000; // 지구 반지름 (미터)
  static const double _walkingSpeedMeterPerMin = 67; // 평균 도보 속도
  static const int _routeSegments = 10;

  /// 두 지점 사이의 경로 계산
  Future<List<NLatLng>> calculateRoute(NLatLng start, NLatLng end) async {
    try {
      if (kDebugMode) {
        debugPrint('경로 계산 시작: ${start.latitude}, ${start.longitude} -> ${end.latitude}, ${end.longitude}');
      }
      
      final routePoints = _generateSimpleRoute(start, end);
      
      if (kDebugMode) {
        debugPrint('경로 계산 완료: ${routePoints.length}개 포인트');
      }
      
      return routePoints;
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('경로 계산 오류: $e');
      }
      return [];
    }
  }

  /// 간단한 직선 경로 생성
  List<NLatLng> _generateSimpleRoute(NLatLng start, NLatLng end) {
    final points = <NLatLng>[start];
    
    // 중간점들 생성
    for (int i = 1; i < _routeSegments; i++) {
      final ratio = i / _routeSegments;
      final lat = start.latitude + (end.latitude - start.latitude) * ratio;
      final lng = start.longitude + (end.longitude - start.longitude) * ratio;
      points.add(NLatLng(lat, lng));
    }
    
    points.add(end);
    return points;
  }

  /// 두 지점 사이의 거리 계산 (미터)
  double calculateDistance(NLatLng start, NLatLng end) {
    final double lat1Rad = start.latitude * math.pi / 180;
    final double lat2Rad = end.latitude * math.pi / 180;
    final double deltaLatRad = (end.latitude - start.latitude) * math.pi / 180;
    final double deltaLngRad = (end.longitude - start.longitude) * math.pi / 180;

    final double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return _earthRadius * c;
  }

  /// 예상 도보 시간 계산 (분)
  int calculateWalkingTime(double distanceInMeters) {
    return (distanceInMeters / _walkingSpeedMeterPerMin).ceil();
  }
}
