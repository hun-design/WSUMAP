// lib/data/category_fallback_data.dart - 최적화된 버전

import 'package:flutter/material.dart';

/// 🔥 카테고리별 건물 매핑 데이터
class CategoryFallbackData {
  
  /// 카테고리별 건물 매핑 데이터
  static const Map<String, List<String>> categoryBuildingMap = {
    // 편의시설
    'lounge': ['W1', 'W10', 'W12', 'W13', 'W19', 'W3', 'W5', 'W6'],
    'vending': ['W1', 'W10', 'W2', 'W4', 'W5', 'W6'],
    'water': ['W1', 'W10', 'W11', 'W12', 'W13', 'W14', 'W15', 'W16',
              'W17-동관', 'W17-서관', 'W18', 'W19', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8', 'W9'],
    'convenience': ['W16'],

    // 음식/카페
    'cafe': ['W12', 'W5'],
    'restaurant': ['W16'],

    // 시설/장비
    'printer': ['W1', 'W10', 'W12', 'W13', 'W16', 'W19', 'W5', 'W7'],
    'copier': ['W1', 'W10', 'W12', 'W13', 'W16', 'W19', 'W5', 'W7'],

    // 금융 (서버에서 지원하지 않으므로 fallback만 사용)
    'atm': ['W1', 'W16'],
    'bank_atm': ['W1', 'W16'],
    'bank': ['W1', 'W16'],

    // 안전시설
    'extinguisher': ['W1', 'W10', 'W11', 'W12', 'W13', 'W14', 'W15', 'W16',
                     'W17-동관', 'W17-서관', 'W18', 'W19', 'W2', 'W2-1', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8', 'W9'],

    // 학습/도서
    'bookstore': ['W16'],
    'library': ['W1', 'W10'],

    // 운동/건강
    'gym': ['W2-1', 'W5'],
    'fitness': ['W2-1', 'W5'],

    // 기타 서비스
    'post': ['W16'],
  };

  /// 서버에서 지원하는 카테고리 목록
  static const List<String> serverSupportedCategories = [
    'cafe', 'restaurant', 'convenience', 'vending', 'water',
    'printer', 'copier', 'library', 'bookstore', 'post',
    'gym', 'fitness', 'lounge', 'extinguisher', 'atm'
  ];

  /// 실내 카테고리 목록
  static const List<String> indoorCategories = [
    'printer', 'copier', 'atm', 'library', 'fitness', 
    'gym', 'lounge', 'water', 'bookstore'
  ];

  /// 24시간 운영 카테고리 목록
  static const List<String> hour24Categories = [
    'vending', 'water', 'extinguisher'
  ];

  /// 카테고리 목록 가져오기
  static List<String> getCategories() => serverSupportedCategories;

  /// ATM 전용 fallback 데이터
  static List<String> getAtmBuildings() => ['W1', 'W16'];

  /// 카테고리별 건물 목록 가져오기
  static List<String> getBuildingsByCategory(String category) {
    return categoryBuildingMap[category] ?? [];
  }

  /// 카테고리 존재 여부 확인
  static bool hasCategory(String category) {
    return categoryBuildingMap.containsKey(category);
  }

  /// 모든 건물 목록 가져오기 (중복 제거)
  static List<String> getAllBuildings() {
    final allBuildings = <String>{};
    for (final buildings in categoryBuildingMap.values) {
      allBuildings.addAll(buildings);
    }
    return allBuildings.toList()..sort();
  }

  /// 건물별 카테고리 목록 가져오기
  static List<String> getCategoriesForBuilding(String buildingName) {
    final categories = <String>[];
    for (final entry in categoryBuildingMap.entries) {
      if (entry.value.contains(buildingName)) {
        categories.add(entry.key);
      }
    }
    return categories;
  }

  /// 카테고리별 건물 통계
  static Map<String, int> getCategoryStats() {
    return categoryBuildingMap.map(
      (category, buildings) => MapEntry(category, buildings.length),
    );
  }

  /// 카테고리별 아이콘 반환
  static IconData getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'cafe':
        return Icons.local_cafe;
      case 'restaurant':
        return Icons.restaurant;
      case 'convenience':
        return Icons.store;
      case 'vending':
        return Icons.local_convenience_store;
      case 'printer':
        return Icons.print;
      case 'copier':
        return Icons.content_copy;
      case 'atm':
      case 'bank_atm':
      case 'bank':
        return Icons.atm;
      case 'wc':
        return Icons.wc;
      case 'medical':
        return Icons.local_hospital;
      case 'library':
        return Icons.local_library;
      case 'fitness':
      case 'gym':
        return Icons.fitness_center;
      case 'lounge':
        return Icons.weekend;
      case 'extinguisher':
      case 'fire_extinguisher':
        return Icons.fire_extinguisher;
      case 'water':
      case 'water_purifier':
        return Icons.water_drop;
      case 'bookstore':
        return Icons.menu_book;
      case 'post':
        return Icons.local_post_office;
      case 'parking':
        return Icons.local_parking;
      default:
        return Icons.category;
    }
  }

  /// 디버그 정보 출력
  static void printDebugInfo() {
    print('=== Category Fallback Data Info ===');
    print('총 카테고리 수: ${categoryBuildingMap.length}');
    print('총 건물 수: ${getAllBuildings().length}');
    print('카테고리별 건물 수:');
    for (final entry in getCategoryStats().entries) {
      print('  ${entry.key}: ${entry.value}개');
    }
    print('=====================================');
  }
}

/// 🔥 카테고리 유틸리티 클래스
class CategoryUtils {
  
  /// 카테고리 이름 정규화
  static String normalizeCategory(String category) {
    return category.trim().toLowerCase();
  }

  /// 건물 이름 정규화
  static String normalizeBuilding(String building) {
    return building.trim().toUpperCase();
  }

  /// 카테고리별 색상 값
  static int getCategoryColorValue(String categoryId) {
    switch (categoryId) {
      case 'cafe': 
        return 0xFF8B4513;
      case 'restaurant': 
        return 0xFFFF6B35;
      case 'convenience': 
        return 0xFF4CAF50;
      case 'vending': 
        return 0xFF2196F3;
      case 'printer':
      case 'copier': 
        return 0xFF9C27B0;
      case 'atm':
      case 'bank_atm':
      case 'bank': 
        return 0xFF4CAF50;
      case 'library': 
        return 0xFF3F51B5;
      case 'fitness':
      case 'gym': 
        return 0xFFFF9800;
      case 'lounge': 
        return 0xFFE91E63;
      case 'extinguisher':
      case 'fire_extinguisher': 
        return 0xFFF44336;
      case 'water':
      case 'water_purifier': 
        return 0xFF00BCD4;
      case 'bookstore': 
        return 0xFF673AB7;
      case 'post': 
        return 0xFF4CAF50;
      default: 
        return 0xFF757575;
    }
  }

  /// 실내 카테고리 여부
  static bool isIndoorCategory(String categoryId) {
    return CategoryFallbackData.indoorCategories.contains(categoryId);
  }

  /// 24시간 운영 카테고리 여부
  static bool is24HourCategory(String categoryId) {
    return CategoryFallbackData.hour24Categories.contains(categoryId);
  }
}
