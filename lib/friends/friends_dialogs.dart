import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/friends/friend.dart';
import 'package:flutter_application_1/friends/friends_controller.dart';
import 'package:flutter_application_1/friends/friends_utils.dart';
import 'package:flutter_application_1/generated/app_localizations.dart';
import 'package:flutter_application_1/controllers/map_controller.dart';

/// 다이얼로그 관련 위젯들
class FriendsDialogs {
  /// 친구 상세 정보 다이얼로그 - 위치 제거 버튼 추가 및 오프라인 처리, 모달창 닫기 통일
  static Future<void> showFriendDetailsDialog(
    BuildContext context,
    Friend friend,
    Function(Friend)? onShowFriendLocation,
  ) async {
    HapticFeedback.lightImpact();

    final mapController = Provider.of<MapScreenController>(
      context,
      listen: false,
    );
    final isLocationDisplayed = mapController.isFriendLocationDisplayed(
      friend.userId,
    );

    // 친구의 최신 온라인 상태 확인 (서버 데이터 우선)
    final friendsController = Provider.of<FriendsController>(
      context,
      listen: false,
    );

    // 현재 친구 목록에서 해당 친구의 최신 상태 가져오기
    final currentFriend = friendsController.friends.firstWhere(
      (f) => f.userId == friend.userId,
      orElse: () => friend, // 찾지 못하면 원본 사용
    );

    // 서버 데이터 기반 온라인 상태 확인
    final isOnline = currentFriend.isLogin;
    debugPrint(
      '🔍 친구 상세 정보 - ${friend.userName} (${friend.userId}): 온라인=$isOnline',
    );

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 헤더
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isOnline
                              ? const Color(0xFF10B981).withValues(
                                  alpha: 0.2,
                                ) // 온라인 친구는 초록색 배경
                              : const Color(0xFF1E3A8A).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isOnline
                                ? const Color(0xFF10B981).withValues(
                                    alpha: 0.5,
                                  ) // 온라인 친구는 초록색 테두리
                                : const Color(
                                    0xFF1E3A8A,
                                  ).withValues(alpha: 0.3),
                            width: isOnline ? 2 : 1, // 온라인 친구는 더 두꺼운 테두리
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          color: isOnline
                              ? const Color(0xFF10B981) // 온라인 친구는 초록색 아이콘
                              : const Color(0xFF1E3A8A),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              friend.userName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: isOnline
                                    ? const Color(0xFF10B981) // 온라인 친구는 초록색 텍스트
                                    : const Color(0xFF1E3A8A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isOnline
                                        ? const Color(0xFF10B981) // 초록색 온라인 표시
                                        : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isOnline
                                      ? AppLocalizations.of(context)!.online
                                      : AppLocalizations.of(context)!.offline,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isOnline
                                        ? const Color(0xFF10B981) // 초록색 온라인 텍스트
                                        : Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 내용
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        context,
                        Icons.badge,
                        AppLocalizations.of(context)!.id,
                        friend.userId,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        context,
                        Icons.phone,
                        AppLocalizations.of(context)!.contact,
                        friend.phone.isEmpty
                            ? AppLocalizations.of(context)!.noContactInfo
                            : friend.phone,
                        isClickable: friend.phone.isNotEmpty,
                        onTap: friend.phone.isNotEmpty
                            ? () => FriendsUtils.handlePhone(
                                context,
                                friend.phone,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),

                // 버튼 영역
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 24,
                  ),
                  child: Column(
                    children: [
                      // 위치 관련 버튼들
                      if (friend.lastLocation.isNotEmpty) ...[
                        Row(
                          children: [
                            // 위치 표시/제거 버튼
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: (!friend.isLocationPublic || !isOnline) ? null : () async {
                                    HapticFeedback.lightImpact();
                                    Navigator.of(context).pop(); // 항상 모달창 닫기

                                    // 🔥 위치 공유 상태 확인 (더 엄격하게)
                                    if (!friend.isLocationPublic) {
                                      debugPrint('❌ 위치 공유 미허용 친구: ${friend.userName}');
                                      FriendsUtils.showErrorMessage(
                                        context,
                                        AppLocalizations.of(context)!.friend_location_permission_denied(friend.userName),
                                      );
                                      return;
                                    }

                                    if (!isOnline) {
                                      FriendsUtils.showErrorMessage(
                                        context,
                                        AppLocalizations.of(
                                          context,
                                        )!.friendOfflineError,
                                      );
                                      return;
                                    }

                                    if (!isLocationDisplayed) {
                                      await _showFriendLocationOnMap(
                                        context,
                                        friend,
                                        onShowFriendLocation,
                                      );
                                    } else {
                                      await _removeFriendLocationFromMap(
                                        context,
                                        friend,
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    isLocationDisplayed
                                        ? Icons.location_off
                                        : Icons.location_on,
                                    size: 18,
                                    color: (!friend.isLocationPublic || !isOnline) 
                                        ? Colors.grey.shade400
                                        : Colors.white,
                                  ),
                                  label: Text(
                                    (!friend.isLocationPublic || !isOnline)
                                        ? '위치 공유 비활성화'
                                        : (isLocationDisplayed
                                            ? AppLocalizations.of(context)!.removeLocation
                                            : AppLocalizations.of(context)!.showLocation),
                                    style: TextStyle(
                                      color: (!friend.isLocationPublic || !isOnline)
                                          ? Colors.grey.shade400
                                          : Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: (!friend.isLocationPublic || !isOnline)
                                        ? Colors.grey.shade300
                                        : (isLocationDisplayed
                                            ? const Color(0xFFEF4444)
                                            : const Color(0xFF10B981)),
                                    foregroundColor: (!friend.isLocationPublic || !isOnline)
                                        ? Colors.grey.shade400
                                        : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // 닫기 버튼
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.close, size: 18),
                                  label: Text(
                                    AppLocalizations.of(context)!.close,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[100],
                                    foregroundColor: Colors.grey[700],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // 위치 정보가 없을 때는 닫기 버튼만
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, size: 18),
                            label: Text(AppLocalizations.of(context)!.close),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              foregroundColor: Colors.grey[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 상세 정보 행 위젯
  static Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isClickable = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: isClickable ? onTap : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isClickable
                        ? const Color(0xFF10B981)
                        : const Color(0xFF1E3A8A),
                    decoration: isClickable ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 친구 위치를 지도에 표시 - 콜백 함수 사용
  static Future<void> _showFriendLocationOnMap(
    BuildContext context,
    Friend friend,
    Function(Friend)? onShowFriendLocation,
  ) async {
    try {
      if (onShowFriendLocation != null) {
        // 콜백 함수 호출 (MapScreen에서 전달받은 함수)
        await onShowFriendLocation(friend);
      } else {
        // 기본 동작 (Provider 사용)
        final mapController = Provider.of<MapScreenController>(
          context,
          listen: false,
        );
        await mapController.showFriendLocation(friend);
        _showFriendLocationSuccess(context, friend);
      }
    } catch (e) {
      debugPrint('❌ 친구 위치 표시 오류: $e');
      FriendsUtils.showErrorMessage(context, AppLocalizations.of(context)!.friend_location_display_error);
    }
  }

  /// 친구 위치를 지도에서 제거
  static Future<void> _removeFriendLocationFromMap(
    BuildContext context,
    Friend friend,
  ) async {
    try {
      final mapController = Provider.of<MapScreenController>(
        context,
        listen: false,
      );
      await mapController.removeFriendLocationMarker(friend.userId);

      FriendsUtils.showSuccessMessage(
        context,
        AppLocalizations.of(context)!.friendLocationRemoved(friend.userName),
      );

      debugPrint('✅ 친구 위치 제거 완료: ${friend.userName}');
    } catch (e) {
      debugPrint('❌ 친구 위치 제거 오류: $e');
      FriendsUtils.showErrorMessage(
        context,
        AppLocalizations.of(context)!.friend_location_remove_error,
      );
    }
  }

  /// 친구 위치 표시 성공 메시지
  static void _showFriendLocationSuccess(BuildContext context, Friend friend) {
    FriendsUtils.showSuccessMessage(
      context,
      AppLocalizations.of(context)!.friendLocationShown(friend.userName),
    );
  }

  /// 요청 취소 다이얼로그
  static Future<void> showCancelRequestDialog(
    BuildContext context,
    SentFriendRequest request,
    VoidCallback onCancel,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
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
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.cancelFriendRequest,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!.cancel_request_description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 내용
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(
                            context,
                          )!.cancelFriendRequestConfirm(request.toUserName),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 버튼 영역
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.no,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.cancelRequest,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      HapticFeedback.lightImpact();
      onCancel();
    }
  }

  /// 친구 삭제 다이얼로그
  static Future<void> showDeleteFriendDialog(
    BuildContext context,
    Friend friend,
    VoidCallback onDelete,
  ) async {
    final l10n = AppLocalizations.of(context)!; // 다국어 텍스트 불러오기

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더 - 경고 스타일
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_outlined,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.friendDeleteTitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.friendDeleteWarning,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 내용
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.friendDeleteHeader,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.friendDeleteToConfirm,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 버튼 영역
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l10n.friendDeleteCancel,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            l10n.friendDeleteButton,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      onDelete();
    }
  }
}
