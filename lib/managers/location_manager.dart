// lib/managers/location_manager.dart - 개선된 버전

import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart' as perm;
import 'dart:async';
import 'dart:io';
import '../services/location_service.dart';

  /// 🔥 UI 갱신 콜백 타입들
  typedef LocationUpdateCallback = void Function(loc.LocationData locationData);
  typedef LocationErrorCallback = void Function(String error);
  typedef LocationSentStatusCallback =
      void Function(bool success, DateTime timestamp);
  typedef LocationSendingStateCallback = void Function(bool isEnabled, String? userId);

class LocationManager extends ChangeNotifier {
  loc.LocationData? currentLocation;
  perm.PermissionStatus? permissionStatus;
  final loc.Location _location = loc.Location();
  final LocationService _locationService = LocationService();

  bool _isInitialized = false;
  bool _isLocationServiceEnabled = false;
  bool _isRequestingLocation = false;
  bool _hasLocationPermissionError = false;

  // 🔥 콜백 관리
  LocationUpdateCallback? onLocationFound;
  LocationErrorCallback? onLocationError;
  LocationSentStatusCallback? onLocationSentStatus;
  LocationSendingStateCallback? onLocationSendingStateChanged;

  // 🔥 타이머 및 스트림 관리 (중복 방지)
  Timer? _requestTimer;
  Timer? _locationSendTimer;
  StreamSubscription<loc.LocationData>? _trackingSubscription;
  Completer<loc.LocationData?>? _currentLocationRequest;

  // 🔥 위치 전송 관련
  String? _currentUserId;
  bool _isLocationSendingEnabled = false;
  DateTime? _lastLocationSentTime;
  int _locationSendFailureCount = 0;
  static const int _maxRetryCount = 3;

  // 🔥 즉시 UI 갱신을 위한 플래그
  bool _needsImmediateUIUpdate = false;
  DateTime? _lastUIUpdateTime;
  static const Duration _uiUpdateThrottle = Duration(
    milliseconds: 100,
  ); // 더 빠르게

  // 캐시 관리
  DateTime? _lastLocationTime;
  static const Duration _cacheValidDuration = Duration(
    minutes: 2,
  ); // 30초에서 2분으로 조정 - 위치 안정성 향상

  // 🔥 앱 생명주기 상태 추적
  AppLifecycleState? _lastLifecycleState;

  // 기존 Getters
  bool get isInitialized => _isInitialized;
  bool get isLocationServiceEnabled => _isLocationServiceEnabled;
  bool get isRequestingLocation => _isRequestingLocation;
  bool get hasValidLocation =>
      currentLocation?.latitude != null && currentLocation?.longitude != null;
  bool get hasLocationPermissionError => _hasLocationPermissionError;

  // 🔥 추가 Getters
  bool get isLocationSendingEnabled => _isLocationSendingEnabled;
  String? get currentUserId => _currentUserId;
  DateTime? get lastLocationSentTime => _lastLocationSentTime;
  int get locationSendFailureCount => _locationSendFailureCount;
  bool get needsImmediateUIUpdate => _needsImmediateUIUpdate;

  LocationManager() {
    _initializeImproved();
    _setupLocationServiceCallbacks();
  }

  /// 🔥 LocationService 콜백 설정
  void _setupLocationServiceCallbacks() {
    _locationService.addLocationSentCallback((success, timestamp) {
      _lastLocationSentTime = timestamp;
      if (success) {
        _locationSendFailureCount = 0;
        debugPrint('✅ 위치 전송 성공 - UI 즉시 갱신 요청');
        _requestImmediateUIUpdate();
      } else {
        _locationSendFailureCount++;
      }

      // 외부 콜백 호출
      onLocationSentStatus?.call(success, timestamp);

      notifyListeners();
    });
  }

  /// 🔥 즉시 UI 갱신 요청
  void _requestImmediateUIUpdate() {
    final now = DateTime.now();

    // 스로틀링: 너무 자주 호출되지 않도록
    if (_lastUIUpdateTime != null &&
        now.difference(_lastUIUpdateTime!) < _uiUpdateThrottle) {
      return;
    }

    _needsImmediateUIUpdate = true;
    _lastUIUpdateTime = now;

    // 다음 프레임에서 플래그 리셋
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _needsImmediateUIUpdate = false;
    });

    notifyListeners();
  }


  /// 🔥 개선된 초기화 (권한 요청 추가)
  Future<void> _initializeImproved() async {
    debugPrint('🚀 LocationManager 개선된 초기화...');

    try {
      // 🔥 1. 권한과 서비스를 병렬로 확인 (더 빠른 초기화)
      final hasPermission = await _requestLocationPermissionSafely();
      if (!hasPermission) {
        debugPrint('❌ 위치 권한 없음 - 초기화 제한적으로 완료');
        _hasLocationPermissionError = true;
        _isInitialized = true;
        notifyListeners();
        return;
      }

      // 🔥 2. 권한이 있을 때만 LocationService 초기화 (타임아웃 단축)
      await _locationService.initialize().timeout(
        const Duration(seconds: 2), // 2초 타임아웃
        onTimeout: () {
          debugPrint('⏰ LocationService 초기화 타임아웃 - 계속 진행');
          throw TimeoutException(
            'LocationService 초기화 타임아웃',
            const Duration(seconds: 2),
          );
        },
      );

      // 🔥 3. 플랫폼별 최적화된 설정 (더 빠른 설정)
      if (Platform.isIOS) {
        debugPrint('📱 iOS 최적화 설정');
        try {
          await _location
              .changeSettings(accuracy: loc.LocationAccuracy.balanced)
              .timeout(const Duration(seconds: 1));
        } catch (e) {
          debugPrint('⏰ iOS 설정 타임아웃 - 기본값 사용: $e');
        }
      } else {
        debugPrint('🤖 Android 최적화 설정');
        try {
          await _location
              .changeSettings(
                accuracy: loc.LocationAccuracy.balanced,
                interval: 3000, // 5000에서 3000으로 단축
                distanceFilter: 5, // 10에서 5로 단축
              )
              .timeout(const Duration(seconds: 1));
        } catch (e) {
          debugPrint('⏰ Android 설정 타임아웃 - 기본값 사용: $e');
        }
      }

      _isInitialized = true;
      _isLocationServiceEnabled = true;
      _hasLocationPermissionError = false;
      notifyListeners();
      debugPrint('✅ LocationManager 개선된 초기화 완료');
    } catch (e) {
      debugPrint('❌ 초기화 오류: $e');
      _hasLocationPermissionError = true;
      _isInitialized = true; // 오류가 있어도 계속 진행
      notifyListeners();
    }
  }

  /// 🔥 안전한 위치 권한 요청 (permission_handler 사용)
  Future<bool> _requestLocationPermissionSafely() async {
    // 1. 위치 서비스 활성화 확인
    _isLocationServiceEnabled = await perm.Permission.location.serviceStatus.isEnabled;
    if (!_isLocationServiceEnabled) {
      debugPrint('🔧 위치 서비스 비활성화됨. 사용자에게 활성화 요청은 다른 곳에서 처리.');
      // 여기서 직접 요청하지 않고, UI에서 사용자에게 안내 후 설정으로 보내는 것을 권장.
      // return false; // 일단 진행
    }

    // 2. 위치 권한 요청
    var status = await perm.Permission.location.status;
    debugPrint('📋 현재 위치 권한 상태: $status');

    if (status.isDenied) {
      status = await perm.Permission.location.request();
      debugPrint('📋 위치 권한 요청 결과: $status');
    }

    if (status.isPermanentlyDenied) {
      debugPrint('🚫 위치 권한이 영구적으로 거부됨');
      _hasLocationPermissionError = true;
      // 🔥 자동으로 설정 화면을 여는 대신, 사용자에게 알림만 하고 UI에서 처리하도록 변경
      // UI에서 설정으로 이동하도록 안내해야 함
      // perm.openAppSettings(); // 자동 열기 제거
      return false;
    }

    if (status.isGranted) {
      debugPrint('✅ 위치 권한 획득.');
      // 3. (Android만 해당) 백그라운드 위치 권한 확인 및 요청
      if (Platform.isAndroid) {
        var backgroundStatus = await perm.Permission.locationAlways.status;
        debugPrint('📋 현재 백그라운드 위치 권한 상태: $backgroundStatus');
        if (backgroundStatus.isDenied) {
          backgroundStatus = await perm.Permission.locationAlways.request();
          debugPrint('📋 백그라운드 위치 권한 요청 결과: $backgroundStatus');
        }
        // 🔥 백그라운드 권한이 영구 거부되어도 자동으로 설정 화면을 열지 않음
        // if(backgroundStatus.isPermanentlyDenied){
        //   perm.openAppSettings(); // 자동 열기 제거
        // }
      }
      _hasLocationPermissionError = false;
      return true;
    }
    
    _hasLocationPermissionError = true;
    return false;
  }


  /// 🔥 실제 GPS 위치인지 확인
  bool isActualGPSLocation(loc.LocationData locationData) {
    return LocationService.isActualGPSLocation(locationData);
  }

  /// 🔥 초고속 위치 요청 (Welcome 화면용) - 더 적극적으로 수정
  Future<loc.LocationData?> requestLocationQuickly() async {
    debugPrint('⚡ 초고속 위치 요청 시작...');

    try {
      // 1. 캐시 확인 (더 빠른 캐시 사용)
      if (_isCacheValid() && currentLocation != null) {
        debugPrint('⚡ 캐시된 위치 즉시 사용');
        if (isActualGPSLocation(currentLocation!)) {
          _scheduleLocationCallback(currentLocation!);
          return currentLocation;
        }
      }

      // 2. 🔥 권한 재확인 및 요청 (더 적극적으로)
      debugPrint('🔐 권한 상태 재확인 중...');
      await recheckPermissionStatus();
      
      if (permissionStatus != perm.PermissionStatus.granted) {
        debugPrint('🔐 권한 요청 중...');
        await requestLocation();
        // 권한 요청 후 잠시 대기
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // 3. 🔥 초고속 위치 요청 (iOS 최적화: 더 긴 타임아웃)
      final locationResult = await _locationService.getCurrentLocation(
        forceRefresh: true,
        timeout: const Duration(seconds: 5), // 3초에서 5초로 증가
      );

      if (locationResult.isSuccess && locationResult.locationData != null) {
        final locationData = locationResult.locationData!;

        if (LocationService.isValidLocation(locationData)) {
          currentLocation = locationData;
          _lastLocationTime = DateTime.now();
          _hasLocationPermissionError = false;

          debugPrint('✅ 초고속 위치 획득 성공!');
          debugPrint(
            '📍 위치: ${locationData.latitude}, ${locationData.longitude}',
          );
          debugPrint('📊 정확도: ${locationData.accuracy?.toStringAsFixed(1)}m');

          // 🔥 실제 GPS 위치 확인 및 콜백 호출
          if (isActualGPSLocation(locationData)) {
            debugPrint('🎯 실제 GPS 위치 확인됨');
            _scheduleLocationCallback(locationData);
          } else {
            debugPrint('⚠️ Fallback 위치일 가능성 있음');
          }

          return locationData;
        }
      }

      // 4. 🔥 LocationService 실패 시 직접 위치 요청 시도
      debugPrint('⚠️ LocationService 실패, 직접 위치 요청 시도');
      final directResult = await _directLocationRequest();
      if (directResult != null) {
        return directResult;
      }

      debugPrint('❌ 초고속 위치 획득 실패');
      return null;
    } catch (e) {
      debugPrint('❌ 초고속 위치 요청 오류: $e');
      return null;
    }
  }

  /// 🔥 개선된 위치 요청 (중복 방지 및 상태 관리 강화)
  Future<loc.LocationData?> requestLocation() async {
    // 이미 요청 중이면 기존 요청 대기
    if (_currentLocationRequest != null) {
      debugPrint('⏳ 이미 위치 요청 중... 기존 요청 대기');
      return await _currentLocationRequest!.future;
    }

    debugPrint('📍 개선된 위치 요청 시작...');

    _currentLocationRequest = Completer<loc.LocationData?>();
    _isRequestingLocation = true;
    _hasLocationPermissionError = false;
    notifyListeners();

    try {
      // 1. 캐시 확인
      if (_isCacheValid() && currentLocation != null) {
        debugPrint('⚡ 캐시된 위치 사용');
        if (isActualGPSLocation(currentLocation!)) {
          _scheduleLocationCallback(currentLocation!);
          _currentLocationRequest!.complete(currentLocation);
          return currentLocation;
        } else {
          debugPrint('🗑️ 캐시된 위치가 fallback, 새로 요청');
        }
      }

      // 2. 🔥 LocationService를 통한 위치 요청 (iOS 최적화: 더 긴 타임아웃)
      final locationResult = await _locationService.getCurrentLocation(
        forceRefresh: true,
        timeout: const Duration(seconds: 5), // iOS에서 더 긴 시간 필요
      );

      if (locationResult.isSuccess && locationResult.locationData != null) {
        final locationData = locationResult.locationData!;

        if (LocationService.isValidLocation(locationData)) {
          currentLocation = locationData;
          _lastLocationTime = DateTime.now();
          _hasLocationPermissionError = false;

          debugPrint('✅ LocationService로 위치 획득 성공!');
          debugPrint(
            '📍 위치: ${locationData.latitude}, ${locationData.longitude}',
          );
          debugPrint('📊 정확도: ${locationData.accuracy?.toStringAsFixed(1)}m');

          // 🔥 실제 GPS 위치 확인 및 콜백 호출
          if (isActualGPSLocation(locationData)) {
            debugPrint('🎯 실제 GPS 위치 확인됨');
            _scheduleLocationCallback(locationData);
            _requestImmediateUIUpdate();
          } else {
            debugPrint('⚠️ Fallback 위치 - 재시도 필요');
            // 한 번 더 시도
            await _retryLocationRequestOnce();
          }

          _currentLocationRequest!.complete(currentLocation);
          return currentLocation;
        }
      }

      // 3. 🔥 LocationService 실패 시 직접 위치 요청
      debugPrint('⚠️ LocationService 실패, 직접 위치 요청 시도');
      final fallbackResult = await _directLocationRequest();
      _currentLocationRequest!.complete(fallbackResult);
      return fallbackResult;
    } catch (e) {
      debugPrint('❌ 위치 요청 실패: $e');
      _hasLocationPermissionError = true;
      onLocationError?.call('위치 요청 실패: $e');
      _currentLocationRequest!.complete(null);
      return null;
    } finally {
      _isRequestingLocation = false;
      _requestTimer?.cancel();
      _requestTimer = null;
      _currentLocationRequest = null;
      notifyListeners();
    }
  }

  /// 🔥 직접 위치 요청 (LocationService 실패 시 백업)
  Future<loc.LocationData?> _directLocationRequest() async {
    try {
      debugPrint('🎯 직접 GPS 위치 획득 시도...');

      // 권한 확인
      final hasPermission = await _requestLocationPermissionSafely();
      if (!hasPermission) {
        debugPrint('❌ 위치 권한 없음');
        _hasLocationPermissionError = true;
        return null;
      }

      // 실제 위치 요청 (iOS 최적화: 더 긴 타임아웃)
      final locationData = await _location.getLocation().timeout(
        const Duration(seconds: 8), // iOS에서 더 긴 시간 필요
        onTimeout: () {
          debugPrint('⏰ 직접 위치 획득 타임아웃');
          throw TimeoutException('직접 위치 획득 타임아웃', const Duration(seconds: 8));
        },
      );

      if (_isLocationDataValid(locationData)) {
        if (isActualGPSLocation(locationData)) {
          currentLocation = locationData;
          _lastLocationTime = DateTime.now();
          _hasLocationPermissionError = false;

          debugPrint('✅ 직접 위치 요청으로 실제 GPS 위치 획득!');
          _scheduleLocationCallback(locationData);
          _requestImmediateUIUpdate();
          return locationData;
        } else {
          debugPrint('⚠️ 직접 요청도 Fallback 위치');
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ 직접 위치 요청 실패: $e');
      _hasLocationPermissionError = true;
      return null;
    }
  }

  /// 🔥 한 번 더 위치 재시도
  Future<void> _retryLocationRequestOnce() async {
    try {
      debugPrint('🔄 위치 재시도 한 번...');

      await Future.delayed(const Duration(seconds: 1));

      final locationResult = await _locationService.forceRefreshLocation(
        timeout: const Duration(seconds: 8),
      );

      if (locationResult.isSuccess && locationResult.locationData != null) {
        final locationData = locationResult.locationData!;

        if (_isLocationDataValid(locationData) &&
            isActualGPSLocation(locationData)) {
          currentLocation = locationData;
          _lastLocationTime = DateTime.now();
          _hasLocationPermissionError = false;

          debugPrint('✅ 재시도로 실제 GPS 위치 획득!');
          _scheduleLocationCallback(locationData);
          _requestImmediateUIUpdate();
        }
      }
    } catch (e) {
      debugPrint('❌ 위치 재시도 실패: $e');
    }
  }

  /// 🔥 개선된 주기적 위치 전송 (즉시 UI 갱신 포함)
  void startPeriodicLocationSending({required String userId}) {
    debugPrint('🚀 개선된 주기적 위치 전송 시작 (5초 간격)');
    debugPrint('👤 사용자 ID: $userId');

    // 🔥 게스트 사용자는 위치 전송 제외
    if (userId.startsWith('guest_')) {
      debugPrint('⚠️ 게스트 사용자는 위치 전송 제외');
      return;
    }

    // 이미 시작된 경우 중복 시작 방지
    if (_isLocationSendingEnabled && _currentUserId == userId) {
      debugPrint('⚠️ 이미 동일한 사용자로 위치 전송 중');
      return;
    }

    _currentUserId = userId;
    _isLocationSendingEnabled = true;
    _locationSendFailureCount = 0;

    // 기존 타이머 정리
    _locationSendTimer?.cancel();

    // 🔥 즉시 한 번 전송 (UI 즉시 갱신)
    _sendCurrentLocationToServerImproved();

    // 5초마다 전송하는 타이머 설정
    _locationSendTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isLocationSendingEnabled) {
        timer.cancel();
        return;
      }
      _sendCurrentLocationToServerImproved();
    });

    // 🔥 실시간 위치 추적도 시작 (UI 갱신 포함)
    startLocationTrackingImproved(
      onLocationChanged: (locationData) {
        debugPrint('📍 실시간 위치 업데이트됨 - UI 즉시 갱신');
        _requestImmediateUIUpdate();
      },
    );

    // 🔥 위치 전송 상태 변경 콜백 호출
    onLocationSendingStateChanged?.call(true, userId);
    notifyListeners();
  }

  /// 🔥 주기적 위치 전송 중지
  void stopPeriodicLocationSending() {
    debugPrint('⏹️ 주기적 위치 전송 중지');

    _locationSendTimer?.cancel();
    _locationSendTimer = null;
    _isLocationSendingEnabled = false;
    _currentUserId = null;
    _locationSendFailureCount = 0;

    // 실시간 위치 추적도 중지
    stopLocationTracking();

    // 🔥 위치 전송 상태 변경 콜백 호출
    onLocationSendingStateChanged?.call(false, null);
    notifyListeners();
  }

  /// 🔥 강제 위치 전송 중지 (앱 종료 시)
  void forceStopLocationSending() {
    debugPrint('🚫 강제 위치 전송 중지');

    // 모든 타이머 즉시 중지
    _locationSendTimer?.cancel();
    _locationSendTimer = null;

    // 모든 상태 초기화
    _isLocationSendingEnabled = false;
    _currentUserId = null;
    _locationSendFailureCount = 0;

    // 실시간 위치 추적도 중지
    stopLocationTracking();

    // 🔥 위치 전송 상태 변경 콜백 호출
    onLocationSendingStateChanged?.call(false, null);
    debugPrint('✅ 강제 위치 전송 중지 완료');
    notifyListeners();
  }

  /// 🔥 개선된 현재 위치를 서버로 전송 (즉시 UI 갱신 포함)
  Future<void> _sendCurrentLocationToServerImproved() async {
    if (!_isLocationSendingEnabled || _currentUserId == null) {
      debugPrint('⚠️ 위치 전송이 비활성화되어 있거나 사용자 ID가 없음');
      return;
    }

    try {
      // 현재 위치 확인
      if (currentLocation == null ||
          !LocationService.isValidLocation(currentLocation)) {
        debugPrint('⚠️ 유효한 위치 데이터가 없음, 새로 요청');
        await requestLocation();
      }

      // 여전히 위치가 없으면 실패 처리
      if (currentLocation == null ||
          !LocationService.isValidLocation(currentLocation)) {
        debugPrint('❌ 위치 데이터를 가져올 수 없음');
        _handleLocationSendFailure();
        return;
      }

      // 실제 GPS 위치인지 확인
      if (!isActualGPSLocation(currentLocation!)) {
        debugPrint('⚠️ Fallback 위치는 전송하지 않음');
        return;
      }

      // 🔥 LocationService를 통한 위치 전송 (콜백 포함)
      final success = await LocationService.sendLocationWithRetry(
        userId: _currentUserId!,
        latitude: currentLocation!.latitude!,
        longitude: currentLocation!.longitude!,
        maxRetries: 2,
        onComplete: (success, timestamp) {
          // 🔥 전송 완료 시 즉시 UI 갱신 요청
          if (success) {
            debugPrint('✅ 위치 전송 성공 - 즉시 UI 갱신 요청');
            _requestImmediateUIUpdate();
          }
        },
      );

      if (success) {
        _lastLocationSentTime = DateTime.now();
        _locationSendFailureCount = 0;
        debugPrint('✅ 위치 전송 성공');

        // 🔥 성공 시 추가 UI 갱신
        _requestImmediateUIUpdate();
        notifyListeners();
      } else {
        _handleLocationSendFailure();
      }
    } catch (e) {
      debugPrint('❌ 위치 전송 중 오류: $e');
      _handleLocationSendFailure();
    }
  }

  /// 🔥 위치 전송 실패 처리 (개선된 버전)
  void _handleLocationSendFailure() {
    _locationSendFailureCount++;
    debugPrint('❌ 위치 전송 실패 (실패 횟수: $_locationSendFailureCount)');

    if (_locationSendFailureCount >= _maxRetryCount) {
      debugPrint('⚠️ 최대 재시도 횟수 초과, 위치 전송 일시 중지');

      // 지수적 백오프로 재시도 간격 증가
      final retryDelay = Duration(
        seconds: 30 * (_locationSendFailureCount - _maxRetryCount + 1),
      );

      Timer(retryDelay, () {
        if (_isLocationSendingEnabled && _currentUserId != null) {
          debugPrint('🔄 위치 전송 재시작');
          _locationSendFailureCount = 0;
          _sendCurrentLocationToServerImproved();
        }
      });
    }

    notifyListeners();
  }

  /// 🔥 수동 위치 전송 (즉시 UI 갱신 포함)
  Future<bool> sendLocationManually() async {
    if (_currentUserId == null) {
      debugPrint('❌ 사용자 ID가 없어 수동 위치 전송 불가');
      return false;
    }

    debugPrint('🔄 수동 위치 전송 시작...');

    // 위치 새로고침 후 전송
    await refreshLocation();
    await _sendCurrentLocationToServerImproved();

    return _locationSendFailureCount == 0;
  }

  /// 🔥 즉시 위치 새로고침 및 UI 갱신
  Future<void> refreshLocation() async {
    debugPrint('🔄 즉시 위치 새로고침 시작...');

    currentLocation = null;
    _lastLocationTime = null;
    _hasLocationPermissionError = false;

    // LocationService를 통한 강제 새로고침
    final locationResult = await _locationService.forceRefreshLocation();

    if (locationResult.isSuccess && locationResult.locationData != null) {
      currentLocation = locationResult.locationData;
      _lastLocationTime = DateTime.now();

      if (isActualGPSLocation(currentLocation!)) {
        debugPrint('✅ 새로고침으로 실제 GPS 위치 획득');
        _scheduleLocationCallback(currentLocation!);
        _requestImmediateUIUpdate();
      }
    } else {
      // LocationService 실패 시 직접 요청
      await requestLocation();
    }
  }

  /// 🔥 개선된 실시간 위치 추적 (UI 갱신 포함)
  void startLocationTrackingImproved({
    LocationUpdateCallback? onLocationChanged,
  }) {
    debugPrint('🔄 개선된 실시간 위치 추적 시작...');

    _location.enableBackgroundMode(enable: true);

    // 위치 서비스 빠른 갱신 설정
    _location.changeSettings(
      interval: 1000, // 1초마다 위치 갱신
      distanceFilter: 1, // 1m 이동마다 갱신
      accuracy: loc.LocationAccuracy.high,
    );

    _trackingSubscription?.cancel();

    _trackingSubscription = _location.onLocationChanged.listen(
      (loc.LocationData locationData) {
        debugPrint(
          '📍 위치 이벤트: ${locationData.latitude}, ${locationData.longitude}',
        );
        if (_isLocationDataValid(locationData) &&
            isActualGPSLocation(locationData)) {
          currentLocation = locationData;
          _lastLocationTime = DateTime.now();
          _hasLocationPermissionError = false;

          debugPrint(
            '📍 실시간 실제 위치 업데이트: ${locationData.latitude}, ${locationData.longitude}',
          );

          // 🔥 즉시 UI 갱신 요청
          _requestImmediateUIUpdate();

          if (mounted) {
            notifyListeners();
          }

          try {
            onLocationChanged?.call(locationData);
            _scheduleLocationCallback(locationData);
          } catch (e) {
            debugPrint('❌ 위치 추적 콜백 오류: $e');
          }
        }
      },
      onError: (error) {
        debugPrint('❌ 위치 추적 오류: $error');
        _hasLocationPermissionError = true;
        onLocationError?.call('위치 추적 오류: $error');
        if (mounted) {
          notifyListeners();
        }
      },
    );
  }

  /// 위치 추적 중지
  void stopLocationTracking() {
    debugPrint('⏹️ 위치 추적 중지');
    _trackingSubscription?.cancel();
    _trackingSubscription = null;
  }

  /// 위치 데이터 유효성 검증
  bool _isLocationDataValid(loc.LocationData? data) {
    return LocationService.isValidLocation(data);
  }

  /// 캐시 유효성 확인
  bool _isCacheValid() {
    if (currentLocation == null || _lastLocationTime == null) return false;

    final now = DateTime.now();
    final timeDiff = now.difference(_lastLocationTime!);

    return timeDiff <= _cacheValidDuration;
  }

  /// 🔥 개선된 콜백 호출 (UI 갱신 포함)
  void _scheduleLocationCallback(loc.LocationData locationData) {
    try {
      onLocationFound?.call(locationData);
      debugPrint('✅ 위치 콜백 호출 완료');

      // 🔥 콜백 호출 후 UI 갱신 요청
      _requestImmediateUIUpdate();
    } catch (e) {
      debugPrint('❌ 위치 콜백 실행 오류: $e');
      onLocationError?.call('위치 콜백 실행 오류: $e');
    }
  }

  /// 위치 초기화
  void clearLocation() {
    currentLocation = null;
    _lastLocationTime = null;
    _hasLocationPermissionError = false;
    _requestImmediateUIUpdate();
    notifyListeners();
  }

  /// 🔥 개선된 앱 라이프사이클 변경 처리
  void handleAppLifecycleChange(AppLifecycleState state) {
    // 🔥 중복 처리 방지
    if (_lastLifecycleState == state) {
      return;
    }
    _lastLifecycleState = state;

    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('📱 앱 복귀 - 위치 서비스 재시작');
        _resumeLocationServices();
        break;

      case AppLifecycleState.paused:
        debugPrint('📱 앱 일시정지 - 위치 서비스 중단');
        _pauseLocationServices();
        break;

      case AppLifecycleState.detached:
        debugPrint('📱 앱 종료 - 모든 서비스 정리');
        _cleanupAllServices();
        break;

      default:
        break;
    }
  }

  /// 🔥 위치 서비스 재시작
  void _resumeLocationServices() {
    if (_isLocationSendingEnabled && _currentUserId != null) {
      startPeriodicLocationSending(userId: _currentUserId!);
    }
  }

  /// 🔥 위치 서비스 일시정지
  void _pauseLocationServices() {
    stopPeriodicLocationSending();
    stopLocationTracking();
  }

  /// 🔥 모든 서비스 정리
  void _cleanupAllServices() {
    stopPeriodicLocationSending();
    stopLocationTracking();
    clearLocation();
  }

  /// 권한 상태 재확인
  Future<void> recheckPermissionStatus() async {
    debugPrint('🔄 권한 상태 재확인...');
    permissionStatus = await perm.Permission.location.status;
    if (!permissionStatus!.isGranted) {
      _hasLocationPermissionError = true;
    } else {
      if (Platform.isAndroid) {
        final backgroundStatus = await perm.Permission.locationAlways.status;
        if (!backgroundStatus.isGranted) {
          _hasLocationPermissionError = true;
        } else {
          _hasLocationPermissionError = false;
        }
      } else {
        _hasLocationPermissionError = false;
      }
    }
    notifyListeners();
  }

  /// 🔥 개선된 위치 전송 상태 정보
  Map<String, dynamic> getLocationSendingStatus() {
    return {
      'isEnabled': _isLocationSendingEnabled,
      'userId': _currentUserId,
      'lastSentTime': _lastLocationSentTime?.toIso8601String(),
      'failureCount': _locationSendFailureCount,
      'hasCurrentLocation': currentLocation != null,
      'isActualGPS': currentLocation != null
          ? isActualGPSLocation(currentLocation!)
          : false,
      'needsImmediateUIUpdate': _needsImmediateUIUpdate,
      'lastUIUpdateTime': _lastUIUpdateTime?.toIso8601String(),
      'cacheValid': _isCacheValid(),
    };
  }

  /// 🔥 콜백 등록 메서드들
  void setLocationFoundCallback(LocationUpdateCallback callback) {
    onLocationFound = callback;
  }

  void setLocationErrorCallback(LocationErrorCallback callback) {
    onLocationError = callback;
  }

  void setLocationSentStatusCallback(LocationSentStatusCallback callback) {
    onLocationSentStatus = callback;
  }

  void setLocationSendingStateCallback(LocationSendingStateCallback callback) {
    onLocationSendingStateChanged = callback;
  }

  /// mounted 상태 확인
  bool get mounted => hasListeners;

  /// 🔥 개선된 dispose 메서드
  @override
  void dispose() {
    debugPrint('🧹 LocationManager dispose 시작...');

    // 모든 타이머 및 스트림 정리
    _requestTimer?.cancel();
    _trackingSubscription?.cancel();
    _locationSendTimer?.cancel();

    // 진행 중인 요청 완료
    _currentLocationRequest?.complete(null);

    // 모든 상태 초기화
    _isLocationSendingEnabled = false;
    _currentUserId = null;
    _needsImmediateUIUpdate = false;

    // LocationService 콜백 정리
    _locationService.dispose();

    debugPrint('🧹 LocationManager dispose 완료');
    super.dispose();
  }
}
