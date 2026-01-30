// lib/signup/sign_up_view.dart - 다국어 지원이 완전히 적용된 버전

import 'package:flutter/material.dart';
import 'package:flutter_application_1/login/login_form_view.dart';
import 'package:provider/provider.dart';
import '../components/woosong_input_field.dart';
import '../auth/user_auth.dart';
import '../generated/app_localizations.dart';

enum UserType { student, professor, external }

extension UserTypeExtension on UserType {
  String displayName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case UserType.student:
        return l10n.student;
      case UserType.professor:
        return l10n.professor;
      case UserType.external:
        return l10n.external_user;
    }
  }
}

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> with TickerProviderStateMixin {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final stuNumberController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _animationController.forward();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    emailController.dispose();
    stuNumberController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// 회원가입 처리
  void _handleSignUp() async {
    final l10n = AppLocalizations.of(context)!;
    final id = usernameController.text.trim();
    final pw = passwordController.text.trim();
    final confirmPw = confirmPasswordController.text.trim();
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final stuNumber = stuNumberController.text.trim();

    // 입력 검증 (전화번호는 App Store 가이드라인 5.1.1 준수를 위해 수집하지 않음)
    if (id.isEmpty || pw.isEmpty || name.isEmpty) {
      _showDialog(l10n.required_fields_empty, isError: true);
      return;
    }

    if (pw != confirmPw) {
      _showDialog(l10n.password_mismatch, isError: true);
      return;
    }

    if (pw.length < 6) {
      _showDialog(l10n.password_too_short, isError: true);
      return;
    }

    // 이메일 형식 검증 (선택사항)
    if (email.isNotEmpty && !_isValidEmail(email)) {
      _showDialog(l10n.invalid_email_format, isError: true);
      return;
    }

    final userAuth = Provider.of<UserAuth>(context, listen: false);
    
    // 서버 API를 통한 회원가입 시도
    final success = await userAuth.register(
      id: id,
      password: pw,
      name: name,
      stuNumber: stuNumber.isEmpty ? null : stuNumber,
      email: email.isEmpty ? null : email,
      context: context,
    );

    if (success && mounted) {
      // 회원가입 성공
      _showDialog(l10n.register_success_message, isSuccess: true);
    } else if (mounted) {
      // 회원가입 실패
      _showDialog(userAuth.lastError ?? l10n.register_error, isError: true);
    }
  }

  /// 이메일 형식 검증
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// 결과 다이얼로그 표시 (우송 네이비 테마)
  void _showDialog(String message, {bool isSuccess = false, bool isError = false}) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isSuccess ? Colors.green : (isError ? Color(0xFF1E3A8A) : Color(0xFF3B82F6))).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSuccess ? Icons.check_circle : (isError ? Icons.error_outline : Icons.info_outline),
                color: isSuccess ? Colors.green : (isError ? Color(0xFF1E3A8A) : Color(0xFF3B82F6)),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isSuccess ? l10n.success : (isError ? l10n.error : l10n.info),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isSuccess ? Colors.green : (isError ? Color(0xFF1E3A8A) : Color(0xFF3B82F6)),
              ),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            message,
            textAlign: TextAlign.center,
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
              onPressed: () {
                Navigator.of(context).pop();
                if (isSuccess) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginFormView()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess ? Colors.green : Color(0xFF1E3A8A),
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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Consumer<UserAuth>(
                builder: (context, userAuth, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 헤더
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: userAuth.isLoading ? null : () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              l10n.register,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // 서브타이틀
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          l10n.welcome_to_ttarausong,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 회원가입 폼
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // 필수 입력 필드들
                            WoosongInputField(
                              icon: Icons.person_outline,
                              label: '${l10n.username} *',
                              controller: usernameController,
                              hint: l10n.enter_username,
                            ),
                            const SizedBox(height: 16),
                            WoosongInputField(
                              icon: Icons.lock_outline,
                              label: '${l10n.password} *',
                              controller: passwordController,
                              isPassword: true,
                              hint: l10n.password_hint,
                            ),
                            const SizedBox(height: 16),
                            WoosongInputField(
                              icon: Icons.lock_outline,
                              label: '${l10n.confirm_password} *',
                              controller: confirmPasswordController,
                              isPassword: true,
                              hint: l10n.confirm_password_hint,
                            ),
                            const SizedBox(height: 16),
                            WoosongInputField(
                              icon: Icons.badge_outlined,
                              label: '${l10n.name} *',
                              controller: nameController,
                              hint: l10n.enter_real_name,
                            ),
                            const SizedBox(height: 16),
                            // 선택 입력 필드들
                            WoosongInputField(
                              icon: Icons.numbers_outlined,
                              label: '${l10n.student_number} (${l10n.optional})',
                              controller: stuNumberController,
                              hint: l10n.enter_student_number,
                            ),
                            const SizedBox(height: 16),
                            WoosongInputField(
                              icon: Icons.email_outlined,
                              label: '${l10n.email} (${l10n.optional})',
                              controller: emailController,
                              hint: l10n.email_hint,
                            ),

                            const SizedBox(height: 24),

                            // 필수 항목 안내
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF1E3A8A).withOpacity(0.1),
                                    Color(0xFF3B82F6).withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Color(0xFF1E3A8A).withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF1E3A8A).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.info_outline,
                                      color: Color(0xFF1E3A8A),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      l10n.required_fields_notice,
                                      style: TextStyle(
                                        color: Color(0xFF1E3A8A),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // 회원가입 버튼
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1E3A8A),
                                    Color(0xFF3B82F6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF1E3A8A).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: userAuth.isLoading ? null : _handleSignUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: userAuth.isLoading 
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        l10n.create_account,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // 취소 버튼
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Color(0xFF1E3A8A).withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: userAuth.isLoading ? null : () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  l10n.cancel,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                              ),
                            ),

                            // 에러 메시지 표시
                            if (userAuth.lastError != null) ...[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.red.shade50,
                                      Colors.red.shade100,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.error_outline,
                                        color: Colors.red.shade600,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        userAuth.lastError!,
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
