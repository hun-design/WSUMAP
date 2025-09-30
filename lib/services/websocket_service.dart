// lib/services/websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../config/api_config.dart';

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
  
  // 🔥 연결 안정성 개선을 위한 추가 변수들
  DateTime? _lastHeartbeatReceived;
  DateTime? _lastHeartbeatSent;
  Timer? _connectionHealthTimer;
  int _consecutiveHeartbeatFailures = 0;
static const int _maxReconnectAttempts = ApiConfig.maxReconnectAttempts;
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

  /// 연결 상태 확인 (개선된 버전)
  bool get isConnected {
    return _isConnected && 
           _channel != null && 
           _subscription != null &&
           _userId != null &&
           !_userId!.startsWith('guest_') &&
           _lastHeartbeatReceived != null &&
           DateTime.now().difference(_lastHeartbeatReceived!).inSeconds < 120; // 🔥 2분 내 하트비트 응답 필요
  }

  /// 현재 연결된 사용자 ID
  String? get currentUserId => _userId;

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

  // 🔌 웹소켓 연결 (최적화된 버전)
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
      debugPrint('✅ 이미 연결되어 있습니다: $userId');
      return;
    }

    // 🔥 이미 연결되어 있지만 다른 사용자인 경우 기존 연결 완전 정리
    if (_isConnected && _userId != userId) {
      debugPrint('🔄 다른 사용자로 연결 변경: $_userId -> $userId');
      await disconnect();
      // 연결 해제 후 잠시 대기
      await Future.delayed(const Duration(milliseconds: 300));
    }

    _userId = userId;
    _shouldReconnect = true;
    _reconnectAttempts = 0;

    // 🔥 플랫폼별 최적화된 연결 타임아웃 설정
    try {
      await _doConnect().timeout(
        _platformConnectionTimeout,
        onTimeout: () {
          debugPrint('⏰ 웹소켓 연결 타임아웃 (${_platformConnectionTimeout.inSeconds}초)');
          throw TimeoutException('웹소켓 연결 타임아웃', _platformConnectionTimeout);
        },
      );
    } catch (e) {
      debugPrint('❌ 웹소켓 연결 실패: $e');
      if (_shouldReconnect) {
        _scheduleReconnect();
      }
      rethrow;
    }
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

    // 🔥 연결 직후 서버에서 자동으로 친구 상태 정보를 전송해주기를 기다림
    debugPrint('📤 웹소켓 연결 완료 - 서버에서 친구 상태 정보 전송 대기');

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
    
    // 🔥 연결 상태 스트림 업데이트를 마이크로태스크로 지연하여 안정성 확보
    Future.microtask(() {
      _connectionController.add(true);
      debugPrint('✅ 웹소켓 연결 성공 - 상태: $_isConnected');
    });

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

  // 메시지 처리 (최적화된 버전)
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message.toString());
      final messageType = data['type'] as String?;
      
      if (messageType == null) {
        debugPrint('⚠️ 메시지 타입이 없음: $data');
        return;
      }
      
      // 중요한 메시지만 로그 출력
      if (kDebugMode && _shouldLogMessage(messageType)) {
        debugPrint('📨 웹소켓 메시지: $messageType');
      }

      switch (messageType) {
        case 'registered':
          _handleRegistered(data);
          break;

        case 'friend_logged_in':
          // 더 이상 사용되지 않음 - friend_status_change로 통합됨
          break;

        case 'friend_logged_out':
          // 더 이상 사용되지 않음 - friend_status_change로 통합됨
          break;

        case 'friend_status_change':
          _handleFriendStatusChange(data);
          _handleFriendStatusChangeMessage(data);
          break;

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

        case 'friend_status_response':
          _handleFriendStatusResponse(data);
          break;

        case 'friend_list_with_status':
          _handleFriendListWithStatus(data);
          break;

        case 'friend_location_share_status_change':
          _handleFriendLocationShareStatusChange(data);
          break;

        case 'request_friend_status':
          _handleRequestFriendStatus(data);
          break;

        case 'online_users_update':
          _handleOnlineUsersUpdate(data);
          _handleOnlineUsersUpdateMessage(data);
          break;

        case 'Login_Status':
          _handleLoginStatusChange(data);
          // 🔥 Login_Status 메시지는 변환되어 스트림에서 처리되므로 여기서는 리턴하지 않음
          return; // 🔥 중복 스트림 전달 방지

        case 'heartbeat_response':
          _handleHeartbeatResponse(data);
          // 하트비트 응답은 스트림으로 전달하지 않음 (내부 처리용)
          return;

        case 'logout_confirmed':
          // 로그아웃 확인은 특별한 처리 없음
          break;

        case 'friend_location_update':
          _handleFriendLocationUpdate(data);
          break;

        default:
          if (kDebugMode) {
            debugPrint('⚠️ 알 수 없는 메시지 타입: $messageType');
          }
      }

      // 모든 메시지를 스트림으로 전달
      debugPrint('📡 메시지를 스트림으로 전달: $data');
      _messageController.add(data);
      debugPrint('✅ 메시지 스트림 전달 완료');
    } catch (e) {
      debugPrint('❌ 메시지 파싱 오류: $e');
    }
  }

  // 🔥 친구 상태 변경 처리 메서드
  void _handleFriendStatusChange(Map<String, dynamic> data) {
    final userId = data['userId'];
    final isOnline = data['isOnline'] ?? false;
    if (kDebugMode) {
      debugPrint('📶 친구 상태 변경: $userId - ${isOnline ? '온라인' : '오프라인'}');
    }
  }

  // 🔥 새로 추가: 위치 공유 상태 변경 처리 메서드
  void _handleFriendLocationShareStatusChange(Map<String, dynamic> data) {
    final userId = data['userId'];
    final isLocationPublic = data['isLocationPublic'] ?? false;
    if (kDebugMode) {
      debugPrint('📍 위치 공유 상태 변경: $userId - ${isLocationPublic ? '공유' : '비공유'}');
    }
  }

  // 🔥 새로 추가: 새로운 친구 요청 처리
  void _handleNewFriendRequest(Map<String, dynamic> data) {
    final fromUserName = data['fromUserName'];
    if (kDebugMode) {
      debugPrint('📨 새로운 친구 요청: $fromUserName');
    }
  }

  // 🔥 새로 추가: 친구 요청 수락 처리
  void _handleFriendRequestAccepted(Map<String, dynamic> data) {
    final fromUserName = data['fromUserName'];
    if (kDebugMode) {
      debugPrint('✅ 친구 요청 수락: $fromUserName');
    }
  }

  // 🔥 새로 추가: 친구 요청 거절 처리
  void _handleFriendRequestRejected(Map<String, dynamic> data) {
    final fromUserName = data['fromUserName'];
    if (kDebugMode) {
      debugPrint('❌ 친구 요청 거절: $fromUserName');
    }
  }

  // 🔥 새로 추가: 친구 삭제 처리
  void _handleFriendDeleted(Map<String, dynamic> data) {
    final deletedUserName = data['deletedUserName'];
    if (kDebugMode) {
      debugPrint('🗑️ 친구 삭제: $deletedUserName');
    }
  }

  // 🔥 새로 추가: 친구 상태 응답 처리
  void _handleFriendStatusResponse(Map<String, dynamic> data) {
    if (kDebugMode && data['friends'] != null && data['friends'] is List) {
      final friendsData = data['friends'] as List;
      debugPrint('📨 친구 상태 응답: ${friendsData.length}명');
    }
  }

  // 🔥 새로 추가: 친구 목록과 상태 정보 응답 처리
  void _handleFriendListWithStatus(Map<String, dynamic> data) {
    if (kDebugMode && data['friends'] != null && data['friends'] is List) {
      final friendsData = data['friends'] as List;
      debugPrint('📨 친구 목록 응답: ${friendsData.length}명');
    }
  }

  // 🔥 친구 위치 업데이트 처리
  void _handleFriendLocationUpdate(Map<String, dynamic> data) {
    final userId = data['userId'];
    if (kDebugMode) {
      debugPrint('📍 친구 위치 업데이트: $userId');
    }
  }

  // 🔥 새로 추가: 친구 상태 동기화 요청 처리
  void _handleRequestFriendStatus(Map<String, dynamic> data) {
    final userId = data['userId'];
    final timestamp = data['timestamp'];
    
    if (kDebugMode) {
      debugPrint('📨 친구 상태 동기화 요청: $userId');
      debugPrint('📨 타임스탬프: $timestamp');
    }
    
    // 서버에 친구 상태 동기화 요청 전달
    _sendMessage({
      'type': 'sync_friend_status',
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // 더 이상 사용되지 않는 메시지 핸들러들 제거됨 (통합된 알림으로 대체)

  void _handleFriendStatusChangeMessage(Map<String, dynamic> data) {
    final userId = data['userId'];
    final isOnline = data['isOnline'] ?? false;
    final message = data['message'];
    final timestamp = data['timestamp'];
    
    if (kDebugMode) {
      debugPrint('📶 친구 상태 변경 알림: $userId - ${isOnline ? '온라인' : '오프라인'}');
      debugPrint('📶 메시지: $message');
      debugPrint('📶 타임스탬프: $timestamp');
    }
  }

  void _handleOnlineUsersUpdateMessage(Map<String, dynamic> data) {
    final onlineUsers = data['onlineUsers'];
    final timestamp = data['timestamp'];
    
    if (kDebugMode) {
      debugPrint('👥 온라인 사용자 목록 업데이트 알림');
      debugPrint('👥 온라인 사용자 수: ${onlineUsers is List ? onlineUsers.length : 'N/A'}');
      debugPrint('👥 타임스탬프: $timestamp');
    }
    
    // 기존 온라인 사용자 업데이트 로직과 통합
    _handleOnlineUsersUpdate(data);
  }


  // 🔥 등록 확인 메시지 처리
  void _handleRegistered(Map<String, dynamic> data) {
    if (kDebugMode) {
      debugPrint('✅ 웹소켓 등록 확인됨');
    }

    // 등록 후 서버에서 자동으로 온라인 사용자 목록을 전송해주기를 기다림
    debugPrint('📤 등록 완료 - 서버에서 온라인 사용자 목록 전송 대기');
  }

  // 🔥 Login_Status 메시지 처리 (서버에서 보내는 친구 로그인/로그아웃 알림) - 개선된 버전
  void _handleLoginStatusChange(Map<String, dynamic> data) {
    final userId = data['userId'];
    final statusRaw = data['status'];
    final message = data['message'];
    final timestamp = data['timestamp'];
    
    // 🔥 상태 값 정규화
    final isOnline = _normalizeStatusValue(statusRaw);
    
    if (kDebugMode) {
      debugPrint('🔥 Login_Status 메시지 처리 시작');
      debugPrint('📨 친구 ID: $userId');
      debugPrint('📨 원본 status 값: $statusRaw');
      debugPrint('📨 정규화된 상태: $isOnline');
      debugPrint('📨 메시지: $message');
    }
    
    // 🔥 friend_status_change 형식으로 변환
    final friendStatusMessage = {
      'type': 'friend_status_change',
      'userId': userId,
      'isOnline': isOnline,
      'message': message,
      'timestamp': timestamp,
      'source': 'Login_Status', // 🔥 메시지 출처 표시
    };
    
    // 🔥 변환된 메시지를 스트림으로 전달
    try {
      _messageController.add(friendStatusMessage);
      if (kDebugMode) {
        debugPrint('✅ Login_Status → friend_status_change 변환 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Login_Status 메시지 변환 실패: $e');
      }
    }
  }

  // 🔥 상태 값 정규화 헬퍼
  bool _normalizeStatusValue(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      final lowerValue = value.toLowerCase();
      return lowerValue == 'true' || lowerValue == 'online' || lowerValue == '1';
    }
    if (value is int) {
      return value == 1;
    }
    return false;
  }

  // 🔥 하트비트 응답 처리 메서드 추가 (개선된 버전)
  void _handleHeartbeatResponse(Map<String, dynamic> data) {
    if (kDebugMode) {
      debugPrint('💓 하트비트 응답 수신: ${data['timestamp']}');
    }
    
    // 🔥 하트비트 응답 시간 기록
    _lastHeartbeatReceived = DateTime.now();
    _consecutiveHeartbeatFailures = 0;
    
    // 하트비트 응답을 받으면 연결 상태를 확실히 유지
    if (!_isConnected) {
      _isConnected = true;
      _reconnectAttempts = 0; // 성공적인 응답이므로 재연결 시도 횟수 리셋
      
      // 🔥 연결 상태 스트림 업데이트를 마이크로태스크로 지연하여 안정성 확보
      Future.microtask(() {
        _connectionController.add(true);
        if (kDebugMode) {
          debugPrint('✅ 하트비트 응답으로 연결 상태 복구');
        }
      });
    }
    
    if (kDebugMode) {
      debugPrint('💓 연결 상태: 건강함, 연속 실패 횟수: $_consecutiveHeartbeatFailures');
    }
  }

  // 🔥 실시간 상태 변경 직접 전달 메서드 (제거됨 - 중복 처리 방지)
  // void _notifyRealTimeStatusChange(String userId, bool isOnline, String message) {
  //   // 이 메서드는 더 이상 사용되지 않음
  //   // Login_Status 메시지는 friend_status_change로 변환되어 처리됨
  // }

  // 🔥 글로벌 상태 변경 브로드캐스트 (제거됨 - 중복 처리 방지)
  // void _broadcastRealTimeStatusChange(String userId, bool isOnline, String message) {
  //   // 이 메서드는 더 이상 사용되지 않음
  //   // Login_Status 메시지는 friend_status_change로 변환되어 처리됨
  // }

  // 🔥 로그 출력 여부 결정 메서드
  bool _shouldLogMessage(String messageType) {
    // 중요한 메시지만 로그 출력
    const importantMessages = {
      'friend_logged_in',
      'friend_logged_out',
      'friend_status_change',
      'friend_location_update',
      'new_friend_request',
      'friend_request_accepted',
      'friend_request_rejected',
      'friend_deleted',
    };
    return importantMessages.contains(messageType);
  }

  // 🔥 플랫폼별 최적화된 연결 타임아웃 (API 설정 사용)
  Duration get _platformConnectionTimeout {
    final platform = Platform.operatingSystem;
    return ApiConfig.platformConnectionTimeouts[platform] ?? ApiConfig.connectionTimeout;
  }

  // 🔥 플랫폼별 최적화된 하트비트 간격 (API 설정 사용)
  Duration get _platformHeartbeatInterval {
    final platform = Platform.operatingSystem;
    return ApiConfig.platformHeartbeatIntervals[platform] ?? ApiConfig.heartbeatInterval;
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
      // 🔥 1단계: 서버에 로그아웃 알림 전송
      debugPrint('📤 서버에 로그아웃 알림 전송 중...');
      _sendMessage({
        'type': 'logout',
        'userId': _userId,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // 🔥 2단계: 서버가 친구들에게 알림을 보낼 시간 확보 (기존 200ms → 1000ms로 증가)
      debugPrint('⏳ 서버가 친구들에게 로그아웃 알림을 보낼 시간 대기 중...');
      await Future.delayed(const Duration(milliseconds: 1000));

      // 🔥 3단계: 추가 확인 - 하트비트 응답 대기 (선택적)
      debugPrint('💓 로그아웃 확인을 위한 추가 대기...');
      await Future.delayed(const Duration(milliseconds: 500));

      debugPrint('✅ 서버 로그아웃 알림 처리 완료');
    } catch (e) {
      debugPrint('❌ 로그아웃 메시지 전송 실패: $e');
      // 실패해도 연결은 해제해야 함
    }

    // 🔥 재연결 방지 설정
    _shouldReconnect = false;

    // 🔥 4단계: 웹소켓 연결 해제
    debugPrint('🔌 웹소켓 연결 해제 시작...');
    await disconnect();

    debugPrint('✅ 로그아웃 및 웹소켓 연결 해제 완료');
  }

  // 🔥 로그아웃 알림만 전송 (웹소켓 연결은 유지)
  Future<void> sendLogoutNotification() async {
    debugPrint('🚪 로그아웃 알림 전송 시작 (웹소켓 연결 유지)...');

    if (!_isConnected || _userId == null) {
      debugPrint('⚠️ 웹소켓이 연결되지 않음 - 로그아웃 알림 전송 불가');
      return;
    }

    try {
      // 🔥 서버에 로그아웃 알림 메시지 전송
      _sendMessage({
        'type': 'logout',
        'userId': _userId,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // 서버가 메시지를 처리할 시간 확보
      await Future.delayed(const Duration(milliseconds: 200));
      debugPrint('✅ 로그아웃 알림 전송 완료 (웹소켓 연결 유지)');
    } catch (e) {
      debugPrint('❌ 로그아웃 알림 전송 실패: $e');
    }
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

  // 💓 하트비트 시작 (플랫폼별 최적화)
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    final heartbeatInterval = _platformHeartbeatInterval;
    if (kDebugMode) {
      debugPrint('💓 하트비트 시작 - 간격: ${heartbeatInterval.inSeconds}초 (${Platform.operatingSystem})');
    }
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (timer) {
      // 🔥 연결 상태를 더 정확하게 체크
      if (_isConnected && _channel != null && _subscription != null) {
        sendHeartbeat();
      } else {
        if (kDebugMode) {
          debugPrint('💓 웹소켓 연결 안됨 - 하트비트 타이머 중지');
        }
        timer.cancel();
      }
    });
    
    // 🔥 연결 건강 상태 모니터링 타이머 시작
    _startConnectionHealthMonitoring();
  }
  
  // 🔥 하트비트 전송 메서드 (개선된 버전)
  void sendHeartbeat() {
    if (kDebugMode) {
      debugPrint('💓 하트비트 전송');
    }
    
    _lastHeartbeatSent = DateTime.now();
    _sendMessage({
      'type': 'heartbeat',
      'userId': _userId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  // 🔥 연결 건강 상태 모니터링 시작
  void _startConnectionHealthMonitoring() {
    _connectionHealthTimer?.cancel();
    
    // 🔥 10초마다 연결 상태 체크 (더 빈번한 체크)
    _connectionHealthTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkConnectionHealth();
    });
  }
  
  // 🔥 연결 건강 상태 체크
  void _checkConnectionHealth() {
    if (!_isConnected || _userId == null) return;
    
    final now = DateTime.now();
    bool shouldReconnect = false;
    
    // 🔥 하트비트 응답이 40초 이상 없으면 연결 불건강으로 판단 (더 엄격하게)
    if (_lastHeartbeatReceived != null) {
      final timeSinceLastResponse = now.difference(_lastHeartbeatReceived!);
      if (timeSinceLastResponse.inSeconds > 40) {
        _consecutiveHeartbeatFailures++;
        
        if (kDebugMode) {
          debugPrint('⚠️ 하트비트 응답 없음: ${timeSinceLastResponse.inSeconds}초, 실패 횟수: $_consecutiveHeartbeatFailures');
        }
        
        // 🔥 2회 연속 실패하면 재연결 시도 (더 빠른 대응)
        if (_consecutiveHeartbeatFailures >= 2) {
          shouldReconnect = true;
          if (kDebugMode) {
            debugPrint('🔄 하트비트 실패로 인한 재연결 시도');
          }
        }
      }
    }
    
    // 🔥 하트비트 전송이 60초 이상 없으면 연결 문제로 판단 (더 엄격하게)
    if (_lastHeartbeatSent != null) {
      final timeSinceLastSent = now.difference(_lastHeartbeatSent!);
      if (timeSinceLastSent.inSeconds > 60) {
        shouldReconnect = true;
        if (kDebugMode) {
          debugPrint('🔄 하트비트 전송 지연으로 인한 재연결 시도');
        }
      }
    }
    
    if (shouldReconnect && _shouldReconnect) {
      _scheduleReconnect();
    }
  }

  // ❌ 오류 처리 (개선된 버전)
  void _handleError(error) {
    debugPrint('❌ 웹소켓 오류: $error');
    _isConnected = false;
    
    // 🔥 연결 상태 스트림 업데이트를 마이크로태스크로 지연하여 안정성 확보
    Future.microtask(() {
      _connectionController.add(false);
    });

    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  // 🔌 연결 해제 처리 (개선된 버전)
  void _handleDisconnection() {
    debugPrint('🔌 웹소켓 연결 해제됨');
    _isConnected = false;
    
    // 🔥 연결 상태 스트림 업데이트를 마이크로태스크로 지연하여 안정성 확보
    Future.microtask(() {
      _connectionController.add(false);
    });

    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  // 🔄 재연결 스케줄링 (개선된 버전)
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
    
    // 🔥 지수 백오프 적용 (2초, 4초, 8초, 16초, 32초) - 더 안정적인 간격
    final delay = Duration(
      seconds: _reconnectDelay.inSeconds * (1 << (_reconnectAttempts - 1)),
    );

    debugPrint(
      '🔄 ${delay.inSeconds}초 후 재연결 시도 ($_reconnectAttempts/$_maxReconnectAttempts)',
    );

    _reconnectTimer = Timer(delay, () async {
      // 🔥 타이머 실행 후 즉시 null로 설정하여 중복 방지
      _reconnectTimer = null;

      // 🔥 재연결 조건 재확인 (더 엄격한 조건)
      if (_shouldReconnect && !_isConnected && !_isConnecting && _userId != null) {
        debugPrint('🔄 재연결 시도 시작...');
        try {
          await _doConnect();
        } catch (e) {
          debugPrint('❌ 재연결 실패: $e');
          // 재연결 실패 시 다음 시도 예약
          if (_shouldReconnect && _reconnectAttempts < _maxReconnectAttempts) {
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
    _connectionHealthTimer?.cancel();
    _heartbeatTimer = null;
    _reconnectTimer = null;
    _connectionHealthTimer = null;
    
    // 🔥 연결 상태 변수들 초기화
    _lastHeartbeatReceived = null;
    _lastHeartbeatSent = null;
    _consecutiveHeartbeatFailures = 0;

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

    // 🔥 연결 상태 스트림 업데이트를 마이크로태스크로 지연하여 안정성 확보
    Future.microtask(() {
      _connectionController.add(false);
      debugPrint('✅ 웹소켓 연결 해제 완료');
    });
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

  // 🔥 실시간 친구 상태 요청 (서버에서 지원하지 않으므로 제거)
  // void requestFriendStatus() {
  //   // 서버에서 get_friend_status 메서드를 지원하지 않음
  //   debugPrint('⚠️ get_friend_status 메서드는 서버에서 지원하지 않음');
  // }

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
