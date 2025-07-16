// lib/map/map_screen.dart - 길찾기 버튼 기능 추가
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/location_controllers.dart';
import 'package:flutter_application_1/friends/friends_screen.dart';
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
import 'package:location/location.dart' as loc;
import 'package:flutter_application_1/widgets/category_chips.dart';
import '../auth/user_auth.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  late MapScreenController _controller;
  late NavigationStateManager _navigationManager;
  late BuildingMarkerService _buildingMarkerService;
  
  final OverlayPortalController _infoWindowController = OverlayPortalController();
  int _currentNavIndex = 0;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _controller = MapScreenController();
    _navigationManager = NavigationStateManager();
    _buildingMarkerService = BuildingMarkerService();
    
    WidgetsBinding.instance.addObserver(this);
    _initializeController();
  }

  @override
  void dispose() {
    _navigationManager.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // context가 준비된 뒤 반드시 한 번만 호출
    _controller.setContext(context);
  }

  /// 간소화된 초기화 - 기존 자동 이동 로직 제거
  Future<void> _initializeController() async {
    if (_isInitializing) return;

    try {
      _isInitializing = true;
      debugPrint('🚀 MapScreen 초기화 시작...');

      // LocationController 생성 및 설정
      final locationController = LocationController();
      _controller.setLocationController(locationController);

      await _controller.initialize();
      debugPrint('✅ MapScreen 초기화 완료');
    } catch (e) {
      debugPrint('❌ MapScreen 초기화 오류: $e');
    } finally {
      _isInitializing = false;
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

  @override
  Widget build(BuildContext context) {
    // 1. userId를 Provider에서 받아오기
    final userId = context.read<UserAuth>().userId ?? '';
    print('userId: $userId'); 
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<MapScreenController>(
        builder: (context, controller, child) {
          return Scaffold(
            body: IndexedStack(
              index: _currentNavIndex,
              children: [
                _buildMapScreen(controller),
                // 2. userId를 ScheduleScreen에 전달
                ScheduleScreen(userId: userId),
                // 친구 바텀시트는 네비게이션에서 띄우니 여긴 텍스트만
                Container(
                  color: Colors.white,
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.friends_screen_bottom_sheet,
                    ),
                  ),
                ),
                const ProfileScreen(),
              ],
            ),
            bottomNavigationBar: _buildBottomNavigationBar(),
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

    return Stack(
      children: [
        MapView(
          onMapReady: (mapController) async {
            await _controller.onMapReady(mapController);
            debugPrint('🗺️ 지도 준비 완료!');
          },
          onTap: () => _controller.closeInfoWindow(_infoWindowController),
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
                selectedCategory: _controller.selectedCategory,
                onCategorySelected: (category, buildingNames) async {
                  debugPrint('카테고리 선택: $category, 건물 이름들: $buildingNames');
                  // 1. 기존 마커 모두 제거
                  await _buildingMarkerService.clearAllMarkers();
                  // 2. 선택 상태 및 정보창 정리
                  _controller.clearSelectedBuilding();
                  _controller.closeInfoWindow(_infoWindowController);
                  // 3. 새 카테고리 마커만 추가
                  _controller.selectCategoryByNames(category, buildingNames);
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
              child: Container(
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

  /// 하단 네비게이션 바
  Widget _buildBottomNavigationBar() {
    final l10n = AppLocalizations.of(context)!;
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
            children: [
              _buildNavItem(0, Icons.map_outlined, Icons.map, l10n.home),
              _buildNavItem(
                1,
                Icons.schedule_outlined,
                Icons.schedule,
                l10n.timetable,
              ),
              _buildFriendsNavItem(), // 친구 바텀시트 진입 버튼
              _buildNavItem(
                3,
                Icons.person_outline,
                Icons.person,
                l10n.my_page,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 친구 바텀시트 진입 버튼
  Widget _buildFriendsNavItem() {
    final myId = context.read<UserAuth>().userId ?? '';
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        if (myId.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('로그인 후 이용 가능합니다.')));
          return;
        }
        FriendsBottomSheet.show(context, myId);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.people_outline,
                size: 22,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.friends,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 일반 네비게이션 바 아이템
  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isActive = _currentNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentNavIndex = index),
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

  /// 위치 에러 처리 - 새로운 retryLocationPermission 사용
  Widget _buildLocationError() {
    final l10n = AppLocalizations.of(context)!;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 150,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.location_off, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.location_permission_denied,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // 설정 열기 버튼
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await AppSettings.openAppSettings();
                    },
                    icon: const Icon(Icons.settings, size: 16),
                    label: Text(l10n.open_settings),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 새로운 재시도 버튼 - MapController의 메서드 사용
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _controller.retryLocationPermission(),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(l10n.retry),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
            // FloorPlanDialog.show(context, building);
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