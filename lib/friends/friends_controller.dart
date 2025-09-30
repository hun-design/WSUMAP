// lib/friends/friends_controller.dart - 최적화된 친구 관리 컨트롤러
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

  // 상태 변수들
  List<Friend> friends = [];
  List<FriendRequest> friendRequests = [];
  List<SentFriendRequest> sentFriendRequests = [];
  List<String> onlineUsers = [];
  bool isLoading = false;
  bool isRefreshing = false;
  String? errorMessage;
  bool isWebSocketConnected = false;
  
  // 실시간 상태 관리
  Map<String, bool> _realTimeStatusCache = {};
  Map<String, DateTime> _statusTimestamp = {};

  // 리소스 관리
  Timer? _updateTimer;
  StreamSubscription? _wsMessageSubscription;
  StreamSubscription? _wsConnectionSubscription;
  StreamSubscription? _wsOnlineUsersSubscription;

  DateTime? _lastUpdate;
  bool _isRealTimeEnabled = true;

  FriendsController(this.repository, this.myId) {
    _initializeController();
  }

  // 게터들
  bool get isRealTimeEnabled => _isRealTimeEnabled && isWebSocketConnected;

  // 플랫폼별 최적화된 업데이트 간격 (개선된 버전)
  Duration get _updateInterval {
    switch (Platform.operatingSystem) {
      case 'android':
        return const Duration(seconds: 30); // Android: 배터리 최적화
      case 'ios':
        return const Duration(seconds: 25); // iOS: 더 빠른 갱신
      case 'macos':
      case 'windows':
      case 'linux':
        return const Duration(seconds: 20); // 데스크톱: 빠른 성능
      default:
        return const Duration(seconds: 30);
    }
  }

  // 컨트롤러 초기화
  void _initializeController() {
    if (kDebugMode) {
      debugPrint('FriendsController 초기화 - 사용자 ID: $myId');
    }
    
    if (!_isGuestUser()) {
      // 🔥 기존 웹소켓 연결 종료 (사용자 변경 대비)
      _disconnectWebSocket();
      
      // 🔥 새로운 사용자로 웹소켓 연결
      _startStreamSubscription();
      _initializeWebSocket();
    }
  }

  // 게스트 사용자 체크
  bool _isGuestUser() => myId.startsWith('guest_');

  // 플랫폼별 연결 안정화 지연 시간 (개선된 버전)
  Duration _getConnectionStabilizationDelay() {
    switch (Platform.operatingSystem) {
      case 'android':
        return const Duration(milliseconds: 500); // Android: 네트워크 안정화
      case 'ios':
        return const Duration(milliseconds: 300); // iOS: 빠른 연결
      case 'macos':
        return const Duration(milliseconds: 200); // macOS: 최적화
      case 'windows':
        return const Duration(milliseconds: 250); // Windows: 중간값
      case 'linux':
        return const Duration(milliseconds: 200); // Linux: 최적화
      default:
        return const Duration(milliseconds: 300);
    }
  }

  // 스트림 구독 시작
  void _startStreamSubscription() {
    if (kDebugMode) {
      debugPrint('웹소켓 스트림 구독 시작');
    }
    
    _wsMessageSubscription?.cancel();
    
    _wsMessageSubscription = _wsService.messageStream.listen(
      _handleWebSocketMessage,
      onError: _handleStreamError,
      onDone: _handleStreamDone,
    );
  }

  // 스트림 에러 핸들러
  void _handleStreamError(error) {
    if (kDebugMode) {
      debugPrint('웹소켓 스트림 오류: $error');
    }
    Future.delayed(const Duration(seconds: 2), _startStreamSubscription);
  }

  // 스트림 완료 핸들러
  void _handleStreamDone() {
    if (kDebugMode) {
      debugPrint('웹소켓 스트림 완료');
    }
    Future.delayed(const Duration(seconds: 1), _startStreamSubscription);
  }

  // 🔥 웹소켓 연결 해제 (사용자 변경 시 호출)
  void _disconnectWebSocket() {
    try {
      if (_wsService.isConnected) {
        if (kDebugMode) {
          debugPrint('🔄 사용자 변경 감지 - 기존 웹소켓 연결 해제 중...');
        }
        _wsService.disconnect();
        isWebSocketConnected = false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ 웹소켓 연결 해제 중 오류: $e');
      }
    }
  }
  
  // 웹소켓 초기화
  Future<void> _initializeWebSocket() async {
    if (kDebugMode) {
      debugPrint('웹소켓 초기화 시작 - 사용자 ID: $myId');
    }

    if (_isGuestUser()) {
      if (kDebugMode) {
        debugPrint('게스트 사용자 - 웹소켓 초기화 제외');
      }
      return;
    }

    // 🔥 항상 새로운 연결 시도 (사용자 변경 대비)
    if (_wsService.isConnected) {
      if (kDebugMode) {
        debugPrint('🔄 기존 웹소켓 연결 해제 후 재연결');
      }
      await _wsService.disconnect();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    try {
    await NotificationService.initialize();
    await _wsService.connect(myId);
      await Future.delayed(_getConnectionStabilizationDelay());
      
    _startStreamSubscription();
    
    _wsConnectionSubscription = _wsService.connectionStream.listen(
      _handleConnectionChange,
    );
    _wsOnlineUsersSubscription = _wsService.onlineUsersStream.listen(
      _handleOnlineUsersUpdate,
    );

      await _syncFriendStatusAfterConnection();
      
      if (kDebugMode) {
        debugPrint('웹소켓 초기화 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('웹소켓 초기화 실패: $e');
      }
    }
  }

  // 연결 완료 후 친구 상태 동기화
  Future<void> _syncFriendStatusAfterConnection() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (_wsService.isConnected && !_isGuestUser()) {
      await _refreshFriendStatusFromAPI();
    }
  }

  // 웹소켓 메시지 처리 (개선된 버전)
  void _handleWebSocketMessage(Map<String, dynamic> message) {
    if (kDebugMode && _shouldLogMessage(message['type'])) {
      debugPrint('웹소켓 메시지 수신: ${message['type']}');
    }
    
    if (_isGuestUser()) return;

    final messageType = message['type'] as String?;
    if (messageType == null) {
      if (kDebugMode) {
        debugPrint('유효하지 않은 웹소켓 메시지: type 필드 없음');
      }
      return;
    }

    try {
      switch (messageType) {
        case 'new_friend_request':
        case 'friend_request_accepted':
        case 'friend_request_rejected':
        case 'friend_deleted':
          quickUpdate();
          break;

        case 'friend_status_change':
          _handleFriendStatusChange(message);
          break;

        case 'Login_Status':
          // 🔥 Login_Status 메시지는 이미 WebSocketService에서 friend_status_change로 변환되어 처리됨
          // 중복 처리 방지를 위해 여기서는 무시
          if (kDebugMode) {
            debugPrint('Login_Status 메시지 무시 (이미 변환되어 처리됨)');
          }
          break;

        case 'friend_location_update':
          _handleFriendLocationUpdate(message);
          break;

        case 'real_time_status_change':
          final userId = message['userId'];
          final isOnline = message['isOnline'];
          if (userId != null) {
            _updateFriendStatusImmediately(userId, isOnline == true);
          }
          break;

        case 'online_users_update':
          _handleOnlineUsersUpdateMessage(message);
          break;

        case 'location_share_status_change':
          _handleLocationShareStatusChange(message);
          break;

        default:
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('웹소켓 메시지 처리 중 오류: $e');
      }
    }
  }

  // 연결 상태 변경 처리
  void _handleConnectionChange(bool isConnected) {
    final previousState = isWebSocketConnected;
    isWebSocketConnected = isConnected;

    if (kDebugMode) {
      debugPrint('웹소켓 연결 상태 변경: $previousState → $isConnected');
    }
      
    if (isConnected) {
      _stopPollingCompletely();
      _initializeWithWebSocket();
      _refreshFriendStatusFromAPI();
    } else {
      _startRealTimeUpdates();
    }

    notifyListeners();
  }

  // 폴링 완전 중지
  void _stopPollingCompletely() {
    _updateTimer?.cancel();
      _updateTimer = null;
    _isRealTimeEnabled = false;
  }

  // 웹소켓 연결 시 초기화
  Future<void> _initializeWithWebSocket() async {
    try {
      if (!_wsService.isConnected || _isGuestUser()) {
        _startRealTimeUpdates();
        return;
      }

      final newFriends = await repository.getMyFriends();
      final newFriendRequests = await repository.getFriendRequests();
      final newSentFriendRequests = await repository.getSentFriendRequests();

      friends = newFriends;
      friendRequests = newFriendRequests;
      sentFriendRequests = newSentFriendRequests;

      _initializeOnlineStatusFromServer();
      _updateFriendsOnlineStatus();

      if (isWebSocketConnected && !_isGuestUser()) {
        _requestFriendStatusSync();
        await _refreshFriendStatusFromAPI();
        await _immediateSync();
      }

      notifyListeners();
    } catch (e) {
        if (kDebugMode) {
          debugPrint('웹소켓 초기화 실패: $e');
        }
      _startRealTimeUpdates();
    }
  }

  // 서버 데이터 기반 온라인 상태 초기화
  void _initializeOnlineStatusFromServer() {
    if (isWebSocketConnected) return;

    onlineUsers.clear();
    for (final friend in friends) {
      if (friend.isLogin) {
        onlineUsers.add(friend.userId);
      }
    }
  }

  // 온라인 사용자 업데이트
  void _handleOnlineUsersUpdate(List<String> users) {
    onlineUsers = users;
    _syncWithServerData();
    _updateFriendsOnlineStatus();
    notifyListeners();
  }

  // 서버 데이터와 웹소켓 데이터 동기화 (개선된 버전)
  void _syncWithServerData() {
    bool hasChanges = false;

    if (kDebugMode) {
      debugPrint('🔄 서버-웹소켓 데이터 동기화 시작');
      debugPrint('🔄 웹소켓 연결 상태: $isWebSocketConnected');
      debugPrint('🔄 온라인 사용자 수: ${onlineUsers.length}');
    }

    for (int i = 0; i < friends.length; i++) {
      final friend = friends[i];
      final isOnlineInServer = friend.isLogin;
      final isOnlineInWebSocket = onlineUsers.contains(friend.userId);

      bool shouldBeOnline;
      if (isWebSocketConnected) {
        // 🔥 웹소켓 연결 시: 웹소켓 데이터 우선, 서버 데이터 보조
        shouldBeOnline = isOnlineInWebSocket;
        
        // 🔥 서버에서 온라인인데 웹소켓에서 누락된 경우 보정
        if (isOnlineInServer && !isOnlineInWebSocket) {
          onlineUsers.add(friend.userId);
          shouldBeOnline = true;
          if (kDebugMode) {
            debugPrint('🔧 서버-웹소켓 상태 보정: ${friend.userName} 온라인으로 설정');
          }
        }
      } else {
        // 🔥 웹소켓 연결 안됨: 서버 데이터 사용
        shouldBeOnline = isOnlineInServer;
      }
      
      // 🔥 상태가 다른 경우에만 업데이트
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
        
        // 🔥 온라인 사용자 목록 동기화
        if (shouldBeOnline && !onlineUsers.contains(friend.userId)) {
          onlineUsers.add(friend.userId);
        } else if (!shouldBeOnline && onlineUsers.contains(friend.userId)) {
          onlineUsers.remove(friend.userId);
        }
        
        hasChanges = true;
        
        if (kDebugMode) {
          debugPrint('🔄 친구 상태 동기화: ${friend.userName} = ${shouldBeOnline ? '온라인' : '오프라인'}');
        }
      }
    }

    if (hasChanges) {
      if (kDebugMode) {
        debugPrint('✅ 서버-웹소켓 데이터 동기화 완료 (변경사항 있음)');
      }
      notifyListeners();
    } else {
      if (kDebugMode) {
        debugPrint('✅ 서버-웹소켓 데이터 동기화 완료 (변경사항 없음)');
      }
    }
  }

  // 친구 상태 변경 처리 (개선된 버전)
  void _handleFriendStatusChange(Map<String, dynamic> message) {
    final userId = message['userId'];
    if (userId == null || userId.isEmpty) {
      if (kDebugMode) {
        debugPrint('❌ 친구 상태 변경 메시지에 userId가 없음: $message');
      }
      return;
    }

    // 🔥 다양한 상태 필드명 지원
    final isOnlineRaw = message['isOnline'] ?? 
                       message['is_login'] ?? 
                       message['status'] ?? 
                       message['isOnline'] ?? 
                       false;
    
    // 🔥 상태 값 정규화
    final isOnline = _normalizeBooleanValue(isOnlineRaw);
    
    if (kDebugMode) {
      debugPrint('📶 친구 상태 변경: $userId = ${isOnline ? '온라인' : '오프라인'}');
      debugPrint('📶 원본 값: $isOnlineRaw → 정규화: $isOnline');
    }

    // 🔥 상태 업데이트 (원자적 처리)
    _updateFriendStatusAtomically(userId, isOnline);
    
    // 🔥 알림 표시
    _showFriendStatusNotification(userId, isOnline);
  }

  // 🔥 Boolean 값 정규화 헬퍼
  bool _normalizeBooleanValue(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) {
      return value == 1;
    }
    return false;
  }

  // 🔥 원자적 친구 상태 업데이트
  void _updateFriendStatusAtomically(String userId, bool isOnline) {
    // 1. 온라인 사용자 목록 업데이트
    _updateOnlineList(userId, isOnline);
    
    // 2. 친구 목록에서 상태 업데이트
    _updateFriendInList(userId, isOnline);
    
    // 3. UI 업데이트
    notifyListeners();
  }

  // 온라인 사용자 목록 업데이트 헬퍼 (개선된 버전)
  void _updateOnlineList(String userId, bool isOnline) {
    if (isOnline && !onlineUsers.contains(userId)) {
      onlineUsers.add(userId);
      if (kDebugMode) {
        debugPrint('✅ 온라인 사용자 추가: $userId');
      }
    } else if (!isOnline && onlineUsers.contains(userId)) {
      onlineUsers.remove(userId);
      if (kDebugMode) {
        debugPrint('❌ 온라인 사용자 제거: $userId');
      }
    }
  }

  // 친구 목록에서 친구 상태 업데이트 (개선된 버전)
  void _updateFriendInList(String userId, bool isOnline) {
    final friendIndex = friends.indexWhere((friend) => friend.userId == userId);
    if (friendIndex != -1) {
      final currentFriend = friends[friendIndex];
      
      // 🔥 상태가 실제로 변경된 경우에만 업데이트
      if (currentFriend.isLogin != isOnline) {
        friends[friendIndex] = Friend(
          userId: currentFriend.userId,
          userName: currentFriend.userName,
          profileImage: currentFriend.profileImage,
          phone: currentFriend.phone,
          isLogin: isOnline,
          lastLocation: currentFriend.lastLocation,
          isLocationPublic: currentFriend.isLocationPublic,
        );
        
        if (kDebugMode) {
          debugPrint('🔄 친구 상태 업데이트: ${currentFriend.userName} = ${isOnline ? '온라인' : '오프라인'}');
        }
      }
    } else {
      if (kDebugMode) {
        debugPrint('⚠️ 친구를 찾을 수 없음: $userId');
      }
    }
  }

  // 실시간 친구 상태 업데이트 (개선된 버전)
  void _updateFriendStatusImmediately(String userId, bool isOnline) {
    if (kDebugMode) {
      debugPrint('⚡ 실시간 친구 상태 업데이트: $userId = ${isOnline ? '온라인' : '오프라인'}');
    }
    
    // 🔥 원자적 상태 업데이트 사용
    _updateFriendStatusAtomically(userId, isOnline);
  }

  // 친구 위치 업데이트
  void _handleFriendLocationUpdate(Map<String, dynamic> message) {
    final userId = message['userId'];
    final x = message['x'];
    final y = message['y'];
    
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
        break;
      }
    }
    notifyListeners();
  }

  // 위치 공유 상태 변경
  void _handleLocationShareStatusChange(Map<String, dynamic> message) {
    final userId = message['userId'];
    final isLocationPublic = message['isLocationPublic'] ?? false;
    
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
        
        if (!isLocationPublic && oldStatus) {
          _removeFriendLocationFromMap(userId);
        }
        break;
      }
    }

    notifyListeners();
  }

  // 지도에서 친구 위치 마커 제거
  void _removeFriendLocationFromMap(String userId) {
    // MapScreen에서 호출될 예정
    if (kDebugMode) {
      debugPrint('친구 위치 마커 제거 요청: $userId');
    }
  }

  // 친구 상태 새로고침
  Future<void> _refreshFriendStatusFromAPI() async {
    try {
      if (_isGuestUser()) return;

      final newFriends = await repository.refreshFriendStatus();
      bool hasStatusChanges = false;
      
      for (int i = 0; i < newFriends.length; i++) {
        final newFriend = newFriends[i];
            final existingFriend = friends.firstWhere(
              (f) => f.userId == newFriend.userId,
          orElse: () => Friend(userId: '', userName: '', profileImage: '', phone: '', isLogin: false, lastLocation: '', isLocationPublic: false),
        );
        
        if (existingFriend.userId.isNotEmpty) {
          final websocketStatus = onlineUsers.contains(newFriend.userId);
          final apiStatus = newFriend.isLogin;
          
          if (websocketStatus != apiStatus) {
            newFriends[i] = Friend(
              userId: newFriend.userId,
              userName: newFriend.userName,
              profileImage: newFriend.profileImage,
              phone: newFriend.phone,
              isLogin: websocketStatus,
              lastLocation: newFriend.lastLocation,
              isLocationPublic: newFriend.isLocationPublic,
            );
            hasStatusChanges = true;
          } else if (existingFriend.isLogin != apiStatus) {
            hasStatusChanges = true;
            _updateOnlineList(newFriend.userId, newFriend.isLogin);
          }
        }
      }
      
      friends = newFriends;
      
      if (hasStatusChanges) {
          notifyListeners();
      }
      
      if (kDebugMode) {
        debugPrint('/myfriend API 친구 상태 새로고침 완료');
      }
        } catch (e) {
      if (kDebugMode) {
        debugPrint('/myfriend API 친구 상태 새로고침 실패: $e');
      }
    }
  }

  // 친구 상태 동기화 요청
  void _requestFriendStatusSync() {
    if (!isWebSocketConnected || _isGuestUser()) return;

    _wsService.sendMessage({
      'type': 'request_friend_status',
      'userId': myId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // 로그 메시지 필터링
  bool _shouldLogMessage(String messageType) {
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

  // 친구 상태 알림 표시
  void _showFriendStatusNotification(String userId, bool isOnline) {
    final friend = friends.firstWhere(
      (f) => f.userId == userId,
      orElse: () => Friend(userId: userId, userName: '알 수 없는 사용자', profileImage: '', phone: '', isLogin: isOnline, lastLocation: '', isLocationPublic: false),
    );

    final statusText = isOnline ? '온라인' : '오프라인';
    final message = '${friend.userName}님이 $statusText 상태가 되었습니다.';
    
    if (kDebugMode) {
      debugPrint('친구 상태 알림: $message');
    }
  }

  // 비즈니스 로직 메서드들
  Future<void> loadAll() async {
    if (kDebugMode) {
      debugPrint('친구 데이터 새로고침');
    }
    
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (_isGuestUser()) {
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
      
      _updateFriendsOnlineStatus();

      if (kDebugMode) {
        debugPrint('친구 데이터 새로고침 완료');
        debugPrint('친구: ${friends.length}명');
        debugPrint('받은 요청: ${friendRequests.length}개');
        debugPrint('보낸 요청: ${sentFriendRequests.length}개');
        debugPrint('온라인 사용자: ${onlineUsers.length}명');
      }
    } catch (e) {
      errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('친구 데이터 새로고침 실패: $e');
      }
    }

    isLoading = false;
      notifyListeners();
  }

  Future<void> addFriend(String addId) async {
    PerformanceMonitor().startOperation('addFriend');
    
    try {
      errorMessage = null;
        notifyListeners();

      await repository.requestFriend(addId);
      
      _optimisticAddSentRequest(addId);
      _syncSentRequestsInBackground();

      debugPrint('친구 추가 요청 완료');
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      try {
        final newFriends = await repository.getMyFriends();
        final newFriendRequests = await repository.getFriendRequests();
        final newSentFriendRequests = await repository.getSentFriendRequests();

        friends = newFriends;
        friendRequests = newFriendRequests;
        sentFriendRequests = newSentFriendRequests;

        _updateFriendsOnlineStatus();
      } catch (loadError) {
        if (kDebugMode) {
          debugPrint('친구 목록 복구 실패: $loadError');
        }
      }
      rethrow;
    } finally {
      PerformanceMonitor().endOperation('addFriend');
    }
  }

  // 낙관적 업데이트
  void _optimisticAddSentRequest(String addId) {
    final existingRequest = sentFriendRequests.firstWhere(
      (request) => request.toUserId == addId,
      orElse: () => SentFriendRequest(toUserId: '', toUserName: '', requestDate: ''),
    );

    if (existingRequest.toUserId.isEmpty) {
      final newRequest = SentFriendRequest(
        toUserId: addId,
        toUserName: '로딩 중...',
        requestDate: DateTime.now().toIso8601String(),
      );
      
      sentFriendRequests.insert(0, newRequest);
    }
  }

  // 백그라운드 동기화
  Future<void> _syncSentRequestsInBackground() async {
    try {
      final serverSentRequests = await repository.getSentFriendRequests();
      sentFriendRequests = serverSentRequests;
        notifyListeners();
    } catch (e) {
        if (kDebugMode) {
          debugPrint('백그라운드 동기화 실패: $e');
        }
    }
  }

  Future<void> acceptRequest(String addId) async {
    FriendRequest? removedRequest;
    try {
      removedRequest = friendRequests.firstWhere(
        (request) => request.fromUserId == addId,
        orElse: () => FriendRequest(fromUserId: '', fromUserName: '', createdAt: ''),
      );
      
      friendRequests.removeWhere((request) => request.fromUserId == addId);
      notifyListeners();
      
      await repository.acceptRequest(addId);
      _syncFriendsInBackground();
      
      debugPrint('친구 요청 수락 완료');
    } catch (e) {
      if (removedRequest != null && removedRequest.fromUserId.isNotEmpty) {
        friendRequests.add(removedRequest);
        notifyListeners();
      }
      
      errorMessage = e.toString();
            notifyListeners();
      rethrow;
    }
  }

  Future<void> rejectRequest(String addId) async {
    FriendRequest? removedRequest;
    try {
      removedRequest = friendRequests.firstWhere(
        (request) => request.fromUserId == addId,
        orElse: () => FriendRequest(fromUserId: '', fromUserName: '', createdAt: ''),
      );
      
      friendRequests.removeWhere((request) => request.fromUserId == addId);
      notifyListeners();
      
      await repository.rejectRequest(addId);
      
      debugPrint('친구 요청 거절 완료');
    } catch (e) {
      if (removedRequest != null && removedRequest.fromUserId.isNotEmpty) {
        friendRequests.add(removedRequest);
        notifyListeners();
      }
      
      errorMessage = e.toString();
        notifyListeners();
      rethrow;
    }
  }

  // 백그라운드 친구 목록 동기화
  Future<void> _syncFriendsInBackground() async {
    try {
      final serverFriends = await repository.getMyFriends();
      friends = serverFriends;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('백그라운드 친구 목록 동기화 실패: $e');
      }
    }
  }

  Future<void> deleteFriend(String addId) async {
    try {
      await repository.deleteFriend(addId);
      friends.removeWhere((friend) => friend.userId == addId);
      notifyListeners();
      await quickUpdate();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> cancelSentRequest(String friendId) async {
    try {
      await repository.cancelSentRequest(friendId);
      sentFriendRequests.removeWhere((request) => request.toUserId == friendId);
        notifyListeners();
      await quickUpdate();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      rethrow;
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
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 새로고침 메서드
  Future<void> refreshWithAnimation() async {
    if (kDebugMode) {
      debugPrint('새로고침 버튼 클릭');
    }
    
    isRefreshing = true;
    notifyListeners();

    try {
      if (_isGuestUser()) return;

      final actualWsConnected = _wsService.isConnected;
      
      if (_wsMessageSubscription == null || _wsMessageSubscription!.isPaused) {
        _startStreamSubscription();
      }
      
      if (!actualWsConnected) {
        await _wsService.connect(myId);
        await Future.delayed(const Duration(milliseconds: 500));
        _startStreamSubscription();
      }

      await _enhancedFriendStatusSync();
      await loadAll();
      
      _forceUIUpdate();
      
        if (kDebugMode) {
        debugPrint('새로고침 버튼 동기화 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('새로고침 버튼 작업 실패: $e');
      }
    } finally {
      await Future.delayed(const Duration(milliseconds: 1500));
      isRefreshing = false;
      notifyListeners();
    }
  }

  // 강화된 친구 상태 동기화
  Future<void> _enhancedFriendStatusSync() async {
    try {
      final serverFriends = await repository.getMyFriends();
      final actualWsConnected = _wsService.isConnected;
      
      if (actualWsConnected != isWebSocketConnected) {
        isWebSocketConnected = actualWsConnected;
      }
      
      final wsOnlineUsers = actualWsConnected ? onlineUsers : <String>[];
      bool hasChanges = false;
      
      for (int i = 0; i < serverFriends.length; i++) {
        final serverFriend = serverFriends[i];
        final isOnlineInWebSocket = wsOnlineUsers.contains(serverFriend.userId);
        
        bool shouldBeOnline;
        if (actualWsConnected) {
          shouldBeOnline = isOnlineInWebSocket;
          
          if (serverFriend.isLogin && !isOnlineInWebSocket && !onlineUsers.contains(serverFriend.userId)) {
            onlineUsers.add(serverFriend.userId);
            shouldBeOnline = true;
          }
        } else {
          shouldBeOnline = serverFriend.isLogin;
        }
        
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
        }
      }
      
      onlineUsers.clear();
      onlineUsers.addAll(serverFriends.where((f) => f.isLogin).map((f) => f.userId));
      
      friends = serverFriends;
      
      if (hasChanges) {
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('강화된 친구 상태 동기화 실패: $e');
      }
      rethrow;
    }
  }

  // 즉시 동기화
  Future<void> _immediateSync() async {
    try {
      if (_isGuestUser() || isWebSocketConnected) return;

      final newFriends = await repository.getMyFriends();
      friends = newFriends;
      
      _initializeOnlineStatusFromServer();
        _updateFriendsOnlineStatus();
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('즉시 동기화 실패: $e');
      }
    }
  }

  // 조용한 업데이트
  Future<void> _silentUpdate() async {
    try {
      if (_isGuestUser()) return;

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

        if (!newFriendIds.containsAll(currentFriendIds) ||
            !currentFriendIds.containsAll(newFriendIds)) {
              hasChanges = true;
          }
        }
        
        if (hasChanges) {
        friends = newFriends;
        friendRequests = newFriendRequests;
        sentFriendRequests = newSentFriendRequests;
        _lastUpdate = DateTime.now();

        _initializeOnlineStatusFromServer();
        _updateFriendsOnlineStatus();
          notifyListeners();
      }
    } catch (e) {
    if (kDebugMode) {
        debugPrint('백그라운드 업데이트 실패: $e');
      }
    }
  }

  // 빠른 업데이트
  Future<void> quickUpdate() async {
    await _silentUpdate();
  }

  // 친구들의 온라인 상태 업데이트
  void _updateFriendsOnlineStatus() {
    if (isWebSocketConnected) {
      _updateFriendsStatusFromWebSocket();
    } else {
      _updateFriendsStatusFromServer();
    }
  }

  // 웹소켓 데이터 기반 친구 상태 업데이트
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
        hasChanges = true;
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  // 서버 데이터 기반 친구 상태 업데이트
  void _updateFriendsStatusFromServer() {
    bool hasChanges = false;

    for (int i = 0; i < friends.length; i++) {
      final isOnlineInServer = friends[i].isLogin;
      final isOnlineInWebSocket = onlineUsers.contains(friends[i].userId);

      if (isOnlineInServer != isOnlineInWebSocket) {
        if (isOnlineInServer && !isOnlineInWebSocket) {
          onlineUsers.add(friends[i].userId);
        } else if (!isOnlineInServer && isOnlineInWebSocket) {
          onlineUsers.remove(friends[i].userId);
        }
        hasChanges = true;
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  // 실시간 업데이트 시작
  void _startRealTimeUpdates() {
    _stopPollingCompletely();
    _isRealTimeEnabled = true;

    _updateTimer = Timer.periodic(_updateInterval, (timer) async {
      await _checkAndRecoverWebSocketConnection();
      
      if (isWebSocketConnected) {
        await _refreshFriendStatusFromAPI();
        return;
      }

      if (_isRealTimeEnabled) {
        await _immediateSync();
      }
    });
  }

  // 웹소켓 연결 상태 확인 및 복구
  Future<void> _checkAndRecoverWebSocketConnection() async {
    try {
      final currentConnectionStatus = _wsService.isConnected;
      
      if (!currentConnectionStatus && !_isGuestUser()) {
        try {
          await _wsService.connect(myId);
          await Future.delayed(const Duration(milliseconds: 100));
          
          if (_wsService.isConnected) {
            isWebSocketConnected = true;
            _refreshFriendStatusFromAPI();
        notifyListeners();
        return;
      }
    } catch (e) {
          if (kDebugMode) {
            debugPrint('웹소켓 재연결 실패: $e');
          }
        }
      }
      
      if (currentConnectionStatus != isWebSocketConnected) {
        isWebSocketConnected = currentConnectionStatus;
        
        if (currentConnectionStatus) {
          _refreshFriendStatusFromAPI();
        } else {
          _startRealTimeUpdates();
        }
        
      notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('웹소켓 연결 상태 확인 중 오류: $e');
      }
    }
  }

  // 온라인 사용자 업데이트 메시지 처리
  void _handleOnlineUsersUpdateMessage(Map<String, dynamic> message) {
    final onlineUsersList = message['onlineUsers'];
    
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

  // 강제 UI 업데이트
  void _forceUIUpdate() {
    _lastUpdate = DateTime.now();
    
    final updatedFriends = friends.map((friend) => Friend(
      userId: friend.userId,
      userName: friend.userName,
      profileImage: friend.profileImage,
      phone: friend.phone,
      isLogin: friend.isLogin,
      lastLocation: friend.lastLocation,
      isLocationPublic: friend.isLocationPublic,
    )).toList();
    
    friends = updatedFriends;
      notifyListeners();
    
    Future.microtask(() => notifyListeners());
  }

  // 기타 메서드들
  void stopRealTimeUpdates() {
    _isRealTimeEnabled = false;
    _updateTimer?.cancel();
  }

  void resumeRealTimeUpdates() {
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

  bool isFriendOnline(String userId) {
    final friend = friends.firstWhere(
      (f) => f.userId == userId,
      orElse: () => Friend(userId: userId, userName: '알 수 없음', profileImage: '', phone: '', isLogin: false, lastLocation: '', isLocationPublic: false),
    );
    return friend.isLogin;
  }

  String get connectionStatus {
    if (isWebSocketConnected) {
      return '실시간 연결됨';
    } else {
      return '폴링 모드';
    }
  }

  // 디버깅 메서드
  void debugPrintStatus() {
    if (kDebugMode) {
      debugPrint('FriendsController 상태 디버깅');
      debugPrint('친구 수: ${friends.length}');
      debugPrint('온라인 사용자 수: ${onlineUsers.length}');
      debugPrint('웹소켓 연결 상태: $isWebSocketConnected');
      debugPrint('실시간 업데이트 활성화: $_isRealTimeEnabled');
    }
  }

  // 사용자 변경 시 데이터 초기화
  void clearAllData() {
    if (kDebugMode) {
      debugPrint('FriendsController 데이터 초기화 시작');
    }
    
    // 🔥 1. 웹소켓 연결 해제 (사용자 변경 대비)
    _disconnectWebSocket();
    
    // 🔥 2. 데이터 초기화
    _clearAllData();
    
    isLoading = false;
    isRefreshing = false;
    errorMessage = null;
    isWebSocketConnected = false;
    
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('FriendsController 데이터 초기화 완료');
    }
  }

  // 리소스 정리
  void _cleanupResources() {
    _updateTimer?.cancel();
    _updateTimer = null;

    try {
      _wsMessageSubscription?.cancel();
      _wsConnectionSubscription?.cancel();
      _wsOnlineUsersSubscription?.cancel();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('리소스 정리 중 오류: $e');
      }
    }
  }

  // 모든 데이터 초기화
  void _clearAllData() {
    friends.clear();
    friendRequests.clear();
    sentFriendRequests.clear();
    onlineUsers.clear();
    _realTimeStatusCache.clear();
    _statusTimestamp.clear();
  }

  @override
  void dispose() {
    if (kDebugMode) {
      debugPrint('FriendsController 정리 시작');
    }

    _clearAllData();
    _cleanupResources();

    super.dispose();
    
    if (kDebugMode) {
      debugPrint('FriendsController 정리 완료');
    }
  }
}
