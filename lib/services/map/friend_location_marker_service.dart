// lib/services/map/friend_location_marker_service.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'dart:math';
import '../../friends/friend.dart';

class FriendLocationMarkerService {
  NaverMapController? _mapController;

  // 🔥 BuildContext 추가 (NOverlayImage.fromWidget에서 필요)
  BuildContext? _context;

  // 친구 위치 마커 관리
  final Map<String, NMarker> _friendLocationMarkers = {};

  // 🔥 랜덤 색상 생성기
  final Random _random = Random();

  // 🔥 마커 아이콘 로딩 상태 추가
  bool _markerIconLoaded = false;

  /// 🔥 BuildContext 설정 메서드 추가
  void setContext(BuildContext context) {
    _context = context;
    debugPrint('✅ FriendLocationMarkerService Context 설정 완료');
  }

  /// 🔥 마커 아이콘 로딩 메서드 추가
  Future<void> loadMarkerIcon() async {
    try {
      debugPrint('🔄 친구 위치 마커 아이콘 로딩 시작');

      // 마커 아이콘 리소스 준비 (실제로는 필요에 따라 구현)
      // 예: 커스텀 아이콘 파일 로딩, 네트워크 이미지 로딩 등

      // 시뮬레이션을 위한 짧은 지연
      await Future.delayed(const Duration(milliseconds: 100));

      _markerIconLoaded = true;
      debugPrint('✅ 친구 위치 마커 아이콘 로딩 완료');
    } catch (e) {
      debugPrint('❌ 친구 위치 마커 아이콘 로딩 실패: $e');
      _markerIconLoaded = false;
    }
  }

  /// 🔥 마커 아이콘 로딩 상태 확인
  bool get isMarkerIconLoaded => _markerIconLoaded;

  /// 지도 컨트롤러 설정
  void setMapController(NaverMapController controller) {
    _mapController = controller;
    debugPrint('✅ FriendLocationMarkerService 지도 컨트롤러 설정 완료');
  }

  /// 🔥 랜덤 색상 생성
  Color _generateRandomColor() {
    final colors = [
      const Color(0xFF1E3A8A), // 블루
      const Color(0xFF10B981), // 그린
      const Color(0xFFEF4444), // 레드
      const Color(0xFFF59E0B), // 옐로우
      const Color(0xFF8B5CF6), // 퍼플
      const Color(0xFFEC4899), // 핑크
      const Color(0xFF06B6D4), // 시안
      const Color(0xFF84CC16), // 라임
      const Color(0xFFF97316), // 오렌지
      const Color(0xFF6366F1), // 인디고
    ];

    return colors[_random.nextInt(colors.length)];
  }

  /// 🔥 원형 마커 생성 (BuildContext 추가)
  Future<NOverlayImage> _createCircleMarker(Color color) async {
    // Context가 없으면 기본 마커 반환
    if (_context == null) {
      debugPrint('⚠️ Context가 없어 기본 마커 사용');
      return NOverlayImage.fromAssetImage(
        'assets/images/default_marker.png', // 기본 마커 이미지가 있다면
      );
    }

    // 원형 마커를 위한 커스텀 위젯 생성 (context 추가)
    return NOverlayImage.fromWidget(
      context: _context!, // 🔥 필수 context 매개변수 추가
                    widget: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 20),
        ),
      ),
      size: const Size(40, 40),
    );
  }

  /// 친구 위치 마커 추가
  Future<void> addFriendLocationMarker(Friend friend) async {
    // 🔥 위치 공유 상태 확인 - 비활성화된 경우 마커 제거 후 종료
    if (!friend.isLocationPublic) {
      debugPrint('❌ 위치공유 미허용 친구: ${friend.userName} - 마커 제거');
      await _removeFriendLocationMarker(friend.userId);
      return;
    }
    if (_mapController == null) {
      debugPrint('❌ 지도 컨트롤러가 없음');
      return;
    }
    if (_context == null) {
      debugPrint('❌ Context가 설정되지 않음');
      return;
    }
    if (!_markerIconLoaded) {
      await loadMarkerIcon();
    }
    final location = _parseLocation(friend.lastLocation);
    if (location == null) {
      debugPrint('❌ 친구 위치 정보 파싱 실패: ${friend.lastLocation}');
      return;
    }
    try {
      await _removeFriendLocationMarker(friend.userId);
      final markerColor = _generateRandomColor();
      final markerId = 'friend_location_${friend.userId}';
      final marker = NMarker(
        id: markerId,
        position: location,
        icon: await _createCircleMarker(markerColor),
        caption: NOverlayCaption(
          text: friend.userName,
          color: markerColor,
          textSize: 14,
          haloColor: Colors.white,
        ),
        size: const Size(40, 40),
      );
      await _mapController!.addOverlay(marker);
      _friendLocationMarkers[friend.userId] = marker;
      debugPrint('✅ 친구 위치 마커 추가 완료: ${friend.userName}');
      await _moveCameraToLocation(location);
    } catch (e) {
      debugPrint('❌ 친구 위치 마커 추가 실패: $e');
    }
  }

  /// 특정 친구의 위치 마커 제거
  Future<void> _removeFriendLocationMarker(String userId) async {
    if (_friendLocationMarkers.containsKey(userId)) {
      try {
        await _mapController!.deleteOverlay(
          _friendLocationMarkers[userId]!.info,
        );
        _friendLocationMarkers.remove(userId);
        debugPrint('친구 위치 마커 제거: $userId');
      } catch (e) {
        debugPrint('친구 위치 마커 제거 실패: $e');
      }
    }
  }

  /// 🔥 특정 친구 위치 마커 제거 (외부 호출용)
  Future<void> removeFriendLocationMarker(String userId) async {
    await _removeFriendLocationMarker(userId);
  }

  /// 🔥 위치 공유 상태 변경으로 인한 친구 마커 제거
  Future<void> removeFriendMarkerDueToLocationShareDisabled(String userId) async {
    debugPrint('🗑️ 위치 공유 비활성화로 인한 친구 마커 제거: $userId');
    await _removeFriendLocationMarker(userId);
  }

  /// 모든 친구 위치 마커 제거
  Future<void> clearAllFriendLocationMarkers() async {
    if (_mapController == null) return;

    try {
      debugPrint('모든 친구 위치 마커 제거 시작: ${_friendLocationMarkers.length}개');

      final markersToRemove = Map<String, NMarker>.from(_friendLocationMarkers);

      for (final marker in markersToRemove.values) {
        try {
          await _mapController!.deleteOverlay(marker.info);
        } catch (e) {
          // 이미 제거된 마커는 무시
        }
      }

      _friendLocationMarkers.clear();
      debugPrint('모든 친구 위치 마커 제거 완료');
    } catch (e) {
      debugPrint('친구 위치 마커 제거 중 오류: $e');
      _friendLocationMarkers.clear();
    }
  }

  /// 🔥 현재 표시된 친구 위치 마커 목록 반환
  List<String> getDisplayedFriendIds() {
    return _friendLocationMarkers.keys.toList();
  }

  /// 🔥 특정 친구 위치 마커가 표시되어 있는지 확인
  bool isFriendLocationDisplayed(String userId) {
    return _friendLocationMarkers.containsKey(userId);
  }

  /// 🔥 현재 표시된 친구 위치 마커 개수 반환
  int get displayedFriendCount => _friendLocationMarkers.length;

  /// 🔥 모든 친구 위치 마커 정보 반환
  Map<String, NMarker> get allFriendLocationMarkers =>
      Map<String, NMarker>.from(_friendLocationMarkers);

  // 기존 위치 파싱 메서드들은 그대로 유지...
  NLatLng? _parseLocation(String locationString) {
    try {
      if (locationString.isEmpty) return null;

      debugPrint('🔍 위치 파싱 시도: $locationString');

      if (locationString.contains('{') && locationString.contains('}')) {
        return _parseJsonLocation(locationString);
      }

      final cleanLocation = locationString.replaceAll(RegExp(r'[latLng:]'), '');
      final parts = cleanLocation.split(',');

      if (parts.length >= 2) {
        final lat = double.parse(parts[0].trim());
        final lng = double.parse(parts[1].trim());

        if (lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
          debugPrint('✅ 위치 파싱 성공: $lat, $lng');
          return NLatLng(lat, lng);
        } else {
          debugPrint('❌ 유효하지 않은 좌표 범위');
          return null;
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ 위치 파싱 오류: $e');
      return null;
    }
  }

  NLatLng? _parseJsonLocation(String jsonString) {
    try {
      debugPrint('🔍 JSON 위치 파싱 시도: $jsonString');

      final xMatch = RegExp(r'x:\s*([0-9.-]+)').firstMatch(jsonString);
      final yMatch = RegExp(r'y:\s*([0-9.-]+)').firstMatch(jsonString);

      if (xMatch != null && yMatch != null) {
        final x = double.parse(xMatch.group(1)!);
        final y = double.parse(yMatch.group(1)!);

        final lat = x;
        final lng = y;

        if (lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
          debugPrint('✅ JSON 위치 파싱 성공: lat=$lat, lng=$lng');
          return NLatLng(lat, lng);
        } else {
          debugPrint('❌ 유효하지 않은 좌표 범위: lat=$lat, lng=$lng');
          return null;
        }
      }

      debugPrint('❌ JSON에서 x, y 값을 찾을 수 없음');
      return null;
    } catch (e) {
      debugPrint('❌ JSON 위치 파싱 오류: $e');
      return null;
    }
  }

  Future<void> _moveCameraToLocation(NLatLng location) async {
    try {
      final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
        target: location,
        zoom: 17.0,
      );

      await _mapController!.updateCamera(cameraUpdate);
      debugPrint('✅ 친구 위치로 카메라 이동 완료');
    } catch (e) {
      debugPrint('❌ 카메라 이동 실패: $e');
    }
  }

  /// 🔥 특정 친구 위치로 카메라 이동 (외부 호출용)
  Future<void> moveCameraToFriend(String userId) async {
    if (_friendLocationMarkers.containsKey(userId)) {
      final marker = _friendLocationMarkers[userId]!;
      await _moveCameraToLocation(marker.position);
    }
  }

  /// 🔥 모든 친구 위치를 포함하는 영역으로 카메라 이동 (매개변수명 수정)
  Future<void> moveCameraToAllFriends() async {
    if (_friendLocationMarkers.isEmpty || _mapController == null) return;

    try {
      final positions = _friendLocationMarkers.values
          .map((marker) => marker.position)
          .toList();

      if (positions.length == 1) {
        await _moveCameraToLocation(positions.first);
        return;
      }

      // 경계 계산
      double minLat = positions.first.latitude;
      double maxLat = positions.first.latitude;
      double minLng = positions.first.longitude;
      double maxLng = positions.first.longitude;

      for (final position in positions) {
        minLat = math.min(minLat, position.latitude);
        maxLat = math.max(maxLat, position.latitude);
        minLng = math.min(minLng, position.longitude);
        maxLng = math.max(maxLng, position.longitude);
      }

      // 🔥 매개변수명 수정: southwest -> southWest, northeast -> northEast
      final bounds = NLatLngBounds(
        southWest: NLatLng(minLat, minLng), // 🔥 수정됨
        northEast: NLatLng(maxLat, maxLng), // 🔥 수정됨
      );

      final cameraUpdate = NCameraUpdate.fitBounds(
        bounds,
        padding: const EdgeInsets.all(50),
      );
      await _mapController!.updateCamera(cameraUpdate);

      debugPrint('✅ 모든 친구 위치를 포함하는 영역으로 카메라 이동 완료');
    } catch (e) {
      debugPrint('❌ 전체 친구 위치 카메라 이동 실패: $e');
    }
  }

  void dispose() {
    debugPrint('🧹 FriendLocationMarkerService 정리');
    _friendLocationMarkers.clear();
    _mapController = null;
    _context = null; // 🔥 Context도 정리
    _markerIconLoaded = false; // 🔥 아이콘 로딩 상태도 리셋
  }
}
