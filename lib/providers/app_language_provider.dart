import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/category_provider.dart';

class AppLanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('ko');
  CategoryProvider? _categoryProvider;

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    debugPrint('🔤 AppLanguageProvider.setLocale 호출: ${locale.languageCode}');
    debugPrint('🔤 이전 로케일: ${_locale.languageCode}');
    
    if (_locale == locale) {
      debugPrint('🔤 동일한 로케일이므로 변경하지 않음');
      return;
    }
    
    _locale = locale;
    debugPrint('🔤 새 로케일 설정: ${_locale.languageCode}');
    
    // 🔥 CategoryProvider에 언어 변경 알림
    if (_categoryProvider != null) {
      _categoryProvider!.onLanguageChanged(locale.languageCode);
    }
    
    debugPrint('🔤 notifyListeners() 호출 시작');
    notifyListeners();
    debugPrint('🔤 notifyListeners() 호출 완료');
    
    // 추가 디버그: 변경된 로케일 확인
    debugPrint('🔤 변경 후 로케일 확인: ${_locale.languageCode}');
  }

  // 강제 리빌드를 위한 메서드 추가
  void forceRebuild() {
    debugPrint('🔤 강제 리빌드 호출');
    notifyListeners();
  }

  // CategoryProvider 설정 메서드
  void setCategoryProvider(CategoryProvider categoryProvider) {
    _categoryProvider = categoryProvider;
  }
}
