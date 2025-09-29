// lib/friends/friends_screen.dart - 분할된 파일들을 사용하는 리팩토링된 메인 화면
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/friends/friend.dart';
import 'package:flutter_application_1/friends/friend_api_service.dart';
import 'package:flutter_application_1/friends/friend_repository.dart';
import 'package:flutter_application_1/friends/friends_controller.dart';
import 'package:flutter_application_1/friends/friends_dialogs.dart';
import 'package:flutter_application_1/friends/friends_tabs.dart';
import 'package:flutter_application_1/friends/friends_tiles.dart';
import 'package:flutter_application_1/friends/friends_utils.dart';
import 'package:flutter_application_1/generated/app_localizations.dart';
import 'package:flutter_application_1/services/auth_service.dart';

class FriendsScreen extends StatefulWidget {
  final String userId;
  final Function(Friend)? onShowFriendLocation; // 콜백 함수 추가

  const FriendsScreen({
    required this.userId,
    this.onShowFriendLocation, // 선택적 매개변수
    super.key,
  });

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with WidgetsBindingObserver {
  late final FriendsController controller;
  final _addController = TextEditingController();
  bool _isAddingFriend = false;
  List<Map<String, String>>? _cachedUserList;
  Future<List<Map<String, String>>>? _userListFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    controller =
        FriendsController(FriendRepository(FriendApiService()), widget.userId)
          ..addListener(() {
            if (mounted) {
              setState(() {});
            }
          })
          ..loadAll();

    debugPrint('🚀 친구 화면 초기화 완료 - 실시간 업데이트 활성화');
  }

  @override
  void didUpdateWidget(FriendsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 🔥 사용자 ID 변경 시 FriendsController 재생성
    if (oldWidget.userId != widget.userId) {
      debugPrint('🔄 FriendsScreen 사용자 변경 감지: ${oldWidget.userId} → ${widget.userId}');
      
      // 기존 컨트롤러 정리
      controller.clearAllData(); // 즉시 데이터 초기화
      controller.dispose();
      
      // 새로운 컨트롤러 생성
      controller = FriendsController(FriendRepository(FriendApiService()), widget.userId)
        ..addListener(() {
          if (mounted) {
            setState(() {});
          }
        })
        ..loadAll();
      
      debugPrint('✅ FriendsScreen FriendsController 재생성 완료');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    _addController.dispose();
    
    // 🔥 캐시 정리
    _clearCachedUserList();
    
    super.dispose();
  }

  // 앱 생명주기 관리 (백그라운드/포그라운드 전환)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('📱 앱 포그라운드 전환 - 실시간 업데이트 재시작');
        controller.resumeRealTimeUpdates();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        debugPrint('📱 앱 백그라운드 전환 - 실시간 업데이트 일시중지');
        controller.stopRealTimeUpdates();
        break;
      default:
        break;
    }
  }

  /// 캐시된 사용자 목록 가져오기
  Future<List<Map<String, String>>> _getCachedUserList() async {
    if (_cachedUserList != null) {
      debugPrint('📋 캐시된 사용자 목록 사용: ${_cachedUserList!.length}명');
      return _cachedUserList!;
    }

    if (_userListFuture != null) {
      debugPrint('📋 진행 중인 사용자 목록 요청 재사용');
      return _userListFuture!;
    }

    debugPrint('📋 새로운 사용자 목록 요청 시작');
    _userListFuture = AuthService().getUserList();
    _cachedUserList = await _userListFuture!;
    _userListFuture = null;

    debugPrint('📋 사용자 목록 캐시 완료: ${_cachedUserList!.length}명');
    return _cachedUserList!;
  }

  /// 캐시된 사용자 목록 초기화
  void _clearCachedUserList() {
    _cachedUserList = null;
    _userListFuture = null;
    debugPrint('📋 사용자 목록 캐시 초기화 완료');
  }

  /// 사용자 목록 새로고침
  Future<void> _refreshUserList() async {
    _clearCachedUserList();
    await _getCachedUserList();
    if (mounted) setState(() {});
  }

  /// 친구 추가 처리 함수
  Future<void> _handleAddFriend([StateSetter? setModalState]) async {
    // 이미 제출 중이면 중복 제출 방지
    if (_isAddingFriend) {
      debugPrint(AppLocalizations.of(context)!.already_adding_friend);
      return;
    }

    final id = _addController.text.trim();
    if (id.isEmpty) {
      FriendsUtils.showErrorMessage(
        context,
        AppLocalizations.of(context)!.enter_id_prompt,
      );
      return;
    }

    debugPrint('🔍 친구 추가 시도 - 입력된 ID: $id');

    setState(() => _isAddingFriend = true);

    try {
      debugPrint('🔄 UI: controller.addFriend 시작...');
      await controller.addFriend(id);
      debugPrint('📤 친구 요청 전송 완료');

      // 성공 - 예외가 발생하지 않았으면 성공
      debugPrint('✅ UI: 친구 요청 성공으로 판단');
      HapticFeedback.lightImpact();
      FriendsUtils.showSuccessMessage(
        context,
        AppLocalizations.of(context)!.friend_request_sent_success,
      );
      _addController.clear();
      
      // 🔥 친구 추가 성공 후 캐시 정리 및 데이터 새로고침
      _clearCachedUserList(); // 사용자 목록 캐시 초기화
      
      // 🔥 백그라운드에서 친구 데이터 새로고침 (UI 블로킹 없음)
      Future.microtask(() async {
        debugPrint('🔄 백그라운드에서 친구 데이터 새로고침 시작');
        await controller.quickUpdate();
        debugPrint('✅ 백그라운드 친구 데이터 새로고침 완료');
      });
      
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint('❌ UI: 친구 추가 중 오류: $e');
      debugPrint('❌ UI: 예외 타입: ${e.runtimeType}');
      debugPrint('❌ UI: 예외 스택: ${StackTrace.current}');
      debugPrint('❌ UI: 예외 메시지: ${e.toString()}');

      HapticFeedback.heavyImpact();
      // 구체적인 에러 메시지 처리
      final errorMsg = FriendsUtils.getAddFriendErrorMessage(context, e);
      FriendsUtils.showErrorMessage(context, errorMsg);
      // 실패 시에도 모달창 닫기
      if (mounted) Navigator.of(context).pop();
    } finally {
      setState(() => _isAddingFriend = false);
    }
  }

  // 실시간 상태 표시기가 포함된 헤더
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.friends,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!.friendManagementAndRequests,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: controller.isRealTimeEnabled
                                ? Colors.green
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 새로고침 버튼과 추가 버튼
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: controller.isRefreshing ? null : () {
                    HapticFeedback.lightImpact();
                    controller.refreshWithAnimation();
                  },
                  icon: controller.isRefreshing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF1E3A8A),
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.refresh,
                          color: Color(0xFF1E3A8A),
                          size: 24,
                        ),
                ),
              ),
              AnimatedScale(
                scale: _isAddingFriend ? 0.95 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: IconButton(
                  onPressed: _isAddingFriend ? null : _showAddDialog,
                  icon: _isAddingFriend
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF1E3A8A),
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.person_add,
                          color: Color(0xFF1E3A8A),
                          size: 28,
                        ),
                ),
              ),
            ],
          ),
          // 실시간 업데이트 정보 표시
          if (controller.isRealTimeEnabled) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi, color: Colors.green.shade600, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context)!.realTimeSyncStatus,
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 친구 관리 다이얼로그 - 실시간 업데이트 적용
  Future<void> _showAddDialog() async {
    final l10n = AppLocalizations.of(context)!;
    HapticFeedback.lightImpact();

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.85, // 0.7에서 0.85로 증가
          minChildSize: 0.6, // 0.5에서 0.6으로 증가
          maxChildSize: 0.95, // 0.95에서 0.95로 유지
          expand: false,
          builder: (context, scrollController) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    // 드래그 핸들
                    Container(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.friend_management,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 탭 바
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TabBar(
                        isScrollable: true, // ← Overflow 방지!
                        labelColor: const Color(0xFF1E3A8A),
                        unselectedLabelColor: Colors.grey,
                        labelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        indicator: BoxDecoration(
                          color: const Color(0xFF1E3A8A).withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tabs: [
                          Tab(
                            child: FittedBox(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.person_add, size: 16),
                                  const SizedBox(width: 4),
                                  Text(AppLocalizations.of(context)!.add),
                                ],
                              ),
                            ),
                          ),
                          Tab(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.send, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.sentRequestsCount(
                                      controller.sentFriendRequests.length,
                                    ),
                                  ),
                                  if (controller.sentFriendRequests.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(left: 4),
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF59E0B),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Tab(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.notifications_active,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.receivedRequestsCount(
                                      controller.friendRequests.length,
                                    ),
                                  ),
                                  if (controller.friendRequests.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(left: 4),
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFEF4444),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 탭 내용
                    Expanded(
                      child: TabBarView(
                        children: [
                          FriendsTabs.buildAddFriendTab(
                            context,
                            setModalState,
                            scrollController,
                            _addController,
                            _isAddingFriend,
                            () => _handleAddFriend(setModalState),
                            _refreshUserList,
                            controller,
                          ),
                          FriendsTabs.buildSentRequestsTab(
                            context,
                            setModalState,
                            scrollController,
                            controller,
                            (String userId, String userName) async {
                              // 요청 취소 로직
                              try {
                                await controller.cancelSentRequest(userId);
                                // 모달 상태 즉시 업데이트
                                setModalState(() {});
                                FriendsUtils.showSuccessMessage(
                                  context,
                                  AppLocalizations.of(
                                    context,
                                  )!.friendRequestCancelled(userName),
                                );
                              } catch (e) {
                                FriendsUtils.showErrorMessage(
                                  context,
                                  AppLocalizations.of(
                                    context,
                                  )!.friendRequestCancelError,
                                );
                              }
                            },
                          ),
                          FriendsTabs.buildReceivedRequestsTab(
                            context,
                            setModalState,
                            scrollController,
                            controller,
                            (String userId, String userName) async {
                              // 요청 수락 로직
                              try {
                                await controller.acceptRequest(userId);
                                // 모달 상태 즉시 업데이트
                                setModalState(() {});
                                FriendsUtils.showSuccessMessage(
                                  context,
                                  AppLocalizations.of(
                                    context,
                                  )!.friendRequestAccepted(userName),
                                );
                              } catch (e) {
                                FriendsUtils.showErrorMessage(
                                  context,
                                  AppLocalizations.of(
                                    context,
                                  )!.friendRequestAcceptError,
                                );
                              }
                            },
                            (String userId, String userName) async {
                              // 요청 거절 로직
                              try {
                                await controller.rejectRequest(userId);
                                // 모달 상태 즉시 업데이트
                                setModalState(() {});
                                FriendsUtils.showSuccessMessage(
                                  context,
                                  AppLocalizations.of(
                                    context,
                                  )!.friendRequestRejected(userName),
                                );
                              } catch (e) {
                                FriendsUtils.showErrorMessage(
                                  context,
                                  AppLocalizations.of(
                                    context,
                                  )!.friendRequestRejectError,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 실시간 업데이트되는 메인 친구 목록
  Widget _buildFriendsContent() {
    return Container(
      margin: EdgeInsets.zero, // 화면에 꽉 차게
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          FriendsTiles.buildSectionHeader(
            AppLocalizations.of(
              context,
            )!.friendCount(controller.friends.length),
            icon: Icons.people_alt,
          ),
          if (controller.friends.isEmpty)
            FriendsTiles.buildEmptyState(
              AppLocalizations.of(context)!.noFriends,
            )
          else
            ...controller.friends.asMap().entries.map((entry) {
              final index = entry.key;
              final friend = entry.value;
              return AnimatedContainer(
                duration: Duration(milliseconds: 300 + (index * 100)),
                curve: Curves.easeOutBack,
                child: FriendsTiles.buildFriendTile(
                  context,
                  friend,
                  () => FriendsDialogs.showFriendDetailsDialog(
                    context,
                    friend,
                    widget.onShowFriendLocation,
                  ),
                  () => FriendsDialogs.showDeleteFriendDialog(
                    context,
                    friend,
                    () async {
                      await controller.deleteFriend(friend.userId);
                      final l10n = AppLocalizations.of(context)!;
                      final message = l10n.friendDeleteSuccessMessage(
                        friend.userName,
                      );
                      FriendsUtils.showSuccessMessage(context, message);
                    },
                  ),
                ),
              );
            }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = controller.isLoading;
    final error = controller.errorMessage;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1E3A8A),
                        ),
                      )
                    : error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Color(0xFFEF4444),
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              error,
                              style: const TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                controller.loadAll();
                              },
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF1E3A8A),
                        onRefresh: controller.loadAll,
                        child: ListView(
                          padding: const EdgeInsets.only(top: 16, bottom: 32),
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [_buildFriendsContent()],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
