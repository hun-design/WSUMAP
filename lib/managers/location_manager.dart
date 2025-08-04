// lib/managers/location_manager.dart - 개선된 버전

import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'dart:async';
import 'dart:io';
import 'package:location/location.dart';
import '../services/location_service.dart';

/// 🔥 UI 갱신 콜백 타입들
typedef LocationUpdateCallback = void Function(loc.LocationData locationData);
typedef LocationErrorCallback = void Function(String error);
typedef LocationSentStatusCallback =
    void Function(bool success, DateTime timestamp);

class LocationManager extends ChangeNotifier {
  loc.LocationData? currentLocation;
  loc.PermissionStatus? permissionStatus;
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
  static const Duration _uiUpdateThrottle = Duration(milliseconds: 100); // 더 빠르게

  // 캐시 관리
  DateTime? _lastLocationTime;
  static const Duration _cacheValidDuration = Duration(seconds: 30);  // 2분에서 30초로 다시 조정

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

  /// 🔥 빠른 위치 요청 (중복 방지 강화)
  Future<LocationData?> requestLocationQuickly() async {
    // 이미 요청 중이면 기존 요청 대기
    if (_currentLocationRequest != null) {
      debugPrint('⏳ 기존 위치 요청 대기 중...');
      return await _currentLocationRequest!.future;
    }

    if (hasValidLocation && currentLocation != null && _isCacheValid()) {
      debugPrint('⚡ 캐시된 위치 반환');
      return currentLocation;
    }

    // 🔥 매우 빠른 위치 요청 (Welcome 화면용)
    return await _requestLocationVeryQuickly();
  }

  /// 🔥 매우 빠른 위치 요청 (Welcome 화면 전용)
  Future<LocationData?> _requestLocationVeryQuickly() async {
    if (_currentLocationRequest != null) {
      return await _currentLocationRequest!.future;
    }

    final completer = Completer<LocationData?>();
    _currentLocationRequest = completer;

    try {
      debugPrint('🚀 매우 빠른 위치 요청 시작...');

      // 1. 직접 위치 요청 (가장 빠름)
      try {
        final locationData = await _location.getLocation().timeout(
          const Duration(seconds: 2), // 매우 짧은 타임아웃
          onTimeout: () {
            debugPrint('⏰ 직접 위치 요청 타임아웃 (2초)');
            throw TimeoutException('직접 위치 요청 타임아웃', const Duration(seconds: 2));
          },
        );

        currentLocation = locationData;
        _lastLocationTime = DateTime.now();
        _hasLocationPermissionError = false;
        notifyListeners();

        debugPrint('✅ 매우 빠른 위치 요청 성공!');
        completer.complete(locationData);
        return locationData;

      } catch (directError) {
        debugPrint('⚠️ 직접 위치 요청 실패: $directError');
        
        // 2. LocationService를 통한 요청 (백업)
        try {
          final locationResult = await _locationService.getCurrentLocation(
            forceRefresh: true,
            timeout: const Duration(seconds: 3), // 짧은 타임아웃
          );

          if (locationResult.isSuccess && locationResult.locationData != null) {
            currentLocation = locationResult.locationData!;
            _lastLocationTime = DateTime.now();
            _hasLocationPermissionError = false;
            notifyListeners();

            debugPrint('✅ LocationService를 통한 빠른 위치 요청 성공!');
            completer.complete(locationResult.locationData);
            return locationResult.locationData;
          } else {
            throw Exception('LocationService 위치 요청 실패');
          }

        } catch (serviceError) {
          debugPrint('❌ LocationService 위치 요청도 실패: $serviceError');
          completer.complete(null);
          return null;
        }
      }

    } catch (e) {
      debugPrint('❌ 매우 빠른 위치 요청 실패: $e');
      completer.complete(null);
      return null;
    } finally {
      _currentLocationRequest = null;
    }
  }

  /// 🔥 개선된 초기화 (권한 요청 추가)
  Future<void> _initializeImproved() async {
    debugPrint('🚀 LocationManager 개선된 초기화...');

    try {
      // 🔥 1. 먼저 권한 확인 및 요청
      final hasPermission = await _requestLocationPermissionSafely();
      if (!hasPermission) {
        debugPrint('❌ 위치 권한 없음 - 초기화 제한적으로 완료');
        _hasLocationPermissionError = true;
        _isInitialized = true;
        notifyListeners();
        return;
      }

      // 🔥 2. 권한이 있을 때만 LocationService 초기화
      await _locationService.initialize();

      // 🔥 3. 플랫폼별 최적화된 설정
      if (Platform.isIOS) {
        debugPrint('📱 iOS 최적화 설정');
        await _location.changeSettings(accuracy: loc.LocationAccuracy.balanced);
      } else {
        debugPrint('🤖 Android 최적화 설정');
        await _location.changeSettings(
          accuracy: loc.LocationAccuracy.balanced,
          interval: 5000,
          distanceFilter: 10,
        );
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

  /// 🔥 안전한 위치 권한 요청
  Future<bool> _requestLocationPermissionSafely() async {
    try {
      debugPrint('🔐 위치 권한 요청 시작...');

      // 1. 현재 권한 상태 확인
      var permissionStatus = await _location.hasPermission();
      debugPrint('📋 현재 권한 상태: $permissionStatus');

      // 2. 권한이 없으면 요청
      if (permissionStatus == loc.PermissionStatus.denied) {
        debugPrint('🔐 권한 요청 중...');
        permissionStatus = await _location.requestPermission();
        debugPrint('📋 권한 요청 결과: $permissionStatus');
      }

      // 3. 권한이 있으면 서비스 상태 확인
      if (permissionStatus == loc.PermissionStatus.granted) {
        debugPrint('✅ 위치 권한 허용됨');

        // 4. 위치 서비스 활성화 확인
        bool serviceEnabled = await _location.serviceEnabled();
        debugPrint('📋 위치 서비스 상태: $serviceEnabled');

        if (!serviceEnabled) {
          debugPrint('🔧 위치 서비스 활성화 요청...');
          serviceEnabled = await _location.requestService();
          debugPrint('📋 위치 서비스 요청 결과: $serviceEnabled');
        }

        return serviceEnabled;
      }

      if (permissionStatus == loc.PermissionStatus.deniedForever) {
        debugPrint('🚫 위치 권한이 영구적으로 거부됨');
        _hasLocationPermissionError = true;
        return false;
      }

      debugPrint('❌ 위치 권한 거부됨');
      return false;
    } catch (e) {
      debugPrint('❌ 권한 요청 중 오류: $e');
      return false;
    }
  }

  /// 🔥 조용한 권한 확인 (개선된 버전)
  Future<bool> checkPermissionQuietly() async {
    try {
      debugPrint('🔍 개선된 조용한 권한 확인...');

      final status = await _location.hasPermission().timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint('⏰ 권한 확인 타임아웃');
          return loc.PermissionStatus.denied;
        },
      );

      debugPrint('📋 권한 상태: $status');

      if (status == loc.PermissionStatus.granted) {
        try {
          final serviceEnabled = await _location.serviceEnabled().timeout(
            const Duration(seconds: 1),
            onTimeout: () => true,
          );
          debugPrint('📋 서비스 상태: $serviceEnabled');
          _isLocationServiceEnabled = serviceEnabled;
          return serviceEnabled;
        } catch (e) {
          debugPrint('⚠️ 서비스 확인 실패, true로 가정: $e');
          _isLocationServiceEnabled = true;
          return true;
        }
      }

      _isLocationServiceEnabled = false;
      return false;
    } catch (e) {
      debugPrint('❌ 조용한 권한 확인 실패: $e');
      _isLocationServiceEnabled = false;
      return false;
    }
  }

  /// 🔥 실제 GPS 위치인지 확인
  bool isActualGPSLocation(loc.LocationData locationData) {
    return LocationService.isActualGPSLocation(locationData);
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

      // 2. 🔥 LocationService를 통한 위치 요청
      final locationResult = await _locationService.getCurrentLocation(
        forceRefresh: true,
        timeout: const Duration(seconds: 5),  // 8초에서 5초로 더 단축
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
      final hasPermission = await _simplePermissionCheck();
      if (!hasPermission) {
        debugPrint('❌ 위치 권한 없음');
        _hasLocationPermissionError = true;
        return null;
      }

      // 실제 위치 요청
      final locationData = await _location.getLocation().timeout(
        const Duration(seconds: 4),  // 6초에서 4초로 더 단축
        onTimeout: () {
          debugPrint('⏰ 직접 위치 획득 타임아웃');
          throw TimeoutException('직접 위치 획득 타임아웃', const Duration(seconds: 4));
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

  /// 🔥 단순한 권한 확인
  Future<bool> _simplePermissionCheck() async {
    try {
      final status = await _location.hasPermission().timeout(
        const Duration(seconds: 2),
        onTimeout: () => loc.PermissionStatus.denied,
      );

      if (status == loc.PermissionStatus.granted) {
        final serviceEnabled = await _location.serviceEnabled().timeout(
          const Duration(seconds: 1),
          onTimeout: () => true,
        );

        if (!serviceEnabled) {
          debugPrint('🔧 위치 서비스 요청...');
          try {
            await _location.requestService().timeout(
              const Duration(seconds: 3),
              onTimeout: () => false,
            );
          } catch (e) {
            debugPrint('⚠️ 서비스 요청 실패: $e');
          }
        }
        return true;
      }

      if (status == loc.PermissionStatus.denied) {
        debugPrint('🔐 권한 요청...');
        final requestedStatus = await _location.requestPermission().timeout(
          const Duration(seconds: 8),
          onTimeout: () => loc.PermissionStatus.denied,
        );

        if (requestedStatus == loc.PermissionStatus.granted) {
          try {
            await _location.requestService().timeout(
              const Duration(seconds: 3),
              onTimeout: () => false,
            );
          } catch (e) {
            debugPrint('⚠️ 서비스 요청 실패: $e');
          }
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('❌ 권한 확인 실패: $e');
      return false;
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

    // 위치 서비스 빠른 갱신 설정
    _location.changeSettings(
      interval: 1000, // 1초마다 위치 갱신
      distanceFilter: 1, // 1m 이동마다 갱신
      accuracy: loc.LocationAccuracy.high,
    );

    _trackingSubscription?.cancel();

    _trackingSubscription = _location.onLocationChanged.listen(
      (loc.LocationData locationData) {
        debugPrint('📍 위치 이벤트: ${locationData.latitude}, ${locationData.longitude}');
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
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('📱 앱 복귀 - 위치 전송 및 UI 갱신');

        // 위치 요청
        Future.delayed(const Duration(seconds: 1), () {
          if (!_isCacheValid() && !_isRequestingLocation) {
            refreshLocation(); // 즉시 새로고침
          }
        });

        // 위치 전송이 활성화되어 있으면 즉시 전송
        if (_isLocationSendingEnabled && _currentUserId != null) {
          Future.delayed(const Duration(seconds: 2), () {
            _sendCurrentLocationToServerImproved();
          });
        }
        break;

      case AppLifecycleState.paused:
        debugPrint('📱 앱 일시정지');
        // 🔥 백그라운드에서도 위치 전송 중지
        forceStopLocationSending();
        break;

      case AppLifecycleState.detached:
        debugPrint('📱 앱 종료');
        forceStopLocationSending();
        break;

      default:
        break;
    }
  }

  /// 권한 상태 재확인
  Future<void> recheckPermissionStatus() async {
    debugPrint('🔄 권한 상태 재확인...');
    final hasPermission = await checkPermissionQuietly();
    if (!hasPermission) {
      _hasLocationPermissionError = true;
      notifyListeners();
    }
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
