// lib/screens/map_loading_screen.dart - 최적화된 버전

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../map/map_screen.dart';
import '../auth/user_auth.dart';
import '../login/login_form_view.dart';

/// 지도 초기화 로딩 화면
class MapLoadingScreen extends StatefulWidget {
  const MapLoadingScreen({super.key});

  @override
  State<MapLoadingScreen> createState() => _MapLoadingScreenState();
}

class _MapLoadingScreenState extends State<MapLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  late Animation<double> _logoAnimation;
  late Animation<double> _progressAnimation;
  
  String _currentStep = '지도 초기화 중...';
  int _currentStepIndex = 0;
  Timer? _navigationTimer;
  Timer? _stepUpdateTimer;
  
  static const List<String> _loadingSteps = [
    '지도 초기화 중...',
    '위치 서비스 준비 중...',
    '친구 목록 로딩 중...',
    '건물 정보 로딩 중...',
    '최종 설정 중...',
  ];

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    
    _startAnimations();
    _startStepUpdates();
    _navigateToMapScreen();
  }

  void _startAnimations() {
    _logoController.forward();
    _progressController.forward();
  }

  void _startStepUpdates() {
    _stepUpdateTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _currentStepIndex = (_currentStepIndex + 1) % _loadingSteps.length;
          _currentStep = _loadingSteps[_currentStepIndex];
        });
      }
    });
  }

  void _navigateToMapScreen() {
    _navigationTimer = Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        FocusScope.of(context).unfocus();
        
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            _checkLoginStatusAndNavigate();
          }
        });
      }
    });
  }

  void _handleLoginFailure() {
    debugPrint('🔥 로그인 실패 감지 - 즉시 로그인 화면으로 이동');
    
    _navigationTimer?.cancel();
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginFormView()),
        (route) => false,
      );
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    
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
                color: const Color(0xFF1E3A8A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Color(0xFF1E3A8A),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '로그인 실패',
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
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                '확인',
                style: TextStyle(
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

  void _checkLoginStatusAndNavigate() {
    final userAuth = Provider.of<UserAuth>(context, listen: false);
    
    if (userAuth.isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MapScreen()),
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginFormView()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _stepUpdateTimer?.cancel();
    _logoController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserAuth>(
      builder: (context, userAuth, child) {
        if (!userAuth.isLoading && userAuth.isLoggedIn && userAuth.isGuest) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              debugPrint('✅ 게스트 로그인 완료 감지 - 즉시 맵 화면으로 이동');
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MapScreen()),
              );
            }
          });
        } else if (!userAuth.isLoading && !userAuth.isLoggedIn && 
                   userAuth.lastError != null && !userAuth.isGuest) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleLoginFailure();
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                _showErrorDialog(userAuth.lastError!);
              }
            });
          });
        }
        
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Container(
            width: double.infinity,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                  
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _logoAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 0.8 + (_logoAnimation.value * 0.2),
                                child: Opacity(
                                  opacity: _logoAnimation.value,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF3B82F6).withOpacity(0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.map,
                                      color: Colors.white,
                                      size: 60,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 24),
                          
                          AnimatedBuilder(
                            animation: _logoAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _logoAnimation.value,
                                child: const Text(
                                  '캠퍼스 네비게이터',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 8),
                          
                          AnimatedBuilder(
                            animation: _logoAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _logoAnimation.value * 0.7,
                                child: const Text(
                                  '따라우송 캠퍼스 길찾기',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _currentStep,
                              key: ValueKey(_currentStep),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: AnimatedBuilder(
                              animation: _progressAnimation,
                              builder: (context, child) {
                                return FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _progressAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF3B82F6),
                                          Color(0xFF1D4ED8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return Text(
                                '${(_progressAnimation.value * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
