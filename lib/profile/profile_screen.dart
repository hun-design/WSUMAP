// lib/profile/profile_screen.dart - 완전 수정된 버전
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/auth/user_auth.dart';
import 'package:flutter_application_1/selection/auth_selection_view.dart';
import 'package:flutter_application_1/welcome_view.dart';
import '../generated/app_localizations.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/websocket_service.dart'; // 🔥 WebSocket 추가
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/providers/app_language_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'help_page.dart';
import 'app_info_page.dart';
import 'profile_edit_page.dart';
import 'profile_action_page.dart'; // 🔥 ProfileActionPage 추가
import 'inquiry_page.dart'; // 🔥 InquiryPage 추가

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // 🔥 시간표 스타일 헤더 추가
              _buildHeader(l10n),

              // 기존 컨텐츠
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Consumer<UserAuth>(
                    builder: (context, userAuth, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUserInfoCard(context, userAuth, l10n),
                          const SizedBox(height: 24),
                          if (userAuth.isLoggedIn && !userAuth.isGuest) ...[
                            _buildMenuList(userAuth, l10n),
                          ] else if (userAuth.isGuest) ...[
                            _buildGuestSection(l10n),
                          ] else ...[
                            _buildGuestSection(l10n),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 왼쪽: 제목과 부제목
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.my_page,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                Text(
                  l10n.my_page_subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // 오른쪽: 언어 변경 버튼
          _buildLanguageButton(),
        ],
      ),
    );
  }

  /// 언어 변경 버튼 위젯
  Widget _buildLanguageButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1E3A8A).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showLanguageSelectionDialog,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.language,
                  size: 20,
                  color: Color(0xFF1E3A8A),
                ),
                const SizedBox(width: 8),
                Text(
                  _getCurrentLanguageText(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: Color(0xFF1E3A8A),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
  void _showLanguageSelectionDialog() {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.8; // 화면 높이의 80%로 제한
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                      _buildLanguageOption('한국어', 'ko', Icons.flag_rounded),
                      const SizedBox(height: 10),
                      _buildLanguageOption('English', 'en', Icons.flag_rounded),
                      const SizedBox(height: 10),
                      _buildLanguageOption('中文', 'zh', Icons.flag_rounded),
                      const SizedBox(height: 10),
                      _buildLanguageOption('Español', 'es', Icons.flag_rounded),
                      const SizedBox(height: 10),
                      _buildLanguageOption('日本語', 'ja', Icons.flag_rounded),
                      const SizedBox(height: 10),
                      _buildLanguageOption('Русский', 'ru', Icons.flag_rounded),
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
                    onPressed: () => Navigator.pop(context),
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
      ),
    );
  }

  /// 언어 옵션 위젯
  Widget _buildLanguageOption(String name, String languageCode, IconData icon) {
    final currentLocale = Localizations.localeOf(context);
    final isSelected = currentLocale.languageCode == languageCode;

    return InkWell(
      onTap: () {
        _changeLanguage(languageCode);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
                icon,
                color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF64748B),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
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

  /// 언어 변경 처리
  void _changeLanguage(String languageCode) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<AppLanguageProvider>(context, listen: false);
    languageProvider.setLocale(Locale(languageCode));
    
    // 디버그 로그 추가
    debugPrint('🔤 언어 변경 시도: $languageCode');
    debugPrint('🔤 Provider 로케일: ${languageProvider.locale}');
    
    // 언어 변경 후 강제 리빌드 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      languageProvider.forceRebuild();
      
      final currentLocale = Localizations.localeOf(context);
      debugPrint('🔤 언어 변경 후 현재 로케일: ${currentLocale.languageCode}');
      debugPrint('🔤 Provider 로케일 재확인: ${languageProvider.locale.languageCode}');
    });
    
    // 언어 변경 성공 메시지
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.success}: ${_getLanguageName(languageCode)}'),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 언어 코드에 따른 언어 이름 반환
  String _getLanguageName(String languageCode) {
    switch (languageCode) {
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

  Widget _buildUserInfoCard(
    BuildContext context,
    UserAuth userAuth,
    AppLocalizations l10n,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: userAuth.isLoggedIn && !userAuth.isGuest
          ? () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileActionPage(
                  userAuth: userAuth,
                  onLogout: () => _handleLogout(userAuth),
                  onDelete: () => _handleMenuTap(l10n.delete_account),
                  onEdit: () => _handleMenuTap(l10n.edit_profile),
                ),
              ),
            )
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A8A),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                userAuth.currentUserIcon,
                size: 32,
                color: const Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userAuth.isLoggedIn
                        ? userAuth.getCurrentUserDisplayName(context)
                        : l10n.guest_user,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      userAuth.isLoggedIn && !userAuth.isGuest
                          ? userAuth.userId ?? l10n.user
                          : (userAuth.userRole?.displayName(context) ??
                                l10n.guest_role),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (userAuth.isLoggedIn)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuList(UserAuth userAuth, AppLocalizations l10n) {
    final menuItems = [
      {
        'icon': Icons.help_outline,
        'title': l10n.help,
        'subtitle': l10n.help_subtitle,
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': Icons.info_outline,
        'title': l10n.app_info,
        'subtitle': l10n.app_info_subtitle,
        'color': const Color(0xFF10B981),
      },
      // 🔥 게스트가 아닌 경우에만 문의하기 표시
      if (!userAuth.isGuest)
        {
          'icon': Icons.contact_support,
          'title': l10n.inquiry,
          'subtitle': l10n.inquiry_content_hint,
          'color': const Color(0xFFF59E0B),
        },
      // 🔥 개인정보 처리 방침 버튼 추가
      {
        'icon': Icons.privacy_tip_outlined,
        'title': l10n.privacy_policy,
        'subtitle': l10n.privacy_policy_subtitle,
        'color': const Color(0xFF8B5CF6),
      },
    ];

    return Column(
      children: [
        ...menuItems.map(
          (item) => _buildMenuItem(
            icon: item['icon'] as IconData,
            title: item['title'] as String,
            subtitle: item['subtitle'] as String,
            color: item['color'] as Color,
            isDestructive: item['isDestructive'] as bool? ?? false,
            onTap: () => _handleMenuTap(item['title'] as String),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestSection(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey.shade50, Colors.grey.shade100],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF1E3A8A).withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF1E3A8A).withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person_add,
                  size: 40,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.login_required,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E3A8A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.login_message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              _buildLoginButton(l10n),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildMenuItem(
          icon: Icons.help_outline,
          title: l10n.help,
          subtitle: l10n.help_subtitle,
          color: const Color(0xFF3B82F6),
          onTap: () => _handleMenuTap(l10n.help),
        ),
        _buildMenuItem(
          icon: Icons.info_outline,
          title: l10n.app_info,
          subtitle: l10n.app_info_subtitle,
          color: const Color(0xFF10B981),
          onTap: () => _handleMenuTap(l10n.app_info),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    final iconColor = color ?? const Color(0xFF1E3A8A);
    final backgroundColor =
        color?.withOpacity(0.1) ?? const Color(0xFF1E3A8A).withOpacity(0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDestructive
                    ? Colors.red.withOpacity(0.2)
                    : const Color(0xFFE2E8F0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? Colors.red.withOpacity(0.1)
                        : backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDestructive
                          ? Colors.red.withOpacity(0.2)
                          : iconColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: isDestructive ? Colors.red[600] : iconColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDestructive
                              ? Colors.red[600]
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _navigateToAuth,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.login, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.login_signup,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 웹소켓 해제 로직이 추가된 로그아웃 처리
  void _handleLogout(UserAuth userAuth) async {
    final l10n = AppLocalizations.of(context)!;

    if (userAuth.isGuest) {
      _navigateToAuth();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔥 헤더
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Color(0xFF1E3A8A),
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.logout_confirm,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.logout_subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF1E3A8A).withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 🔥 내용
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF1E3A8A),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.logout_message,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 🔥 버튼 영역
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l10n.cancel,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            l10n.logout,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      debugPrint('🔥 ProfileScreen: 로그아웃 시작');

      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFF1E3A8A)),
                const SizedBox(height: 16),
                Text(
                  l10n.logout_processing,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      try {
        // 🔥 1. 먼저 웹소켓 연결을 명시적으로 해제하여 친구들에게 로그아웃 알림 전송
        debugPrint('🔥 ProfileScreen: 웹소켓 연결 해제 중...');
        final wsService = WebSocketService();
        await wsService.logoutAndDisconnect();
        debugPrint('✅ ProfileScreen: 웹소켓 연결 해제 완료');

        // 🔥 2. 잠시 대기하여 서버가 친구들에게 로그아웃 메시지를 전송할 시간 확보
        await Future.delayed(const Duration(milliseconds: 500));

        // 3. 로그아웃 처리
        final success = await userAuth.logout();

        // 로딩 다이얼로그 닫기
        if (mounted) Navigator.pop(context);

        if (success && mounted) {
          debugPrint('🔥 ProfileScreen: 로그아웃 성공 - 완전한 앱 재시작');

          // 4. 앱을 완전히 재시작하여 모든 상태 초기화
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);

          // 5. 성공 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.logout_success,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        debugPrint('❌ 로그아웃 처리 중 오류: $e');

        // 로딩 다이얼로그 닫기
        if (mounted) Navigator.pop(context);

        // �� 오류 발생 시에도 웹소켓 해제 시도
        try {
          final wsService = WebSocketService();
          await wsService.disconnect();
          debugPrint('✅ 오류 상황에서도 웹소켓 연결 해제 완료');
        } catch (wsError) {
          debugPrint('❌ 웹소켓 해제 중 오류: $wsError');
        }

        // 강제로 초기 화면으로 이동
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }

        // 오류 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.logout_error_message,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handleMenuTap(String title) {
    final l10n = AppLocalizations.of(context)!;
    final userAuth = Provider.of<UserAuth>(context, listen: false);

    if (title == l10n.help) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HelpPage()),
      );
    } else if (title == l10n.app_info) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AppInfoPage()),
      );
    } else if (title == l10n.edit_profile) {
      _showPasswordConfirmDialog();
    } else if (title == l10n.delete_account) {
      _showDeleteDialog();
    } else if (title == l10n.inquiry) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => InquiryPage(userAuth: userAuth)),
      );
    } else if (title == l10n.privacy_policy) {
      _openPrivacyPolicy();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.construction, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$title ${l10n.feature_in_progress}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E3A8A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// ================================
  /// 비밀번호 확인 다이얼로그
  /// ================================
  void _showPasswordConfirmDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final userAuth = Provider.of<UserAuth>(context, listen: false);
    final passwordController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔥 헤더
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.password_confirm_title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.password_confirm_subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 🔥 내용
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: l10n.password,
                          labelStyle: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Color(0xFF1E3A8A),
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 🔥 버튼들
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(color: Color(0xFF1E3A8A)),
                            ),
                            child: Text(
                              l10n.cancel,
                              style: const TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final password = passwordController.text.trim();
                              if (password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.password_required),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              // 비밀번호 확인 로직
                              final isValid = await _verifyPassword(password);
                              if (isValid) {
                                Navigator.pop(context, true);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.password_mismatch_confirm),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              l10n.password_confirm_button,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      // 비밀번호 확인 성공 시 회원정보 수정 페이지로 이동
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileEditPage()),
      );
    }
  }

  /// 비밀번호 확인
  Future<bool> _verifyPassword(String password) async {
    final userAuth = Provider.of<UserAuth>(context, listen: false);
    // SharedPreferences에서 저장된 비밀번호와 비교
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('user_password');

    debugPrint('🔐 비밀번호 확인 시작');
    debugPrint('🔐 입력된 비밀번호: $password');
    debugPrint('🔐 저장된 비밀번호: $savedPassword');
    debugPrint('🔐 사용자 ID: ${userAuth.userId}');
    debugPrint('🔐 사용자 이름: ${userAuth.userName}');
    debugPrint('🔐 로그인 상태: ${userAuth.isLoggedIn}');
    debugPrint('🔐 일치 여부: ${savedPassword == password}');

    // 저장된 비밀번호가 없으면 서버에서 확인
    if (savedPassword == null || savedPassword.isEmpty) {
      debugPrint('🔐 저장된 비밀번호가 없음, 서버 확인 시도');
      // 서버에서 비밀번호 확인 (선택적)
      return await _verifyPasswordFromServer(password);
    }

    return savedPassword == password;
  }

  /// 서버에서 비밀번호 확인 (선택적)
  Future<bool> _verifyPasswordFromServer(String password) async {
    try {
      final userAuth = Provider.of<UserAuth>(context, listen: false);
      final userId = userAuth.userId;

      if (userId == null) {
        debugPrint('🔐 사용자 ID가 없음');
        return false;
      }

      debugPrint('🔐 서버에서 비밀번호 확인 시도: $userId');

      // 서버에서 비밀번호 확인 API 호출 (선택적)
      // 현재는 false 반환 (서버 API가 구현되지 않은 경우)
      return false;
    } catch (e) {
      debugPrint('🔐 서버 비밀번호 확인 실패: $e');
      return false;
    }
  }

  /// ================================
  /// 회원탈퇴 다이얼로그 및 실제 탈퇴 기능
  /// ================================
  void _showDeleteDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final userAuth = Provider.of<UserAuth>(context, listen: false);

    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔥 헤더 - 경고 스타일
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_outlined,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.delete_account_confirm,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.account_delete_subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 🔥 내용
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.data_to_be_deleted,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.delete_account_message,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 🔥 버튼 영역
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l10n.cancel,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            l10n.yes,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // 실제 회원탈퇴 처리
    if (result == true) {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFF1E3A8A)),
                const SizedBox(height: 16),
                Text(
                  l10n.deleting_account,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // 1. 서버에 회원탈퇴 요청
      final apiResult = await AuthService.deleteUser(id: userAuth.userId ?? '');

      // 로딩 다이얼로그 닫기
      if (mounted) Navigator.pop(context);

      if (apiResult.isSuccess) {
        // 2. 로컬 사용자 정보 초기화
        await userAuth.deleteAccount(context: context);

        // 3. 탈퇴 성공 안내 및 로그인/웰컴 화면 이동
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthSelectionView()),
            (route) => false,
          );

          // 성공 스낵바
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.delete_account_success,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // 4. 탈퇴 실패 안내
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      apiResult.message,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  /// ================================
  /// 메인화면(WelcomeView)으로 이동
  /// ================================
  void _navigateToAuth() {
    debugPrint('🔥 ProfileScreen: WelcomeView로 이동');

    // 🔥 게스트 모드에서 WelcomeView로 이동할 때 isFirstLaunch를 true로 설정
    final userAuth = Provider.of<UserAuth>(context, listen: false);
    userAuth.resetToWelcome();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeView()),
      (route) => false,
    );
  }

  /// ================================
  /// 개인정보 처리 방침 열기
  /// ================================
  Future<void> _openPrivacyPolicy() async {
    // 현재 언어 설정에 따라 다른 링크로 이동
    final currentLocale = Localizations.localeOf(context);
    final languageCode = currentLocale.languageCode;
    
    String privacyPolicyUrl;
    String languageName;
    
    switch (languageCode) {
      case 'ko':
        privacyPolicyUrl = 'https://www.notion.so/24c8988c2e2f80bd9c42c99bbbeb034b?source=copy_link';
        languageName = '한국어';
        break;
      case 'en':
        privacyPolicyUrl = 'https://www.notion.so/Privacy-Policy-ENG-24e8988c2e2f80bb9349cc2bdbc740fc?source=copy_link';
        languageName = '영어';
        break;
      case 'ja':
        privacyPolicyUrl = 'https://www.notion.so/JPN-24e8988c2e2f80fcad4fc246c3911127?source=copy_link';
        languageName = '일본어';
        break;
      case 'zh':
        privacyPolicyUrl = 'https://www.notion.so/CHN-24e8988c2e2f808fbda0e94c4d92212d?source=copy_link';
        languageName = '중국어';
        break;
      case 'ru':
        privacyPolicyUrl = 'https://www.notion.so/RUS-24e8988c2e2f80d88872cafc31bfd06c?source=copy_link';
        languageName = '러시아어';
        break;
      case 'es':
        privacyPolicyUrl = 'https://www.notion.so/Pol-tica-de-Privacidad-ES-24e8988c2e2f80e1abcce5dbfac4fcd9?source=copy_link';
        languageName = '스페인어';
        break;
      default:
        // 기본값은 영어
        privacyPolicyUrl = 'https://www.notion.so/Privacy-Policy-ENG-24e8988c2e2f80bb9349cc2bdbc740fc?source=copy_link';
        languageName = '영어';
        break;
    }
    
    final url = Uri.parse(privacyPolicyUrl);
    
    try {
      // 개인정보 처리 방침 페이지를 브라우저에서 열기
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication, // 외부 브라우저에서 열기
        );
      } else {
        // 링크를 열 수 없는 경우 클립보드에 복사
        await Clipboard.setData(ClipboardData(text: url.toString()));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$languageName 개인정보 처리 방침 링크가 클립보드에 복사되었습니다.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      // 오류 발생 시 클립보드에 복사
      await Clipboard.setData(ClipboardData(text: url.toString()));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$languageName 개인정보 처리 방침 링크 열기 실패. 링크가 클립보드에 복사되었습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
