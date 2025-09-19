// lib/controllers/location_controllers.dart - 완전한 구현 - 실제 코드 기반
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/map_location_service.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:location/location.dart' as loc;
import '../services/location_service.dart';
import '../services/location_permission_manager.dart';

/// 위치 관련 UI 상태 관리 컨트롤러
class LocationController extends ChangeNotifier {
  final LocationService _locationService;
  final LocationPermissionManager _permissionManager;
  final MapLocationService _mapLocationService;

  // 🔥 Location 인스턴스 직접 생성
  final loc.Location _location = loc.Location();

  // 현재 상태
  bool _isRequesting = false;
  bool _hasValidLocation = false;
  bool _hasLocationPermissionError = false;
  bool _isLocationSearching = false; // 내 위치 찾기 중 상태
  loc.LocationData? _currentLocation;

  // 지도 관련
  NaverMapController? _mapController;

  // 🔥 마지막으로 업데이트된 위치 저장
  NLatLng? _lastUpdatedPosition;

  LocationController({
    LocationService? locationService,
    LocationPermissionManager? permissionManager,
    MapLocationService? mapLocationService,
  }) : _locationService = locationService ?? LocationService(),
       _permissionManager = permissionManager ?? LocationPermissionManager(),
       _mapLocationService = mapLocationService ?? MapLocationService() {
    _initialize();
  }

  // Getters
  bool get isRequesting => _isRequesting;
  bool get hasValidLocation => _hasValidLocation;
  bool get hasLocationPermissionError => _hasLocationPermissionError;
  bool get isLocationSearching => _isLocationSearching;
  loc.LocationData? get currentLocation => _currentLocation;
  loc.Location get location => _location;

  /// 초기화
  Future<void> _initialize() async {
    try {
      await _locationService.initialize();
      _permissionManager.addPermissionListener(_onPermissionChanged);
    } catch (e) {
      debugPrint('LocationController 초기화 실패: $e');
    }
  }

  /// 권한 상태 변경 콜백
  void _onPermissionChanged(PermissionResult result) {
    debugPrint('권한 상태 변경: $result');

    switch (result) {
      case PermissionResult.granted:
        _hasLocationPermissionError = false;
        break;
      case PermissionResult.denied:
      case PermissionResult.deniedForever:
      case PermissionResult.serviceDisabled:
        _hasLocationPermissionError = true;
        break;
      default:
        break;
    }
    notifyListeners();
  }

  /// 🔥 초고속 위치 요청 (MapScreen용) - iOS 최적화
  Future<void> requestCurrentLocationQuickly() async {
    if (_isRequesting) return;

    try {
      _isRequesting = true;
      _isLocationSearching = true;
      _hasLocationPermissionError = false;
      notifyListeners();

      // 🔥 빠른 권한 확인 (캐시 우선)
      final permissionResult = await _permissionManager.checkPermissionStatus(
        forceRefresh: false, // 캐시 사용
      );

      if (permissionResult != PermissionResult.granted) {
        // 빠른 권한 요청
        final requestResult = await _permissionManager.requestPermission();
        if (requestResult != PermissionResult.granted) {
          _hasLocationPermissionError = true;
          _isLocationSearching = false;
          notifyListeners();
          return;
        }
      }

      // 🔥 iOS 최적화: 더 긴 타임아웃과 재시도 로직
      final locationResult = await _locationService.getCurrentLocation(
        forceRefresh: true,
        timeout: const Duration(seconds: 3), // iOS에서 더 긴 시간 필요
      );

      if (locationResult.isSuccess && locationResult.hasValidLocation) {
        _currentLocation = locationResult.locationData;
        _hasValidLocation = true;
        _isLocationSearching = false;
        
        debugPrint('✅ 위치 획득 성공: ${locationResult.locationData!.latitude}, ${locationResult.locationData!.longitude}');

        await _mapLocationService.showMyLocation(
          locationResult.locationData!,
          shouldMoveCamera: true,
        );
      } else {
        // 내 위치를 찾지 못한 경우
        debugPrint('❌ 내 위치를 찾을 수 없습니다');
        _hasLocationPermissionError = true;
        _isLocationSearching = false;
      }
    } catch (e) {
      debugPrint('초고속 위치 요청 실패: $e');
      _hasLocationPermissionError = true;
      _isLocationSearching = false;
    } finally {
      _isRequesting = false;
      // 🔥 iOS 최적화: 상태 변경 후 즉시 UI 업데이트
      notifyListeners();
    }
  }

  /// 현재 위치 요청 (메인 API)
  Future<void> requestCurrentLocation({bool forceRefresh = false}) async {
    if (_isRequesting) return;

    try {
      _isRequesting = true;
      _isLocationSearching = true;
      _hasLocationPermissionError = false;
      notifyListeners();

      // 1. 권한 확인
      final permissionResult = await _permissionManager.checkPermissionStatus(
        forceRefresh: forceRefresh,
      );

      if (permissionResult != PermissionResult.granted) {
        // 권한 요청
        final requestResult = await _permissionManager.requestPermission();
        if (requestResult != PermissionResult.granted) {
          _hasLocationPermissionError = true;
          _isLocationSearching = false;
          notifyListeners();
          return;
        }
      }

      // 2. 위치 획득 (iOS 최적화: 더 긴 타임아웃)
      final locationResult = await _locationService.getCurrentLocation(
        forceRefresh: forceRefresh,
        timeout: const Duration(seconds: 4), // iOS에서 더 긴 시간 필요
      );

      if (locationResult.isSuccess && locationResult.hasValidLocation) {
        _currentLocation = locationResult.locationData;
        _hasValidLocation = true;
        _isLocationSearching = false;
        
        debugPrint('✅ 메인 위치 요청 성공: ${locationResult.locationData!.latitude}, ${locationResult.locationData!.longitude}');

        await _mapLocationService.showMyLocation(
          locationResult.locationData!,
          shouldMoveCamera: true,
        );
      } else {
        // 내 위치를 찾지 못한 경우
        debugPrint('❌ 내 위치를 찾을 수 없습니다');
        _hasLocationPermissionError = true;
        _isLocationSearching = false;
      }
    } catch (e) {
      debugPrint('위치 요청 실패: $e');
      _hasLocationPermissionError = true;
      _isLocationSearching = false;
    } finally {
      _isRequesting = false;
      // 🔥 iOS 최적화: 상태 변경 후 즉시 UI 업데이트
      notifyListeners();
    }
  }

  /// 내 위치로 이동
  Future<void> moveToMyLocation() async {
    if (_currentLocation != null) {
      await _mapLocationService.showMyLocation(
        _currentLocation!,
        shouldMoveCamera: true,
      );
    } else {
      await requestCurrentLocation();
    }
  }

  /// 위치 권한 재요청
  Future<void> retryLocationPermission() async {
    _permissionManager.invalidateCache();
    await requestCurrentLocation(forceRefresh: true);
  }

  /// 🔥 위치 업데이트 재시작 메서드 추가
  void resumeLocationUpdates() {
    debugPrint('📍 위치 업데이트 재시작');
    // 이미 요청 중이 아니면 위치 요청 재시작
    if (!_isRequesting) {
      requestCurrentLocation();
    }
  }

  /// 🔥 위치 업데이트 일시정지 메서드 추가
  void pauseLocationUpdates() {
    debugPrint('⏸️ 위치 업데이트 일시정지');
    // 현재 진행 중인 위치 요청을 중단하고 상태 정리
    _isRequesting = false;
    notifyListeners();
  }

  /// 🔥 지도 컨트롤러 설정
  void setMapController(NaverMapController mapController) {
    _mapController = mapController;
    _mapLocationService.setMapController(mapController);
    debugPrint('✅ LocationController에 지도 컨트롤러 설정 완료');
  }
  
  /// 🔥 컨텍스트 설정
  void setContext(BuildContext context) {
    _mapLocationService.setContext(context);
    debugPrint('✅ LocationController에 컨텍스트 설정 완료');
  }
  
  /// 지도 회전 각도 업데이트
  void updateMapRotation(double rotation) {
    _mapLocationService.updateMapRotation(rotation);
  }
  

  /// 🔥 사용자 위치 마커 업데이트 - 커스텀 마커 사용
  void updateUserLocationMarker(NLatLng position) async {
    if (_mapController == null) {
      debugPrint('⚠️ MapController가 null입니다');
      return;
    }

    // 🔥 위치 변경 감지 - 같은 위치면 업데이트하지 않음
    if (_lastUpdatedPosition != null &&
        _lastUpdatedPosition!.latitude == position.latitude &&
        _lastUpdatedPosition!.longitude == position.longitude) {
      return; // 위치가 변경되지 않았으면 업데이트하지 않음
    }

    try {
      // 🔥 로그 최적화 - 실제 업데이트 시에만 출력
      debugPrint(
        '📍 커스텀 위치 마커 업데이트: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
      );

      // 🔥 MapLocationService 사용 (커스텀 마커 포함)
      final locationData = loc.LocationData.fromMap({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': _currentLocation?.accuracy ?? 10.0,
      });

      await _mapLocationService.updateMyLocation(
        locationData,
        shouldMoveCamera: false, // 카메라는 이동하지 않음
      );

      // 🔥 성공 시 위치 저장
      _lastUpdatedPosition = position;
    } catch (e) {
      debugPrint('❌ 커스텀 위치 마커 업데이트 실패: $e');
    }
  }

  // 🔥 기존 마커 관련 메서드들은 CustomUserLocationMarker로 대체됨

  // 🔥 기존 오버레이 관련 메서드들은 CustomUserLocationMarker로 대체됨

  @override
  void dispose() {
    // 🔥 dispose 시에는 MapLocationService가 CustomUserLocationMarker를 정리함
    _permissionManager.removePermissionListener(_onPermissionChanged);
    _permissionManager.dispose();
    _locationService.dispose();
    _mapLocationService.dispose();
    super.dispose();
  }
}
