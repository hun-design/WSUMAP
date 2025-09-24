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
  
  // 🔥 WebSocket 관련 상수들
  static const Duration heartbeatInterval = Duration(seconds: 60);
  static const Duration reconnectDelay = Duration(seconds: 5);
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const int maxReconnectAttempts = 5;
  
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