// lib/services/websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../config/api_config.dart'; // 🔥 추가 필요

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  String? _userId;
  bool _isConnected = false;
  bool _isConnecting = false; // 🔥 동시 연결 시도 방지
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
static const int _maxReconnectAttempts = ApiConfig.maxReconnectAttempts;
static const Duration _heartbeatInterval = ApiConfig.heartbeatInterval;
static const Duration _reconnectDelay = ApiConfig.reconnectDelay;

  // 이벤트 스트림 컨트롤러들
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  final StreamController<List<String>> _onlineUsersController =
      StreamController<List<String>>.broadcast();

  // 공개 스트림
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<List<String>> get onlineUsersStream => _onlineUsersController.stream;

  /// 연결 상태 확인
  bool get isConnected {
    // 🔥 더 안정적인 연결 상태 확인
    final hasChannel = _channel != null;
    final hasSubscription = _subscription != null;
    final channelReady = _channel?.ready != null;
    
    // 모든 조건이 만족되어야 연결됨으로 간주
    final status = _isConnected && hasChannel && hasSubscription && channelReady;

    // 🔥 디버그 로그를 조건부로 출력 (너무 많은 로그 방지)
    if (!status || _isConnecting) {
      debugPrint('🔍 연결 상태 확인:');
      debugPrint('🔍 _isConnected: $_isConnected');
      debugPrint('🔍 hasChannel: $hasChannel');
      debugPrint('🔍 hasSubscription: $hasSubscription');
      debugPrint('🔍 channelReady: $channelReady');
      debugPrint('🔍 최종 상태: $status');
    }

    return status;
  }

  /// 연결 상태 스트림
  Stream<bool> get connectionStatus => _connectionController.stream;

  /// 연결 상태 상세 정보
  Map<String, dynamic> get connectionInfo {
    return {
      'isConnected': _isConnected,
      'isConnecting': _isConnecting,
      'hasChannel': _channel != null,
      'hasSubscription': _subscription != null,
      'shouldReconnect': _shouldReconnect,
      'reconnectAttempts': _reconnectAttempts,
      'userId': _userId,
    };
  }

  // 🔌 웹소켓 연결
  Future<void> connect(String userId) async {
    // 🔥 게스트 사용자는 웹소켓 연결 차단
    if (userId.startsWith('guest_')) {
      debugPrint('🚫 게스트 사용자는 웹소켓 연결이 차단됩니다: $userId');
      return;
    }

    // 🔥 이미 연결 중이거나 같은 사용자로 연결된 경우 중복 연결 방지
    if (_isConnecting) {
      debugPrint('⚠️ 이미 연결 중입니다: $userId');
      return;
    }

    // 🔥 이미 연결되어 있고 같은 사용자인 경우
    if (_isConnected && _userId == userId) {
      debugPrint('⚠️ 이미 연결되어 있습니다: $userId');
      return;
    }

    // 🔥 이미 연결되어 있지만 다른 사용자인 경우 기존 연결 완전 정리
    if (_isConnected && _userId != userId) {
      debugPrint('🔄 다른 사용자로 연결 변경: $_userId -> $userId');
      await disconnect();
      // 연결 해제 후 잠시 대기
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _userId = userId;
    _shouldReconnect = true;
    _reconnectAttempts = 0;

    await _doConnect();
  }

  // 실제 연결 수행
  Future<void> _doConnect() async {
  // 🔥 동시 연결 시도 방지
  if (_isConnecting) {
    debugPrint('⚠️ 이미 연결 중입니다. 중복 연결 시도 무시');
    return;
  }

  _isConnecting = true;

  // 🔥 연결 시도 전 서버 상태 확인
  debugPrint('🔍 웹소켓 서버 상태 확인 중...');
  debugPrint('🔍 서버 URL: ${ApiConfig.websocketUrl}'); // 🔥 수정
  debugPrint('🔍 사용자 ID: $_userId');

  try {
    debugPrint('🔄 웹소켓 연결 시작 - 사용자 ID: $_userId');

    // 기존 연결 완전 정리
    await _cleanupConnection();

    // 🔥 ApiConfig에서 웹소켓 URL 가져오기 - 수정된 부분
    final wsUrl = ApiConfig.websocketUrl;
    debugPrint('🔌 웹소켓 연결 시도: $wsUrl');
    debugPrint('🔌 서버 호스트: ${ApiConfig.baseWsHost}');
    debugPrint('🔌 서버 포트: ${ApiConfig.websocketPort}');
    debugPrint('🔌 웹소켓 경로: /friend/ws');

    debugPrint('📡 WebSocketChannel 생성 시작...');
    _channel = WebSocketChannel.connect(
      Uri.parse(wsUrl),
      // protocols: ['chat'], // 프로토콜 제거 - 서버에서 지원하지 않을 수 있음
    );
    debugPrint('📡 WebSocketChannel 생성 완료');
    debugPrint('📡 채널 상태: ${_channel != null}');
    debugPrint('📡 채널 준비 상태: ${_channel?.ready}');

    debugPrint('⏳ 웹소켓 연결 대기 중...');
    // 🔥 연결 확인을 위한 타임아웃 (ApiConfig에서 가져오기) - 수정된 부분
    await _channel!.ready.timeout(
      ApiConfig.connectionTimeout,
      onTimeout: () {
        debugPrint('⏰ 웹소켓 연결 타임아웃 (${ApiConfig.connectionTimeout.inSeconds}초)');
        throw TimeoutException('웹소켓 연결 타임아웃', ApiConfig.connectionTimeout);
      },
    );

    // ... 나머지 코드는 동일
    debugPrint('✅ 웹소켓 연결 준비 완료');
    debugPrint('✅ 채널 상태: ${_channel != null}');
    debugPrint('✅ 채널 준비 상태: ${_channel?.ready}');

    // 🔥 연결 직후 즉시 서버에 연결 알림 전송 (서버에서 처리하는 메시지 타입으로 변경)
    debugPrint('📤 웹소켓 연결 직후 서버에 연결 알림 전송');
    _sendMessageDirectly({
      'type': 'register', // 🔥 서버에서 처리하는 타입
      'userId': _userId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // 서버가 메시지를 처리할 시간 확보
    await Future.delayed(const Duration(milliseconds: 200));

    // 메시지 수신 리스너 설정 - 중복 리스너 방지
    debugPrint('👂 메시지 수신 리스너 설정 시작');
    await _setupMessageListener();

    // 초기 메시지들 전송
    await _sendInitialMessages();

    // 🔥 연결 상태를 마지막에 설정하여 완전히 준비된 후에만 연결됨으로 표시
    _isConnected = true;
    _reconnectAttempts = 0;
    _connectionController.add(true);

    debugPrint('✅ 웹소켓 연결 성공 - 상태: $_isConnected');

    // 하트비트 시작
    _startHeartbeat();
    debugPrint('💓 하트비트 시작 완료');
  } catch (e) {
    debugPrint('❌ 웹소켓 연결 실패: $e');
    debugPrint('❌ 오류 타입: ${e.runtimeType}');
    debugPrint('❌ 오류 상세: ${e.toString()}');

    // 연결 실패 시 더 자세한 정보 출력
    if (e is TimeoutException) {
      debugPrint('⏰ 타임아웃 오류 - 서버 응답 없음');
    } else if (e.toString().contains('SocketException')) {
      debugPrint('🌐 네트워크 오류 - 서버에 연결할 수 없음');
    } else if (e.toString().contains('WebSocketException')) {
      debugPrint('🔌 웹소켓 오류 - 프로토콜 또는 핸드셰이크 실패');
    }

    _isConnected = false;
    _connectionController.add(false);

    if (_shouldReconnect) {
      debugPrint('🔄 재연결 시도 예약');
      _scheduleReconnect();
    }
  } finally {
    // 🔥 연결 시도 완료 표시
    _isConnecting = false;
  }
}

  // 🔥 기존 연결 완전 정리
  Future<void> _cleanupConnection() async {
    debugPrint('🧹 기존 연결 정리 시작');

    // 기존 리스너 취소
    if (_subscription != null) {
      try {
        await _subscription!.cancel();
        debugPrint('✅ 기존 리스너 취소 완료');
      } catch (e) {
        debugPrint('⚠️ 기존 리스너 취소 중 오류: $e');
      }
      _subscription = null;
    }

    // 기존 채널 정리
    if (_channel != null) {
      try {
        await _channel!.sink.close();
        debugPrint('✅ 기존 채널 정리 완료');
      } catch (e) {
        debugPrint('⚠️ 기존 채널 정리 중 오류: $e');
      }
      _channel = null;
    }

    _isConnected = false;
    _connectionController.add(false);
    debugPrint('🧹 기존 연결 정리 완료');
  }

  // 🔥 연결 상태 재확인 및 복구
  Future<void> _ensureConnection() async {
    if (!_isConnected || _channel == null || _subscription == null) {
      debugPrint('⚠️ 웹소켓 연결 상태 불량 - 재연결 시도');
      await _doConnect();
    }
  }

  // 🔥 메시지 리스너 설정
  Future<void> _setupMessageListener() async {
    if (_subscription != null) {
      await _subscription!.cancel();
      _subscription = null;
      debugPrint('🔄 기존 리스너 취소 완료');
    }

    _subscription = _channel!.stream.listen(
      _handleMessage,
      onError: _handleError,
      onDone: _handleDisconnection,
    );

    debugPrint('✅ 메시지 수신 리스너 설정 완료');
  }

  // 🔥 초기 메시지들 전송 (서버에서 처리하는 메시지만 사용)
  Future<void> _sendInitialMessages() async {
    try {
      // 🔥 1. 하트비트 메시지로 연결 확인 (서버에서 처리하는 메시지)
      debugPrint('📤 하트비트 메시지 전송');
      _sendMessage({
        'type': 'heartbeat',
        'userId': _userId,
        'timestamp': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ 초기 메시지 전송 완료');
    } catch (e) {
      debugPrint('❌ 초기 메시지 전송 실패: $e');
    }
  }

  // 메시지 처리
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message.toString());
      debugPrint('📨 웹소켓 메시지 수신: ${data['type']}');
      debugPrint('📨 메시지 내용: $data');
      debugPrint('📨 메시지 타입: ${data['type']}');
      debugPrint('📨 전체 메시지: $message');

      switch (data['type']) {
        // 🔥 서버에서 처리하는 메시지들만 유지
        case 'registered':
          _handleRegistered(data);
          break;

        case 'online_users_update':
          _handleOnlineUsersUpdate(data);
          break;

        case 'friend_logged_in':
          _handleFriendLoggedIn(data);
          break;

        case 'friend_logged_out':
          _handleFriendLoggedOut(data);
          break;

        // 🔥 친구 요청 관련 메시지들 추가
        case 'new_friend_request':
          _handleNewFriendRequest(data);
          break;

        case 'friend_request_accepted':
          _handleFriendRequestAccepted(data);
          break;

        case 'friend_request_rejected':
          _handleFriendRequestRejected(data);
          break;

        case 'friend_deleted':
          _handleFriendDeleted(data);
          break;

        // 🔥 위치 공유 상태 변경 처리 추가
        case 'friend_location_share_status_change':
          _handleFriendLocationShareStatusChange(data);
          break;

        case 'heartbeat_response':
          debugPrint('❤️ 하트비트 응답 수신');
          break;

        default:
          debugPrint('⚠️ 알 수 없는 메시지 타입: ${data['type']}');
      }

      // 모든 메시지를 스트림으로 전달
      _messageController.add(data);
    } catch (e) {
      debugPrint('❌ 메시지 파싱 오류: $e');
    }
  }

  // 🔥 새로 추가: 친구 로그아웃 처리 메서드
  void _handleFriendLoggedOut(Map<String, dynamic> data) {
    final loggedOutUserId = data['userId'];
    debugPrint('👋 친구 로그아웃: $loggedOutUserId');
    debugPrint('👋 친구 로그아웃 메시지 전체: $data');

    // 🔥 메시지 중복 전송 방지 - _handleMessage에서 이미 전송됨
    // _messageController.add(data); // 제거

    // 🔥 추가 디버깅: 온라인 사용자 목록에서 제거
    debugPrint('🔥 친구 로그아웃으로 인한 온라인 사용자 목록 업데이트');
    debugPrint('🔥 메시지 스트림으로 전달됨 - FriendsController에서 처리 예정');
  }

  // 🔥 새로 추가: 친구 로그인 처리 메서드
  void _handleFriendLoggedIn(Map<String, dynamic> data) {
    final loggedInUserId = data['userId'];
    debugPrint('👋 친구 로그인: $loggedInUserId');
    debugPrint('👋 친구 로그인 메시지 전체: $data');

    // 🔥 메시지 중복 전송 방지 - _handleMessage에서 이미 전송됨
    // _messageController.add(data); // 제거

    // 🔥 추가 디버깅: 온라인 사용자 목록에 추가
    debugPrint('🔥 친구 로그인으로 인한 온라인 사용자 목록 업데이트');
    debugPrint('🔥 메시지 스트림으로 전달됨 - FriendsController에서 처리 예정');
  }

  // 🔥 새로 추가: 위치 공유 상태 변경 처리 메서드
  void _handleFriendLocationShareStatusChange(Map<String, dynamic> data) {
    final userId = data['userId'];
    final isLocationPublic = data['isLocationPublic'] ?? false;
    debugPrint('📍 위치 공유 상태 변경: $userId - ${isLocationPublic ? '공유' : '비공유'}');

    // 🔥 메시지 중복 전송 방지 - _handleMessage에서 이미 전송됨
    // _messageController.add(data); // 제거

    // 위치 공유 상태 변경 알림 표시 (나중에 구현)
    // NotificationService.showLocationShareStatusChangeNotification(
    //   userId,
    //   isLocationPublic,
    //   data['message'] ?? '친구의 위치 공유 상태가 변경되었습니다.',
    // );
  }

  // 🔥 새로 추가: 새로운 친구 요청 처리
  void _handleNewFriendRequest(Map<String, dynamic> data) {
    final fromUserId = data['fromUserId'];
    final fromUserName = data['fromUserName'];
    debugPrint('📨 새로운 친구 요청: $fromUserName ($fromUserId)');
    debugPrint('📨 친구 요청 메시지 전체: $data');

    // 🔥 메시지 중복 전송 방지 - _handleMessage에서 이미 전송됨
    // _messageController.add(data); // 제거
  }

  // 🔥 새로 추가: 친구 요청 수락 처리
  void _handleFriendRequestAccepted(Map<String, dynamic> data) {
    final fromUserId = data['fromUserId'];
    final fromUserName = data['fromUserName'];
    debugPrint('✅ 친구 요청 수락: $fromUserName ($fromUserId)');
    debugPrint('✅ 친구 요청 수락 메시지 전체: $data');

    // 🔥 메시지 중복 전송 방지 - _handleMessage에서 이미 전송됨
    // _messageController.add(data); // 제거
  }

  // 🔥 새로 추가: 친구 요청 거절 처리
  void _handleFriendRequestRejected(Map<String, dynamic> data) {
    final fromUserId = data['fromUserId'];
    final fromUserName = data['fromUserName'];
    debugPrint('❌ 친구 요청 거절: $fromUserName ($fromUserId)');
    debugPrint('❌ 친구 요청 거절 메시지 전체: $data');

    // 🔥 메시지 중복 전송 방지 - _handleMessage에서 이미 전송됨
    // _messageController.add(data); // 제거
  }

  // 🔥 새로 추가: 친구 삭제 처리
  void _handleFriendDeleted(Map<String, dynamic> data) {
    final deletedUserId = data['deletedUserId'];
    final deletedUserName = data['deletedUserName'];
    debugPrint('🗑️ 친구 삭제: $deletedUserName ($deletedUserId)');
    debugPrint('🗑️ 친구 삭제 메시지 전체: $data');

    // 🔥 메시지 중복 전송 방지 - _handleMessage에서 이미 전송됨
    // _messageController.add(data); // 제거
  }

  // 🔥 웹소켓 연결 확인 메시지 처리
  void _handleConnect(Map<String, dynamic> data) {
    debugPrint('✅ 웹소켓 연결 확인됨');
  }

  // 🔥 웹소켓 연결 해제 확인 메시지 처리
  void _handleDisconnect(Map<String, dynamic> data) {
    debugPrint('✅ 웹소켓 연결 해제 확인됨');
  }

  // 🔥 등록 확인 메시지 처리
  void _handleRegistered(Map<String, dynamic> data) {
    debugPrint('✅ 웹소켓 등록 확인됨');

    // 등록 후 온라인 사용자 목록 다시 요청
    _sendMessage({
      'type': 'get_online_users',
      'userId': _userId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // 🔥 사용자 로그인 처리
  void _handleUserLogin(Map<String, dynamic> data) {
    final userId = data['userId'];
    debugPrint('👤 사용자 로그인: $userId');

    // 로그인 이벤트를 스트림으로 전달
    _messageController.add({'type': 'user_login', 'userId': userId});
  }

  // 🔥 온라인 사용자 목록 업데이트 처리 (개선)
  void _handleOnlineUsersUpdate(Map<String, dynamic> data) {
    List<String> onlineUsers = [];

    // 다양한 데이터 형식 처리
    if (data['users'] != null) {
      if (data['users'] is List) {
        onlineUsers = (data['users'] as List)
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
    } else if (data['onlineUsers'] != null) {
      if (data['onlineUsers'] is List) {
        onlineUsers = (data['onlineUsers'] as List)
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
    }

    debugPrint('👥 온라인 사용자 목록 업데이트: ${onlineUsers.length}명');

    // 온라인 사용자 스트림으로 전달
    _onlineUsersController.add(onlineUsers);
  }

  // 🚪 로그아웃 전용 메서드 - 서버에 로그아웃 알리고 연결 해제
  // lib/services/websocket_service.dart의 logoutAndDisconnect 메서드
  Future<void> logoutAndDisconnect() async {
    debugPrint('🚪 로그아웃 및 웹소켓 연결 해제 시작...');

    // 🔥 중복 로그아웃 방지
    if (!_isConnected || _userId == null) {
      debugPrint('⚠️ 이미 로그아웃되었거나 연결되지 않음');
      await disconnect();
      return;
    }

    try {
      // 🔥 서버에서 처리하는 메시지가 없으므로 연결 해제만 수행
      debugPrint('📤 웹소켓 연결 해제 시작');

      // 서버가 메시지를 처리할 시간 확보
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      debugPrint('❌ 로그아웃 메시지 전송 실패: $e');
    }

    // 재연결 방지 설정
    _shouldReconnect = false;

    // 기존 disconnect 메서드 호출
    await disconnect();

    debugPrint('✅ 로그아웃 및 웹소켓 연결 해제 완료');
  }

  // 📤 메시지 전송 (연결 상태 체크 포함)
  void _sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      try {
        final jsonMessage = jsonEncode(message);
        _channel!.sink.add(jsonMessage);
        debugPrint('✅ 메시지 전송 성공: ${message['type']}');
      } catch (e) {
        debugPrint('❌ 메시지 전송 실패: $e');
      }
    } else {
      debugPrint('⚠️ 웹소켓 연결되지 않음 - 메시지 전송 실패');
    }
  }

  // 📤 메시지 직접 전송 (연결 상태 체크 없음)
  void _sendMessageDirectly(Map<String, dynamic> message) {
    if (_channel != null) {
      try {
        final jsonMessage = jsonEncode(message);
        _channel!.sink.add(jsonMessage);
        debugPrint('✅ 메시지 직접 전송 성공: ${message['type']}');
      } catch (e) {
        debugPrint('❌ 메시지 직접 전송 실패: $e');
      }
    } else {
      debugPrint('⚠️ 채널이 없음 - 메시지 직접 전송 실패');
    }
  }

  // 💓 하트비트 시작
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_isConnected) {
        _sendMessage({
          'type': 'heartbeat',
          'timestamp': DateTime.now().toIso8601String(),
        });
      } else {
        timer.cancel();
      }
    });
  }

  // ❌ 오류 처리
  void _handleError(error) {
    debugPrint('❌ 웹소켓 오류: $error');
    _isConnected = false;
    _connectionController.add(false);

    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  // 🔌 연결 해제 처리
  void _handleDisconnection() {
    debugPrint('🔌 웹소켓 연결 해제됨');
    _isConnected = false;
    _connectionController.add(false);

    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  // 🔄 재연결 스케줄링
  void _scheduleReconnect() {
    // 🔥 이미 재연결 타이머가 실행 중이면 중복 방지
    if (_reconnectTimer != null) {
      debugPrint('⚠️ 재연결 타이머가 이미 실행 중입니다');
      return;
    }

    // 🔥 최대 재연결 시도 횟수 체크
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('🛑 최대 재연결 시도 횟수 초과: $_reconnectAttempts/$_maxReconnectAttempts');
      _shouldReconnect = false; // 더 이상 재연결 시도하지 않음
      return;
    }

    _reconnectAttempts++;
    
    // 🔥 지수 백오프 적용 (1초, 2초, 4초, 8초, 16초)
    final delay = Duration(
      seconds: _reconnectDelay.inSeconds * (1 << (_reconnectAttempts - 1)),
    );

    debugPrint(
      '🔄 ${delay.inSeconds}초 후 재연결 시도 ($_reconnectAttempts/$_maxReconnectAttempts)',
    );

    _reconnectTimer = Timer(delay, () async {
      // 🔥 타이머 실행 후 즉시 null로 설정하여 중복 방지
      _reconnectTimer = null;

      // 🔥 재연결 조건 재확인
      if (_shouldReconnect && !_isConnected && !_isConnecting) {
        debugPrint('🔄 재연결 시도 시작...');
        try {
          await _doConnect();
        } catch (e) {
          debugPrint('❌ 재연결 실패: $e');
          // 재연결 실패 시 다음 시도 예약
          if (_shouldReconnect) {
            _scheduleReconnect();
          }
        }
      } else {
        debugPrint('⚠️ 재연결 조건 불만족 - 재연결 시도 중단');
      }
    });
  }

  // 🔌 연결 해제
  Future<void> disconnect() async {
    debugPrint('🔌 웹소켓 연결 해제 중...');

    // 🔥 재연결 방지
    _shouldReconnect = false;
    _isConnected = false;
    _isConnecting = false;

    // 🔥 타이머들 정리
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _heartbeatTimer = null;
    _reconnectTimer = null;

    // 🔥 구독 정리
    try {
      await _subscription?.cancel();
      debugPrint('✅ 구독 정리 완료');
    } catch (e) {
      debugPrint('⚠️ 구독 정리 중 오류: $e');
    }
    _subscription = null;

    // 🔥 채널 정리
    try {
      await _channel?.sink.close(status.normalClosure);
      debugPrint('✅ 채널 정리 완료');
    } catch (e) {
      debugPrint('⚠️ 채널 정리 중 오류: $e');
    }
    _channel = null;

    // 🔥 연결 상태 스트림 업데이트
    _connectionController.add(false);
    
    debugPrint('✅ 웹소켓 연결 해제 완료');
  }

  // 🧹 리소스 정리
  void dispose() {
    debugPrint('🛑 WebSocketService 정리 중...');
    
    try {
      disconnect();
      debugPrint('✅ 웹소켓 연결 해제 완료');
    } catch (e) {
      debugPrint('⚠️ 웹소켓 연결 해제 중 오류: $e');
    }

    try {
      _messageController.close();
      _connectionController.close();
      _onlineUsersController.close();
      debugPrint('✅ 스트림 컨트롤러 정리 완료');
    } catch (e) {
      debugPrint('⚠️ 스트림 컨트롤러 정리 중 오류: $e');
    }

    debugPrint('✅ WebSocketService 정리 완료');
  }

  // 🔍 연결 상태 테스트 메서드
  void testConnection() {
    debugPrint('🔍 웹소켓 연결 상태: $_isConnected');

    if (_isConnected && _channel != null) {
      debugPrint('✅ 웹소켓 연결됨 - 테스트 메시지 전송');
      _sendMessage({
        'type': 'test',
        'userId': _userId,
        'timestamp': DateTime.now().toIso8601String(),
        'message': '클라이언트에서 테스트 메시지 전송',
      });
    } else {
      debugPrint('❌ 웹소켓 연결되지 않음');
    }
  }

  // 🔥 실시간 친구 상태 요청
  void requestFriendStatus() {
    if (_isConnected && _channel != null) {
      debugPrint('🔍 실시간 친구 상태 요청');
      _sendMessage({
        'type': 'get_friend_status',
        'userId': _userId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } else {
      debugPrint('❌ 웹소켓 연결되지 않음 - 친구 상태 요청 실패');
    }
  }

  /// 🔥 웹소켓 메시지 전송 (공개 메서드)
  void sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      debugPrint('📤 웹소켓 메시지 전송: ${message['type']}');
      _sendMessage(message);
    } else {
      debugPrint('❌ 웹소켓 연결되지 않음 - 메시지 전송 실패');
    }
  }
}
