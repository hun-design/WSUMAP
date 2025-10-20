// lib/providers/app_language_provider.dart - 최적화된 버전

import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/category_provider.dart';

/// 앱 언어 제공자
class AppLanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('ko');
  CategoryProvider? _categoryProvider;

  Locale get locale => _locale;

  /// 로케일 설정
  void setLocale(Locale locale) {
    if (_locale == locale) {
      debugPrint('🔤 동일한 로케일이므로 변경하지 않음');
      return;
    }
    
    debugPrint('🔤 AppLanguageProvider.setLocale: ${_locale.languageCode} → ${locale.languageCode}');
    
    _locale = locale;
    
    // CategoryProvider에 언어 변경 알림
    _categoryProvider?.onLanguageChanged(locale.languageCode);
    
    notifyListeners();
  }

  /// 강제 리빌드
  void forceRebuild() {
    debugPrint('🔤 강제 리빌드 호출');
    notifyListeners();
  }

  /// CategoryProvider 설정
  void setCategoryProvider(CategoryProvider categoryProvider) {
    _categoryProvider = categoryProvider;
  }
}
