// lib/services/building_api_service.dart - 디버그 로그 정리된 버전

import 'dart:convert';
import 'package:flutter_application_1/config/api_config.dart';
import 'package:flutter/material.dart';
import '../models/building.dart';
import 'api_helper.dart';
import 'jwt_service.dart';

class BuildingApiService {
  static final String baseUrl = ApiConfig.buildingBase;
  
  /// 모든 건물 데이터 가져오기
  static Future<List<Building>> getAllBuildings() async {
    try {
      // 🔥 게스트 사용자인 경우 (토큰이 없으면) 항상 캐시 무시하고 새로고침
      final hasToken = await JwtService.isTokenValid();
      final shouldForceRefresh = !hasToken;
      
      debugPrint('========================================');
      debugPrint('🏢 건물 목록 API 호출 시작');
      debugPrint('🏢 URL: $baseUrl');
      debugPrint('🔐 JWT 토큰 유효성: $hasToken');
      debugPrint('🔄 강제 새로고침: $shouldForceRefresh');
      debugPrint('========================================');
      
      final response = await ApiHelper.get(baseUrl, forceRefresh: shouldForceRefresh);
      
      debugPrint('========================================');
      debugPrint('📡 건물 목록 API 응답 상태: ${response.statusCode}');
      debugPrint('📡 건물 목록 API 응답 본문 길이: ${response.body.length}');
      if (response.body.length < 500) {
        debugPrint('📡 건물 목록 API 응답 본문: ${response.body}');
      }
      debugPrint('========================================');
      
      if (response.statusCode == 200) {
        // UTF-8 디코딩
        final String responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonData = json.decode(responseBody);
        
        debugPrint('✅ 건물 목록 파싱 완료: ${jsonData.length}개');
        
        if (jsonData.isEmpty) {
          debugPrint('⚠️ 건물 목록이 비어있습니다!');
          throw Exception('서버에서 건물 데이터가 비어있습니다');
        }
        
        // 서버 데이터를 Building 모델로 변환
        final List<Building> buildings = jsonData.map((json) {
          return Building.fromServerJson(json);
        }).toList();
        
        debugPrint('✅ 건물 데이터 변환 완료: ${buildings.length}개');
        debugPrint('🔍 건물 목록: ${buildings.take(5).map((b) => b.name).join(', ')}${buildings.length > 5 ? '...' : ''}');
        return buildings;
        
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // 🔥 인증 오류 - 게스트 사용자일 때
        debugPrint('========================================');
        debugPrint('❌ 건물 목록 API 인증 오류: ${response.statusCode}');
        debugPrint('❌ 응답 본문: ${response.body}');
        debugPrint('========================================');
        throw Exception('건물 목록을 가져오는데 인증 오류가 발생했습니다: ${response.statusCode}');
      } else {
        debugPrint('========================================');
        debugPrint('❌ 건물 목록 API 오류: ${response.statusCode}');
        debugPrint('❌ 응답 본문: ${response.body}');
        debugPrint('========================================');
        throw Exception('건물 데이터를 가져오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('========================================');
      debugPrint('❌ 건물 데이터 로딩 오류: $e');
      debugPrint('❌ 오류 타입: ${e.runtimeType}');
      debugPrint('========================================');
      rethrow;
    }
  }
  
  /// 특정 건물 정보 가져오기
  static Future<Building?> getBuildingByName(String name) async {
    try {
      final response = await ApiHelper.get('$baseUrl/$name');
      
      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonData = json.decode(responseBody);
        
        if (jsonData.isNotEmpty) {
          return Building.fromServerJson(jsonData.first);
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('특정 건물 조회 실패: $e');
      return null;
    }
  }
}