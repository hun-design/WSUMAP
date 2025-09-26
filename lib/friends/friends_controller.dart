// lib/friends/friends_controller.dart - 웹소켓 연동 추가
import 'dart:async';
import 'package:flutter/material.dart';
import 'friend.dart';
import 'friend_repository.dart';
import '../services/websocket_service.dart';
import '../services/notification_service.dart';
import '../services/performance_monitor.dart';

class FriendsController extends ChangeNotifier {
  final FriendRepository repository;
  final String myId;
  final WebSocketService _wsService = WebSocketService();

  FriendsController(this.repository, this.myId) {
    // 🔥 게스트 사용자는 웹소켓 초기화 제외
    if (!myId.startsWith('guest_')) {
      _initializeWebSocket();
    } else {
      debugPrint('⚠️ 게스트 사용자 - 웹소켓 초기화 제외');
    }
  }

  List<Friend> friends = [];
  List<FriendRequest> friendRequests = [];
  List<SentFriendRequest> sentFriendRequests = [];
  List<String> onlineUsers = [];
  bool isLoading = false;
  String? errorMessage;
  bool isWebSocketConnected = false;

  Timer? _updateTimer;
  StreamSubscription? _wsMessageSubscription;
  StreamSubscription? _wsConnectionSubscription;
  StreamSubscription? _wsOnlineUsersSubscription;

  static const Duration _updateInterval = Duration(seconds: 1); // 2초 → 1초로 변경
  DateTime? _lastUpdate;
  bool _isRealTimeEnabled = true;

  bool get isRealTimeEnabled => _isRealTimeEnabled && isWebSocketConnected;

  // 🔌 웹소켓 초기화
  Future<void> _initializeWebSocket() async {
    debugPrint('🔌 웹소켓 서비스 초기화 중...');

    // 🔥 게스트 사용자는 웹소켓 초기화 제외
    if (myId.startsWith('guest_')) {
      debugPrint('⚠️ 게스트 사용자 - 웹소켓 초기화 제외');
      return;
    }

    // 중복 초기화 방지
    if (_wsService.isConnected) {
      debugPrint('⚠️ 웹소켓이 이미 연결됨 - 초기화 건너뜀');
      return;
    }

    // 알림 서비스 초기화
    await NotificationService.initialize();

    // 웹소켓 연결
    await _wsService.connect(myId);

    // 웹소켓 이벤트 리스너 설정
    _wsMessageSubscription = _wsService.messageStream.listen(
      _handleWebSocketMessage,
    );
    _wsConnectionSubscription = _wsService.connectionStream.listen(
      _handleConnectionChange,
    );
    _wsOnlineUsersSubscription = _wsService.onlineUsersStream.listen(
      _handleOnlineUsersUpdate,
    );

    // 🔥 초기 연결 상태 확인 후 폴링 제어
    try {
      // 웹소켓 연결 상태를 여러 번 확인
      await Future.delayed(const Duration(milliseconds: 500)); // 연결 안정화 대기

      final wsConnected = _wsService.isConnected;
      isWebSocketConnected = wsConnected;
      debugPrint('🔍 초기 웹소켓 연결 상태: $wsConnected');
      debugPrint('🔍 웹소켓 연결 상태 상세: ${_wsService.connectionInfo}');

      if (wsConnected) {
        debugPrint('✅ 초기 웹소켓 연결됨 - 폴링 시작하지 않음');
        // 웹소켓이 연결되면 폴링 타이머 정리
        _updateTimer?.cancel();
        _updateTimer = null;
      } else {
        debugPrint('❌ 초기 웹소켓 연결 실패 - 폴링 모드로 시작');
        _startRealTimeUpdates();
      }
    } catch (e) {
      debugPrint('❌ 웹소켓 연결 상태 확인 실패: $e');
      debugPrint('🔍 웹소켓 연결 상태: ${_wsService.connectionStatus}');
      _startRealTimeUpdates();
    }

    debugPrint('✅ 웹소켓 서비스 초기화 완료');
    debugPrint('🔍 웹소켓 연결 상태: ${_wsService.connectionStatus}');
  }

  // 📨 웹소켓 메시지 처리 (개선)
  void _handleWebSocketMessage(Map<String, dynamic> message) {
    debugPrint('📨 FriendsController: 웹소켓 메시지 수신');
    debugPrint('📨 FriendsController: 메시지 타입: ${message['type']}');
    debugPrint('📨 FriendsController: 메시지 내용: $message');
    debugPrint('📨 FriendsController: 현재 사용자 ID: $myId');

    // 🔥 게스트 사용자는 웹소켓 메시지 처리 제외
    if (myId.startsWith('guest_')) {
      debugPrint('⚠️ 게스트 사용자 - 웹소켓 메시지 처리 제외');
      return;
    }

    // 🔥 메시지 유효성 검사
    if (message['type'] == null) {
      debugPrint('⚠️ 유효하지 않은 웹소켓 메시지: $message');
      return;
    }

    debugPrint('📨 친구 컨트롤러에서 웹소켓 메시지 수신: ${message['type']}');
    debugPrint('📨 메시지 내용: $message');
    debugPrint('📨 현재 웹소켓 연결 상태: $isWebSocketConnected');
    debugPrint('📨 현재 온라인 사용자 수: ${onlineUsers.length}');

    try {
      switch (message['type']) {
        case 'new_friend_request':
        case 'friend_request_accepted':
        case 'friend_request_rejected':
        case 'friend_deleted':
          // 친구 관련 이벤트 발생 시 즉시 데이터 업데이트
          debugPrint('🔄 친구 이벤트로 인한 즉시 업데이트');
          quickUpdate();
          break;

        case 'friend_status_change':
          _handleFriendStatusChange(message);
          break;

        // 🔥 실시간 친구 위치 업데이트 처리
        case 'friend_location_update':
          _handleFriendLocationUpdate(message);
          break;

        // 🔥 온라인 사용자 목록 업데이트 처리
        case 'online_users_update':
          if (message['users'] != null) {
            List<String> users = [];
            if (message['users'] is List) {
              users = (message['users'] as List)
                  .map((user) {
                    if (user is String) {
                      return user;
                    } else if (user is Map) {
                      return user['userId']?.toString() ??
                          user['id']?.toString() ??
                          '';
                    } else {
                      return user.toString();
                    }
                  })
                  .where((id) => id.isNotEmpty)
                  .toList();
            }
            _handleOnlineUsersUpdate(users);
          }
          break;

        // 🔥 등록 확인 메시지
        case 'registered':
          debugPrint('✅ 웹소켓 등록 확인됨 - 친구 컨트롤러');
          break;

        // 🔥 새로 추가: 사용자 로그인 처리
        case 'user_login':
          _handleUserLogin(message);
          break;

        // 🔥 새로 추가: 사용자 로그아웃 처리
        case 'user_logout':
          _handleUserLogout(message);
          break;

        // 🔥 새로 추가: 친구 로그인 처리
        case 'friend_logged_in':
          debugPrint('📨 FriendsController: friend_logged_in 메시지 처리 시작');
          debugPrint('📨 FriendsController: 로그인 사용자 ID: ${message['userId']}');
          _handleFriendLoggedIn(message);
          debugPrint('📨 FriendsController: friend_logged_in 메시지 처리 완료');
          break;

        // 🔥 새로 추가: 친구 로그아웃 처리
        case 'friend_logged_out':
          debugPrint('📨 FriendsController: friend_logged_out 메시지 처리 시작');
          debugPrint('📨 FriendsController: 로그아웃 사용자 ID: ${message['userId']}');
          _handleFriendLoggedOut(message);
          debugPrint('📨 FriendsController: friend_logged_out 메시지 처리 완료');
          break;

        // 🔥 하트비트 응답 처리
        case 'heartbeat_response':
          debugPrint('❤️ 친구 컨트롤러에서 하트비트 응답 수신');
          // 특별한 UI 업데이트 필요 없음
          break;

        // 🔥 위치 공유 상태 변경 처리
        case 'location_share_status_change':
          _handleLocationShareStatusChange(message);
          break;

        // 🔥 친구 상태 응답 처리
        case 'friend_status_response':
          _handleFriendStatusResponse(message);
          break;

        default:
          debugPrint('⚠️ 알 수 없는 웹소켓 메시지 타입: ${message['type']}');
      }
    } catch (e) {
      debugPrint('❌ 웹소켓 메시지 처리 중 오류: $e');
      debugPrint('❌ 오류가 발생한 메시지: $message');
    }
  }

  // 친구 위치 실시간 업데이트 핸들러
  void _handleFriendLocationUpdate(Map<String, dynamic> message) {
    final userId = message['userId'];
    final x = message['x'];
    final y = message['y'];
    debugPrint('📍 친구 위치 실시간 업데이트: $userId ($x, $y)');
    for (int i = 0; i < friends.length; i++) {
      if (friends[i].userId == userId) {
        friends[i] = Friend(
          userId: friends[i].userId,
          userName: friends[i].userName,
          profileImage: friends[i].profileImage,
          phone: friends[i].phone,
          isLogin: friends[i].isLogin,
          lastLocation: '$x,$y',
          isLocationPublic: friends[i].isLocationPublic,
        );
        debugPrint('✅ ${friends[i].userName} 위치 갱신: $x, $y');
        break;
      }
    }
    notifyListeners();
  }

  // 🔌 연결 상태 변경 처리
  void _handleConnectionChange(bool isConnected) {
    final previousState = isWebSocketConnected;
    isWebSocketConnected = isConnected;
    debugPrint('🔌 웹소켓 연결 상태 변경: $previousState → $isConnected');

    if (isConnected) {
      debugPrint('✅ 웹소켓 연결됨 - 실시간 모드 활성화');
      debugPrint('🔄 폴링 타이머 완전 중지 중...');
      
      // 🔥 폴링 타이머 완전 정리
      _updateTimer?.cancel();
      _updateTimer = null;
      
      debugPrint('✅ 폴링 타이머 중지 완료 - 실시간 모드로 전환');
      
      // 🔥 웹소켓 연결 시 초기 데이터 로드 및 동기화
      _initializeWithWebSocket();
      
      // 🔥 웹소켓 연결 시 즉시 온라인 사용자 목록 요청
      _requestOnlineUsers();
      
    } else {
      debugPrint('❌ 웹소켓 연결 끊어짐 - 폴링 모드로 전환');
      debugPrint('🔄 폴링 타이머 시작 중...');
      
      // 🔥 웹소켓이 끊어지면 폴링 재시작
      _startRealTimeUpdates();
      
      debugPrint('✅ 폴링 모드 활성화 완료');
    }

    notifyListeners();
  }

  // 🔥 웹소켓 연결 시 초기화 및 동기화
  Future<void> _initializeWithWebSocket() async {
    try {
      debugPrint('🔄 웹소켓 연결 시 초기 데이터 로드 시작');

      // 웹소켓 연결 상태 재확인
      if (!_wsService.isConnected) {
        debugPrint('⚠️ 웹소켓이 연결되지 않음 - 폴링 모드로 전환');
        _startRealTimeUpdates();
        return;
      }

      // 🔥 게스트 사용자는 친구 API 호출 제외
      if (myId.startsWith('guest_')) {
        debugPrint('⚠️ 게스트 사용자 - 친구 API 호출 제외');
        friends = [];
        friendRequests = [];
        sentFriendRequests = [];
        return;
      }

      // 1. 친구 목록 로드
      final newFriends = await repository.getMyFriends();
      friends = newFriends;
      debugPrint('✅ 친구 목록 로드 완료: ${friends.length}명');

      // 2. 친구 요청 목록 로드
      final newFriendRequests = await repository.getFriendRequests();
      friendRequests = newFriendRequests;
      debugPrint('✅ 친구 요청 목록 로드 완료: ${friendRequests.length}개');

      // 3. 보낸 친구 요청 목록 로드
      final newSentFriendRequests = await repository.getSentFriendRequests();
      sentFriendRequests = newSentFriendRequests;
      debugPrint('✅ 보낸 친구 요청 목록 로드 완료: ${sentFriendRequests.length}개');

      // 🔥 4. 서버 데이터 기반 온라인 상태 초기화
      _initializeOnlineStatusFromServer();

      // 5. 온라인 상태 동기화 (개선된 버전)
      _updateFriendsOnlineStatus();

      // 🔥 6. 웹소켓 연결 후 즉시 온라인 사용자 목록 요청
      if (isWebSocketConnected) {
        debugPrint('📡 웹소켓 연결 후 온라인 사용자 목록 요청');
        _requestOnlineUsers();
        
        // 🔥 추가: 친구 상태 요청
        Future.delayed(const Duration(milliseconds: 500), () {
          _wsService.sendMessage({
            'type': 'get_friend_status',
            'userId': myId,
            'timestamp': DateTime.now().toIso8601String(),
          });
        });
      }

      debugPrint('✅ 웹소켓 초기화 완료');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ 웹소켓 초기화 실패: $e');
      // 초기화 실패 시 폴링 모드로 전환
      _startRealTimeUpdates();
    }
  }

  // 🔥 서버 데이터 기반 온라인 상태 초기화
  void _initializeOnlineStatusFromServer() {
    debugPrint('🔄 서버 데이터 기반 온라인 상태 초기화 시작');

    // 온라인 사용자 목록 초기화
    onlineUsers.clear();

    for (int i = 0; i < friends.length; i++) {
      final friend = friends[i];
      if (friend.isLogin) {
        onlineUsers.add(friend.userId);
      }
    }

    debugPrint('🔄 서버 데이터 기반 초기화 완료 - 온라인 사용자: ${onlineUsers.length}명');
  }

  // 👥 온라인 사용자 목록 업데이트
  void _handleOnlineUsersUpdate(List<String> users) {
    onlineUsers = users;
    debugPrint('👥 온라인 사용자 업데이트: ${users.length}명');

    // 🔥 서버 데이터와 웹소켓 데이터 동기화
    // 서버에서 받은 친구 목록의 Is_Login 상태를 우선 반영
    _syncWithServerData();

    // 친구 목록의 온라인 상태 업데이트
    _updateFriendsOnlineStatus();

    debugPrint('🔄 UI 업데이트 트리거 - 온라인 사용자 업데이트');
    notifyListeners();
  }

  // 🔥 서버 데이터와 웹소켓 데이터 동기화 (개선된 버전)
  void _syncWithServerData() {
    debugPrint('🔄 서버 데이터와 웹소켓 데이터 동기화 시작');
    debugPrint('🔄 웹소켓 연결 상태: $isWebSocketConnected');
    debugPrint('🔄 현재 온라인 사용자 목록: $onlineUsers');

    bool hasChanges = false;

    // 🔥 모든 친구에 대해 서버 데이터와 웹소켓 데이터를 비교하여 동기화
    for (int i = 0; i < friends.length; i++) {
      final friend = friends[i];
      final isOnlineInServer = friend.isLogin;
      final isOnlineInWebSocket = onlineUsers.contains(friend.userId);

      debugPrint('🔄 ${friend.userName} 상태 동기화:');
      debugPrint('🔄   서버 상태: $isOnlineInServer');
      debugPrint('🔄   웹소켓 상태: $isOnlineInWebSocket');

      // 🔥 웹소켓이 연결되어 있으면 웹소켓 데이터를 우선하되, 서버 데이터도 고려
      if (isWebSocketConnected) {
        // 웹소켓 데이터가 있으면 우선 사용
        if (isOnlineInWebSocket && !isOnlineInServer) {
          // 웹소켓에서는 온라인이지만 서버에서는 오프라인인 경우
          // 서버 데이터를 업데이트 (실시간 상태 반영)
          friends[i] = Friend(
            userId: friends[i].userId,
            userName: friends[i].userName,
            profileImage: friends[i].profileImage,
            phone: friends[i].phone,
            isLogin: true, // 웹소켓 상태로 업데이트
            lastLocation: friends[i].lastLocation,
            isLocationPublic: friends[i].isLocationPublic,
          );
          hasChanges = true;
          debugPrint('✅ ${friend.userName} 서버 상태를 웹소켓 상태로 업데이트');
        }
      } else {
        // 🔥 웹소켓 연결 안됨: 서버 데이터를 우선하되 온라인 사용자 목록도 업데이트
        if (isOnlineInServer && !isOnlineInWebSocket) {
          onlineUsers.add(friend.userId);
          hasChanges = true;
          debugPrint('✅ ${friend.userName}을 온라인 사용자 목록에 추가 (서버 데이터)');
        } else if (!isOnlineInServer && isOnlineInWebSocket) {
          onlineUsers.remove(friend.userId);
          hasChanges = true;
          debugPrint('✅ ${friend.userName}을 온라인 사용자 목록에서 제거 (서버 데이터)');
        }
      }
    }

    if (hasChanges) {
      debugPrint('🔄 동기화 완료 - 변경사항 있음');
      debugPrint('🔄 최종 온라인 사용자: $onlineUsers');
      notifyListeners();
    } else {
      debugPrint('🔄 동기화 완료 - 변경사항 없음');
    }
  }

  // 📶 친구 상태 변경 처리 (기존 메서드 개선)
  void _handleFriendStatusChange(Map<String, dynamic> message) {
    final userId = message['userId'];
    final isOnline = message['isOnline'] ?? false;

    debugPrint('📶 친구 상태 변경: $userId - ${isOnline ? '온라인' : '오프라인'}');

    // 온라인 사용자 목록 업데이트
    if (isOnline) {
      if (!onlineUsers.contains(userId)) {
        onlineUsers.add(userId);
      }
    } else {
      onlineUsers.remove(userId);
    }

    // 친구 목록에서 해당 사용자의 상태 업데이트
    for (int i = 0; i < friends.length; i++) {
      if (friends[i].userId == userId) {
        friends[i] = Friend(
          userId: friends[i].userId,
          userName: friends[i].userName,
          profileImage: friends[i].profileImage,
          phone: friends[i].phone,
          isLogin: isOnline,
          lastLocation: friends[i].lastLocation,
          isLocationPublic: friends[i].isLocationPublic,
        );

        debugPrint(
          '✅ ${friends[i].userName}님 상태를 ${isOnline ? '온라인' : '오프라인'}으로 업데이트',
        );
        break;
      }
    }

    notifyListeners();
  }

  // 🔥 사용자 로그인 처리
  void _handleUserLogin(Map<String, dynamic> message) {
    final userId = message['userId'];
    debugPrint('👤 사용자 로그인 감지: $userId');

    // 온라인 사용자 목록에 추가
    if (!onlineUsers.contains(userId)) {
      onlineUsers.add(userId);
      debugPrint('✅ 온라인 사용자 목록에 추가: $userId');
    }

    // 친구 목록에서 해당 사용자의 상태를 온라인으로 업데이트
    for (int i = 0; i < friends.length; i++) {
      if (friends[i].userId == userId) {
        if (!friends[i].isLogin) {
          friends[i] = Friend(
            userId: friends[i].userId,
            userName: friends[i].userName,
            profileImage: friends[i].profileImage,
            phone: friends[i].phone,
            isLogin: true,
            lastLocation: friends[i].lastLocation,
            isLocationPublic: friends[i].isLocationPublic,
          );
          debugPrint('✅ ${friends[i].userName} 상태를 온라인으로 업데이트');
        }
        break;
      }
    }

    notifyListeners();
  }

  // 🔥 사용자 로그아웃 처리
  void _handleUserLogout(Map<String, dynamic> message) {
    final userId = message['userId'];
    debugPrint('👤 사용자 로그아웃 감지: $userId');

    // 온라인 사용자 목록에서 제거
    if (onlineUsers.contains(userId)) {
      onlineUsers.remove(userId);
      debugPrint('✅ 온라인 사용자 목록에서 제거: $userId');
    }

    // 친구 목록에서 해당 사용자의 상태를 오프라인으로 업데이트
    for (int i = 0; i < friends.length; i++) {
      if (friends[i].userId == userId) {
        if (friends[i].isLogin) {
          friends[i] = Friend(
            userId: friends[i].userId,
            userName: friends[i].userName,
            profileImage: friends[i].profileImage,
            phone: friends[i].phone,
            isLogin: false,
            lastLocation: friends[i].lastLocation,
            isLocationPublic: friends[i].isLocationPublic,
          );
          debugPrint('✅ ${friends[i].userName} 상태를 오프라인으로 업데이트');
        }
        break;
      }
    }

    notifyListeners();
  }

  // 🔥 새로 추가: 친구 로그인 처리 메서드 (개선된 버전)
  void _handleFriendLoggedIn(Map<String, dynamic> message) {
    final loggedInUserId = message['userId'];
    debugPrint('👤 친구 로그인 감지: $loggedInUserId');
    debugPrint('👤 친구 로그인 메시지 전체: $message');
    debugPrint('👤 현재 온라인 사용자 목록: $onlineUsers');
    debugPrint('👤 현재 친구 목록 수: ${friends.length}');

    bool hasChanges = false;

    // 🔥 실시간으로 즉시 온라인 사용자 목록에 추가
    if (!onlineUsers.contains(loggedInUserId)) {
      onlineUsers.add(loggedInUserId);
      hasChanges = true;
      debugPrint('✅ 실시간: 온라인 사용자 목록에 추가: $loggedInUserId');
      debugPrint('✅ 업데이트된 온라인 사용자 목록: $onlineUsers');
    } else {
      debugPrint('ℹ️ 이미 온라인 사용자 목록에 존재: $loggedInUserId');
    }

    // 🔥 친구 목록에서 해당 사용자의 상태를 즉시 온라인으로 업데이트
    bool found = false;
    for (int i = 0; i < friends.length; i++) {
      if (friends[i].userId == loggedInUserId) {
        found = true;
        final oldStatus = friends[i].isLogin;
        if (!friends[i].isLogin) {
          friends[i] = Friend(
            userId: friends[i].userId,
            userName: friends[i].userName,
            profileImage: friends[i].profileImage,
            phone: friends[i].phone,
            isLogin: true, // 🔥 실시간으로 온라인으로 변경
            lastLocation: friends[i].lastLocation,
            isLocationPublic: friends[i].isLocationPublic,
          );
          hasChanges = true;
          debugPrint('✅ 실시간: ${friends[i].userName} 상태를 온라인으로 업데이트 ($oldStatus → true)');
        } else {
          debugPrint('ℹ️ ${friends[i].userName} 이미 온라인 상태');
        }
        break;
      }
    }

    if (!found) {
      debugPrint('⚠️ 친구 목록에서 해당 사용자를 찾을 수 없음: $loggedInUserId');
      debugPrint('⚠️ 친구 목록의 모든 userId: ${friends.map((f) => f.userId).toList()}');
    }

    // 🔥 변경사항이 있는 경우에만 UI 업데이트
    if (hasChanges) {
      debugPrint('🔄 UI 업데이트 트리거 - 친구 로그인 (변경사항 있음)');
      debugPrint('🔄 notifyListeners() 호출 전 상태: ${friends.where((f) => f.userId == loggedInUserId).map((f) => '${f.userName}: ${f.isLogin}').join(', ')}');
      
      // 🔥 즉시 UI 업데이트
      notifyListeners();
      
      // 🔥 추가 강제 UI 새로고침 (지연 없이)
      Future.delayed(const Duration(milliseconds: 50), () {
        _forceUIUpdate();
        notifyListeners();
      });
      
      // 🔥 친구 로그인 알림 표시
      _showFriendStatusNotification(loggedInUserId, true);
      
      debugPrint('🔄 notifyListeners() 호출 완료');
    } else {
      debugPrint('ℹ️ 상태 변경 없음 - UI 업데이트 스킵');
    }
  }

  // 🔥 위치 공유 상태 변경 처리
  void _handleLocationShareStatusChange(Map<String, dynamic> message) {
    final userId = message['userId'];
    final isLocationPublic = message['isLocationPublic'] ?? false;
    
    debugPrint('📍 위치 공유 상태 변경: $userId - ${isLocationPublic ? '공유' : '비공유'}');
    
    // 친구 목록에서 해당 사용자의 위치 공유 상태 업데이트
    for (int i = 0; i < friends.length; i++) {
      if (friends[i].userId == userId) {
        final oldStatus = friends[i].isLocationPublic;
        friends[i] = Friend(
          userId: friends[i].userId,
          userName: friends[i].userName,
          profileImage: friends[i].profileImage,
          phone: friends[i].phone,
          isLogin: friends[i].isLogin,
          lastLocation: friends[i].lastLocation,
          isLocationPublic: isLocationPublic,
        );
        
        debugPrint('✅ ${friends[i].userName} 위치 공유 상태 변경: $oldStatus → $isLocationPublic');
        
        // 위치 공유가 비활성화된 경우 지도에서 해당 친구 위치 마커 제거
        if (!isLocationPublic && oldStatus) {
          debugPrint('🗑️ ${friends[i].userName} 위치 마커 제거 필요 (위치 공유 비활성화)');
          // 지도 컨트롤러에 친구 위치 마커 제거 요청
          _removeFriendLocationFromMap(userId);
        }
        
        break;
      }
    }
    
    notifyListeners();
  }

  // 🔥 지도에서 친구 위치 마커 제거
  void _removeFriendLocationFromMap(String userId) {
    try {
      debugPrint('🗑️ 친구 위치 마커 제거 요청: $userId');
      // 이 메서드는 MapScreen에서 호출될 예정
      // MapScreenController의 removeFriendLocationDueToLocationShareDisabled 메서드 호출
    } catch (e) {
      debugPrint('❌ 친구 위치 마커 제거 중 오류: $e');
    }
  }

  // 🔥 강제 UI 업데이트 메서드
  void _forceUIUpdate() {
    try {
      debugPrint('🔄 강제 UI 업데이트 시작');
      
      // 현재 시간을 업데이트하여 UI 강제 새로고침 트리거
      _lastUpdate = DateTime.now();
      
      // 친구 목록의 참조를 변경하여 UI가 다시 빌드되도록 함
      final updatedFriends = List<Friend>.from(friends);
      friends = updatedFriends;
      
      debugPrint('🔄 강제 UI 업데이트 완료');
    } catch (e) {
      debugPrint('❌ 강제 UI 업데이트 중 오류: $e');
    }
  }

  // 🔥 웹소켓 연결 상태 재확인 및 복구 메서드
  Future<void> _checkAndRecoverWebSocketConnection() async {
    try {
      debugPrint('🔍 웹소켓 연결 상태 재확인 중...');
      
      // 현재 웹소켓 연결 상태 확인
      final currentConnectionStatus = _wsService.isConnected;
      debugPrint('🔍 현재 웹소켓 연결 상태: $currentConnectionStatus');
      debugPrint('🔍 컨트롤러의 웹소켓 연결 상태: $isWebSocketConnected');
      
      // 상태가 일치하지 않으면 동기화
      if (currentConnectionStatus != isWebSocketConnected) {
        debugPrint('🔄 웹소켓 연결 상태 동기화: $isWebSocketConnected → $currentConnectionStatus');
        isWebSocketConnected = currentConnectionStatus;
        
        if (currentConnectionStatus) {
          debugPrint('✅ 웹소켓 연결 복구됨 - 온라인 사용자 목록 재요청');
          _requestOnlineUsers();
          
          // 친구 상태 재요청
          Future.delayed(const Duration(milliseconds: 500), () {
            _wsService.sendMessage({
              'type': 'get_friend_status',
              'userId': myId,
              'timestamp': DateTime.now().toIso8601String(),
            });
          });
        } else {
          debugPrint('⚠️ 웹소켓 연결 끊어짐 - 폴링 모드로 전환');
          _startRealTimeUpdates();
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ 웹소켓 연결 상태 확인 중 오류: $e');
    }
  }

  // 🔥 온라인 사용자 목록 요청 메서드
  void _requestOnlineUsers() {
    try {
      debugPrint('📡 온라인 사용자 목록 요청 중...');
      
      // 웹소켓을 통해 온라인 사용자 목록 요청
      _wsService.sendMessage({
        'type': 'get_online_users',
        'userId': myId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('✅ 온라인 사용자 목록 요청 전송 완료');
    } catch (e) {
      debugPrint('❌ 온라인 사용자 목록 요청 중 오류: $e');
    }
  }

  // 🔥 친구 상태 변경 알림 표시
  void _showFriendStatusNotification(String userId, bool isOnline) {
    try {
      // 친구 이름 찾기
      final friend = friends.firstWhere(
        (f) => f.userId == userId,
        orElse: () => Friend(
          userId: userId,
          userName: '알 수 없는 사용자',
          profileImage: '',
          phone: '',
          isLogin: isOnline,
          lastLocation: '',
          isLocationPublic: false,
        ),
      );

      final statusText = isOnline ? '온라인' : '오프라인';
      final message = '${friend.userName}님이 $statusText 상태가 되었습니다.';
      
      debugPrint('🔔 친구 상태 알림: $message');
      debugPrint('🔔 상태 변경 시간: ${DateTime.now().toIso8601String()}');
      
      // 🔥 즉시 UI 강제 새로고침을 위한 추가 트리거
      Future.delayed(const Duration(milliseconds: 100), () {
        _forceUIUpdate();
        notifyListeners();
      });
      
      // 실제 알림 표시는 나중에 구현할 수 있음
      // NotificationService.showFriendStatusNotification(message);
      
    } catch (e) {
      debugPrint('❌ 친구 상태 알림 표시 중 오류: $e');
    }
  }

  // 🔥 새로 추가: 친구 상태 응답 처리
  void _handleFriendStatusResponse(Map<String, dynamic> message) {
    debugPrint('📨 친구 상태 응답 처리 시작');
    debugPrint('📨 친구 상태 응답 데이터: $message');

    try {
      // 서버에서 받은 친구 상태 정보를 처리
      if (message['friends'] != null && message['friends'] is List) {
        final friendsData = message['friends'] as List;
        debugPrint('📨 서버에서 받은 친구 상태 수: ${friendsData.length}');
        
        bool hasChanges = false;
        
        // 각 친구의 상태를 업데이트
        for (var friendData in friendsData) {
          if (friendData is Map) {
            final userId = friendData['userId']?.toString() ?? '';
            final isOnline = friendData['isOnline'] ?? false;
            
            debugPrint('📨 친구 상태 업데이트: $userId - ${isOnline ? '온라인' : '오프라인'}');
            
            // 온라인 사용자 목록 업데이트
            if (isOnline && !onlineUsers.contains(userId)) {
              onlineUsers.add(userId);
              hasChanges = true;
              debugPrint('✅ 온라인 사용자 목록에 추가: $userId');
            } else if (!isOnline && onlineUsers.contains(userId)) {
              onlineUsers.remove(userId);
              hasChanges = true;
              debugPrint('✅ 온라인 사용자 목록에서 제거: $userId');
            }
            
            // 친구 목록에서 해당 사용자의 상태 업데이트
            for (int i = 0; i < friends.length; i++) {
              if (friends[i].userId == userId) {
                if (friends[i].isLogin != isOnline) {
                  friends[i] = Friend(
                    userId: friends[i].userId,
                    userName: friends[i].userName,
                    profileImage: friends[i].profileImage,
                    phone: friends[i].phone,
                    isLogin: isOnline,
                    lastLocation: friends[i].lastLocation,
                    isLocationPublic: friends[i].isLocationPublic,
                  );
                  hasChanges = true;
                  debugPrint('✅ ${friends[i].userName} 상태 업데이트: ${!isOnline} → $isOnline');
                }
                break;
              }
            }
          }
        }
        
        if (hasChanges) {
          debugPrint('🔄 친구 상태 응답으로 인한 UI 업데이트');
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('❌ 친구 상태 응답 처리 중 오류: $e');
    }
  }

  // 🔥 새로 추가: 친구 로그아웃 처리 메서드 (개선된 버전)
  void _handleFriendLoggedOut(Map<String, dynamic> message) {
    final loggedOutUserId = message['userId'];
    debugPrint('👤 친구 로그아웃 감지: $loggedOutUserId');
    debugPrint('👤 친구 로그아웃 메시지 전체: $message');
    debugPrint('👤 현재 온라인 사용자 목록: $onlineUsers');
    debugPrint('👤 현재 친구 목록 수: ${friends.length}');

    // 🔥 즉시 온라인 사용자 목록에서 제거
    bool wasOnline = onlineUsers.contains(loggedOutUserId);
    if (wasOnline) {
      onlineUsers.remove(loggedOutUserId);
      debugPrint('✅ 즉시: 온라인 사용자 목록에서 제거: $loggedOutUserId');
      debugPrint('✅ 업데이트된 온라인 사용자 목록: $onlineUsers');
    } else {
      debugPrint('ℹ️ 온라인 사용자 목록에 존재하지 않음: $loggedOutUserId');
    }

    // 🔥 즉시 친구 목록에서 해당 사용자의 상태를 오프라인으로 업데이트
    bool found = false;
    bool statusChanged = false;
    for (int i = 0; i < friends.length; i++) {
      if (friends[i].userId == loggedOutUserId) {
        found = true;
        final oldStatus = friends[i].isLogin;
        if (friends[i].isLogin) {
          friends[i] = Friend(
            userId: friends[i].userId,
            userName: friends[i].userName,
            profileImage: friends[i].profileImage,
            phone: friends[i].phone,
            isLogin: false, // 🔥 즉시 오프라인으로 변경
            lastLocation: friends[i].lastLocation,
            isLocationPublic: friends[i].isLocationPublic,
          );
          statusChanged = true;
          debugPrint('✅ 즉시: ${friends[i].userName} 상태를 오프라인으로 업데이트 ($oldStatus → false)');
        } else {
          debugPrint('ℹ️ ${friends[i].userName} 이미 오프라인 상태');
        }
        break;
      }
    }

    if (!found) {
      debugPrint('⚠️ 친구 목록에서 해당 사용자를 찾을 수 없음: $loggedOutUserId');
      debugPrint('⚠️ 친구 목록의 모든 userId: ${friends.map((f) => f.userId).toList()}');
    }

    // 🔥 상태가 변경된 경우에만 UI 업데이트
    if (statusChanged || wasOnline) {
      debugPrint('🔄 UI 업데이트 트리거 - 친구 로그아웃 (상태 변경됨)');
      debugPrint('🔄 notifyListeners() 호출 전 상태: ${friends.where((f) => f.userId == loggedOutUserId).map((f) => '${f.userName}: ${f.isLogin}').join(', ')}');
      
      // 🔥 즉시 UI 업데이트
      notifyListeners();
      
      // 🔥 추가 강제 UI 새로고침 (지연 없이)
      Future.delayed(const Duration(milliseconds: 50), () {
        _forceUIUpdate();
        notifyListeners();
      });
      
      // 🔥 친구 로그아웃 알림 표시
      _showFriendStatusNotification(loggedOutUserId, false);
      
      debugPrint('🔄 notifyListeners() 호출 완료');
    } else {
      debugPrint('ℹ️ 상태 변경 없음 - UI 업데이트 스킵');
    }
  }

  // 👥 친구들의 온라인 상태 업데이트 (개선)
  void _updateFriendsOnlineStatus() {
    debugPrint('🔄 친구 온라인 상태 업데이트 시작');
    debugPrint('온라인 사용자 목록: $onlineUsers');
    debugPrint('웹소켓 연결 상태: $isWebSocketConnected');

    // 🔥 웹소켓이 연결되어 있으면 웹소켓 데이터를 우선
    if (isWebSocketConnected) {
      debugPrint('✅ 웹소켓 연결됨 - 웹소켓 데이터 기반 상태 업데이트');
      _updateFriendsStatusFromWebSocket();
    } else {
      debugPrint('⚠️ 웹소켓 연결 안됨 - 서버 데이터 기반 상태 업데이트');
      _updateFriendsStatusFromServer();
    }
  }

  // 🔥 웹소켓 데이터 기반 친구 상태 업데이트
  void _updateFriendsStatusFromWebSocket() {
    bool hasChanges = false;

    for (int i = 0; i < friends.length; i++) {
      final isOnlineInWebSocket = onlineUsers.contains(friends[i].userId);
      final currentStatus = friends[i].isLogin;

      if (currentStatus != isOnlineInWebSocket) {
        friends[i] = Friend(
          userId: friends[i].userId,
          userName: friends[i].userName,
          profileImage: friends[i].profileImage,
          phone: friends[i].phone,
          isLogin: isOnlineInWebSocket,
          lastLocation: friends[i].lastLocation,
          isLocationPublic: friends[i].isLocationPublic,
        );
        debugPrint(
          '✅ ${friends[i].userName} 상태 변경: $currentStatus → $isOnlineInWebSocket (웹소켓)',
        );
        hasChanges = true;
      }
    }

    if (hasChanges) {
      debugPrint('🔄 UI 업데이트 트리거 - 웹소켓 기반 친구 상태 변경');
      notifyListeners();
    } else {
      debugPrint('ℹ️ 웹소켓 기반 친구 상태 변경 없음');
    }
  }

  // 🔥 서버 데이터 기반 친구 상태 업데이트
  void _updateFriendsStatusFromServer() {
    bool hasChanges = false;

    for (int i = 0; i < friends.length; i++) {
      final isOnlineInServer = friends[i].isLogin;
      final isOnlineInWebSocket = onlineUsers.contains(friends[i].userId);

      if (isOnlineInServer != isOnlineInWebSocket) {
        if (isOnlineInServer && !isOnlineInWebSocket) {
          onlineUsers.add(friends[i].userId);
          debugPrint('✅ ${friends[i].userName}을 온라인 사용자 목록에 추가 (서버 데이터)');
        } else if (!isOnlineInServer && isOnlineInWebSocket) {
          onlineUsers.remove(friends[i].userId);
          debugPrint('✅ ${friends[i].userName}을 온라인 사용자 목록에서 제거 (서버 데이터)');
        }
        hasChanges = true;
      }
    }

    if (hasChanges) {
      debugPrint('🔄 UI 업데이트 트리거 - 서버 데이터 기반 친구 상태 변경');
      notifyListeners();
    } else {
      debugPrint('ℹ️ 서버 데이터 기반 친구 상태 변경 없음');
    }
  }

  // 🔄 실시간 업데이트 시작 (웹소켓이 없을 때 폴백)
  void _startRealTimeUpdates() {
    debugPrint('🔄 실시간 업데이트 시작');
    _updateTimer?.cancel();

    // 🔥 웹소켓이 연결되어 있으면 폴링을 완전히 시작하지 않음
    if (isWebSocketConnected) {
      debugPrint('📡 웹소켓 연결됨 - 폴링 완전 중지');
      return; // 타이머를 생성하지 않고 완전히 중지
    }

    // 🔥 이미 타이머가 실행 중이면 중복 방지
    if (_updateTimer != null) {
      debugPrint('⚠️ 폴링 타이머가 이미 실행 중입니다');
      return;
    }

    _updateTimer = Timer.periodic(_updateInterval, (timer) async {
      debugPrint('⏰ 폴링 타이머 실행 - 웹소켓 연결 상태: $isWebSocketConnected');
      
      // 🔥 폴링 중에도 웹소켓 연결 상태 확인
      await _checkAndRecoverWebSocketConnection();
      
      // 🔥 웹소켓이 연결되면 타이머 즉시 완전 중지
      if (isWebSocketConnected) {
        debugPrint('📡 웹소켓 연결됨 - 폴링 타이머 즉시 완전 중지');
        timer.cancel(); // 타이머 자체를 중지
        _updateTimer = null; // 타이머 참조 해제
        debugPrint('✅ 폴링 타이머 완전 정리 완료');
        return;
      }

      // 웹소켓이 연결되어 있지 않을 때만 폴링
      if (_isRealTimeEnabled) {
        debugPrint('📡 폴링 모드로 업데이트 (웹소켓 비활성)');
        _silentUpdate();
      }
    });
    
    debugPrint('✅ 폴링 타이머 시작됨 - 간격: ${_updateInterval.inSeconds}초');
  }

  // 🔄 조용한 업데이트
  Future<void> _silentUpdate() async {
    try {
      debugPrint('🔄 백그라운드 친구 데이터 업데이트 중...');

      // 🔥 게스트 사용자는 친구 API 호출 제외
      if (myId.startsWith('guest_')) {
        debugPrint('⚠️ 게스트 사용자 - 백그라운드 친구 API 호출 제외');
        return;
      }

      final now = DateTime.now();
      final previousFriendsCount = friends.length;
      final previousRequestsCount = friendRequests.length;
      final previousSentRequestsCount = sentFriendRequests.length;

      final newFriends = await repository.getMyFriends();
      final newFriendRequests = await repository.getFriendRequests();
      final newSentFriendRequests = await repository.getSentFriendRequests();

      bool hasChanges = false;

      if (newFriends.length != previousFriendsCount ||
          newFriendRequests.length != previousRequestsCount ||
          newSentFriendRequests.length != previousSentRequestsCount) {
        hasChanges = true;
      }

      if (!hasChanges) {
        final newFriendIds = newFriends.map((f) => f.userId).toSet();
        final currentFriendIds = friends.map((f) => f.userId).toSet();

        final newRequestIds = newFriendRequests
            .map((r) => r.fromUserId)
            .toSet();
        final currentRequestIds = friendRequests
            .map((r) => r.fromUserId)
            .toSet();

        final newSentIds = newSentFriendRequests.map((r) => r.toUserId).toSet();
        final currentSentIds = sentFriendRequests
            .map((r) => r.toUserId)
            .toSet();

        if (!newFriendIds.containsAll(currentFriendIds) ||
            !currentFriendIds.containsAll(newFriendIds) ||
            !newRequestIds.containsAll(currentRequestIds) ||
            !currentRequestIds.containsAll(newRequestIds) ||
            !newSentIds.containsAll(currentSentIds) ||
            !currentSentIds.containsAll(newSentIds)) {
          hasChanges = true;
        }
      }

      if (hasChanges) {
        debugPrint('📡 친구 데이터 변경 감지됨! UI 업데이트 중...');

        if (newFriendRequests.length > previousRequestsCount) {
          final newRequests = newFriendRequests.length - previousRequestsCount;
          debugPrint('🔔 새로운 친구 요청 $newRequests개 도착!');
        }

        if (newFriends.length > previousFriendsCount) {
          final newFriendsCount = newFriends.length - previousFriendsCount;
          debugPrint('✅ 새로운 친구 $newFriendsCount명 추가됨!');
        }

        friends = newFriends;
        friendRequests = newFriendRequests;
        sentFriendRequests = newSentFriendRequests;
        // errorMessage는 유지 (에러 상황에서는 초기화하지 않음)
        _lastUpdate = now;

        // 🔥 서버 데이터 기반 온라인 상태 업데이트
        _initializeOnlineStatusFromServer();

        // 온라인 상태 업데이트
        _updateFriendsOnlineStatus();

        notifyListeners();
      } else {
        debugPrint('📊 친구 데이터 변경 없음');
      }
    } catch (e) {
      debugPrint('❌ 백그라운드 업데이트 실패: $e');
    }
  }

  // ⚡ 즉시 업데이트
  Future<void> quickUpdate() async {
    debugPrint('⚡ 빠른 친구 데이터 업데이트');
    await _silentUpdate();
  }

  // 기존 메서드들은 동일하게 유지...
  Future<void> loadAll() async {
    debugPrint('🔄 명시적 친구 데이터 새로고침');
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // 🔥 게스트 사용자는 친구 API 호출 제외
      if (myId.startsWith('guest_')) {
        debugPrint('⚠️ 게스트 사용자 - 친구 데이터 새로고침 제외');
        friends = [];
        friendRequests = [];
        sentFriendRequests = [];
        isLoading = false;
        notifyListeners();
        return;
      }

      friends = await repository.getMyFriends();
      friendRequests = await repository.getFriendRequests();
      sentFriendRequests = await repository.getSentFriendRequests();
      _lastUpdate = DateTime.now();

      // 온라인 상태 업데이트
      _updateFriendsOnlineStatus();

      debugPrint('✅ 친구 데이터 새로고침 완료');
      debugPrint('👥 친구: ${friends.length}명');
      debugPrint('📥 받은 요청: ${friendRequests.length}개');
      debugPrint('📤 보낸 요청: ${sentFriendRequests.length}개');
      debugPrint('🌐 온라인 사용자: ${onlineUsers.length}명');

      // 각 친구의 온라인 상태 로그 출력
      for (final friend in friends) {
        debugPrint('👤 ${friend.userName}: ${friend.isLogin ? "온라인" : "오프라인"}');
      }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('❌ 친구 데이터 새로고침 실패: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> addFriend(String addId) async {
    // 🔥 성능 모니터링 시작
    PerformanceMonitor().startOperation('addFriend');
    
    try {
      debugPrint('👤 친구 추가 요청: $addId');

      // 🔥 요청 시작 시 에러 메시지 초기화
      errorMessage = null;
      notifyListeners();

      debugPrint('🔄 repository.requestFriend 시작...');
      await repository.requestFriend(addId);
      debugPrint('✅ repository.requestFriend 완료');

      // 🔥 성공 시 즉시 로컬 상태 업데이트 (서버 동기화는 백그라운드에서)
      _optimisticAddSentRequest(addId);
      
      // 🔥 백그라운드에서 서버와 동기화 (UI 블로킹 없음)
      _syncSentRequestsInBackground();

      debugPrint('✅ 친구 추가 요청 완료');

      // 🔥 성공 시 에러 메시지 확실히 초기화
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ 친구 추가 실패: $e');
      debugPrint('❌ 예외 타입: ${e.runtimeType}');
      debugPrint('❌ 예외 스택: ${StackTrace.current}');

      // 🔥 실패 시에도 기존 친구 목록을 유지하기 위해 전체 데이터 다시 로드
      try {
        final newFriends = await repository.getMyFriends();
        final newFriendRequests = await repository.getFriendRequests();
        final newSentFriendRequests = await repository.getSentFriendRequests();

        friends = newFriends;
        friendRequests = newFriendRequests;
        sentFriendRequests = newSentFriendRequests;

        // 온라인 상태 업데이트
        _updateFriendsOnlineStatus();

        debugPrint('✅ 친구 목록 복구 완료');
      } catch (loadError) {
        debugPrint('❌ 친구 목록 복구 실패: $loadError');
      }

      // 예외를 다시 던져서 UI에서 처리하도록 함
      rethrow;
    } finally {
      // 🔥 성능 모니터링 완료
      PerformanceMonitor().endOperation('addFriend');
    }
  }

  /// 🔥 낙관적 업데이트: 보낸 요청 즉시 추가 (서버 응답 대기 없음)
  void _optimisticAddSentRequest(String addId) {
    // 이미 존재하는지 확인
    final existingRequest = sentFriendRequests.firstWhere(
      (request) => request.toUserId == addId,
      orElse: () => SentFriendRequest(
        toUserId: '',
        toUserName: '',
        requestDate: '',
      ),
    );

    if (existingRequest.toUserId.isEmpty) {
      // 새로운 요청 추가 (임시 데이터)
      final newRequest = SentFriendRequest(
        toUserId: addId,
        toUserName: '로딩 중...', // 서버에서 실제 이름을 받아올 때까지 임시
        requestDate: DateTime.now().toIso8601String(),
      );
      
      sentFriendRequests.insert(0, newRequest); // 맨 앞에 추가
      debugPrint('✅ 낙관적 업데이트: 보낸 요청 즉시 추가됨');
    }
  }

  /// 🔥 백그라운드에서 보낸 요청 목록 동기화
  Future<void> _syncSentRequestsInBackground() async {
    try {
      debugPrint('🔄 백그라운드에서 보낸 요청 목록 동기화 시작...');
      final serverSentRequests = await repository.getSentFriendRequests();
      
      // 서버 데이터로 업데이트
      sentFriendRequests = serverSentRequests;
      
      debugPrint('✅ 백그라운드 동기화 완료: ${sentFriendRequests.length}개');
      
      // UI 업데이트 (백그라운드에서)
      notifyListeners();
    } catch (e) {
      debugPrint('❌ 백그라운드 동기화 실패: $e');
    }
  }

  Future<void> acceptRequest(String addId) async {
    FriendRequest? removedRequest;
    try {
      debugPrint('✅ 친구 요청 수락: $addId');
      
      // 🔥 낙관적 업데이트: 즉시 UI에서 요청 제거
      removedRequest = friendRequests.firstWhere(
        (request) => request.fromUserId == addId,
        orElse: () => FriendRequest(
          fromUserId: '',
          fromUserName: '',
          createdAt: '',
        ),
      );
      
      friendRequests.removeWhere((request) => request.fromUserId == addId);
      notifyListeners();
      
      // 🔥 서버 요청 (백그라운드에서)
      await repository.acceptRequest(addId);
      
      // 🔥 백그라운드에서 친구 목록 동기화
      _syncFriendsInBackground();
      
      debugPrint('✅ 친구 요청 수락 완료');
    } catch (e) {
      // 🔥 실패 시 롤백: 제거된 요청을 다시 추가
      if (removedRequest != null && removedRequest.fromUserId.isNotEmpty) {
        friendRequests.add(removedRequest);
        notifyListeners();
      }
      
      errorMessage = e.toString();
      debugPrint('❌ 친구 요청 수락 실패: $e');
      notifyListeners();
      rethrow; // UI에서 에러 처리할 수 있도록 예외 재발생
    }
  }

  Future<void> rejectRequest(String addId) async {
    FriendRequest? removedRequest;
    try {
      debugPrint('❌ 친구 요청 거절: $addId');
      
      // 🔥 낙관적 업데이트: 즉시 UI에서 요청 제거
      removedRequest = friendRequests.firstWhere(
        (request) => request.fromUserId == addId,
        orElse: () => FriendRequest(
          fromUserId: '',
          fromUserName: '',
          createdAt: '',
        ),
      );
      
      friendRequests.removeWhere((request) => request.fromUserId == addId);
      notifyListeners();
      
      // 🔥 서버 요청 (백그라운드에서)
      await repository.rejectRequest(addId);
      
      debugPrint('✅ 친구 요청 거절 완료');
    } catch (e) {
      // 🔥 실패 시 롤백: 제거된 요청을 다시 추가
      if (removedRequest != null && removedRequest.fromUserId.isNotEmpty) {
        friendRequests.add(removedRequest);
        notifyListeners();
      }
      
      errorMessage = e.toString();
      debugPrint('❌ 친구 요청 거절 실패: $e');
      notifyListeners();
      rethrow; // UI에서 에러 처리할 수 있도록 예외 재발생
    }
  }

  /// 🔥 백그라운드에서 친구 목록 동기화
  Future<void> _syncFriendsInBackground() async {
    try {
      debugPrint('🔄 백그라운드에서 친구 목록 동기화 시작...');
      final serverFriends = await repository.getMyFriends();
      
      // 서버 데이터로 업데이트
      friends = serverFriends;
      
      debugPrint('✅ 백그라운드 친구 목록 동기화 완료: ${friends.length}명');
      
      // UI 업데이트 (백그라운드에서)
      notifyListeners();
    } catch (e) {
      debugPrint('❌ 백그라운드 친구 목록 동기화 실패: $e');
    }
  }

  Future<void> deleteFriend(String addId) async {
    try {
      debugPrint('🗑️ 친구 삭제: $addId');
      await repository.deleteFriend(addId);
      
      // 즉시 UI 업데이트를 위해 로컬에서 해당 친구 제거
      friends.removeWhere((friend) => friend.userId == addId);
      notifyListeners();
      
      // 백그라운드에서 서버와 동기화
      await quickUpdate();
      debugPrint('✅ 친구 삭제 완료');
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('❌ 친구 삭제 실패: $e');
      notifyListeners();
      rethrow; // UI에서 에러 처리할 수 있도록 예외 재발생
    }
  }

  Future<void> cancelSentRequest(String friendId) async {
    try {
      debugPrint('🚫 친구 요청 취소: $friendId');
      await repository.cancelSentRequest(friendId);
      
      // 즉시 UI 업데이트를 위해 로컬에서 해당 요청 제거
      sentFriendRequests.removeWhere((request) => request.toUserId == friendId);
      notifyListeners();
      
      // 백그라운드에서 서버와 동기화
      await quickUpdate();
      debugPrint('✅ 친구 요청 취소 완료');
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('❌ 친구 요청 취소 실패: $e');
      notifyListeners();
      rethrow; // UI에서 에러 처리할 수 있도록 예외 재발생
    }
  }

  Future<Friend?> getFriendInfo(String friendId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      return await repository.getFriendInfo(friendId);
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('❌ 친구 정보 조회 실패: $e');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void stopRealTimeUpdates() {
    debugPrint('⏸️ 실시간 친구 업데이트 중지');
    _isRealTimeEnabled = false;
    _updateTimer?.cancel();
  }

  void resumeRealTimeUpdates() {
    debugPrint('▶️ 실시간 친구 업데이트 재시작');
    _isRealTimeEnabled = true;
    _startRealTimeUpdates();
    quickUpdate();
  }

  String get lastUpdateTime {
    if (_lastUpdate == null) return '업데이트 없음';

    final now = DateTime.now();
    final diff = now.difference(_lastUpdate!);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}초 전';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else {
      return '${diff.inHours}시간 전';
    }
  }

  // 📶 특정 친구의 온라인 상태 확인 (서버 데이터 우선)
  bool isFriendOnline(String userId) {
    // 1. 친구 목록에서 해당 친구 찾기 (서버 데이터 우선)
    final friend = friends.firstWhere(
      (f) => f.userId == userId,
      orElse: () => Friend(
        userId: userId,
        userName: '알 수 없음',
        profileImage: '',
        phone: '',
        isLogin: false,
        lastLocation: '',
        isLocationPublic: false,
      ),
    );

    // 2. 서버 데이터 기반 온라인 상태 반환
    return friend.isLogin;
  }

  // 📊 웹소켓 연결 상태 정보
  String get connectionStatus {
    if (isWebSocketConnected) {
      return '실시간 연결됨';
    } else {
      return '폴링 모드';
    }
  }

  // 🔍 디버깅용 메서드
  void debugPrintStatus() {
    debugPrint('🔍 FriendsController 상태 디버깅');
    debugPrint('🔍 친구 수: ${friends.length}');
    debugPrint('🔍 온라인 사용자 수: ${onlineUsers.length}');
    debugPrint('🔍 웹소켓 연결 상태: $isWebSocketConnected');
    debugPrint('🔍 실시간 업데이트 활성화: $_isRealTimeEnabled');

    for (int i = 0; i < friends.length; i++) {
      final friend = friends[i];
      debugPrint(
        '🔍 친구 ${i + 1}: ${friend.userName} (${friend.userId}) - 온라인: ${friend.isLogin}',
      );
    }
  }

  // 🔍 웹소켓 연결 테스트
  void testWebSocketConnection() {
    debugPrint('🔍 웹소켓 연결 테스트 시작');
    _wsService.testConnection();

    // 3초 후 상태 확인
    Future.delayed(const Duration(seconds: 3), () {
      debugPrint('🔍 웹소켓 연결 테스트 결과');
      debugPrintStatus();
    });
  }

  // 🔍 서버 데이터 테스트
  void testServerData() async {
    debugPrint('🔍 서버 데이터 테스트 시작');

    try {
      final newFriends = await repository.getMyFriends();
      debugPrint('🔍 서버에서 받은 친구 목록: ${newFriends.length}명');

      for (int i = 0; i < newFriends.length; i++) {
        final friend = newFriends[i];
        debugPrint(
          '🔍 ${friend.userName} (${friend.userId}): 온라인=${friend.isLogin}',
        );
      }

      // 서버 데이터로 온라인 상태 초기화
      _initializeOnlineStatusFromServer();
      debugPrint('🔍 서버 데이터 테스트 완료');
    } catch (e) {
      debugPrint('❌ 서버 데이터 테스트 실패: $e');
    }
  }

  @override
  void dispose() {
    debugPrint('🛑 FriendsController 정리 중...');

    // 🔥 타이머 정리
    _updateTimer?.cancel();
    _updateTimer = null;

    // 🔥 웹소켓 구독 정리
    try {
      _wsMessageSubscription?.cancel();
      _wsConnectionSubscription?.cancel();
      _wsOnlineUsersSubscription?.cancel();
      debugPrint('✅ 웹소켓 구독 정리 완료');
    } catch (e) {
      debugPrint('⚠️ 웹소켓 구독 정리 중 오류: $e');
    }

    // 🔥 글로벌 웹소켓은 해제하지 않음 (앱 전역에서 공유됨)
    // 기존: _wsService.disconnect(); → 제거
    try {
      debugPrint('✅ 웹소켓 연결 유지 (FriendsController dispose)');
    } catch (e) {
      debugPrint('⚠️ 웹소켓 연결 유지 처리 중 오류: $e');
    }

    super.dispose();
    debugPrint('✅ FriendsController 정리 완료');
  }
}
