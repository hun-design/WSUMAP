import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/components/woosong_button.dart';
import 'package:flutter_application_1/components/woosong_input_field.dart';
import 'package:flutter_application_1/friends/friends_controller.dart';
import 'package:flutter_application_1/friends/friends_tiles.dart';
import 'package:flutter_application_1/generated/app_localizations.dart';
import 'package:flutter_application_1/services/auth_service.dart';

/// 탭 관련 위젯들
class FriendsTabs {
  /// 친구 추가 탭
  static Widget buildAddFriendTab(
    BuildContext context,
    StateSetter setModalState,
    ScrollController scrollController,
    TextEditingController addController,
    bool isAddingFriend,
    VoidCallback onAddFriend,
    VoidCallback onRefreshUserList,
    FriendsController controller,
  ) {
    return FutureBuilder<List<Map<String, String>>>(
      future: _getCachedUserList(),
      builder: (context, snapshot) {
        List<Map<String, String>> userList = [];
        if (snapshot.hasData) {
          userList = snapshot.data!;
        }

        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            Text(
              AppLocalizations.of(context)!.enterFriendIdPrompt,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            Container(
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
              child: WoosongInputField(
                icon: Icons.person_add_alt,
                label: AppLocalizations.of(context)!.friendId,
                controller: addController,
                hint: AppLocalizations.of(context)!.enterFriendId,
                enabled: !isAddingFriend,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 60),
                curve: Curves.easeOutCubic,
                transform: Matrix4.identity()..scale(isAddingFriend ? 0.92 : 1.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isAddingFriend ? [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ] : [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: isAddingFriend ? null : () async {
                      HapticFeedback.mediumImpact();
                      // 백그라운드에서 사용자 목록을 확인하여 유효성 검증
                      final enteredId = addController.text.trim();
                      if (enteredId.isEmpty) {
                        HapticFeedback.lightImpact();
                        return;
                      }
                  
                  // 🔥 사용자 목록 새로고침 후 확인
                  try {
                    // 사용자 목록 새로고침
                    onRefreshUserList();
                    
                    // 새로고침된 사용자 목록에서 확인
                    final isValidUser = userList.any((user) => user['id'] == enteredId);
                    if (!isValidUser) {
                      HapticFeedback.heavyImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.user_not_found),
                          backgroundColor: const Color(0xFFEF4444),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                      return;
                    }
                    
                    // 🔥 서버에서 중복 체크를 하므로 클라이언트 측 체크 제거
                    // 서버가 정확한 데이터베이스 상태를 기반으로 체크함
                    
                    // 모든 검증 통과 시 친구 추가 진행
                    onAddFriend();
                  } catch (e) {
                    debugPrint('❌ 사용자 목록 새로고침 실패: $e');
                    HapticFeedback.heavyImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('사용자 확인 중 오류가 발생했습니다.'),
                        backgroundColor: const Color(0xFFEF4444),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                child: WoosongButton(
                  onPressed: isAddingFriend ? null : () {}, // 활성화 상태 유지
                  child: isAddingFriend
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(AppLocalizations.of(context)!.sendFriendRequest),
                ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  /// 실시간 업데이트되는 보낸 요청 탭
  static Widget buildSentRequestsTab(
    BuildContext context,
    StateSetter setModalState,
    ScrollController scrollController,
    FriendsController controller,
    Future<void> Function(String userId, String userName) onCancelRequest,
  ) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.update, color: Colors.blue.shade600, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.realTimeSyncActive,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (controller.sentFriendRequests.isEmpty)
          SizedBox(
            height: 300,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_outlined,
                      color: Color(0xFF1E3A8A),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noSentRequests,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...controller.sentFriendRequests.map(
            (request) => FriendsTiles.buildSentRequestTile(
              context,
              request,
              () => onCancelRequest(request.toUserId, request.toUserName),
            ),
          ),
      ],
    );
  }

  /// 실시간 업데이트되는 받은 요청 탭
  static Widget buildReceivedRequestsTab(
    BuildContext context,
    StateSetter setModalState,
    ScrollController scrollController,
    FriendsController controller,
    Future<void> Function(String userId, String userName) onAcceptRequest,
    Future<void> Function(String userId, String userName) onRejectRequest,
  ) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        if (controller.friendRequests.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: Colors.red.shade600,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.newFriendRequests(controller.friendRequests.length),
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        if (controller.friendRequests.isEmpty)
          SizedBox(
            height: 300,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none,
                      color: Color(0xFF1E3A8A),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noReceivedRequests,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...controller.friendRequests.map(
            (request) => FriendsTiles.buildReceivedRequestTile(
              context,
              request,
              () => onAcceptRequest(request.fromUserId, request.fromUserName),
              () => onRejectRequest(request.fromUserId, request.fromUserName),
            ),
          ),
      ],
    );
  }

  /// 캐시된 사용자 목록 가져오기
  static Future<List<Map<String, String>>> _getCachedUserList() async {
    try {
      return await AuthService().getUserList();
    } catch (e) {
      debugPrint('User list fetch error: $e');
      return [];
    }
  }
}
