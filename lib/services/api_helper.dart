// lib/services/api_helper.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'jwt_service.dart';

/// API 요청 헬퍼 클래스 (최적화된 버전)
class ApiHelper {
  // 🔥 요청 캐시를 위한 Map
  static final Map<String, http.Response> _responseCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 2); // 2분 캐시

  /// 🔥 JWT 토큰이 포함된 헤더로 GET 요청 (캐시 최적화)
  static Future<http.Response> get(String url, {Map<String, String>? additionalHeaders}) async {
    // 🔥 캐시 확인 (GET 요청만 캐시)
    final cacheKey = url;
    if (_responseCache.containsKey(cacheKey)) {
      final timestamp = _cacheTimestamps[cacheKey];
      if (timestamp != null && DateTime.now().difference(timestamp) < _cacheExpiry) {
        debugPrint('📋 캐시된 응답 사용: $url');
        return _responseCache[cacheKey]!;
      } else {
        // 만료된 캐시 제거
        _responseCache.remove(cacheKey);
        _cacheTimestamps.remove(cacheKey);
      }
    }

    final headers = await JwtService.getAuthHeaders();
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    debugPrint('🌐 GET 요청: $url');
    debugPrint('🔐 요청 헤더: $headers');
    
    try {
      final response = await http.get(Uri.parse(url), headers: headers).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⏰ GET 요청 타임아웃: $url');
          throw TimeoutException('GET 요청 타임아웃', const Duration(seconds: 10));
        },
      );
      
      debugPrint('📡 GET 응답 상태: ${response.statusCode}');
      debugPrint('📡 GET 응답 본문: ${response.body}');
      
      // 🔥 성공적인 응답만 캐시
      if (response.statusCode == 200) {
        _responseCache[cacheKey] = response;
        _cacheTimestamps[cacheKey] = DateTime.now();
        debugPrint('📋 응답 캐시됨: $url');
      }
      
      return response;
    } catch (e) {
      debugPrint('❌ GET 요청 실패: $e');
      rethrow;
    }
  }

  /// 🔥 JWT 토큰이 포함된 헤더로 POST 요청 (최적화된 버전)
  static Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final authHeaders = await JwtService.getAuthHeaders();
    if (headers != null) {
      authHeaders.addAll(headers);
    }
    
    // 🔥 body가 Map이나 List인 경우 JSON으로 인코딩
    String? jsonBody;
    if (body != null) {
      if (body is Map || body is List) {
        jsonBody = jsonEncode(body);
      } else if (body is String) {
        jsonBody = body;
      } else {
        jsonBody = body.toString();
      }
    }
    
    debugPrint('🌐 POST 요청: $url');
    debugPrint('🔐 요청 헤더: $authHeaders');
    debugPrint('📤 요청 본문: $jsonBody');
    
    try {
      final response = await http.post(Uri.parse(url), headers: authHeaders, body: jsonBody).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('⏰ POST 요청 타임아웃: $url');
          throw TimeoutException('POST 요청 타임아웃', const Duration(seconds: 15));
        },
      );
      
      debugPrint('📡 POST 응답 상태: ${response.statusCode}');
      debugPrint('📡 POST 응답 본문: ${response.body}');
      
      // 🔥 POST 요청 후 관련 캐시 무효화
      _invalidateRelatedCache(url);
      
      return response;
    } catch (e) {
      debugPrint('❌ POST 요청 실패: $e');
      rethrow;
    }
  }

  /// 🔥 관련 캐시 무효화
  static void _invalidateRelatedCache(String url) {
    // 친구 관련 URL의 경우 친구 목록 캐시 무효화
    if (url.contains('/friend/')) {
      _responseCache.removeWhere((key, value) => key.contains('/friend/'));
      _cacheTimestamps.removeWhere((key, value) => key.contains('/friend/'));
      debugPrint('🗑️ 친구 관련 캐시 무효화됨');
    }
  }

  /// 🔥 JWT 토큰이 포함된 헤더로 PUT 요청 (크로스 플랫폼 최적화)
  static Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final authHeaders = await JwtService.getAuthHeaders();
    if (headers != null) {
      authHeaders.addAll(headers);
    }
    
    // 🔥 body가 Map이나 List인 경우 JSON으로 인코딩
    String? jsonBody;
    if (body != null) {
      if (body is Map || body is List) {
        jsonBody = jsonEncode(body);
      } else if (body is String) {
        jsonBody = body;
      } else {
        jsonBody = body.toString();
      }
    }
    
    debugPrint('🌐 PUT 요청: $url');
    debugPrint('🔐 요청 헤더: $authHeaders');
    debugPrint('📤 요청 본문: $jsonBody');
    
    try {
      final response = await http.put(Uri.parse(url), headers: authHeaders, body: jsonBody).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('⏰ PUT 요청 타임아웃: $url');
          throw TimeoutException('PUT 요청 타임아웃', const Duration(seconds: 15));
        },
      );
      
      debugPrint('📡 PUT 응답 상태: ${response.statusCode}');
      debugPrint('📡 PUT 응답 본문: ${response.body}');
      
      // 🔥 PUT 요청 후 관련 캐시 무효화
      _invalidateRelatedCache(url);
      
      return response;
    } catch (e) {
      debugPrint('❌ PUT 요청 실패: $e');
      rethrow;
    }
  }

  /// 🔥 JWT 토큰이 포함된 헤더로 DELETE 요청 (크로스 플랫폼 최적화)
  static Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final authHeaders = await JwtService.getAuthHeaders();
    if (headers != null) {
      authHeaders.addAll(headers);
    }
    
    // 🔥 body가 Map이나 List인 경우 JSON으로 인코딩
    String? jsonBody;
    if (body != null) {
      if (body is Map || body is List) {
        jsonBody = jsonEncode(body);
      } else if (body is String) {
        jsonBody = body;
      } else {
        jsonBody = body.toString();
      }
    }
    
    debugPrint('🌐 DELETE 요청: $url');
    debugPrint('🔐 요청 헤더: $authHeaders');
    debugPrint('📤 요청 본문: $jsonBody');
    
    try {
      final response = await http.delete(Uri.parse(url), headers: authHeaders, body: jsonBody).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('⏰ DELETE 요청 타임아웃: $url');
          throw TimeoutException('DELETE 요청 타임아웃', const Duration(seconds: 15));
        },
      );
      
      debugPrint('📡 DELETE 응답 상태: ${response.statusCode}');
      debugPrint('📡 DELETE 응답 본문: ${response.body}');
      
      // 🔥 DELETE 요청 후 관련 캐시 무효화
      _invalidateRelatedCache(url);
      
      return response;
    } catch (e) {
      debugPrint('❌ DELETE 요청 실패: $e');
      rethrow;
    }
  }

  /// 🔥 JWT 토큰이 포함된 헤더로 MultipartRequest 생성
  static Future<http.MultipartRequest> createMultipartRequest(
    String method,
    String url, {
    Map<String, String>? headers,
  }) async {
    final request = http.MultipartRequest(method, Uri.parse(url));
    
    final authHeaders = await JwtService.getAuthHeaders();
    request.headers.addAll(authHeaders);
    if (headers != null) {
      request.headers.addAll(headers);
    }
    
    return request;
  }

  /// 🔥 캐시 정리 (메모리 관리)
  static void clearCache() {
    _responseCache.clear();
    _cacheTimestamps.clear();
    debugPrint('🗑️ API 캐시 완전 정리됨');
  }

  /// 🔥 만료된 캐시만 정리
  static void clearExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) >= _cacheExpiry) {
        expiredKeys.add(key);
      }
    });
    
    for (final key in expiredKeys) {
      _responseCache.remove(key);
      _cacheTimestamps.remove(key);
    }
    
    if (expiredKeys.isNotEmpty) {
      debugPrint('🗑️ 만료된 캐시 ${expiredKeys.length}개 정리됨');
    }
  }

  /// 🔥 캐시 통계
  static Map<String, dynamic> getCacheStats() {
    return {
      'totalCached': _responseCache.length,
      'cacheExpiry': _cacheExpiry.inMinutes,
      'oldestCache': _cacheTimestamps.values.isNotEmpty 
          ? _cacheTimestamps.values.reduce((a, b) => a.isBefore(b) ? a : b)
          : null,
    };
  }
}
