// lib/services/jwt_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// JWT 토큰 관리 서비스
class JwtService {
  static const String _tokenKey = 'jwt_token';
  static const String _tokenExpiryKey = 'jwt_token_expiry';
  
  static String? _cachedToken;
  static DateTime? _cachedExpiry;

  /// 🔥 토큰 저장
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      
      // 토큰에서 만료 시간 추출 (JWT는 base64로 인코딩된 payload를 포함)
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          // payload 부분 디코딩
          final payload = parts[1];
          // base64 패딩 추가
          final normalizedPayload = payload.padRight(
            payload.length + (4 - payload.length % 4) % 4,
            '=',
          );
          final decodedPayload = utf8.decode(base64.decode(normalizedPayload));
          final payloadJson = json.decode(decodedPayload);
          
          if (payloadJson['exp'] != null) {
            // exp는 Unix timestamp (초 단위)
            final expiryTimestamp = payloadJson['exp'] as int;
            final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp * 1000);
            await prefs.setString(_tokenExpiryKey, expiryDate.toIso8601String());
            
            debugPrint('🔐 JWT 토큰 저장 완료');
            debugPrint('🔐 토큰 만료 시간: $expiryDate');
          }
        }
      } catch (e) {
        debugPrint('⚠️ JWT 토큰 만료 시간 파싱 실패: $e');
      }
      
      // 캐시 업데이트
      _cachedToken = token;
      
      // 🔥 새로운 토큰 저장 시 기존 캐시 무효화 (사용자가 변경된 경우 대비)
      _clearApiCache();
    } catch (e) {
      debugPrint('❌ JWT 토큰 저장 실패: $e');
    }
  }

  /// 🔥 토큰 가져오기
  static Future<String?> getToken() async {
    try {
      // 캐시된 토큰이 있고 유효하면 반환
      if (_cachedToken != null && _cachedExpiry != null) {
        if (DateTime.now().isBefore(_cachedExpiry!)) {
          return _cachedToken;
        } else {
          // 만료된 토큰은 캐시에서 제거
          _cachedToken = null;
          _cachedExpiry = null;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final expiryString = prefs.getString(_tokenExpiryKey);
      
      if (token != null && expiryString != null) {
        final expiry = DateTime.parse(expiryString);
        if (DateTime.now().isBefore(expiry)) {
          // 유효한 토큰
          _cachedToken = token;
          _cachedExpiry = expiry;
          return token;
        } else {
          // 만료된 토큰 삭제
          await clearToken();
          return null;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ JWT 토큰 가져오기 실패: $e');
      return null;
    }
  }

  /// 🔥 토큰 삭제
  static Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_tokenExpiryKey);
      
      // 캐시 클리어
      _cachedToken = null;
      _cachedExpiry = null;
      
      // 🔥 토큰 삭제 시 API 캐시도 함께 무효화 (로그아웃 대비)
      _clearApiCache();
      
      debugPrint('🔐 JWT 토큰 삭제 완료');
    } catch (e) {
      debugPrint('❌ JWT 토큰 삭제 실패: $e');
    }
  }

  /// 🔥 토큰 유효성 검사
  static Future<bool> isTokenValid() async {
    final token = await getToken();
    return token != null;
  }

  /// 🔥 API 캐시 무효화 (사용자 변경 시 필수)
  static void _clearApiCache() {
    try {
      // ApiHelper의 캐시 초기화를 위해 동적으로 import
      // (순환 참조 방지를 위해 리플렉션 대신 콜백 사용)
      if (_onCacheClearCallback != null) {
        _onCacheClearCallback!();
        debugPrint('🗑️ JWT 토큰 변경에 따른 API 캐시 무효화 완료');
      }
    } catch (e) {
      debugPrint('⚠️ API 캐시 무효화 실패: $e');
    }
  }
  
  /// 🔥 캐시 초기화 콜백 등록 (ApiHelper에서 설정)
  static void Function()? _onCacheClearCallback;
  
  static void registerCacheClearCallback(void Function() callback) {
    _onCacheClearCallback = callback;
    debugPrint('✅ API 캐시 초기화 콜백 등록 완료');
  }

  /// 🔥 Authorization 헤더 생성 (크로스 플랫폼 최적화)
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    
    // 🔥 게스트 사용자인지 확인 (userId가 guest_로 시작하는지 확인)
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final isGuestUser = userId == null || userId.startsWith('guest_');
    
    debugPrint('🔐 JWT 토큰 상태: ${token != null ? "있음" : "없음"}');
    debugPrint('🔐 현재 사용자 ID: $userId');
    debugPrint('🔐 게스트 사용자 여부: $isGuestUser');
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'WSUMAP-Mobile/1.0.0',
      'X-Platform': Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : 'unknown',
    };
    
    // 🔥 게스트 사용자인 경우 항상 X-Guest-User 헤더 추가 (토큰이 있어도)
    if (isGuestUser) {
      headers['X-Guest-User'] = 'true';
      debugPrint('🔐 게스트 사용자로 인식 - X-Guest-User 헤더 추가');
    }
    
    // 토큰이 있으면 Authorization 헤더 추가
    if (token != null) {
      debugPrint('🔐 JWT 토큰 길이: ${token.length}');
      debugPrint('🔐 JWT 토큰 시작: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      headers['Authorization'] = 'Bearer $token';
    } else if (!isGuestUser) {
      // 일반 사용자인데 토큰이 없는 경우 경고
      debugPrint('⚠️ 일반 사용자인데 JWT 토큰이 없습니다.');
    }
    
    return headers;
  }

  /// 🔥 토큰 만료까지 남은 시간 (초)
  static Future<int?> getTokenExpirySeconds() async {
    try {
      if (_cachedExpiry != null) {
        final now = DateTime.now();
        final difference = _cachedExpiry!.difference(now);
        return difference.inSeconds > 0 ? difference.inSeconds : 0;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final expiryString = prefs.getString(_tokenExpiryKey);
      if (expiryString != null) {
        final expiry = DateTime.parse(expiryString);
        final now = DateTime.now();
        final difference = expiry.difference(now);
        return difference.inSeconds > 0 ? difference.inSeconds : 0;
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ 토큰 만료 시간 계산 실패: $e');
      return null;
    }
  }

  /// 🔥 토큰 갱신이 필요한지 확인 (만료 1시간 전)
  static Future<bool> shouldRefreshToken() async {
    try {
      final expirySeconds = await getTokenExpirySeconds();
      if (expirySeconds == null) return false;
      
      // 만료 1시간 전에 갱신 신호
      const refreshThreshold = 3600; // 1시간 = 3600초
      return expirySeconds <= refreshThreshold;
    } catch (e) {
      debugPrint('❌ 토큰 갱신 필요 여부 확인 실패: $e');
      return false;
    }
  }

  /// 🔥 토큰이 곧 만료되는지 확인 (만료 5분 전)
  static Future<bool> isTokenExpiringSoon() async {
    try {
      final expirySeconds = await getTokenExpirySeconds();
      if (expirySeconds == null) return false;
      
      // 만료 5분 전에 경고
      const warningThreshold = 300; // 5분 = 300초
      return expirySeconds <= warningThreshold;
    } catch (e) {
      debugPrint('❌ 토큰 만료 임박 확인 실패: $e');
      return false;
    }
  }
}
