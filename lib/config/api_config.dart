// lib/config/api_config.dart
import 'package:flutter/material.dart';

class ApiConfig {
  // 🌐 Base Configuration
  static const String baseHost = 'http://52.65.94.225';
  static const String baseWsHost = '52.65.94.225'; // WebSocket용 호스트 (protocol 제외)
  
  // 🔌 Port Configuration
  static const int buildingPort = 3000;
  static const int userPort = 3001;
  static const int websocketPort = 3002; // 🔥 WebSocket 포트 추가
  
  // 📡 HTTP API Endpoints
  static String get buildingBase => '$baseHost:$buildingPort/building';
  static String get categoryBase => '$baseHost:$buildingPort/category';
  static String get pathBase => '$baseHost:$buildingPort';
  static String get userBase => '$baseHost:$userPort/user';
  static String get friendBase => '$baseHost:$userPort/friend';
  static String get timetableBase => '$baseHost:$userPort/timetable'; // 시간표 CRUD
  static String get timetableUploadUrl => '$baseHost:$userPort/timetable/upload'; // 엑셀 업로드
  static String get timetableUploadBase => '$baseHost:$userPort/timetable';
  static String get floorBase => '$baseHost:$buildingPort/floor';
  static String get roomBase => '$baseHost:$buildingPort/room';
  
  // 🔌 WebSocket Configuration
  static String get websocketUrl => 'ws://$baseWsHost:$websocketPort/friend/ws';
  static String get websocketBase => 'ws://$baseWsHost:$websocketPort';
  
  // 🔥 WebSocket 관련 상수들 (연결 안정성 개선)
  static const Duration heartbeatInterval = Duration(seconds: 25); // 더 빈번한 하트비트로 연결 안정성 확보
  static const Duration reconnectDelay = Duration(seconds: 2); // 재연결 간격 증가
  static const Duration connectionTimeout = Duration(seconds: 12); // 연결 타임아웃 증가
  static const int maxReconnectAttempts = 5; // 5회 유지
  
  // 🔥 플랫폼별 최적화 설정 (연결 안정성 개선)
  static const Map<String, Duration> platformHeartbeatIntervals = {
    'android': Duration(seconds: 25), // 안드로이드: 더 빈번한 하트비트로 연결 안정성 확보
    'ios': Duration(seconds: 25), // iOS: 더 빈번한 하트비트로 연결 안정성 확보
    'windows': Duration(seconds: 20), // Windows: 네트워크 최적화
    'macos': Duration(seconds: 20), // macOS: 네트워크 최적화
    'linux': Duration(seconds: 20), // Linux: 네트워크 최적화
  };
  
  static const Map<String, Duration> platformConnectionTimeouts = {
    'android': Duration(seconds: 15), // 안드로이드: 네트워크 지연 고려
    'ios': Duration(seconds: 12), // iOS: 빠른 연결
    'windows': Duration(seconds: 12), // Windows: 중간값
    'macos': Duration(seconds: 10), // macOS: 최적화
    'linux': Duration(seconds: 14), // Linux: 네트워크 다양성 고려
  };
  
  // 🛠️ Development/Production 환경 구분 (선택사항)
  static bool get isDevelopment => true; // 환경에 따라 설정
  
  // 🔍 디버그용 정보 출력
  static void printConfiguration() {
    debugPrint('🌐 API Configuration:');
    debugPrint('🏢 Building API: $buildingBase');
    debugPrint('👤 User API: $userBase');
    debugPrint('👫 Friend API: $friendBase');
    debugPrint('🔌 WebSocket: $websocketUrl');
    debugPrint('📅 Timetable API: $timetableBase');
  }
}