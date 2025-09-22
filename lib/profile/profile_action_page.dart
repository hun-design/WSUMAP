import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../auth/user_auth.dart';
import '../services/auth_service.dart';
import '../services/websocket_service.dart';
import '../generated/app_localizations.dart';

class ProfileActionPage extends StatefulWidget {
  final UserAuth userAuth;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onLogout;

  const ProfileActionPage({
    required this.userAuth,
    required this.onEdit,
    required this.onDelete,
    required this.onLogout,
    super.key,
  });

  @override
  State<ProfileActionPage> createState() => _ProfileActionPageState();
}

class _ProfileActionPageState extends State<ProfileActionPage> {
  bool _isLocationEnabled = false;
  bool _isUpdating = false;
  StreamSubscription? _websocketSubscription;

  @override
  void initState() {
    super.initState();
    _loadLocationShareStatus();
    _setupWebSocketListener();
  }

  @override
  void dispose() {
    _websocketSubscription?.cancel();
    super.dispose();
  }



  /// 🔥 웹소켓 리스너 설정
  void _setupWebSocketListener() {
    final wsService = WebSocketService();
    _websocketSubscription = wsService.messageStream.listen((message) {
      if (message['type'] == 'friend_location_share_status_change') {
        final userId = message['userId'];
        final isLocationPublic = message['isLocationPublic'] ?? false;
        
        // 현재 사용자의 위치 공유 상태 변경인 경우에만 업데이트
        if (userId == widget.userAuth.userId) {
          debugPrint('📍 현재 사용자 위치 공유 상태 변경: $isLocationPublic');
          setState(() {
            _isLocationEnabled = isLocationPublic;
          });
          // SharedPreferences에도 저장
          _saveLocationShareStatus(isLocationPublic);
        }
      }
    });
  }

  /// 🔥 SharedPreferences에서 위치공유 상태 로드
  Future<void> _loadLocationShareStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStatus = prefs.getBool('location_share_enabled');
      debugPrint('🔥 SharedPreferences에서 로드한 위치공유 상태: $savedStatus');
      
      if (savedStatus != null) {
        // 저장된 상태가 있으면 사용
        setState(() {
          _isLocationEnabled = savedStatus;
        });
        debugPrint('✅ SharedPreferences에서 위치공유 상태 로드 완료: $savedStatus');
      } else {
        // 저장된 상태가 없으면 서버에서 가져오기
        debugPrint('🔄 저장된 상태가 없음, 서버에서 조회 시도');
        await _fetchLocationShareStatus();
      }
    } catch (e) {
      debugPrint('❌ 위치공유 상태 로드 중 오류: $e');
      // 오류 발생 시 기본값으로 설정
      setState(() {
        _isLocationEnabled = false;
      });
      await _saveLocationShareStatus(false);
    }
  }

  /// 🔥 SharedPreferences에 위치공유 상태 저장
  Future<void> _saveLocationShareStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_share_enabled', status);
    debugPrint('🔥 SharedPreferences에 위치공유 상태 저장: $status');
  }

  /// 🔥 서버에서 위치공유 상태 가져오기
  Future<void> _fetchLocationShareStatus() async {
    try {
      final userId = widget.userAuth.userId;
      if (userId != null && userId.isNotEmpty && !widget.userAuth.isGuest) {
        final status = await AuthService().getShareLocationStatus(userId);
        if (status != null) {
          setState(() {
            _isLocationEnabled = status;
          });
          await _saveLocationShareStatus(status);
          debugPrint('✅ 서버에서 위치공유 상태 로드 완료: $status');
        } else {
          // 🔥 서버에서 상태를 가져올 수 없으면 기본값 true로 설정 (실제로 위치가 전송되고 있다면)
          setState(() {
            _isLocationEnabled = true;
          });
          await _saveLocationShareStatus(true);
          debugPrint('⚠️ 서버에서 위치공유 상태 null, 기본값 true 설정 (위치 전송 중)');
        }
      } else {
        setState(() {
          _isLocationEnabled = false;
        });
        await _saveLocationShareStatus(false);
        debugPrint('⚠️ 게스트 사용자 또는 userId 없음, 기본값 false 설정');
      }
    } catch (e) {
      debugPrint('❌ 서버에서 위치공유 상태 조회 실패: $e');
      setState(() {
        _isLocationEnabled = false;
      });
      await _saveLocationShareStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.my_info,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E3A8A), // 우송대 남색
                Color(0xFF3B82F6), // 파란색
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 위치 허용 섹션
              _buildLocationSection(),
              const SizedBox(height: 20),
              
              // 회원정보 수정 섹션
              _buildEditProfileSection(),
              const SizedBox(height: 20),
              
              // 회원탈퇴 섹션
              _buildDeleteAccountSection(),
              const SizedBox(height: 20),
              
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isLocationEnabled 
            ? const Color(0xFF10B981).withOpacity(0.3)
            : Colors.grey.shade200,
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
              color: _isLocationEnabled 
                ? const Color(0xFF10B981).withOpacity(0.1)
                : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isLocationEnabled 
                  ? const Color(0xFF10B981).withOpacity(0.3)
                  : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Icon(
              Icons.location_on,
              color: _isLocationEnabled ? const Color(0xFF10B981) : Colors.grey.shade500,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.location_share_title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _isLocationEnabled ? const Color(0xFF1E293B) : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isLocationEnabled ? l10n.location_share_enabled : l10n.location_share_disabled,
                  style: TextStyle(
                    fontSize: 14,
                    color: _isLocationEnabled ? Colors.grey[600] : Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          _isUpdating
              ? Container(
                  width: 48,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                      ),
                    ),
                  ),
                )
              : Switch(
                  value: _isLocationEnabled,
                  onChanged: _onLocationToggleChanged,
                  activeColor: const Color(0xFF10B981),
                  activeTrackColor: const Color(0xFF10B981).withOpacity(0.3),
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[300],
                ),
        ],
      ),
    );
  }

  Widget _buildEditProfileSection() {
    final l10n = AppLocalizations.of(context)!;
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
      child: InkWell(
        onTap: widget.onEdit,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF1E3A8A).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF1E3A8A),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.profile_edit_title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.profile_edit_subtitle,
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
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountSection() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
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
      child: InkWell(
        onTap: widget.onDelete,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.account_delete_title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.account_delete_subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.withOpacity(0.7),
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
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.red.withOpacity(0.7),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1E3A8A).withOpacity(0.3),
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
      child: InkWell(
        onTap: widget.onLogout,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF1E3A8A).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.logout,
                color: Color(0xFF1E3A8A),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.logout_title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.logout_subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF1E3A8A).withOpacity(0.7),
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
                color: const Color(0xFF1E3A8A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: const Color(0xFF1E3A8A).withOpacity(0.7),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 위치 허용 토글 변경 처리 (개선된 버전)
  void _onLocationToggleChanged(bool value) async {
    debugPrint('🔥 위치 공유 상태 변경 시도: $value');
    
    // 이미 업데이트 중이면 무시
    if (_isUpdating) {
      debugPrint('⚠️ 이미 업데이트 중입니다. 무시합니다.');
      return;
    }
    
    setState(() {
      _isUpdating = true;
    });
    
    final userId = widget.userAuth.userId;
    final prev = _isLocationEnabled;
    final l10n = AppLocalizations.of(context)!;
    
    // UI를 즉시 업데이트 (사용자 경험 향상)
    setState(() {
      _isLocationEnabled = value;
    });
    
    // SharedPreferences에 즉시 저장
    await _saveLocationShareStatus(value);
    
    // 로그인한 사용자이고 게스트가 아닌 경우에만 서버 동기화
    if (userId != null && userId.isNotEmpty && !widget.userAuth.isGuest) {
      try {
        debugPrint('🔄 서버에 위치공유 상태 업데이트 시도: $value');
        final success = await AuthService().updateShareLocation(userId, value);
        
        if (success) {
          debugPrint('✅ 서버에 위치 공유 상태 저장 성공');
          // 🔥 웹소켓을 통해 다른 사용자들에게 위치 공유 상태 변경 알림
          _sendLocationShareStatusChangeNotification(userId, value);
          
          // 성공 메시지 표시
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(value ? l10n.location_share_enabled_success : l10n.location_share_disabled_success),
                backgroundColor: const Color(0xFF10B981),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          debugPrint('❌ 서버에 위치 공유 상태 저장 실패');
          if (mounted) {
            // 실패 시 원래대로 롤백
            setState(() {
              _isLocationEnabled = prev;
            });
            // SharedPreferences도 롤백
            await _saveLocationShareStatus(prev);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.location_share_update_failed),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('❌ 위치 공유 상태 업데이트 중 오류: $e');
        if (mounted) {
          // 오류 시 원래대로 롤백
          setState(() {
            _isLocationEnabled = prev;
          });
          // SharedPreferences도 롤백
          await _saveLocationShareStatus(prev);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.location_share_update_failed),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } else {
      debugPrint('❗ userId가 null이거나 게스트 모드, 로컬만 저장');
      // 게스트 모드이거나 userId가 없으면 로컬만 저장
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.guest_location_share_success),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
    
    setState(() {
      _isUpdating = false;
    });
  }

  /// 🔥 웹소켓을 통해 위치 공유 상태 변경 알림 전송
  void _sendLocationShareStatusChangeNotification(String userId, bool isLocationPublic) {
    try {
      final wsService = WebSocketService();
      if (wsService.isConnected) {
        // 🔥 웹소켓 메시지 전송
        wsService.sendMessage({
          'type': 'friend_location_share_status_change',
          'userId': userId,
          'isLocationPublic': isLocationPublic,
          'message': '친구의 위치 공유 상태가 변경되었습니다.',
          'timestamp': DateTime.now().toIso8601String(),
        });
        debugPrint('📍 위치 공유 상태 변경 알림 전송: $userId - ${isLocationPublic ? '공유' : '비공유'}');
      } else {
        debugPrint('⚠️ 웹소켓이 연결되지 않아 알림을 전송할 수 없습니다.');
      }
    } catch (e) {
      debugPrint('❌ 위치 공유 상태 변경 알림 전송 실패: $e');
    }
  }
} 