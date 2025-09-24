// lib/services/location_service.dart - 개선된 버전
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'dart:async';
import 'dart:io';
import '../config/api_config.dart';
import '../utils/ios_location_utils.dart';
import 'api_helper.dart';

/// 위치 획득 결과
class LocationResult {
  final loc.LocationData? locationData;
  final LocationError? error;
  final bool isFromCache;
  final DateTime timestamp;

  LocationResult({
    this.locationData,
    this.error,
    this.isFromCache = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isSuccess => locationData != null && error == null;
  bool get hasValidLocation =>
      locationData?.latitude != null && locationData?.longitude != null;
}

/// 위치 관련 에러
enum LocationError {
  permissionDenied,
  serviceDisabled,
  timeout,
  unknown,
  noLocationFound,
  networkError,
  serverError,
}

/// 위치 전송 성공 콜백 타입
typedef LocationSentCallback = void Function(bool success, DateTime timestamp);

/// 핵심 위치 서비스 - 위치 획득 및 서버 전송
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final loc.Location _location = loc.Location();
  loc.LocationData? _cachedLocation;
  DateTime? _cacheTime;

  // 위치 요청 상태
  bool _isRequesting = false;
  Timer? _requestTimer;
  Completer<LocationResult>? _currentRequest;

  // 캐시 유효 시간 (30초에서 2분으로 다시 조정 - 위치 안정성 향상)
  static const Duration _cacheValidDuration = Duration(minutes: 2);

  // 🔥 위치 전송 성공 콜백들
  final List<LocationSentCallback> _locationSentCallbacks = [];

  /// 🔥 위치 전송 성공 콜백 등록
  void addLocationSentCallback(LocationSentCallback callback) {
    _locationSentCallbacks.add(callback);
  }

  /// 🔥 위치 전송 성공 콜백 제거
  void removeLocationSentCallback(LocationSentCallback callback) {
    _locationSentCallbacks.remove(callback);
  }

  /// 🔥 위치 전송 성공 시 모든 콜백 호출
  void _notifyLocationSent(bool success, DateTime timestamp) {
    for (final callback in _locationSentCallbacks) {
      try {
        callback(success, timestamp);
      } catch (e) {
        debugPrint('❌ 위치 전송 콜백 오류: $e');
      }
    }
  }

  /// 🔥 위치 데이터 유효성 검증 (static 메서드)
  static bool isValidLocation(loc.LocationData? locationData) {
    if (locationData == null) return false;
    if (locationData.latitude == null || locationData.longitude == null)
      return false;

    final lat = locationData.latitude!;
    final lng = locationData.longitude!;

    // 유효한 좌표 범위 확인
    if (lat < -90 || lat > 90) return false;
    if (lng < -180 || lng > 180) return false;

    return true;
  }

  /// 🔥 실제 GPS 위치인지 확인 (LocationManager와 동일한 로직)
  static bool isActualGPSLocation(loc.LocationData locationData) {
    const fallbackLat = 36.3370;
    const fallbackLng = 127.4450;

    if (locationData.latitude == null || locationData.longitude == null) {
      return false;
    }

    final lat = locationData.latitude!;
    final lng = locationData.longitude!;

    // fallback 위치와 정확히 같으면 실제 위치가 아님
    if ((lat - fallbackLat).abs() < 0.0001 &&
        (lng - fallbackLng).abs() < 0.0001) {
      return false;
    }

    return true;
  }

  /// 🔥 서버로 위치 전송 (개선된 버전 - 콜백 포함)
  static Future<bool> sendLocationToServer({
    required String userId,
    required double latitude,
    required double longitude,
    LocationSentCallback? onComplete,
  }) async {
    final timestamp = DateTime.now();
    bool success = false;

    try {
      debugPrint('📤 서버로 위치 전송 시작...');
      debugPrint('👤 사용자 ID: $userId');
      debugPrint('📍 위치: $latitude, $longitude');

      // 데이터 유효성 검증
      if (userId.isEmpty) {
        debugPrint('❌ 사용자 ID가 비어있음');
        return false;
      }

      if (!_isValidCoordinates(latitude, longitude)) {
        debugPrint('❌ 유효하지 않은 좌표');
        return false;
      }

      final url = Uri.parse('${ApiConfig.userBase}/update_location');

      // 🔥 수정된 좌표 매핑: 서버에서 x에 위도, y에 경도를 기대
      final requestBody = {
        'id': userId,
        'x': latitude, // 서버에서 x에 위도를 기대
        'y': longitude, // 서버에서 y에 경도를 기대
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

      debugPrint('📋 요청 URL: $url');
      debugPrint('📋 수정된 요청 데이터: $requestBody');
      debugPrint('📍 좌표 매핑: x(위도)=$latitude, y(경도)=$longitude');

      final response = await ApiHelper.put(
        '${ApiConfig.userBase}/update_location',
        body: requestBody,
      );

      debugPrint('📋 응답 상태: ${response.statusCode}');
      debugPrint('📋 응답 내용: ${response.body}');

      // 상태 코드별 처리
      switch (response.statusCode) {
        case 200:
          debugPrint('✅ 위치 전송 성공 (좌표 매핑 수정됨)');
          success = true;
          break;
        case 400:
          debugPrint('❌ 잘못된 요청 데이터: ${response.body}');
          break;
        case 404:
          debugPrint('❌ 사용자를 찾을 수 없음: ${response.body}');
          break;
        case 500:
          debugPrint('❌ 서버 내부 오류: ${response.body}');
          break;
        default:
          debugPrint('❌ 서버 오류: ${response.statusCode} - ${response.body}');
          break;
      }
    } on SocketException catch (e) {
      debugPrint('❌ 네트워크 연결 오류: $e');
    } on TimeoutException catch (e) {
      debugPrint('❌ 요청 타임아웃: $e');
    } on FormatException catch (e) {
      debugPrint('❌ 데이터 형식 오류: $e');
    } catch (e) {
      debugPrint('❌ 위치 전송 알 수 없는 오류: $e');
    } finally {
      // 🔥 콜백 호출 및 전역 콜백 알림
      onComplete?.call(success, timestamp);
      LocationService()._notifyLocationSent(success, timestamp);
    }

    return success;
  }

  /// 🔥 재시도 로직이 포함된 위치 전송 (개선된 버전)
  static Future<bool> sendLocationWithRetry({
    required String userId,
    required double latitude,
    required double longitude,
    int maxRetries = 3,
    LocationSentCallback? onComplete,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      debugPrint('🔄 위치 전송 시도 $attempt/$maxRetries');

      final success = await sendLocationToServer(
        userId: userId,
        latitude: latitude,
        longitude: longitude,
        onComplete: attempt == maxRetries ? onComplete : null, // 마지막 시도에만 콜백
      );

      if (success) {
        debugPrint('✅ 위치 전송 성공 (시도 $attempt)');
        return true;
      }

      if (attempt < maxRetries) {
        // 지수적 백오프로 재시도 간격 증가
        final delay = Duration(seconds: attempt * 2);
        debugPrint('⏳ ${delay.inSeconds}초 후 재시도...');
        await Future.delayed(delay);
      }
    }

    debugPrint('❌ 모든 재시도 실패');
    return false;
  }

  /// 🔥 좌표 유효성 검증 (private helper)
  static bool _isValidCoordinates(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  /// 🔥 위치 데이터 검증 및 정규화 (좌표 매핑 수정)
  static Map<String, dynamic>? validateAndNormalizeLocation({
    required String userId,
    required double latitude,
    required double longitude,
  }) {
    // 사용자 ID 검증
    if (userId.trim().isEmpty) {
      debugPrint('❌ 사용자 ID가 비어있음');
      return null;
    }

    // 좌표 유효성 검증
    if (!_isValidCoordinates(latitude, longitude)) {
      debugPrint('❌ 유효하지 않은 좌표: ($latitude, $longitude)');
      return null;
    }

    // 🔥 수정된 좌표 매핑으로 정규화된 데이터 반환
    return {
      'id': userId.trim(),
      'x': latitude, // 서버에서 x에 위도를 기대
      'y': longitude, // 서버에서 y에 경도를 기대
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// 위치 서비스 초기화 (iOS 최적화 버전)
  Future<void> initialize() async {
    try {
      debugPrint('🚀 LocationService 초기화...');

      // 플랫폼별 설정 (iOS 최적화)
      if (Platform.isIOS) {
        // 🔥 iOS 최적화 설정
        debugPrint('📱 iOS 플랫폼 감지 - iOS 최적화 설정 적용');
        try {
          await _location.changeSettings(
            accuracy: loc.LocationAccuracy.high,
            interval: 2000, // iOS는 더 긴 간격 필요
            distanceFilter: 1,
          ).timeout(
            IOSLocationUtils.getIOSPermissionTimeout(),
            onTimeout: () {
              debugPrint('⏰ iOS 설정 타임아웃 - 기본값 사용');
              throw TimeoutException('iOS 설정 타임아웃', IOSLocationUtils.getIOSPermissionTimeout());
            },
          );
          debugPrint('🍎 iOS 최적화 설정 완료');
        } catch (e) {
          debugPrint('⚠️ iOS 설정 실패, 기본값 사용: $e');
        }
      } else {
        // 🔥 Android 초고속 설정
        try {
          await _location.changeSettings(
            accuracy: loc.LocationAccuracy.high,
            interval: 1000, // Android는 빠른 업데이트
            distanceFilter: 1,
          ).timeout(
            const Duration(milliseconds: 500),
            onTimeout: () {
              debugPrint('⏰ Android 설정 타임아웃 - 기본값 사용');
              throw TimeoutException('Android 설정 타임아웃', const Duration(milliseconds: 500));
            },
          );
          debugPrint('🤖 Android 초고속 설정 완료');
        } catch (e) {
          debugPrint('⚠️ Android 설정 실패, 기본값 사용: $e');
        }
      }

      debugPrint('✅ LocationService 초기화 완료');
    } catch (e) {
      debugPrint('❌ LocationService 초기화 실패: $e');
      // 초기화 실패해도 계속 진행
    }
  }

  /// 🔥 현재 위치 획득 (메인 메서드 - 중복 요청 방지 강화)
  Future<LocationResult> getCurrentLocation({
    bool forceRefresh = false,
    Duration? timeout,
  }) async {
    debugPrint('📍 위치 획득 요청 - forceRefresh: $forceRefresh');

    // 🔥 중복 요청 방지 - 이미 진행 중인 요청이 있으면 대기
    if (_isRequesting && _currentRequest != null) {
      debugPrint('⏳ 이미 위치 요청 중... 기존 요청 대기');
      return await _currentRequest!.future;
    }

    // 캐시된 위치 확인
    if (!forceRefresh && _isCacheValid()) {
      debugPrint('⚡ 캐시된 위치 사용');
      return LocationResult(
        locationData: _cachedLocation,
        isFromCache: true,
        timestamp: _cacheTime!,
      );
    }

    return await _requestLocationWithRetry(timeout: timeout);
  }

  /// 🔥 재시도가 포함된 위치 요청 (초고속 버전)
  Future<LocationResult> _requestLocationWithRetry({
    Duration? timeout,
    int maxRetries = 1,  // 2에서 1로 더 줄임
  }) async {
    if (_isRequesting) {
      debugPrint('⚠️ 이미 위치 요청 중');
      return LocationResult(error: LocationError.unknown);
    }

    _isRequesting = true;
    _currentRequest = Completer<LocationResult>();

    try {
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        debugPrint('🔄 위치 요청 시도 $attempt/$maxRetries');

        // 🔥 iOS 최적화 타임아웃: 플랫폼별 적절한 시간
        final timeoutDuration = timeout ?? IOSLocationUtils.getIOSLocationTimeout();

        try {
          final locationData = await _location.getLocation().timeout(
            timeoutDuration,
            onTimeout: () {
              debugPrint('⏰ 위치 요청 타임아웃 (시도 $attempt)');
              throw TimeoutException('위치 획득 타임아웃', timeoutDuration);
            },
          );

          if (_isLocationDataValid(locationData)) {
            // 🔥 iOS 특화 위치 유효성 검증
            if (Platform.isIOS && !IOSLocationUtils.isValidIOSLocation(locationData)) {
              debugPrint('⚠️ iOS 위치 유효성 검증 실패 (시도 $attempt)');
              if (attempt < maxRetries) {
                await Future.delayed(IOSLocationUtils.getIOSRetryInterval());
                continue;
              }
            }
            
            _updateCache(locationData);
            debugPrint(
              '✅ 위치 획득 성공 (시도 $attempt): ${locationData.latitude}, ${locationData.longitude}',
            );
            debugPrint('📊 정확도: ${locationData.accuracy?.toStringAsFixed(1)}m');

            // 🔥 실제 GPS 위치인지 확인
            if (isActualGPSLocation(locationData)) {
              debugPrint('🎯 실제 GPS 위치 확인됨');
            } else {
              debugPrint('⚠️ Fallback 위치일 가능성 있음');
            }

            final result = LocationResult(
              locationData: locationData,
              timestamp: DateTime.now(),
            );
            
            _currentRequest!.complete(result);
            return result;
          }

          debugPrint('⚠️ 유효하지 않은 위치 데이터 (시도 $attempt)');
        } catch (e) {
          debugPrint('❌ 위치 요청 시도 $attempt 실패: $e');

          if (attempt < maxRetries) {
            // 🔥 iOS 최적화 재시도 간격
            await Future.delayed(IOSLocationUtils.getIOSRetryInterval());
            continue;
          }

          // 마지막 시도에서 실패
          final result = LocationResult(error: _mapExceptionToError(e));
          _currentRequest!.complete(result);
          return result;
        }
      }

      final result = LocationResult(error: LocationError.noLocationFound);
      _currentRequest!.complete(result);
      return result;
    } finally {
      _isRequesting = false;
      _requestTimer?.cancel();
      _requestTimer = null;
      _currentRequest = null;
    }
  }

  /// 🔥 즉시 위치 새로고침 (UI 갱신용)
  Future<LocationResult> forceRefreshLocation({Duration? timeout}) async {
    debugPrint('🔄 강제 위치 새로고침 시작...');
    
    // 캐시 무효화
    invalidateCache();
    
    // 새로운 위치 요청
    return await getCurrentLocation(
      forceRefresh: true,
      timeout: timeout ?? const Duration(seconds: 10),
    );
  }

  /// 기본 위치 제공 (우송대학교)
  LocationResult getFallbackLocation() {
    debugPrint('🏫 기본 위치 제공: 우송대학교');

    final fallbackLocation = loc.LocationData.fromMap({
      'latitude': 36.3370,
      'longitude': 127.4450,
      'accuracy': 50.0,
      'altitude': 0.0,
      'speed': 0.0,
      'speedAccuracy': 0.0,
      'heading': 0.0,
      'time': DateTime.now().millisecondsSinceEpoch.toDouble(),
      'isMock': false,
    });

    _updateCache(fallbackLocation);

    return LocationResult(
      locationData: fallbackLocation,
      timestamp: DateTime.now(),
    );
  }

  /// 위치 데이터 유효성 검증 (instance 메서드)
  bool _isLocationDataValid(loc.LocationData? data) {
    return LocationService.isValidLocation(data);
  }

  /// 캐시 유효성 확인
  bool _isCacheValid() {
    if (_cachedLocation == null || _cacheTime == null) return false;

    final now = DateTime.now();
    final timeDiff = now.difference(_cacheTime!);

    return timeDiff <= _cacheValidDuration;
  }

  /// 캐시 업데이트
  void _updateCache(loc.LocationData locationData) {
    _cachedLocation = locationData;
    _cacheTime = DateTime.now();
  }

  /// 예외를 LocationError로 변환
  LocationError _mapExceptionToError(dynamic exception) {
    if (exception is TimeoutException) {
      return LocationError.timeout;
    }

    final errorString = exception.toString().toLowerCase();

    if (errorString.contains('permission')) {
      return LocationError.permissionDenied;
    }

    if (errorString.contains('service') || errorString.contains('disabled')) {
      return LocationError.serviceDisabled;
    }

    if (errorString.contains('socket') || errorString.contains('network')) {
      return LocationError.networkError;
    }

    if (errorString.contains('server') || errorString.contains('500')) {
      return LocationError.serverError;
    }

    return LocationError.unknown;
  }

  /// 캐시된 위치 반환 (있는 경우)
  loc.LocationData? get cachedLocation => _cachedLocation;

  /// 캐시 유효 여부
  bool get hasCachedLocation => _isCacheValid();

  /// 현재 요청 중 여부
  bool get isRequesting => _isRequesting;

  /// 캐시 무효화
  void invalidateCache() {
    debugPrint('🗑️ 위치 캐시 무효화');
    _cachedLocation = null;
    _cacheTime = null;
  }

  /// 서비스 정리
  void dispose() {
    _requestTimer?.cancel();
    _requestTimer = null;
    _isRequesting = false;
    _currentRequest?.complete(LocationResult(error: LocationError.unknown));
    _currentRequest = null;
    _locationSentCallbacks.clear();
    debugPrint('🧹 LocationService 정리 완료');
  }
}