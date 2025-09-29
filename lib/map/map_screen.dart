// lib/map/map_screen.dart - 로그아웃/재로그인 마커 문제 해결 버전
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/location_controllers.dart';
import 'package:flutter_application_1/friends/friends_screen.dart';
import 'package:flutter_application_1/friends/friend.dart';
import 'package:flutter_application_1/friends/friends_controller.dart';
import 'package:flutter_application_1/friends/friend_repository.dart';
import 'package:flutter_application_1/friends/friend_api_service.dart';
import 'package:flutter_application_1/services/map/building_marker_service.dart';
import 'package:flutter_application_1/timetable/timetable_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/map/widgets/map_view.dart';
import 'package:flutter_application_1/map/widgets/building_info_window.dart';
import 'package:flutter_application_1/map/widgets/building_detail_sheet.dart';
import 'package:flutter_application_1/map/widgets/building_search_bar.dart';
import 'package:flutter_application_1/map/widgets/map_controls.dart';
import 'package:flutter_application_1/map/widgets/directions_screen.dart';
import 'package:flutter_application_1/controllers/map_controller.dart';
import 'package:flutter_application_1/profile/profile_screen.dart';
import 'package:flutter_application_1/map/navigation_state_manager.dart';
import '../generated/app_localizations.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_application_1/widgets/category_chips.dart';
import '../auth/user_auth.dart';
import 'package:flutter_application_1/managers/location_manager.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../tutorial/tutorial_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/map/building_data.dart';
import 'package:flutter_application_1/models/building.dart';
import 'package:flutter_application_1/inside/building_map_page.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  late MapScreenController _controller;
  late NavigationStateManager _navigationManager;
  late BuildingMarkerService _buildingMarkerService;
  late LocationController _locationController;
  late FriendsController _friendsController; // 🔥 FriendsController 추가
  

  final OverlayPortalController _infoWindowController =
      OverlayPortalController();
  int _currentNavIndex = 0;

  // 🔥 사용자 ID 추적용
  String? _lastUserId;

  // 🔥 시간표에서 전달받은 건물 정보 처리 플래그
  bool _hasProcessedTimetableBuilding = false;

  // 🔥 튜토리얼 관련 변수
  bool _hasShownTutorial = false;
  bool _isShowingTutorial = false; // 튜토리얼 표시 중인지 확인
  bool _isTutorialCheckInProgress = false; // 튜토리얼 확인 진행 중인지 확인

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    debugPrint('🗺️ MapScreen 초기화 시작');
    _initializeMapScreen();

    // 🔥 지도 진입 시 Welcome에서 받아온 위치가 있으면 즉시 표시 (개선된 버전)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationManager = context.read<LocationManager>();
      if (locationManager.hasValidLocation &&
          locationManager.currentLocation != null) {
        debugPrint('✅ Welcome에서 받아온 위치를 지도에 즉시 표시');
        _controller.updateUserLocationMarker(
          NLatLng(
            locationManager.currentLocation!.latitude!,
            locationManager.currentLocation!.longitude!,
          ),
        );
        
        // 🔥 즉시 내 위치로 이동 (지연 없이)
        Future.delayed(const Duration(milliseconds: 100), () {
          _controller.moveToMyLocation();
        });
      } else {
        // 🔥 위치가 없으면 즉시 빠른 위치 요청
        debugPrint('⚡ 위치가 없음 - 즉시 빠른 위치 요청');
        Future.delayed(const Duration(milliseconds: 200), () {
          _locationController.requestCurrentLocationQuickly();
        });
      }
    });
  }

  /// 🔥 맵 스크린 초기화 로직 (빠른 초기화로 사용자 경험 향상)
  Future<void> _initializeMapScreen() async {
    try {
      // UserAuth 상태 확인
      final userAuth = context.read<UserAuth>();
      debugPrint(
        '🔥 MapScreen 초기화 - 사용자 상태: ${userAuth.isLoggedIn ? '로그인' : '비로그인'}',
      );

      // 🔥 즉시 초기화로 속도 향상
      _controller = MapScreenController()..addListener(() => setState(() {}));
      _controller.resetForNewSession();

      _locationController = LocationController()
        ..addListener(() => setState(() {}));
      _controller.setLocationController(_locationController);

      debugPrint('🔥🔥🔥 MapScreen에서 FriendsController 생성 🔥🔥🔥');
      debugPrint('🔍 사용자 ID: ${userAuth.userId}');
      
      _friendsController = FriendsController(
        FriendRepository(FriendApiService()),
        userAuth.userId ?? '',
      );
      
      debugPrint('✅ MapScreen FriendsController 생성 완료');
      
      _friendsController.addListener(_onFriendsControllerChanged);

      _navigationManager = NavigationStateManager();
      _buildingMarkerService = BuildingMarkerService();

      // 🔥 지연 제거 - 즉시 초기화
      await _controller.initialize();
      _controller.setContext(context);

      // 🔥 초기화 완료 - UI 상태 업데이트
      if (mounted) {
        setState(() {});
      }

      debugPrint('✅ MapScreen 즉시 초기화 완료');
    } catch (e) {
      debugPrint('❌ MapScreen 초기화 오류: $e');
      // 오류 발생 시에도 UI 상태 업데이트하여 앱이 멈추지 않도록 함
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 🔥 UserAuth 상태 변경 감지 (한 번만 처리하도록 개선)
    final userAuth = context.read<UserAuth>(); // watch 대신 read 사용
    final currentUserId = userAuth.userId;

    // 🔥 사용자 변경 감지 시 FriendsController 재생성 (친구 목록 초기화)
    if (_lastUserId != null && _lastUserId != currentUserId && currentUserId != null) {
      debugPrint('🔄 사용자 변경 감지: $_lastUserId → $currentUserId');
      debugPrint('🔄 FriendsController 재생성 시작');
      
      // 기존 FriendsController 정리
      _friendsController.removeListener(_onFriendsControllerChanged);
      _friendsController.clearAllData(); // 즉시 데이터 초기화
      _friendsController.dispose();
      
      // 새로운 FriendsController 생성
      _friendsController = FriendsController(
        FriendRepository(FriendApiService()),
        currentUserId,
      );
      _friendsController.addListener(_onFriendsControllerChanged);
      
      debugPrint('✅ FriendsController 재생성 완료 - 새로운 사용자: $currentUserId');
    }

    // 🔥 새 사용자 로그인 감지 시에만 처리 (더 엄격한 조건)
    if (currentUserId != _lastUserId &&
        currentUserId != null &&
        userAuth.isLoggedIn &&
        !_hasShownTutorial &&
        !_isShowingTutorial &&
        !_isTutorialCheckInProgress) {
      debugPrint(
        '🔄 didChangeDependencies에서 새 사용자 감지: $_lastUserId -> $currentUserId',
      );
      _lastUserId = currentUserId;
      _hasProcessedTimetableBuilding = false; // 🔥 플래그 리셋
      _isShowingTutorial = false; // 🔥 표시 중 플래그 리셋
      _isTutorialCheckInProgress = false; // 🔥 확인 진행 중 플래그 리셋
      debugPrint('🔄 새 사용자 감지 - 플래그 리셋 (튜토리얼 표시 여부는 유지)');

      // 🔥 새 사용자일 때 튜토리얼 표시 (더 긴 지연으로 중복 방지)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted &&
            !_hasShownTutorial &&
            !_isShowingTutorial &&
            !_isTutorialCheckInProgress) {
          debugPrint('🔄 didChangeDependencies에서 튜토리얼 표시 시도');
          _showTutorialIfNeeded();
        } else {
          debugPrint('ℹ️ didChangeDependencies에서 튜토리얼 표시 시도 건너뜀 - 플래그 상태 확인');
        }
      });
    }

    // 🔥 시간표에서 전달받은 건물 정보 처리
    _handleBuildingInfoFromTimetable();
  }

  // 초기 튜토리얼 표시 로직은 didChangeDependencies에서만 처리합니다.

  // _reinitializeMapForNewUser는 현재 사용되지 않습니다.

  /// 🔥 친구 위치 표시 및 지도 화면 전환 메서드
  Future<void> _showFriendLocationAndSwitchToMap(Friend friend) async {
    try {
      debugPrint('📍 친구 위치 표시 및 지도 전환: ${friend.userName}');

      // 🔥 위치 공유 상태 확인
      if (!friend.isLocationPublic) {
        debugPrint('❌ 위치 공유가 허용되지 않은 친구: ${friend.userName}');

        // 1. 지도 화면으로 전환
        setState(() {
          _currentNavIndex = 0;
        });

        // 2. 위치 공유 미허용 메시지 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.location_off, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${friend.userName}님이 위치 공유를 허용하지 않았습니다.',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFFF9800),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // 1. 지도 화면으로 전환
      setState(() {
        _currentNavIndex = 0;
      });

      // 2. 잠시 후 친구 위치 표시 (지도 로딩 대기)
      await Future.delayed(const Duration(milliseconds: 500));

      // 3. 친구 위치 마커 표시
      await _controller.showFriendLocation(friend);

      // 4. 성공 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${friend.userName}님의 위치를 지도에 표시했습니다.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      debugPrint('✅ 친구 위치 표시 완료');
    } catch (e) {
      debugPrint('❌ 친구 위치 표시 실패: $e');

      // 에러 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '친구 위치를 표시할 수 없습니다.',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// 🔥 FriendsController 변경사항 감지하여 친구 위치 마커 관리
  void _onFriendsControllerChanged() {
    // 위치 공유가 비활성화된 친구들의 마커를 제거
    for (final friend in _friendsController.friends) {
      if (!friend.isLocationPublic && _controller.isFriendLocationDisplayed(friend.userId)) {
        debugPrint('🗑️ 위치 공유 비활성화된 친구 마커 제거: ${friend.userName}');
        _controller.removeFriendLocationDueToLocationShareDisabled(friend.userId);
      }
    }
  }

  @override
  void dispose() {
    _navigationManager.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _locationController.dispose();
    _friendsController.removeListener(_onFriendsControllerChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('🔄 앱 복귀 - 위치 서비스 재시작');
        _locationController.resumeLocationUpdates();
        break;
      case AppLifecycleState.paused:
        debugPrint('⏸️ 앱 일시정지 - 위치 서비스 중단');
        _locationController.pauseLocationUpdates();
        break;
      default:
        break;
    }
  }

  /// 길찾기 화면 열기
  void _openDirectionsScreen() async {
    if (_infoWindowController.isShowing) {
      _controller.closeInfoWindow(_infoWindowController);
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DirectionsScreen()),
    );
    if (result != null && result is Map<String, dynamic>) {
      print('길찾기 결과 받음: $result');
      _navigationManager.handleDirectionsResult(result, context);
    }
  }

  /// 🔥 시간표에서 전달받은 건물 정보 처리
  void _handleBuildingInfoFromTimetable() {
    // 🔥 이미 처리된 경우 스킵
    if (_hasProcessedTimetableBuilding) {
      return;
    }

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('showBuilding')) {
      final buildingName = args['showBuilding'] as String;
      final buildingInfo = args['buildingInfo'] as Map<String, dynamic>?;

      debugPrint('🏢 외부에서 건물 정보 받음: $buildingName');
      debugPrint('🏢 건물 상세 정보: $buildingInfo');

      // 🔥 처리 플래그 설정
      _hasProcessedTimetableBuilding = true;

      // 지도가 준비된 후 건물 정보 표시
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showBuildingFromTimetable(buildingName, buildingInfo);
      });

      // �� arguments 클리어 (다음 화면 전환 시 중복 처리 방지)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && ModalRoute.of(context) != null) {
          final route = ModalRoute.of(context)!;
          if (route.settings.arguments is Map<String, dynamic>) {
            final currentArgs =
                route.settings.arguments as Map<String, dynamic>;
            if (currentArgs.containsKey('showBuilding')) {
              // arguments에서 showBuilding 제거
              currentArgs.remove('showBuilding');
              currentArgs.remove('buildingInfo');
              debugPrint('🧹 외부 건물 정보 arguments 클리어 완료');
            }
          }
        }
      });
    }
  }

  /// 🔥 외부에서 전달받은 건물 정보로 건물 선택 및 정보창 표시
  Future<void> _showBuildingFromTimetable(
    String buildingName,
    Map<String, dynamic>? buildingInfo,
  ) async {
    try {
      debugPrint('🏢 시간표 건물 정보 표시 시작: $buildingName');

      // 1. 지도가 완전히 로드될 때까지 대기
      int retryCount = 0;
      while (!_controller.isMapReady && retryCount < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        retryCount++;
        debugPrint('🗺️ 지도 로딩 대기 중... ($retryCount/10)');
      }

      if (!_controller.isMapReady) {
        debugPrint('❌ 지도 로딩 시간 초과');
        return;
      }

      // 2. 건물 데이터에서 해당 건물 찾기
      final buildings = BuildingDataProvider.getBuildingData(context);
      debugPrint('🏢 전체 건물 수: ${buildings.length}');
      debugPrint('🏢 찾을 건물 이름: $buildingName');

      // 모든 건물 이름 출력 (디버깅용)
      for (int i = 0; i < buildings.length; i++) {
        debugPrint('🏢 건물 $i: ${buildings[i].name}');
      }

      // 건물 이름 매칭 로직
      Building? targetBuilding;

      // 1차: 정확한 이름 매칭
      try {
        targetBuilding = buildings.firstWhere(
          (building) =>
              building.name.toLowerCase() == buildingName.toLowerCase(),
        );
        debugPrint('✅ 정확한 이름 매칭 성공: ${targetBuilding.name}');
      } catch (e) {
        debugPrint('❌ 정확한 이름 매칭 실패: $e');
      }

      // 2차: 건물 코드 매칭 (W1, W2 등)
      if (targetBuilding == null) {
        try {
          final searchCode = _extractBuildingCode(buildingName);
          debugPrint('🏢 추출된 건물 코드: $searchCode');

          targetBuilding = buildings.firstWhere((building) {
            final buildingCode = _extractBuildingCode(building.name);
            return buildingCode.toLowerCase() == searchCode.toLowerCase();
          });
          debugPrint('✅ 건물 코드 매칭 성공: ${targetBuilding.name}');
        } catch (e) {
          debugPrint('❌ 건물 코드 매칭 실패: $e');
        }
      }

      // 3차: 부분 매칭 (포함 관계)
      if (targetBuilding == null) {
        try {
          targetBuilding = buildings.firstWhere((building) {
            final buildingNameLower = building.name.toLowerCase();
            final searchNameLower = buildingName.toLowerCase();

            return buildingNameLower.contains(searchNameLower) ||
                searchNameLower.contains(buildingNameLower);
          });
          debugPrint('✅ 부분 매칭 성공: ${targetBuilding.name}');
        } catch (e) {
          debugPrint('❌ 부분 매칭 실패: $e');
        }
      }

      // 4차: 첫 번째 건물 사용
      if (targetBuilding == null) {
        targetBuilding = buildings.first;
        debugPrint('⚠️ 기본 건물 사용: ${targetBuilding.name}');
      }

      debugPrint('🏢 최종 선택된 건물: ${targetBuilding.name}');

      // 3. 건물 선택
      _controller.selectBuilding(targetBuilding);

      // 4. 카테고리 자동 선택 로직 제거
      // if (buildingInfo != null && buildingInfo.containsKey('category')) {
      //   final category = buildingInfo['category'] as String?;
      //   if (category != null && category.isNotEmpty) {
      //     debugPrint('🎯 카테고리 자동 선택: $category');
      //     _selectCategoryAutomatically(category);
      //   }
      // }

      // 5. 잠시 후 정보창 표시 (지도 업데이트 대기)
      await Future.delayed(const Duration(milliseconds: 1500));

      // 6. 정보창 표시
      if (mounted) {
        if (!_infoWindowController.isShowing) {
          _infoWindowController.show();
          debugPrint('✅ 정보창 표시됨');
        } else {
          debugPrint('ℹ️ 정보창이 이미 표시 중');
        }
      }

      // 6. 성공 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    buildingInfo != null
                        ? '${buildingInfo['name']} ${buildingInfo['floorNumber']}층 ${buildingInfo['roomName']}호 위치를 표시했습니다.'
                        : '$buildingName 위치를 표시했습니다.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF8B5CF6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      debugPrint('✅ 시간표 건물 정보 표시 완료');
    } catch (e) {
      debugPrint('❌ 시간표 건물 정보 표시 실패: $e');
    }
  }

  /// 🔥 카테고리 자동 선택 메서드 제거
  // void _selectCategoryAutomatically(String category) {
  //   try {
  //     debugPrint('🎯 카테고리 자동 선택 시작: $category');
  //
  //     // 서버 카테고리명을 카테고리 ID로 변환
  //     final categoryId = _mapCategoryName(category);
  //     debugPrint('🎯 매핑된 카테고리: $category → $categoryId');
  //
  //     // CategoryChips 위젯에 카테고리 선택 이벤트 전달
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (mounted) {
  //         // CategoryChips 위젯의 selectCategory 메서드 호출
  //         final categoryChipsState = CategoryChips.globalKey.currentState;
  //         if (categoryChipsState != null) {
  //           debugPrint('🎯 CategoryChips 위젯 상태 찾음, 카테고리 선택 시도: $categoryId');
  //           categoryChipsState.selectCategory(categoryId);
  //           debugPrint('🎯 카테고리 자동 선택 완료: $categoryId');
  //         } else {
  //           debugPrint('❌ CategoryChips 위젯을 찾을 수 없음');
  //           debugPrint('❌ CategoryChips.globalKey: ${CategoryChips.globalKey}');
  //           debugPrint('❌ CategoryChips.globalKey.currentState: ${CategoryChips.globalKey.currentState}');
  //         }
  //       } else {
  //         debugPrint('❌ 위젯이 mounted 상태가 아님');
  //       }
  //     });
  //   } catch (e) {
  //     debugPrint('❌ 카테고리 자동 선택 실패: $e');
  //   }
  // }

  /// 카테고리명 매핑 메서드 제거
  // String _mapCategoryName(String serverCategory) {
  //   // 서버 카테고리명을 카테고리 ID로 매핑
  //   switch (serverCategory.toLowerCase()) {
  //     case 'lounge':
  //       return 'lounge';
  //     case 'cafe':
  //       return 'cafe';
  //     case 'restaurant':
  //       return 'restaurant';
  //     case 'convenience':
  //       return 'convenience';
  //     case 'vending':
  //       return 'vending';
  //     case 'atm':
  //       return 'atm';
  //     case 'bank':
  //       return 'atm'; // bank도 atm으로 매핑
  //     case 'library':
  //       return 'library';
  //     case 'fitness':
  //     case 'gym':
  //       return 'gym';
  //     case 'extinguisher':
  //     case 'fire_extinguisher':
  //       return 'extinguisher';
  //     case 'water':
  //     case 'water_purifier':
  //       return 'water';
  //     case 'bookstore':
  //       return 'bookstore';
  //     case 'post':
  //       return 'post';
  //     default:
  //       return serverCategory.toLowerCase(); // 매핑되지 않은 경우 소문자로 변환
  //   }
  // }

  /// �� 건물명에서 건물 코드 추출 헬퍼 메서드
  String _extractBuildingCode(String buildingName) {
    final regex = RegExp(r'\(([^)]+)\)');
    final match = regex.firstMatch(buildingName);
    if (match != null) {
      return match.group(1)!;
    }
    final spaceSplit = buildingName.trim().split(' ');
    if (spaceSplit.isNotEmpty &&
        RegExp(r'^[A-Za-z0-9\-]+$').hasMatch(spaceSplit[0])) {
      return spaceSplit[0];
    }
    return buildingName;
  }

  /// 🔥 현재 사용자 ID 가져오기
  String _getCurrentUserId() {
    final userAuth = context.read<UserAuth>();
    return userAuth.userId ?? 'unknown';
  }

  /// 🔥 튜토리얼 표시 메서드
  void _showTutorialIfNeeded() async {
    // 이미 표시했거나 화면이 마운트되지 않았거나 현재 표시 중이거나 확인 진행 중이면 표시하지 않음
    if (_hasShownTutorial ||
        !mounted ||
        _isShowingTutorial ||
        _isTutorialCheckInProgress) {
      debugPrint(
        'ℹ️ 튜토리얼 표시 건너뜀 - 이미 표시됨: $_hasShownTutorial, 마운트됨: $mounted, 표시중: $_isShowingTutorial, 확인중: $_isTutorialCheckInProgress',
      );
      return;
    }

    // 🔥 이번 세션에서 이미 튜토리얼을 표시했는지 확인
    final prefs = await SharedPreferences.getInstance();
    final sessionTutorialShown = prefs.getBool('session_tutorial_shown_${_getCurrentUserId()}') ?? false;
    if (sessionTutorialShown) {
      debugPrint('ℹ️ 이번 세션에서 이미 튜토리얼을 표시했음');
      _hasShownTutorial = true;
      return;
    }

    // 중복 호출 방지를 위한 추가 체크
    if (_isTutorialCheckInProgress) {
      debugPrint('ℹ️ 튜토리얼 확인이 이미 진행 중입니다.');
      return;
    }

    _isTutorialCheckInProgress = true; // 확인 진행 중 플래그 설정
    debugPrint('🔍 튜토리얼 확인 시작');

    final userAuth = context.read<UserAuth>();
    debugPrint(
      '🔍 현재 사용자: ${userAuth.userId}, 로그인 상태: ${userAuth.isLoggedIn}, 튜토리얼 설정: ${userAuth.isTutorial}',
    );
    debugPrint(
      '🔍 사용자 ID 타입: ${userAuth.userId.runtimeType}, 튜토리얼 설정 타입: ${userAuth.isTutorial.runtimeType}',
    );
      debugPrint(
        '🔍 튜토리얼 설정 상세: ${userAuth.isTutorial}',
      );

    // 로그인되지 않았으면 튜토리얼 표시하지 않음
    if (!userAuth.isLoggedIn) {
      debugPrint('ℹ️ 로그인되지 않음 - 튜토리얼 표시하지 않음');
      _isTutorialCheckInProgress = false;
      return;
    }

    bool shouldShowTutorial = false;

    if (!userAuth.userId!.startsWith('guest_')) {
      // 로그인된 사용자는 서버의 Is_Tutorial 설정에 따라
      shouldShowTutorial = userAuth.isTutorial;
      debugPrint(
        '🔍 로그인 사용자 튜토리얼 확인: $shouldShowTutorial (서버 설정: ${userAuth.isTutorial})',
      );
      debugPrint('🔍 shouldShowTutorial 타입: ${shouldShowTutorial.runtimeType}');
      debugPrint('🔍 shouldShowTutorial 상세: $shouldShowTutorial');

      // 서버 설정이 false면 튜토리얼 표시하지 않음
      if (!shouldShowTutorial) {
        debugPrint('ℹ️ 서버 설정에 따라 튜토리얼 표시하지 않음 (Is_Tutorial: false)');
        _hasShownTutorial = true; // 표시하지 않았지만 표시했다고 표시
        _isTutorialCheckInProgress = false;
        return;
      }
    } else {
      // 게스트는 로컬 설정을 확인
      try {
        final prefs = await SharedPreferences.getInstance();
        shouldShowTutorial =
            prefs.getBool('guest_tutorial_show') ?? true; // 기본값은 true
        debugPrint('🔍 게스트 튜토리얼 확인: $shouldShowTutorial');
      } catch (e) {
        debugPrint('❌ 게스트 튜토리얼 설정 확인 오류: $e');
        shouldShowTutorial = true; // 오류 시 기본적으로 표시
      }
    }

    if (shouldShowTutorial && mounted) {
      _hasShownTutorial = true;
      _isShowingTutorial = true; // 표시 중 플래그 설정
      _isTutorialCheckInProgress = false; // 확인 완료
      
      // 🔥 이번 세션에서 튜토리얼을 표시했다고 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('session_tutorial_shown_${_getCurrentUserId()}', true);
      
      debugPrint('✅ 튜토리얼 표시 시작');

      // 즉시 표시
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TutorialScreen()),
      ).then((_) {
        // 튜토리얼 화면이 닫힌 후 플래그 리셋
        _isShowingTutorial = false;
        debugPrint('✅ 튜토리얼 화면 닫힘');
      });
    } else {
      debugPrint('ℹ️ 튜토리얼 표시하지 않음 (설정에 따라)');
      _hasShownTutorial = true; // 이번 세션에서는 표시했다고 표시
      _isTutorialCheckInProgress = false; // 확인 완료
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 UserAuth 상태 변화를 감지 (watch 대신 read 사용으로 중복 호출 방지)
    final userAuth = context.read<UserAuth>();
    final userId = userAuth.userId ?? '';

    // 🔥 게스트로 전환됐는데 현재 인덱스가 1·2(시간표/친구)라면 0(지도)로 되돌림
    if (userAuth.isGuest && (_currentNavIndex == 1 || _currentNavIndex == 2)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currentNavIndex = 0);
      });
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _controller),
        ChangeNotifierProvider.value(value: _friendsController),
      ],
      child: Consumer<MapScreenController>(
        builder: (context, controller, child) {
          return Scaffold(
            body: IndexedStack(
              index: _currentNavIndex,
              children: [
                _buildMapScreen(controller),
                // 2. 🔥 ScheduleScreen 사용 (TimetableScreen 대신)
                ScheduleScreen(userId: userId),
                // 3. 🔥 친구 화면 래퍼 사용 - 콜백 함수 전달
                _FriendScreenWrapper(
                  userId: userId,
                  controller: _controller,
                  onShowFriendLocation: _showFriendLocationAndSwitchToMap,
                ),
                const ProfileScreen(),
              ],
            ),
            bottomNavigationBar: _buildBottomNavigationBar(userAuth),
            floatingActionButton: null,
          );
        },
      ),
    );
  }

  /// 지도 화면(실제 지도, 검색바, 카테고리, 컨트롤, 정보창 등)
  Widget _buildMapScreen(MapScreenController controller) {
    if (controller.selectedBuilding != null &&
        !_infoWindowController.isShowing &&
        mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_infoWindowController.isShowing) {
          _infoWindowController.show();
        }
      });
    }

    return Consumer<LocationManager>(
      builder: (context, locationManager, child) {
        if (locationManager.hasValidLocation) {
          controller.updateUserLocationMarker(
            NLatLng(
              locationManager.currentLocation!.latitude!,
              locationManager.currentLocation!.longitude!,
            ),
          );
        }
        return Stack(
          children: [
            MapView(
              onMapReady: (mapController) async {
                await _controller.onMapReady(mapController);
                debugPrint('🗺️ 지도 준비 완료!');
                
                // 🔥 지도 준비 완료 시 즉시 위치 확인 및 이동
                final locationManager = context.read<LocationManager>();
                if (locationManager.hasValidLocation &&
                    locationManager.currentLocation != null) {
                  debugPrint('⚡ 지도 준비 완료 - 즉시 내 위치로 이동');
                  await _controller.moveToMyLocation();
                } else {
                  debugPrint('⚡ 지도 준비 완료 - 빠른 위치 요청 후 이동');
                  // 빠른 위치 요청 후 이동 (iOS 최적화)
                  _locationController.requestCurrentLocationQuickly().then((_) {
                    if (_locationController.hasValidLocation) {
                      _controller.moveToMyLocation();
                    }
                  }).catchError((error) {
                    debugPrint('❌ 위치 요청 실패: $error');
                    // 에러 발생 시에도 검색 상태 리셋
                    if (mounted) {
                      setState(() {
                        // UI 상태 강제 업데이트
                      });
                    }
                    // 에러 타입별 처리
                    if (error.toString().contains('permission')) {
                      debugPrint('❌ 위치 권한 오류');
                    } else if (error.toString().contains('timeout')) {
                      debugPrint('❌ 위치 요청 타임아웃');
                    } else {
                      debugPrint('❌ 기타 위치 오류: $error');
                    }
                  });
                }
              },
              onTap: () => _controller.closeInfoWindow(_infoWindowController),
              onMapRotationChanged: (rotation) {
                // 지도 회전 각도를 LocationController에 전달
                _locationController.updateMapRotation(rotation);
              },
            ),
            if (_controller.isCategoryLoading) _buildCategoryLoadingIndicator(),
            // 검색바와 카테고리 칩들
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  BuildingSearchBar(
                    onBuildingSelected: (building) {
                      if (_controller.selectedCategory != null) {
                        _controller.clearCategorySelection();
                      }
                      _controller.selectBuilding(building);
                      if (mounted) _infoWindowController.show();
                    },
                    onSearchFocused: () =>
                        _controller.closeInfoWindow(_infoWindowController),
                    onDirectionsTap: () => _openDirectionsScreen(),
                  ),
                  const SizedBox(height: 12),
                  CategoryChips(
                    key: ValueKey('category_chips_${_controller.hashCode}'),
                    selectedCategory: _controller.selectedCategory,
                    onCategorySelected: (category, buildingInfoList) async {
                      debugPrint('🎯 === 카테고리 선택 콜백 시작 ===');
                      debugPrint(
                        '🎯 카테고리: "$category", 건물 정보 개수: ${buildingInfoList.length}',
                      );

                      if (category.isEmpty) {
                        // "건물" 버튼 클릭 또는 카테고리 해제
                        debugPrint('🎯 "건물" 버튼 클릭 - 모든 건물 마커 표시 시작');

                        // 1. 카테고리 마커 제거
                        await _controller.clearCategorySelection();

                        // 2. 건물 마커가 없다면 다시 로드
                        if (!_buildingMarkerService.hasMarkers) {
                          debugPrint('⚠️ 건물 마커가 없음 - 다시 로드 시작');
                          await _controller.loadDefaultMarkers();
                        } else {
                          debugPrint('✅ 건물 마커가 이미 존재함 - 가시성만 변경');
                        }

                        // 3. UI 상태 정리
                        _controller.clearSelectedBuilding();
                        _controller.closeInfoWindow(_infoWindowController);

                        debugPrint('✅ "건물" 버튼 처리 완료 - 모든 건물 마커 표시됨');
                      } else {
                        // 특정 카테고리 선택
                        debugPrint('🎯 카테고리 선택 처리 시작: $category');

                        // 1. UI 상태 정리
                        _controller.clearSelectedBuilding();
                        _controller.closeInfoWindow(_infoWindowController);

                        // 2. 카테고리 마커 표시 (기존 건물 마커는 자동으로 숨겨짐)
                        await _controller.selectCategoryByNames(
                          category,
                          buildingInfoList,
                          context,
                        );

                        debugPrint('✅ 카테고리 선택 처리 완료: $category');
                      }

                      debugPrint('🎯 === 카테고리 선택 콜백 끝 ===');
                    },
                  ),
                ],
              ),
            ),
            // 네비게이션 상태 카드
            if (_navigationManager.showNavigationStatus) ...[
              Positioned(
                left: 0,
                right: 0,
                bottom: 27,
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: _buildNavigationStatusCard(),
                  ),
                ),
              ),
            ],
            // 경로 계산, 위치 에러, 경로 초기화 버튼 등 기타 UI
            if (controller.isLoading &&
                controller.startBuilding != null &&
                controller.endBuilding != null)
              _buildRouteLoadingIndicator(),
            if (controller.hasLocationPermissionError) _buildLocationError(),
            if (_locationController.isLocationSearching && !_locationController.hasValidLocation) _buildLocationSearchingIndicator(),
            if (controller.hasActiveRoute &&
                !_navigationManager.showNavigationStatus)
              Positioned(
                left: 16,
                right: 100,
                bottom: 30,
                child: _buildClearNavigationButton(controller),
              ),
            // 우측 하단 컨트롤 버튼
            Positioned(
              right: 16,
              bottom: 27,
              child: MapControls(
                controller: controller,
                onMyLocationPressed: () => _controller.moveToMyLocation(),
              ),
            ),
            _buildBuildingInfoWindow(controller),
          ],
        );
      },
    );
  }

  /// 카테고리 로딩 인디케이터
  Widget _buildCategoryLoadingIndicator() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 170,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2196F3).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${_controller.selectedCategory} 위치를 검색 중...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 하단 네비게이션 바 - 게스트 여부에 따라 탭 표시
  Widget _buildBottomNavigationBar(UserAuth userAuth) {
    final l10n = AppLocalizations.of(context)!;

    // 🔥 표시할 탭 목록을 동적으로 구성
    final List<Widget> items = [
      _buildNavItem(0, Icons.map_outlined, Icons.map, l10n.home),
    ];

    // 🔥 게스트가 아니면 시간표와 친구 탭 추가
    if (!userAuth.isGuest) {
      items.addAll([
        _buildNavItem(
          1,
          Icons.schedule_outlined,
          Icons.schedule,
          l10n.timetable,
        ),
        _buildNavItem(2, Icons.people_outline, Icons.people, l10n.friends),
      ]);
    }

            items.add(
          _buildNavItem(3, Icons.person_outline, Icons.person, l10n.my_page),
        );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items,
          ),
        ),
      ),
    );
  }

  /// 🔥 일반 네비게이션 바 아이템 - 접근 제한 로직 제거
  Widget _buildNavItem(
    int screenIndex, // �� IndexedStack의 실제 화면 인덱스
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final bool isActive = _currentNavIndex == screenIndex;

    return GestureDetector(
      onTap: () {
        // 🔥 지도 화면으로 전환 시 친구 위치 마커 정리
        if (screenIndex == 0) {
          _controller.clearFriendLocationMarkers();
        }

        setState(() => _currentNavIndex = screenIndex);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF1E3A8A).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                size: 22,
                color: isActive ? const Color(0xFF1E3A8A) : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? const Color(0xFF1E3A8A) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 네비게이션 상태 카드 위젯
  Widget _buildNavigationStatusCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 예상 시간과 거리 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCompactInfoItem(
                Icons.straighten,
                '거리',
                _navigationManager.estimatedDistance.isNotEmpty
                    ? _navigationManager.estimatedDistance
                    : '계산중',
              ),
              Container(
                width: 1,
                height: 20,
                color: Colors.white.withOpacity(0.2),
              ),
              _buildCompactInfoItem(
                Icons.access_time,
                '시간',
                _navigationManager.estimatedTime.isNotEmpty
                    ? _navigationManager.estimatedTime
                    : '계산중',
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 길 안내 시작 버튼과 경로 초기화 버튼
          Row(
            children: [
              // 길 안내 시작 버튼 (50%)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _navigationManager.startActualNavigation(
                      _controller,
                      context,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 1,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.navigation, size: 12),
                      SizedBox(width: 3),
                      Text(
                        '길 안내',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // 경로 초기화 버튼 (50%)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _controller.clearNavigation();
                    _navigationManager.clearNavigation();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 1,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.clear, size: 12),
                      SizedBox(width: 3),
                      Text(
                        '초기화',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 컴팩트한 정보 아이템 위젯
  Widget _buildCompactInfoItem(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 14),
        const SizedBox(height: 1),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteLoadingIndicator() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Color(0xFF1E3A8A),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.calculating_route,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.finding_optimal_route,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClearNavigationButton(MapScreenController controller) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _controller.clearNavigation();
              _navigationManager.clearNavigation();
            },
            borderRadius: BorderRadius.circular(25),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.clear, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    l10n.clear_route,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 위치 에러 처리 - 개선된 안내 메시지
  Widget _buildLocationError() {

    return Positioned(
      top: MediaQuery.of(context).padding.top + 150,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_off,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '내 위치를 찾을 수 없습니다',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'GPS 신호가 약하거나 위치 권한이 필요합니다',
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await AppSettings.openAppSettings();
                    },
                    icon: const Icon(Icons.settings, size: 18),
                    label: const Text('설정 열기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _controller.retryLocationPermission(),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('다시 시도'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 내 위치 찾기 중 인디케이터
  Widget _buildLocationSearchingIndicator() {
    
    return Positioned(
      top: MediaQuery.of(context).padding.top + 150,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Color(0xFF3B82F6),
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '내 위치를 찾는 중...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'GPS 신호를 받고 있습니다',
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
          ],
        ),
      ),
    );
  }

  Widget _buildBuildingInfoWindow(MapScreenController controller) {
    return OverlayPortal(
      controller: _infoWindowController,
      overlayChildBuilder: (context) {
        if (controller.selectedBuilding == null) {
          return const SizedBox.shrink();
        }

        return BuildingInfoWindow(
          building: controller.selectedBuilding!,
          onClose: () => controller.closeInfoWindow(_infoWindowController),
          onShowDetails: (building) =>
              BuildingDetailSheet.show(context, building),
          onShowFloorPlan: (building) {
            // 내부도면 페이지로 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BuildingMapPage(buildingName: building.name),
              ),
            );
          },
          onSetStart: (result) {
            if (result is Map<String, dynamic>) {
              print('길찾기 결과 받음 (출발지): $result');
              _navigationManager.handleDirectionsResult(result, context);
            } else {
              print('잘못된 결과 타입: $result');
            }
          },
          onSetEnd: (result) {
            if (result is Map<String, dynamic>) {
              print('길찾기 결과 받음 (도착지): $result');
              _navigationManager.handleDirectionsResult(result, context);
            } else {
              print('잘못된 결과 타입: $result');
            }
          },
        );
      },
    );
  }
}

// 🔥 친구 화면 래퍼 클래스
class _FriendScreenWrapper extends StatelessWidget {
  final String userId;
  final MapScreenController controller;
  final Function(Friend) onShowFriendLocation;

  const _FriendScreenWrapper({
    required this.userId,
    required this.controller,
    required this.onShowFriendLocation,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: FriendsScreen(
        userId: userId,
        onShowFriendLocation: onShowFriendLocation,
      ),
    );
  }
}
