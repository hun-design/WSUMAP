// lib/auth/user_auth.dart - 수정된 버전

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../generated/app_localizations.dart';
import '../services/auth_service.dart';

/// 우송대학교 캠퍼스 네비게이터 사용자 역할 정의
enum UserRole {
  /// 외부 방문자 (게스트)
  external,

  /// 학생 및 교수진 (로그인 사용자)
  studentProfessor,

  /// 시스템 관리자
  admin,
}

/// UserRole enum에 대한 확장 기능
extension UserRoleExtension on UserRole {
  /// 사용자 역할의 다국어 표시명
  String displayName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case UserRole.external:
        return l10n.guest;
      case UserRole.studentProfessor:
        return l10n.student_professor;
      case UserRole.admin:
        return l10n.admin;
    }
  }

  /// 역할별 아이콘
  IconData get icon {
    switch (this) {
      case UserRole.external:
        return Icons.person_outline;
      case UserRole.studentProfessor:
        return Icons.school;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }

  /// 역할별 대표 색상 (우송대 테마)
  Color get primaryColor {
    switch (this) {
      case UserRole.external:
        return const Color(0xFF64748B); // 회색
      case UserRole.studentProfessor:
        return const Color(0xFF1E3A8A); // 우송대 남색
      case UserRole.admin:
        return const Color(0xFFDC2626); // 관리자 빨간색
    }
  }

  /// 설정 편집 권한 확인
  bool get canEditSettings => this == UserRole.admin;

  /// 전체 접근 권한 확인
  bool get hasFullAccess => this == UserRole.admin;
}

/// 우송대학교 캠퍼스 네비게이터 인증 관리 클래스
class UserAuth extends ChangeNotifier {
  // 사용자 정보
  UserRole? _userRole;
  String? _userId;
  String? _userName;
  bool _isLoggedIn = false;

  // 상태 관리
  bool _isLoading = false;
  String? _lastError;

  // 첫 실행 상태 관리
  bool _isFirstLaunch = true;

  /// 현재 사용자 역할
  UserRole? get userRole => _userRole;

  /// 현재 사용자 ID
  String? get userId => _userId;

  /// 현재 사용자 이름
  String? get userName => _userName;

  /// 로그인 상태
  bool get isLoggedIn => _isLoggedIn;

  /// 로딩 상태
  bool get isLoading => _isLoading;

  /// 마지막 에러 메시지
  String? get lastError => _lastError;

  /// 첫 실행 상태
  bool get isFirstLaunch => _isFirstLaunch;

  /// 첫 실행 완료 처리
  void completeFirstLaunch() {
    debugPrint('UserAuth: completeFirstLaunch 호출됨');
    _isFirstLaunch = false;
    debugPrint('UserAuth: _isFirstLaunch를 false로 설정');
    notifyListeners();
    debugPrint('UserAuth: notifyListeners 호출됨');
  }

  /// Welcome 화면으로 돌아가기
  void resetToWelcome() {
    debugPrint('UserAuth: resetToWelcome 호출됨');
    _isFirstLaunch = true;
    debugPrint('UserAuth: _isFirstLaunch를 true로 설정');
    notifyListeners();
    debugPrint('UserAuth: notifyListeners 호출됨');
  }

  /// 초기화 - 저장된 로그인 정보 복원 (기억하기가 체크되었던 경우만)
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getString('user_id');
      final savedUserName = prefs.getString('user_name');
      final savedIsLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final rememberMe = prefs.getBool('remember_me') ?? false;

      // 기억하기가 체크되어 있고, 로그인 정보가 모두 있는 경우에만 복원
      if (rememberMe &&
          savedIsLoggedIn &&
          savedUserId != null &&
          savedUserName != null) {
        _userId = savedUserId;
        _userName = savedUserName;
        _userRole = UserRole.studentProfessor;
        _isLoggedIn = true;
        _isFirstLaunch = false; // 저장된 로그인 정보가 있으면 첫 실행이 아님
        notifyListeners();
      } else {
        // 기억하기가 체크되지 않았거나 정보가 불완전한 경우 정보 삭제
        await _clearLoginInfo();
      }
    } catch (e) {
      debugPrint('초기화 오류: $e');
    }
  }

  /// 사용자 로그인 (서버 API 연동)
  Future<bool> loginWithCredentials({
    required String id,
    required String password,
    bool rememberMe = false,
    BuildContext? context,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await AuthService.login(id: id, pw: password);

      if (result.isSuccess) {
        if (result.userId != null && result.userName != null) {
          _userId = result.userId!;
          _userName = result.userName!;
          _userRole = UserRole.studentProfessor;
          _isLoggedIn = true;
          _isFirstLaunch = false; // 로그인 성공 시 첫 실행 상태 해제

          // 기억하기 옵션이 체크된 경우에만 로그인 정보 저장
          if (rememberMe) {
            await _saveLoginInfo(rememberMe: true, password: password);
          } else {
            await _clearLoginInfo();
          }

          notifyListeners();
          return true;
        } else {
          if (context != null) {
            final l10n = AppLocalizations.of(context)!;
            _setError(l10n.user_info_not_found);
          } else {
            _setError('로그인 응답에서 사용자 정보를 찾을 수 없습니다.');
          }
          return false;
        }
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      if (context != null) {
        final l10n = AppLocalizations.of(context)!;
        _setError(l10n.unexpected_login_error);
      } else {
        _setError('로그인 중 예상치 못한 오류가 발생했습니다.');
      }
      debugPrint('로그인 예외: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 게스트 로그인
  Future<void> loginAsGuest({BuildContext? context}) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _userRole = UserRole.external;
      _userId = 'guest';
      if (context != null) {
        final l10n = AppLocalizations.of(context)!;
        _userName = l10n.guest;
      } else {
        _userName = '게스트';
      }
      _isLoggedIn = true;
      _isFirstLaunch = false; // 게스트 로그인 시 첫 실행 상태 해제

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// 관리자 로그인 (개발용)
  Future<void> loginAsAdmin({BuildContext? context}) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _userRole = UserRole.admin;
      _userId = 'admin';
      if (context != null) {
        final l10n = AppLocalizations.of(context)!;
        _userName = l10n.admin;
      } else {
        _userName = '관리자';
      }
      _isLoggedIn = true;
      _isFirstLaunch = false; // 관리자 로그인 시 첫 실행 상태 해제

      await _saveLoginInfo(rememberMe: true);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// 서버에만 로그아웃 (로컬 로그인 정보는 유지)
  /// 앱 백그라운드/종료 시 사용
  Future<void> logoutServerOnly() async {
    try {
      if (_userId != null && _userId != 'guest' && _userId != 'admin') {
        debugPrint('📱 앱 백그라운드 진입 - 서버에만 로그아웃 요청');
        final result = await AuthService.logout(id: _userId!);
        if (result.isSuccess) {
          debugPrint('✅ 서버 로그아웃 성공 - 로컬 정보는 유지');
        } else {
          debugPrint('❌ 서버 로그아웃 실패: ${result.message}');
        }
      }
    } catch (e) {
      debugPrint('❌ 서버 로그아웃 오류: $e');
    }
  }

  /// 저장된 로그인 정보로 자동 서버 로그인
  /// 앱 포그라운드 복귀 시 사용
  Future<void> autoLoginToServer() async {
    try {
      if (_userId != null && _userId != 'guest' && _userId != 'admin') {
        debugPrint('📱 앱 포그라운드 복귀 - 서버에 자동 로그인 시도');

        // 현재 저장된 정보로 서버에 로그인 요청
        final prefs = await SharedPreferences.getInstance();
        final savedUserId = prefs.getString('user_id');
        final savedPassword = prefs.getString('user_password');
        final rememberMe = prefs.getBool('remember_me') ?? false;

        if (rememberMe && savedUserId != null && savedPassword != null) {
          // 기존 로그인 정보를 사용해서 서버에 로그인
          final result = await AuthService.login(
            id: savedUserId,
            pw: savedPassword,
          );

          if (result.isSuccess) {
            debugPrint('✅ 서버 자동 로그인 완료');
          } else {
            debugPrint('❌ 서버 자동 로그인 실패: ${result.message}');
            // 자동 로그인 실패 시 로컬 정보도 삭제 (토큰 만료 등의 경우)
            await _clearLoginInfo();
            _userRole = null;
            _userId = null;
            _userName = null;
            _isLoggedIn = false;
            notifyListeners();
          }
        } else {
          debugPrint('❌ 저장된 로그인 정보가 불완전함');
        }
      }
    } catch (e) {
      debugPrint('❌ 서버 자동 로그인 오류: $e');
    }
  }

  /// 사용자 로그아웃
  Future<bool> logout() async {
    _setLoading(true);

    try {
      if (_userId != null && _userId != 'guest' && _userId != 'admin') {
        final result = await AuthService.logout(id: _userId!);
        if (!result.isSuccess) {
          debugPrint('서버 로그아웃 실패: ${result.message}');
        }
      }

      await _clearLoginInfo();

      _userRole = null;
      _userId = null;
      _userName = null;
      _isLoggedIn = false;
      _isFirstLaunch = true; // 로그아웃 시 Welcome 페이지로 돌아가도록 설정
      _clearError();

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('로그아웃 오류: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 회원가입
  Future<bool> register({
    required String id,
    required String password,
    required String name,
    required String phone,
    String? stuNumber,
    String? email,
    BuildContext? context,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await AuthService.register(
        id: id,
        pw: password,
        name: name,
        phone: phone,
        stuNumber: stuNumber,
        email: email,
      );

      if (result.isSuccess) {
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      if (context != null) {
        final l10n = AppLocalizations.of(context)!;
        _setError(l10n.register_error);
      } else {
        _setError('회원가입 중 예상치 못한 오류가 발생했습니다.');
      }
      debugPrint('회원가입 예외: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 회원정보 수정
  Future<bool> updateUserInfo({
    String? password,
    String? phone,
    String? email,
    BuildContext? context,
  }) async {
    if (_userId == null || !_isLoggedIn) {
      if (context != null) {
        final l10n = AppLocalizations.of(context)!;
        _setError(l10n.login_required);
      } else {
        _setError('로그인이 필요합니다.');
      }
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await AuthService.updateUserInfo(
        id: _userId!,
        pw: password,
        phone: phone,
        email: email,
      );

      if (result.isSuccess) {
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
      if (context != null) {
        final l10n = AppLocalizations.of(context)!;
        _setError(l10n.update_error);
      } else {
        _setError('회원정보 수정 중 예상치 못한 오류가 발생했습니다.');
      }
      debugPrint('회원정보 수정 예외: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 회원 탈퇴
  Future<bool> deleteAccount({BuildContext? context}) async {
    // 1. 로그인 상태가 아니면 탈퇴 불가
    if (_userId == null || !_isLoggedIn) {
      if (context != null) {
        final l10n = AppLocalizations.of(context)!;
        _setError(l10n.login_required); // 다국어 에러 메시지
      } else {
        _setError('로그인이 필요합니다.');
      }
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      // 2. 서버에 회원탈퇴 요청
      final result = await AuthService.deleteUser(id: _userId!);

      if (result.isSuccess) {
        // 3. 로컬 사용자 정보 및 SharedPreferences 삭제
        await _clearLoginInfo();
        _userRole = null;
        _userId = null;
        _userName = null;
        _isLoggedIn = false;

        notifyListeners();
        return true;
      } else {
        // 4. 서버에서 실패 메시지 반환 시 에러 기록
        _setError(result.message);
        return false;
      }
    } catch (e) {
      // 5. 예외 발생 시 에러 메시지 기록
      if (context != null) {
        final l10n = AppLocalizations.of(context)!;
        _setError(l10n.delete_error);
      } else {
        _setError('회원 탈퇴 중 예상치 못한 오류가 발생했습니다.');
      }
      debugPrint('회원 탈퇴 예외: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 현재 사용자의 다국어 표시명
  String getCurrentUserDisplayName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _userName ?? _userRole?.displayName(context) ?? l10n.guest;
  }

  /// 현재 사용자의 아이콘
  IconData get currentUserIcon {
    return _userRole?.icon ?? Icons.person;
  }

  /// 현재 사용자의 색상
  Color get currentUserColor {
    return _userRole?.primaryColor ?? const Color(0xFF64748B);
  }

  /// 현재 사용자가 게스트인지 확인
  bool get isGuest => _userRole == UserRole.external;

  /// 현재 사용자가 관리자인지 확인
  bool get isAdmin => _userRole == UserRole.admin;

  /// 저장된 로그인 정보가 있는지 확인
  Future<bool> hasSavedLoginInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('remember_me') ?? false;
      final savedUserId = prefs.getString('user_id');
      final savedUserName = prefs.getString('user_name');

      return rememberMe && savedUserId != null && savedUserName != null;
    } catch (e) {
      debugPrint('저장된 로그인 정보 확인 오류: $e');
      return false;
    }
  }

  /// 일반 에러 메시지 설정
  void setError(String message) {
    _setError(message);
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _lastError = error;
    notifyListeners();
  }

  void _clearError() {
    _lastError = null;
  }

  /// 로그인 정보 저장 (수정됨 - 패스워드 저장 추가)
  Future<void> _saveLoginInfo({
    bool rememberMe = false,
    String? password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _userId ?? '');
      await prefs.setString('user_name', _userName ?? '');
      await prefs.setBool('is_logged_in', _isLoggedIn);
      await prefs.setBool('remember_me', rememberMe);

      // 🔐 보안 주의: 실제 운영 환경에서는 패스워드 저장 대신
      // 토큰 기반 인증 시스템 사용을 권장합니다.
      if (rememberMe && password != null) {
        await prefs.setString('user_password', password);
      }
    } catch (e) {
      debugPrint('로그인 정보 저장 오류: $e');
    }
  }

  /// 로그인 정보 삭제
  Future<void> _clearLoginInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('user_name');
      await prefs.remove('is_logged_in');
      await prefs.remove('remember_me');
      await prefs.remove('user_password'); // 패스워드도 삭제
    } catch (e) {
      debugPrint('로그인 정보 삭제 오류: $e');
    }
  }
}
