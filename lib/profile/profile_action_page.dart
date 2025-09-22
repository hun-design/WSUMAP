import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../auth/user_auth.dart';
import '../services/auth_service.dart';
import '../services/websocket_service.dart';
import '../managers/location_manager.dart';
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

class _ProfileActionPageState extends State<ProfileActionPage> with TickerProviderStateMixin {
  bool _isLocationEnabled = false;
  bool _isUpdating = false;
  StreamSubscription? _websocketSubscription;
  LocationManager? _locationManager;
  bool _isUserToggling = false; // 🔥 사용자가 직접 토글 중인지 확인하는 플래그
  
  // 🔥 애니메이션 컨트롤러들
  late AnimationController _toggleAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _toggleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _locationManager = Provider.of<LocationManager>(context, listen: false);
    
    // 🔥 애니메이션 컨트롤러 초기화
    _toggleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // 🔥 애니메이션 설정
    _toggleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _toggleAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));
    
    
    _loadLocationShareStatus();
    _setupWebSocketListener();
    _setupLocationManagerListener();
  }

  @override
  void dispose() {
    _websocketSubscription?.cancel();
    _toggleAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  /// 🔥 LocationManager 리스너 설정 (무한 루프 방지 및 사용자 토글 우선순위 보장)
  void _setupLocationManagerListener() {
    if (_locationManager != null) {
      _locationManager!.setLocationSendingStateCallback((isEnabled, userId) {
        debugPrint('📍 LocationManager에서 위치 전송 상태 변경: $isEnabled, userId: $userId');
        
        // 🔥 사용자가 직접 토글 중이면 동기화 차단
        if (_isUserToggling) {
          debugPrint('⚠️ 사용자 토글 중이므로 LocationManager 동기화 차단');
          return;
        }
        
        // 현재 사용자의 위치 전송 상태인지 확인
        if (userId == widget.userAuth.userId) {
          // 🔥 무한 루프 방지: 현재 상태와 다를 때만 업데이트
          if (_isLocationEnabled != isEnabled) {
            setState(() {
              _isLocationEnabled = isEnabled;
            });
            // SharedPreferences에도 저장 (조건부)
            _saveLocationShareStatus(isEnabled);
            debugPrint('✅ 프로필 페이지 위치 상태 동기화: $isEnabled');
          } else {
            debugPrint('⚠️ 상태가 동일하여 동기화 건너뜀: $isEnabled');
          }
        }
      });
    }
  }



  /// 🔥 웹소켓 리스너 설정 (사용자 토글 우선순위 보장)
  void _setupWebSocketListener() {
    final wsService = WebSocketService();
    _websocketSubscription = wsService.messageStream.listen((message) {
      if (message['type'] == 'friend_location_share_status_change') {
        final userId = message['userId'];
        final isLocationPublic = message['isLocationPublic'] ?? false;
        
        // 🔥 사용자가 직접 토글 중이면 웹소켓 동기화 차단
        if (_isUserToggling) {
          debugPrint('⚠️ 사용자 토글 중이므로 웹소켓 동기화 차단');
          return;
        }
        
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

  /// 🔥 SharedPreferences에서 위치공유 상태 로드 (단순화된 버전 - 강제 동기화 제거)
  Future<void> _loadLocationShareStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStatus = prefs.getBool('location_share_enabled');
      debugPrint('🔥 SharedPreferences에서 로드한 위치공유 상태: $savedStatus');
      
      if (savedStatus != null) {
        // 저장된 상태가 있으면 사용 (LocationManager 강제 동기화 제거)
        setState(() {
          _isLocationEnabled = savedStatus;
        });
        
        // 🔥 초기 애니메이션 상태 설정
        if (savedStatus) {
          _toggleAnimationController.value = 1.0;
        } else {
          _toggleAnimationController.value = 0.0;
        }
        
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
    return AnimatedBuilder(
      animation: Listenable.merge([_toggleAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isLocationEnabled 
                ? const Color(0xFF10B981).withOpacity(0.3 + (_toggleAnimation.value * 0.2))
                : Colors.grey.shade200,
              width: 1 + (_toggleAnimation.value * 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: _isLocationEnabled 
                  ? const Color(0xFF10B981).withOpacity(0.1 + (_toggleAnimation.value * 0.1))
                  : Colors.black.withOpacity(0.08),
                blurRadius: 16 + (_toggleAnimation.value * 4),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // 🔥 애니메이션된 아이콘 컨테이너
              Transform.scale(
                scale: _isLocationEnabled ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _isLocationEnabled 
                      ? const Color(0xFF10B981).withOpacity(0.1 + (_toggleAnimation.value * 0.1))
                      : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isLocationEnabled 
                        ? const Color(0xFF10B981).withOpacity(0.3 + (_toggleAnimation.value * 0.2))
                        : Colors.grey.shade300,
                      width: 1 + (_toggleAnimation.value * 0.5),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: Icon(
                      _isLocationEnabled ? Icons.location_on : Icons.location_off,
                      key: ValueKey(_isLocationEnabled),
                      color: _isLocationEnabled ? const Color(0xFF10B981) : Colors.grey.shade500,
                      size: 24,
                    ),
                  ),
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
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 14,
                    color: _isLocationEnabled ? Colors.grey[600] : Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                  child: Text(_getLocationStatusText()),
                ),
              ],
            ),
          ),
          // 🔥 부드러운 토글 스위치
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
              : AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Switch(
                    value: _isLocationEnabled,
                    onChanged: _onLocationToggleChanged,
                    activeColor: const Color(0xFF10B981),
                    activeTrackColor: const Color(0xFF10B981).withOpacity(0.3),
                    inactiveThumbColor: Colors.grey[400],
                    inactiveTrackColor: Colors.grey[300],
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
        ],
      ),
    );
      },
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

  /// 🔥 위치 허용 토글 변경 처리 (개선된 버전 - 즉시 반응형)
  void _onLocationToggleChanged(bool value) async {
    debugPrint('🔥 위치 공유 상태 변경 시도: $value (현재 상태: $_isLocationEnabled)');
    
    // 이미 업데이트 중이면 무시
    if (_isUpdating) {
      debugPrint('⚠️ 이미 업데이트 중입니다. 무시합니다.');
      return;
    }
    
    // 🔥 사용자 토글 플래그 설정 (다른 동기화 로직 차단)
    _isUserToggling = true;
    
    // 🔥 상태 관리를 위한 변수들
    final userId = widget.userAuth.userId;
    final l10n = AppLocalizations.of(context)!;
    
      // 🔥 즉시 UI 업데이트 (사용자 경험 최우선)
      setState(() {
        _isLocationEnabled = value;
        _isUpdating = true;
      });
      
      // 🔥 애니메이션 트리거
      if (value) {
        _toggleAnimationController.forward();
        _pulseAnimationController.repeat(reverse: true);
      } else {
        _toggleAnimationController.reverse();
        _pulseAnimationController.stop();
        _pulseAnimationController.reset();
      }
      
      debugPrint('✅ UI 즉시 업데이트 완료: $value');
    
    // SharedPreferences에 즉시 저장
    await _saveLocationShareStatus(value);
    debugPrint('💾 SharedPreferences 저장 완료: $value');
    
    // 🔥 LocationManager 즉시 연동
    if (_locationManager != null && userId != null && userId.isNotEmpty && !widget.userAuth.isGuest) {
      try {
        if (value) {
          _locationManager!.startPeriodicLocationSending(userId: userId);
          debugPrint('✅ LocationManager 위치 전송 시작');
        } else {
          _locationManager!.stopPeriodicLocationSending();
          debugPrint('✅ LocationManager 위치 전송 중지');
        }
      } catch (e) {
        debugPrint('⚠️ LocationManager 연동 중 오류: $e');
      }
    }
    
    // 🔥 백그라운드에서 서버 동기화 (UI 블로킹 없음)
    _syncWithServerInBackground(value, userId, l10n);
    
    // 🔥 업데이트 상태 해제
    setState(() {
      _isUpdating = false;
    });
    
    // 🔥 사용자 토글 플래그 해제
    _isUserToggling = false;
    debugPrint('✅ 위치 공유 상태 업데이트 완료: $value');
    debugPrint('📍 최종 UI 상태: $_isLocationEnabled');
  }
  
  /// 🔥 백그라운드에서 서버 동기화 (UI 블로킹 없음)
  void _syncWithServerInBackground(bool value, String? userId, AppLocalizations l10n) async {
    if (userId == null || userId.isEmpty || widget.userAuth.isGuest) {
      debugPrint('❗ 게스트 모드 또는 userId 없음, 서버 동기화 건너뜀');
      return;
    }
    
    try {
      debugPrint('🔄 백그라운드 서버 동기화 시작: $value');
      
      final success = await AuthService().updateShareLocation(userId, value);
      
      if (success) {
        debugPrint('✅ 백그라운드 서버 동기화 성공');
        
        // 웹소켓 알림 전송
        try {
          _sendLocationShareStatusChangeNotification(userId, value);
        } catch (e) {
          debugPrint('⚠️ 웹소켓 알림 전송 중 오류: $e');
        }
        
        // 성공 메시지 표시 (선택적) - 위젯 상태 안전성 확인
        _showSafeSnackBar(
          value ? '위치 공유가 활성화되었습니다.' : '위치 공유가 비활성화되었습니다.',
          const Color(0xFF10B981),
        );
      } else {
        debugPrint('❌ 백그라운드 서버 동기화 실패');
        
        // 실패 시 사용자에게 알림 (선택적)
        _showSafeSnackBar(
          '서버 동기화에 실패했습니다. 로컬 설정은 적용되었습니다.',
          Colors.orange,
        );
      }
    } catch (e) {
      debugPrint('❌ 백그라운드 서버 동기화 중 오류: $e');
    }
  }
  
  /// 🔥 안전한 SnackBar 표시 (위젯 상태 확인)
  void _showSafeSnackBar(String message, Color backgroundColor) {
    if (!mounted) {
      debugPrint('⚠️ 위젯이 마운트되지 않음, SnackBar 표시 건너뜀');
      return;
    }
    
    try {
      // 위젯 트리가 안전한지 확인
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        debugPrint('⚠️ 컨텍스트가 마운트되지 않음, SnackBar 표시 건너뜀');
      }
    } catch (e) {
      debugPrint('⚠️ SnackBar 표시 중 오류 (무시): $e');
    }
  }

  /// 🔥 위치 상태 텍스트 생성 (다국어 지원)
  String _getLocationStatusText() {
    final l10n = AppLocalizations.of(context)!;
    
    if (_isUpdating) {
      return l10n.location_share_updating;
    }
    
    if (_isLocationEnabled) {
      return l10n.location_share_enabled;
    } else {
      return l10n.location_share_disabled;
    }
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