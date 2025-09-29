// lib/friends/friends_controller.dart - 웹소켓 연동 추가
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
    debugPrint('🔥🔥🔥 FriendsController 생성자 호출됨 🔥🔥🔥');
    debugPrint('🔍 내 ID: $myId');
    debugPrint('🔍 Repository: $repository');
    
    // 🔥 게스트 사용자는 웹소켓 초기화 제외
    if (!myId.startsWith('guest_')) {
      debugPrint('✅ 일반 사용자 - 웹소켓 초기화 시작');
      // 🔥 즉시 스트림 구독 시작
      _startStreamSubscription();
      _initializeWebSocket();
    } else {
      debugPrint('⚠️ 게스트 사용자 - 웹소켓 초기화 제외');
    }
    
    debugPrint('🔥🔥🔥 FriendsController 생성자 완료 🔥🔥🔥');
  }

  List<Friend> friends = [];
  List<FriendRequest> friendRequests = [];
  List<SentFriendRequest> sentFriendRequests = [];
  List<String> onlineUsers = [];
  bool isLoading = false;
  bool isRefreshing = false; // 🔥 새로고침 버튼 전용 로딩 상태
  String? errorMessage;
  bool isWebSocketConnected = false;
  
  // 🔥 실시간 상태 우선 메커니즘
  Map<String, bool> _realTimeStatusCache = {}; // 친구별 실시간 상태 캐시
  Map<String, DateTime> _statusTimestamp = {}; // 상태 변경 시간 기록

  Timer? _updateTimer;
  StreamSubscription? _wsMessageSubscription;
  StreamSubscription? _wsConnectionSubscription;
  StreamSubscription? _wsOnlineUsersSubscription;

  // 🔥 플랫폼별 최적화된 업데이트 간격 (서버 부하 감소를 위해 조정)
  Duration get _updateInterval {
    if (Platform.isAndroid) {
      return const Duration(seconds: 30); // 안드로이드: 1초 → 30초
    } else if (Platform.isIOS) {
      return const Duration(seconds: 30); // iOS: 2초 → 30초
    } else if (Platform.isWindows) {
      return const Duration(seconds: 30); // Windows: 500ms → 30초
    } else if (Platform.isMacOS) {
      return const Duration(seconds: 30); // macOS: 1초 → 30초
    } else if (Platform.isLinux) {
      return const Duration(seconds: 30); // Linux: 800ms → 30초
    }
    return const Duration(seconds: 30); // 기본값: 1초 → 30초
  }
  
  DateTime? _lastUpdate;
  bool _isRealTimeEnabled = true;

  bool get isRealTimeEnabled => _isRealTimeEnabled && isWebSocketConnected;

  // 🔥 스트림 구독 강제 시작 메서드
  void _startStreamSubscription() {
    debugPrint('🔥🔥🔥 스트림 구독 강제 시작! 🔥🔥🔥');
    
    // 기존 구독이 있다면 취소
    _wsMessageSubscription?.cancel();
    
    // 즉시 스트림 구독 시도
    _wsMessageSubscription = _wsService.messageStream.listen(
      (message) {
        debugPrint('🔥🔥🔥 강제 구독된 스트림에서 메시지 수신! 🔥🔥🔥');
        debugPrint('📡 강제 구독 스트림 메시지: $message');
        _handleWebSocketMessage(message);
      },
      onError: (error) {
        debugPrint('❌ 강제 구독된 웹소켓 메시지 스트림 오류: $error');
        // 에러 발생 시 재구독 시도
        Future.delayed(const Duration(seconds: 1), () {
          debugPrint('🔄 에러 후 재구독 시도');
          _startStreamSubscription();
        });
      },
      onDone: () {
        debugPrint('🔚 강제 구독된 웹소켓 메시지 스트림 완료됨');
        // 완료 시 재구독 시도
        Future.delayed(const Duration(seconds: 1), () {
          debugPrint('🔄 완료 후 재구독 시도');
          _startStreamSubscription();
        });
      },
    );
    
    debugPrint('✅ 강제 스트림 구독 완료');
    
    // 주기적으로 구독 상태 확인
    Timer.periodic(const Duration(seconds: 10), (timer) {
      // 스트림이 닫혔거나 구독이 중지된 경우 재구독
      if (_wsMessageSubscription == null || _wsMessageSubscription!.isPaused == true) {
        debugPrint('🔄 주기적 재구독 실행');
        _startStreamSubscription();
      }
    });
  }

  // 🔌 웹소켓 초기화
  Future<void> _initializeWebSocket() async {
    debugPrint('🔥🔥🔥 FriendsController _initializeWebSocket 호출됨 🔥🔥🔥');
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
    
    // 🔥 웹소켓 연결 완료 후 스트림 구독
    await Future.delayed(const Duration(milliseconds: 500)); // 연결 안정화 대기
    
    // 웹소켓 이벤트 리스너 설정
    debugPrint('🔌 웹소켓 메시지 스트림 리스너 등록 시작');
    debugPrint('🔍 웹소켓 연결 상태: ${_wsService.isConnected}');
    debugPrint('🔍 메시지 스트림 사용 가능 여부: ${_wsService.messageStream != null}');
    
    // 🔥 추가 스트림 구독 시도 (기존 구독이 있어도 추가로 구독)
    debugPrint('🔄 추가 스트림 구독 시도');
    _startStreamSubscription();
    
    // 🔥 웹소켓 연결 완료 후 친구 상태 동기화 요청
    Future.delayed(const Duration(milliseconds: 1000), () async {
      if (_wsService.isConnected) {
        debugPrint('🧪 연결 테스트: 친구 상태 동기화 요청');
        await _refreshFriendStatusFromAPI();
      }
    });
    
    // 🔥 추가 연결 및 상태 구독
    debugPrint('🔌 연결 상태 및 온라인 사용자 스트림 구독 중...');
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

  // 📨 웹소켓 메시지 처리 (최적화된 버전)
  void _handleWebSocketMessage(Map<String, dynamic> message) {
    debugPrint('🔥🔥🔥 _handleWebSocketMessage 호출됨! FriendsController에 메시지 도착 🔥🔥🔥');
    debugPrint('📨 받은 메시지 전체: $message');
    
    // 🔥 게스트 사용자는 웹소켓 메시지 처리 제외
    if (myId.startsWith('guest_')) {
      debugPrint('⚠️ 게스트 사용자 - 메시지 처리 제외');
      return;
    }

    // 🔥 메시지 유효성 검사
    final messageType = message['type'] as String?;
    if (messageType == null) {
      debugPrint('⚠️ 유효하지 않은 웹소켓 메시지 - type 필드 없음');
      debugPrint('📨 전체 메시지: $message');
      return;
    }

    debugPrint('📨 메시지 타입: $messageType');
    debugPrint('📨 메시지 내용 상세: $message');

    // 중요한 메시지만 로그 출력
    if (kDebugMode && _shouldLogMessage(messageType)) {
      debugPrint('📨 중요한 웹소켓 메시지 처리 중: $messageType');
    }

    try {
      switch (messageType) {
        case 'new_friend_request':
        case 'friend_request_accepted':
        case 'friend_request_rejected':
        case 'friend_deleted':
          // 친구 관련 이벤트 발생 시 즉시 데이터 업데이트
          quickUpdate();
          break;

        case 'friend_status_change':
          debugPrint('🔥🔥🔥 friend_status_change 메시지 처리 시작! 🔥🔥🔥');
          debugPrint('📨 friend_status_change 메시지: $message');
          _handleFriendStatusChange(message);
          debugPrint('🔥🔥🔥 friend_status_change 메시지 처리 완료! 🔥🔥🔥');
          break;

        case 'Login_Status':
          // 이제 Login_Status는 friend_status_change로 변환되어 전달되므로
          // 중복 처리를 방지하기 위해 로깅만 함
          debugPrint('🔥 Login_Status 메시지 감지됨 - friend_status_change로 변환되어 별도 처리됨');
          break;

        case 'friend_location_update':
          _handleFriendLocationUpdate(message);
          break;

        case 'real_time_status_change':
          // 🔥 실시간 상태 변경 직접 처리
          final userId = message['userId'];
          final isOnline = message['isOnline'];
          final source = message['source'];
          
          debugPrint('🔥🔥🔥 실시간 상태 변경 이벤트 수신 🔥🔥🔥');
          debugPrint('📱 친구 ID: $userId');
          debugPrint('📱 상태: $isOnline');
          debugPrint('📱 소스: $source');
          
          _updateFriendStatusImmediately(userId, isOnline);
          break;

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
          _handleOnlineUsersUpdateMessage(message);
          break;

        case 'registered':
          // 등록 확인은 특별한 처리 없음
          break;

        case 'user_login':
          _handleUserLogin(message);
          break;

        case 'user_logout':
          _handleUserLogout(message);
          break;

        case 'friend_logged_in':
          _handleFriendLoggedIn(message);
          break;

        case 'friend_logged_out':
          _handleFriendLoggedOut(message);
          break;


        case 'heartbeat_response':
          // 하트비트 응답은 특별한 처리 없음
          break;

        case 'location_share_status_change':
          _handleLocationShareStatusChange(message);
          break;

        case 'friend_status_response':
          _handleFriendStatusResponse(message);
          break;

        case 'friend_list_with_status':
          _handleFriendListWithStatus(message);
          break;

        default:
          if (kDebugMode) {
            debugPrint('⚠️ 알 수 없는 웹소켓 메시지 타입: $messageType');
          }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 웹소켓 메시지 처리 중 오류: $e');
      }
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

  // 🔌 연결 상태 변경 처리 (개선된 버전)
  void _handleConnectionChange(bool isConnected) {
    final previousState = isWebSocketConnected;
    isWebSocketConnected = isConnected;
    debugPrint('🔌 웹소켓 연결 상태 변경: $previousState → $isConnected');

    if (isConnected) {
      debugPrint('✅ 웹소켓 연결됨 - 실시간 모드 활성화');
      
      // 🔥 폴링 타이머 완전 정리 (즉시 중지)
      _stopPollingCompletely();
      
      // 🔥 웹소켓 연결 시 초기 데이터 로드 및 동기화
      _initializeWithWebSocket();
      
      // 🔥 웹소켓 연결 시 /myfriend API로 친구 상태 새로고침
      debugPrint('📡 웹소켓 연결됨 - /myfriend API로 친구 상태 새로고침');
      _refreshFriendStatusFromAPI();
      
    } else {
      debugPrint('❌ 웹소켓 연결 끊어짐 - 폴링 모드로 전환');
      
      // 🔥 웹소켓이 끊어지면 폴링 재시작 (30초 간격)
      _startRealTimeUpdates();
      
      debugPrint('✅ 폴링 모드 활성화 완료 (30초 간격)');
    }

    notifyListeners();
  }

  // 🔥 폴링 완전 중지 메서드 (개선된 버전)
  void _stopPollingCompletely() {
    debugPrint('🔄 폴링 타이머 완전 중지 중...');
    
    if (_updateTimer != null) {
      _updateTimer!.cancel();
      _updateTimer = null;
      debugPrint('✅ 폴링 타이머 완전 정리 완료');
    } else {
      debugPrint('ℹ️ 폴링 타이머가 이미 중지됨');
    }
    
    // 실시간 업데이트 상태도 중지
    _isRealTimeEnabled = false;
    debugPrint('✅ 실시간 업데이트 상태 중지 완료');
  }

  // 🔥 웹소켓 연결 시 초기화 및 동기화 (개선된 버전)
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

      // 🔥 6. 웹소켓 연결 후 즉시 친구 상태 동기화 요청
      if (isWebSocketConnected) {
        debugPrint('📡 웹소켓 연결 완료 - 즉시 친구 상태 동기화 요청');
        _requestFriendStatusSync();
        
        // 추가로 /myfriend API로 친구 상태 새로고침
        await _refreshFriendStatusFromAPI();
        
        // 🔥 즉시 동기화 실행 (지연 문제 해결)
        await _immediateSync();
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

  // 🔥 서버 데이터와 웹소켓 데이터 동기화 (수정된 버전)
  void _syncWithServerData() {
    debugPrint('🔄 서버 데이터와 웹소켓 데이터 동기화 시작');
    debugPrint('🔄 웹소켓 연결 상태: $isWebSocketConnected');

    bool hasChanges = false;

    // 🔥 수정된 로직: 웹소켓 상태가 있으면 웹소켓 데이터와 서버 데이터를 모두 고려
    for (int i = 0; i < friends.length; i++) {
      final friend = friends[i];
      final isOnlineInServer = friend.isLogin;
      final isOnlineInWebSocket = onlineUsers.contains(friend.userId);

      // 🔥 수정된 로직: 웹소켓이 연결되어 있으면 웹소켓 데이터를 믿되, 서버 데이터와 충돌시 웹소켓 우선
      // 만약 웹소켓에서 온라인이지만 서버에서 오프라인이면, 웹소켓 우선 (실시간 상태)
      // 만약 웹소켓에서 오프라인이지만 서버에서 온라인이면, 웹소켓 우선 (실시간 연결 끊김)
      bool shouldBeOnline;
      if (isWebSocketConnected) {
        // 웹소켓이 연결된 경우: 웹소켓 온라인 상태가 더 정확하므로 우선시
        // 단, 새로운 친구가 서버에서만 온라인 표시된 경우에는 웹소켓 온라인 목록을 업데이트
        shouldBeOnline = isOnlineInWebSocket;
        
        // 서버에서 온라인이지만 웹소켓 목록에 없는 경우 추가
        if (isOnlineInServer && !isOnlineInWebSocket && !onlineUsers.contains(friend.userId)) {
          onlineUsers.add(friend.userId);
          shouldBeOnline = true;
          debugPrint('📡 서버 온라인 친구를 웹소켓 목록에 추가: ${friend.userName}');
        }
      } else {
        // 웹소켓이 끊어진 경우: 서버 데이터만 믿음
        shouldBeOnline = isOnlineInServer;
      }
      
      if (friend.isLogin != shouldBeOnline) {
        friends[i] = Friend(
          userId: friend.userId,
          userName: friend.userName,
          profileImage: friend.profileImage,
          phone: friend.phone,
          isLogin: shouldBeOnline,
          lastLocation: friend.lastLocation,
          isLocationPublic: friend.isLocationPublic,
        );
        
        // 온라인 사용자 목록도 동기화
        if (shouldBeOnline && !onlineUsers.contains(friend.userId)) {
          onlineUsers.add(friend.userId);
        } else if (!shouldBeOnline && onlineUsers.contains(friend.userId)) {
          onlineUsers.remove(friend.userId);
        }
        
        hasChanges = true;
        debugPrint('✅ ${friend.userName} 상태 동기화: ${friend.isLogin} → $shouldBeOnline (웹소켓: $isOnlineInWebSocket, 서버: $isOnlineInServer)');
      }
    }

    if (hasChanges) {
      debugPrint('🔄 동기화 완료 - 변경사항 있음');
      notifyListeners();
    } else {
      debugPrint('🔄 동기화 완료 - 변경사항 없음');
    }
  }

  // 📶 친구 상태 변경 처리 (강화된 버전)
  void _handleFriendStatusChange(Map<String, dynamic> message) {
    debugPrint('🔥🔥🔥 _handleFriendStatusChange 메서드 시작! 🔥🔥🔥');
    debugPrint('📨 받은 메시지: $message');
    
    final userId = message['userId'];
    final isOnlineRaw = message['isOnline'] ?? message['is_login'] ?? message['status'] ?? false;
    final isOnline = isOnlineRaw == true || isOnlineRaw == "true" || isOnlineRaw == 1;
    final messageText = message['message'];
    final timestamp = message['timestamp'];

    debugPrint('🔥🔥🔥 친구 상태 변경 핸들러 세부 정보 🔥🔥🔥');
    debugPrint('📶 친구 ID: $userId');
    debugPrint('📶 원본 값: $isOnlineRaw');
    debugPrint('📶 변환된 온라인 상태: $isOnline');
    debugPrint('📶 메시지: $messageText');
    debugPrint('📶 타임스탬프: $timestamp');

    // 🔥 강제로 온라인 사용자 목록 업데이트 (웹소켓 상태 우선)
    debugPrint('🔥 웹소켓 상태 변경 처리: $userId = ${isOnline ? '온라인' : '오프라인'}');
    if (isOnline) {
      if (!onlineUsers.contains(userId)) {
        onlineUsers.add(userId);
        debugPrint('✅ 온라인 사용자 목록에 추가: $userId');
        debugPrint('🔥 업데이트된 온라인 사용자 목록: ${onlineUsers.join(', ')}');
      }
    } else {
      if (onlineUsers.contains(userId)) {
        onlineUsers.remove(userId);
        debugPrint('✅ 온라인 사용자 목록에서 제거: $userId');
        debugPrint('🔥 업데이트된 온라인 사용자 목록: ${onlineUsers.join(', ')}');
      }
    }

    // 🔥 강제로 친구 목록에서 해당 사용자의 상태 업데이트
    bool found = false;
    for (int i = 0; i < friends.length; i++) {
      if (friends[i].userId == userId) {
        found = true;
        final oldStatus = friends[i].isLogin;
        final friendName = friends[i].userName;
        
        // 🔥 강제로 상태 업데이트 (조건 없이)
        friends[i] = Friend(
          userId: friends[i].userId,
          userName: friends[i].userName,
          profileImage: friends[i].profileImage,
          phone: friends[i].phone,
          isLogin: isOnline, // 🔥 강제로 상태 변경
          lastLocation: friends[i].lastLocation,
          isLocationPublic: friends[i].isLocationPublic,
        );

        debugPrint('✅ $friendName 상태 강제 변경: ${oldStatus ? '온라인' : '오프라인'} → ${isOnline ? '온라인' : '오프라인'}');
        break;
      }
    }

    if (!found) {
      debugPrint('⚠️ 친구 목록에서 해당 사용자를 찾을 수 없음: $userId');
      debugPrint('⚠️ 현재 친구 목록 (${friends.length}명): ${friends.map((f) => '${f.userId}(${f.userName})').join(', ')}');
      debugPrint('⚠️ 온라인 사용자 목록: ${onlineUsers.join(', ')}');
      
      // 🔥 친구가 목록에 없으면 친구 목록 새로고침
      debugPrint('🔄 친구 목록 새로고침 필요 - 친구 목록 갤러리 로드');
      Future.microtask(() async {
        try {
          final newFriends = await repository.getMyFriends();
          friends = newFriends;
          notifyListeners();
          debugPrint('✅ 친구 목록 새로고침 완료');
        } catch (e) {
          debugPrint('❌ 친구 목록 새로고침 실패: $e');
        }
      });
    }

    // 🔥 즉시 UI 업데이트 (실시간 반영)
    debugPrint('🔥🔥🔥 친구 상태 변경으로 인한 즉시 UI 업데이트 시작 🔥🔥🔥');
    debugPrint('🔥 웹소켓 상태 변경 우선 - 서버 동기화는 잠시 후에 실행');
    
    // 🔥 웹소켓 연결 상태 확인 및 업데이트
    final actualWsConnected = _wsService.isConnected;
    if (actualWsConnected != isWebSocketConnected) {
      debugPrint('📡 친구 상태 변경 중 웹소켓 상태 동기화: $isWebSocketConnected → $actualWsConnected');
      isWebSocketConnected = actualWsConnected;
    }
    
    // 🔥 강제 UI 업데이트 먼저 호출
    debugPrint('🔥🔥🔥 _forceUIUpdate 호출! 🔥🔥🔥');
    _forceUIUpdate();
    debugPrint('🔥🔥🔥 _forceUIUpdate 완료! 🔥🔥🔥');
    
    // 🔥 실시간 웹소켓 상태 우선 유지를 위해 서버 동기화 지연 (웹소켓 상태 보호)
    Future.delayed(const Duration(seconds: 2), () async {
      debugPrint('🔥 2초 후 서버 동기화 시작 (웹소켓 상태 우선 후)');
      await _refreshFriendStatusFromAPI();
    });
    
    // 🔥 폴백 확인 예약 (3초 후 상태 재확인)
    _scheduleFallbackCheck(userId, isOnline);
    
    _showFriendStatusNotification(userId, isOnline);
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

  // 🔥 새로 추가: 친구 로그인 처리 메서드 (강화된 버전)
  void _handleFriendLoggedIn(Map<String, dynamic> message) {
    final loggedInUserId = message['userId'];
    final messageText = message['message'];
    final timestamp = message['timestamp'];
    
    if (kDebugMode) {
      debugPrint('👤 친구 로그인 감지: $loggedInUserId');
      debugPrint('👤 메시지: $messageText');
      debugPrint('👤 타임스탬프: $timestamp');
    }

    // 🔥 실시간으로 즉시 온라인 사용자 목록에 추가
    if (!onlineUsers.contains(loggedInUserId)) {
      onlineUsers.add(loggedInUserId);
      debugPrint('✅ 온라인 사용자 목록에 추가: $loggedInUserId');
    }

    // 🔥 친구 목록에서 해당 사용자의 상태를 즉시 온라인으로 업데이트
    bool found = false;
    for (int i = 0; i < friends.length; i++) {
      if (friends[i].userId == loggedInUserId) {
        found = true;
        final oldStatus = friends[i].isLogin;
        final friendName = friends[i].userName;
        
        // 🔥 강제로 온라인으로 설정 (조건 없이)
        friends[i] = Friend(
          userId: friends[i].userId,
          userName: friends[i].userName,
          profileImage: friends[i].profileImage,
          phone: friends[i].phone,
          isLogin: true, // 🔥 무조건 온라인으로 변경
          lastLocation: friends[i].lastLocation,
          isLocationPublic: friends[i].isLocationPublic,
        );
        debugPrint('✅ $friendName 상태를 강제로 온라인으로 변경 ($oldStatus → true)');
        break;
      }
    }

    if (!found) {
      debugPrint('⚠️ 친구 목록에서 해당 사용자를 찾을 수 없음: $loggedInUserId');
      debugPrint('⚠️ 현재 친구 목록 (${friends.length}명): ${friends.map((f) => '${f.userId}(${f.userName})').join(', ')}');
      debugPrint('⚠️ 온라인 사용자 목록: ${onlineUsers.join(', ')}');

      // 🔥 친구가 목록에 없으면 친구 목록 새로고침
      debugPrint('🔄 친구 목록 새로고침 필요 - 친구 목록 갤러리 로드');
      Future.microtask(() async {
        try {
          final newFriends = await repository.getMyFriends();
          friends = newFriends;
          notifyListeners();
          debugPrint('✅ 친구 목록 새로고침 완료');
        } catch (e) {
          debugPrint('❌ 친구 목록 새로고침 실패: $e');
        }
      });
    }

    // 🔥 즉시 UI 업데이트 (지연 제거)
    debugPrint('🔄 친구 로그인으로 인한 즉시 UI 업데이트');
    
    // 🔥 강제 UI 업데이트 먼저 호출
    _forceUIUpdate();
    
    // 🔥 폴백 확인 예약 (3초 후 로그인 상태 재확인)
    _scheduleFallbackCheck(loggedInUserId, true);
    
    _showFriendStatusNotification(loggedInUserId, true);
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
    
    // 🔥 즉시 UI 업데이트 (실시간 반영)
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

  // 🔥 강화된 강제 UI 업데이트 메서드
  void _forceUIUpdate() {
    debugPrint('🔥🔥🔥 _forceUIUpdate 메서드 시작! 🔥🔥🔥');
    try {
      debugPrint('\n🔄 🔥🔥🔥 강화된 강제 UI 업데이트 시작 🔥🔥🔥');
      debugPrint('🔄 현재 친구 수: ${friends.length}명');
      debugPrint('🔄 현재 온라인 사용자 수: ${onlineUsers.length}명');
      
      // 현재 시간을 업데이트하여 UI 강제 새로고침 트리거
      _lastUpdate = DateTime.now();
      
      // 🔥 친구 목록을 완전히 새로 생성하여 참조 변경을 강화
      final currentFriends = friends;
      final updatedFriends = <Friend>[];
      
      for (int i = 0; i < currentFriends.length; i++) {
        final friend = currentFriends[i];
        updatedFriends.add(Friend(
          userId: friend.userId,
          userName: friend.userName,
          profileImage: friend.profileImage,
          phone: friend.phone,
          isLogin: friend.isLogin,
          lastLocation: friend.lastLocation,
          isLocationPublic: friend.isLocationPublic,
        ));
      }
      friends = updatedFriends;
      
      // 🔥 즉시 여러 번 UI 업데이트 시도
      notifyListeners();
      
      // 🔥 마이크로태스크로 한 번 더 업데이트
      Future.microtask(() {
        notifyListeners();
        debugPrint('🔄 마이크로태스크 UI 업데이트 완료');
      });
      
      // 🔥 디버깅: 모든 친구의 상태 출력
      for (int i = 0; i < friends.length; i++) {
        final friend = friends[i];
        final statusIcon = friend.isLogin ? '🟢' : '🔴';
        final statusText = friend.isLogin ? '온라인' : '오프라인';
        debugPrint('👤 친구 $statusIcon ${friend.userName}(${friend.userId}): $statusText');
      }
      
      debugPrint('✅ 🔥🔥🔥 강화된 강제 UI 업데이트 완료 🔥🔥🔥\n');
      
    } catch (e) {
      debugPrint('❌ 강화된 강제 UI 업데이트 실패: $e');
    }
  }

  // 🔥 친구 상태 검증 메서드 (디버깅용)
  void _verifyFriendStatus(String userId, bool expectedStatus) {
    try {
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
      
      final isOnlineInList = onlineUsers.contains(userId);
      
      debugPrint('🔍 친구 상태 검증: ${friend.userName} ($userId)');
      debugPrint('🔍 예상 상태: ${expectedStatus ? '온라인' : '오프라인'}');
      debugPrint('🔍 실제 상태: ${friend.isLogin ? '온라인' : '오프라인'}');
      debugPrint('🔍 온라인 목록 포함: $isOnlineInList');
      
      // 상태가 일치하지 않으면 강제 수정
      if (friend.isLogin != expectedStatus) {
        debugPrint('⚠️ 상태 불일치 감지 - 강제 수정');
        for (int i = 0; i < friends.length; i++) {
          if (friends[i].userId == userId) {
            friends[i] = Friend(
              userId: friends[i].userId,
              userName: friends[i].userName,
              profileImage: friends[i].profileImage,
              phone: friends[i].phone,
              isLogin: expectedStatus,
              lastLocation: friends[i].lastLocation,
              isLocationPublic: friends[i].isLocationPublic,
            );
            break;
          }
        }
        notifyListeners();
      }
      
      // 온라인 목록도 수정
      if (expectedStatus && !isOnlineInList) {
        onlineUsers.add(userId);
        debugPrint('✅ 온라인 목록에 추가: $userId');
        notifyListeners();
      } else if (!expectedStatus && isOnlineInList) {
        onlineUsers.remove(userId);
        debugPrint('✅ 온라인 목록에서 제거: $userId');
        notifyListeners();
      }
      
    } catch (e) {
      debugPrint('❌ 친구 상태 검증 중 오류: $e');
    }
  }

  // 🔥 웹소켓 연결 상태 재확인 및 복구 메서드 (적극적 재연결)
  Future<void> _checkAndRecoverWebSocketConnection() async {
    try {
      debugPrint('🔍 웹소켓 연결 상태 재확인 중...');
      
      // 현재 웹소켓 연결 상태 확인
      final currentConnectionStatus = _wsService.isConnected;
      debugPrint('🔍 현재 웹소켓 연결 상태: $currentConnectionStatus');
      debugPrint('🔍 컨트롤러의 웹소켓 연결 상태: $isWebSocketConnected');
      
      // 🔥 웹소켓이 연결되지 않았으면 적극적으로 재연결 시도
      if (!currentConnectionStatus && !myId.startsWith('guest_')) {
        debugPrint('🔄 웹소켓 연결 끊어짐 - 적극적 재연결 시도');
        try {
          await _wsService.connect(myId);
          await Future.delayed(const Duration(milliseconds: 100)); // 연결 안정화 대기
          
          if (_wsService.isConnected) {
            debugPrint('✅ 웹소켓 재연결 성공');
            isWebSocketConnected = true;
            // _requestOnlineUsers(); // 서버에서 지원하지 않는 메서드 제거
            
            // /myfriend API로 친구 상태 새로고침
            debugPrint('📡 웹소켓 재연결 성공 - /myfriend API로 친구 상태 새로고침');
            _refreshFriendStatusFromAPI();
            notifyListeners();
            return;
          }
        } catch (e) {
          debugPrint('❌ 웹소켓 재연결 실패: $e');
        }
      }
      
      // 상태가 일치하지 않으면 동기화
      if (currentConnectionStatus != isWebSocketConnected) {
        debugPrint('🔄 웹소켓 연결 상태 동기화: $isWebSocketConnected → $currentConnectionStatus');
        isWebSocketConnected = currentConnectionStatus;
        
        if (currentConnectionStatus) {
          debugPrint('✅ 웹소켓 연결 복구됨 - 온라인 사용자 목록 재요청');
          // _requestOnlineUsers(); // 서버에서 지원하지 않는 메서드 제거
          
          // /myfriend API로 친구 상태 새로고침
          debugPrint('📡 웹소켓 연결 복구됨 - /myfriend API로 친구 상태 새로고침');
          _refreshFriendStatusFromAPI();
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

  // 🔥 웹소켓을 통한 친구 상태 동기화 요청
  void _requestFriendStatusSync() {
    try {
      debugPrint('📡 웹소켓을 통한 친구 상태 동기화 요청');
      
      if (!isWebSocketConnected) {
        debugPrint('⚠️ 웹소켓이 연결되지 않음 - 동기화 요청 불가');
        return;
      }

      // 서버에 친구 상태 동기화 요청 메시지 전송
      _wsService.sendMessage({
        'type': 'request_friend_status',
        'userId': myId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('✅ 친구 상태 동기화 요청 전송 완료');
    } catch (e) {
      debugPrint('❌ 친구 상태 동기화 요청 실패: $e');
    }
  }

  // 🔥 /myfriend API를 사용한 친구 상태 새로고침 메서드
  Future<void> _refreshFriendStatusFromAPI() async {
    try {
      debugPrint('📡 /myfriend API를 사용한 친구 상태 새로고침 시작');
      
      // 🔥 게스트 사용자는 API 호출 제외
      if (myId.startsWith('guest_')) {
        debugPrint('⚠️ 게스트 사용자 - 친구 상태 새로고침 제외');
        return;
      }

      // /myfriend API를 사용하여 최신 친구 상태 조회
      final newFriends = await repository.refreshFriendStatus();
      
      // 기존 친구 목록과 비교하여 상태 변경 감지
      bool hasStatusChanges = false;
      for (int i = 0; i < newFriends.length; i++) {
        final newFriend = newFriends[i];
        final existingFriend = friends.firstWhere(
          (f) => f.userId == newFriend.userId,
          orElse: () => Friend(
            userId: '',
            userName: '',
            profileImage: '',
            phone: '',
            isLogin: false,
            lastLocation: '',
            isLocationPublic: false,
          ),
        );
        
        if (existingFriend.userId.isNotEmpty) {
          // 🔥 웹소켓 상태와 API 상태 비교 - 웹소켓 상태 우선
          final websocketStatus = onlineUsers.contains(newFriend.userId);
          final apiStatus = newFriend.isLogin;
          
          // 🔥 웹소켓과 API 상태가 충돌하면 웹소켓 상태 우선 적용
          if (websocketStatus != apiStatus) {
            debugPrint('🔥 상태 충돌 감지: ${newFriend.userName} - 웹소켓: ${websocketStatus}, API: ${apiStatus}');
            debugPrint('🔥 웹소켓 상태 우선 적용: ${websocketStatus ? '온라인' : '오프라인'}');
            
            // 새로운 Friend 객체 생성하여 상태 변경
            newFriends[i] = Friend(
              userId: newFriend.userId,
              userName: newFriend.userName,
              profileImage: newFriend.profileImage,
              phone: newFriend.phone,
              isLogin: websocketStatus, // 웹소켓 상태 우선 적용
              lastLocation: newFriend.lastLocation,
              isLocationPublic: newFriend.isLocationPublic,
            );
            hasStatusChanges = true;
          } else if (existingFriend.isLogin != apiStatus) {
            // 일반적인 상태 변경
            hasStatusChanges = true;
            debugPrint('🔄 ${newFriend.userName} 상태 변경: ${existingFriend.isLogin ? '온라인' : '오프라인'} → ${newFriend.isLogin ? '온라인' : '오프라인'}');
            
            // 🔥 온라인 사용자 목록도 동기화
            if (newFriend.isLogin && !onlineUsers.contains(newFriend.userId)) {
              onlineUsers.add(newFriend.userId);
              debugPrint('✅ ${newFriend.userName}을 온라인 사용자 목록에 추가 (API 동기화)');
            } else if (!newFriend.isLogin && onlineUsers.contains(newFriend.userId)) {
              onlineUsers.remove(newFriend.userId);
              debugPrint('✅ ${newFriend.userName}을 온라인 사용자 목록에서 제거 (API 동기화)');
            }
          }
        }
      }
      
      // 친구 목록 업데이트
      friends = newFriends;
      
      // 🔥 웹소켓 상태가 우선 적용되었으므로 별도 초기화 불필요
      // 기존 onlineUsers 상태 유지 (웹소켓 실시간 성태 반영됨)
      debugPrint('🔥 웹소켓 상태 우선 적용 완료 - 온라인 사용자 상태 유지');
      
      if (hasStatusChanges) {
        debugPrint('✅ 친구 상태 변경 감지됨 - UI 업데이트');
        notifyListeners();
      } else {
        debugPrint('ℹ️ 친구 상태 변경 없음');
      }
      
      debugPrint('✅ /myfriend API 친구 상태 새로고침 완료');
    } catch (e) {
      debugPrint('❌ /myfriend API 친구 상태 새로고침 실패: $e');
    }
  }

  // 🔥 새로고침 버튼 전용 메서드 (강화된 친구 상태 동기화)
  Future<void> refreshWithAnimation() async {
    debugPrint('🔄 새로고침 버튼 클릭 - 강화된 동기화 시작');
    
    // 🔥 항상 새로고침 상태로 설정
    isRefreshing = true;
    notifyListeners();

    try {
      // 🔥 게스트 사용자는 친구 API 호출 제외
      if (myId.startsWith('guest_')) {
        debugPrint('⚠️ 게스트 사용자 - 새로고침 제외');
        return;
      }

      // 🔥 1. 웹소켓 상태 확인 및 재연결 시도 (강화)
      debugPrint('📡 현재 웹소켓 실제 연결 상태: ${_wsService.isConnected}');

      debugPrint('📡 컨트롤러에서 추적하는 상태: $isWebSocketConnected');
      debugPrint('📡 스트림 구독 상태: ${_wsMessageSubscription != null}');
      
      // 🔥 스트림 구독 상태 확인 및 재구독
      if (_wsMessageSubscription == null || _wsMessageSubscription!.isPaused) {
        debugPrint('🔄 스트림구독 없음 또는 중지됨 - 재구독 시도');
        _startStreamSubscription();
      }
      
      if (!_wsService.isConnected) {
        debugPrint('📡 웹소켓 연결 안됨 - 강제 재연결 시도');
        await _wsService.connect(myId);
        await Future.delayed(const Duration(milliseconds: 500)); // 연결 안정화 대기 시간 증가
        
        // 🔥 재연결 후 스트림 재구독
        _startStreamSubscription();
        
        // 🔥 재연결 후 상태 다시 확인
        final reconnectedStatus = _wsService.isConnected;
        if (reconnectedStatus) {
          debugPrint('✅ 웹소켓 재연결 성공');
          isWebSocketConnected = true;
        } else {
          debugPrint('❌ 웹소켓 재연결 실패 - 폴링 모드 사용');
          isWebSocketConnected = false;
        }
      } else {
        debugPrint('✅ 웹소켓 이미 연결됨');
        isWebSocketConnected = true;
        // 🔥 연결되어도 스트림 구독 재확인
        _startStreamSubscription();
      }

      // 🔥 2. 강화된 친구 상태 동기화 실행
      await _enhancedFriendStatusSync();

      // 🔥 3. 전체 데이터 새로고침
      await loadAll();
      
      // 🔥 4. 최종 상태 검증 및 동기화
      await _finalStatusValidation();
      
      // 🔥 5. 최종 강제 UI 업데이트
      _forceUIUpdate();
      
      debugPrint('✅ 새로고침 버튼 강화된 동기화 완료');
    } catch (e) {
      debugPrint('❌ 새로고침 버튼 작업 실패: $e');
    } finally {
      // 🔥 최소 1.5초는 로딩 애니메이션을 표시하여 사용자에게 명확한 피드백 제공
      await Future.delayed(const Duration(milliseconds: 1500));
      isRefreshing = false;
      notifyListeners();
      debugPrint('🔄 새로고침 버튼 로딩 애니메이션 종료');
    }
  }

  // 🔥 강화된 친구 상태 동기화 메서드 (수정됨)
  Future<void> _enhancedFriendStatusSync() async {
    try {
      debugPrint('🔄 강화된 친구 상태 동기화 시작');
      
      // 🔥 1. 서버에서 최신 친구 목록 및 상태 받아오기
      final serverFriends = await repository.getMyFriends();
      debugPrint('📡 서버에서 받은 친구 목록: ${serverFriends.length}명');
      
      // 🔥 2. 웹소켓 온라인 사용자 상태 확인 (실제 연결 상태 강제 확인)
      final actualWsConnected = _wsService.isConnected;
      debugPrint('📡 웹소켓 실제 연결 상태: $actualWsConnected');
      debugPrint('📡 컨트롤러에서 추적하는 상태: $isWebSocketConnected');
      
      // 🔥 웹소켓 상태 동기화
      if (actualWsConnected != isWebSocketConnected) {
        debugPrint('📡 웹소켓 상태 불일치 감지 - 동기화: $isWebSocketConnected → $actualWsConnected');
        isWebSocketConnected = actualWsConnected;
      }
      
      final wsOnlineUsers = actualWsConnected ? onlineUsers : <String>[];
      debugPrint('📡 웹소켓 온라인 사용자 목록: ${wsOnlineUsers.length}명');
      
      // 🔥 3. 수정된 충돌 해결 로직 - 웹소켓 상태를 실시간 상태로 우선하되 서버 백업 고려
      bool hasChanges = false;
      for (int i = 0; i < serverFriends.length; i++) {
        final serverFriend = serverFriends[i];
        final isOnlineInWebSocket = wsOnlineUsers.contains(serverFriend.userId);
        
        bool shouldBeOnline;
        if (actualWsConnected) {
          // 웹소켓 연결된 경우: 웹소켓 상태 우선
          // 단, 서버에서 온라인인데 웹소켓 목록에 없는 경우 (신규 연결 등) 웹소켓 목록 업데이트
          shouldBeOnline = isOnlineInWebSocket;
          
          if (serverFriend.isLogin && !isOnlineInWebSocket && !onlineUsers.contains(serverFriend.userId)) {
            onlineUsers.add(serverFriend.userId);
            shouldBeOnline = true;
            debugPrint('📡 서버 온라인 친구를 웹소켓 목록에 추가: ${serverFriend.userName}');
          }
        } else {
          // 웹소켓 연결 안됨: 서버 데이터만 믿음
          shouldBeOnline = serverFriend.isLogin;
        }
        
        debugPrint('🔍 친구 상태 분석: ${serverFriend.userName}(${serverFriend.userId})');
        debugPrint('  - 서버 상태: ${serverFriend.isLogin}');
        debugPrint('  - 웹소켓 상태: $isOnlineInWebSocket ($actualWsConnected)');
        debugPrint('  - 최종 결정: ${shouldBeOnline}');
        
        if (serverFriend.isLogin != shouldBeOnline) {
          serverFriends[i] = Friend(
            userId: serverFriend.userId,
            userName: serverFriend.userName,
            profileImage: serverFriend.profileImage,
            phone: serverFriend.phone,
            isLogin: shouldBeOnline,
            lastLocation: serverFriend.lastLocation,
            isLocationPublic: serverFriend.isLocationPublic,
          );
          hasChanges = true;
          debugPrint('✅ ${serverFriend.userName} 상태 통합: ${serverFriend.isLogin} → $shouldBeOnline');
        }
      }
      
      // 🔥 4. 온라인 사용자 목록 동기화
      onlineUsers.clear();
      onlineUsers.addAll(serverFriends.where((f) => f.isLogin).map((f) => f.userId));
      
      // 🔥 5. 친구 목록 업데이트
      friends = serverFriends;
      
      // 🔥 6. 상태 변경이 있으면 UI 업데이트
      if (hasChanges) {
        debugPrint('🔄 상태 변경 감지 - UI 컴파일');
        notifyListeners();
      }
      
      debugPrint('✅ 강화된 친구 상태 동기화 완료');
    } catch (e) {
      debugPrint('❌ 강화된 친구 상태 동기화 실패: $e');
      rethrow;
    }
  }

  // 🔥 최종 상태 검증 및 동기화
  Future<void> _finalStatusValidation() async {
    try {
      debugPrint('🔍 최종 상태 검증 및 동기화 시작');
      
      // 🔥 모든 친구의 온라인 상태를 다시 한 번 확인
      for (int i = 0; i < friends.length; i++) {
        final friend = friends[i];
        final isInOnlineList = onlineUsers.contains(friend.userId);
        
        if (friend.isLogin != isInOnlineList) {
          debugPrint('⚠️ 상태 일치하지 않음: ${friend.userName} - 친구리스트:${friend.isLogin}, 온라인리스트:$isInOnlineList');
          
          // 웹소켓이 연결되어 있으면 웹소켓 데이터 기준으로 동기화
          if (_wsService.isConnected) {
            friends[i] = Friend(
              userId: friend.userId,
              userName: friend.userName,
              profileImage: friend.profileImage,
              phone: friend.phone,
              isLogin: isInOnlineList,
              lastLocation: friend.lastLocation,
              isLocationPublic: friend.isLocationPublic,
            );
            debugPrint('✅ ${friend.userName} 상태 웹소켓 기준으로 수정');
          }
        }
      }
      
      // 🔥 서버 상태와 웹소켓 상태 불일치 시 웹소켓 우선으로 마무리 동기화
      if (_wsService.isConnected) {
        _updateFriendsOnlineStatus();
      }
      
      debugPrint('✅ 최종 상태 검증 완료');
    } catch (e) {
      debugPrint('❌ 최종 상태 검증 실패: $e');
    }
  }

  // 🔥 즉시 친구 상태 강제 새로고침 메서드 (진단용 로그 추가)
  Future<void> forceRefreshFriendStatus() async {
    try {
      final startTime = DateTime.now();
      debugPrint('🔄 친구 상태 강제 새로고침 시작... (${startTime.toIso8601String()})');
      
      // 🔥 게스트 사용자는 제외
      if (myId.startsWith('guest_')) {
        debugPrint('⚠️ 게스트 사용자 - 강제 새로고침 제외');
        return;
      }

      // 웹소켓이 연결되어 있으면 /myfriend API로 친구 상태 새로고침
      if (isWebSocketConnected) {
        debugPrint('📡 웹소켓 연결됨 - /myfriend API로 친구 상태 새로고침 (${DateTime.now().toIso8601String()})');
        await _refreshFriendStatusFromAPI();
      } else {
        debugPrint('📡 폴링으로 친구 상태 업데이트 (${DateTime.now().toIso8601String()})');
        await _silentUpdate();
      }
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      debugPrint('✅ 친구 상태 강제 새로고침 완료 (소요시간: ${duration.inMilliseconds}ms)');
    } catch (e) {
      debugPrint('❌ 친구 상태 강제 새로고침 실패: $e');
    }
  }

  // 🔥 폴백 동기화 메커니즘 (실시간 반영 실패 시 자동 복구)
  Future<void> _fallbackSyncMechanism() async {
    try {
      debugPrint('🔄 폴백 동기화 메커니즘 시작 - 실시간 반영 실패 시 복구');
      
      // 🔥 1. 웹소켓 연결 상태 재확인
      if (!_wsService.isConnected) {
        debugPrint('📡 폴백: 웹소켓 연결 끊어짐 감지 - 재연결 시도');
        await _wsService.connect(myId);
        
        // 연결 후 잠깐 대기
        await Future.delayed(const Duration(milliseconds: 500));
        
        // 상태 다시 확인
        if (_wsService.isConnected) {
          debugPrint('✅ 폴백: 웹소켓 재연결 성공');
          isWebSocketConnected = true;
        } else {
          debugPrint('❌ 폴백: 웹소켓 재연결 실패 - 폴링 모드');
          isWebSocketConnected = false;
        }
      }
      
      // 🔥 2. 서버에서 강제 상태 새로고침
      await _refreshFriendStatusFromAPI();
      
      // 🔥 3. 웹소켓 상태와 서버 상태 재동기화
      if (_wsService.isConnected && onlineUsers.isNotEmpty) {
        debugPrint('📡 폴백: 웹소켓 상태와 서버 상태 재동기화');
        _updateFriendsOnlineStatus();
      }
      
      // 🔥 4. 최종 UI 업데이트
      debugPrint('🔄 폴백: 최종 UI 업데이트');
      notifyListeners();
      
      debugPrint('✅ 폴백 동기화 메커니즘 완료');
    } catch (e) {
      debugPrint('❌ 폴백 동기화 메커니즘 실패: $e');
    }
  }


  // 🔥 친구 상태 변경 시 폴백 확인 메서드 (실시간 반영 후 일정 시간 뒤 확인)
  void _scheduleFallbackCheck(String userId, bool expectedStatus) {
    Timer(const Duration(seconds: 3), () async {
      try {
        final friend = friends.firstWhere(
          (f) => f.userId == userId,
          orElse: () => Friend(
            userId: '',
            userName: '',
            profileImage: '',
            phone: '',
            isLogin: false,
            lastLocation: '',
            isLocationPublic: false,
          ),
        );
        
        if (friend.userId.isNotEmpty && friend.isLogin != expectedStatus) {
          debugPrint('⚠️ 폴백 확인: ${friend.userName} 상태가 예상과 다름 - 강제 동기화 실행');
          await _fallbackSyncMechanism();
        }
      } catch (e) {
        debugPrint('❌ 폴백 확인 오류: $e');
      }
    });
  }

  // 🔥 로그 출력 여부 결정 메서드
  bool _shouldLogMessage(String messageType) {
    // 중요한 메시지만 로그 출력
    const importantMessages = {
      'friend_logged_in',
      'friend_logged_out',
      'friend_status_change',
      'new_friend_request',
      'friend_request_accepted',
      'friend_request_rejected',
      'friend_deleted',
    };
    return importantMessages.contains(messageType);
  }

  // 🔥 앱 포그라운드 복귀 시 즉시 친구 상태 확인 (지연 문제 해결)
  void onAppResumed() {
    debugPrint('📱 앱 포그라운드 복귀 - 즉시 친구 상태 확인');
    
    // 즉시 동기화 실행
    Future.microtask(() async {
      debugPrint('⚡ 앱 포그라운드 복귀 - 즉시 동기화 실행');
      await _immediateSync();
    });
    
    // 추가로 /myfriend API로 친구 상태 새로고침
    _refreshFriendStatusFromAPI();
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
      
      // 🔥 UI 강제 새로고침 (이미 상위에서 notifyListeners 호출됨)
      _forceUIUpdate();
      
      // 🔥 즉시 UI 업데이트 확신 (지연 제거)
      Future.microtask(() {
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

  // 🔥 새로 추가: 친구 목록과 상태 정보 응답 처리
  void _handleFriendListWithStatus(Map<String, dynamic> message) {
    debugPrint('📨 친구 목록과 상태 정보 응답 처리 시작');
    debugPrint('📨 친구 목록과 상태 정보 응답 데이터: $message');

    try {
      // 서버에서 받은 친구 목록과 상태 정보를 처리
      if (message['friends'] != null && message['friends'] is List) {
        final friendsData = message['friends'] as List;
        debugPrint('📨 서버에서 받은 친구 목록 수: ${friendsData.length}');
        
        bool hasChanges = false;
        
        // 각 친구의 정보를 업데이트
        for (var friendData in friendsData) {
          if (friendData is Map) {
            final userId = friendData['userId']?.toString() ?? '';
            final userName = friendData['userName']?.toString() ?? '';
            final isOnline = friendData['isOnline'] ?? friendData['Is_Login'] ?? false;
            
            debugPrint('📨 친구 정보 업데이트: $userName ($userId) - ${isOnline ? '온라인' : '오프라인'}');
            
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
            
            // 친구 목록에서 해당 사용자의 정보 업데이트
            bool found = false;
            for (int i = 0; i < friends.length; i++) {
              if (friends[i].userId == userId) {
                found = true;
                final oldStatus = friends[i].isLogin;
                if (oldStatus != isOnline) {
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
                  debugPrint('✅ ${friends[i].userName} 상태 업데이트: $oldStatus → $isOnline');
                }
                break;
              }
            }
            
            if (!found) {
              debugPrint('⚠️ 친구 목록에서 해당 사용자를 찾을 수 없음: $userId');
            }
          }
        }
        
        if (hasChanges) {
          debugPrint('🔄 친구 목록과 상태 정보 응답으로 인한 UI 업데이트');
          _forceUIUpdate();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('❌ 친구 목록과 상태 정보 응답 처리 중 오류: $e');
    }
  }

  // 🔥 새로 추가: 친구 로그아웃 처리 메서드 (강화된 버전)
  void _handleFriendLoggedOut(Map<String, dynamic> message) {
    final loggedOutUserId = message['userId'];
    final messageText = message['message'];
    final timestamp = message['timestamp'];
    
    if (kDebugMode) {
      debugPrint('👤 친구 로그아웃 감지: $loggedOutUserId');
      debugPrint('👤 메시지: $messageText');
      debugPrint('👤 타임스탬프: $timestamp');
    }

    // 🔥 강제로 온라인 사용자 목록에서 제거
    bool wasOnline = onlineUsers.contains(loggedOutUserId);
    if (wasOnline) {
      onlineUsers.remove(loggedOutUserId);
      debugPrint('✅ 온라인 사용자 목록에서 제거: $loggedOutUserId');
    }

    // 🔥 강제로 친구 목록에서 해당 사용자의 상태를 오프라인으로 업데이트
    bool found = false;
    for (int i = 0; i < friends.length; i++) {
      if (friends[i].userId == loggedOutUserId) {
        found = true;
        final oldStatus = friends[i].isLogin;
        final friendName = friends[i].userName;
        
        // 🔥 강제로 오프라인으로 설정 (조건 없이)
        friends[i] = Friend(
          userId: friends[i].userId,
          userName: friends[i].userName,
          profileImage: friends[i].profileImage,
          phone: friends[i].phone,
          isLogin: false, // 🔥 무조건 오프라인으로 변경
          lastLocation: friends[i].lastLocation,
          isLocationPublic: friends[i].isLocationPublic,
        );
        
        debugPrint('✅ $friendName 상태를 강제로 오프라인으로 변경 ($oldStatus → false)');
        break;
      }
    }

    if (!found) {
      debugPrint('⚠️ 친구 목록에서 해당 사용자를 찾을 수 없음: $loggedOutUserId');
      debugPrint('⚠️ 현재 친구 목록: ${friends.map((f) => '${f.userId}(${f.userName})').join(', ')}');
    }

    // 🔥 즉시 UI 업데이트 (지연 제거)
    debugPrint('🔄 친구 로그아웃으로 인한 즉시 UI 업데이트');
    
    // 🔥 강제 UI 업데이트 먼저 호출
    _forceUIUpdate();
    
    // 🔥 폴백 확인 예약 (3초 후 로그아웃 상태 재확인)
    _scheduleFallbackCheck(loggedOutUserId, false);
    
    _showFriendStatusNotification(loggedOutUserId, false);
    
    // 🔥 즉시 상태 재확인 (지연 제거)
    Future.microtask(() async {
      _verifyFriendStatus(loggedOutUserId, false);
    });
  }

  // 🔥 API 문서에 명시된 새로운 메시지 핸들러들 추가
  // 더 이상 사용되지 않는 함수 제거됨 (통합된 알림으로 대체)

  void _handleOnlineUsersUpdateMessage(Map<String, dynamic> message) {
    final onlineUsersList = message['onlineUsers'];
    final timestamp = message['timestamp'];
    
    if (kDebugMode) {
      debugPrint('👥 온라인 사용자 목록 업데이트 알림');
      debugPrint('👥 온라인 사용자 수: ${onlineUsersList is List ? onlineUsersList.length : 'N/A'}');
      debugPrint('👥 타임스탬프: $timestamp');
    }
    
    // 기존 온라인 사용자 업데이트 로직과 통합
    if (onlineUsersList is List) {
      final users = onlineUsersList
          .map((user) {
            if (user is String) {
              return user;
            } else if (user is Map) {
              return user['userId']?.toString() ?? user['id']?.toString() ?? '';
            } else {
              return user.toString();
            }
          })
          .where((id) => id.isNotEmpty)
          .toList();
      _handleOnlineUsersUpdate(users);
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

  // 🔥 웹소켓 데이터 기반 친구 상태 업데이트 (개선됨)
  void _updateFriendsStatusFromWebSocket() {
    bool hasChanges = false;

    for (int i = 0; i < friends.length; i++) {
      final isOnlineInWebSocket = onlineUsers.contains(friends[i].userId);
      final currentStatus = friends[i].isLogin;

      // 상태 변경이 있고, 웹소켓 상태가 실제로 다르면 업데이트
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
          '✅ ${friends[i].userName} 상태 변경: ${currentStatus ? '온라인' : '오프라인'} → ${isOnlineInWebSocket ? '온라인' : '오프라인'} (웹소켓 기반)',
        );
        hasChanges = true;
      }
    }

    if (hasChanges) {
      debugPrint('🔄 UI 업데이트 트리거 - 웹소켓 기반 친구 상태 변경');
      // 🔥 즉시 UI 업데이트 (지연 없음)
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

  // 🔄 실시간 업데이트 시작 (개선된 버전)
  void _startRealTimeUpdates() {
    debugPrint('🔄 실시간 업데이트 시작');
    
    // 🔥 기존 타이머 완전 정리
    _stopPollingCompletely();

    // 🔥 실시간 업데이트 상태 활성화
    _isRealTimeEnabled = true;

    // 🔥 웹소켓이 연결되어 있어도 주기적 상태 동기화를 위해 타이머 시작
    _updateTimer = Timer.periodic(_updateInterval, (timer) async {
      debugPrint('⏰ 폴링 타이머 실행 - 웹소켓 연결 상태: $isWebSocketConnected');
      
      // 🔥 폴링 중에도 웹소켓 연결 상태 확인
      await _checkAndRecoverWebSocketConnection();
      
      // 🔥 웹소켓이 연결되어 있으면 주기적 상태 동기화만 수행
      if (isWebSocketConnected) {
        debugPrint('📡 웹소켓 연결됨 - 주기적 상태 동기화 수행');
        await _refreshFriendStatusFromAPI();
        return;
      }

      // 웹소켓이 연결되어 있지 않을 때는 기존 폴링 로직 수행
      if (_isRealTimeEnabled) {
        debugPrint('📡 폴링 모드로 업데이트 (웹소켓 비활성)');
        await _immediateSync(); // 즉시 동기화 메서드 사용
      }
    });
    
    debugPrint('✅ 폴링 타이머 시작됨 - 간격: ${_updateInterval.inSeconds}초');
  }

  // 🔥 즉시 동기화 메서드 (지연 문제 해결)
  Future<void> _immediateSync() async {
    try {
      debugPrint('⚡ 즉시 동기화 시작 - 지연 문제 해결');
      
      // 🔥 게스트 사용자는 제외
      if (myId.startsWith('guest_')) {
        debugPrint('⚠️ 게스트 사용자 - 즉시 동기화 제외');
        return;
      }

      // 1. 웹소켓 연결 상태 재확인
      if (isWebSocketConnected) {
        debugPrint('📡 웹소켓 연결됨 - 즉시 동기화 중단');
        return;
      }

      // 2. 즉시 친구 상태 새로고침
      debugPrint('📡 즉시 친구 상태 새로고침 시작');
      final newFriends = await repository.getMyFriends();
      
      // 3. 상태 변경 감지 및 즉시 업데이트
      bool hasStatusChanges = false;
      for (int i = 0; i < newFriends.length; i++) {
        final newFriend = newFriends[i];
        final existingFriend = friends.firstWhere(
          (f) => f.userId == newFriend.userId,
          orElse: () => Friend(
            userId: '',
            userName: '',
            profileImage: '',
            phone: '',
            isLogin: false,
            lastLocation: '',
            isLocationPublic: false,
          ),
        );
        
        if (existingFriend.userId.isNotEmpty && existingFriend.isLogin != newFriend.isLogin) {
          hasStatusChanges = true;
          debugPrint('⚡ ${newFriend.userName} 상태 즉시 변경: ${existingFriend.isLogin ? '온라인' : '오프라인'} → ${newFriend.isLogin ? '온라인' : '오프라인'}');
        }
      }
      
      // 4. 친구 목록 즉시 업데이트
      friends = newFriends;
      
      // 5. 온라인 상태 즉시 동기화
      _initializeOnlineStatusFromServer();
      _updateFriendsOnlineStatus();
      
      if (hasStatusChanges) {
        debugPrint('⚡ 상태 변경 감지됨 - 즉시 UI 업데이트');
        _forceUIUpdate();
        notifyListeners();
      }
      
      debugPrint('⚡ 즉시 동기화 완료');
    } catch (e) {
      debugPrint('❌ 즉시 동기화 실패: $e');
    }
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
    // 🔥 loadAll에서는 isRefreshing을 설정하지 않음 (refreshWithAnimation에서만 설정)
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
        // 🔥 게스트 사용자의 경우 isRefreshing은 refreshWithAnimation에서만 관리
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
    // 🔥 loadAll에서는 isRefreshing을 설정하지 않음 (refreshWithAnimation에서만 관리)
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
    debugPrint('🔍 온라인 사용자 목록: $onlineUsers');

    for (int i = 0; i < friends.length; i++) {
      final friend = friends[i];
      final isInOnlineList = onlineUsers.contains(friend.userId);
      final statusMatch = friend.isLogin == isInOnlineList;
      debugPrint(
        '🔍 친구 ${i + 1}: ${friend.userName} (${friend.userId}) - 온라인: ${friend.isLogin}, 목록포함: $isInOnlineList, 일치: $statusMatch',
      );
    }
  }

  // 🔍 특정 친구 상태 강제 수정 (디버깅용)
  void forceUpdateFriendStatus(String userId, bool isOnline) {
    debugPrint('🔧 친구 상태 강제 수정: $userId → ${isOnline ? '온라인' : '오프라인'}');
    
    // 온라인 사용자 목록 수정
    if (isOnline) {
      if (!onlineUsers.contains(userId)) {
        onlineUsers.add(userId);
        debugPrint('✅ 온라인 목록에 추가: $userId');
      }
    } else {
      if (onlineUsers.contains(userId)) {
        onlineUsers.remove(userId);
        debugPrint('✅ 온라인 목록에서 제거: $userId');
      }
    }
    
    // 친구 목록 상태 수정
    for (int i = 0; i < friends.length; i++) {
      if (friends[i].userId == userId) {
        final oldStatus = friends[i].isLogin;
        friends[i] = Friend(
          userId: friends[i].userId,
          userName: friends[i].userName,
          profileImage: friends[i].profileImage,
          phone: friends[i].phone,
          isLogin: isOnline,
          lastLocation: friends[i].lastLocation,
          isLocationPublic: friends[i].isLocationPublic,
        );
        debugPrint('✅ ${friends[i].userName} 상태 강제 수정: $oldStatus → $isOnline');
        break;
      }
    }
    
    // UI 강제 업데이트
    _forceUIUpdate();
    notifyListeners();
    debugPrint('✅ UI 강제 업데이트 완료');
  }

  // 🔍 웹소켓 연결 테스트 (크로스 플랫폼 최적화)
  void testWebSocketConnection() {
    debugPrint('🔍 웹소켓 연결 테스트 시작 (${Platform.operatingSystem})');
    _wsService.testConnection();

    // 플랫폼별 최적화된 대기 시간
    final delay = Platform.isAndroid 
        ? const Duration(seconds: 2) 
        : Platform.isIOS 
        ? const Duration(seconds: 3)
        : const Duration(seconds: 2);
        
    Future.delayed(delay, () {
      debugPrint('🔍 웹소켓 연결 테스트 결과 (${Platform.operatingSystem})');
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

    // 🔥 친구 목록 및 데이터 완전 초기화
    friends.clear();
    friendRequests.clear();
    sentFriendRequests.clear();
    onlineUsers.clear();
    _realTimeStatusCache.clear();
    _statusTimestamp.clear();
    
    debugPrint('✅ 친구 데이터 완전 초기화 완료');

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

  // 🔥 실시간 친구 상태 즉시 업데이트 메서드
  void _updateFriendStatusImmediately(String userId, bool isOnline) async {
    debugPrint('🔥🔥🔥 실시간 상태 즉시 업데이트 시작 🔥🔥🔥');
    debugPrint('📱 친구 ID: $userId');
    debugPrint('📱 상태: ${isOnline ? '온라인' : '오프라인'}');
    
    // 친구 목록에서 해당 친구 찾기
    bool found = false;
    for (int i = 0; i < friends.length; i++) {
      if (friends[i].userId == userId) {
        found = true;
        final friendName = friends[i].userName;
        final oldStatus = friends[i].isLogin;
        
        // 🔥 강제로 상태 업데이트
        friends[i] = Friend(
            userId: friends[i].userId,
            userName: friends[i].userName,
            profileImage: friends[i].profileImage,
            phone: friends[i].phone,
            isLogin: isOnline, // 🔥 실시간 상태 강제 적용
            lastLocation: friends[i].lastLocation,
            isLocationPublic: friends[i].isLocationPublic,
          );

        // 온라인 사용자 목록 업데이트
        if (isOnline && !onlineUsers.contains(userId)) {
          onlineUsers.add(userId);
          debugPrint('✅ 온라인 사용자 목록에 추가: $userId');
        } else if (!isOnline && onlineUsers.contains(userId)) {
          onlineUsers.remove(userId);
          debugPrint('✅ 온라인 사용자 목록에서 제거: $userId');
        }

        debugPrint('🔥 ${friendName} 상태 즉시 변경: ${oldStatus ? '온라인' : '오프라인'} → ${isOnline ? '온라인' : '오프라인'}');
        break;
      }
    }

    if (!found) {
      debugPrint('⚠️ 친구 ID $userId를 친구 목록에서 찾을 수 없습니다');
      debugPrint('🔍 현재 친구 목록: ${friends.map((f) => '${f.userName}(${f.userId})').join(', ')}');
    }

    // 🔥 즉시 UI 업데이트
    debugPrint('🔄 즉시 UI 업데이트 실행');
    notifyListeners();
    
    debugPrint('✅ 실시간 상태 즉시 업데이트 완료');
  }


  // 🔥 사용자 변경 시 즉시 데이터 초기화 메서드
  void clearAllData() {
    debugPrint('🔄 FriendsController 데이터 즉시 초기화 시작');
    
    // 모든 친구 관련 데이터 초기화
    friends.clear();
    friendRequests.clear();
    sentFriendRequests.clear();
    onlineUsers.clear();
    _realTimeStatusCache.clear();
    _statusTimestamp.clear();
    
    // 상태 초기화
    isLoading = false;
    isRefreshing = false;
    errorMessage = null;
    isWebSocketConnected = false;
    
    debugPrint('✅ FriendsController 데이터 즉시 초기화 완료');
    
    // UI 업데이트
    notifyListeners();
  }
}
