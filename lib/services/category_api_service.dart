import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_config.dart';
import 'package:flutter_application_1/data/category_fallback_data.dart';
import 'package:flutter_application_1/utils/category_name_mapper.dart';
import '../models/category.dart';
import 'api_helper.dart';

class CategoryApiService {
  static final String baseUrl = ApiConfig.categoryBase;

  // 🔥 연결 상태 캐시 (더 긴 시간으로 변경)
  static bool? _lastConnectionStatus;
  static DateTime? _lastConnectionCheck;
  static const Duration _connectionCacheTime = Duration(minutes: 15); // 10분 → 15분으로 증가

  // 🔥 카테고리/건물 캐시 (더 오래 유지)
  static List<Category>? _cachedCategories;
  static Map<String, List<String>> _cachedBuildingNames = {};
  static DateTime? _lastCategoryCacheTime;
  static const Duration _categoryCacheTime = Duration(minutes: 30); // 카테고리 캐시 30분으로 증가

  // 🔥 요청 중복 방지
  static bool _isLoadingCategories = false;
  static Future<List<Category>>? _currentCategoryRequest;

  /// 🔥 카테고리 목록 조회 (메모리 캐시 활용, fallback 지원) - 안정성 개선
  static Future<List<Category>> getCategories({bool forceRefresh = false}) async {
    // 🔥 중복 요청 방지
    if (_isLoadingCategories && _currentCategoryRequest != null) {
      debugPrint('⚠️ 카테고리 요청 중복 방지 - 기존 요청 대기');
      return await _currentCategoryRequest!;
    }

    // 캐시가 유효하고 강제 새로고침이 아닌 경우 캐시 반환
    if (!forceRefresh && _cachedCategories != null && _lastCategoryCacheTime != null) {
      final timeDiff = DateTime.now().difference(_lastCategoryCacheTime!);
      if (timeDiff < _categoryCacheTime) {
        debugPrint('✔️ 유효한 캐시된 카테고리 반환 (${timeDiff.inMinutes}분 전)');
        return _cachedCategories!;
      }
    }

    // 🔥 요청 시작
    _isLoadingCategories = true;
    _currentCategoryRequest = _fetchCategoriesFromServer(forceRefresh);
    
    try {
      final result = await _currentCategoryRequest!;
      return result;
    } finally {
      _isLoadingCategories = false;
      _currentCategoryRequest = null;
    }
  }

  /// 🔥 서버에서 카테고리 가져오기 (내부 메서드)
  static Future<List<Category>> _fetchCategoriesFromServer(bool forceRefresh) async {
    try {
      debugPrint('🔍 getCategories 시작');

      // 연결 상태 확인 (캐시 활용)
      final isConnected = await _checkConnection();
      if (!isConnected) {
        debugPrint('⚠️ 서버 연결 불가, fallback 데이터 사용');
        final fallback = _getFallbackCategories();
        _cachedCategories = fallback;
        _lastCategoryCacheTime = DateTime.now();
        return fallback;
      }

      final response = await ApiHelper.get(baseUrl);

      debugPrint('🔍 getCategories 응답: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint('📄 응답 데이터 개수: ${data.length}');

        Set<String> categoryNames = {};

        for (var item in data) {
          if (item is Map<String, dynamic> && item.containsKey('Category_Name')) {
            final categoryName = item['Category_Name']?.toString();
            if (categoryName != null && categoryName.isNotEmpty) {
              // 🔥 원본 카테고리 이름 그대로 사용 (언어 설정에 따라 표시됨)
              categoryNames.add(categoryName);
            }
          }
        }

        if (categoryNames.isNotEmpty) {
          final categories = categoryNames.map((name) => Category(categoryName: name)).toList();
          debugPrint('✅ 서버에서 카테고리 로딩 성공: ${categories.length}개');
          debugPrint('📋 카테고리 목록: $categoryNames');
          _cachedCategories = categories;
          _lastCategoryCacheTime = DateTime.now();
          return categories;
        } else {
          debugPrint('⚠️ 서버 응답은 성공했지만 카테고리가 비어있음');
          final fallback = _getFallbackCategories();
          _cachedCategories = fallback;
          _lastCategoryCacheTime = DateTime.now();
          return fallback;
        }

      } else {
        debugPrint('❌ 서버 응답 오류: ${response.statusCode}');
        final fallback = _getFallbackCategories();
        _cachedCategories = fallback;
        _lastCategoryCacheTime = DateTime.now();
        return fallback;
      }
    } catch (e) {
      debugPrint('🚨 getCategories 에러: $e');
      final fallback = _getFallbackCategories();
      _cachedCategories = fallback;
      _lastCategoryCacheTime = DateTime.now();
      return fallback;
    }
  }

  /// 🔥 카테고리별 건물 이름 조회 (메모리 캐시 활용, fallback 지원)
  static Future<List<String>> getCategoryBuildingNames(String categoryId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedBuildingNames.containsKey(categoryId)) {
      debugPrint('✔️ 캐시된 건물 목록 반환: $categoryId');
      return _cachedBuildingNames[categoryId]!;
    }

    try {
      debugPrint('🎯 getCategoryBuildingNames 호출: $categoryId');

      // 🔥 연결 상태 확인
      final isConnected = await _checkConnection();
      if (!isConnected) {
        debugPrint('⚠️ 서버 연결 불가, fallback 데이터에서 건물 조회');
        final fallback = CategoryFallbackData.getBuildingsByCategory(categoryId);
        _cachedBuildingNames[categoryId] = fallback;
        return fallback;
      }

      // ✅ 영어 ID → 한글 변환 (서버 요청용)
      final categoryParam = _getKoreanCategoryIfExists(categoryId);

      // 🔥 JWT 토큰을 포함한 요청
      final response = await ApiHelper.get('$baseUrl/${Uri.encodeComponent(categoryParam)}');

      debugPrint('📡 카테고리 응답: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<String> buildingNames = [];

        for (var item in data) {
          if (item is Map<String, dynamic> && item.containsKey('Building_Name')) {
            final buildingName = item['Building_Name']?.toString();
            if (buildingName != null && buildingName.isNotEmpty) {
              buildingNames.add(buildingName);
            }
          }
        }

        if (buildingNames.isNotEmpty) {
          debugPrint('🏢 서버에서 건물 목록 조회 성공: $buildingNames');
          _cachedBuildingNames[categoryId] = buildingNames;
          return buildingNames;
        } else {
          debugPrint('⚠️ 서버에서 해당 카테고리의 건물을 찾지 못함, fallback 사용');
          final fallback = CategoryFallbackData.getBuildingsByCategory(categoryId);
          _cachedBuildingNames[categoryId] = fallback;
          return fallback;
        }

      } else if (response.statusCode == 404) {
        debugPrint('⚠️ 카테고리 "$categoryParam"를 서버에서 찾지 못함, fallback 사용');
        final fallback = CategoryFallbackData.getBuildingsByCategory(categoryId);
        _cachedBuildingNames[categoryId] = fallback;
        return fallback;
      } else {
        debugPrint('❌ 서버 응답 오류: ${response.statusCode}, fallback 사용');
        final fallback = CategoryFallbackData.getBuildingsByCategory(categoryId);
        _cachedBuildingNames[categoryId] = fallback;
        return fallback;
      }

    } catch (e) {
      debugPrint('🚨 getCategoryBuildingNames 에러: $e, fallback 사용');
      final fallback = CategoryFallbackData.getBuildingsByCategory(categoryId);
      _cachedBuildingNames[categoryId] = fallback;
      return fallback;
    }
  }

  /// 🔥 카테고리별 건물+층 정보 조회 (서버에서 [{Building_Name, Floor_Numbers}] 형태)
  static Future<List<Map<String, dynamic>>> getCategoryBuildingInfoList(String categoryId, {bool forceRefresh = false}) async {
    try {
      debugPrint('🎯 getCategoryBuildingInfoList 호출: $categoryId');
      
      // ATM은 서버에서 "은행(atm)"으로 저장되어 있으므로 해당 이름으로 요청
      if (categoryId == 'atm' || categoryId == 'bank_atm' || categoryId == 'bank') {
        debugPrint('🏧 ATM 카테고리는 서버에서 "은행(atm)"으로 저장되어 있음');
        final isConnected = await _checkConnection();
        if (!isConnected) {
          debugPrint('⚠️ 서버 연결 불가, ATM fallback 사용');
          final atmBuildings = CategoryFallbackData.getAtmBuildings();
          return atmBuildings.map((name) => {'Building_Name': name, 'Floor_Numbers': <String>[]}).toList();
        }
        
        // 서버에 "은행(atm)"으로 요청
        final response = await ApiHelper.get('$baseUrl/${Uri.encodeComponent("은행(atm)")}');
        
        debugPrint('📡 ATM 서버 응답: ${response.statusCode}');
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          List<Map<String, dynamic>> result = [];
          for (var item in data) {
            if (item is Map<String, dynamic> && item.containsKey('Building_Name')) {
              result.add({
                'Building_Name': item['Building_Name'],
                'Floor_Numbers': (item['Floor_Numbers'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
              });
            }
          }
          debugPrint('🏢 ATM 서버에서 건물+층 목록 조회 성공: $result');
          if (result.isNotEmpty) {
            return result;
          }
        }
        
        // 서버에서 데이터가 없으면 fallback 사용
        debugPrint('⚠️ ATM 서버 데이터 없음, fallback 사용');
        final atmBuildings = CategoryFallbackData.getAtmBuildings();
        return atmBuildings.map((name) => {'Building_Name': name, 'Floor_Numbers': <String>[]}).toList();
      }
      
      final isConnected = await _checkConnection();
      if (!isConnected) {
        debugPrint('⚠️ 서버 연결 불가, fallback 데이터에서 건물 조회');
        final fallback = CategoryFallbackData.getBuildingsByCategory(categoryId);
        return fallback.map((name) => {'Building_Name': name, 'Floor_Numbers': <String>[]}).toList();
      }
      final categoryParam = _getKoreanCategoryIfExists(categoryId);
      // ✅ 경로를 /category/{카테고리명} 으로 수정
      final response = await ApiHelper.get('$baseUrl/${Uri.encodeComponent(categoryParam)}');
      debugPrint('📡 getCategoryBuildingInfoList 응답: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> result = [];
        for (var item in data) {
          if (item is Map<String, dynamic> && item.containsKey('Building_Name')) {
            result.add({
              'Building_Name': item['Building_Name'],
              'Floor_Numbers': (item['Floor_Numbers'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
            });
          }
        }
        debugPrint('🏢 서버에서 건물+층 목록 조회 성공: $result');
        // 🔥 데이터가 비어 있으면 fallback 사용
        if (result.isEmpty) {
          final fallback = CategoryFallbackData.getBuildingsByCategory(categoryId);
          return fallback.map((name) => {'Building_Name': name, 'Floor_Numbers': <String>[]}).toList();
        }
        return result;
      } else {
        debugPrint('❌ 서버 응답 오류: ${response.statusCode}, fallback 사용');
        final fallback = CategoryFallbackData.getBuildingsByCategory(categoryId);
        return fallback.map((name) => {'Building_Name': name, 'Floor_Numbers': <String>[]}).toList();
      }
    } catch (e) {
      debugPrint('🚨 getCategoryBuildingInfoList 에러: $e, fallback 사용');
      final fallback = CategoryFallbackData.getBuildingsByCategory(categoryId);
      return fallback.map((name) => {'Building_Name': name, 'Floor_Numbers': <String>[]}).toList();
    }
  }

  /// 🧹 캐시 명시적 삭제
  static void clearCache() {
    _cachedCategories = null;
    _cachedBuildingNames.clear();
    _lastCategoryCacheTime = null;
    _isLoadingCategories = false;
    _currentCategoryRequest = null;
    debugPrint('🗑️ 전체 데이터 캐시 비움');
  }

  /// 🧠 ID에서 한글명 찾기 (없으면 그대로 반환)
  static String _getKoreanCategoryIfExists(String id) {
    debugPrint('🔍 _getKoreanCategoryIfExists 호출: $id');
    
    final map = CategoryNameMapper.koreanToId.entries.firstWhere(
      (entry) => entry.value == id,
      orElse: () => const MapEntry('', ''),
    );
    final result = map.key.isNotEmpty ? map.key : id;
    debugPrint('🔍 _getKoreanCategoryIfExists 결과: $id → $result');
    return result;
  }

  /// 🔄 fallback 호출
  static List<Category> _getFallbackCategories() {
    final categoryNames = CategoryFallbackData.getCategories();
    final categories = categoryNames.map((name) => Category(categoryName: name)).toList();
    debugPrint('🔄 Fallback 카테고리 반환: ${categories.length}개');
    return categories;
  }

  /// 🔍 서버 연결 체크
  static Future<bool> _checkConnection() async {
    try {
      if (_lastConnectionStatus != null && _lastConnectionCheck != null) {
        final timeDiff = DateTime.now().difference(_lastConnectionCheck!);
        if (timeDiff < _connectionCacheTime) {
          debugPrint('🔄 연결 상태 캐시 사용: $_lastConnectionStatus');
          return _lastConnectionStatus!;
        }
      }

      debugPrint('🌐 서버 연결 상태 확인 중...');
      // 🔥 JWT 토큰을 포함한 연결 테스트
      final response = await ApiHelper.get(baseUrl);

      final isConnected = response.statusCode == 200 || response.statusCode == 404;

      _lastConnectionStatus = isConnected;
      _lastConnectionCheck = DateTime.now();

      return isConnected;
    } catch (e) {
      debugPrint('❌ 서버 연결 확인 실패: $e');

      _lastConnectionStatus = false;
      _lastConnectionCheck = DateTime.now();

      return false;
    }
  }

  /// 연결 캐시 무효화
  static void invalidateConnectionCache() {
    _lastConnectionStatus = null;
    _lastConnectionCheck = null;
    debugPrint('🗑️ 연결 상태 캐시 무효화');
  }

  /// 수동 연결 테스트
  static Future<bool> testConnection() async {
    invalidateConnectionCache();
    return await _checkConnection();
  }


  /// 디버그 정보 출력
  static void printDebugInfo() {
    debugPrint('=== CategoryApiService Debug Info ===');
    debugPrint('Base URL: $baseUrl');
    debugPrint('Last Connection Status: $_lastConnectionStatus');
    debugPrint('Last Connection Check: $_lastConnectionCheck');
    debugPrint('Fallback Categories: ${CategoryFallbackData.getCategories().length}개');
    debugPrint('=====================================');
  }
}
