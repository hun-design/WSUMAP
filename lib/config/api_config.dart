// lib/config/api_config.dart
import 'package:flutter/material.dart';

/// API 설정 클래스
class ApiConfig {
  // Base Configuration
  static const String baseHost = 'https://52.65.94.225';
  static const String baseWsHost = '52.65.94.225'; // WebSocket용 호스트 (protocol 제외)
  
  // Port Configuration
  static const int buildingPort = 3000;
  static const int userPort = 3000;
  static const int websocketPort = 3003; // 🔥 서버 포트와 일치 (websocket-server.js에서 3003 사용)
  
  // HTTP API Endpoints
  static String get buildingBase => '$baseHost:$buildingPort/building';
  static String get categoryBase => '$baseHost:$buildingPort/category';
  static String get pathBase => '$baseHost:$buildingPort';
  static String get userBase => '$baseHost:$userPort/user';
  static String get friendBase => '$baseHost:$userPort/friend';
  static String get timetableBase => '$baseHost:$userPort/timetable';
  static String get timetableUploadUrl => '$baseHost:$userPort/timetable/upload';
  static String get timetableUploadBase => '$baseHost:$userPort/timetable';
  static String get floorBase => '$baseHost:$buildingPort/floor';
  static String get roomBase => '$baseHost:$buildingPort/room';
  
  // WebSocket Configuration
  static String get websocketUrl => 'wss://$baseWsHost:$websocketPort/friend/ws';
  static String get websocketBase => 'wss://$baseWsHost:$websocketPort';
  
  // WebSocket 관련 상수들 (연결 안정성 개선)
  static const Duration heartbeatInterval = Duration(seconds: 15); // 🔥 25초 → 15초로 단축
  static const Duration reconnectDelay = Duration(seconds: 2);
  static const Duration connectionTimeout = Duration(seconds: 12);
  static const int maxReconnectAttempts = 5;
  
  // 플랫폼별 최적화 설정 (연결 안정성 개선)
  static const Map<String, Duration> platformHeartbeatIntervals = {
    'android': Duration(seconds: 15), // 🔥 25초 → 15초로 단축
    'ios': Duration(seconds: 15),     // 🔥 25초 → 15초로 단축
    'windows': Duration(seconds: 15), // 🔥 20초 → 15초로 단축
    'macos': Duration(seconds: 15),   // 🔥 20초 → 15초로 단축
    'linux': Duration(seconds: 15),   // 🔥 20초 → 15초로 단축
  };
  
  static const Map<String, Duration> platformConnectionTimeouts = {
    'android': Duration(seconds: 15),
    'ios': Duration(seconds: 12),
    'windows': Duration(seconds: 12),
    'macos': Duration(seconds: 10),
    'linux': Duration(seconds: 14),
  };
  
  // Development/Production 환경 구분
  static bool get isDevelopment => true;
  
  /// 플랫폼별 하트비트 간격 가져오기
  static Duration getHeartbeatIntervalForPlatform(String platform) {
    return platformHeartbeatIntervals[platform] ?? heartbeatInterval;
  }
  
  /// 플랫폼별 연결 타임아웃 가져오기
  static Duration getConnectionTimeoutForPlatform(String platform) {
    return platformConnectionTimeouts[platform] ?? connectionTimeout;
  }
  
  /// 디버그용 정보 출력
  static void printConfiguration() {
    debugPrint('API Configuration:');
    debugPrint('Building API: $buildingBase');
    debugPrint('User API: $userBase');
    debugPrint('Friend API: $friendBase');
    debugPrint('WebSocket: $websocketUrl');
    debugPrint('Timetable API: $timetableBase');
  }
}