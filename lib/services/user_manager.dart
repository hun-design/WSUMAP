// lib/services/user_manager.dart - 최적화된 버전

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 현재 사용자 정보 관리
class UserManager {
  static UserManager? _instance;
  static UserManager get instance => _instance ??= UserManager._();

  UserManager._();

  // 현재 로그인한 사용자 정보
  String? _currentUserId;
  String? _currentUserName;
  bool _isLoggedIn = false;
  bool _isGuest = false;

  // Getter들
  String? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;
  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;

  /// 로그인 성공 시 사용자 정보 저장
  Future<void> setCurrentUser({
    required String userId,
    required String userName,
    bool isGuest = false,
  }) async {
    _currentUserId = userId;
    _currentUserName = userName;
    _isLoggedIn = true;
    _isGuest = isGuest;

    // SharedPreferences에도 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_id', userId);
    await prefs.setString('current_user_name', userName);
    await prefs.setBool('is_logged_in', true);
    await prefs.setBool('is_guest', isGuest);

    if (kDebugMode) {
      debugPrint('사용자 정보 저장: ID=$userId, Name=$userName, isGuest=$isGuest');
    }
  }

  /// 게스트 로그인
  Future<void> setGuestUser() async {
    final guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    await setCurrentUser(
      userId: guestId,
      userName: 'Guest User',
      isGuest: true,
    );
  }

  /// 로그아웃
  Future<void> logout() async {
    _currentUserId = null;
    _currentUserName = null;
    _isLoggedIn = false;
    _isGuest = false;

    // SharedPreferences에서도 제거
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
    await prefs.remove('current_user_name');
    await prefs.remove('is_logged_in');
    await prefs.remove('is_guest');

    if (kDebugMode) {
      debugPrint('사용자 정보 삭제됨');
    }
  }

  /// 회원탈퇴 (모든 사용자 정보 완전 삭제)
  Future<void> deleteAccount() async {
    _currentUserId = null;
    _currentUserName = null;
    _isLoggedIn = false;
    _isGuest = false;

    // SharedPreferences의 모든 사용자 관련 데이터 삭제
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
    await prefs.remove('current_user_name');
    await prefs.remove('is_logged_in');
    await prefs.remove('is_guest');

    if (kDebugMode) {
      debugPrint('회원탈퇴: 사용자 정보 및 로컬 데이터 완전 삭제 완료');
    }
  }

  /// 앱 시작 시 저장된 사용자 정보 복원
  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();

    _currentUserId = prefs.getString('current_user_id');
    _currentUserName = prefs.getString('current_user_name');
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    _isGuest = prefs.getBool('is_guest') ?? false;

    if (kDebugMode) {
      debugPrint(
        '사용자 정보 복원: ID=$_currentUserId, Name=$_currentUserName, isGuest=$_isGuest',
      );
    }
  }

  /// 사용자별 데이터 키 생성 (SharedPreferences용)
  String getUserDataKey(String dataType) {
    final userId = _currentUserId ?? 'unknown';
    return '${dataType}_$userId';
  }

  /// 현재 사용자가 유효한지 확인
  bool isValidUser() {
    return _currentUserId != null && _currentUserId!.isNotEmpty;
  }
}
