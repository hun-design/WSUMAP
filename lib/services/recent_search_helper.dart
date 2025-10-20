// lib/services/recent_search_helper.dart - 최적화된 버전

import 'package:shared_preferences/shared_preferences.dart';

/// 최근 검색어 관리
class RecentSearchHelper {
  static const String _key = 'recent_search_queries';
  static const int _maxRecentSearches = 10;

  /// 검색어 추가
  static Future<void> addSearchQuery(String query) async {
    if (query.trim().isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    List<String> recent = prefs.getStringList(_key) ?? [];

    // 중복 제거 후 맨 앞에 추가
    recent.remove(query);
    recent.insert(0, query);

    // 최대 개수 제한
    if (recent.length > _maxRecentSearches) {
      recent = recent.sublist(0, _maxRecentSearches);
    }

    await prefs.setStringList(_key, recent);
  }

  /// 최근 검색어 목록 가져오기
  static Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  /// 최근 검색어 전체 삭제
  static Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// 특정 검색어 삭제
  static Future<void> removeSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recent = prefs.getStringList(_key) ?? [];
    recent.remove(query);
    await prefs.setStringList(_key, recent);
  }
}
