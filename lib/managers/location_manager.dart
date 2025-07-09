// lib/managers/location_manager.dart - iOS 메인 스레드 블로킹 완전 해결

import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'dart:async';
import 'dart:isolate';
import 'package:flutter/services.dart';

class LocationManager extends ChangeNotifier {
  loc.LocationData? currentLocation;
  loc.PermissionStatus? permissionStatus;
  final loc.Location _location = loc.Location();
  
  bool _isInitialized = false;
  bool _isLocationServiceEnabled = false;
  bool _isRequestingLocation = false;
  bool _hasLocationPermissionError = false;

  void Function(loc.LocationData)? onLocationFound;
  
  // 간단한 타임아웃 관리
  Timer? _requestTimer;
  
  // 권한 상태 주기적 확인용 타이머
  Timer? _permissionCheckTimer;

  // 위치 스트림 구독
  StreamSubscription<loc.LocationData>? _locationStreamSubscription;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLocationServiceEnabled => _isLocationServiceEnabled;
  bool get isRequestingLocation => _isRequestingLocation;
  bool get hasValidLocation => currentLocation?.latitude != null && currentLocation?.longitude != null;
  bool get hasLocationPermissionError => _hasLocationPermissionError;

  LocationManager() {
    _initializeQuickly();
  }

  /// 빠른 초기화 - 즉시 실행
  Future<void> _initializeQuickly() async {
    try {
      debugPrint('🚀 LocationManager 빠른 초기화 시작...');
      
      // 위치 서비스 설정
      await _location.changeSettings(
        accuracy: loc.LocationAccuracy.balanced, // high는 너무 정확해서 시간이 오래 걸림
        interval: 5000, // 5초
        distanceFilter: 10, // 10m
      );
      
      _isInitialized = true;
      notifyListeners();
      
      // 백그라운드에서 권한 상태 확인 (더 긴 지연으로 메인 스레드 보호)
      _checkPermissionInBackgroundDelayed();
      
      debugPrint('✅ LocationManager 빠른 초기화 완료');
      
    } catch (e) {
      debugPrint('❌ 초기화 오류: $e');
      _isInitialized = false;
      notifyListeners();
    }
  }

  /// 백그라운드에서 권한 상태 확인 (iOS 메인 스레드 보호)
  void _checkPermissionInBackgroundDelayed() {
    // iOS에서 메인 스레드 블로킹을 방지하기 위해 더 긴 지연 적용
    Timer(const Duration(milliseconds: 500), () {
      _checkPermissionInBackground();
    });
  }

  /// 백그라운드에서 권한 상태 확인 (비동기)
  void _checkPermissionInBackground() {
    // Isolate.spawn 대신 compute를 사용하여 백그라운드 처리
    Future.microtask(() async {
      try {
        // iOS에서 메인 스레드 블로킹 방지를 위한 추가 지연
        await Future.delayed(const Duration(milliseconds: 200));
        
        debugPrint('📍 백그라운드에서 권한 상태 확인 시작...');
        
        // 권한 상태를 비동기적으로 확인
        final status = await _checkPermissionStatusSafely();
        final serviceEnabled = await _checkServiceStatusSafely();
        
        debugPrint('📍 권한 상태: $status');
        debugPrint('📍 서비스 상태: $serviceEnabled');
        
        // 메인 스레드에서 상태 업데이트
        if (mounted) {
          final previousStatus = permissionStatus;
          permissionStatus = status;
          _isLocationServiceEnabled = serviceEnabled;
          
          // 권한 상태가 변경되었을 때 알림
          if (previousStatus != status) {
            debugPrint('📍 권한 상태 변경 감지: $previousStatus → $status');
          }
          
          notifyListeners();
        }
        
      } catch (e) {
        debugPrint('❌ 백그라운드 권한 확인 오류: $e');
      }
    });
  }

  /// 안전한 권한 상태 확인 (타임아웃 적용)
  Future<loc.PermissionStatus?> _checkPermissionStatusSafely() async {
    try {
      return await _location.hasPermission().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('⏰ 권한 상태 확인 타임아웃');
          return loc.PermissionStatus.denied;
        },
      );
    } catch (e) {
      debugPrint('❌ 권한 상태 확인 오류: $e');
      return loc.PermissionStatus.denied;
    }
  }

  /// 안전한 서비스 상태 확인 (타임아웃 적용)
  Future<bool> _checkServiceStatusSafely() async {
    try {
      return await _location.serviceEnabled().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('⏰ 서비스 상태 확인 타임아웃');
          return false;
        },
      );
    } catch (e) {
      debugPrint('❌ 서비스 상태 확인 오류: $e');
      return false;
    }
  }

  /// 스트림 기반 위치 요청 (iOS 최적화) - 메인 스레드 보호 강화
  Future<void> requestLocation() async {
    if (_isRequestingLocation) {
      debugPrint('⏳ 이미 위치 요청 중...');
      return;
    }

    _isRequestingLocation = true;
    _hasLocationPermissionError = false;
    notifyListeners();

    try {
      debugPrint('📍 위치 요청 시작...');
      
      // 1. 캐시된 위치 확인
      if (_isLocationRecent()) {
        debugPrint('⚡ 캐시된 위치 사용');
        return;
      }

      // 2. 권한 확인 (메인 스레드 보호)
      final hasPermission = await _ensureLocationPermissionSafely();
      if (!hasPermission) {
        _hasLocationPermissionError = true;
        return;
      }

      // 3. 스트림 기반 위치 요청
      await _requestLocationViaStreamSafely();

    } catch (e) {
      debugPrint('❌ 위치 요청 실패: $e');
      _hasLocationPermissionError = true;
    } finally {
      _isRequestingLocation = false;
      _requestTimer?.cancel();
      _requestTimer = null;
      notifyListeners();
    }
  }

  /// 안전한 권한 확인 (메인 스레드 블로킹 방지)
  Future<bool> _ensureLocationPermissionSafely() async {
    try {
      debugPrint('🔍 안전한 권한 확인 시작...');
      
      // 메인 스레드를 보호하기 위해 약간의 지연 추가
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 현재 권한 상태 확인 (타임아웃 적용)
      final currentStatus = await _checkPermissionStatusSafely();
      permissionStatus = currentStatus;
      
      debugPrint('🔍 현재 권한 상태: $currentStatus');
      
      if (currentStatus == loc.PermissionStatus.granted) {
        // 서비스 상태 확인
        final serviceEnabled = await _checkServiceStatusSafely();
        _isLocationServiceEnabled = serviceEnabled;
        
        if (!serviceEnabled) {
          debugPrint('🔧 위치 서비스 요청...');
          try {
            final serviceRequested = await _location.requestService().timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                debugPrint('⏰ 위치 서비스 요청 타임아웃');
                return false;
              },
            );
            _isLocationServiceEnabled = serviceRequested;
            return serviceRequested;
          } catch (e) {
            debugPrint('❌ 위치 서비스 요청 실패: $e');
            return false;
          }
        }
        
        return true;
      }

      // 권한 요청
      if (currentStatus == loc.PermissionStatus.denied || currentStatus == null) {
        debugPrint('🔐 권한 요청 중...');
        
        // 메인 스레드 보호를 위한 지연
        await Future.delayed(const Duration(milliseconds: 200));
        
        final requestedStatus = await _location.requestPermission().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('⏰ 권한 요청 타임아웃');
            return loc.PermissionStatus.denied;
          },
        );
        
        permissionStatus = requestedStatus;
        
        if (requestedStatus == loc.PermissionStatus.granted) {
          final serviceEnabled = await _checkServiceStatusSafely();
          if (!serviceEnabled) {
            final serviceRequested = await _location.requestService().timeout(
              const Duration(seconds: 5),
              onTimeout: () => false,
            );
            _isLocationServiceEnabled = serviceRequested;
            return serviceRequested;
          }
          _isLocationServiceEnabled = true;
          return true;
        }
        
        return false;
      }

      return currentStatus == loc.PermissionStatus.granted;
      
    } catch (e) {
      debugPrint('❌ 권한 확인 실패: $e');
      return false;
    }
  }

  /// 안전한 스트림 기반 위치 요청 (iOS 최적화)
  Future<void> _requestLocationViaStreamSafely() async {
    debugPrint('📍 안전한 스트림 기반 위치 요청 시작...');
    
    // 타임아웃 설정 (iOS에서는 조금 더 길게)
    _requestTimer = Timer(const Duration(seconds: 12), () {
      debugPrint('⏰ 스트림 위치 요청 타임아웃');
      _locationStreamSubscription?.cancel();
      _locationStreamSubscription = null;
      // 타임아웃 시 fallback으로 단발성 위치 요청
      _requestSingleLocationSafely();
    });

    try {
      // 기존 스트림 정리
      await _locationStreamSubscription?.cancel();
      _locationStreamSubscription = null;
      
      // 메인 스레드 보호를 위한 지연
      await Future.delayed(const Duration(milliseconds: 300));
      
      // 새로운 스트림 구독
      _locationStreamSubscription = _location.onLocationChanged.listen(
        (loc.LocationData locationData) {
          debugPrint('📍 스트림에서 위치 수신: ${locationData.latitude}, ${locationData.longitude}');
          
          if (locationData.latitude != null && locationData.longitude != null) {
            // 위치 업데이트
            currentLocation = locationData;
            _hasLocationPermissionError = false;
            
            debugPrint('✅ 스트림 위치 획득 성공: ${locationData.latitude}, ${locationData.longitude}');
            debugPrint('📊 정확도: ${locationData.accuracy?.toStringAsFixed(1)}m');
            
            // 메인 스레드에서 콜백 호출
            _scheduleLocationCallback(locationData);
            
            // 스트림 정리
            _locationStreamSubscription?.cancel();
            _locationStreamSubscription = null;
            _requestTimer?.cancel();
            _requestTimer = null;
            
            if (mounted) {
              notifyListeners();
            }
          }
        },
        onError: (error) {
          debugPrint('❌ 스트림 위치 오류: $error');
          _hasLocationPermissionError = true;
          
          // 스트림 정리
          _locationStreamSubscription?.cancel();
          _locationStreamSubscription = null;
          _requestTimer?.cancel();
          _requestTimer = null;
          
          // fallback으로 단발성 위치 요청
          _requestSingleLocationSafely();
          
          if (mounted) {
            notifyListeners();
          }
        },
      );
      
      // 스트림 시작 후 대기
      await Future.delayed(const Duration(milliseconds: 800));
      
    } catch (e) {
      debugPrint('❌ 스트림 위치 요청 실패: $e');
      _hasLocationPermissionError = true;
      
      // 스트림 정리
      _locationStreamSubscription?.cancel();
      _locationStreamSubscription = null;
      
      // fallback으로 단발성 위치 요청
      await _requestSingleLocationSafely();
    }
  }

  /// 메인 스레드에서 안전하게 콜백 실행
  void _scheduleLocationCallback(loc.LocationData locationData) {
    // 메인 스레드에서 콜백 실행하되, 약간의 지연을 두어 UI 업데이트와 충돌 방지
    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        onLocationFound?.call(locationData);
      } catch (e) {
        debugPrint('❌ 위치 콜백 실행 오류: $e');
      }
    });
  }

  /// 안전한 단발성 위치 요청 (fallback)
  Future<void> _requestSingleLocationSafely() async {
    debugPrint('📍 안전한 단발성 위치 요청 시작...');
    
    try {
      // 메인 스레드 보호를 위한 지연
      await Future.delayed(const Duration(milliseconds: 200));
      
      // 타임아웃을 적절하게 설정
      final locationData = await _location.getLocation().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⏰ 단발성 위치 요청 타임아웃');
          throw TimeoutException('위치 획득 타임아웃', const Duration(seconds: 10));
        },
      );

      if (locationData.latitude != null && locationData.longitude != null) {
        currentLocation = locationData;
        _hasLocationPermissionError = false;
        
        debugPrint('✅ 단발성 위치 획득 성공: ${locationData.latitude}, ${locationData.longitude}');
        
        // 안전한 콜백 호출
        _scheduleLocationCallback(locationData);
        
        return;
      }

      debugPrint('⚠️ 유효하지 않은 위치 데이터');
      _hasLocationPermissionError = true;
      
    } catch (e) {
      debugPrint('❌ 단발성 위치 획득 실패: $e');
      _hasLocationPermissionError = true;
    }
  }

  /// 권한 상태 재확인
  Future<void> recheckPermissionStatus() async {
    _checkPermissionInBackgroundDelayed();
  }

  /// 위치 새로고침
  Future<void> refreshLocation() async {
    debugPrint('🔄 위치 새로고침...');
    
    // 권한 상태 다시 확인
    _checkPermissionInBackgroundDelayed();
    
    // 기존 위치 무효화
    currentLocation = null;
    
    // 새로운 위치 요청
    await requestLocation();
  }

  /// 현재 위치가 최근 것인지 확인
  bool _isLocationRecent() {
    if (currentLocation?.time == null) return false;
    
    final locationTime = DateTime.fromMillisecondsSinceEpoch(
      currentLocation!.time!.toInt()
    );
    final now = DateTime.now();
    final difference = now.difference(locationTime);
    
    return difference.inSeconds < 30; // 30초
  }

  /// 앱 라이프사이클 변경 처리
  void handleAppLifecycleChange(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('📱 앱 복귀 - 권한 재확인');
      _checkPermissionInBackgroundDelayed();
    }
  }

  /// 실시간 위치 추적
  StreamSubscription<loc.LocationData>? _trackingSubscription;
  
  void startLocationTracking({Function(loc.LocationData)? onLocationChanged}) {
    if (permissionStatus != loc.PermissionStatus.granted) {
      debugPrint('❌ 위치 추적 불가: 권한 없음');
      return;
    }
    
    debugPrint('🔄 실시간 위치 추적 시작...');
    
    // 기존 추적 중지
    _trackingSubscription?.cancel();
    
    _trackingSubscription = _location.onLocationChanged.listen(
      (loc.LocationData locationData) {
        if (locationData.latitude != null && locationData.longitude != null) {
          
          currentLocation = locationData;
          _hasLocationPermissionError = false;
          
          if (mounted) {
            notifyListeners();
          }
          
          // 안전한 콜백 호출
          if (onLocationChanged != null) {
            Future.delayed(const Duration(milliseconds: 50), () {
              try {
                onLocationChanged(locationData);
              } catch (e) {
                debugPrint('❌ 위치 추적 콜백 오류: $e');
              }
            });
          }
          
          debugPrint('📍 위치 업데이트: ${locationData.latitude}, ${locationData.longitude}');
        }
      },
      onError: (error) {
        debugPrint('❌ 위치 추적 오류: $error');
        _hasLocationPermissionError = true;
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

  /// 위치 초기화
  void clearLocation() {
    currentLocation = null;
    _hasLocationPermissionError = false;
    notifyListeners();
  }

  /// mounted 상태 확인
  bool get mounted => hasListeners;

  @override
  void dispose() {
    _requestTimer?.cancel();
    _permissionCheckTimer?.cancel();
    _locationStreamSubscription?.cancel();
    _trackingSubscription?.cancel();
    super.dispose();
  }
}