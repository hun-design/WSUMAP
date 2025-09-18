// lib/selection/auth_selection_view.dart - 다국어 지원이 추가된 인증 선택 화면

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../signup/sign_up_view.dart';
import '../login/login_form_view.dart';
import '../auth/user_auth.dart';
import '../generated/app_localizations.dart';
import '../providers/app_language_provider.dart';
import '../providers/category_provider.dart';
import '../map/map_screen.dart';

class AuthSelectionView extends StatefulWidget {
  const AuthSelectionView({super.key});

  @override
  State<AuthSelectionView> createState() => _AuthSelectionViewState();
}

class _AuthSelectionViewState extends State<AuthSelectionView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _floatingController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;

  // 🔥 카테고리 로드 중복 방지 플래그
  bool _isLoadingCategories = false;
  
  // 🔥 버튼 중복 클릭 방지 플래그
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _floatingAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  /// 현재 언어 텍스트 반환
  String _getCurrentLanguageText() {
    final languageProvider = Provider.of<AppLanguageProvider>(context, listen: true);
    final locale = languageProvider.locale;
    switch (locale.languageCode) {
      case 'ko':
        return '한국어';
      case 'en':
        return 'English';
      case 'zh':
        return '中文';
      case 'es':
        return 'Español';
      case 'ja':
        return '日本語';
      case 'ru':
        return 'Русский';
      default:
        return '한국어';
    }
  }

  /// 언어 선택 다이얼로그 표시
  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.8; // 화면 높이의 80%로 제한
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: maxHeight,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 상단 아이콘 + 타이틀
                Container(
                  padding: const EdgeInsets.only(top: 24, bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.language_rounded,
                          color: Color(0xFF1E3A8A),
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.language_selection,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.language_selection_description,
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF1E3A8A).withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 스크롤 가능한 언어 옵션들
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      children: [
                        _buildLanguageOption('한국어', 'ko'),
                        const SizedBox(height: 10),
                        _buildLanguageOption('English', 'en'),
                        const SizedBox(height: 10),
                        _buildLanguageOption('中文', 'zh'),
                        const SizedBox(height: 10),
                        _buildLanguageOption('Español', 'es'),
                        const SizedBox(height: 10),
                        _buildLanguageOption('日本語', 'ja'),
                        const SizedBox(height: 10),
                        _buildLanguageOption('Русский', 'ru'),
                      ],
                    ),
                  ),
                ),
                
                // 하단 버튼
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
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
  }

  /// 언어 옵션 위젯
  Widget _buildLanguageOption(String text, String languageCode) {
    final currentLocale = Localizations.localeOf(context);
    final isSelected = currentLocale.languageCode == languageCode;
    
    return InkWell(
      onTap: () {
        final languageProvider = Provider.of<AppLanguageProvider>(context, listen: false);
        switch (languageCode) {
          case 'ko':
            languageProvider.setLocale(const Locale('ko'));
            break;
          case 'en':
            languageProvider.setLocale(const Locale('en'));
            break;
          case 'zh':
            languageProvider.setLocale(const Locale('zh'));
            break;
          case 'es':
            languageProvider.setLocale(const Locale('es'));
            break;
          case 'ja':
            languageProvider.setLocale(const Locale('ja'));
            break;
          case 'ru':
            languageProvider.setLocale(const Locale('ru'));
            break;
        }
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF1E3A8A).withValues(alpha: 0.1)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF1E3A8A).withValues(alpha: 0.1)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.flag_rounded,
                color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF64748B),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF334155),
                ),
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E3A8A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }


  /// 게스트 로그인 실제 수행 (다이얼로그 없이)
  Future<void> _performGuestLogin() async {
    final userAuth = Provider.of<UserAuth>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    
    // 🔥 게스트 로그인과 동시에 카테고리 로드
    await Future.wait([
      userAuth.loginAsGuest(context: context),
      categoryProvider.loadCategoriesFromServer(),
    ]);
    
    if (mounted) {
      // 게스트 로그인 후 MapScreen으로 이동
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MapScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // 매우 진한 남색
              Color(0xFF1E3A8A), // 우송대 남색
              Color(0xFF3B82F6), // 밝은 남색
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // 배경 장식 요소들
            _buildFloatingDecorations(),
            
            // 메인 콘텐츠
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height - 
                              MediaQuery.of(context).padding.top - 48,
                      child: Column(
                        children: [
                          // 상단 헤더
                          _buildHeader(l10n),
                          
                          const SizedBox(height: 40),
                          
                          // 메인 콘텐츠 카드
                          Expanded(
                            child: _buildMainCard(l10n),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // 하단 정보
                          _buildFooter(l10n),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingDecorations() {
    return Stack(
      children: [
        // 우상단 장식
        Positioned(
          top: 80,
          right: -80,
          child: AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatingAnimation.value),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              );
            },
          ),
        ),
        
        // 좌하단 장식
        Positioned(
          bottom: 100,
          left: -100,
          child: AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -_floatingAnimation.value * 0.7),
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.03),
                  ),
                ),
              );
            },
          ),
        ),
        
        // 중앙 작은 장식들
        Positioned(
          top: 200,
          left: 50,
          child: AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_floatingAnimation.value * 0.3, 0),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

Widget _buildHeader(AppLocalizations l10n) {
  return Row(
    children: [
      IconButton(
        onPressed: () {
          // UserAuth 상태를 먼저 초기화
          final userAuth = Provider.of<UserAuth>(context, listen: false);
          userAuth.resetToWelcome();
          
          // 약간의 지연 후 네비게이션 (상태 변경이 적용되도록)
          Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const MapScreen(),
            ),
            (route) => false,
          );
          });
        },
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
          size: 24,
        ),
      ),
      Expanded(
        child: Text(
          l10n.select_auth_method,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      // 언어 선택 버튼
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.2),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        icon: const Icon(Icons.language, size: 18),
        label: Text(
          _getCurrentLanguageText(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: _showLanguageDialog,
      ),
    ],
  );
}


  Widget _buildMainCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Consumer<UserAuth>(
        builder: (context, userAuth, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 로고 섹션
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1E3A8A),
                      Color(0xFF3B82F6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 타이틀
              Text(
                l10n.app_name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              
              const SizedBox(height: 4),
              
              // 서브타이틀
              Text(
                l10n.woosong_campus_guide_service,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 인증 옵션들
              _buildAuthOption(
                icon: Icons.person_add,
                title: l10n.register,
                subtitle: l10n.register_description,
                onTap: userAuth.isLoading ? null : () => _navigateToSignUp(),
              ),
              
              const SizedBox(height: 12),
              
              _buildAuthOption(
                icon: Icons.login,
                title: l10n.login,
                subtitle: l10n.login_description,
                onTap: userAuth.isLoading ? null : () => _navigateToLogin(),
              ),
              
              const SizedBox(height: 16),
              
              // 게스트 접속
              SizedBox(
                height: 36,
                child: TextButton(
                  onPressed: userAuth.isLoading ? null : () => _showGuestDialog(l10n),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    l10n.browse_as_guest,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              // 로딩 상태 표시
              if (userAuth.isLoading) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.processing,
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 에러 메시지 표시
              if (userAuth.lastError != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          userAuth.lastError!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildAuthOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: onTap == null ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: onTap == null ? const Color(0xFFE2E8F0) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withOpacity(onTap == null ? 0.5 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: onTap == null 
                    ? const Color(0xFF1E3A8A).withOpacity(0.5)
                    : const Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: onTap == null 
                          ? const Color(0xFF1E3A8A).withOpacity(0.5)
                          : const Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: onTap == null 
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: onTap == null 
                  ? const Color(0xFF64748B).withOpacity(0.5)
                  : const Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(AppLocalizations l10n) {
    return Column(
      children: [
        Text(
          l10n.woosong_university,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          l10n.campus_navigator_version,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  void _navigateToSignUp() async {
    // 🔥 중복 클릭 방지
    if (_isNavigating || _isLoadingCategories) {
      debugPrint('ℹ️ 네비게이션 중 - 회원가입 건너뜀');
      return;
    }
    
    debugPrint('🔄 회원가입 네비게이션 시작');
    _isNavigating = true;
    _isLoadingCategories = true;
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    
    try {
      // 🔥 회원가입 화면으로 이동하면서 카테고리 로드
      debugPrint('🔄 카테고리 로드 시작');
      await categoryProvider.loadCategoriesFromServer();
      debugPrint('✅ 카테고리 로드 완료');
      
      if (mounted) {
        debugPrint('🔄 회원가입 화면으로 이동');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SignUpView(),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ 회원가입 네비게이션 오류: $e');
    } finally {
      _isNavigating = false;
      _isLoadingCategories = false;
      debugPrint('✅ 회원가입 네비게이션 완료');
    }
  }

  void _navigateToLogin() async {
    // 🔥 중복 클릭 방지
    if (_isNavigating || _isLoadingCategories) {
      debugPrint('ℹ️ 네비게이션 중 - 로그인 건너뜀');
      return;
    }
    
    debugPrint('🔄 로그인 네비게이션 시작');
    _isNavigating = true;
    _isLoadingCategories = true;
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    
    try {
      // 🔥 로그인 화면으로 이동하면서 카테고리 로드
      debugPrint('🔄 카테고리 로드 시작');
      await categoryProvider.loadCategoriesFromServer();
      debugPrint('✅ 카테고리 로드 완료');
      
      if (mounted) {
        debugPrint('🔄 로그인 화면으로 이동');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const LoginFormView(),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ 로그인 네비게이션 오류: $e');
    } finally {
      _isNavigating = false;
      _isLoadingCategories = false;
      debugPrint('✅ 로그인 네비게이션 완료');
    }
  }

  void _showGuestDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.info_outline,
                color: Color(0xFF3B82F6),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.guest_mode,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            l10n.guest_mode_confirm,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFF1E3A8A),
                      side: BorderSide(color: Color(0xFF1E3A8A)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _performGuestLogin();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      l10n.confirm,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
