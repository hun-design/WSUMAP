// lib/data/category_fallback_data.dart - 새로 생성
// 카테고리 API 실패 시 사용할 fallback 데이터

import 'package:flutter/material.dart';

class CategoryFallbackData {
  
  /// 🔥 카테고리별 건물 매핑 데이터
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

  // 금융
  'atm': ['W1', 'W16'],

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

   /// 🔥 카테고리 목록 가져오기
  static List<String> getCategories() {
    return categoryBuildingMap.keys.toList()..sort();
  }

  static List<String> getBuildingsByCategory(String category) {
    return categoryBuildingMap[category] ?? [];
  }

  static bool hasCategory(String category) {
    return categoryBuildingMap.containsKey(category);
  }

  static List<String> getAllBuildings() {
    final allBuildings = <String>{};
    for (final buildings in categoryBuildingMap.values) {
      allBuildings.addAll(buildings);
    }
    return allBuildings.toList()..sort();
  }

  static List<String> getCategoriesForBuilding(String buildingName) {
    final categories = <String>[];
    for (final entry in categoryBuildingMap.entries) {
      if (entry.value.contains(buildingName)) {
        categories.add(entry.key);
      }
    }
    return categories;
  }

  static Map<String, int> getCategoryStats() {
    return categoryBuildingMap.map(
      (category, buildings) => MapEntry(category, buildings.length),
    );
  }

  /// 카테고리별 아이콘 반환 (이름 기반)
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
      return Icons.atm;
    case 'library':
      return Icons.local_library;
    case 'fitness':
    case 'gym':
      return Icons.fitness_center;
    case 'lounge':
      return Icons.weekend;
    case 'extinguisher':
      return Icons.fire_extinguisher;
    case 'water':
      return Icons.water_drop;
    case 'bookstore':
      return Icons.menu_book;
    case 'post':
      return Icons.local_post_office;
    default:
      return Icons.category;
  }
}

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

class CategoryUtils {
  static String normalizeCategory(String category) {
    return category.trim().toLowerCase();
  }

  static String normalizeBuilding(String building) {
    return building.trim().toUpperCase();
  }

  static int getCategoryColorValue(String categoryId) {
  switch (categoryId) {
    case 'cafe': return 0xFF8B4513;
    case 'restaurant': return 0xFFFF6B35;
    case 'convenience': return 0xFF4CAF50;
    case 'vending': return 0xFF2196F3;
    case 'printer':
    case 'copier': return 0xFF9C27B0;
    case 'atm': return 0xFF4CAF50;
    case 'library': return 0xFF3F51B5;
    case 'fitness':
    case 'gym': return 0xFFFF9800;
    case 'lounge': return 0xFFE91E63;
    case 'extinguisher': return 0xFFF44336;
    case 'water': return 0xFF00BCD4;
    case 'bookstore': return 0xFF673AB7;
    case 'post': return 0xFF4CAF50;
    default: return 0xFF757575;
  }
}

static bool isIndoorCategory(String categoryId) {
  const indoor = [ 'printer', 'copier', 'atm', 'library', 'fitness', 'gym', 'lounge', 'water', 'bookstore' ];
  return indoor.contains(categoryId);
}

static bool is24HourCategory(String categoryId) {
  return ['vending', 'water', 'extinguisher'].contains(categoryId);
}
}