import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'generated/app_localizations.dart';
import 'auth/user_auth.dart';
import 'managers/location_manager.dart';
import 'selection/auth_selection_view.dart';

/// 앱 언어 열거형
enum AppLanguage { korean, english, chinese, spanish, japanese, russian }

/// 언어를 문자열로 변환
String languageToString(AppLanguage lang) {
  switch (lang) {
    case AppLanguage.korean:
      return '한국어';
    case AppLanguage.english:
      return 'English';
    case AppLanguage.chinese:
      return '中文';
    case AppLanguage.spanish:
      return 'Español';
    case AppLanguage.japanese:
      return '日本語';
    case AppLanguage.russian:
      return 'Русский';
  }
}

/// Locale을 AppLanguage로 변환
AppLanguage localeToAppLanguage(Locale locale) {
  switch (locale.languageCode) {
    case 'ko':
      return AppLanguage.korean;
    case 'en':
      return AppLanguage.english;
    case 'zh':
      return AppLanguage.chinese;
    case 'es':
      return AppLanguage.spanish;
    case 'ja':
      return AppLanguage.japanese;
    case 'ru':
      return AppLanguage.russian;
    default:
      return AppLanguage.korean;
  }
}

/// AppLanguage를 Locale로 변환
Locale appLanguageToLocale(AppLanguage lang) {
  switch (lang) {
    case AppLanguage.korean:
      return const Locale('ko');
    case AppLanguage.english:
      return const Locale('en');
    case AppLanguage.chinese:
      return const Locale('zh');
    case AppLanguage.spanish:
      return const Locale('es');
    case AppLanguage.japanese:
      return const Locale('ja');
    case AppLanguage.russian:
      return const Locale('ru');
  }
}

/// 웰컴 화면 위젯
class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

/// 말풍선 꼬리 그리기 클래스
class SpeechBubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WelcomeViewState extends State<WelcomeView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _floatingController;

  /// 위치 준비 관련 변수들
  bool _isPreparingLocation = false;
  bool _locationPrepared = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );


    _fadeController.forward();
    _slideController.forward();
    _floatingController.repeat(reverse: true);

    // Welcome 화면 진입 시 백그라운드에서 위치 미리 준비
    _prepareLocationInBackground();

    // 2초 후 자동으로 AuthSelectionView로 이동
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _navigateToAuthSelection();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  /// 백그라운드에서 위치 미리 준비
  Future<void> _prepareLocationInBackground() async {
    if (_isPreparingLocation || _locationPrepared) return;

    try {
      _isPreparingLocation = true;
      debugPrint('🔄 Welcome 화면에서 위치 미리 준비 시작...');

      // 대기 시간 단축
      await Future.delayed(const Duration(milliseconds: 200));
      final locationManager = Provider.of<LocationManager>(context, listen: false);

      // LocationManager 초기화 대기
      int retries = 0;
      while (!locationManager.isInitialized && retries < 5) {
        await Future.delayed(const Duration(milliseconds: 100));
        retries++;
      }

      if (locationManager.isInitialized) {
        debugPrint('🔍 Welcome에서 위치 권한 확인 중...');
        await Future.delayed(const Duration(milliseconds: 100));
        await locationManager.recheckPermissionStatus();

        // 권한 상태 확인
        int permissionRetries = 0;
        while (locationManager.permissionStatus == null && permissionRetries < 3) {
          await Future.delayed(const Duration(milliseconds: 100));
          permissionRetries++;
        }

        debugPrint('🔍 최종 권한 상태: ${locationManager.permissionStatus}');
        debugPrint('✅ Welcome에서 초고속 위치 요청 시작...');

        try {
          // 초고속 위치 요청
          await locationManager.requestLocationQuickly().timeout(
            const Duration(milliseconds: 500),
            onTimeout: () {
              debugPrint('⏰ Welcome 위치 요청 타임아웃 (0.5초) - 정상 진행');
              throw TimeoutException('Welcome 위치 타임아웃', const Duration(milliseconds: 500));
            },
          );

          if (locationManager.hasValidLocation && mounted) {
            debugPrint('✅ Welcome 화면에서 위치 준비 완료!');
            debugPrint('   위도: ${locationManager.currentLocation?.latitude}');
            debugPrint('   경도: ${locationManager.currentLocation?.longitude}');
            setState(() {
              _locationPrepared = true;
            });
          } else {
            debugPrint('⚠️ Welcome 화면에서 위치 준비 실패 - Map에서 재시도');
          }
        } catch (e) {
          debugPrint('⚠️ Welcome 위치 요청 실패: $e - Map에서 재시도');
        }
      } else {
        debugPrint('❌ Welcome 화면에서 LocationManager 초기화 실패');
      }
    } catch (e) {
      debugPrint('⚠️ Welcome 화면 위치 준비 오류: $e');
    } finally {
      _isPreparingLocation = false;
    }
  }


  /// AuthSelectionView로 자동 이동
  void _navigateToAuthSelection() {
    final userAuth = Provider.of<UserAuth>(context, listen: false);

    // 게스트 모드에서 WelcomeView로 온 경우 AuthSelectionView로 직접 이동
    if (userAuth.isGuest) {
      debugPrint('🔥 게스트 모드: AuthSelectionView로 직접 이동');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthSelectionView()),
      );
    } else {
      // 일반 사용자: 첫 실행 완료 표시
      debugPrint('🔥 일반 사용자: completeFirstLaunch 호출');
      userAuth.completeFirstLaunch();
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
              Color(0xFF60A5FA),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 1),

              // 말풍선 컨테이너
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      l10n?.welcome_subtitle_1 ?? '내 손 안의 따라우송,',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n?.welcome_subtitle_2 ?? '건물 정보가 다 여기에!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ],
                ),
              ),

              // 말풍선 꼬리
              Container(
                margin: const EdgeInsets.only(top: 0),
                child: CustomPaint(
                  size: const Size(24, 24),
                  painter: SpeechBubbleTailPainter(),
                ),
              ),

              const SizedBox(height: 50),

              // 지도 핀 아이콘
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1E3A8A),
                      Color(0xFF3B82F6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(70),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on,
                  size: 70,
                  color: Colors.white,
                ),
              ),

              // 지도 핀 그림자
              Container(
                margin: const EdgeInsets.only(top: 0),
                width: 100,
                height: 25,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              const SizedBox(height: 40),

              // 앱 이름
              Text(
                '따라우송',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // 개발자 정보
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Text(
                  '@YJB',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
