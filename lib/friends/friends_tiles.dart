import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/friends/friend.dart';
import 'package:flutter_application_1/friends/friends_controller.dart';
import 'package:flutter_application_1/friends/friends_utils.dart';
import 'package:flutter_application_1/generated/app_localizations.dart';

/// 친구 타일 관련 위젯들
class FriendsTiles {
  /// 친구 타일 - 클릭 시 상세 정보 다이얼로그 표시
  static Widget buildFriendTile(
    BuildContext context,
    Friend friend,
    VoidCallback onShowDetails,
    VoidCallback onDelete,
  ) {
    // FriendsController에서 최신 상태 가져오기
    final friendsController = Provider.of<FriendsController>(
      context,
      listen: false,
    );
    final currentFriend = friendsController.friends.firstWhere(
      (f) => f.userId == friend.userId,
      orElse: () => friend, // 찾지 못하면 원본 사용
    );

    // 디버깅: 친구 상태 로그
    debugPrint(
      '🎨 ${friend.userName} (${friend.userId}) 타일 렌더링 - 원본 온라인: ${friend.isLogin}, 최신 온라인: ${currentFriend.isLogin}',
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: currentFriend.isLogin
              ? const Color(0xFF10B981).withValues(alpha: 0.5) // 더 진한 초록색 테두리
              : const Color(0xFFE2E8F0),
          width: currentFriend.isLogin ? 2 : 1, // 온라인 친구는 더 두꺼운 테두리
        ),
        boxShadow: [
          BoxShadow(
            color: currentFriend.isLogin
                ? const Color(0xFF10B981).withValues(
                    alpha: 0.1,
                  ) // 온라인 친구는 초록색 그림자
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onShowDetails,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: currentFriend.isLogin
                        ? const Color(0xFF10B981).withValues(
                            alpha: 0.15,
                          ) // 더 진한 초록색 배경
                        : const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: currentFriend.isLogin
                          ? const Color(0xFF10B981).withValues(
                              alpha: 0.5,
                            ) // 더 진한 초록색 테두리
                          : const Color(0xFF1E3A8A).withValues(alpha: 0.3),
                      width: currentFriend.isLogin
                          ? 2.5
                          : 2, // 온라인 친구는 더 두꺼운 테두리
                    ),
                  ),
                  child: Icon(
                    Icons.person,
                    color: currentFriend.isLogin
                        ? const Color(0xFF10B981) // 초록색 아이콘
                        : const Color(0xFF1E3A8A),
                    size: 24,
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
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: currentFriend.isLogin
                              ? const Color(0xFF10B981) // 온라인 친구는 초록색 텍스트
                              : const Color(0xFF1E3A8A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: currentFriend.isLogin
                                  ? const Color(0xFF10B981) // 초록색 온라인 표시
                                  : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            currentFriend.isLogin
                                ? AppLocalizations.of(context)!.online
                                : AppLocalizations.of(context)!.offline,
                            style: TextStyle(
                              fontSize: 12,
                              color: currentFriend.isLogin
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
                IconButton(
                  icon: const Icon(
                    Icons.person_remove,
                    color: Color(0xFFEF4444),
                  ),
                  tooltip: AppLocalizations.of(context)!.friendDeleteTitle,
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 애니메이션이 추가된 보낸 요청 타일
  static Widget buildSentRequestTile(
    BuildContext context,
    SentFriendRequest request,
    VoidCallback onCancel,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.schedule,
              color: Color(0xFF1E3A8A),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.toUserName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppLocalizations.of(context)!.id}: ${FriendsUtils.maskUserId(request.toUserId)}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
                if (request.requestDate.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.requestDate(request.requestDate),
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.cancel,
                color: Color(0xFFEF4444),
                size: 20,
              ),
              onPressed: onCancel,
            ),
          ),
        ],
      ),
    );
  }

  /// 애니메이션이 추가된 받은 요청 타일
  static Widget buildReceivedRequestTile(
    BuildContext context,
    FriendRequest request,
    VoidCallback onAccept,
    VoidCallback onReject,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_add,
              color: Color(0xFFF59E0B),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      request.fromUserName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.newBadge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppLocalizations.of(context)!.id}: ${FriendsUtils.maskUserId(request.fromUserId)}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.check,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                  onPressed: onAccept,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                  onPressed: onReject,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 빈 상태 위젯
  static Widget buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_outline,
              color: Color(0xFF1E3A8A),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// 섹션 헤더 위젯
  static Widget buildSectionHeader(String title, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E3A8A),
            ),
          ),
        ],
      ),
    );
  }
}
