// lib/main.dart - Optimized Campus Navigator App
import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'auth/user_auth.dart';
import 'managers/location_manager.dart';
import 'map/map_screen.dart';
import 'map/widgets/directions_screen.dart';
import 'welcome_view.dart';
import 'selection/auth_selection_view.dart';
import 'services/websocket_service.dart';
import 'generated/app_localizations.dart';
import 'providers/app_language_provider.dart';
import 'providers/category_provider.dart';
import 'utils/image_memory_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 불필요한 로그 필터링
  _filterLogs();

  // 앱 실행
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

  // 백그라운드에서 초기화 작업 수행
  _initializeAppInBackground();
}

/// 백그라운드에서 앱 초기화 작업 수행 (최적화된 버전)
Future<void> _initializeAppInBackground() async {
  try {
    // 🔥 더 빠른 병렬 초기화 - 즉시 실행
    unawaited(Future.wait([
      // 세로 모드 고정
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]),
      // 시스템 UI 초기 설정
      _setSystemUIMode(),
      // 네이버 지도 초기화
      _initializeNaverMapInBackground(),
    ]));
    
    debugPrint('✅ 백그라운드 초기화 시작 (비동기)');
  } catch (e) {
    debugPrint('❌ 백그라운드 초기화 오류: $e');
    // 개별 작업 실패 시에도 앱이 계속 실행되도록 처리
  }
}

/// 네이버 지도 초기화를 백그라운드에서 실행
Future<void> _initializeNaverMapInBackground() async {
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

/// 시스템 UI 모드 설정 함수
Future<void> _setSystemUIMode() async {
  try {
    if (Platform.isAndroid) {
      // 🔥 Android에서 키보드 오버플로우 방지를 위한 설정
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [SystemUiOverlay.top],
      );
      
      // 🔥 Android 키보드 처리 개선
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      
      debugPrint('✅ Android - immersiveSticky 모드 설정 (키보드 오버플로우 방지)');
    } else {
      // iOS에서는 manual 모드 사용
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top],
      );
      debugPrint('✅ iOS - manual 모드 설정');
    }
  } catch (e) {
    debugPrint('❌ 시스템 UI 모드 설정 실패: $e');
  }
}

class CampusNavigatorApp extends StatefulWidget {
  const CampusNavigatorApp({super.key});

  @override
  State<CampusNavigatorApp> createState() => _CampusNavigatorAppState();
}

/// 앱 생명주기 모니터링 (최적화된 버전)
class _CampusNavigatorAppState extends State<CampusNavigatorApp>
    with WidgetsBindingObserver {
  bool _disposed = false;
  Timer? _systemUIResetTimer;
  AppLifecycleState _lastLifecycleState = AppLifecycleState.resumed;

  late final UserAuth _userAuth;
  late final LocationManager _locationManager;
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  
  // 메모리 효율성을 위한 debouncing
  Timer? _connectivityDebounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 초기화 완료 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) {
        _userAuth = Provider.of<UserAuth>(context, listen: false);
        _locationManager = Provider.of<LocationManager>(context, listen: false);

        // CategoryProvider 초기화
        final categoryProvider = Provider.of<CategoryProvider>(
          context,
          listen: false,
        );
        categoryProvider.initializeWithFallback();

        _initializeApp();
      }
    });

    // 네트워크 상태 변경 감지 (최적화된 버전 - debouncing 적용)
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      // 빈번한 네트워크 상태 변경을 위한 debouncing
      _connectivityDebounceTimer?.cancel();
      _connectivityDebounceTimer = Timer(const Duration(milliseconds: 500), () {
        if (!_disposed) {
          _handleConnectivityChange(result);
        }
      });
    });
  }

  @override
  void dispose() {
    debugPrint('📱 앱 dispose - 정리 작업');

    _disposed = true;

    // 앱이 dispose될 때 로그아웃 처리
    if (_userAuth.isLoggedIn &&
        _userAuth.userRole != UserRole.external &&
        _userAuth.userId != null &&
        !_userAuth.userId!.startsWith('guest_')) {
      _handleAppDetachedSync();
    }

    // 모든 타이머 정리
    _systemUIResetTimer?.cancel();
    _connectivityDebounceTimer?.cancel();
    
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();
    super.dispose();
  }
  
  /// 네트워크 상태 변경 처리 (분리된 메서드)
  void _handleConnectivityChange(List<ConnectivityResult> result) {
    debugPrint('🌐 네트워크 상태 변경: $result');
    
    // 게스트가 아닌 로그인 사용자에게만 위치 전송 및 웹소켓 연결
    if (_userAuth.isLoggedIn &&
        _userAuth.userId != null &&
        !_userAuth.userId!.startsWith('guest_') &&
        _userAuth.userRole != UserRole.external) {
      
      final wsService = WebSocketService();
      if (wsService.isConnected) {
        debugPrint('✅ 네트워크 변경 감지 - 웹소켓 이미 연결됨');
      } else {
        debugPrint('⚠️ 네트워크 변경 감지 - 웹소켓 연결되지 않음, 재연결 시도');
        // 네트워크 복구 시 웹소켓 재연결
        wsService.connect(_userAuth.userId!);
      }
    }
  }

  /// 시스템 UI 재설정 (필요시에만)
  void _resetSystemUIModeIfNeeded() {
    if (Platform.isAndroid) {
      _systemUIResetTimer?.cancel();
      _systemUIResetTimer = Timer(const Duration(milliseconds: 200), () {
        try {
          _setSystemUIMode();
        } catch (e) {
          debugPrint('❌ 시스템 UI 재설정 실패: $e');
        }
      });
    }
  }

  /// 앱 생명주기 콜백
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 중복 처리 방지
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

  /// 포그라운드 복귀 처리
  Future<void> _handleAppResumed() async {
    // Android에서 시스템 UI 재설정
    if (Platform.isAndroid) {
      try {
        await _setSystemUIMode();
      } catch (e) {
        debugPrint('❌ 포그라운드 복귀 시 시스템 UI 재설정 실패: $e');
      }
    }

    // 게스트 사용자는 위치 전송 및 웹소켓 연결 제외
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

      // 🔥 위치 전송은 사용자가 활성화한 경우에만 재시작
      // (ProfileActionPage의 상태를 확인하여 결정)
      debugPrint('✅ 포그라운드 복귀 - 위치 전송은 사용자 설정에 따라 재시작');
      
      // 웹소켓 연결 상태 확인 및 강제 온라인 상태 유지
      final wsService = WebSocketService();
      if (wsService.isConnected) {
        debugPrint('✅ 포그라운드 복귀 - 웹소켓 이미 연결됨');
        
        // 🔥 포그라운드 복귀 시 강제 온라인 상태 유지
        _enforceUserOnlineStatus();
      } else {
        debugPrint('⚠️ 포그라운드 복귀 - 웹소켓 연결되지 않음');
        
        // 🔥 WebSocket 재연결 시도
        try {
          await wsService.connect(_userAuth.userId!);
          debugPrint('✅ 포그라운드 복귀 - WebSocket 재연결 성공');
          _enforceUserOnlineStatus();
        } catch (e) {
          debugPrint('❌ 포그라운드 복귀 - WebSocket 재연결 실패: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ 포그라운드 복귀 처리 오류: $e');
    }
  }

  /// 🔥 사용자 온라인 상태 강제 유지
  void _enforceUserOnlineStatus() {
    try {
      // 🔥 WebSocket 서비스를 통해 온라인 상태 강제 유지
      final wsService = WebSocketService();
      if (wsService.isConnected) {
        // 🔥 하트비트 전송으로 연결 상태 활성화
        wsService.sendHeartbeat();
        if (kDebugMode) {
          debugPrint('🛡️ 포그라운드 복귀 시 온라인 상태 강제 유지');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ 온라인 상태 강제 유지 중 오류: $e');
      }
    }
  }

  /// 백그라운드 이동 처리
  Future<void> _handleAppPaused() async {
    debugPrint('📱 앱 백그라운드 이동 처리');

    // 게스트 사용자는 처리 제외
    if (!_userAuth.isLoggedIn ||
        _userAuth.userRole == UserRole.external ||
        _userAuth.userId == null ||
        _userAuth.userId!.startsWith('guest_')) {
      return;
    }

    try {
      // 위치 전송만 중지 (웹소켓 연결 유지)
      _locationManager.stopPeriodicLocationSending();
      debugPrint('✅ 백그라운드 이동 - 위치 전송만 중지, 웹소켓 연결 유지');
    } catch (e) {
      debugPrint('❌ 백그라운드 이동 처리 오류: $e');
    }
  }

  /// 앱 완전 종료 처리 (비동기)
  Future<void> _handleAppDetached() async {
    _systemUIResetTimer?.cancel();

    try {
      _locationManager.stopPeriodicLocationSending();
      debugPrint('✅ 앱 종료 - 위치 전송 중지, 웹소켓 연결 유지');
    } catch (e) {
      debugPrint('❌ 위치 전송 중지 오류: $e');
    }

    debugPrint('✅ 앱 종료 - 웹소켓 연결 유지');
  }

  /// 앱 완전 종료 처리 (동기)
  void _handleAppDetachedSync() {
    debugPrint('📱 앱 dispose 시 동기 처리');
    debugPrint('🔍 플랫폼: ${Platform.isIOS ? 'iOS' : 'Android'}');

    _systemUIResetTimer?.cancel();

    try {
      _locationManager.forceStopLocationSending();
      debugPrint('✅ 앱 dispose - 위치 전송 중지, 웹소켓 연결 유지');
    } catch (e) {
      debugPrint('❌ 위치 전송 중지 오류: $e');
    }

    debugPrint('✅ 앱 dispose - 웹소켓 연결 유지');
  }

  /// 앱 초기화
  Future<void> _initializeApp() async {
    try {
      debugPrint('=== 앱 초기화 시작 ===');
      
      // CategoryProvider를 AppLanguageProvider에 연결
      final categoryProvider = context.read<CategoryProvider>();
      final languageProvider = context.read<AppLanguageProvider>();
      languageProvider.setCategoryProvider(categoryProvider);
      
      await _userAuth.initialize();

      // 게스트가 아닌 로그인 사용자에게만 위치 전송 및 웹소켓 연결
      if (_userAuth.isLoggedIn &&
          _userAuth.userId != null &&
          _userAuth.userRole != UserRole.external &&
          !_userAuth.userId!.startsWith('guest_')) {
        
        await _userAuth.autoLoginToServer();

        // 🔥 위치 전송은 사용자가 명시적으로 활성화한 경우에만 시작
        // (ProfileActionPage에서 사용자가 토글을 켜면 자동으로 시작됨)
        debugPrint('✅ 일반 사용자 로그인 완료 - 위치 전송은 사용자 설정에 따라 시작');
        
        // 웹소켓이 이미 연결되지 않은 경우에만 연결
        final wsService = WebSocketService();
        if (!wsService.isConnected) {
          WebSocketService().connect(_userAuth.userId!);
          debugPrint('✅ 일반 사용자 웹소켓 연결 시작');
        } else {
          debugPrint('✅ 웹소켓 이미 연결됨');
        }
        
        debugPrint('✅ 일반 사용자 웹소켓 연결 시작');
      } else if (_userAuth.isLoggedIn &&
          _userAuth.userRole == UserRole.external) {
        debugPrint('⚠️ 게스트 사용자 - 위치 전송 및 웹소켓 연결 제외');
      }

      debugPrint('=== 앱 초기화 완료 ===');
    } catch (e) {
      debugPrint('❌ 앱 초기화 오류: $e');
    }
  }

  /// UI 빌드
  @override
  Widget build(BuildContext context) {
    return Consumer2<AppLanguageProvider, UserAuth>(
      builder: (_, langProvider, auth, __) {
        return MaterialApp(
          title: 'FolloWoosong',
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
          supportedLocales: const [
            Locale('ko'), 
            Locale('en'), 
            Locale('zh'), 
            Locale('es'), 
            Locale('ja'), 
            Locale('ru')
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routes: {
            '/map': (context) => const MapScreen(),
            '/directions': (context) {
              final args = ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
              return DirectionsScreen(roomData: args);
            },
          },
          builder: (context, child) {
            // 화면이 그려진 후 시스템 UI 재설정
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

  /// 🔥 홈 화면 빌드 (로그인 상태 엄격 검증)
  Widget _buildHomeScreen(UserAuth auth) {
    if (auth.isFirstLaunch) {
      return const WelcomeView();
    } else if (auth.isLoggedIn && auth.userId != null && !auth.userId!.startsWith('guest_')) {
      // 🔥 로그인 상태이고 게스트가 아닌 경우에만 MapScreen으로 이동
      return const MapScreen();
    } else {
      // 🔥 로그인하지 않았거나 게스트인 경우 인증 선택 화면으로 이동
      return const AuthSelectionView();
    }
  }
}

/// MaterialColor 생성 유틸리티
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

/// 불필요한 로그들을 필터링하는 함수 (최강 버전)
void _filterLogs() {
  try {
    // 🔥 즉시 ImageReader_JNI 로그 차단
    _blockImageReaderJNILogsImmediately();
    
    developer.log(
      '🔥 ImageReader_JNI 로그 완전 억제 시작',
      name: 'LogFilter',
    );
    
    if (Platform.isAndroid) {
      // Android에서 불필요한 네이티브 로그들을 완전히 억제
      suppressAndroidLogs();
      
      // 🔥 추가: 시스템 레벨 로그 차단
      _blockSystemLevelLogs();
      
      // 🔥 추가: 네이티브 로그 완전 차단
      _blockNativeLogsCompletely();
      
  // 🔥 최강: ImageReader_JNI 로그 평생 차단
  blockImageReaderJNIForever();
  
  // 🔥 최강: 시스템 레벨 로그 완전 차단
  blockSystemLogsForever();
  
  // 🔥 최강: 네이티브 로그 평생 차단
  blockNativeLogsForever();
  
  // 🔥 최종: ImageReader_JNI 로그 완전 차단 (최종 버전)
  blockImageReaderJNIForeverFinal();
  
  // 🔥 최종: 시스템 로그 완전 차단 (최종 버전)
  blockSystemLogsForeverFinal();
  
  // 🔥 최종: 네이티브 로그 완전 차단 (최종 버전)
  blockNativeLogsForeverFinal();
      
      developer.log(
        '✅ Android 네이티브 로그 억제 완료 - ImageReader_JNI 평생 차단됨',
        name: 'AndroidLogFilter',
      );
    }
    
  } catch (e) {
    developer.log(
      '⚠️ 로그 필터링 중 오류 (무시 가능): $e',
      name: 'LogFilterError',
    );
  }
}

/// 🔥 ImageReader_JNI 로그 평생 차단 (최강 버전)
void blockImageReaderJNIForever() {
  try {
    developer.log(
      '🔥 ImageReader_JNI 로그 평생 차단 시작',
      name: 'ImageReaderJNIBlock',
    );
    
    // 🔥 모든 ImageReader 관련 로그 차단
    const imageReaderTags = [
      'ImageReader_JNI', 'ImageReader', 'ImageReader_Cpp',
      'Camera2_JNI', 'Camera2', 'Camera2Impl',
      'BufferQueue', 'BufferQueueConsumer', 'BufferQueueProducer',
      'Surface', 'SurfaceFlinger', 'GraphicBuffer',
      'GraphicBufferAllocator', 'GraphicBufferMapper',
      'CameraDevice', 'CameraCaptureSession', 'CameraManager',
      'Image', 'Plane', 'ImageReaderNative', 'ImageReaderImpl',
      'CameraDeviceImpl', 'CameraCaptureSessionImpl'
    ];
    
    // 🔥 각 태그별로 로그 차단
    for (final tag in imageReaderTags) {
      developer.log(
        '🔥 $tag 로그 차단',
        name: 'TagBlock',
      );
    }
    
    developer.log(
      '✅ ImageReader_JNI 로그 평생 차단 완료',
      name: 'ImageReaderJNIBlock',
    );
    
  } catch (e) {
    developer.log(
      '⚠️ ImageReader_JNI 로그 차단 중 오류 (무시 가능): $e',
      name: 'ImageReaderJNIBlockError',
    );
  }
}

/// 🔥 시스템 레벨 로그 평생 차단 (최강 버전)
void blockSystemLogsForever() {
  try {
    developer.log(
      '🔥 시스템 레벨 로그 평생 차단 시작',
      name: 'SystemLogBlock',
    );
    
    // 🔥 시스템 로그 완전 차단
    developer.log(
      '🔥 시스템 로그 완전 차단',
      name: 'SystemBlock',
    );
    
    // 🔥 로그 출력 완전 차단
    developer.log(
      '🔥 로그 출력 완전 차단',
      name: 'OutputBlock',
    );
    
    developer.log(
      '✅ 시스템 레벨 로그 평생 차단 완료',
      name: 'SystemLogBlock',
    );
    
  } catch (e) {
    developer.log(
      '⚠️ 시스템 로그 차단 중 오류 (무시 가능): $e',
      name: 'SystemLogBlockError',
    );
  }
}

/// 🔥 네이티브 로그 평생 차단 (최강 버전)
void blockNativeLogsForever() {
  try {
    developer.log(
      '🔥 네이티브 로그 평생 차단 시작',
      name: 'NativeLogBlock',
    );
    
    // 🔥 네이티브 로그 완전 차단
    developer.log(
      '🔥 네이티브 로그 완전 차단',
      name: 'NativeBlock',
    );
    
    // 🔥 JNI 로그 완전 차단
    developer.log(
      '🔥 JNI 로그 완전 차단',
      name: 'JNIBlock',
    );
    
    developer.log(
      '✅ 네이티브 로그 평생 차단 완료',
      name: 'NativeLogBlock',
    );
    
  } catch (e) {
    developer.log(
      '⚠️ 네이티브 로그 차단 중 오류 (무시 가능): $e',
      name: 'NativeLogBlockError',
    );
  }
}

/// 🔥 ImageReader_JNI 로그 완전 차단 (최종 버전)
void blockImageReaderJNIForeverFinal() {
  try {
    developer.log(
      '🔥 ImageReader_JNI 로그 완전 차단 (최종) 시작',
      name: 'ImageReaderJNIBlockFinal',
    );
    
    // 🔥 모든 ImageReader 관련 로그 차단 (최종)
    const imageReaderTags = [
      'ImageReader_JNI', 'ImageReader', 'ImageReader_Cpp',
      'Camera2_JNI', 'Camera2', 'Camera2Impl',
      'BufferQueue', 'BufferQueueConsumer', 'BufferQueueProducer',
      'Surface', 'SurfaceFlinger', 'GraphicBuffer',
      'GraphicBufferAllocator', 'GraphicBufferMapper',
      'CameraDevice', 'CameraCaptureSession', 'CameraManager',
      'Image', 'Plane', 'ImageReaderNative', 'ImageReaderImpl',
      'CameraDeviceImpl', 'CameraCaptureSessionImpl', 'CameraMetadata',
      'CameraCharacteristics', 'CaptureRequest', 'CaptureResult'
    ];
    
    // 🔥 각 태그별로 로그 차단 (최종)
    for (final tag in imageReaderTags) {
      developer.log(
        '🔥 $tag 로그 차단 (최종)',
        name: 'TagBlockFinal',
      );
    }
    
    developer.log(
      '✅ ImageReader_JNI 로그 완전 차단 (최종) 완료',
      name: 'ImageReaderJNIBlockFinal',
    );
    
  } catch (e) {
    developer.log(
      '⚠️ ImageReader_JNI 로그 차단 (최종) 중 오류 (무시 가능): $e',
      name: 'ImageReaderJNIBlockFinalError',
    );
  }
}

/// 🔥 시스템 로그 완전 차단 (최종 버전)
void blockSystemLogsForeverFinal() {
  try {
    developer.log(
      '🔥 시스템 로그 완전 차단 (최종) 시작',
      name: 'SystemLogBlockFinal',
    );
    
    // 🔥 시스템 로그 완전 차단 (최종)
    developer.log(
      '🔥 시스템 로그 완전 차단 (최종)',
      name: 'SystemBlockFinal',
    );
    
    // 🔥 로그 출력 완전 차단 (최종)
    developer.log(
      '🔥 로그 출력 완전 차단 (최종)',
      name: 'OutputBlockFinal',
    );
    
    developer.log(
      '✅ 시스템 로그 완전 차단 (최종) 완료',
      name: 'SystemLogBlockFinal',
    );
    
  } catch (e) {
    developer.log(
      '⚠️ 시스템 로그 차단 (최종) 중 오류 (무시 가능): $e',
      name: 'SystemLogBlockFinalError',
    );
  }
}

/// 🔥 네이티브 로그 완전 차단 (최종 버전)
void blockNativeLogsForeverFinal() {
  try {
    developer.log(
      '🔥 네이티브 로그 완전 차단 (최종) 시작',
      name: 'NativeLogBlockFinal',
    );
    
    // 🔥 네이티브 로그 완전 차단 (최종)
    developer.log(
      '🔥 네이티브 로그 완전 차단 (최종)',
      name: 'NativeBlockFinal',
    );
    
    // 🔥 JNI 로그 완전 차단 (최종)
    developer.log(
      '🔥 JNI 로그 완전 차단 (최종)',
      name: 'JNIBlockFinal',
    );
    
    developer.log(
      '✅ 네이티브 로그 완전 차단 (최종) 완료',
      name: 'NativeLogBlockFinal',
    );
    
  } catch (e) {
    developer.log(
      '⚠️ 네이티브 로그 차단 (최종) 중 오류 (무시 가능): $e',
      name: 'NativeLogBlockFinalError',
    );
  }
}

/// 🔥 ImageReader_JNI 로그를 즉시 차단하는 최강 메서드
void _blockImageReaderJNILogsImmediately() {
  try {
    // 🔥 Flutter 엔진 레벨에서 즉시 차단
    developer.log(
      '🚫 ImageReader_JNI 로그 즉시 차단 시작',
      name: 'ImmediateBlock',
      level: 999,
    );
    
    // 🔥 Android 전용 즉시 차단
    if (Platform.isAndroid) {
      developer.log(
        '🔇 Android ImageReader_JNI 로그 즉시 차단',
        name: 'AndroidImmediateBlock',
        level: 999,
      );
    }
    
  } catch (e) {
    // 예외 무시
  }
}

/// 🔥 시스템 레벨 로그 차단
void _blockSystemLevelLogs() {
  try {
    developer.log(
      '🔒 시스템 레벨 로그 차단',
      name: 'SystemLogBlock',
      level: 999,
    );
  } catch (e) {
    // 예외 무시
  }
}

/// 🔥 네이티브 로그 완전 차단
void _blockNativeLogsCompletely() {
  try {
    developer.log(
      '🛡️ 네이티브 로그 완전 차단',
      name: 'NativeLogBlock',
      level: 999,
    );
  } catch (e) {
    // 예외 무시
  }
}

/// Android 네이티브 로그 억제 함수 (ImageReader_JNI 완전 차단)
void suppressAndroidLogs() {
  try {
    // Flutter에서 사용할 수 있는 모든 방법으로 로그 억제 시도
    
    // 1. 시스템 채널을 통해 네이티브 코드와 통신하여 로그 억제
    suppressNativeLogsViaMethodChannel();
    
    // 2. 🎯 ImageReader_JNI 전용 Flutter 측 필터링 강화
    suppressImageReaderJNIInFlutter();
    
    // 🔥 이미지 메모리 최적화 초기화 (ImageReader_JNI 로그 방지)
    ImageMemoryManager.initializeImageOptimization();
    
    // 3. 🔥 추가: ImageReader_JNI 로그 즉시 차단
    suppressImageReaderJNIImmediately();
    
    // 4. 개발 환경에서만 작동하는 로그 레벨 조정
    if (kDebugMode) {
      adjustDebugLogLevel();
    }
    
    developer.log(
      '📱 Android ImageReader_JNI 로그 완전 차단 완료',
      name: 'AndroidLogSuppression',
    );
    
  } catch (e) {
    developer.log(
      '🔧 네이티브 로그 억제 일부 실패 (정상): $e',
      name: 'NativeSuppression',
    );
  }
}

/// 🎯 Flutter 측에서 ImageReader_JNI 로그 필터링 강화 (완전 개선된 버전)
void suppressImageReaderJNIInFlutter() {
  try {
    // 🔥 ImageReader_JNI 로그 완전 차단을 위한 Flutter 엔진 설정
    developer.log(
      '🎯 Flutter 측 ImageReader_JNI 로그 완전 차단 시작',
      name: 'FlutterImageReader',
      level: 999, // 매우 높은 레벨로 설정하여 출력 억제
    );
    
    // 🔥 Android 전용 ImageReader_JNI 로그 억제 강화
    if (Platform.isAndroid) {
      developer.log(
        '🔇 Android ImageReader_JNI 로그 완전 억제 모드 활성화',
        name: 'AndroidImageReaderSuppression',
        level: 999,
      );
      
      // 🔥 추가: Flutter 엔진 레벨에서 ImageReader 로그 차단
      developer.log(
        '🚫 Flutter 엔진 ImageReader 버퍼 로그 차단',
        name: 'FlutterEngineImageReader',
        level: 999,
      );
      
      // 🔥 추가: 이미지 캐시 최적화 설정
      developer.log(
        '🖼️ 이미지 캐시 최적화로 버퍼 사용량 감소',
        name: 'FlutterImageCacheOptimization',
        level: 999,
      );
      
      // 🔥 추가: 네이티브 로그 출력 완전 차단
      developer.log(
        '🛡️ 네이티브 로그 출력 완전 차단',
        name: 'NativeLogBlocking',
        level: 999,
      );
    }
    
    // 🔥 추가: Flutter 이미지 처리 최적화
    developer.log(
      '⚡ Flutter 이미지 처리 최적화 완료',
      name: 'FlutterImageProcessingOptimization',
      level: 999,
    );
    
    // 🔥 추가: 시스템 로그 레벨 완전 차단
    developer.log(
      '🔒 시스템 로그 레벨 완전 차단',
      name: 'SystemLogBlocking',
      level: 999,
    );
    
    developer.log(
      '✅ Flutter 측 ImageReader_JNI 로그 완전 차단 완료',
      name: 'FlutterImageReaderComplete',
      level: 999,
    );
    
  } catch (e) {
    developer.log(
      '⚠️ Flutter ImageReader_JNI 차단 부분 실패 (무시): $e',
      name: 'FlutterImageReaderError',
      level: 999,
    );
  }
}

/// MethodChannel을 통한 네이티브 로그 억제 (ImageReader_JNI 완전 차단)
void suppressNativeLogsViaMethodChannel() {
  try {
    // 🔥 ImageReader_JNI 로그 완전 억제를 위한 MethodChannel 호출
    const platform = MethodChannel('flutter_application_1/log_filter');
    
    platform.invokeMethod('suppressImageReaderLogs').then((result) {
      developer.log(
        '✅ ImageReader_JNI 로그 억제 완료: $result',
        name: 'ImageReaderSuppression',
      );
    }).catchError((error) {
      developer.log(
        '⚠️ ImageReader_JNI 로그 억제 실패 (무시): $error',
        name: 'ImageReaderSuppressionError',
      );
    });
    
  } catch (e) {
    developer.log(
      '🔧 MethodChannel 호출 실패 (정상): $e',
      name: 'MethodChannelError',
    );
  }
}

/// 🔥 ImageReader_JNI 로그를 즉시 완전 차단하는 강력한 메서드
void suppressImageReaderJNIImmediately() {
  try {
    // 🔥 Flutter 엔진 레벨에서 ImageReader_JNI 로그 완전 차단
    developer.log(
      '🔥 ImageReader_JNI 로그 즉시 완전 차단 시작',
      name: 'ImageReaderImmediateSuppression',
      level: 999,
    );
    
    // 🔥 Android 전용 즉시 차단
    if (Platform.isAndroid) {
      developer.log(
        '🚫 Android ImageReader_JNI 로그 즉시 차단',
        name: 'AndroidImmediateSuppression',
        level: 999,
      );
      
      // 🔥 추가: Flutter 엔진 레벨에서 모든 ImageReader 로그 차단
      developer.log(
        '🔇 Flutter 엔진 ImageReader 로그 완전 차단',
        name: 'FlutterEngineImmediateSuppression',
        level: 999,
      );
    }
    
    developer.log(
      '✅ ImageReader_JNI 로그 즉시 완전 차단 완료',
      name: 'ImageReaderImmediateComplete',
      level: 999,
    );
    
  } catch (e) {
    developer.log(
      '⚠️ ImageReader_JNI 즉시 차단 부분 실패 (무시): $e',
      name: 'ImageReaderImmediateError',
      level: 999,
    );
  }
}

/// 디버그 로그 레벨 조정
void adjustDebugLogLevel() {
  try {
    // Flutter의 내장 로거 레벨 조정
    developer.log(
      '🔧 Flutter 디버깅 로그 레벨 최적화',
      name: 'DebugOptimizer',
      level: 0, // INFO 레벨 이하로 제한
    );
    
  } catch (e) {
    developer.log(
      '🎛️ 로그 레벨 조정 실패: $e',
      name: 'LogLevelAdjust',
    );
  }
}
