import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generated/app_localizations.dart';
import '../auth/user_auth.dart';
import 'providers/app_language_provider.dart';
import '../managers/location_manager.dart';
import '../selection/auth_selection_view.dart';

enum AppLanguage { korean, english, chinese, spanish, japanese, russian }

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

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

// 말풍선 꼬리 그리기 클래스
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
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;
  late AppLanguage _selectedLanguage;

  // 🔥 위치 준비 관련 변수들 추가
  bool _isPreparingLocation = false;
  bool _locationPrepared = false;

  @override
  void initState() {
    super.initState();
    final locale = Provider.of<AppLanguageProvider>(
      context,
      listen: false,
    ).locale;
    _selectedLanguage = localeToAppLanguage(locale);

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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );
    _floatingAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _floatingController.repeat(reverse: true);

    // 🔥 Welcome 화면 진입 시 백그라운드에서 위치 미리 준비
    _prepareLocationInBackground();

    // 🔥 2초 후 자동으로 AuthSelectionView로 이동
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

  /// 🔥 백그라운드에서 위치 미리 준비 (최적화된 버전)
  Future<void> _prepareLocationInBackground() async {
    if (_isPreparingLocation || _locationPrepared) return;

    try {
      _isPreparingLocation = true;
      debugPrint('🔄 Welcome 화면에서 위치 미리 준비 시작...');

      // 대기 시간 단축 (1.5초에서 0.5초로)
      await Future.delayed(const Duration(milliseconds: 500));
      final locationManager = Provider.of<LocationManager>(context, listen: false);

      // LocationManager 초기화 대기 (최대 1초)
      int retries = 0;
      while (!locationManager.isInitialized && retries < 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        retries++;
      }

      if (locationManager.isInitialized) {
        debugPrint('🔍 Welcome에서 위치 권한 확인 중...');
        await Future.delayed(const Duration(milliseconds: 200)); // 300ms에서 200ms로 단축
        await locationManager.recheckPermissionStatus();

        // 권한 상태 확인 (최대 0.5초 대기)
        int permissionRetries = 0;
        while (locationManager.permissionStatus == null && permissionRetries < 5) {
          await Future.delayed(const Duration(milliseconds: 100));
          permissionRetries++;
        }

        debugPrint('🔍 최종 권한 상태: ${locationManager.permissionStatus}');
        debugPrint('✅ Welcome에서 빠른 위치 요청 시작...');

        try {
          // 🔥 빠른 위치 요청 (1초 타임아웃)
          await locationManager.requestLocationQuickly().timeout(
            const Duration(seconds: 1), // 3초에서 1초로 단축
            onTimeout: () {
              debugPrint('⏰ Welcome 위치 요청 타임아웃 (1초) - 정상 진행');
              throw TimeoutException('Welcome 위치 타임아웃', const Duration(seconds: 1));
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

  /// 🔥 위치 준비 (개선된 버전) - 제거됨
  // Future<void> _prepareLocation() async {
  //   if (_isPreparingLocation) return;
  //   _isPreparingLocation = true;

  //   try {
  //     debugPrint('📍 Welcome 화면에서 위치 준비 시작...');

  //     final locationManager = Provider.of<LocationManager>(context, listen: false);
  //     if (locationManager != null) {
  //       debugPrint('✅ LocationManager 초기화 확인됨');

  //       // 권한 상태 확인 (최대 0.5초 대기)
  //       int permissionRetries = 0;
  //       while (locationManager.permissionStatus == null && permissionRetries < 5) {
  //         await Future.delayed(const Duration(milliseconds: 100));
  //         permissionRetries++;
  //       }

  //       debugPrint('🔍 최종 권한 상태: ${locationManager.permissionStatus}');
  //       debugPrint('✅ Welcome에서 빠른 위치 요청 시작...');

  //       try {
  //         // 🔥 빠른 위치 요청 (1초 타임아웃)
  //         await locationManager.requestLocationQuickly().timeout(
  //           const Duration(seconds: 1), // 1초로 단축
  //           onTimeout: () {
  //             debugPrint('⏰ Welcome 위치 요청 타임아웃 (1초) - 정상 진행');
  //             throw TimeoutException('Welcome 위치 타임아웃', const Duration(seconds: 1));
  //           },
  //         );

  //         if (locationManager.hasValidLocation && mounted) {
  //           debugPrint('✅ Welcome 화면에서 위치 준비 완료!');
  //           debugPrint('   위도: ${locationManager.currentLocation?.latitude}');
  //           debugPrint('   경도: ${locationManager.currentLocation?.longitude}');
  //           setState(() {
  //             _locationPrepared = true;
  //           });
  //         } else {
  //           debugPrint('⚠️ Welcome 화면에서 위치 준비 실패 - Map에서 재시도');
  //         }
  //       } catch (e) {
  //         debugPrint('⚠️ Welcome 위치 요청 실패: $e - Map에서 재시도');
  //       }
  //     } else {
  //       debugPrint('❌ Welcome 화면에서 LocationManager 초기화 실패');
  //     }
  //   } catch (e) {
  //     debugPrint('⚠️ Welcome 화면 위치 준비 오류: $e');
  //   } finally {
  //     _isPreparingLocation = false;
  //   }
  // }

  // 기본 텍스트 반환 함수들 (localization이 없을 때 사용)
  String _getAppTitle() {
    switch (_selectedLanguage) {
      case AppLanguage.korean:
        return '따라우송';
      case AppLanguage.english:
        return '따라우송';
      case AppLanguage.chinese:
        return '따라우송';
      case AppLanguage.spanish:
        return '따라우송';
      case AppLanguage.japanese:
        return '따라우송';
      case AppLanguage.russian:
        return '따라우송';
    }
  }

  String _getSubtitle() {
    switch (_selectedLanguage) {
      case AppLanguage.korean:
        return '우송대학교 캠퍼스를\n쉽고 빠르게 탐색하세요';
      case AppLanguage.english:
        return 'Explore Woosong University campus easily and quickly';
      case AppLanguage.chinese:
        return '轻松快捷地探索又松大学校园';
      case AppLanguage.spanish:
        return 'Explora el campus de la Universidad de Woosong de manera fácil y rápida';
      case AppLanguage.japanese:
        return 'ウソン大学のキャンパスを\n簡単かつ迅速に探索しましょう';
      case AppLanguage.russian:
        return 'Легко и быстро исследуйте кампус Университета Вусонг';
    }
  }

  String _getStartText() {
    switch (_selectedLanguage) {
      case AppLanguage.korean:
        return '시작하기';
      case AppLanguage.english:
        return 'Get Started';
      case AppLanguage.chinese:
        return '开始';
      case AppLanguage.spanish:
        return 'Comenzar';
      case AppLanguage.japanese:
        return '始める';
      case AppLanguage.russian:
        return 'Начать';
    }
  }

  String _getLanguageText() {
    // AppLocalizations를 사용하여 다국어 지원
    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      return l10n.select_language;
    }
    // 폴백: 현재 선택된 언어에 따라 반환
    switch (_selectedLanguage) {
      case AppLanguage.korean:
        return '언어 선택';
      case AppLanguage.english:
        return 'Select Language';
      case AppLanguage.chinese:
        return '选择语言';
      case AppLanguage.spanish:
        return 'Seleccionar Idioma';
      case AppLanguage.japanese:
        return '言語選択';
      case AppLanguage.russian:
        return 'Выбрать язык';
    }
  }

  String _getWoosongText() {
    switch (_selectedLanguage) {
      case AppLanguage.korean:
        return '따라우송';
      case AppLanguage.english:
        return '따라우송';
      case AppLanguage.chinese:
        return '따라우송';
      case AppLanguage.spanish:
        return '따라우송';
      case AppLanguage.japanese:
        return '따라우송';
      case AppLanguage.russian:
        return '따라우송';
    }
  }

  /// 🔥 AuthSelectionView로 자동 이동
  void _navigateToAuthSelection() {
    final userAuth = Provider.of<UserAuth>(context, listen: false);

    // 🔥 게스트 모드에서 WelcomeView로 온 경우 AuthSelectionView로 직접 이동
    if (userAuth.isGuest) {
      debugPrint('🔥 게스트 모드: AuthSelectionView로 직접 이동');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthSelectionView()),
      );
    } else {
      // 🔥 일반 사용자: 첫 실행 완료 표시 - Consumer가 자동으로 AuthSelectionView로 전환
      debugPrint('🔥 일반 사용자: completeFirstLaunch 호출');
      userAuth.completeFirstLaunch();
    }
  }

  void _showLanguageDialog() async {
    final result = await showDialog<AppLanguage>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 상단 아이콘+타이틀
                    Padding(
                      padding: const EdgeInsets.only(top: 32, bottom: 12),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.language,
                            color: Color(0xFF1E3A8A),
                            size: 36,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _getLanguageText(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 언어 선택 버튼들
                    ...AppLanguage.values.map((lang) {
                      final selected = lang == _selectedLanguage;
                      return GestureDetector(
                        onTap: () => Navigator.of(context).pop(lang),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 6,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF1E3A8A).withOpacity(0.08)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF1E3A8A)
                                  : Colors.grey[300]!,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                selected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: selected
                                    ? const Color(0xFF1E3A8A)
                                    : Colors.grey[400],
                              ),
                              const SizedBox(width: 16),
                              Text(
                                languageToString(lang),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: selected
                                      ? const Color(0xFF1E3A8A)
                                      : Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                ),
                // 🔥 오른쪽 상단 X 버튼
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null && result != _selectedLanguage) {
      setState(() {
        _selectedLanguage = result;
      });
      Provider.of<AppLanguageProvider>(
        context,
        listen: false,
      ).setLocale(appLanguageToLocale(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    // AppLocalizations를 안전하게 가져오기 (null일 수 있음)
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
              Color(0xFF1E3A8A), // 우송 네이비 (진한)
              Color(0xFF3B82F6), // 우송 네이비 (중간)
              Color(0xFF60A5FA), // 우송 네이비 (연한)
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n?.welcome_subtitle_2 ?? '건물 정보가 다 여기에!',
                      style: TextStyle(
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
                      Color(0xFF1E3A8A), // 우송 네이비
                      Color(0xFF3B82F6), // 우송 네이비 (밝은)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(70),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF1E3A8A).withValues(alpha: 0.4),
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
                  color: Color(0xFF1E3A8A).withValues(alpha: 0.3),
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
