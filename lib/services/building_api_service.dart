// lib/services/building_api_service.dart - 디버그 로그 정리된 버전

import 'dart:convert';
import 'package:flutter_application_1/config/api_config.dart';
import 'package:flutter/material.dart';
import '../models/building.dart';
import 'api_helper.dart';

class BuildingApiService {
  static final String baseUrl = ApiConfig.buildingBase;
  
  /// 모든 건물 데이터 가져오기
  static Future<List<Building>> getAllBuildings() async {
    try {
      final response = await ApiHelper.get(baseUrl);
      
      if (response.statusCode == 200) {
        // UTF-8 디코딩
        final String responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonData = json.decode(responseBody);
        
        // 서버 데이터를 Building 모델로 변환
        final List<Building> buildings = jsonData.map((json) {
          return Building.fromServerJson(json);
        }).toList();
        
        return buildings;
        
      } else {
        throw Exception('건물 데이터를 가져오는데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('건물 데이터 로딩 오류: $e');
      throw Exception('네트워크 연결 실패: $e');
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