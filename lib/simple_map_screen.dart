// lib/simple_map_screen.dart - 간단한 테스트용 지도 화면
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/user_auth.dart';
import 'map/map_screen.dart';

class SimpleMapScreen extends StatefulWidget {
  const SimpleMapScreen({super.key});

  @override
  State<SimpleMapScreen> createState() => _SimpleMapScreenState();
}

class _SimpleMapScreenState extends State<SimpleMapScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('✅ SimpleMapScreen 초기화 완료');
  }

  @override
  Widget build(BuildContext context) {
    try {
      final userAuth = context.read<UserAuth>();
      
      return Scaffold(
        appBar: AppBar(
          title: const Text('지도 화면'),
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map, size: 100, color: Color(0xFF1E3A8A)),
              const SizedBox(height: 20),
              Text(
                '로그인 성공!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '사용자: ${userAuth.userName ?? "알 수 없음"}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'ID: ${userAuth.userId ?? "알 수 없음"}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // 실제 MapScreen으로 이동
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MapScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text('실제 지도로 이동'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // 로그아웃
                  userAuth.logout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text('로그아웃'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ SimpleMapScreen build 오류: $e');
      return Scaffold(
        appBar: AppBar(
          title: const Text('오류'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 100, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                '화면 로딩 중 오류가 발생했습니다.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                '오류: $e',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/',
                    (route) => false,
                  );
                },
                child: const Text('처음으로 돌아가기'),
              ),
            ],
          ),
        ),
      );
    }
  }
}

