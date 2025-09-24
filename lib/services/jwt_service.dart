// lib/services/jwt_service.dart
import 'dart:convert';
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

  /// 🔥 Authorization 헤더 생성
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    debugPrint('🔐 JWT 토큰 상태: ${token != null ? "있음" : "없음"}');
    if (token != null) {
      debugPrint('🔐 JWT 토큰 길이: ${token.length}');
      debugPrint('🔐 JWT 토큰 시작: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    } else {
      debugPrint('⚠️ JWT 토큰이 없어서 인증 헤더 없이 요청');
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    }
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
