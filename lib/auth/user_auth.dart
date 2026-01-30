// lib/auth/user_auth.dart - 로그아웃 후 재로그인 마커 문제 해결 버전

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../generated/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/websocket_service.dart';
import '../services/jwt_service.dart';
import '../managers/location_manager.dart';
import '../repositories/building_repository.dart';

/// 우송대학교 캠퍼스 네비게이터 사용자 역할 정의
enum UserRole {
  /// 외부 방문자 (게스트)
  external,

  /// 학생 및 교수진 (로그인 사용자)
  studentProfessor,

  /// 시스템 관리자
  admin,
}

/// 인증 관련 상수 정의
class AuthConstants {
  // 지연 시간 상수
  static const Duration locationStartDelay = Duration(seconds: 2);
  static const Duration onlineStatusDelay = Duration(seconds: 3);
  static const Duration logoutNotificationDelay = Duration(milliseconds: 1000);
  static const Duration logoutMessageDelay = Duration(milliseconds: 1500);
  
  // SharedPreferences 키
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserPassword = 'user_password';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyRememberMe = 'remember_me';
  
  // 특수 사용자 ID
  static const String guestPrefix = 'guest_';
  static const String adminId = 'admin';
  static const String guestId = 'guest';
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

/// 우송대학교 캠퍼스 네비게이터 인증 관리 클래스 (최적화된 버전)
class UserAuth extends ChangeNotifier {
  // 사용자 정보
  UserRole? _userRole;
  String? _userId;
  String? _userName;
  bool _isLoggedIn = false;
  bool _isTutorial = true; // 튜토리얼 표시 여부

  // 상태 관리
  bool _isLoading = false;
  String? _lastError;

  // 첫 실행 상태 관리
  bool _isFirstLaunch = true;
  
  // 성능 최적화를 위한 상태 캐싱

  /// 현재 사용자 역할
  UserRole? get userRole => _userRole;

  /// 현재 사용자 ID
  String? get userId => _userId;

  /// 현재 사용자 이름
  String? get userName => _userName;

  /// 로그인 상태
  bool get isLoggedIn => _isLoggedIn;

  /// 튜토리얼 표시 여부
  bool get isTutorial => _isTutorial;

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

  /// 게스트 사용자인지 확인
  bool _isGuestUser() {
    return _userRole == UserRole.external || 
           _userId == null || 
           _userId!.startsWith(AuthConstants.guestPrefix);
  }

  /// 웹소켓 연결 시작 (게스트 제외)
  void _startWebSocketConnection() {
    if (_isGuestUser()) {
      debugPrint('⚠️ 게스트 사용자는 웹소켓 연결 제외');
      return;
    }

    try {
      WebSocketService().connect(_userId!);
      debugPrint('✅ 웹소켓 연결 시작 - 사용자 ID: $_userId');
    } catch (e) {
      debugPrint('❌ 웹소켓 연결 시작 오류: $e');
    }
  }

  /// 위치 전송 시작 (게스트 제외)
  void _startLocationSending(BuildContext context) {
    if (_isGuestUser()) {
      debugPrint('⚠️ 게스트 사용자는 위치 전송 제외');
      return;
    }

    try {
      final locationManager = Provider.of<LocationManager>(
        context,
        listen: false,
      );
      locationManager.startPeriodicLocationSending(userId: _userId!);
      debugPrint('✅ 위치 전송 시작 완료 - 사용자 ID: $_userId');
    } catch (e) {
      debugPrint('❌ 위치 전송 시작 오류: $e');
    }
  }

  /// 위치 전송 중지 (로그아웃 시)
  void _stopLocationSending(BuildContext context) {
    try {
      final locationManager = Provider.of<LocationManager>(
        context,
        listen: false,
      );
      locationManager.stopPeriodicLocationSending();
      debugPrint('✅ 위치 전송 중지 완료');
    } catch (e) {
      debugPrint('❌ 위치 전송 중지 오류: $e');
    }
  }

  /// 위치 전송 및 웹소켓 연결 시작 (지연 실행)
  void _startLocationAndWebSocketWithDelay(BuildContext context) {
    Future.delayed(AuthConstants.locationStartDelay, () {
      _startLocationSending(context);
      _startWebSocketConnection();
    });
  }

  /// 로그인 후 온라인 상태 강제 유지
  void _enforceOnlineStatusAfterLoginWithDelay() {
    Future.delayed(AuthConstants.onlineStatusDelay, () {
      _enforceOnlineStatusAfterLogin();
    });
  }

  /// 서버에 자동 로그인 (저장된 정보 사용)
  Future<bool> autoLoginToServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getString(AuthConstants.keyUserId);
      final savedPassword = prefs.getString(AuthConstants.keyUserPassword);
      final rememberMe = prefs.getBool(AuthConstants.keyRememberMe) ?? false;

      // 기억하기가 체크되어 있고 저장된 정보가 있는 경우만 자동 로그인
      if (rememberMe && savedUserId != null && savedPassword != null) {
        debugPrint('🔄 서버 자동 로그인 시도 - 사용자: $savedUserId');

        final result = await AuthService.login(
          id: savedUserId,
          pw: savedPassword,
        );

        if (result.isSuccess && result.userId != null && result.userName != null) {
          debugPrint('✅ 서버 자동 로그인 성공');
          
          // 🔥 로그인 상태 설정
          _userId = result.userId!;
          _userName = result.userName!;
          _userRole = UserRole.studentProfessor;
          _isLoggedIn = true;
          _isFirstLaunch = false;
          _isTutorial = result.isTutorial ?? true;
          
          debugPrint('🔍 자동 로그인 완료 - 사용자: $_userId, 이름: $_userName');
          
          return true;
        } else {
          debugPrint('⚠️ 서버 자동 로그인 실패: ${result.message}');
          return false;
        }
      }

      return false;
    } catch (e) {
      debugPrint('❌ 서버 자동 로그인 오류: $e');
      return false;
    }
  }

  /// 서버에서만 로그아웃 (로컬 정보는 유지) - 웹소켓 알림 추가
  Future<bool> logoutServerOnly() async {
    try {
      if (_userId != null && _userId != AuthConstants.guestId && _userId != AuthConstants.adminId) {
        debugPrint('🔄 서버 전용 로그아웃 시도 - 사용자: $_userId');

        // 1. 먼저 웹소켓을 통해 친구들에게 로그아웃 알림 전송 (웹소켓 연결은 유지)
        try {
          final wsService = WebSocketService();
          if (wsService.isConnected) {
            debugPrint('🔥 서버 전용 로그아웃: 웹소켓을 통한 로그아웃 알림 전송');
            await wsService.sendLogoutNotification();
            debugPrint('✅ 서버 전용 로그아웃: 웹소켓 로그아웃 알림 완료');
          } else {
            debugPrint('ℹ️ 서버 전용 로그아웃: 웹소켓이 연결되지 않음');
          }
        } catch (wsError) {
          debugPrint('❌ 서버 전용 로그아웃: 웹소켓 알림 전송 실패: $wsError');
        }

        // 2. 잠시 대기하여 서버가 친구들에게 메시지를 전송할 시간 확보
        debugPrint('⏳ 서버가 친구들에게 로그아웃 메시지를 전송할 시간 대기 중...');
        await Future.delayed(AuthConstants.logoutNotificationDelay);

        // 3. 서버에 로그아웃 요청
        final result = await AuthService.logout(id: _userId!);

        if (result.isSuccess) {
          debugPrint('✅ 서버 전용 로그아웃 성공');
          return true;
        } else {
          debugPrint('⚠️ 서버 전용 로그아웃 실패: ${result.message}');
          return false;
        }
      }

      return true; // 게스트나 관리자는 서버 로그아웃 불필요
    } catch (e) {
      debugPrint('❌ 서버 전용 로그아웃 오류: $e');
      return false;
    }
  }

  /// 초기화 - 저장된 로그인 정보 복원 (JWT 토큰 우선 사용)
  Future<void> initialize({BuildContext? context}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getString(AuthConstants.keyUserId);
      final savedUserName = prefs.getString(AuthConstants.keyUserName);
      final savedIsLoggedIn = prefs.getBool(AuthConstants.keyIsLoggedIn) ?? false;
      final rememberMe = prefs.getBool(AuthConstants.keyRememberMe) ?? false;

      // 게스트 사용자는 위치 전송 제외
      if (rememberMe &&
          savedIsLoggedIn &&
          savedUserId != null &&
          savedUserName != null &&
          !savedUserId.startsWith(AuthConstants.guestPrefix)) {
        
        debugPrint('🔄 저장된 로그인 정보 발견 - JWT 토큰 확인');
        
        // 1단계: JWT 토큰이 유효한지 확인
        final isTokenValid = await JwtService.isTokenValid();
        
        if (isTokenValid) {
          debugPrint('✅ JWT 토큰이 유효함 - 토큰으로 로그인 상태 복원');
          
          // 토큰이 유효하면 비밀번호 없이 로그인 상태 복원
          _userId = savedUserId;
          _userName = savedUserName;
          _userRole = UserRole.studentProfessor;
          _isLoggedIn = true;
          _isFirstLaunch = false;
          
          // 게스트가 아닌 경우에만 위치 전송 및 웹소켓 연결 시작 (지연)
          if (context != null) {
            _startLocationAndWebSocketWithDelay(context);
          }
        } else {
          debugPrint('❌ JWT 토큰이 만료됨 - 서버 자동 로그인 시도');
          
          // 2단계: 토큰이 만료되었을 때만 비밀번호로 재로그인
          final autoLoginSuccess = await autoLoginToServer();
          
          if (autoLoginSuccess) {
            debugPrint('✅ 서버 자동 로그인 성공 - 로그인 상태 복원');
            
            if (context != null) {
              _startLocationAndWebSocketWithDelay(context);
            }
          } else {
            debugPrint('❌ 서버 자동 로그인 실패 - 로그인 정보 삭제');
            await _clearLoginInfo();
          }
        }
        
        notifyListeners();
      } else {
        debugPrint('ℹ️ 저장된 로그인 정보 없음 또는 기억하기 미체크');
        await _clearLoginInfo();
      }
    } catch (e) {
      debugPrint('초기화 오류: $e');
      await _clearLoginInfo();
    }
  }

  /// 사용자 로그인 (서버 API 연동) - 서버 DB 검증 강화 및 게스트 진입 방지
  Future<bool> loginWithCredentials({
    required String id,
    required String password,
    bool rememberMe = false,
    BuildContext? context,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('🔄 로그인 시도 시작 - 사용자 ID: $id');
      
      // 서버 DB 검증 강화 - 로그인 API 호출
      final result = await AuthService.login(id: id, pw: password);

      if (result.isSuccess) {
        if (result.userId != null && result.userName != null) {
          debugPrint('✅ 서버 DB 검증 성공 - 사용자 존재 확인');
          
          _userId = result.userId!;
          _userName = result.userName!;
          _userRole = UserRole.studentProfessor;
          _isLoggedIn = true;
          _isFirstLaunch = false;
          _isTutorial = result.isTutorial ?? true; // 서버에서 받은 튜토리얼 정보
          
          debugPrint('🔍 UserAuth: 서버에서 받은 튜토리얼 설정: ${result.isTutorial}');
          debugPrint('🔍 UserAuth: 저장된 튜토리얼 설정: $_isTutorial');
          debugPrint('🔍 UserAuth: 사용자 ID: $_userId');

          // 로그인 성공 시 항상 비밀번호 저장 (프로필 수정 시 확인용)
          await _saveLoginInfo(rememberMe: rememberMe, password: password);

          // 로그인 성공 시 위치 전송 시작 및 웹소켓 연결
          if (context != null) {
            _startLocationSending(context);
            _startWebSocketConnection();
            _enforceOnlineStatusAfterLoginWithDelay();
          }

          notifyListeners();
          return true;
        } else {
          debugPrint('❌ 서버 응답에서 사용자 정보 누락');
          _setErrorFromContext(context, 'user_info_not_found', 
              '로그인 응답에서 사용자 정보를 찾을 수 없습니다.');
          return false;
        }
      } else {
        debugPrint('❌ 서버 DB 검증 실패: ${result.message}');
        _setError(result.message);
        return false;
      }
    } catch (e) {
      debugPrint('❌ 로그인 중 예외 발생: $e');
      _setErrorFromContext(context, 'unexpected_login_error', 
          '로그인 중 예상치 못한 오류가 발생했습니다.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 게스트 로그인 - 서버 API 호출
  Future<void> loginAsGuest({BuildContext? context}) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('🔄 게스트 로그인 시도 - 서버 API 호출');

      // 🔥 서버에 게스트 로그인 요청
      final result = await AuthService.guestLogin();

      if (result.isSuccess) {
        // 🔥 서버에서 반환된 게스트 정보 사용
        final guestId = result.userId ?? '${AuthConstants.guestPrefix}${DateTime.now().millisecondsSinceEpoch}';
        final guestName = result.userName ?? 
            (context != null ? AppLocalizations.of(context)!.guest : '게스트');

        debugPrint('✅ 게스트 로그인 성공 - ID: $guestId');

        // 게스트 사용자 정보 설정
        _userRole = UserRole.external;
        _userId = guestId;
        _userName = guestName;
        _isLoggedIn = true;
        _isFirstLaunch = false;
        _isTutorial = result.isTutorial ?? true; // 게스트는 항상 튜토리얼 표시

        // 게스트 로그인 정보 저장 (선택적)
        await _saveLoginInfo(rememberMe: false);

        debugPrint('✅ 게스트 로그인 완료 - 위치 전송 및 웹소켓 연결 없음');
        
        // 🔥 게스트 로그인 후 API 캐시 초기화는 제거
        // (건물 마커 등 다른 API 호출에 영향을 주지 않도록)
        // 대신 각 API 호출 시 게스트 사용자는 자동으로 forceRefresh를 사용
        
        // 🔥 게스트 로그인 후 BuildingRepository 강제 새로고침 (서버에서 건물 데이터 가져오기)
        try {
          debugPrint('========================================');
          debugPrint('🔥 게스트 로그인 후 건물 데이터 강제 새로고침 시작');
          debugPrint('========================================');
          
          final buildingRepository = BuildingRepository();
          
          debugPrint('1️⃣ BuildingRepository 리셋 시작...');
          buildingRepository.resetForNewSession();
          debugPrint('2️⃣ BuildingRepository 리셋 완료');
          
          debugPrint('3️⃣ 서버에서 건물 데이터 가져오기 시작...');
          final result = await buildingRepository.getAllBuildings(forceRefresh: true);
          
          if (result.isSuccess) {
            debugPrint('✅ 게스트 로그인 후 건물 데이터 새로고침 완료: ${result.data?.length ?? 0}개');
          } else {
            debugPrint('❌ 게스트 로그인 후 건물 데이터 새로고침 실패: ${result.error}');
          }
          
          debugPrint('========================================');
        } catch (e) {
          debugPrint('========================================');
          debugPrint('❌ 게스트 로그인 후 건물 데이터 새로고침 실패: $e');
          debugPrint('========================================');
        }
        
        notifyListeners();
      } else {
        // 🔥 서버 게스트 로그인 실패 시 로컬 fallback
        debugPrint('⚠️ 서버 게스트 로그인 실패, 로컬 게스트 로그인으로 fallback');
        final guestId = '${AuthConstants.guestPrefix}${DateTime.now().millisecondsSinceEpoch}';
        
        _userRole = UserRole.external;
        _userId = guestId;
        _userName = context != null 
            ? AppLocalizations.of(context)!.guest 
            : '게스트';
        _isLoggedIn = true;
        _isFirstLaunch = false;
        _isTutorial = true;

        debugPrint('✅ 로컬 게스트 로그인 완료 (서버 연결 실패)');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ 게스트 로그인 오류: $e');
      _setErrorFromContext(context, 'unexpected_login_error', 
          '게스트 로그인 중 오류가 발생했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 관리자 로그인 (개발용) - 위치 전송 시작 및 웹소켓 연결 추가
  Future<void> loginAsAdmin({BuildContext? context}) async {
    _setLoading(true);
    _clearError();

    try {
      _userRole = UserRole.admin;
      _userId = AuthConstants.adminId;
      _userName = context != null 
          ? AppLocalizations.of(context)!.admin 
          : '관리자';
      _isLoggedIn = true;
      _isFirstLaunch = false;

      await _saveLoginInfo(rememberMe: true);

      // 관리자 로그인 시 위치 전송 시작 및 웹소켓 연결
      if (context != null) {
        _startLocationSending(context);
        _startWebSocketConnection();
        _enforceOnlineStatusAfterLoginWithDelay();
      }

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// 사용자 로그아웃 - 웹소켓 해제 강화된 버전
  Future<bool> logout({BuildContext? context}) async {
    _setLoading(true);

    try {
      debugPrint('🔄 UserAuth: 로그아웃 시작 - 현재 사용자: $_userId');

      // 1. 먼저 웹소켓 연결을 명시적으로 해제하여 친구들에게 로그아웃 알림 전송
      try {
        final wsService = WebSocketService();
        if (wsService.isConnected) {
          debugPrint('🔥 UserAuth: 웹소켓 연결 해제 중...');
          await wsService.logoutAndDisconnect();
          debugPrint('✅ UserAuth: 웹소켓 연결 해제 완료');
        } else {
          debugPrint('ℹ️ UserAuth: 웹소켓이 이미 연결되지 않음');
        }
      } catch (wsError) {
        debugPrint('❌ UserAuth: 웹소켓 해제 중 오류: $wsError');
      }

      // 2. 잠시 대기하여 서버가 친구들에게 로그아웃 메시지를 전송할 시간 확보
      debugPrint('⏳ 서버가 친구들에게 로그아웃 메시지를 전송할 시간 대기 중...');
      await Future.delayed(AuthConstants.logoutMessageDelay);

      // 3. 위치 전송 중지
      if (context != null) {
        _stopLocationSending(context);
      }

      // 4. 서버에 로그아웃 요청
      if (_userId != null && _userId != AuthConstants.guestId && _userId != AuthConstants.adminId) {
        try {
          final result = await AuthService.logout(id: _userId!);
          if (!result.isSuccess) {
            debugPrint('서버 로그아웃 실패: ${result.message}');
          }
        } catch (e) {
          debugPrint('서버 로그아웃 요청 중 오류: $e');
        }
      }

      // 5. 로컬 상태 초기화
      await _clearLoginInfo();

      // 상태 완전 초기화
      final previousUserId = _userId;
      _userRole = null;
      _userId = null;
      _userName = null;
      _isLoggedIn = false;
      _isFirstLaunch = true;
      _clearError();

      debugPrint('🔥 UserAuth: 로그아웃 완료 - 이전 사용자: $previousUserId');

      // 상태 변경 알림 - 지연 없이 즉시 호출
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('❌ UserAuth: 로그아웃 중 오류: $e');

      // 오류가 발생해도 로컬 데이터는 초기화
      await _clearLoginInfo();
      _userRole = null;
      _userId = null;
      _userName = null;
      _isLoggedIn = false;
      _isFirstLaunch = true;
      _clearError();
      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 앱 종료 시 자동 로그아웃 (기억하기 옵션이 false인 경우) - 위치 전송 중지 및 웹소켓 연결 해제 추가
  Future<void> autoLogoutOnAppExit({BuildContext? context}) async {
    debugPrint('🔄 앱 종료 감지 - 자동 로그아웃 확인');

    if (!_isLoggedIn) {
      debugPrint('📝 로그인 상태가 아니므로 자동 로그아웃 스킵');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(AuthConstants.keyRememberMe) ?? false;

      if (rememberMe) {
        debugPrint('✅ 기억하기 옵션이 체크되어 있어 자동 로그아웃 스킵');
        return;
      }

      if (_userRole == UserRole.external || !rememberMe) {
        debugPrint('🔄 자동 로그아웃 실행 - 사용자: $_userId, 역할: $_userRole');

        // 자동 로그아웃 시 위치 전송만 중지 (웹소켓 연결은 유지)
        if (context != null) {
          _stopLocationSending(context);
          debugPrint('✅ 자동 로그아웃 - 위치 전송만 중지, 웹소켓 연결 유지');
        }

        if (_userId != null && _userId != AuthConstants.guestId && _userId != AuthConstants.adminId) {
          try {
            final result = await AuthService.logout(id: _userId!);
            if (result.isSuccess) {
              debugPrint('✅ 서버 로그아웃 성공');
            } else {
              debugPrint('⚠️ 서버 로그아웃 실패: ${result.message}');
            }
          } catch (e) {
            debugPrint('⚠️ 서버 로그아웃 예외: $e');
          }
        }

        await _clearLoginInfo();
        _userRole = null;
        _userId = null;
        _userName = null;
        _isLoggedIn = false;
        _isFirstLaunch = true;
        _clearError();

        debugPrint('✅ 자동 로그아웃 완료');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ 자동 로그아웃 오류: $e');
    }
  }

  /// 로그인 후 강제 온라인 상태 유지 메서드
  void _enforceOnlineStatusAfterLogin() {
    try {
      debugPrint('🛡️ 로그인 후 강제 온라인 상태 유지 시작');
      
      // WebSocket 서비스를 통해 현재 사용자 온라인 상태 강제 확인
      final wsService = WebSocketService();
      if (wsService.isConnected) {
        debugPrint('🛡️ WebSocket 연결 확인됨 - 온라인 상태 유지');
        
        // 하트비트 전송으로 연결 상태 활성화
        wsService.sendHeartbeat();
        
        debugPrint('🛡️ 로그인 후 온라인 상태 강제 유지 완료');
      } else {
        debugPrint('⚠️ WebSocket 연결되지 않음 - 재연결 시도');
        
        // WebSocket 재연결 시도
        if (!_isGuestUser()) {
          _startWebSocketConnection();
        }
      }
    } catch (e) {
      debugPrint('❌ 로그인 후 온라인 상태 유지 중 오류: $e');
    }
  }

  /// 앱 재시작 시 자동 로그아웃 처리된 상태 확인
  Future<bool> shouldAutoLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(AuthConstants.keyRememberMe) ?? false;
      final savedUserId = prefs.getString(AuthConstants.keyUserId);

      return !rememberMe && savedUserId != null;
    } catch (e) {
      debugPrint('자동 로그아웃 확인 오류: $e');
      return false;
    }
  }

  /// 회원가입 (전화번호는 App Store 가이드라인 5.1.1 준수로 수집하지 않음)
  Future<bool> register({
    required String id,
    required String password,
    required String name,
    String? phone,
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

  /// 🔥 회원 탈퇴 - 위치 전송 중지 및 웹소켓 연결 해제 추가
  Future<bool> deleteAccount({BuildContext? context}) async {
    if (_userId == null) {
      _setError('사용자 ID가 없습니다.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      // 🔥 회원 탈퇴 시 위치 전송만 중지 (웹소켓 연결은 유지)
      if (context != null) {
        _stopLocationSending(context);
        // 🔥 웹소켓 연결은 유지 (실시간 통신 필요)
        debugPrint('✅ 회원 탈퇴 - 위치 전송만 중지, 웹소켓 연결 유지');
      }

      final result = await AuthService.deleteUser(id: _userId!);

      if (result.isSuccess) {
        await _clearLoginInfo();
        _userRole = null;
        _userId = null;
        _userName = null;
        _isLoggedIn = false;
        notifyListeners();
        return true;
      } else {
        _setError(result.message);
        return false;
      }
    } catch (e) {
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
      final rememberMe = prefs.getBool(AuthConstants.keyRememberMe) ?? false;
      final savedUserId = prefs.getString(AuthConstants.keyUserId);
      final savedUserName = prefs.getString(AuthConstants.keyUserName);

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

  /// 튜토리얼 표시 여부 업데이트
  Future<bool> updateTutorial({required bool showTutorial}) async {
    try {
      if (_isGuestUser()) {
        debugPrint('⚠️ 게스트 사용자는 튜토리얼 설정을 업데이트할 수 없습니다.');
        return false;
      }

      debugPrint('🔄 튜토리얼 설정 업데이트 시도 - 사용자: $_userId, 표시: $showTutorial');

      final result = await AuthService.updateTutorial(id: _userId!);

      if (result.isSuccess) {
        _isTutorial = showTutorial;
        notifyListeners();
        debugPrint('✅ 튜토리얼 설정 업데이트 성공 - 새로운 값: $_isTutorial');
        return true;
      } else {
        debugPrint('❌ 튜토리얼 설정 업데이트 실패: ${result.message}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ 튜토리얼 설정 업데이트 오류: $e');
      return false;
    }
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

  /// Context를 사용하여 에러 메시지 설정
  void _setErrorFromContext(BuildContext? context, String l10nKey, String fallbackMessage) {
    if (context != null) {
      final l10n = AppLocalizations.of(context)!;
      // l10nKey를 통해 동적으로 번역된 메시지 가져오기
      String message;
      switch (l10nKey) {
        case 'user_info_not_found':
          message = l10n.user_info_not_found;
          break;
        case 'unexpected_login_error':
          message = l10n.unexpected_login_error;
          break;
        case 'login_required':
          message = l10n.login_required;
          break;
        case 'register_error':
          message = l10n.register_error;
          break;
        case 'update_error':
          message = l10n.update_error;
          break;
        case 'delete_error':
          message = l10n.delete_error;
          break;
        default:
          message = fallbackMessage;
      }
      _setError(message);
    } else {
      _setError(fallbackMessage);
    }
  }

  /// 로그인 정보 저장 (수정됨 - 패스워드 저장 추가)
  Future<void> _saveLoginInfo({
    bool rememberMe = false,
    String? password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AuthConstants.keyUserId, _userId ?? '');
      await prefs.setString(AuthConstants.keyUserName, _userName ?? '');
      await prefs.setBool(AuthConstants.keyIsLoggedIn, _isLoggedIn);
      await prefs.setBool(AuthConstants.keyRememberMe, rememberMe);

      // 프로필 수정 시 확인용으로 항상 비밀번호 저장
      if (password != null) {
        await prefs.setString(AuthConstants.keyUserPassword, password);
        debugPrint('🔐 비밀번호 저장됨');
      }
    } catch (e) {
      debugPrint('로그인 정보 저장 오류: $e');
    }
  }

  /// 로그인 정보 삭제
  Future<void> _clearLoginInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AuthConstants.keyUserId);
      await prefs.remove(AuthConstants.keyUserName);
      await prefs.remove(AuthConstants.keyIsLoggedIn);
      await prefs.remove(AuthConstants.keyRememberMe);
      await prefs.remove(AuthConstants.keyUserPassword);
      
      // JWT 토큰 삭제
      await JwtService.clearToken();
      debugPrint('🔐 JWT 토큰 삭제 완료');
    } catch (e) {
      debugPrint('로그인 정보 삭제 오류: $e');
    }
  }
}
