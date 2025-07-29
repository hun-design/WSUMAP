import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/user_auth.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import '../generated/app_localizations.dart';

class ProfileActionPage extends StatefulWidget {
  final UserAuth userAuth;
  final AppLocalizations l10n;
  final VoidCallback onLogout;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ProfileActionPage({
    super.key,
    required this.userAuth,
    required this.l10n,
    required this.onLogout,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<ProfileActionPage> createState() => _ProfileActionPageState();
}

class _ProfileActionPageState extends State<ProfileActionPage> {
  bool _isLocationEnabled = true; // 기본값은 true
  bool _isUpdating = false; // 업데이트 중 상태

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.l10n.my_info,
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 위치 허용 섹션
              _buildLocationSection(),
              const SizedBox(height: 24),
              
              // 회원정보 수정 섹션
              _buildEditProfileSection(),
              const SizedBox(height: 24),
              
              // 회원탈퇴 섹션
              _buildDeleteAccountSection(),
              const SizedBox(height: 24),
              
              // 로그아웃 섹션
              _buildLogoutSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: _isLocationEnabled ? const Color(0xFF10B981) : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '위치 정보 공유',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _isLocationEnabled ? const Color(0xFF1E293B) : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isLocationEnabled ? '위치 정보가 활성화되어 있습니다' : '위치 정보가 비활성화되어 있습니다',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isLocationEnabled ? Colors.grey[600] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isLocationEnabled,
              onChanged: _isUpdating ? null : _onLocationToggleChanged,
              activeColor: const Color(0xFF10B981),
              activeTrackColor: const Color(0xFF10B981).withOpacity(0.3),
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditProfileSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        leading: Icon(Icons.edit_outlined, color: const Color(0xFF1E3A8A)),
        title: Text(
          '프로필 정보 수정',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Text(
          '이름, 이메일, 전화번호, 비밀번호 변경',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
        onTap: widget.onEdit,
      ),
    );
  }

  Widget _buildDeleteAccountSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Icon(Icons.delete_outline, color: Colors.red),
        title: Text(
          '계정 삭제',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.red,
          ),
        ),
        subtitle: Text(
          '모든 데이터가 영구적으로 삭제됩니다',
          style: TextStyle(
            fontSize: 12,
            color: Colors.red.withOpacity(0.7),
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.red.withOpacity(0.5), size: 16),
        onTap: widget.onDelete,
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A8A)),
      ),
      child: ListTile(
        leading: Icon(Icons.logout, color: const Color(0xFF1E3A8A)),
        title: Text(
          '로그아웃',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        subtitle: Text(
          '현재 계정에서 로그아웃합니다',
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF1E3A8A).withOpacity(0.7),
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: const Color(0xFF1E3A8A).withOpacity(0.5), size: 16),
        onTap: widget.onLogout,
      ),
    );
  }

  /// 🔥 위치 허용 토글 변경 처리
  Future<void> _onLocationToggleChanged(bool value) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      // 현재 로그인된 사용자 ID 가져오기
      final currentUserId = widget.userAuth.userId;
      if (currentUserId == null) {
        throw Exception('로그인된 사용자 정보를 찾을 수 없습니다');
      }

      // 서버에 위치 공유 설정 업데이트 요청
      final authService = AuthService();
      final success = await authService.updateShareLocation(currentUserId, value);

      if (success) {
        setState(() {
          _isLocationEnabled = value;
        });

        // 성공 메시지 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    value ? Icons.location_on : Icons.location_off,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value ? '위치 공유가 활성화되었습니다' : '위치 공유가 비활성화되었습니다',
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
        // 실패 시 원래 상태로 되돌리기
        setState(() {
          _isLocationEnabled = !value;
        });

        // 실패 메시지 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('위치 공유 설정 변경에 실패했습니다'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('위치 공유 설정 변경 오류: $e');
      
      // 실패 시 원래 상태로 되돌리기
      setState(() {
        _isLocationEnabled = !value;
      });

      // 에러 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('위치 공유 설정 변경 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }
} 