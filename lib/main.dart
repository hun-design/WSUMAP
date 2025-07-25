// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/managers/location_manager.dart';
import 'package:flutter_application_1/map/map_screen.dart';
import 'package:flutter_application_1/welcome_view.dart';
import 'package:flutter_application_1/selection/auth_selection_view.dart';
import 'package:flutter_application_1/map/widgets/directions_screen.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'services/websocket_service.dart';
import 'auth/user_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/app_localizations.dart';
import 'providers/app_language_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 👈 세로 모드 고정 추가
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 👈 시스템 UI 초기 설정
  await _setSystemUIMode();

  try {
    await FlutterNaverMap().init(
      clientId: 'a7hukqhx2a',
      onAuthFailed: (ex) => debugPrint('NaverMap 인증 실패: $ex'),
    );
    debugPrint('✅ 네이버 지도 초기화 성공');
  } catch (e) {
    debugPrint('❌ 네이버 지도 초기화 오류: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserAuth()),
        ChangeNotifierProvider(create: (_) => AppLanguageProvider()),
        ChangeNotifierProvider(create: (_) => LocationManager()),
      ],
      child: const CampusNavigatorApp(),
    ),
  );
}

// 👈 시스템 UI 모드 설정 함수
Future<void> _setSystemUIMode() async {
  if (Platform.isAndroid) {
    // Android에서 immersiveSticky 모드 사용 - 자동으로 2-3초 후 숨김
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [SystemUiOverlay.top],
    );
    debugPrint('🔽 Android - immersiveSticky 모드 설정');
  } else {
    // iOS에서는 기존 설정 유지
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
    debugPrint('📱 iOS - manual 모드 설정');
  }
}

class CampusNavigatorApp extends StatefulWidget {
  const CampusNavigatorApp({super.key});

  @override
  State<CampusNavigatorApp> createState() => _CampusNavigatorAppState();
}

/// 앱 생명주기 모니터링
class _CampusNavigatorAppState extends State<CampusNavigatorApp>
    with WidgetsBindingObserver {
  bool _isInitialized = false;
  Timer? _systemUIResetTimer; // 👈 시스템 UI 재설정 타이머

  late final UserAuth _userAuth;
  late final LocationManager _locationManager;
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // provider 인스턴스 캐싱
    _userAuth = Provider.of<UserAuth>(context, listen: false);
    _locationManager = Provider.of<LocationManager>(context, listen: false);

    // 네트워크 상태 변화 감지 및 WebSocket 재연결
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // 하나라도 연결된 네트워크가 있으면 재연결 시도
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection && _userAuth.isLoggedIn && _userAuth.userId != null) {
        WebSocketService().connect(_userAuth.userId!);
        debugPrint('🌐 네트워크 변경 감지 - 웹소켓 재연결 시도');
      }
    });

    _initializeApp();
  }

  @override
  void dispose() {
    _systemUIResetTimer?.cancel(); // 👈 타이머 정리
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // 👈 시스템 UI 재설정 (필요시에만)
  void _resetSystemUIModeIfNeeded() {
    if (Platform.isAndroid) {
      _systemUIResetTimer?.cancel();
      _systemUIResetTimer = Timer(const Duration(milliseconds: 100), () {
        _setSystemUIMode();
      });
    }
  }

  // ---------- 앱 생명주기 콜백 ----------
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('📱 앱 포그라운드 복귀');
        _handleAppResumed();
        break;

      case AppLifecycleState.paused:
        debugPrint('📱 앱 백그라운드 이동');
        _handleAppPaused();
        break;

      case AppLifecycleState.detached:
        debugPrint('📱 앱 완전 종료');
        _handleAppDetached();
        break;

      default:
        break;
    }
  }

  // ---------- 상태별 처리 ----------
  /// 포그라운드 복귀
  Future<void> _handleAppResumed() async {
    debugPrint('📱 앱 포그라운드 복귀');

    // 👈 Android에서 시스템 UI 재설정
    if (Platform.isAndroid) {
      await _setSystemUIMode();
    }

    // 🔥 게스트 사용자는 위치 전송 및 웹소켓 연결 제외
    if (!_userAuth.isLoggedIn ||
        _userAuth.userRole == UserRole.external ||
        _userAuth.userId == null ||
        _userAuth.userId!.startsWith('guest_')) {
      debugPrint('⚠️ 게스트 사용자 - 위치 전송 및 웹소켓 연결 제외');
      return;
    }

    try {
      // 저장된 로그인 정보가 있으면 서버 재로그인
      if (await _userAuth.hasSavedLoginInfo()) {
        await _userAuth.autoLoginToServer();
      }

      // 위치 전송 및 웹소켓 연결 재시작
      _locationManager.startPeriodicLocationSending(userId: _userAuth.userId!);
      WebSocketService().connect(_userAuth.userId!);

      debugPrint('✅ 일반 사용자 위치 전송 및 웹소켓 연결 재시작');
    } catch (e) {
      debugPrint('❌ 포그라운드 복귀 처리 오류: $e');
    }
  }

  /// 🔥 백그라운드 이동 시 - 플랫폼 무관하게 위치 전송 및 웹소켓 연결 중지
  Future<void> _handleAppPaused() async {
    debugPrint('📱 앱 백그라운드 이동 - 위치 전송 및 웹소켓 연결 중지');
    debugPrint('🔍 플랫폼: ${Platform.isIOS ? 'iOS' : 'Android'}');

    _systemUIResetTimer?.cancel(); // 👈 백그라운드 이동 시 타이머 중지

    // 🔥 모든 사용자의 위치 전송 및 웹소켓 연결 무조건 중지 (플랫폼 무관)
    try {
      _locationManager.stopPeriodicLocationSending();
      WebSocketService().disconnect();
      debugPrint('✅ 위치 전송 및 웹소켓 연결 중지 완료');
    } catch (e) {
      debugPrint('❌ 위치 전송 및 웹소켓 연결 중지 오류: $e');
    }

    // 🔥 일반 사용자만 서버 로그아웃 처리
    if (_userAuth.isLoggedIn &&
        _userAuth.userRole != UserRole.external &&
        _userAuth.userId != null &&
        !_userAuth.userId!.startsWith('guest_')) {
      try {
        await _userAuth.logoutServerOnly();
        debugPrint('✅ 서버 로그아웃 완료');
      } catch (e) {
        debugPrint('❌ 서버 로그아웃 오류: $e');
      }
    }
  }

  /// 🔥 앱 완전 종료 시 - 강제 중지
  Future<void> _handleAppDetached() async {
    debugPrint('📱 앱 완전 종료 - 모든 연결 강제 중지');

    _systemUIResetTimer?.cancel(); // 👈 앱 종료 시 타이머 중지

    // 🔥 강제 위치 전송 및 웹소켓 연결 중지
    try {
      _locationManager.forceStopLocationSending();
      WebSocketService().disconnect();
      debugPrint('✅ 모든 연결 강제 중지 완료');
    } catch (e) {
      debugPrint('❌ 연결 강제 중지 오류: $e');
    }

    // 🔥 일반 사용자만 서버 로그아웃 처리
    if (_userAuth.isLoggedIn &&
        _userAuth.userRole != UserRole.external &&
        _userAuth.userId != null &&
        !_userAuth.userId!.startsWith('guest_')) {
      try {
        await _userAuth.logoutServerOnly();
        debugPrint('✅ 서버 로그아웃 완료');
      } catch (e) {
        debugPrint('❌ 서버 로그아웃 오류: $e');
      }
    }
  }

  // ---------- 앱 초기화 ----------
  Future<void> _initializeApp() async {
    try {
      debugPrint('=== 앱 초기화 시작 ===');
      await _userAuth.initialize();

      // 🔥 게스트가 아닌 로그인 사용자에게만 위치 전송 및 웹소켓 연결
      if (_userAuth.isLoggedIn &&
          _userAuth.userId != null &&
          _userAuth.userRole != UserRole.external && // 게스트 제외
          !_userAuth.userId!.startsWith('guest_')) {
        // 게스트 ID 체크
        await _userAuth.autoLoginToServer();

        _locationManager.startPeriodicLocationSending(
          userId: _userAuth.userId!,
        );
        WebSocketService().connect(_userAuth.userId!);
        debugPrint('✅ 일반 사용자 위치 전송 및 웹소켓 연결 시작');
      } else if (_userAuth.isLoggedIn &&
          _userAuth.userRole == UserRole.external) {
        debugPrint('⚠️ 게스트 사용자 - 위치 전송 및 웹소켓 연결 제외');
      }

      debugPrint('=== 앱 초기화 완료 ===');
    } catch (e) {
      debugPrint('❌ 앱 초기화 오류: $e');
    } finally {
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Consumer<AppLanguageProvider>(
      builder: (_, langProvider, __) {
        return MaterialApp(
          title: 'Campus Navigator',
          theme: ThemeData(
            primarySwatch: createMaterialColor(const Color(0xFF1E3A8A)),
            fontFamily: 'Pretendard',
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          locale: langProvider.locale,
          supportedLocales: const [Locale('ko'), Locale('en'), Locale('zh')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routes: {
            '/directions': (context) {
              final args =
                  ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
              return DirectionsScreen(roomData: args);
            },
          },
          builder: (context, child) {
            // 👈 화면이 그려진 후 시스템 UI 재설정
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _resetSystemUIModeIfNeeded();
            });
            return child!;
          },
          home: _isInitialized
              ? Consumer<UserAuth>(
                  builder: (_, auth, __) {
                    if (auth.isFirstLaunch) {
                      return const WelcomeView();
                    } else if (auth.isLoggedIn) {
                      return const MapScreen();
                    } else {
                      return const AuthSelectionView();
                    }
                  },
                )
              : _buildLoadingScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(Icons.school, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 32),
              const Text(
                '우송대학교',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '캠퍼스 네비게이터',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '초기화 중...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- 색상 유틸 ----------
MaterialColor createMaterialColor(Color color) {
  final strengths = <double>[.05];
  final swatch = <int, Color>{};
  final r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }

  for (var strength in strengths) {
    final ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}
