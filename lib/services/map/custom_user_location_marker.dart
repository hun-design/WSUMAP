// lib/services/map/custom_user_location_marker.dart

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
  
  NMarker? _userLocationMarker;
  NCircleOverlay? _accuracyCircle;
  NMarker? _directionArrow;
  
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  StreamSubscription<CompassEvent>? _compassSubscription;
  double _currentHeading = 0.0;
  double _mapRotation = 0.0;
  bool _isDirectionEnabled = false;
  bool _isMagnetometerAvailable = true;
  int _magnetometerErrorCount = 0;
  
  static const Color _primaryBlue = Color(0xFF3B82F6);
  
  /// 지도 컨트롤러 설정 (안전한 초기화)
  void setMapController(NaverMapController controller) {
    try {
      _mapController = controller;
      debugPrint('✅ CustomUserLocationMarker 지도 컨트롤러 설정 완료');
      
      // 🔥 iOS에서는 지도 컨트롤러 설정 후 충분한 지연을 두고 방향 추적 시작
      if (_magnetometerSubscription == null && _compassSubscription == null) {
        _isDirectionEnabled = true;
        
        if (Platform.isIOS) {
          // iOS에서는 3초 지연 후 시작 (flutter_compass 안정성 확보)
          Future.delayed(const Duration(seconds: 3), () {
            if (_isDirectionEnabled && _mapController != null) {
              _startDirectionTracking();
            }
          });
        } else {
          // Android는 즉시 시작
          _startDirectionTracking();
        }
      }
    } catch (e) {
      debugPrint('❌ CustomUserLocationMarker 초기화 오류: $e');
    }
  }
  
  /// iOS용 나침반 추적 시작 (안전한 초기화)
  void _startIOSCompassTracking() {
    try {
      debugPrint('🧭 iOS 나침반 추적 시작 (안전한 초기화)');
      
      // 기존 구독 취소
      _compassSubscription?.cancel();
      
      // FlutterCompass.events가 null인지 확인
      if (FlutterCompass.events == null) {
        debugPrint('⚠️ FlutterCompass.events가 null입니다. 2초 후 재시도...');
        Future.delayed(const Duration(seconds: 2), () {
          if (_isDirectionEnabled) {
            _startIOSCompassTracking();
          }
        });
        return;
      }
      
      _compassSubscription = FlutterCompass.events!.listen(
        (CompassEvent event) {
          try {
            final double? heading = event.heading;
            if (heading == null) return;
            
            double newHeading = heading;
            if ((newHeading - _currentHeading).abs() > 0.5) {
              _currentHeading = newHeading;
              _updateDirectionArrowRotation();
              debugPrint('🧭 iOS 나침반 방향 업데이트: ${_currentHeading.toStringAsFixed(1)}도');
            }
          } catch (e) {
            debugPrint('❌ iOS Compass 데이터 처리 오류: $e');
          }
        }, 
        onError: (error) {
          debugPrint('❌ iOS Compass 스트림 오류: $error');
          // 오류 발생 시 5초 후 재시도
          Future.delayed(const Duration(seconds: 5), () {
            if (_isDirectionEnabled) {
              debugPrint('🔄 iOS Compass 재시도...');
              _startIOSCompassTracking();
            }
          });
        },
        cancelOnError: false, // 오류 발생해도 스트림 유지
      );
      
      debugPrint('✅ iOS 나침반 추적 시작 완료');
    } catch (e) {
      debugPrint('❌ iOS 나침반 추적 시작 실패: $e');
      // 초기화 실패 시 5초 후 재시도
      Future.delayed(const Duration(seconds: 5), () {
        if (_isDirectionEnabled) {
          debugPrint('🔄 iOS Compass 초기화 재시도...');
          _startIOSCompassTracking();
        }
      });
    }
  }

  /// 컨텍스트 설정
  void setContext(BuildContext context) {
    _context = context;
    debugPrint('✅ CustomUserLocationMarker 컨텍스트 설정 완료');
  }
  
  /// 지도 회전 각도 업데이트
  void updateMapRotation(double rotation) {
    _mapRotation = rotation;
    if (_directionArrow != null) {
      _updateDirectionArrowRotation();
    }
  }
  
  
  /// 사용자 위치 마커 표시
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
      
      await _removeAllMarkers();
      await Future.delayed(const Duration(milliseconds: 100));
      
      await _addUserLocationMarker(position);
      
      _isDirectionEnabled = true;
      await _addDirectionArrow(position);
      await _startDirectionTracking();
      
      if (!_isMagnetometerAvailable) {
        debugPrint('⚠️ 자력계 센서를 사용할 수 없습니다. 방향 화살표가 작동하지 않을 수 있습니다.');
        debugPrint('💡 iOS 사용자: 설정 > 개인정보 보호 및 보안 > 위치 서비스 > 시스템 서비스 > 나침반 보정을 활성화해주세요.');
      }
      
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
      debugPrint(
          '🔄 사용자 위치 업데이트: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}');

      // If marker doesn't exist, create it.
      if (_userLocationMarker == null) {
        await _addUserLocationMarker(position);
      } else {
        _userLocationMarker!.setPosition(position);
      }

      if (_accuracyCircle != null) {
        // This can stay as is, it's less critical
        _accuracyCircle!.setCenter(position);
        if (accuracy != null) {
          _accuracyCircle!.setRadius(accuracy);
        }
      }

      // If direction arrow doesn't exist, create it
      if (_directionArrow == null && updateDirection && _isMagnetometerAvailable) {
        await _addDirectionArrow(position);
      } else if (_directionArrow != null &&
          updateDirection &&
          _isMagnetometerAvailable) {
        _directionArrow!.setPosition(position);
        await _updateDirectionArrowRotation();
      }

      debugPrint('✅ 사용자 위치 업데이트 완료');
    } catch (e) {
      debugPrint('❌ 사용자 위치 업데이트 실패: $e');
      // No fallback to showUserLocation to avoid creating duplicate markers.
    }
  }
  
  
  /// 사용자 위치 마커 추가
  Future<void> _addUserLocationMarker(NLatLng position) async {
    try {
      final markerIcon = await _createCustomMarkerIcon();
      
      _userLocationMarker = NMarker(
        id: 'user_location_marker',
        position: position,
        icon: markerIcon,
        size: const Size(24, 24),
        anchor: const NPoint(0.5, 0.5),
        angle: 0,
      );
      
      await _mapController!.addOverlay(_userLocationMarker!);
      debugPrint('✅ 사용자 위치 마커 추가 완료');
    } catch (e) {
      debugPrint('❌ 사용자 위치 마커 추가 실패: $e');
    }
  }
  
  
  /// 커스텀 마커 아이콘 생성
  Future<NOverlayImage> _createCustomMarkerIcon() async {
    try {
      return await _createUserLocationMarkerIcon();
    } catch (e) {
      debugPrint('❌ 커스텀 마커 아이콘 생성 실패: $e');
      return const NOverlayImage.fromAssetImage(
        'lib/asset/building_marker_blue.png',
      );
    }
  }
  
  /// 사용자 위치 마커 아이콘 생성
  Future<NOverlayImage> _createUserLocationMarkerIcon() async {
    try {
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
      return const NOverlayImage.fromAssetImage(
        'lib/asset/building_marker_blue.png',
      );
    }
  }
  
  /// 방향 화살표 아이콘 생성
  Future<NOverlayImage> _createDirectionArrowIcon() async {
    try {
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
      return const NOverlayImage.fromAssetImage(
        'lib/asset/building_marker_blue.png',
      );
    }
  }
  
  /// 방향 화살표 추가
  Future<void> _addDirectionArrow(NLatLng position) async {
    try {
      final arrowIcon = await _createDirectionArrowIcon();
      
      _directionArrow = NMarker(
        id: 'user_direction_arrow',
        position: position,
        icon: arrowIcon,
        size: const Size(24, 24),
        anchor: const NPoint(0.5, 0.5),
        angle: _currentHeading,
      );
      
      await _mapController!.addOverlay(_directionArrow!);
    } catch (e) {
      // 🔥 방향 화살표 추가 실패 시 조용히 처리 (플러그인 미지원 가능성)
      _isMagnetometerAvailable = false;
      _directionArrow = null;
    }
  }
  
  /// 방향 추적 시작 (자력계 센서 사용) - 기기 방향 추적
  Future<void> _startDirectionTracking() async {
    try {
      // 기기 방향 추적 시작 로그 제거
      
      // iOS에서 자력계 센서 사용 가능 여부 확인
      if (Platform.isIOS) {
        // iOS는 CoreLocation 기반 나침반 스트림 사용 (flutter_compass)
        _startIOSCompassTracking();
        // iOS Compass(heading) 추적 시작 로그 제거
        return; // iOS는 magnetometer 사용 안 함
      }
      
      _magnetometerSubscription = magnetometerEventStream().listen(
        (event) {
          try {
            // 자력계 데이터 유효성 검사
            if (!_isValidMagnetometerData(event.x, event.y)) {
              _magnetometerErrorCount++;
              if (_magnetometerErrorCount > 10) {
                // 자력계 데이터 오류가 너무 많음 로그 제거
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
            // 자력계 데이터 처리 오류 로그 제거
            _magnetometerErrorCount++;
          }
        },
        onError: (error) {
          // 자력계 스트림 오류 로그 제거
          _magnetometerErrorCount++;
          
          // iOS에서 권한 오류인 경우
          if (Platform.isIOS && error.toString().contains('permission')) {
            // iOS 자력계 센서 권한 필요 로그 제거
            _isMagnetometerAvailable = false;
            _stopDirectionTracking();
          }
        },
      );
      
      // 기기 방향 추적 시작 완료 로그 제거
    } catch (e) {
      // 기기 방향 추적 시작 실패 로그 제거
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
      
      // 방향 업데이트 로그 제거 (각도 변경 시마다 로그 폭발 방지)
    } catch (e) {
      // 🔥 화살표 방향 업데이트 실패 시 조용히 처리 (플러그인 미지원 시 발생)
      // MissingPluginException 등은 조용히 무시
      if (e.toString().contains('MissingPluginException') || 
          e.toString().contains('No implementation found')) {
        // 방향 화살표 기능 비활성화
        _isMagnetometerAvailable = false;
        if (_directionArrow != null) {
          try {
            await _mapController?.deleteOverlay(_directionArrow!.info);
          } catch (_) {
            // 무시
          }
          _directionArrow = null;
        }
      }
      // 기타 오류도 조용히 무시
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
      // 기기 방향 추적 중지 완료 로그 제거
    } catch (e) {
      // 기기 방향 추적 중지 실패 로그 제거
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

