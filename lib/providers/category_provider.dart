// lib/providers/category_provider.dart - 최적화된 버전

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/category_api_service.dart';
import 'package:flutter_application_1/data/category_fallback_data.dart';

/// 카테고리 제공자
class CategoryProvider extends ChangeNotifier {
  List<String> _categories = [];
  bool _isLoaded = false;
  bool _isLoading = false;
  String? _error;
  String _currentLanguage = 'ko';

  // Getters
  List<String> get categories => _categories;
  bool get isLoaded => _isLoaded;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 서버에서 카테고리 로드
  Future<void> loadCategoriesFromServer() async {
    if (_isLoading) {
      debugPrint('⚠️ 이미 카테고리 로딩 중');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🔄 서버에서 카테고리 로드 시작...');
      
      final categories = await CategoryApiService.getCategories();
      final categoryNames = categories
          .map((category) => category.categoryName)
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList();

      if (categoryNames.isNotEmpty) {
        debugPrint('✅ 서버에서 카테고리 로딩 성공: ${categoryNames.length}개');
        _categories = categoryNames;
        _isLoaded = true;
      } else {
        debugPrint('⚠️ 서버에서 빈 카테고리 목록 반환, fallback 사용');
        _categories = CategoryFallbackData.getCategories();
        _isLoaded = true;
      }
    } catch (e) {
      debugPrint('❌ 서버 카테고리 로딩 실패: $e, fallback 사용');
      _categories = CategoryFallbackData.getCategories();
      _isLoaded = true;
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// fallback 데이터로 초기화
  void initializeWithFallback() {
    if (!_isLoaded) {
      debugPrint('🔄 fallback 카테고리로 초기화');
      _categories = CategoryFallbackData.getCategories();
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// 언어 변경 시 카테고리 새로고침
  void onLanguageChanged(String newLanguage) {
    if (_currentLanguage != newLanguage) {
      debugPrint('🔤 언어 변경 감지: $_currentLanguage → $newLanguage');
      _currentLanguage = newLanguage;
      refreshCategories();
    }
  }

  /// 카테고리 새로고침
  Future<void> refreshCategories() async {
    await loadCategoriesFromServer();
  }

  /// 카테고리 초기화
  void reset() {
    _categories = [];
    _isLoaded = false;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
