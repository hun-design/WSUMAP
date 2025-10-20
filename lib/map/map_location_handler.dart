// lib/map/map_location_handler.dart - 최적화된 버전

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter_application_1/controllers/map_controller.dart';
import 'package:flutter_application_1/managers/location_manager.dart';
import '../generated/app_localizations.dart';

/// 지도 위치 핸들러
class MapLocationHandler {
  final BuildContext context;
  final MapScreenController controller;
  
  // 상태 변수들
  bool _hasFoundInitialLocation = false;
  bool _isMapReady = false;
  bool _hasTriedAutoMove = false;
  bool _autoMoveScheduled = false;
  Timer? _autoMoveTimer;
  Timer? _forceAutoMoveTimer;
  int _autoMoveRetryCount = 0;
  static const int _maxAutoMoveRetries = 3;
  bool _isRequestingLocation = false;

  // Getters
  bool get hasFoundInitialLocation => _hasFoundInitialLocation;
  bool get isMapReady => _isMapReady;
  bool get hasTriedAutoMove => _hasTriedAutoMove;
  bool get isRequestingLocation => _isRequestingLocation;

  MapLocationHandler({
    required this.context,
    required this.controller,
  });

  void dispose() {
    debugPrint('🗺️ MapLocationHandler dispose 시작...');
    
    // 모든 타이머 정리
    _autoMoveTimer?.cancel();
    _autoMoveTimer = null;
    _forceAutoMoveTimer?.cancel();
    _forceAutoMoveTimer = null;

    // 상태 변수들 초기화
    _hasFoundInitialLocation = false;
    _isMapReady = false;
    _hasTriedAutoMove = false;
    _autoMoveScheduled = false;
    _autoMoveRetryCount = 0;
    _isRequestingLocation = false;
    
    debugPrint('✅ MapLocationHandler dispose 완료');
  }

  void setMapReady(bool ready) {
    _isMapReady = ready;
    if (ready && !_hasTriedAutoMove) {
      final locationManager = Provider.of<LocationManager>(context, listen: false);
      if (locationManager.hasValidLocation) {
        debugPrint('🚀 지도 준비 완료, 즉시 자동 이동 시작');
        scheduleImmediateAutoMove();
      } else {
        debugPrint('⏳ 지도 준비 완료, 위치 대기 중...');
      }
    }
  }

  void setFoundInitialLocation(bool found) {
    _hasFoundInitialLocation = found;
  }

  /// 안전한 위치 권한 체크 및 요청
  Future<void> checkAndRequestLocation() async {
    if (_isRequestingLocation) {
      debugPrint('⚠️ 이미 위치 요청 중입니다.');
      return;
    }

    try {
      _isRequestingLocation = true;
      debugPrint('🔄 권한 상태 재확인 중...');
      
      final locationManager = Provider.of<LocationManager>(context, listen: false);
      
      // LocationManager가 초기화되지 않았으면 잠시 대기
      if (!locationManager.isInitialized) {
        debugPrint('⏳ LocationManager 초기화 대기 중...');
        await Future.delayed(const Duration(milliseconds: 500));
        if (!locationManager.isInitialized) {
          debugPrint('❌ LocationManager 초기화 실패');
          return;
        }
      }

      // 권한 상태 재확인
      await locationManager.recheckPermissionStatus();
      
      // 권한이 없다면 요청
      if (locationManager.permissionStatus != loc.PermissionStatus.granted) {
        debugPrint('🔐 위치 권한 요청 중...');
        await locationManager.requestLocation();
      } else {
        debugPrint('✅ 권한 허용됨 - 위치 요청 시작');
        await locationManager.requestLocation();
      }
    } catch (e) {
      debugPrint('❌ 위치 권한 체크 실패: $e');
    } finally {
      _isRequestingLocation = false;
    }
  }

  /// 안전한 초기 위치 요청
  Future<void> requestInitialLocationSafely(LocationManager locationManager) async {
    if (_isRequestingLocation || _hasFoundInitialLocation) {
      return;
    }

    try {
      _isRequestingLocation = true;
      debugPrint('📍 안전한 초기 위치 요청 시작...');
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      // LocationManager 초기화 대기
      int retries = 0;
      while (!locationManager.isInitialized && retries < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        retries++;
      }

      if (!locationManager.isInitialized) {
        debugPrint('⚠️ LocationManager 초기화 타임아웃');
        _hasFoundInitialLocation = true;
        return;
      }

      debugPrint('✅ LocationManager 초기화 완료');

      // 캐시된 위치 확인
      if (locationManager.hasValidLocation && locationManager.currentLocation != null) {
        debugPrint('🎯 Welcome에서 미리 준비된 위치 발견! 즉시 사용');
        _hasFoundInitialLocation = true;
        
        Future.delayed(const Duration(milliseconds: 200), () {
          checkAndAutoMove();
        });
        return;
      }

      debugPrint('🔄 미리 준비된 위치가 없음, 새로 위치 요청 시작...');
      
      await locationManager.requestLocation();
      
      if (locationManager.hasValidLocation) {
        debugPrint('✅ 새로운 위치 획득 성공!');
        _hasFoundInitialLocation = true;
        
        Future.delayed(const Duration(milliseconds: 300), () {
          checkAndAutoMove();
        });
      } else {
        debugPrint('❌ 위치 획득 실패');
        _hasFoundInitialLocation = true;
      }
    } catch (e) {
      debugPrint('❌ 초기 위치 요청 실패: $e');
      _hasFoundInitialLocation = true;
    } finally {
      _isRequestingLocation = false;
    }
  }

  /// 지도와 위치가 모두 준비되면 자동 이동
  void checkAndAutoMove() {
    debugPrint('🎯 자동 이동 조건 체크...');
    debugPrint('_isMapReady: $_isMapReady');
    debugPrint('_hasFoundInitialLocation: $_hasFoundInitialLocation');
    debugPrint('_hasTriedAutoMove: $_hasTriedAutoMove');
    
    if (_isMapReady && _hasFoundInitialLocation && !_hasTriedAutoMove && !_isRequestingLocation) {
      debugPrint('🎯 조건 충족, 자동 이동 예약');
      scheduleAutoMove();
    } else {
      debugPrint('⏳ 자동 이동 조건 미충족');
    }
  }

  /// 즉시 자동 이동 예약
  void scheduleImmediateAutoMove() {
    if (_autoMoveScheduled) return;
    
    _autoMoveScheduled = true;
    debugPrint('⚡ 즉시 자동 이동 예약됨');
    
    _autoMoveTimer = Timer(const Duration(milliseconds: 500), () {
      if (!_hasTriedAutoMove) {
        executeRobustAutoMove();
      }
    });
    
    _forceAutoMoveTimer = Timer(const Duration(seconds: 2), () {
      if (!_hasTriedAutoMove) {
        debugPrint('🚨 강제 자동 이동 실행');
        executeRobustAutoMove();
      }
    });
  }

  /// 자동 이동 예약
  void scheduleAutoMove() {
    if (_autoMoveScheduled) return;
    
    _autoMoveScheduled = true;
    debugPrint('⏰ 자동 이동 예약됨');
    
    _autoMoveTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (_isMapReady && !_hasTriedAutoMove) {
        timer.cancel();
        executeAutoMove();
      }
    });
    
    Timer(const Duration(seconds: 5), () {
      if (!_hasTriedAutoMove && _isMapReady) {
        _autoMoveTimer?.cancel();
        executeAutoMove();
      }
    });
  }

  /// 강건한 자동 이동 실행
  Future<void> executeRobustAutoMove() async {
    if (_hasTriedAutoMove) return;
    
    try {
      _hasTriedAutoMove = true;
      _autoMoveRetryCount = 0;
      debugPrint('🎯 강건한 자동 이동 시작! (시도 ${_autoMoveRetryCount + 1}/${_maxAutoMoveRetries})');
      
      final locationManager = Provider.of<LocationManager>(context, listen: false);
      if (!locationManager.hasValidLocation) {
        debugPrint('❌ 유효한 위치 없음, 자동 이동 실패');
        return;
      }
      
      await Future.delayed(const Duration(milliseconds: 800));
      
      bool success = await tryMoveToLocation();
      
      if (!success && _autoMoveRetryCount < _maxAutoMoveRetries) {
        _autoMoveRetryCount++;
        _hasTriedAutoMove = false;
        debugPrint('🔄 자동 이동 재시도 예약 (${_autoMoveRetryCount}/${_maxAutoMoveRetries})');
        
        Timer(const Duration(seconds: 1), () {
          if (!_hasTriedAutoMove) {
            executeRobustAutoMove();
          }
        });
      } else if (success) {
        debugPrint('✅ 자동 이동 성공!');
        showLocationMoveSuccess();
      } else {
        debugPrint('❌ 자동 이동 최대 재시도 실패');
      }
    } catch (e) {
      debugPrint('❌ 자동 이동 실행 오류: $e');
      _hasTriedAutoMove = false;
    }
  }

  /// 자동 이동 실행
  Future<void> executeAutoMove() async {
    if (_hasTriedAutoMove) return;
    
    try {
      _hasTriedAutoMove = true;
      debugPrint('🎯 자동 이동 실행!');
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      await controller.moveToMyLocation();
      debugPrint('✅ 자동 이동 완료!');
      
      showLocationMoveSuccess();
    } catch (e) {
      debugPrint('❌ 자동 이동 실패: $e');
      _hasTriedAutoMove = false;
    }
  }

  /// 위치 이동 시도 (성공/실패 반환)
  Future<bool> tryMoveToLocation() async {
    try {
      debugPrint('📍 위치 이동 시도 시작...');
      
      await controller.moveToMyLocation().timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          debugPrint('⏰ 위치 이동 타임아웃');
          throw TimeoutException('위치 이동 타임아웃', const Duration(seconds: 8));
        },
      );
      
      debugPrint('✅ 위치 이동 성공');
      return true;
    } catch (e) {
      debugPrint('❌ 위치 이동 실패: $e');
      return false;
    }
  }

  /// 안전한 내 위치로 이동
  Future<void> moveToMyLocationSafely() async {
    if (_isRequestingLocation) {
      debugPrint('⚠️ 이미 위치 요청 중입니다.');
      return;
    }

    try {
      _isRequestingLocation = true;
      debugPrint('📍 수동 내 위치 이동 요청...');
      
      final locationManager = Provider.of<LocationManager>(context, listen: false);
      
      // LocationManager 초기화 대기
      if (!locationManager.isInitialized) {
        debugPrint('⏳ LocationManager 초기화 대기...');
        for (int i = 0; i < 10; i++) {
          await Future.delayed(const Duration(milliseconds: 300));
          if (locationManager.isInitialized) break;
        }
        
        if (!locationManager.isInitialized) {
          showLocationError('위치 서비스를 초기화할 수 없습니다.');
          return;
        }
      }

      // 권한 확인
      await locationManager.recheckPermissionStatus();
      
      if (locationManager.permissionStatus != loc.PermissionStatus.granted) {
        debugPrint('🔐 위치 권한 요청 중...');
        await locationManager.requestLocation();
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (locationManager.permissionStatus != loc.PermissionStatus.granted) {
          showLocationError('위치 권한이 필요합니다.');
          return;
        }
      }

      // 위치 요청
      if (!locationManager.hasValidLocation) {
        debugPrint('📍 새로운 위치 요청 중...');
        await locationManager.requestLocation();
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      // 위치 이동 시도 (최대 3회)
      bool moveSuccess = false;
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          debugPrint('🎯 내 위치 이동 시도 $attempt/3');
          
          await controller.moveToMyLocation().timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('이동 타임아웃', const Duration(seconds: 10)),
          );
          
          moveSuccess = true;
          debugPrint('✅ 내 위치 이동 성공 (시도 $attempt)');
          break;
        } catch (e) {
          debugPrint('❌ 이동 시도 $attempt 실패: $e');
          if (attempt < 3) {
            await Future.delayed(const Duration(milliseconds: 1000));
          }
        }
      }
      
      if (moveSuccess) {
        showLocationMoveSuccess();
      } else {
        showLocationError('위치로 이동할 수 없습니다. 네트워크를 확인해주세요.');
      }
      
    } catch (e) {
      debugPrint('❌ 내 위치 이동 전체 오류: $e');
      showLocationError('위치로 이동할 수 없습니다. 다시 시도해주세요.');
    } finally {
      _isRequestingLocation = false;
    }
  }

  /// 위치 이동 성공 메시지 표시
  void showLocationMoveSuccess() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.my_location, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(l10n.moved_to_my_location),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// 위치 에러 메시지 표시
  void showLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
