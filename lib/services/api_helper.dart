// lib/services/api_helper.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'jwt_service.dart';

/// API 요청 헬퍼 클래스
class ApiHelper {
  /// 🔥 JWT 토큰이 포함된 헤더로 GET 요청
  static Future<http.Response> get(String url, {Map<String, String>? additionalHeaders}) async {
    final headers = await JwtService.getAuthHeaders();
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    debugPrint('🌐 GET 요청: $url');
    debugPrint('🔐 요청 헤더: $headers');
    
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      debugPrint('📡 GET 응답 상태: ${response.statusCode}');
      debugPrint('📡 GET 응답 본문: ${response.body}');
      return response;
    } catch (e) {
      debugPrint('❌ GET 요청 실패: $e');
      rethrow;
    }
  }

  /// 🔥 JWT 토큰이 포함된 헤더로 POST 요청
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
      final response = await http.post(Uri.parse(url), headers: authHeaders, body: jsonBody);
      debugPrint('📡 POST 응답 상태: ${response.statusCode}');
      debugPrint('📡 POST 응답 본문: ${response.body}');
      return response;
    } catch (e) {
      debugPrint('❌ POST 요청 실패: $e');
      rethrow;
    }
  }

  /// 🔥 JWT 토큰이 포함된 헤더로 PUT 요청
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
    
    return await http.put(Uri.parse(url), headers: authHeaders, body: jsonBody);
  }

  /// 🔥 JWT 토큰이 포함된 헤더로 DELETE 요청
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
    
    return await http.delete(Uri.parse(url), headers: authHeaders, body: jsonBody);
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
}
