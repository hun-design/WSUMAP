// lib/services/map/custom_user_location_marker.dart
// 커스텀 사용자 위치 마커 서비스 - 앱 디자인에 맞는 이쁜 마커와 방향 화살표

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:io';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_compass/flutter_compass.dart';

/// 커스텀 사용자 위치 마커 서비스
class CustomUserLocationMarker {
  NaverMapController? _mapController;
  BuildContext? _context;
  
  // 마커 관련 오버레이들
  NMarker? _userLocationMarker;
  NCircleOverlay? _accuracyCircle;
  NMarker? _directionArrow;
  
  // 방향 관련 (기기가 바라보는 방향 추적)
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  StreamSubscription<CompassEvent>? _compassSubscription; // iOS용 heading 스트림
  double _currentHeading = 0.0;
  double _mapRotation = 0.0; // 지도 회전 각도 추적
  bool _isDirectionEnabled = false;
  bool _isMagnetometerAvailable = true; // 자력계 센서 사용 가능 여부
  int _magnetometerErrorCount = 0; // 자력계 오류 카운트
  
  // 마커 스타일 설정 (파란색 디자인)
  static const Color _primaryBlue = Color(0xFF3B82F6); // 메인 파란색
  
  /// 지도 컨트롤러 설정
  void setMapController(NaverMapController controller) {
    _mapController = controller;
    debugPrint('✅ CustomUserLocationMarker 지도 컨트롤러 설정 완료');
    // 지도 준비 시점부터 방향 추적을 시작해 항상 heading이 갱신되도록 함
    if (_magnetometerSubscription == null) {
      _isDirectionEnabled = true;
      _startDirectionTracking();
    }
  }
  
  void _startIOSCompassTracking() {
    _compassSubscription?.cancel();
    _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
      try {
        final double? heading = event.heading;
        if (heading == null) return;
        // heading은 0~360(북 기준). 지도 회전 보정은 별도 적용됨
        double newHeading = heading;
        // 더 민감하게: 임계값 0.5도
        if ((newHeading - _currentHeading).abs() > 0.5) {
          _currentHeading = newHeading;
          _updateDirectionArrowRotation();
        }
      } catch (e) {
        debugPrint('❌ iOS Compass 처리 오류: $e');
      }
    }, onError: (error) {
      debugPrint('❌ iOS Compass 스트림 오류: $error');
    });
  }

  /// 컨텍스트 설정
  void setContext(BuildContext context) {
    _context = context;
    debugPrint('✅ CustomUserLocationMarker 컨텍스트 설정 완료');
  }
  
  /// 지도 회전 각도 업데이트 (지도 회전 감지, 실시간 보정)
  void updateMapRotation(double rotation) {
    _mapRotation = rotation;
    // 화살표가 있을 때 즉시 회전 보정 적용 (방향 추적 플래그와 무관하게 반영)
    if (_directionArrow != null) {
      _updateDirectionArrowRotation();
    }
  }
  
  
  /// 사용자 위치 마커 표시 (방향 화살표 포함)
  Future<void> showUserLocation({
    required NLatLng position,
    double? accuracy,
    bool showDirectionArrow = true,
    bool shouldMoveCamera = false,
    double zoom = 16.0,
  }) async {
    if (_mapController == null) {
      debugPrint('❌ 지도 컨트롤러가 설정되지 않음');
      return;
    }
    
    try {
      debugPrint('📍 커스텀 사용자 위치 마커 표시: ${position.latitude}, ${position.longitude}');
      
      // 기존 마커들 제거
      await _removeAllMarkers();
      
      // 잠시 대기
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 정확도 원형 마커 제거 (사용자 요청)
      // if (accuracy != null && accuracy > 0) {
      //   await _addAccuracyCircle(position, accuracy);
      // }
      
      // 사용자 위치 마커 추가
      await _addUserLocationMarker(position);
      
      // 방향 화살표 활성화 (기기 방향 추적)
      _isDirectionEnabled = true;
      await _addDirectionArrow(position);
      await _startDirectionTracking();
      
      // 자력계 센서가 사용 불가능한 경우 경고 메시지
      if (!_isMagnetometerAvailable) {
        debugPrint('⚠️ 자력계 센서를 사용할 수 없습니다. 방향 화살표가 작동하지 않을 수 있습니다.');
        debugPrint('💡 iOS 사용자: 설정 > 개인정보 보호 및 보안 > 위치 서비스 > 시스템 서비스 > 나침반 보정을 활성화해주세요.');
      }
      
      // 카메라 이동 (옵션)
      if (shouldMoveCamera) {
        await _moveCameraToLocation(position, zoom);
      }
      
      debugPrint('✅ 커스텀 사용자 위치 마커 표시 완료');
    } catch (e) {
      debugPrint('❌ 커스텀 사용자 위치 마커 표시 실패: $e');
    }
  }
  
  /// 사용자 위치 업데이트
  Future<void> updateUserLocation({
    required NLatLng position,
    double? accuracy,
    bool updateDirection = true,
  }) async {
    if (_mapController == null) return;
    
    try {
      debugPrint('🔄 사용자 위치 업데이트: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}');
      
      // 위치 마커 업데이트
      if (_userLocationMarker != null) {
        _userLocationMarker!.setPosition(position);
      }
      
      // 정확도 원형 업데이트
      if (_accuracyCircle != null) {
        _accuracyCircle!.setCenter(position);
      }
      
      // 방향 화살표 업데이트 (위치 이동 및 회전)
      if (_directionArrow != null && updateDirection && _isMagnetometerAvailable) {
        _directionArrow!.setPosition(position);
        await _updateDirectionArrowRotation();
      }
      
      debugPrint('✅ 사용자 위치 업데이트 완료');
    } catch (e) {
      debugPrint('❌ 사용자 위치 업데이트 실패: $e');
      // 실패 시 전체 마커 재생성
      await showUserLocation(
        position: position,
        accuracy: accuracy,
        showDirectionArrow: _isDirectionEnabled,
        shouldMoveCamera: false,
      );
    }
  }
  
  // 정확도 원형 마커 메서드 제거 (사용자 요청으로 비활성화)
  
  /// 사용자 위치 마커 추가 (이쁜 디자인)
  Future<void> _addUserLocationMarker(NLatLng position) async {
    try {
      // 커스텀 마커 아이콘 생성 (원형 + 점)
      final markerIcon = await _createCustomMarkerIcon();
      
      _userLocationMarker = NMarker(
        id: 'user_location_marker',
        position: position,
        icon: markerIcon,
        size: const Size(24, 24), // 적절한 마커 크기
        anchor: const NPoint(0.5, 0.5), // 중심점 기준
        angle: 0, // 기본 마커는 회전하지 않음
      );
      
      await _mapController!.addOverlay(_userLocationMarker!);
      debugPrint('✅ 사용자 위치 마커 추가 완료');
    } catch (e) {
      debugPrint('❌ 사용자 위치 마커 추가 실패: $e');
    }
  }
  
  
  /// 커스텀 마커 아이콘 생성 (원형 + 중심점) - 앱 디자인에 맞는 이쁜 마커
  Future<NOverlayImage> _createCustomMarkerIcon() async {
    try {
      // 앱의 메인 컬러를 사용한 커스텀 마커 생성
      return await _createUserLocationMarkerIcon();
    } catch (e) {
      debugPrint('❌ 커스텀 마커 아이콘 생성 실패: $e');
      // 기본 마커 사용
      return const NOverlayImage.fromAssetImage(
        'lib/asset/building_marker_blue.png',
      );
    }
  }
  
  /// 사용자 위치 마커 아이콘 생성 (원형 + 중심점) - 커스텀 디자인
  Future<NOverlayImage> _createUserLocationMarkerIcon() async {
    try {
      // 커스텀 마커 위젯 생성
      if (_context == null) {
        throw Exception('Context가 설정되지 않음');
      }
      return await NOverlayImage.fromWidget(
        context: _context!,
        widget: Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _primaryBlue,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
        size: const Size(24, 24),
      );
    } catch (e) {
      debugPrint('❌ 커스텀 사용자 위치 마커 아이콘 생성 실패: $e');
      // 기본 마커 사용
      return const NOverlayImage.fromAssetImage(
        'lib/asset/building_marker_blue.png',
      );
    }
  }
  
  /// 방향 화살표 아이콘 생성 - 북쪽 고정 화살표 디자인
  Future<NOverlayImage> _createDirectionArrowIcon() async {
    try {
      // 커스텀 화살표 위젯 생성 (항상 북쪽을 가리키는 화살표)
      if (_context == null) {
        throw Exception('Context가 설정되지 않음');
      }
      return await NOverlayImage.fromWidget(
        context: _context!,
        widget: Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _primaryBlue,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.navigation,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
        size: const Size(24, 24),
      );
    } catch (e) {
      debugPrint('❌ 커스텀 방향 화살표 아이콘 생성 실패: $e');
      // 기본 마커 사용
      return const NOverlayImage.fromAssetImage(
        'lib/asset/building_marker_blue.png',
      );
    }
  }
  
  /// 방향 화살표 추가
  Future<void> _addDirectionArrow(NLatLng position) async {
    try {
      // 방향 화살표 아이콘 생성
      final arrowIcon = await _createDirectionArrowIcon();
      
      _directionArrow = NMarker(
        id: 'user_direction_arrow',
        position: position,
        icon: arrowIcon,
        size: const Size(24, 24), // 적절한 크기
        anchor: const NPoint(0.5, 0.5),
        angle: _currentHeading, // 기기가 바라보는 방향
      );
      
      await _mapController!.addOverlay(_directionArrow!);
      debugPrint('✅ 방향 화살표 추가 완료');
    } catch (e) {
      debugPrint('❌ 방향 화살표 추가 실패: $e');
    }
  }
  
  /// 방향 추적 시작 (자력계 센서 사용) - 기기 방향 추적
  Future<void> _startDirectionTracking() async {
    try {
      debugPrint('🧭 기기 방향 추적 시작');
      
      // iOS에서 자력계 센서 사용 가능 여부 확인
      if (Platform.isIOS) {
        // iOS는 CoreLocation 기반 나침반 스트림 사용 (flutter_compass)
        _startIOSCompassTracking();
        debugPrint('✅ iOS Compass(heading) 추적 시작');
        return; // iOS는 magnetometer 사용 안 함
      }
      
      _magnetometerSubscription = magnetometerEventStream().listen(
        (event) {
          try {
            // 자력계 데이터 유효성 검사
            if (!_isValidMagnetometerData(event.x, event.y)) {
              _magnetometerErrorCount++;
              if (_magnetometerErrorCount > 10) {
                debugPrint('⚠️ 자력계 데이터 오류가 너무 많음. 센서 비활성화');
                _isMagnetometerAvailable = false;
                _stopDirectionTracking();
                return;
              }
              return;
            }
            
            // 자력계 데이터를 방향으로 변환
            final heading = _calculateHeading(event.x, event.y);
            
            // 방향이 변경된 경우에만 업데이트 (플랫폼별 민감도 조정 - 더 민감하게)
            double threshold = Platform.isIOS ? 0.8 : 0.5;
            if ((heading - _currentHeading).abs() > threshold) {
              _currentHeading = heading;
              _updateDirectionArrowRotation();
              _magnetometerErrorCount = 0; // 성공 시 오류 카운트 리셋
            }
          } catch (e) {
            debugPrint('❌ 자력계 데이터 처리 오류: $e');
            _magnetometerErrorCount++;
          }
        },
        onError: (error) {
          debugPrint('❌ 자력계 스트림 오류: $error');
          _magnetometerErrorCount++;
          
          // iOS에서 권한 오류인 경우
          if (Platform.isIOS && error.toString().contains('permission')) {
            debugPrint('⚠️ iOS 자력계 센서 권한이 필요합니다. 설정에서 허용해주세요.');
            _isMagnetometerAvailable = false;
            _stopDirectionTracking();
          }
        },
      );
      
      debugPrint('✅ 기기 방향 추적 시작 완료');
    } catch (e) {
      debugPrint('❌ 기기 방향 추적 시작 실패: $e');
      _isMagnetometerAvailable = false;
    }
  }
  
  /// 자력계 데이터 유효성 검사
  bool _isValidMagnetometerData(double x, double y) {
    // 자력계 데이터가 너무 작거나 큰 값인지 확인
    const double minThreshold = 0.1;
    const double maxThreshold = 100.0;
    
    double magnitude = math.sqrt(x * x + y * y);
    return magnitude > minThreshold && magnitude < maxThreshold;
  }
  
  /// 자력계 데이터를 방향으로 변환 - 기기 방향 계산 (플랫폼별 최적화)
  double _calculateHeading(double x, double y) {
    // 자력계 데이터를 도 단위로 변환
    double heading = math.atan2(y, x) * 180 / math.pi;
    
    // 플랫폼별 보정 적용
    if (Platform.isIOS) {
      // iOS는 다른 보정이 필요할 수 있음
      heading = (heading + 90) % 360;
    } else {
      // Android 보정
      heading = (heading + 90) % 360;
    }
    
    // 화살표가 반대 방향을 가리키는 문제 해결을 위해 180도 반전
    heading = (heading + 180) % 360;
    
    // 음수 각도를 양수로 변환
    if (heading < 0) {
      heading += 360;
    }
    
    // 부드러운 회전을 위해 반올림 (iOS는 더 부드럽게)
    double roundValue = Platform.isIOS ? 1.0 : 1.0;
    return (heading / roundValue).round() * roundValue;
  }
  
  /// 방향 화살표 회전 업데이트 - 기기 방향에 따라 화살표 회전 (지도 회전 보정)
  Future<void> _updateDirectionArrowRotation() async {
    if (_directionArrow == null || _mapController == null) return;
    
    try {
      // 기기 방향에서 지도 회전을 빼서 보정된 각도 계산
      // 지도가 시계방향으로 회전하면 화살표는 반시계방향으로 회전해야 함
      double correctedAngle = _currentHeading - _mapRotation;
      
      // 각도를 0-360도 범위로 정규화
      while (correctedAngle < 0) correctedAngle += 360;
      while (correctedAngle >= 360) correctedAngle -= 360;
      
      // 화살표 마커에 보정된 회전 각도 적용
      _directionArrow!.setAngle(correctedAngle);
      
      debugPrint('🧭 화살표 방향 업데이트: 기기방향 ${_currentHeading.toStringAsFixed(1)}도, 지도회전 ${_mapRotation.toStringAsFixed(1)}도, 보정각도 ${correctedAngle.toStringAsFixed(1)}도');
    } catch (e) {
      debugPrint('❌ 화살표 방향 업데이트 실패: $e');
    }
  }
  
  /// 카메라 이동
  Future<void> _moveCameraToLocation(NLatLng position, double zoom) async {
    if (_mapController == null) return;
    
    try {
      final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
        target: position,
        zoom: zoom,
      );
      
      await _mapController!.updateCamera(cameraUpdate);
      debugPrint('✅ 카메라 이동 완료');
    } catch (e) {
      debugPrint('❌ 카메라 이동 실패: $e');
    }
  }
  
  /// 모든 마커 제거
  Future<void> _removeAllMarkers() async {
    try {
      if (_userLocationMarker != null) {
        await _mapController!.deleteOverlay(_userLocationMarker!.info);
        _userLocationMarker = null;
      }
      
      if (_accuracyCircle != null) {
        await _mapController!.deleteOverlay(_accuracyCircle!.info);
        _accuracyCircle = null;
      }
      
      if (_directionArrow != null) {
        await _mapController!.deleteOverlay(_directionArrow!.info);
        _directionArrow = null;
      }
      
      debugPrint('✅ 모든 사용자 위치 마커 제거 완료');
    } catch (e) {
      debugPrint('❌ 마커 제거 중 오류: $e');
    }
  }
  
  /// 사용자 위치 마커 숨기기
  Future<void> hideUserLocation() async {
    debugPrint('👻 사용자 위치 마커 숨기기');
    await _removeAllMarkers();
    // 방향 추적은 유지하여 사용자가 버튼을 누르지 않아도 heading이 계속 갱신되도록 함
  }
  
  /// 방향 추적 중지
  Future<void> _stopDirectionTracking() async {
    try {
      _magnetometerSubscription?.cancel();
      _magnetometerSubscription = null;
      _compassSubscription?.cancel();
      _compassSubscription = null;
      _isDirectionEnabled = false;
      _magnetometerErrorCount = 0;
      debugPrint('✅ 기기 방향 추적 중지 완료');
    } catch (e) {
      debugPrint('❌ 기기 방향 추적 중지 실패: $e');
    }
  }
  
  /// 현재 방향 가져오기
  double get currentHeading => _currentHeading;
  
  /// 방향 추적 활성화 여부
  bool get isDirectionEnabled => _isDirectionEnabled;
  
  /// 자력계 센서 사용 가능 여부
  bool get isMagnetometerAvailable => _isMagnetometerAvailable;
  
  /// 사용자 위치 마커 표시 여부
  bool get hasUserLocationMarker => _userLocationMarker != null;
  
  /// 서비스 정리
  void dispose() {
    debugPrint('🧹 CustomUserLocationMarker 정리');
    
    _stopDirectionTracking();
    _removeAllMarkers();
    
    _mapController = null;
    _context = null;
    _userLocationMarker = null;
    _accuracyCircle = null;
    _directionArrow = null;
    _isMagnetometerAvailable = true;
    _magnetometerErrorCount = 0;
  }
}

