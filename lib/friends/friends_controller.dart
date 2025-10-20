// lib/friends/friends_controller.dart - 최적화된 친구 관리 컨트롤러
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'friend.dart';
import 'friend_repository.dart';
import '../services/websocket_service.dart';
import '../services/notification_service.dart';
import '../services/performance_monitor.dart';
import '../services/api_helper.dart';

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
  
  // 🔥 백그라운드 상태 관리
  Timer? _backgroundTimer;
  DateTime? _backgroundEnterTime;

  // 친구 요청 알림 콜백
  Function(String)? _onFriendRequestNotification;
  
  // 🔥 친구 요청 수락 알림 콜백 (새로 추가)
  Function(String)? _onFriendRequestAcceptedNotification;
  
  // 🔥 친구 요청 취소 알림 콜백 (새로 추가)
  Function(String)? _onFriendRequestCancelledNotification;

  FriendsController(this.repository, this.myId) {
    _initializeController();
  }

  // 친구 요청 알림 콜백 설정
  void setOnFriendRequestNotification(Function(String)? callback) {
    _onFriendRequestNotification = callback;
  }
  
  // 🔥 친구 요청 수락 알림 콜백 설정 (새로 추가)
  void setOnFriendRequestAcceptedNotification(Function(String)? callback) {
    _onFriendRequestAcceptedNotification = callback;
  }
  
  // 🔥 친구 요청 취소 알림 콜백 설정 (새로 추가)
  void setOnFriendRequestCancelledNotification(Function(String)? callback) {
    _onFriendRequestCancelledNotification = callback;
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

    // 🔥 같은 사용자로 이미 연결되어 있으면 재연결하지 않음
    if (_wsService.isConnected && _wsService.currentUserId == myId) {
      if (kDebugMode) {
        debugPrint('✅ 이미 같은 사용자로 연결되어 있음 - 재연결 건너뛰기');
      }
      return;
    }

    // 🔥 다른 사용자로 연결되어 있으면 기존 연결 해제
    if (_wsService.isConnected && _wsService.currentUserId != myId) {
      if (kDebugMode) {
        debugPrint('🔄 다른 사용자로 연결됨 - 기존 웹소켓 연결 해제 후 재연결');
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
      if (kDebugMode) {
        debugPrint('🔄 웹소켓 연결 후 친구 상태 동기화 시작');
      }
      
      // 🔥 API를 통한 친구 상태 새로고침 (1회만)
      await _refreshFriendStatusFromAPI();
      
      // 🔥 추가 동기화 (서버 응답 대기)
      await Future.delayed(const Duration(milliseconds: 500));
      _syncWithServerData();
      
      if (kDebugMode) {
        debugPrint('✅ 웹소켓 연결 후 친구 상태 동기화 완료');
      }
    }
  }

  // 🔥 Login_Status 메시지 처리
  void _handleLoginStatusMessage(Map<String, dynamic> message) {
    try {
      final userId = message['userId'] as String?;
      final statusRaw = message['status'];
      
      if (userId == null || userId.isEmpty) {
        if (kDebugMode) {
          debugPrint('❌ Login_Status 메시지에 userId가 없음');
        }
        return;
      }
      
      // 🔥 상태 값 정규화
      final isOnline = _normalizeBooleanValue(statusRaw);
      
      if (kDebugMode) {
        debugPrint('📶 Login_Status 메시지 처리: $userId = ${isOnline ? '온라인' : '오프라인'}');
      }
      
      // 🔥 친구 상태 즉시 업데이트
      _updateFriendStatusImmediately(userId, isOnline);
      
      // 🔥 온라인 사용자 목록 업데이트
      _updateOnlineList(userId, isOnline);
      
      // 🔥 UI 업데이트
      notifyListeners();
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Login_Status 메시지 처리 중 오류: $e');
      }
    }
  }

  // 새 친구 요청 알림 처리
  void _handleNewFriendRequest(Map<String, dynamic> message) {
    try {
      final fromUserName = message['fromUserName'] as String?;
      final fromUserId = message['fromUserId'] as String?;
      
      if (kDebugMode) {
        debugPrint('🔥 새 친구 요청 알림 수신: $fromUserName($fromUserId)');
        debugPrint('🔥 메시지 전체 내용: $message');
      }
      
      // 🔥 햅틱 피드백으로 사용자에게 알림
      HapticFeedback.mediumImpact();
      
      // 🔥 알림 콜백 호출
      if (_onFriendRequestNotification != null && fromUserName != null) {
        _onFriendRequestNotification!(fromUserName);
      }
      
      // 🔥 친구 요청 목록 즉시 새로고침 (강화된 버전)
      _immediateFriendRequestUpdate();
      
      // 🔥 추가로 전체 데이터도 새로고침 (확실한 동기화)
      Future.delayed(const Duration(milliseconds: 200), () {
        if (kDebugMode) {
          debugPrint('🔥 추가 전체 데이터 새로고침 실행');
        }
        loadAll();
      });
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔥 친구 요청 알림 처리 중 오류: $e');
      }
    }
  }
  
  // 🔥 친구 요청 목록 즉시 업데이트 (강화된 버전)
  Future<void> _immediateFriendRequestUpdate() async {
    try {
      if (kDebugMode) {
        debugPrint('🔥 친구 요청 목록 즉시 업데이트 시작');
      }
      
      // 🔥 API 캐시 초기화 후 친구 요청 목록 새로고침
      await _clearApiCache();
      final newFriendRequests = await repository.getFriendRequests();
      
      // 🔥 받은 요청 목록 업데이트
      friendRequests = newFriendRequests;
      
      if (kDebugMode) {
        debugPrint('🔥 친구 요청 목록 즉시 업데이트 완료: ${friendRequests.length}개');
        for (final request in friendRequests) {
          debugPrint('  - ${request.fromUserName}(${request.fromUserId})');
        }
      }
      
      // 🔥 UI 즉시 업데이트 (여러 번 호출하여 확실히 업데이트)
      notifyListeners();
      Future.microtask(() => notifyListeners());
      Future.delayed(const Duration(milliseconds: 50), () => notifyListeners());
      Future.delayed(const Duration(milliseconds: 100), () => notifyListeners());
      
      // 🔥 추가로 전체 데이터도 백그라운드에서 새로고침
      Future.microtask(() => quickUpdate());
      
      // 🔥 추가로 전체 데이터 로드도 실행
      Future.delayed(const Duration(milliseconds: 300), () => loadAll());
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔥 친구 요청 목록 즉시 업데이트 실패: $e');
      }
      
      // 🔥 실패 시 기존 방법으로 폴백
      Future.microtask(() => quickUpdate());
      Future.delayed(const Duration(milliseconds: 500), () => loadAll());
    }
  }
  
  // 🔥 친구 요청 수락 알림 처리 (새로 추가)
  void _handleFriendRequestAccepted(Map<String, dynamic> message) {
    try {
      final acceptedByUserName = message['acceptedByUserName'] as String?;
      final acceptedByUserId = message['acceptedByUserId'] as String?;
      
      if (kDebugMode) {
        debugPrint('🔥 친구 요청 수락 알림 수신: $acceptedByUserName($acceptedByUserId)이 내 요청을 수락함');
      }
      
      // 🔥 햅틱 피드백으로 사용자에게 알림
      HapticFeedback.mediumImpact();
      
      // 🔥 친구 요청 수락 알림 콜백 호출
      if (_onFriendRequestAcceptedNotification != null && acceptedByUserName != null) {
        _onFriendRequestAcceptedNotification!(acceptedByUserName);
      }
      
      // 🔥 친구 목록 즉시 업데이트 (새 친구 추가)
      _immediateFriendListUpdate();
      
      // 🔥 보낸 요청 목록에서 해당 요청 제거
      _removeFromSentRequests(acceptedByUserId);
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔥 친구 요청 수락 알림 처리 중 오류: $e');
      }
    }
  }

  // 🔥 친구 요청 취소 알림 처리 (새로 추가)
  void _handleFriendRequestCancelled(Map<String, dynamic> message) {
    try {
      final cancelledByUserName = message['cancelledByUserName'] as String?;
      final cancelledByUserId = message['cancelledByUserId'] as String?;
      
      if (kDebugMode) {
        debugPrint('🔥 친구 요청 취소 알림 수신: $cancelledByUserName($cancelledByUserId)이 내게 보낸 요청을 취소함');
      }
      
      // 🔥 햅틱 피드백으로 사용자에게 알림
      HapticFeedback.lightImpact();
      
      // 🔥 친구 요청 취소 알림 콜백 호출
      if (_onFriendRequestCancelledNotification != null && cancelledByUserName != null) {
        _onFriendRequestCancelledNotification!(cancelledByUserName);
      }
      
      // 🔥 받은 요청 목록에서 해당 요청 즉시 제거
      _removeFromReceivedRequests(cancelledByUserId);
      
      // 🔥 추가로 전체 데이터도 새로고침 (확실한 동기화)
      Future.delayed(const Duration(milliseconds: 200), () {
        if (kDebugMode) {
          debugPrint('🔥 친구 요청 취소 후 전체 데이터 새로고침 실행');
        }
        loadAll();
      });
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔥 친구 요청 취소 알림 처리 중 오류: $e');
      }
    }
  }
  
  // 🔥 친구 목록 즉시 업데이트 (개선된 버전)
  Future<void> _immediateFriendListUpdate() async {
    try {
      if (kDebugMode) {
        debugPrint('🔥 친구 목록 즉시 업데이트 시작');
      }
      
      // 🔥 서버에서 최신 친구 목록 가져오기
      final updatedFriends = await repository.refreshFriendStatus();
      
      // 🔥 기존 친구 목록과 비교하여 새 친구 찾기
      final previousFriendIds = friends.map((f) => f.userId).toSet();
      final newFriendIds = updatedFriends.map((f) => f.userId).toSet();
      final addedFriendIds = newFriendIds.difference(previousFriendIds);
      
      // 🔥 친구 목록 업데이트
      friends = updatedFriends;
      
      // 🔥 온라인 상태 업데이트
      _updateFriendsOnlineStatus();
      
      // 🔥 UI 즉시 업데이트
      notifyListeners();
      
      if (kDebugMode) {
        debugPrint('🔥 친구 목록 즉시 업데이트 완료: ${friends.length}명');
        if (addedFriendIds.isNotEmpty) {
          debugPrint('🔥 새로 추가된 친구: ${addedFriendIds.join(', ')}');
        }
      }
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔥 친구 목록 즉시 업데이트 실패: $e');
      }
      
      // 🔥 실패 시 기존 데이터 새로고침
      await quickUpdate();
    }
  }
  
  // 🔥 보낸 요청 목록에서 해당 요청 제거 (새로 추가)
  void _removeFromSentRequests(String? userId) {
    if (userId == null || userId.isEmpty) return;
    
    try {
      final removedCount = sentFriendRequests.length;
      sentFriendRequests.removeWhere((request) => request.toUserId == userId);
      final newCount = sentFriendRequests.length;
      
      if (removedCount != newCount) {
        if (kDebugMode) {
          debugPrint('🔥 보낸 요청 목록에서 제거: $userId (${removedCount - newCount}개 제거됨)');
        }
        
        // 🔥 UI 즉시 업데이트
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔥 보낸 요청 목록 제거 중 오류: $e');
      }
    }
  }

  // 🔥 받은 요청 목록에서 해당 요청 제거 (새로 추가)
  void _removeFromReceivedRequests(String? userId) {
    if (userId == null || userId.isEmpty) return;
    
    try {
      final removedCount = friendRequests.length;
      friendRequests.removeWhere((request) => request.fromUserId == userId);
      final newCount = friendRequests.length;
      
      if (removedCount != newCount) {
        if (kDebugMode) {
          debugPrint('🔥 받은 요청 목록에서 제거: $userId (${removedCount - newCount}개 제거됨)');
        }
        
        // 🔥 UI 즉시 업데이트
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔥 받은 요청 목록 제거 중 오류: $e');
      }
    }
  }

  // 웹소켓 메시지 처리 (개선된 버전)
  void _handleWebSocketMessage(Map<String, dynamic> message) {
    final messageType = message['type'] as String?;
    
    if (kDebugMode) {
      debugPrint('🔥 웹소켓 메시지 수신: $messageType');
      debugPrint('🔥 메시지 내용: $message');
      debugPrint('🔥 현재 사용자 ID: $myId');
      debugPrint('🔥 WebSocket 연결 상태: $isWebSocketConnected');
    }
    
    if (_isGuestUser()) {
      if (kDebugMode) {
        debugPrint('🔥 게스트 사용자 - 메시지 무시');
      }
      return;
    }

    if (messageType == null) {
      if (kDebugMode) {
        debugPrint('🔥 유효하지 않은 웹소켓 메시지: type 필드 없음');
      }
      return;
    }

    try {
      switch (messageType) {
        case 'new_friend_request':
          if (kDebugMode) {
            debugPrint('🔥 새 친구 요청 메시지 처리 시작');
          }
          _handleNewFriendRequest(message);
          break;
        case 'friend_request_accepted':
          if (kDebugMode) {
            debugPrint('🔥 친구 요청 수락 메시지 처리 시작');
          }
          _handleFriendRequestAccepted(message);
          break;
        case 'friend_request_rejected':
          if (kDebugMode) {
            debugPrint('🔥 친구 요청 거절 메시지 처리');
          }
          quickUpdate();
          break;
        case 'friend_request_cancelled':
          if (kDebugMode) {
            debugPrint('🔥 친구 요청 취소 메시지 처리');
          }
          _handleFriendRequestCancelled(message);
          break;
        case 'friend_deleted':
          if (kDebugMode) {
            debugPrint('🔥 친구 삭제 메시지 처리');
          }
          quickUpdate();
          break;
        case 'friend_status_change':
          if (kDebugMode) {
            debugPrint('🔥 친구 상태 변경 메시지 처리');
          }
          _handleFriendStatusChange(message);
          break;
        case 'Login_Status':
          // 🔥 Login_Status 메시지 처리 (친구의 로그인/로그아웃 상태 변경)
          _handleLoginStatusMessage(message);
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
        
        // 🔥 강제 온라인 상태 유지 모드 활성화
        _forceOnlineStatusMaintenance();
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
    if (kDebugMode) {
      debugPrint('👥 온라인 사용자 목록 업데이트 수신: ${users.length}명');
      debugPrint('👥 온라인 사용자: ${users.join(', ')}');
    }
    
    // 🔥 온라인 사용자 목록 업데이트
    onlineUsers = users;
    
    // 🔥 서버 데이터와 동기화
    _syncWithServerData();
    
    // 🔥 친구 상태 업데이트
    _updateFriendsOnlineStatus();
    
    // 🔥 UI 업데이트
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('✅ 온라인 사용자 목록 업데이트 완료');
      debugPrint('✅ 현재 온라인 친구 수: ${onlineUsers.length}명');
    }
  }

  // 서버 데이터와 웹소켓 데이터 동기화 (개선된 버전)
  void _syncWithServerData() {
    bool hasChanges = false;

    if (kDebugMode) {
      debugPrint('🔄 서버-웹소켓 데이터 동기화 시작');
      debugPrint('🔄 웹소켓 연결 상태: $isWebSocketConnected');
      debugPrint('🔄 온라인 사용자 수: ${onlineUsers.length}');
      debugPrint('🔄 친구 수: ${friends.length}');
    }

    for (int i = 0; i < friends.length; i++) {
      final friend = friends[i];
      final isOnlineInServer = friend.isLogin;
      final isOnlineInWebSocket = onlineUsers.contains(friend.userId);

      bool shouldBeOnline;
      if (isWebSocketConnected) {
        // 🔥 웹소켓 연결 시: 웹소켓 데이터 우선 (DB 상태 무시)
        // DB의 Is_Login이 오래되었을 수 있으므로 웹소켓 연결 상태만 사용
        shouldBeOnline = isOnlineInWebSocket;
        
        if (kDebugMode) {
          debugPrint('🔄 친구 ${friend.userName}: 서버=${isOnlineInServer}, 웹소켓=${isOnlineInWebSocket} → 최종=${shouldBeOnline} (웹소켓 우선)');
        }
      } else {
        // 🔥 웹소켓 연결 안됨: 서버 데이터 사용
        shouldBeOnline = isOnlineInServer;
        
        if (kDebugMode) {
          debugPrint('🔄 친구 ${friend.userName}: 웹소켓 연결 안됨, 서버 데이터 사용 → 최종=${shouldBeOnline}');
        }
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
          debugPrint('🔄 친구 상태 변경: ${friend.userName} = ${shouldBeOnline ? '온라인' : '오프라인'}');
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
  
  // 🔥 강제 온라인 상태 유지 메서드 (서버 오프라인 처리 우회)
  void _forceOnlineStatusMaintenance() {
    if (kDebugMode) {
      debugPrint('🛡️ 온라인 상태 강제 유지 모드 활성화');
    }
    
    // 🔥 현재 사용자가 온라인 사용자 목록에 없으면 추가
    if (!onlineUsers.contains(myId)) {
      onlineUsers.add(myId);
      if (kDebugMode) {
        debugPrint('🛡️ 현재 사용자를 온라인 목록에 강제 추가: $myId');
      }
    }
    
    // 🔥 더 빈번한 온라인 상태 확인 (15초마다)
    Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!isWebSocketConnected || _isGuestUser()) {
        timer.cancel();
        return;
      }
      
      // 🔥 현재 사용자가 온라인 목록에 없으면 강제로 추가
      if (!onlineUsers.contains(myId)) {
        onlineUsers.add(myId);
        if (kDebugMode) {
          debugPrint('🛡️ 현재 사용자를 온라인 목록에 재추가: $myId');
        }
      }
      
      // 🔥 WebSocket 연결 상태 강제 확인
      _verifyWebSocketConnection();
      
      // 🔥 서버 데이터 새로고침
      _refreshFriendStatusFromAPI();
      if (kDebugMode) {
        debugPrint('🛡️ 강제 온라인 상태 유지를 위한 서버 데이터 새로고침');
      }
    });
    
    // 🔥 추가: 5초마다 온라인 상태 강제 확인
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!isWebSocketConnected || _isGuestUser()) {
        timer.cancel();
        return;
      }
      
      // 🔥 현재 사용자 온라인 상태 강제 확인
      _enforceCurrentUserOnline();
    });
  }
  
  // 🔥 WebSocket 연결 상태 강제 확인
  void _verifyWebSocketConnection() {
    try {
      if (_wsService.isConnected) {
        // 🔥 연결이 유지되고 있으면 하트비트 전송
        _wsService.sendHeartbeat();
        if (kDebugMode) {
          debugPrint('🛡️ WebSocket 연결 상태 확인 및 하트비트 전송');
        }
      } else {
        // 🔥 연결이 끊어졌으면 재연결 시도
        if (kDebugMode) {
          debugPrint('🛡️ WebSocket 연결 끊김 감지 - 재연결 시도');
        }
        _initializeWithWebSocket();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🛡️ WebSocket 연결 확인 중 오류: $e');
      }
    }
  }
  
  // 🔥 현재 사용자 온라인 상태 강제 확인
  void _enforceCurrentUserOnline() {
    // 🔥 현재 사용자가 온라인 목록에 없으면 즉시 추가
    if (!onlineUsers.contains(myId)) {
      onlineUsers.add(myId);
      if (kDebugMode) {
        debugPrint('🛡️ 현재 사용자 온라인 상태 강제 복구: $myId');
      }
    }
    
    // 🔥 현재 사용자가 온라인 목록에 없으면 강제로 추가
    if (!onlineUsers.contains(myId)) {
      onlineUsers.add(myId);
      if (kDebugMode) {
        debugPrint('🛡️ 현재 사용자 온라인 상태 강제 유지: $myId');
      }
      notifyListeners();
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

    // 🔥 현재 사용자의 오프라인 상태 변경은 완전 무시 (강제 온라인 유지)
    if (userId == myId) {
      if (message['isOnline'] == false) {
        if (kDebugMode) {
          debugPrint('🛡️ 현재 사용자의 오프라인 상태 변경 완전 무시: $userId');
        }
        
        // 🔥 현재 사용자를 온라인 목록에 강제로 추가
        if (!onlineUsers.contains(myId)) {
          onlineUsers.add(myId);
          if (kDebugMode) {
            debugPrint('🛡️ 현재 사용자를 온라인 목록에 강제 재추가: $myId');
          }
        }
        
        // 🔥 현재 사용자의 친구 상태도 온라인으로 강제 설정
        _enforceCurrentUserOnline();
        return;
      } else if (message['isOnline'] == true) {
        // 🔥 온라인 상태는 허용하되, 이미 온라인 목록에 추가
        if (!onlineUsers.contains(myId)) {
          onlineUsers.add(myId);
          if (kDebugMode) {
            debugPrint('🛡️ 현재 사용자를 온라인 목록에 추가: $myId');
          }
        }
      }
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
      debugPrint('📶 메시지 출처: ${message['source'] ?? 'unknown'}');
    }

    // 🔥 중복 처리 방지: 같은 상태로 변경되는 경우 무시
    final friend = friends.firstWhere(
      (f) => f.userId == userId,
      orElse: () => Friend(userId: userId, userName: '알 수 없음', profileImage: '', phone: '', isLogin: false, lastLocation: '', isLocationPublic: false),
    );
    
    if (friend.isLogin == isOnline) {
      if (kDebugMode) {
        debugPrint('⚠️ 친구 상태가 이미 동일함 - 처리 무시: $userId = ${isOnline ? '온라인' : '오프라인'}');
      }
      return;
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

  // 🔥 원자적 친구 상태 업데이트 (개선된 버전)
  void _updateFriendStatusAtomically(String userId, bool isOnline) {
    if (kDebugMode) {
      debugPrint('🔄 친구 상태 원자적 업데이트 시작: $userId = ${isOnline ? '온라인' : '오프라인'}');
    }
    
    // 1. 온라인 사용자 목록 업데이트
    _updateOnlineList(userId, isOnline);
    
    // 2. 친구 목록에서 상태 업데이트
    _updateFriendInList(userId, isOnline);
    
    // 3. UI 업데이트 (마이크로태스크로 지연하여 안정성 확보)
    Future.microtask(() {
      notifyListeners();
      if (kDebugMode) {
        debugPrint('✅ 친구 상태 원자적 업데이트 완료: $userId');
      }
    });
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
    } else {
      if (kDebugMode) {
        debugPrint('ℹ️ 온라인 사용자 목록 변경 없음: $userId = ${isOnline ? '온라인' : '오프라인'}');
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

  // 친구 상태 새로고침 (public 메서드로 변경)
  Future<void> refreshFriendStatusFromAPI() async {
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
          
          // 🔥 웹소켓 연결 시: 웹소켓 상태 우선 (DB 상태 무시)
          if (isWebSocketConnected) {
            // 웹소켓에서 온라인인데 DB에서 오프라인인 경우 → 웹소켓 상태 유지
            if (websocketStatus && !apiStatus) {
              newFriends[i] = Friend(
                userId: newFriend.userId,
                userName: newFriend.userName,
                profileImage: newFriend.profileImage,
                phone: newFriend.phone,
                isLogin: true, // 🔥 웹소켓 상태 우선
                lastLocation: newFriend.lastLocation,
                isLocationPublic: newFriend.isLocationPublic,
              );
              hasStatusChanges = true;
              
              if (kDebugMode) {
                debugPrint('🔧 ${newFriend.userName} 상태 보정: DB=오프라인 → 웹소켓=온라인 유지');
              }
            }
            // 웹소켓에서 오프라인인데 DB에서 온라인인 경우 → 웹소켓 상태 유지
            else if (!websocketStatus && apiStatus) {
              newFriends[i] = Friend(
                userId: newFriend.userId,
                userName: newFriend.userName,
                profileImage: newFriend.profileImage,
                phone: newFriend.phone,
                isLogin: false, // 🔥 웹소켓 상태 우선
                lastLocation: newFriend.lastLocation,
                isLocationPublic: newFriend.isLocationPublic,
              );
              hasStatusChanges = true;
              
              if (kDebugMode) {
                debugPrint('🔧 ${newFriend.userName} 상태 보정: DB=온라인 → 웹소켓=오프라인 유지');
              }
            }
          } else {
            // 🔥 웹소켓 연결 안됨: DB 상태 사용
            if (existingFriend.isLogin != apiStatus) {
              hasStatusChanges = true;
              _updateOnlineList(newFriend.userId, newFriend.isLogin);
            }
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

  // 🔥 포그라운드 복귀 시 호출되는 메서드 (개선된 버전)
  Future<void> onAppResumed() async {
    if (kDebugMode) {
      debugPrint('🔄 포그라운드 복귀 - 친구 상태 동기화 시작 (네이버 지도/카카오맵 방식)');
    }
    
    // 🔥 백그라운드 타이머 취소
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
    
    // 🔥 백그라운드에 있었던 시간 계산
    if (_backgroundEnterTime != null) {
      final backgroundDuration = DateTime.now().difference(_backgroundEnterTime!);
      if (kDebugMode) {
        debugPrint('⏱️ 백그라운드에 있었던 시간: ${backgroundDuration.inSeconds}초');
      }
    }
    
    try {
      // 🔥 1. 웹소켓 연결 상태 확인 및 재연결 시도
      if (!_wsService.isConnected && !_isGuestUser()) {
        if (kDebugMode) {
          debugPrint('⚠️ 포그라운드 복귀 - 웹소켓 연결 끊김, 재연결 시도');
        }
        
        // 🔥 웹소켓 재연결 시도
        await _wsService.connect(myId);
        await Future.delayed(const Duration(milliseconds: 1000));
        
        if (_wsService.isConnected) {
          isWebSocketConnected = true;
          
          if (kDebugMode) {
            debugPrint('✅ 포그라운드 복귀 - 웹소켓 재연결 성공');
          }
          
          // 🔥 재연결 후 친구 상태 동기화
          await _syncFriendStatusAfterReconnection();
        } else {
          if (kDebugMode) {
            debugPrint('❌ 포그라운드 복귀 - 웹소켓 재연결 실패, 폴링 모드로 전환');
          }
          _startRealTimeUpdates();
        }
      } else if (_wsService.isConnected) {
        isWebSocketConnected = true;
        
        if (kDebugMode) {
          debugPrint('✅ 포그라운드 복귀 - 웹소켓 연결 유지됨');
          debugPrint('✅ 현재 온라인 친구 수: ${onlineUsers.length}명');
        }
        
        // 🔥 2. 하트비트 전송으로 연결 활성화 (네이버 지도/카카오맵 방식)
        _wsService.sendHeartbeat();
        
        // 🔥 3. 온라인 사용자 목록 요청
        _wsService.sendMessage({
          'type': 'request_online_users',
          'userId': myId,
          'timestamp': DateTime.now().toIso8601String(),
        });
        
        // 🔥 4. 웹소켓 연결 상태를 우선시하고 UI만 업데이트
        // API 호출을 하지 않음 (DB 상태가 오래되었을 수 있음)
        _syncWithServerData();
        
        // 🔥 5. UI 업데이트
        notifyListeners();
        
        if (kDebugMode) {
          debugPrint('✅ 포그라운드 복귀 - 친구 상태 동기화 완료 (웹소켓 상태 유지)');
        }
      } else {
        if (kDebugMode) {
          debugPrint('⚠️ 포그라운드 복귀 - 웹소켓 연결 안됨, 폴링 모드로 전환');
        }
        _startRealTimeUpdates();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 포그라운드 복귀 - 친구 상태 동기화 실패: $e');
      }
    }
  }
  
  // 🔥 백그라운드 진입 시 호출되는 메서드 (개선된 버전)
  Future<void> onAppPaused() async {
    if (kDebugMode) {
      debugPrint('📱 백그라운드 진입 - 웹소켓 연결 유지 (네이버 지도/카카오맵 방식)');
    }
    
    _backgroundEnterTime = DateTime.now();
    
    // 🔥 기존 백그라운드 타이머 취소
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
    
    // 🔥 웹소켓 연결 유지 (백그라운드에서도 친구들이 온라인 상태를 볼 수 있음)
    // 위치 전송만 중지하고 웹소켓은 계속 유지하여 실시간 친구 상태 확인 가능
    if (kDebugMode) {
      debugPrint('✅ 백그라운드 진입 - 웹소켓 연결 유지, 위치 전송만 중지');
      debugPrint('✅ 친구들이 당신을 온라인으로 계속 볼 수 있습니다');
    }
    
    // 🔥 실시간 업데이트는 이미 stopRealTimeUpdates()에서 처리됨
  }
  
  // 🔥 웹소켓 재연결 후 친구 상태 동기화
  Future<void> _syncFriendStatusAfterReconnection() async {
    if (kDebugMode) {
      debugPrint('🔄 웹소켓 재연결 후 친구 상태 동기화 시작');
    }
    
    try {
      // 🔥 1. 친구 목록 새로고침
      await loadAll();
      
      // 🔥 2. 서버에서 친구 상태 확인
      await Future.delayed(const Duration(milliseconds: 500));
      await _refreshFriendStatusFromAPI();
      
      // 🔥 3. 동기화
      _syncWithServerData();
      
      // 🔥 4. UI 업데이트
      notifyListeners();
      
      if (kDebugMode) {
        debugPrint('✅ 웹소켓 재연결 후 친구 상태 동기화 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 웹소켓 재연결 후 친구 상태 동기화 실패: $e');
      }
    }
  }

  // 🔥 내부에서 사용하는 private 메서드 (기존 코드 호환성 유지)
  Future<void> _refreshFriendStatusFromAPI() async {
    await refreshFriendStatusFromAPI();
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
    
    // 🔥 실제 알림 표시 로직은 필요시 여기에 추가
    // 예: Flutter의 showNotification 또는 다른 알림 시스템 사용
  }

  // 비즈니스 로직 메서드들
  Future<void> loadAll() async {
    if (kDebugMode) {
      debugPrint('🔥 친구 데이터 새로고침 시작');
    }
    
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (_isGuestUser()) {
        if (kDebugMode) {
          debugPrint('🔥 게스트 사용자 - 데이터 초기화');
        }
        friends = [];
        friendRequests = [];
        sentFriendRequests = [];
        isLoading = false;
        notifyListeners();
        return;
      }

      if (kDebugMode) {
        debugPrint('🔥 서버에서 친구 데이터 로드 시작');
      }

      // 🔥 순차적으로 데이터 로드 (안정성 확보)
      final newFriends = await repository.getMyFriends();
      if (kDebugMode) {
        debugPrint('🔥 친구 목록 로드 완료: ${newFriends.length}명');
      }

      friendRequests = await repository.getFriendRequests();
      if (kDebugMode) {
        debugPrint('🔥 받은 요청 로드 완료: ${friendRequests.length}개');
        for (final request in friendRequests) {
          debugPrint('🔥   - ${request.fromUserName}(${request.fromUserId})');
        }
      }

      sentFriendRequests = await repository.getSentFriendRequests();
      if (kDebugMode) {
        debugPrint('🔥 보낸 요청 로드 완료: ${sentFriendRequests.length}개');
      }

      // 🔥 웹소켓 연결 시: 웹소켓 상태를 우선시하여 DB 상태 보정
      if (isWebSocketConnected) {
        if (kDebugMode) {
          debugPrint('🔥 웹소켓 연결 상태 우선 - DB 상태 보정 시작');
        }
        
        // 각 친구의 상태를 웹소켓 상태로 보정
        for (int i = 0; i < newFriends.length; i++) {
          final friend = newFriends[i];
          final websocketStatus = onlineUsers.contains(friend.userId);
          final apiStatus = friend.isLogin;
          
          // 웹소켓 상태와 DB 상태가 다른 경우 웹소켓 상태로 보정
          if (websocketStatus != apiStatus) {
            newFriends[i] = Friend(
              userId: friend.userId,
              userName: friend.userName,
              profileImage: friend.profileImage,
              phone: friend.phone,
              isLogin: websocketStatus, // 🔥 웹소켓 상태 우선
              lastLocation: friend.lastLocation,
              isLocationPublic: friend.isLocationPublic,
            );
            
            if (kDebugMode) {
              debugPrint('🔧 ${friend.userName} 상태 보정: DB=${apiStatus ? '온라인' : '오프라인'} → 웹소켓=${websocketStatus ? '온라인' : '오프라인'}');
            }
          }
        }
      }

      // 🔥 보정된 친구 목록으로 업데이트
      friends = newFriends;

      _lastUpdate = DateTime.now();
      _updateFriendsOnlineStatus();

      if (kDebugMode) {
        debugPrint('🔥 친구 데이터 새로고침 완료');
        debugPrint('🔥 최종 결과:');
        debugPrint('🔥   - 친구: ${friends.length}명');
        debugPrint('🔥   - 받은 요청: ${friendRequests.length}개');
        debugPrint('🔥   - 보낸 요청: ${sentFriendRequests.length}개');
        debugPrint('🔥   - 온라인 사용자: ${onlineUsers.length}명');
      }
    } catch (e) {
      errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('🔥 친구 데이터 새로고침 실패: $e');
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

      if (kDebugMode) {
        debugPrint('🔥 친구 요청 전송 시작: $addId');
      }

      // 🔥 서버에 친구 요청 전송
      await repository.requestFriend(addId);
      
      // 🔥 보낸 요청 목록에 낙관적으로 추가
      _optimisticAddSentRequest(addId);
      
      // 🔥 백그라운드에서 동기화
      _syncSentRequestsInBackground();

      if (kDebugMode) {
        debugPrint('🔥 친구 추가 요청 완료: $addId');
      }
      
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔥 친구 요청 전송 실패: $e');
      }
      
      try {
        // 🔥 실패 시 전체 데이터 새로고침
        final newFriends = await repository.getMyFriends();
        final newFriendRequests = await repository.getFriendRequests();
        final newSentFriendRequests = await repository.getSentFriendRequests();

        friends = newFriends;
        friendRequests = newFriendRequests;
        sentFriendRequests = newSentFriendRequests;

        _updateFriendsOnlineStatus();
        
        if (kDebugMode) {
          debugPrint('🔥 친구 목록 복구 완료');
        }
      } catch (loadError) {
        if (kDebugMode) {
          debugPrint('🔥 친구 목록 복구 실패: $loadError');
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
      // 🔥 수락할 요청 정보 저장
      removedRequest = friendRequests.firstWhere(
        (request) => request.fromUserId == addId,
        orElse: () => FriendRequest(fromUserId: '', fromUserName: '', createdAt: ''),
      );
      
      final acceptedUserName = removedRequest.fromUserName;
      
      // 🔥 UI 즉시 업데이트 (낙관적 업데이트)
      friendRequests.removeWhere((request) => request.fromUserId == addId);
      notifyListeners();
      
      // 🔥 서버에 수락 요청 전송
      await repository.acceptRequest(addId);
      
      // 🔥 친구 목록 즉시 새로고침 (실시간 반영)
      await _immediateFriendListUpdate();
      
      // 🔥 햅틱 피드백으로 사용자에게 알림
      HapticFeedback.mediumImpact();
      
      if (kDebugMode) {
        debugPrint('🔥 친구 요청 수락 완료: $acceptedUserName($addId)');
      }
      
    } catch (e) {
      // 🔥 실패 시 원래 상태로 복구
      if (removedRequest != null && removedRequest.fromUserId.isNotEmpty) {
        friendRequests.add(removedRequest);
        notifyListeners();
      }
      
      errorMessage = e.toString();
      notifyListeners();
      
      if (kDebugMode) {
        debugPrint('🔥 친구 요청 수락 실패: $e');
      }
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
      if (kDebugMode) {
        debugPrint('🔥 친구 요청 취소 시작: $friendId');
      }

      // 🔥 취소할 요청 정보 저장
      final cancelledRequest = sentFriendRequests.firstWhere(
        (request) => request.toUserId == friendId,
        orElse: () => SentFriendRequest(toUserId: '', toUserName: '', requestDate: ''),
      );
      
      final cancelledUserName = cancelledRequest.toUserName;
      
      // 🔥 UI 즉시 업데이트 (낙관적 업데이트)
      sentFriendRequests.removeWhere((request) => request.toUserId == friendId);
      notifyListeners();

      // 🔥 서버에 취소 요청 전송
      await repository.cancelSentRequest(friendId);

      // 🔥 햅틱 피드백으로 사용자에게 알림
      HapticFeedback.lightImpact();

      if (kDebugMode) {
        debugPrint('🔥 친구 요청 취소 완료: $cancelledUserName($friendId)');
      }

      // 🔥 백그라운드에서 전체 데이터 새로고침
      Future.microtask(() => quickUpdate());
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔥 친구 요청 취소 실패: $e');
      }
      
      errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }


  // 새로고침 메서드


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
        // 🔥 웹소켓 연결 시: 웹소켓 상태를 우선시하여 DB 상태 보정
        if (isWebSocketConnected) {
          // 각 친구의 상태를 웹소켓 상태로 보정
          for (int i = 0; i < newFriends.length; i++) {
            final friend = newFriends[i];
            final websocketStatus = onlineUsers.contains(friend.userId);
            final apiStatus = friend.isLogin;
            
            // 웹소켓 상태와 DB 상태가 다른 경우 웹소켓 상태로 보정
            if (websocketStatus != apiStatus) {
              newFriends[i] = Friend(
                userId: friend.userId,
                userName: friend.userName,
                profileImage: friend.profileImage,
                phone: friend.phone,
                isLogin: websocketStatus, // 🔥 웹소켓 상태 우선
                lastLocation: friend.lastLocation,
                isLocationPublic: friend.isLocationPublic,
              );
            }
          }
        }
        
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
    
    _backgroundTimer?.cancel();
    _backgroundTimer = null;

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

  /// 🔄 모든 친구 데이터 새로고침 (새로고침 버튼용)
  Future<void> refreshAllData() async {
    if (kDebugMode) {
      debugPrint('🔄 새로고침 버튼 클릭 - 모든 친구 데이터 새로고침 시작');
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

      // 🔥 API 캐시 강제 무효화 (새로고침 시 최신 데이터 보장)
      await _forceRefreshWithoutCache();

      if (kDebugMode) {
        debugPrint('✅ 새로고침 완료:');
        debugPrint('  - 친구: ${friends.length}명');
        debugPrint('  - 받은 요청: ${friendRequests.length}개');
        debugPrint('  - 보낸 요청: ${sentFriendRequests.length}개');
        debugPrint('  - 온라인 사용자: ${onlineUsers.length}명');
        
        // 🔥 받은 요청 상세 로그
        if (friendRequests.isNotEmpty) {
          debugPrint('🔥 받은 요청 상세:');
          for (final request in friendRequests) {
            debugPrint('  - ${request.fromUserName}(${request.fromUserId})');
          }
        }
      }
    } catch (e) {
      errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('❌ 새로고침 실패: $e');
      }
    }

    isLoading = false;
    notifyListeners();
    
    // 🔥 추가 UI 업데이트 (확실히 업데이트되도록)
    Future.microtask(() => notifyListeners());
    Future.delayed(const Duration(milliseconds: 100), () => notifyListeners());
  }

  /// 🔥 캐시 무시하고 강제 새로고침
  Future<void> _forceRefreshWithoutCache() async {
    if (kDebugMode) {
      debugPrint('🔥 캐시 무시 강제 새로고침 시작');
    }

    try {
      // 🔥 1. API 캐시 완전 초기화
      await _clearApiCache();
      
      // 🔥 2. 순차적으로 모든 데이터 새로 가져오기 (캐시 우회)
      final newFriends = await repository.getMyFriends();
      final newFriendRequests = await repository.getFriendRequests();
      final newSentFriendRequests = await repository.getSentFriendRequests();

      // 🔥 3. 웹소켓 연결 시: 웹소켓 상태를 우선시하여 DB 상태 보정
      if (isWebSocketConnected) {
        if (kDebugMode) {
          debugPrint('🔥 웹소켓 연결 상태 우선 - DB 상태 보정 시작');
        }
        
        // 각 친구의 상태를 웹소켓 상태로 보정
        for (int i = 0; i < newFriends.length; i++) {
          final friend = newFriends[i];
          final websocketStatus = onlineUsers.contains(friend.userId);
          final apiStatus = friend.isLogin;
          
          // 웹소켓 상태와 DB 상태가 다른 경우 웹소켓 상태로 보정
          if (websocketStatus != apiStatus) {
            newFriends[i] = Friend(
              userId: friend.userId,
              userName: friend.userName,
              profileImage: friend.profileImage,
              phone: friend.phone,
              isLogin: websocketStatus, // 🔥 웹소켓 상태 우선
              lastLocation: friend.lastLocation,
              isLocationPublic: friend.isLocationPublic,
            );
            
            if (kDebugMode) {
              debugPrint('🔧 ${friend.userName} 상태 보정: DB=${apiStatus ? '온라인' : '오프라인'} → 웹소켓=${websocketStatus ? '온라인' : '오프라인'}');
            }
          }
        }
      }

      // 🔥 4. 데이터 업데이트
      friends = newFriends;
      friendRequests = newFriendRequests;
      sentFriendRequests = newSentFriendRequests;
      _lastUpdate = DateTime.now();
      
      // 🔥 5. 온라인 상태 업데이트
      _updateFriendsOnlineStatus();

      if (kDebugMode) {
        debugPrint('🔥 캐시 무시 강제 새로고침 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔥 캐시 무시 강제 새로고침 실패: $e');
      }
      rethrow;
    }
  }

  /// 🔥 API 캐시 완전 초기화
  Future<void> _clearApiCache() async {
    try {
      // ApiHelper 캐시 초기화
      ApiHelper.clearCache();
      
      if (kDebugMode) {
        debugPrint('🔥 API 캐시 초기화 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔥 API 캐시 초기화 실패: $e');
      }
    }
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
