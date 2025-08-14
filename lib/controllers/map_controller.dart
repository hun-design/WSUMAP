// lib/controllers/map_controller.dart - 로그아웃 후 재로그인 마커 문제 해결 완전 버전
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/location_controllers.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter_application_1/services/map_service.dart';
import 'package:flutter_application_1/services/path_api_service.dart';
import 'package:flutter_application_1/models/building.dart';
import 'package:flutter_application_1/models/category_marker_data.dart';
import 'package:flutter_application_1/repositories/building_repository.dart';
import 'package:flutter_application_1/services/map/friend_location_marker_service.dart';
import 'package:flutter_application_1/friends/friend.dart';
import 'package:flutter_application_1/core/result.dart';
import 'package:flutter_application_1/friends/friends_controller.dart';
import 'package:flutter_application_1/data/category_fallback_data.dart';
import 'package:flutter_application_1/generated/app_localizations.dart';

class MapScreenController extends ChangeNotifier {
  MapService? _mapService;

  // 🔥 BuildingRepository 사용 - _allBuildings 제거
  final BuildingRepository _buildingRepository = BuildingRepository();

  // 🔥 추가: 현재 Context 저장
  BuildContext? _currentContext;

  // 🔥 마커 초기화 상태 추가
  bool _markersInitialized = false;

  // 🔥 지도 준비 상태 추가
  bool _isMapReady = false;

  // 🔥 친구 위치 마커 서비스 추가
  final FriendLocationMarkerService _friendLocationMarkerService =
      FriendLocationMarkerService();

  // 🏫 우송대학교 중심 좌표
  static const NLatLng _schoolCenter = NLatLng(36.3370, 127.4450);
  static const double _schoolZoomLevel = 15.5;

  // 선택된 건물
  Building? _selectedBuilding;

  // 경로 관련
  Building? _startBuilding;
  Building? _endBuilding;
  bool _isLoading = false;

  // 🔥 내 위치 관련 상태 완전 개선
  LocationController? _locationController;

  // 언어 변경 감지
  Locale? _currentLocale;

  // 🔥 추가된 getter들
  LocationController? get locationController => _locationController;
  NaverMapController? get mapController => _mapService?.getController();

  // 🔥 지도 준비 상태 getter 추가
  bool get isMapReady => _isMapReady;

  // 🔥 사용자 위치 마커 업데이트 메서드 추가
  void updateUserLocationMarker(NLatLng position) {
    _locationController?.updateUserLocationMarker(position);
  }

  // 경로 정보
  String? _routeDistance;
  String? _routeTime;

  // 현재 위치에서 길찾기 관련 속성
  Building? _targetBuilding;
  bool _isNavigatingFromCurrentLocation = false;

  // 오버레이 관리
  final List<NOverlay> _routeOverlays = [];

  // 카테고리 관련 상태
  String? _selectedCategory;
  bool _isCategoryLoading = false;
  String? _categoryError;

  // 실시간 친구 위치 추적용 상태
  String? trackedFriendId;

  /// 실시간으로 친구 위치 마커를 업데이트 (friendsController에서 호출)
  Future<void> updateTrackedFriendMarker(Friend friend) async {
    if (trackedFriendId == null || trackedFriendId != friend.userId) return;
    // 기존 마커가 있으면 위치만 이동, 없으면 새로 추가
    await _friendLocationMarkerService.addFriendLocationMarker(friend);
    notifyListeners();
  }

  // Getters
  Building? get selectedBuilding => _selectedBuilding;
  Building? get startBuilding => _startBuilding;
  Building? get endBuilding => _endBuilding;
  bool get isLoading => _isLoading;
  bool get buildingMarkersVisible =>
      _mapService?.buildingMarkersVisible ?? true;
  String? get routeDistance => _routeDistance;
  String? get routeTime => _routeTime;

  // 🔥 내 위치 관련 새로운 Getters
  bool get hasLocationPermissionError =>
      _locationController?.hasLocationPermissionError ?? false;
  bool get hasMyLocationMarker =>
      _locationController?.hasValidLocation ?? false;
  bool get isLocationRequesting => _locationController?.isRequesting ?? false;
  loc.LocationData? get myLocation => _locationController?.currentLocation;

  Building? get targetBuilding => _targetBuilding;
  bool get isNavigatingFromCurrentLocation => _isNavigatingFromCurrentLocation;
  bool get hasActiveRoute =>
      (_startBuilding != null && _endBuilding != null) ||
      _isNavigatingFromCurrentLocation;

  // 카테고리 관련 Getters
  String? get selectedCategory => _selectedCategory;
  bool get isCategoryLoading => _isCategoryLoading;
  String? get categoryError => _categoryError;

  /// 🔥 로그아웃/재로그인 시 완전한 재초기화 - 개선된 버전
  void resetForNewSession() {
    debugPrint('🔄 MapController 새 세션을 위한 완전 리셋');

    // 지도 및 마커 상태 리셋
    _markersInitialized = false;
    _isMapReady = false;

    // 선택된 상태들 클리어
    _selectedBuilding = null;
    _selectedCategory = null;
    _startBuilding = null;
    _endBuilding = null;
    _targetBuilding = null;

    // 로딩 상태들 리셋
    _isLoading = false;
    _isCategoryLoading = false;
    _isNavigatingFromCurrentLocation = false;

    // 에러 상태 클리어
    _categoryError = null;

    // 친구 위치 마커 정리
    clearFriendLocationMarkers();

    debugPrint('✅ MapController 새 세션 리셋 완료');
    notifyListeners();
  }

  /// 🚀 초기화 - 학교 중심으로 즉시 시작
  Future<void> initialize() async {
    try {
      debugPrint('🚀 MapController 초기화 시작 (학교 중심 방식)...');
      _isLoading = true;
      notifyListeners();

      // 서비스 초기화
      _mapService = MapService();

      // 🔥 친구 위치 마커 서비스 초기화
      await _friendLocationMarkerService.loadMarkerIcon();

      // 🔥 BuildingRepository 데이터 변경 리스너 등록
      _buildingRepository.addDataChangeListener(_onBuildingDataChanged);

      // 병렬 초기화 - 서버 연결 테스트 제거
      await Future.wait([_mapService!.loadMarkerIcons()], eagerError: false);

      debugPrint('✅ MapController 초기화 완료 (학교 중심)');
    } catch (e) {
      debugPrint('❌ MapController 초기화 오류: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔥 Context 설정 - 친구 위치 마커 서비스에도 Context 설정
  void setContext(BuildContext context) {
    _currentContext = context;
    _mapService?.setContext(context);

    // 🔥 친구 위치 마커 서비스에도 Context 설정
    _friendLocationMarkerService.setContext(context);

    debugPrint('✅ MapController에 Context 설정 완료');

    final currentLocale = Localizations.localeOf(context);
    if (_currentLocale != null && _currentLocale != currentLocale) {
      debugPrint(
        '언어 변경 감지: ${_currentLocale?.languageCode} -> ${currentLocale.languageCode}',
      );
      _onLocaleChanged(currentLocale);
    }
    _currentLocale = currentLocale;
  }

  void _onLocaleChanged(Locale newLocale) {
    debugPrint('언어 변경으로 인한 마커 재생성 시작');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _refreshBuildingMarkers();
      // 언어 변경 시 마커가 숨겨져 있으면 다시 보이게
      _showAllBuildingMarkers();
      // 내 위치도 다시 표시
      await moveToMyLocation();
    });
  }

  Future<void> _refreshBuildingMarkers() async {
    if (_mapService == null) return;

    try {
      debugPrint('언어 변경으로 인한 마커 재생성 시작');
      await _mapService!.addBuildingMarkers(_onBuildingMarkerTap);
      debugPrint('언어 변경으로 인한 마커 재생성 완료');
    } catch (e) {
      debugPrint('마커 재생성 오류: $e');
    }
  }

  /// 🔥 개선된 지도 준비 완료 처리 - 기본 마커 로드 추가
  Future<void> onMapReady(NaverMapController mapController) async {
    try {
      debugPrint('🗺️ 지도 준비 완료 - 새 세션 확인');

      // 기존 상태 확인 및 필요시 리셋
      if (_markersInitialized) {
        debugPrint('🔄 기존 마커 상태 감지 - 강제 리셋');
        resetForNewSession();
      }

      _mapService?.setController(mapController);
      _locationController?.setMapController(mapController);

      // 🔥 지도 준비 상태 설정
      _isMapReady = true;

      // 🔥 친구 위치 마커 서비스 설정 및 초기화
      _friendLocationMarkerService.setMapController(mapController);

      // 🔥 Context가 설정되어 있으면 친구 위치 마커 서비스에도 설정
      if (_currentContext != null) {
        _friendLocationMarkerService.setContext(_currentContext!);
      }

      // 마커 아이콘이 로딩되지 않았다면 다시 로딩
      try {
        await _friendLocationMarkerService.loadMarkerIcon();
        debugPrint('✅ 친구 위치 마커 아이콘 로딩 완료');
      } catch (e) {
        debugPrint('❌ 친구 위치 마커 아이콘 로딩 실패: $e');
      }

      await _moveToSchoolCenterImmediately();
      await _ensureBuildingMarkersAdded();

      // 🔥 지도 준비 완료 후 기본 마커들 로드
      await loadDefaultMarkers();

      debugPrint('✅ 지도 서비스 설정 완료');
    } catch (e) {
      debugPrint('❌ 지도 준비 오류: $e');
    }
  }

  /// 🔥 기본 마커들 로드 - 새 메서드 추가
  Future<void> loadDefaultMarkers() async {
    try {
      debugPrint('🔄 기본 마커 로드 시작');

      // 지도가 준비되지 않았으면 대기
      if (!_isMapReady || _mapService?.getController() == null) {
        debugPrint('⚠️ 지도가 준비되지 않아 기본 마커 로드 연기');
        return;
      }

      // BuildingRepository에서 기본 건물들 가져오기
      final allBuildings = _buildingRepository.allBuildings;

      if (allBuildings.isNotEmpty) {
        // MapService를 통해 건물 마커들 추가
        await _mapService?.addBuildingMarkers(_onBuildingMarkerTap);
        debugPrint('✅ 기본 마커 로드 완료: ${allBuildings.length}개');
      } else {
        debugPrint('⚠️ 로드할 기본 건물 데이터가 없음');
        // BuildingRepository 강제 새로고침 시도
        await _buildingRepository.getAllBuildings();
        if (_buildingRepository.allBuildings.isNotEmpty) {
          await _mapService?.addBuildingMarkers(_onBuildingMarkerTap);
          debugPrint(
            '✅ 새로고침 후 기본 마커 로드 완료: ${_buildingRepository.allBuildings.length}개',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ 기본 마커 로드 오류: $e');
    }
  }

  /// 🔥 친구 위치 표시 (개선된 버전)
  Future<void> showFriendLocation(Friend friend) async {
    try {
      debugPrint('=== 친구 위치 표시 시작 ===');
      debugPrint('친구 이름: ${friend.userName}');
      debugPrint('친구 ID: ${friend.userId}');
      debugPrint('원본 위치 데이터: "${friend.lastLocation}"');

      // 1. 기본 검증
      if (friend.lastLocation.isEmpty) {
        debugPrint('❌ 친구의 위치 정보가 없습니다');
        throw Exception('친구의 위치 정보가 없습니다');
      }

      // 2. 지도 컨트롤러 확인
      final mapController = _mapService?.getController();
      debugPrint('지도 컨트롤러 상태: ${mapController != null ? '설정됨' : '없음'}');

      if (mapController == null) {
        debugPrint('❌ 지도 컨트롤러가 설정되지 않음');
        throw Exception('지도가 아직 준비되지 않았습니다');
      }

      // 3. 마커 서비스 준비 확인
      debugPrint('친구 위치 마커 서비스 상태: 준비됨');

      // 4. 기존 친구 마커들 모두 제거
      debugPrint('기존 친구 마커들 제거 중...');
      await _friendLocationMarkerService.clearAllFriendLocationMarkers();

      // 5. 새로운 친구 마커 추가
      debugPrint('새로운 친구 마커 추가 중...');
      await _friendLocationMarkerService.addFriendLocationMarker(friend);

      debugPrint('✅ 친구 위치 마커 표시 완료: ${friend.userName}');
      debugPrint('=== 친구 위치 표시 완료 ===');

      // 6. UI 업데이트
      notifyListeners();
    } catch (e) {
      debugPrint('❌ 친구 위치 표시 실패: $e');
      debugPrint('=== 친구 위치 표시 실패 ===');

      // 사용자에게 알림
      if (_currentContext != null) {
        ScaffoldMessenger.of(_currentContext!).showSnackBar(
          SnackBar(
            content: Text('친구 위치를 표시할 수 없습니다: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      throw Exception('친구 위치를 표시할 수 없습니다: $e');
    }
  }

  /// 🔥 특정 친구 위치 마커 제거
  Future<void> removeFriendLocationMarker(String userId) async {
    await _friendLocationMarkerService.removeFriendLocationMarker(userId);
    notifyListeners();
  }

  /// 🔥 친구 위치 마커 표시 상태 확인
  bool isFriendLocationDisplayed(String userId) {
    return _friendLocationMarkerService.isFriendLocationDisplayed(userId);
  }

  /// 🔥 친구 위치 마커 모두 제거
  Future<void> clearFriendLocationMarkers() async {
    await _friendLocationMarkerService.clearAllFriendLocationMarkers();
    notifyListeners();
  }

  /// 🔥 특정 친구 위치로 카메라 이동
  Future<void> moveCameraToFriend(String userId) async {
    await _friendLocationMarkerService.moveCameraToFriend(userId);
  }

  /// 🔥 모든 친구 위치를 포함하는 영역으로 카메라 이동
  Future<void> moveCameraToAllFriends() async {
    await _friendLocationMarkerService.moveCameraToAllFriends();
  }

  /// 🔥 모든 친구 위치 표시
  Future<void> showAllFriendLocations(
    FriendsController friendsController,
  ) async {
    try {
      debugPrint('=== 모든 친구 위치 표시 시작 ===');

      // 1. 지도 컨트롤러 확인
      final mapController = _mapService?.getController();
      if (mapController == null) {
        debugPrint('❌ 지도 컨트롤러가 설정되지 않음');
        throw Exception('지도가 아직 준비되지 않았습니다');
      }

      // 3. 친구 데이터 강제 새로고침
      debugPrint('친구 데이터 새로고침 중...');
      await friendsController.loadAll();

      // 4. 친구 목록 확인
      debugPrint('친구 목록 확인: ${friendsController.friends.length}명');
      for (final friend in friendsController.friends) {
        debugPrint(
          '친구: ${friend.userName}, 온라인: ${friend.isLogin}, 위치: ${friend.lastLocation}',
        );
      }

      // 5. 기존 친구 마커들 모두 제거
      debugPrint('기존 친구 마커들 제거 중...');
      await _friendLocationMarkerService.clearAllFriendLocationMarkers();

      // 6. 모든 친구의 위치 마커 추가
      debugPrint('모든 친구 위치 마커 추가 중...');
      int addedCount = 0;
      int onlineCount = 0;
      int offlineCount = 0;
      int locationSharedCount = 0;
      List<String> offlineFriends = [];
      List<String> noLocationShareFriends = [];

      for (final friend in friendsController.friends) {
        if (friend.isLogin) {
          onlineCount++;
          if (friend.lastLocation.isNotEmpty) {
            // 🔥 위치 공유 상태 확인
            if (friend.isLocationPublic) {
              try {
                await _friendLocationMarkerService.addFriendLocationMarker(
                  friend,
                );
                addedCount++;
                debugPrint('✅ 친구 위치 마커 추가: ${friend.userName}');
              } catch (e) {
                debugPrint('⚠️ 친구 위치 마커 추가 실패: ${friend.userName} - $e');
              }
            } else {
              locationSharedCount++;
              noLocationShareFriends.add(friend.userName);
              debugPrint('⚠️ 위치 공유 미허용: ${friend.userName}');
            }
          } else {
            debugPrint('⚠️ 위치 정보 없음: ${friend.userName}');
          }
        } else {
          offlineCount++;
          offlineFriends.add(friend.userName);
          debugPrint('⚠️ 오프라인 친구: ${friend.userName}');
        }
      }

      debugPrint('✅ 모든 친구 위치 마커 표시 완료: $addedCount명');
      debugPrint('온라인: $onlineCount명, 오프라인: $offlineCount명');
      debugPrint('=== 모든 친구 위치 표시 완료 ===');

      // 7. UI 업데이트
      notifyListeners();

      // 8. 결과 메시지 표시
      if (_currentContext != null) {
        String message;
        Color backgroundColor;
        IconData icon;

        if (friendsController.friends.isEmpty) {
          // 친구가 없는 경우
          message = AppLocalizations.of(_currentContext!)!.no_friends_message;
          backgroundColor = const Color(0xFF6B7280); // 회색 (정보)
          icon = Icons.info;
        } else if (offlineCount > 0 || locationSharedCount > 0) {
          // 오프라인 친구나 위치 공유 미허용 친구가 있는 경우
          if (addedCount > 0) {
            // 위치를 표시할 수 있는 친구가 있는 경우
            String detailMessage = '';
            if (offlineCount > 0 && locationSharedCount > 0) {
              detailMessage = AppLocalizations.of(_currentContext!)!.both_offline_and_location_denied(offlineCount, locationSharedCount);
            } else if (offlineCount > 0) {
              detailMessage = AppLocalizations.of(_currentContext!)!.offline_friends_not_displayed(offlineCount);
            } else if (locationSharedCount > 0) {
              detailMessage = AppLocalizations.of(_currentContext!)!.location_denied_friends_not_displayed(locationSharedCount);
            }
            message = '친구 $addedCount명의 위치를 표시했습니다.$detailMessage';
            backgroundColor = const Color(0xFFF59E0B); // 주황색 (경고)
            icon = Icons.warning;
          } else {
            // 모든 친구가 오프라인이거나 위치 공유를 허용하지 않는 경우
            if (offlineCount > 0 && locationSharedCount > 0) {
              message = AppLocalizations.of(_currentContext!)!.all_friends_offline_or_location_denied;
            } else if (offlineCount > 0) {
              message = AppLocalizations.of(_currentContext!)!.all_friends_offline;
            } else {
              message = AppLocalizations.of(_currentContext!)!.all_friends_location_denied;
            }
            backgroundColor = const Color(0xFFEF4444); // 빨간색 (오류)
            icon = Icons.offline_bolt;
          }
        } else {
          // 모든 친구가 온라인이고 위치 공유를 허용하는 경우
          message = AppLocalizations.of(_currentContext!)!.friends_location_display_success(addedCount);
          backgroundColor = const Color(0xFF10B981); // 초록색 (성공)
          icon = Icons.people;
        }

        ScaffoldMessenger.of(_currentContext!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: backgroundColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 4),
          ),
        );

        // 오프라인 친구가 있는 경우 추가 다이얼로그 표시
        if (offlineCount > 0 && addedCount == 0) {
          // 모든 친구가 오프라인인 경우에만 다이얼로그 표시
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showOfflineFriendsDialog(offlineFriends, offlineCount);
          });
        }
      }
    } catch (e) {
      debugPrint('❌ 모든 친구 위치 표시 실패: $e');
      debugPrint('=== 모든 친구 위치 표시 실패 ===');

      // 사용자에게 알림
      if (_currentContext != null) {
        ScaffoldMessenger.of(_currentContext!).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(_currentContext!)!.friends_location_display_error(e.toString())}'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  /// 🔥 오프라인 친구 다이얼로그 표시
  void _showOfflineFriendsDialog(
    List<String> offlineFriends,
    int offlineCount,
  ) {
    if (_currentContext == null) return;

    showDialog(
      context: _currentContext!,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 헤더
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.offline_bolt,
                          color: Color(0xFFF59E0B),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.offline_friends_dialog_title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)!.offline_friends_dialog_subtitle(offlineCount),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 오프라인 친구 목록
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: offlineFriends.map((friendName) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_off,
                                color: Colors.grey[500],
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  friendName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.offline,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // 확인 버튼
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.confirm,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 🔥 FriendsController 가져오기 (Provider를 통해)
  // _getFriendsController 메서드는 더 이상 필요 없음

  /// 🔥 현재 표시된 친구 위치 마커 개수
  int get displayedFriendCount =>
      _friendLocationMarkerService.displayedFriendCount;

  /// 🔥 현재 표시된 친구 위치 마커 목록
  List<String> get displayedFriendIds =>
      _friendLocationMarkerService.getDisplayedFriendIds();

  /// 🔥 건물 마커 추가 보장 메서드
  Future<void> _ensureBuildingMarkersAdded() async {
    if (_markersInitialized) {
      debugPrint('✅ 건물 마커가 이미 초기화됨');
      return;
    }

    try {
      debugPrint('🏢 건물 마커 초기화 시작...');

      // BuildingRepository 로딩 상태 확인 및 대기
      await _waitForBuildingRepository();

      // MapService에 콜백 등록
      _mapService!.setCategorySelectedCallback(_handleServerDataUpdate);

      // 건물 마커 추가
      await _mapService!.addBuildingMarkers(_onBuildingMarkerTap);

      _markersInitialized = true;
      debugPrint('✅ 건물 마커 초기화 완료');

      notifyListeners(); // UI 업데이트
    } catch (e) {
      debugPrint('❌ 건물 마커 초기화 오류: $e');
      // 실패 시 재시도
      _retryBuildingMarkersWithDelay();
    }
  }

  /// 🔥 BuildingRepository 로딩 대기
  Future<void> _waitForBuildingRepository() async {
    int retryCount = 0;
    const maxRetries = 10;
    const retryDelay = Duration(milliseconds: 500);

    while (!_buildingRepository.isLoaded && retryCount < maxRetries) {
      debugPrint(
        '⏳ BuildingRepository 로딩 대기 중... (시도: ${retryCount + 1}/$maxRetries)',
      );

      // 강제로 건물 데이터 로딩 시도
      await _buildingRepository.getAllBuildings();

      if (_buildingRepository.isLoaded &&
          _buildingRepository.allBuildings.isNotEmpty) {
        debugPrint(
          '✅ BuildingRepository 로딩 완료: ${_buildingRepository.allBuildings.length}개 건물',
        );
        break;
      }

      await Future.delayed(retryDelay);
      retryCount++;
    }

    if (!_buildingRepository.isLoaded) {
      debugPrint('❌ BuildingRepository 로딩 실패 - 최대 재시도 횟수 초과');
      throw Exception('BuildingRepository 로딩 실패');
    }
  }

  /// 🔥 지연 후 재시도
  void _retryBuildingMarkersWithDelay() {
    Future.delayed(const Duration(seconds: 2), () async {
      if (!_markersInitialized && _mapService != null) {
        debugPrint('🔄 건물 마커 재시도 중...');
        await _ensureBuildingMarkersAdded();
      }
    });
  }

  /// 🔥 수동 마커 새로고침 메서드 (UI에서 호출 가능)
  Future<void> refreshBuildingMarkers() async {
    debugPrint('🔄 건물 마커 수동 새로고침 시작');
    _markersInitialized = false;
    await _ensureBuildingMarkersAdded();
  }

  /// 🔥 강제 마커 재초기화 메서드
  Future<void> forceReinitializeMarkers() async {
    debugPrint('🔄 마커 강제 재초기화 시작');

    // 기존 마커들 완전 제거
    await _mapService?.clearBuildingMarkers();

    // 상태 리셋
    _markersInitialized = false;
    _isMapReady = false;

    // BuildingRepository 강제 새로고침
    await _buildingRepository.forceRefresh();

    // 마커 재추가
    await _ensureBuildingMarkersAdded();

    debugPrint('✅ 마커 강제 재초기화 완료');
  }

  void setLocationController(LocationController locationController) {
    _locationController = locationController;
    _locationController!.addListener(_onLocationUpdate);
    debugPrint('✅ LocationController 설정 완료');
  }

  /// 내 위치로 이동 (단순화됨)
  Future<void> moveToMyLocation() async {
    await _locationController?.moveToMyLocation();
  }

  /// 위치 권한 재요청 (단순화됨)
  Future<void> retryLocationPermission() async {
    await _locationController?.retryLocationPermission();
  }

  /// 🏫 즉시 학교 중심으로 이동
  Future<void> _moveToSchoolCenterImmediately() async {
    try {
      debugPrint('🏫 즉시 학교 중심으로 이동');
      await _mapService?.moveCamera(_schoolCenter, zoom: _schoolZoomLevel);
      debugPrint('✅ 학교 중심 이동 완료');
    } catch (e) {
      debugPrint('❌ 학교 중심 이동 실패: $e');
    }
  }

  /// 🔥 건물 이름 목록으로 카테고리 아이콘 마커 표시 - BuildingRepository 사용
  Future<void> selectCategoryByNames(
    String category,
    List<Map<String, dynamic>> buildingInfoList,
    BuildContext context,
  ) async {
    debugPrint('=== 카테고리 선택 요청: $category ===');
    debugPrint('🔍 받은 건물 정보들: $buildingInfoList');

    if (category.isEmpty) {
      debugPrint('⚠️ 카테고리가 비어있음 - 해제 처리');
      await clearCategorySelection();
      return;
    }

    if (_selectedCategory == category) {
      debugPrint('같은 카테고리 재선택 → 유지');
      return;
    }

    if (_selectedCategory != null) {
      debugPrint('이전 카테고리($_selectedCategory) 정리');
      await _clearCategoryMarkers();
    }

    _selectedCategory = category;
    _isCategoryLoading = true;
    notifyListeners();

    _mapService?.saveLastCategorySelection(
      category,
      buildingInfoList.map((e) => e['Building_Name'] as String).toList(),
    );

    try {
      debugPrint('기존 건물 마커들 숨기기...');
      await _hideAllBuildingMarkers(); // 반드시 빌딩 마커 숨기기

      debugPrint('카테고리 아이콘 마커들 표시...');
      await _showCategoryIconMarkers(buildingInfoList, category, context);

      debugPrint('✅ 카테고리 선택 완료: $category');
    } catch (e) {
      debugPrint('🚨 카테고리 선택 오류: $e');
      await clearCategorySelection();
    } finally {
      _isCategoryLoading = false;
      notifyListeners();
    }
  }

  /// 🔥 카테고리 아이콘 마커들 표시 - BuildingRepository 사용
  Future<void> _showCategoryIconMarkers(
    List<Map<String, dynamic>> buildingInfoList,
    String category,
    BuildContext context,
  ) async {
    debugPrint('🔍 === 카테고리 매칭 디버깅 시작 ===');
    debugPrint('🔍 선택된 카테고리: $category');
    debugPrint('🔍 API에서 받은 건물 정보들: $buildingInfoList');

    final allBuildings = _buildingRepository.allBuildings;
    debugPrint('🔍 전체 건물 데이터 개수: ${allBuildings.length}');

    if (!_buildingRepository.isLoaded || allBuildings.length <= 1) {
      debugPrint('⏳ BuildingRepository 데이터 대기 중... 잠시 후 재시도');
      await Future.delayed(const Duration(seconds: 1));
      if (_selectedCategory == category) {
        await _buildingRepository.getAllBuildings();
        if (_buildingRepository.isLoaded &&
            _buildingRepository.allBuildings.length > 1) {
          await _showCategoryIconMarkers(buildingInfoList, category, context);
        }
      }
      return;
    }

    debugPrint('🔍 카테고리 아이콘 마커 표시 시작: ${buildingInfoList.length}개');

    final categoryMarkerLocations = <CategoryMarkerData>[];

    for (final info in buildingInfoList) {
      final buildingName = info['Building_Name'] as String? ?? '';
      final floors = (info['Floor_Numbers'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();
      debugPrint('🔍 건물 검색 중: "$buildingName" (floors: $floors)');
      final building = _findBuildingByName(buildingName, allBuildings);
      if (building != null) {
        debugPrint('✅ 마커 floors 전달: $floors');
        categoryMarkerLocations.add(
          CategoryMarkerData(
            buildingName: building.name,
            lat: building.lat,
            lng: building.lng,
            category: category,
            icon: _getCategoryIcon(category),
            floors: floors,
            categoryFloors: floors, // 🔥 카테고리가 존재하는 층 정보 전달
          ),
        );
        debugPrint(
          '✅ 카테고리 마커 추가: ${building.name} - $category 아이콘, floors: $floors',
        );
      }
    }

    debugPrint('🔍 === 매칭 결과 ===');
    debugPrint(
      '🔍 총 매칭된 건물 수: ${categoryMarkerLocations.length}/${buildingInfoList.length}',
    );

    if (categoryMarkerLocations.isEmpty) {
      debugPrint('❌ 매칭되는 건물이 없습니다 - 카테고리 해제');
      await clearCategorySelection();
      return;
    }

    debugPrint('📍 카테고리 마커 표시 시작...');
    await _mapService?.showCategoryIconMarkers(
      categoryMarkerLocations,
      context,
    );

    debugPrint('✅ 카테고리 아이콘 마커 표시 완료: ${categoryMarkerLocations.length}개');
    debugPrint('🔍 === 카테고리 매칭 디버깅 끝 ===');
  }

  /// 🔥 향상된 건물 찾기 메서드 - BuildingRepository 사용
  Building? _findBuildingByName(
    String buildingName,
    List<Building> allBuildings,
  ) {
    try {
      // 1. 정확한 매칭 시도
      return allBuildings.firstWhere(
        (b) => b.name.trim().toUpperCase() == buildingName.trim().toUpperCase(),
      );
    } catch (e) {
      try {
        // 2. 부분 매칭 시도
        return allBuildings.firstWhere(
          (b) => b.name.contains(buildingName) || buildingName.contains(b.name),
        );
      } catch (e2) {
        try {
          // 3. 건물 코드 매칭 시도 (W1, W2 등)
          return allBuildings.firstWhere(
            (b) => b.name.toLowerCase().contains(buildingName.toLowerCase()),
          );
        } catch (e3) {
          debugPrint('❌ 매칭 실패: "$buildingName"');
          return null;
        }
      }
    }
  }

  /// 🔥 BuildingRepository 데이터 변경 리스너
  void _onBuildingDataChanged(List<Building> buildings) {
    debugPrint('🔄 BuildingRepository 데이터 변경 감지: ${buildings.length}개');

    // 현재 선택된 카테고리가 있으면 재매칭
    if (_selectedCategory != null) {
      debugPrint('🔁 데이터 변경 후 카테고리 재매칭: $_selectedCategory');

      // 저장된 건물 이름들로 재매칭 시도
      final savedBuildingNames =
          _mapService
              ?.getAllBuildings()
              .where(
                (b) =>
                    b.category.toLowerCase() ==
                    _selectedCategory!.toLowerCase(),
              )
              .map((b) => b.name)
              .toList() ??
          [];

      if (savedBuildingNames.isNotEmpty) {
        final infoList = savedBuildingNames
            .map((name) => {'Building_Name': name, 'Floor_Numbers': <String>[]})
            .toList();
        Future.microtask(
          () => _showCategoryIconMarkers(
            infoList,
            _selectedCategory!,
            _currentContext!,
          ),
        );
      }
    }
  }

  /// 카테고리 아이콘 반환 - CategoryFallbackData 사용
  IconData _getCategoryIcon(String category) {
    debugPrint('==== [카테고리 아이콘 함수 진입] 넘어온 category: "$category"');

    // 한국어 카테고리 이름을 영어 ID로 변환
    String categoryId = _convertToEnglishId(category);
    debugPrint('==== 변환된 categoryId: "$categoryId"');

    // CategoryFallbackData에서 아이콘 가져오기
    final iconData = CategoryFallbackData.getCategoryIcon(categoryId);
    debugPrint('==== 반환된 아이콘: $iconData');

    return iconData;
  }

  /// 한국어 카테고리 이름을 영어 ID로 변환
  String _convertToEnglishId(String koreanCategory) {
    switch (koreanCategory) {
      case '카페':
        return 'cafe';
      case '식당':
        return 'restaurant';
      case '편의점':
        return 'convenience';
      case '자판기':
        return 'vending';
      case '화장실':
        return 'wc';
      case '프린터':
        return 'printer';
      case '복사기':
        return 'copier';
      case 'ATM':
      case '은행(atm)':
        return 'atm';
      case '의료':
      case '보건소':
        return 'medical';
      case '도서관':
        return 'library';
      case '체육관':
      case '헬스장':
        return 'fitness';
      case '주차장':
        return 'parking';
      case '라운지':
        return 'lounge';
      case '소화기':
        return 'extinguisher';
      case '정수기':
        return 'water';
      case '서점':
        return 'bookstore';
      case '우체국':
      case 'post_office':
        return 'post';
      default:
        return koreanCategory.toLowerCase();
    }
  }

  /// 🔥 카테고리 마커들 제거
  Future<void> _clearCategoryMarkers() async {
    debugPrint('카테고리 마커들 제거 중...');
    await _mapService?.clearCategoryMarkers();
  }

  /// 🔥 카테고리 선택 해제 (기존 건물 마커들 다시 표시)
  Future<void> clearCategorySelection() async {
    debugPrint('=== 카테고리 선택 해제 ===');
    if (_selectedCategory != null) {
      debugPrint('선택 해제할 카테고리: $_selectedCategory');
      await _clearCategoryMarkers();
    }
    _selectedCategory = null;
    _isCategoryLoading = false;

    debugPrint('모든 건물 마커 다시 표시 시작...');

    // 1. 건물 마커 다시 표시
    await _showAllBuildingMarkers();

    debugPrint('✅ 카테고리 선택 해제 완료');
    notifyListeners(); // UI 업데이트를 위해 다시 추가
  }

  /// 🔥 모든 건물 마커 다시 표시
  Future<void> _showAllBuildingMarkers() async {
    await _mapService?.showAllBuildingMarkers();
  }

  /// 🔥 모든 건물 마커 숨기기
  Future<void> _hideAllBuildingMarkers() async {
    await _mapService?.clearAllBuildingMarkers();
  }

  /// 위치 업데이트 리스너 (단순화됨)
  void _onLocationUpdate() {
    notifyListeners();
  }

  /// 🔥 서버 데이터 도착 시 카테고리 재매칭
  void _handleServerDataUpdate(String category, List<String> buildingNames) {
    debugPrint('🔄 서버 데이터 도착 - 카테고리 재매칭 중...');

    // 🔥 현재 선택된 카테고리가 있으면 재매칭
    if (_selectedCategory != null && _selectedCategory == category) {
      debugPrint('🔁 서버 데이터 도착 후 카테고리 재매칭: $_selectedCategory');
      final infoList = buildingNames
          .map((name) => {'Building_Name': name, 'Floor_Numbers': <String>[]})
          .toList();
      _showCategoryIconMarkers(infoList, category, _currentContext!);
    }
  }

  void _onBuildingMarkerTap(NMarker marker, Building building) async {
    await _mapService?.highlightBuildingMarker(marker);
    _selectedBuilding = building;
    notifyListeners();

    // 선택된 마커로 부드럽게 이동
    await _mapService?.moveCamera(marker.position, zoom: 17);
  }

  void selectBuilding(Building building) async {
    _selectedBuilding = building;
    notifyListeners();

    // 🔥 해당 건물의 마커를 찾아서 하이라이트
    try {
      final marker = _mapService?.findMarkerForBuilding(building);
      if (marker != null) {
        await _mapService?.highlightBuildingMarker(marker);
        debugPrint('✅ 건물 마커 하이라이트 완료: ${building.name}');
      } else {
        debugPrint('⚠️ 건물 마커를 찾을 수 없음: ${building.name}');
      }
    } catch (e) {
      debugPrint('❌ 건물 마커 하이라이트 실패: $e');
    }
  }

  void clearSelectedBuilding() {
    if (_selectedBuilding != null) {
      _mapService?.resetAllBuildingMarkers();
      _selectedBuilding = null;
      notifyListeners();
    }
  }

  void closeInfoWindow(OverlayPortalController controller) {
    if (controller.isShowing) {
      controller.hide();
    }
    clearSelectedBuilding();
    debugPrint('🚪 InfoWindow 닫기 완료');
  }

  Future<void> navigateFromCurrentLocation(Building targetBuilding) async {
    if (_locationController == null ||
        _locationController!.currentLocation == null) {
      debugPrint('내 위치 정보가 없습니다.');
      return;
    }

    try {
      _setLoading(true);

      final myLoc = _locationController!.currentLocation!;
      final myLatLng = NLatLng(myLoc.latitude!, myLoc.longitude!);

      final pathCoordinates = await PathApiService.getRouteFromLocation(
        myLatLng,
        targetBuilding,
      );

      if (pathCoordinates.isNotEmpty) {
        await _mapService?.drawPath(pathCoordinates);
        await _mapService?.moveCameraToPath(pathCoordinates);
      }
    } catch (e) {
      debugPrint('내 위치 경로 계산 실패: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void setStartBuilding(Building building) {
    _startBuilding = building;
    _isNavigatingFromCurrentLocation = false;
    _targetBuilding = null;
    notifyListeners();
  }

  void setEndBuilding(Building building) {
    _endBuilding = building;
    _isNavigatingFromCurrentLocation = false;
    _targetBuilding = null;
    notifyListeners();
  }

  Future<void> calculateRoute() async {
    if (_startBuilding == null || _endBuilding == null) return;

    try {
      _setLoading(true);
      final pathCoordinates = await PathApiService.getRoute(
        _startBuilding!,
        _endBuilding!,
      );

      if (pathCoordinates.isNotEmpty) {
        await _mapService?.drawPath(pathCoordinates);
        await _mapService?.moveCameraToPath(pathCoordinates);
      }
    } catch (e) {
      debugPrint('경로 계산 실패: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> clearNavigation() async {
    try {
      debugPrint('모든 경로 관련 오버레이 제거 시작');

      await _clearAllOverlays();
      await _mapService?.clearPath();

      _startBuilding = null;
      _endBuilding = null;
      _targetBuilding = null;
      _isNavigatingFromCurrentLocation = false;
      _routeDistance = null;
      _routeTime = null;

      debugPrint('모든 경로 관련 오버레이 제거 완료');
      notifyListeners();
    } catch (e) {
      debugPrint('경로 초기화 오류: $e');
    }
  }

  Future<void> _clearAllOverlays() async {
    try {
      final controller = await _mapService?.getControllerAsync();
      if (controller == null) return;

      if (_routeOverlays.isNotEmpty) {
        for (final overlay in List.from(_routeOverlays)) {
          try {
            controller.deleteOverlay(overlay.info);
            await Future.delayed(const Duration(milliseconds: 50));
          } catch (e) {
            debugPrint('개별 오버레이 제거 오류: $e');
          }
        }
        _routeOverlays.clear();
      }

      debugPrint('모든 오버레이 제거 완료');
    } catch (e) {
      debugPrint('오버레이 제거 중 오류: $e');
    }
  }

  void clearLocationError() {
    notifyListeners();
  }

  Future<void> toggleBuildingMarkers() async {
    try {
      await _mapService?.toggleBuildingMarkers();
      notifyListeners();
    } catch (e) {
      debugPrint('건물 마커 토글 오류: $e');
    }
  }

  Result<List<Building>> searchBuildings(String query) {
    return _buildingRepository.searchBuildings(query);
  }

  void searchByCategory(String category) {
    final result = _buildingRepository.getBuildingsByCategory(category);
    final buildings = result.isSuccess ? result.data! : [];

    debugPrint('카테고리 검색: $category, 결과: ${buildings.length}개');

    if (buildings.isNotEmpty) {
      selectBuilding(buildings.first);
      final location = NLatLng(buildings.first.lat, buildings.first.lng);
      _mapService?.moveCamera(location, zoom: 16);
    }
  }

  /// 🔥 로딩 상태 설정 메서드
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    clearCategorySelection();
    _locationController?.removeListener(_onLocationUpdate);
    _buildingRepository.removeDataChangeListener(_onBuildingDataChanged);
    _buildingRepository.dispose();
    _mapService?.dispose();

    // 🔥 친구 위치 마커 서비스 정리
    _friendLocationMarkerService.dispose();

    super.dispose();
  }
}
