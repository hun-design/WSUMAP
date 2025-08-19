// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'managers/location_manager.dart';
import 'map/map_screen.dart';
import 'welcome_view.dart';
import 'selection/auth_selection_view.dart';
import 'map/widgets/directions_screen.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'services/websocket_service.dart';
import 'auth/user_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/app_localizations.dart';
import 'providers/app_language_provider.dart';
import 'providers/category_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 즉시 앱 실행하여 스플래시 스크린 우회
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserAuth()),
        ChangeNotifierProvider(create: (_) => AppLanguageProvider()),
        ChangeNotifierProvider(create: (_) => LocationManager()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: const CampusNavigatorApp(),
    ),
  );

  // 앱 실행 후 백그라운드에서 초기화 작업 수행
  _initializeAppInBackground();
}

// 백그라운드에서 앱 초기화 작업 수행
void _initializeAppInBackground() async {
  // 세로 모드 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 시스템 UI 초기 설정
  await _setSystemUIMode();

  // 네이버 지도 초기화
  _initializeNaverMapInBackground();
}

// 네이버 지도 초기화를 백그라운드에서 실행
void _initializeNaverMapInBackground() async {
  try {
    await FlutterNaverMap().init(
      clientId: 'a7hukqhx2a',
      onAuthFailed: (ex) => debugPrint('NaverMap 인증 실패: $ex'),
    );
    debugPrint('✅ 네이버 지도 초기화 성공');
  } catch (e) {
    debugPrint('❌ 네이버 지도 초기화 오류: $e');
  }
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
  bool _disposed = false; // 👈 dispose 상태 추적
  Timer? _systemUIResetTimer; // 👈 시스템 UI 재설정 타이머
  AppLifecycleState _lastLifecycleState = AppLifecycleState.resumed; // 👈 상태 추적

  late final UserAuth _userAuth;
  late final LocationManager _locationManager;
  late final StreamSubscription<List<ConnectivityResult>>
  _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 즉시 초기화 완료로 설정하여 스플래시 스크린 완전 우회
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) {
        setState(() => _isInitialized = true);
        
        _userAuth = Provider.of<UserAuth>(context, listen: false);
        _locationManager = Provider.of<LocationManager>(context, listen: false);

        // 🔥 CategoryProvider 초기화
        final categoryProvider = Provider.of<CategoryProvider>(
          context,
          listen: false,
        );
        categoryProvider.initializeWithFallback();

        _initializeApp();
      }
    });

    // 🔥 네트워크 상태 변경 감지
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      debugPrint('🌐 네트워크 상태 변경: $result');
      
      // 🔥 게스트가 아닌 로그인 사용자에게만 위치 전송 및 웹소켓 연결
      if (_userAuth.isLoggedIn &&
          _userAuth.userId != null &&
          !_userAuth.userId!.startsWith('guest_') &&
          _userAuth.userRole != UserRole.external) {
        
        // 🔥 웹소켓 연결은 이미 앱 초기화 시에 완료되었으므로 재연결하지 않음
        final wsService = WebSocketService();
        if (wsService.isConnected) {
          debugPrint('🌐 네트워크 변경 감지 - 웹소켓 이미 연결됨');
        } else {
          debugPrint('⚠️ 네트워크 변경 감지 - 웹소켓 연결되지 않음 (앱 초기화에서 처리)');
        }
      }
    });
  }

  @override
  void dispose() {
    debugPrint('📱 앱 dispose - 로그아웃 처리');

    _disposed = true; // 👈 dispose 상태 설정

    // 🔥 앱이 dispose될 때도 로그아웃 처리 (iOS 앱 강제 종료 대응)
    if (_userAuth.isLoggedIn &&
        _userAuth.userRole != UserRole.external &&
        _userAuth.userId != null &&
        !_userAuth.userId!.startsWith('guest_')) {
      // 🔥 동기적으로 즉시 처리 (Future.delayed 없이)
      _handleAppDetachedSync();
    }

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

    // 🔥 중복 처리 방지
    if (_lastLifecycleState == state) {
      return;
    }
    _lastLifecycleState = state;

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
    // 👈 Android에서 시스템 UI 재설정
    if (Platform.isAndroid) {
      await _setSystemUIMode();
    }

    // 🔥 게스트 사용자는 위치 전송 및 웹소켓 연결 제외
    if (!_userAuth.isLoggedIn ||
        _userAuth.userRole == UserRole.external ||
        _userAuth.userId == null ||
        _userAuth.userId!.startsWith('guest_')) {
      return;
    }

    try {
      // 저장된 로그인 정보가 있으면 서버 재로그인
      if (await _userAuth.hasSavedLoginInfo()) {
        await _userAuth.autoLoginToServer();
      }

      // 위치 전송만 재시작 (웹소켓은 이미 연결되어 있음)
      _locationManager.startPeriodicLocationSending(userId: _userAuth.userId!);
      
      // 🔥 웹소켓 연결은 이미 앱 초기화 시에 완료되었으므로 재연결하지 않음
      final wsService = WebSocketService();
      if (wsService.isConnected) {
        debugPrint('✅ 포그라운드 복귀 - 웹소켓 이미 연결됨');
      } else {
        debugPrint('⚠️ 포그라운드 복귀 - 웹소켓 연결되지 않음 (앱 초기화에서 처리)');
      }
    } catch (e) {
      debugPrint('❌ 포그라운드 복귀 처리 오류: $e');
    }
  }

  /// 백그라운드 이동
  Future<void> _handleAppPaused() async {
    debugPrint('📱 앱 백그라운드 이동 처리');

    // 🔥 게스트 사용자는 처리 제외
    if (!_userAuth.isLoggedIn ||
        _userAuth.userRole == UserRole.external ||
        _userAuth.userId == null ||
        _userAuth.userId!.startsWith('guest_')) {
      return;
    }

    try {
      // 🔥 웹소켓 연결은 유지하고 위치 전송만 중지 (백그라운드에서도 실시간 통신 유지)
      _locationManager.stopPeriodicLocationSending();
      debugPrint('✅ 백그라운드 이동 - 위치 전송만 중지, 웹소켓 연결 유지');
    } catch (e) {
      debugPrint('❌ 백그라운드 이동 처리 오류: $e');
    }
  }

  /// 🔥 앱 완전 종료 시 - 강제 중지 (비동기)
  Future<void> _handleAppDetached() async {
    _systemUIResetTimer?.cancel(); // 👈 앱 종료 시 타이머 중지

    // 🔥 앱이 완전히 종료될 때만 웹소켓 연결 해제
    // 백그라운드 이동 시에는 웹소켓 연결 유지
    try {
      _locationManager.stopPeriodicLocationSending();
      // 🔥 웹소켓 연결은 유지 (백그라운드에서도 실시간 통신 필요)
      debugPrint('✅ 백그라운드 이동 - 위치 전송만 중지, 웹소켓 연결 유지');
    } catch (e) {
      debugPrint('❌ 위치 전송 중지 오류: $e');
    }

    // 🔥 백그라운드 이동 시에는 서버 로그아웃 처리하지 않음
    // 웹소켓 연결을 유지하여 실시간 통신 계속
    debugPrint('✅ 백그라운드 이동 - 웹소켓 연결 유지, 서버 로그아웃 스킵');
  }

  /// 🔥 앱 완전 종료 시 - 강제 중지 (동기)
  void _handleAppDetachedSync() {
    debugPrint('📱 앱 dispose 시 동기 로그아웃 처리');
    debugPrint('🔍 플랫폼: ${Platform.isIOS ? 'iOS' : 'Android'}');

    _systemUIResetTimer?.cancel(); // 👈 앱 종료 시 타이머 중지

    // 🔥 강제 위치 전송 중지 (웹소켓 연결은 유지)
    try {
      _locationManager.forceStopLocationSending();
      // 🔥 웹소켓 연결은 유지 (앱이 완전히 종료될 때까지)
      debugPrint('✅ 앱 dispose - 위치 전송만 중지, 웹소켓 연결 유지');
    } catch (e) {
      debugPrint('❌ 위치 전송 중지 오류: $e');
    }

    // 🔥 앱 dispose 시에도 서버 로그아웃 처리하지 않음
    // 웹소켓 연결을 유지하여 실시간 통신 계속
    debugPrint('✅ 앱 dispose - 웹소켓 연결 유지, 서버 로그아웃 스킵');
  }

  // ---------- 앱 초기화 ----------
  Future<void> _initializeApp() async {
    try {
      debugPrint('=== 앱 초기화 시작 ===');
      
      // 🔥 CategoryProvider를 AppLanguageProvider에 연결
      final categoryProvider = context.read<CategoryProvider>();
      final languageProvider = context.read<AppLanguageProvider>();
      languageProvider.setCategoryProvider(categoryProvider);
      
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
        
        // 🔥 웹소켓이 이미 연결되지 않은 경우에만 연결
        final wsService = WebSocketService();
        if (!wsService.isConnected) {
          WebSocketService().connect(_userAuth.userId!);
          debugPrint('✅ 일반 사용자 웹소켓 연결 시작');
        } else {
          debugPrint('✅ 웹소켓 이미 연결됨');
        }
        
        debugPrint('✅ 일반 사용자 위치 전송 및 웹소켓 연결 시작');
      } else if (_userAuth.isLoggedIn &&
          _userAuth.userRole == UserRole.external) {
        debugPrint('⚠️ 게스트 사용자 - 위치 전송 및 웹소켓 연결 제외');
      }

      debugPrint('=== 앱 초기화 완료 ===');
    } catch (e) {
      debugPrint('❌ 앱 초기화 오류: $e');
    } finally {
      // mounted 체크를 더 엄격하게 수행
      if (mounted && !_disposed) {
        setState(() => _isInitialized = true);
      }
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Consumer2<AppLanguageProvider, UserAuth>(
      builder: (_, langProvider, auth, __) {
        // 디버그 로그 추가
        debugPrint('🔤 MaterialApp 빌드 - Provider 로케일: ${langProvider.locale.languageCode}');
        debugPrint('🔤 MaterialApp 빌드 - 현재 시간: ${DateTime.now()}');
        
        return MaterialApp(
          title: '따라우송',
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
          supportedLocales: const [Locale('ko'), Locale('en'), Locale('zh'), Locale('es'), Locale('ja'), Locale('ru')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routes: {
            '/map': (context) => const MapScreen(),
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
          home: _buildHomeScreen(auth),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  Widget _buildHomeScreen(UserAuth auth) {
    // 앱 초기화 상태와 관계없이 바로 WelcomeView를 표시
    if (auth.isFirstLaunch) {
      return const WelcomeView();
    } else if (auth.isLoggedIn) {
      return const MapScreen();
    } else {
      return const AuthSelectionView();
    }
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
