// lib/screens/map_loading_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../map/map_screen.dart';

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
  
  final List<String> _loadingSteps = [
    '지도 초기화 중...',
    '위치 서비스 준비 중...',
    '친구 목록 로딩 중...',
    '건물 정보 로딩 중...',
    '최종 설정 중...',
  ];

  @override
  void initState() {
    super.initState();
    
    // 로고 애니메이션 컨트롤러
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // 진행률 애니메이션 컨트롤러
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // 로고 페이드인 애니메이션
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));
    
    // 진행률 애니메이션
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _startAnimations();
    _startStepUpdates();
    _navigateToMapScreen();
  }

  void _startAnimations() {
    _logoController.forward();
    _progressController.forward();
  }

  void _startStepUpdates() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _currentStepIndex = (_currentStepIndex + 1) % _loadingSteps.length;
          _currentStep = _loadingSteps[_currentStepIndex];
        });
      }
    });
  }

  void _navigateToMapScreen() {
    // 🔥 키보드 완전 숨김 후 MapScreen으로 이동 (오버플로우 방지)
    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        // 🔥 키보드가 완전히 숨겨진 상태에서 화면 전환
        FocusScope.of(context).unfocus();
        
        // 🔥 부드러운 전환을 위한 추가 지연
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MapScreen()),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                // 상단 여백
                const SizedBox(height: 80),
              
              // 로고 섹션
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 앱 로고 (애니메이션)
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
                    
                    // 앱 이름
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
                    
                    // 부제목
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
              
              // 로딩 섹션
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 현재 단계 텍스트
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
                    
                    // 진행률 바
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
                    
                    // 진행률 퍼센트
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
              
              // 하단 여백
              const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
