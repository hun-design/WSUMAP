import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/controllers/map_controller.dart';
import 'package:flutter_application_1/managers/location_manager.dart';
import 'package:flutter_application_1/auth/user_auth.dart';
import 'package:flutter_application_1/friends/friends_controller.dart';
import 'package:flutter_application_1/generated/app_localizations.dart';

class MapControls extends StatelessWidget {
  final MapScreenController controller;
  final VoidCallback? onMyLocationPressed;

  const MapControls({
    super.key,
    required this.controller,
    this.onMyLocationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocationManager, UserAuth>(
      builder: (context, locationManager, userAuth, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔥 친구 위치 제거 버튼 (친구 위치가 표시되어 있을 때만 보임)
            if (controller.displayedFriendCount > 0) ...[
              _buildFriendLocationRemoveButton(context),
              const SizedBox(height: 12),
            ],

            // 🔥 친구 모두 보기 버튼 (게스트 모드가 아닐 때만 표시)
            if (!userAuth.isGuest) ...[
              _buildShowAllFriendsButton(context),
              const SizedBox(height: 12),
            ],

            // 기존 카테고리/건물 마커 토글 버튼
            _buildCompactControlButton(
              onPressed: () async {
                HapticFeedback.lightImpact();
                // 카테고리가 선택되어 있으면 전체 건물만 보이도록 상태 전환
                if (controller.selectedCategory != null) {
                  // 카테고리 선택 해제(전체 건물만 표시)
                  await controller.clearCategorySelection();
                } else {
                  // 전체 건물 마커 토글 (숨김/표시)
                  await controller.toggleBuildingMarkers();
                }
              },
              icon: _getMainMarkerButtonIcon(),
              color: _getMainMarkerButtonColor(),
            ),
            const SizedBox(height: 12),

            // 기존 내 위치 버튼
            _buildMyLocationButton(locationManager),
          ],
        );
      },
    );
  }

  /// 🔥 친구 모두 보기 버튼
  Widget _buildShowAllFriendsButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          HapticFeedback.lightImpact();

          try {
            // Provider로 friendsController를 가져와서 인자로 넘김
            final friendsController = Provider.of<FriendsController>(context, listen: false);
            await controller.showAllFriendLocations(friendsController);
          } catch (e) {
            // 에러 메시지는 controller에서 처리됨
            debugPrint('친구 모두 보기 실패: $e');
          }
        },
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF10B981).withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.people,
              color: Color(0xFF10B981),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  /// 🔥 친구 위치 제거 버튼
  Widget _buildFriendLocationRemoveButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          HapticFeedback.lightImpact();

          // 친구 위치 마커 모두 제거
          await controller.clearFriendLocationMarkers();

          // 성공 메시지 표시
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.location_off, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.friendLocationRemovedFromMap,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFEF4444).withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Icons.person_off,
                  color: Color(0xFFEF4444),
                  size: 24,
                ),
              ),

              // 🔥 친구 개수 표시 배지 (2명 이상일 때)
              if (controller.displayedFriendCount > 1)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${controller.displayedFriendCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 전체 건물/카테고리 상태에 따라 아이콘 변경
  IconData _getMainMarkerButtonIcon() {
    if (controller.selectedCategory != null) {
      // 카테고리 선택 중이면 전체 건물로 돌아가는 느낌의 아이콘
      return Icons.layers; // 또는 Icons.list, 아이콘은 취향에 따라
    } else {
      // 전체 건물 표시/숨김 토글
      return controller.buildingMarkersVisible
          ? Icons.location_on
          : Icons.location_off;
    }
  }

  /// 전체 건물/카테고리 상태에 따라 색상 변경
  Color _getMainMarkerButtonColor() {
    if (controller.selectedCategory != null) {
      // 카테고리 선택 중이면 강조색
      return const Color(0xFF1E3A8A);
    } else {
      // 전체 건물 토글
      return controller.buildingMarkersVisible
          ? const Color(0xFF1E3A8A)
          : Colors.grey.shade500;
    }
  }

  Widget _buildMyLocationButton(LocationManager locationManager) {
    final bool isLoading = locationManager.isRequestingLocation;
    final bool hasLocation = locationManager.hasValidLocation;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading
            ? null
            : () {
                if (onMyLocationPressed != null) {
                  HapticFeedback.lightImpact();
                  onMyLocationPressed!();
                }
              },
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: hasLocation
                  ? const Color(0xFF1E3A8A).withOpacity(0.3)
                  : Colors.grey.shade200,
              width: hasLocation ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Color(0xFF1E3A8A),
                    strokeWidth: 2,
                  ),
                )
              : hasLocation
                  ? const Icon(
                      Icons.my_location,
                      color: Color(0xFF1E3A8A),
                      size: 24,
                    )
                  : Icon(
                      Icons.location_searching,
                      color: const Color(0xFF1E3A8A),
                      size: 24,
                    ),
        ),
      ),
    );
  }

  Widget _buildCompactControlButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }
}
