import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../auth/user_auth.dart';
import '../providers/app_language_provider.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});
  
  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
    
    // 전화번호 포맷팅 리스너 추가
    _phoneController.addListener(_formatPhoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// 전화번호 자동 포맷팅
  void _formatPhoneNumber() {
    final text = _phoneController.text;
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length <= 3) {
      _phoneController.value = TextEditingValue(
        text: digitsOnly,
        selection: TextSelection.collapsed(offset: digitsOnly.length),
      );
    } else if (digitsOnly.length <= 7) {
      final formatted = '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3)}';
      _phoneController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } else {
      final formatted = '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 7)}-${digitsOnly.substring(7, 11)}';
      _phoneController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;
    
    // 변경된 필드 확인
    final userAuth = Provider.of<UserAuth>(context, listen: false);
    
    final newName = _nameController.text.trim();
    final newEmail = _emailController.text.trim();
    final newPhone = _phoneController.text.trim();
    final newPassword = _passwordController.text.trim();
    final newConfirmPassword = _confirmPasswordController.text.trim();
    
    // 변경사항이 있는지 확인
    bool hasChanges = false;
    Map<String, dynamic> changes = {};
    
    // 이름 변경 확인
    if (newName.isNotEmpty && newName != userAuth.userName) {
      changes['name'] = newName;
      hasChanges = true;
    }
    
    // 이메일 변경 확인 (현재 이메일은 저장되지 않으므로 비어있지 않으면 변경으로 간주)
    if (newEmail.isNotEmpty) {
      changes['email'] = newEmail;
      hasChanges = true;
    }
    
    // 전화번호 변경 확인 (현재 전화번호는 저장되지 않으므로 비어있지 않으면 변경으로 간주)
    if (newPhone.isNotEmpty) {
      changes['phone'] = newPhone;
      hasChanges = true;
    }
    
    // 비밀번호 변경 확인
    if (newPassword.isNotEmpty) {
      if (newPassword != newConfirmPassword) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text(l10n.password_mismatch),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }
      changes['password'] = newPassword;
      hasChanges = true;
    }
    
    // 변경사항이 없으면 저장하지 않음
    if (!hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info, color: Colors.white),
              const SizedBox(width: 8),
              Text(l10n.no_changes),
            ],
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      debugPrint('프로필 수정 변경사항: $changes');
      final success = await userAuth.updateUserInfo(
        email: changes['email'],
        phone: changes['phone'],
        password: changes['password'],
        context: context,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(l10n.profile_updated),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text(userAuth.lastError ?? l10n.update_error),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text(l10n.profile_edit_error),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLanguageProvider>(
      builder: (context, languageProvider, child) {
        final l10n = AppLocalizations.of(context)!;
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: Text(
              l10n.edit_profile,
              style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: const Color(0xFF1E3A8A),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔥 우송 네이비 그라데이션 헤더
                    _buildHeader(l10n),
                    const SizedBox(height: 32),
                    
                    // 이름
                    _buildProfileField(
                      label: l10n.name,
                      controller: _nameController,
                      icon: Icons.person,
                      validator: (value) => value == null || value.trim().isEmpty ? l10n.name_required : null,
                    ),
                    const SizedBox(height: 20),
                    // 이메일
                    _buildProfileField(
                      label: l10n.email,
                      controller: _emailController,
                      icon: Icons.email,
                      validator: (value) => value == null || value.trim().isEmpty ? l10n.email_required : null,
                    ),
                    const SizedBox(height: 20),
                    // 전화번호 (선택, 가이드라인 5.1.1)
                    _buildProfileField(
                      label: '${l10n.phone} (${l10n.optional})',
                      controller: _phoneController,
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) => null,
                    ),
                    const SizedBox(height: 20),
                    // 비밀번호
                    _buildProfileField(
                      label: l10n.password,
                      controller: _passwordController,
                      icon: Icons.lock,
                      obscureText: true,
                      validator: (value) => null,
                    ),
                    const SizedBox(height: 20),
                    // 비밀번호 확인
                    _buildProfileField(
                      label: l10n.confirm_password,
                      controller: _confirmPasswordController,
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) => null,
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              side: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              l10n.cancel,
                              style: const TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(
                                    l10n.save,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 🔥 우송 네이비 그라데이션 헤더
  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF3B82F6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.edit,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.edit_profile,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.edit_profile_subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1E3A8A).withOpacity(0.2),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF1E3A8A).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1E3A8A),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                labelStyle: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                floatingLabelStyle: const TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }
}
