// lib/login/login_form_view.dart - 다국어 지원이 추가된 로그인 폼

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/user_auth.dart';
import '../components/woosong_input_field.dart';
import '../components/woosong_button.dart';
import '../generated/app_localizations.dart';
import '../screens/map_loading_screen.dart';

class LoginFormView extends StatefulWidget {
  const LoginFormView({super.key});

  @override
  State<LoginFormView> createState() => _LoginFormViewState();
}

class _LoginFormViewState extends State<LoginFormView> with TickerProviderStateMixin {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _rememberMe = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// 🔥 로그인 처리 (서버 DB 검증 강화 및 즉시 실패 처리)
  void _handleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    final id = usernameController.text.trim();
    final password = passwordController.text.trim();

    // 입력 검증
    if (id.isEmpty || password.isEmpty) {
      _showErrorDialog(l10n.username_password_required);
      return;
    }

    // 🔥 키보드 즉시 숨김 처리 (오버플로우 방지)
    FocusScope.of(context).unfocus();
    
    // 🔥 키보드가 완전히 숨겨진 후 화면 전환 (부드러운 전환)
    await Future.delayed(const Duration(milliseconds: 100));

    // 🔥 로그인 처리 전에 로딩 상태 표시
    final userAuth = Provider.of<UserAuth>(context, listen: false);
    
    // 🔥 로그인 버튼을 누르는 순간 즉시 로딩 화면으로 이동
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MapLoadingScreen()),
      (route) => false,
    );

    // 🔥 로딩 화면에서 실제 로그인 처리 (서버 DB 검증 강화)
    final success = await userAuth.loginWithCredentials(
      id: id,
      password: password,
      rememberMe: _rememberMe,
      context: context,
    );

    // 🔥 로그인 실패 시 즉시 로그인 화면으로 돌아가기 (MapScreen 진입 방지)
    if (!success && mounted) {
      debugPrint('🔥 로그인 실패 - 즉시 로그인 화면으로 돌아가기');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginFormView()),
        (route) => false,
      );
      // 🔥 에러 다이얼로그는 MapLoadingScreen에서 처리됨
    }
  }

  /// 게스트 로그인 처리
  void _handleGuestLogin() async {
    final l10n = AppLocalizations.of(context)!;
    
    // 게스트 로그인 확인 다이얼로그 표시
    final confirmed = await showDialog<bool>(
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
                Icons.person_outline,
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
                    onPressed: () => Navigator.of(context).pop(false),
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
                    onPressed: () => Navigator.of(context).pop(true),
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

    if (confirmed == true && mounted) {
      // 🔥 키보드 즉시 숨김 처리 (오버플로우 방지)
      FocusScope.of(context).unfocus();
      
      // 🔥 키보드가 완전히 숨겨진 후 화면 전환 (부드러운 전환)
      await Future.delayed(const Duration(milliseconds: 100));

      // 게스트 로그인 확인 즉시 로딩 화면으로 이동
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MapLoadingScreen()),
        (route) => false,
      );

      // 로딩 화면에서 실제 게스트 로그인 처리
      final userAuth = Provider.of<UserAuth>(context, listen: false);
      await userAuth.loginAsGuest(context: context);
    }
  }

  /// 에러 다이얼로그 표시 (우송 네이비 테마)
  void _showErrorDialog(String message) {
    final l10n = AppLocalizations.of(context)!;
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
                color: Color(0xFF1E3A8A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.error_outline,
                color: Color(0xFF1E3A8A),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.login_failed,
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
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE2E8F0),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                // 🔥 키보드 오버플로우 방지를 위한 추가 설정
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 뒤로가기 버튼
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF1E3A8A),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 헤더
                    Center(
                      child: Text(
                        l10n.login,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 서브타이틀 (가운데 정렬)
                    Center(
                      child: Text(
                        l10n.start_campus_exploration,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 로그인 폼 카드
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Consumer<UserAuth>(
                          builder: (context, userAuth, child) {
                            return Column(
                              children: [
                                // 로고
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E3A8A).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.school,
                                    size: 30,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // 입력 필드들
                                WoosongInputField(
                                  icon: Icons.person_outline,
                                  label: l10n.username,
                                  controller: usernameController,
                                  hint: l10n.enter_username,
                                ),
                                const SizedBox(height: 4),
                                WoosongInputField(
                                  icon: Icons.lock_outline,
                                  label: l10n.password,
                                  controller: passwordController,
                                  isPassword: true,
                                  hint: l10n.enter_password,
                                ),
                                const SizedBox(height: 16),

                                // 기억하기 체크박스
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: _rememberMe,
                                        onChanged: userAuth.isLoading ? null : (value) {
                                          setState(() {
                                            _rememberMe = value ?? false;
                                          });
                                        },
                                        activeColor: const Color(0xFF1E3A8A),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: userAuth.isLoading ? null : () {
                                            setState(() {
                                              _rememberMe = !_rememberMe;
                                            });
                                          },
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                l10n.remember_me,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              Text(
                                                l10n.remember_me_description,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (_rememberMe)
                                        const Icon(
                                          Icons.verified,
                                          size: 16,
                                          color: Color(0xFF1E3A8A),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // 로그인 버튼
                                WoosongButton(
                                  onPressed: userAuth.isLoading ? null : _handleLogin,
                                  child: userAuth.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(l10n.login),
                                ),
                                const SizedBox(height: 12),

                                // 게스트 로그인 버튼
                                WoosongButton(
                                  onPressed: userAuth.isLoading ? null : _handleGuestLogin,
                                  isPrimary: false,
                                  isOutlined: true,
                                  child: Text(l10n.login_as_guest),
                                ),
                                const SizedBox(height: 16),

                                // 추가 옵션들
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: TextButton(
                                        onPressed: userAuth.isLoading ? null : () {
                                          _showComingSoonDialog(context, l10n.find_password);
                                        },
                                        child: Text(
                                          l10n.find_password,
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 12,
                                      color: const Color(0xFFE2E8F0),
                                      margin: const EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                    Flexible(
                                      child: TextButton(
                                        onPressed: userAuth.isLoading ? null : () {
                                          _showComingSoonDialog(context, l10n.find_username);
                                        },
                                        child: Text(
                                          l10n.find_username,
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

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
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 뒤로가기 버튼 제거
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 추가 기능 안내 다이얼로그 (우송 네이비 테마)
  void _showComingSoonDialog(BuildContext context, String feature) {
    final l10n = AppLocalizations.of(context)!;
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
                Icons.construction,
                color: Color(0xFF3B82F6),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feature,
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
            l10n.feature_coming_soon(feature),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
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
        ],
      ),
    );
  }
}
