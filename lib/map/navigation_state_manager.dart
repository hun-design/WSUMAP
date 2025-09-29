// lib/map/navigation_state_manager.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/building.dart';
import 'package:flutter_application_1/controllers/map_controller.dart';

class NavigationStateManager extends ChangeNotifier {
  bool _showNavigationStatus = false;
  String _estimatedDistance = '';
  String _estimatedTime = '';
  Building? _navigationStart;
  Building? _navigationEnd;

  // Getters
  bool get showNavigationStatus => _showNavigationStatus;
  String get estimatedDistance => _estimatedDistance;
  String get estimatedTime => _estimatedTime;
  Building? get navigationStart => _navigationStart;
  Building? get navigationEnd => _navigationEnd;

  // 상태 초기화
  void clearNavigation() {
    _showNavigationStatus = false;
    _estimatedDistance = '';
    _estimatedTime = '';
    _navigationStart = null;
    _navigationEnd = null;
    notifyListeners();
  }

  // 길찾기 결과 처리 메서드
  void handleDirectionsResult(Map<String, dynamic> result, BuildContext context) {
    final startBuilding = result['start'] as Building?;
    final endBuilding = result['end'] as Building?;
    final useCurrentLocation = result['useCurrentLocation'] as bool? ?? false;
    final estimatedDistance = result['estimatedDistance'] as String? ?? '';
    final estimatedTime = result['estimatedTime'] as String? ?? '';
    final showNavigationStatus = result['showNavigationStatus'] as bool? ?? false;
    
    debugPrint('=== 경로 안내 결과 처리 ===');
    debugPrint('출발지: ${startBuilding?.name ?? '내 위치'}');
    debugPrint('도착지: ${endBuilding?.name}');
    debugPrint('현재 위치 사용: $useCurrentLocation');
    debugPrint('예상 거리: $estimatedDistance');
    debugPrint('예상 시간: $estimatedTime');
    debugPrint('네비게이션 상태 표시: $showNavigationStatus');
    
    // 네비게이션 상태 업데이트
    _showNavigationStatus = showNavigationStatus;
    _estimatedDistance = estimatedDistance;
    _estimatedTime = estimatedTime;
    _navigationStart = useCurrentLocation ? null : startBuilding;
    _navigationEnd = endBuilding;
    notifyListeners();
    
    // 성공 알림 표시
    if (showNavigationStatus) {
      _showSuccessMessage(context, endBuilding, estimatedDistance, estimatedTime);
    }
  }

  // 실제 길 안내 시작 메서드
  void startActualNavigation(MapScreenController controller, BuildContext context) {
    if (_navigationEnd == null) {
      debugPrint('도착지가 설정되지 않았습니다');
      return;
    }
    
    debugPrint('🚀 길 안내 시작 - 경로 표시!');
    debugPrint('출발지: ${_navigationStart?.name ?? "현재 위치"}');
    debugPrint('도착지: ${_navigationEnd!.name}');
    
    try {
      if (_navigationStart == null) {
        // 현재 위치에서 출발
        debugPrint('현재 위치에서 ${_navigationEnd!.name}까지 경로 표시');
        controller.navigateFromCurrentLocation(_navigationEnd!);
      } else {
        // 특정 건물에서 출발
        debugPrint('${_navigationStart!.name}에서 ${_navigationEnd!.name}까지 경로 표시');
        controller.setStartBuilding(_navigationStart!);
        controller.setEndBuilding(_navigationEnd!);
        controller.calculateRoute();
      }
      
      // 성공 알림 표시
      _showNavigationStartMessage(context);
      
    } catch (e) {
      debugPrint('❌ 경로 표시 실패: $e');
      _showErrorMessage(context, '경로 표시에 실패했습니다. 다시 시도해주세요.');
    }
  }

  void _showSuccessMessage(BuildContext context, Building? endBuilding, String distance, String time) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${endBuilding?.name}까지의 경로 정보가 준비되었습니다',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (distance.isNotEmpty && time.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '$distance • $time',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
            ],
          ],
        ),
        backgroundColor: const Color(0xFF2196F3),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showNavigationStartMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.navigation, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _navigationStart == null 
                  ? '${_navigationEnd!.name}까지 경로가 표시되었습니다'
                  : '${_navigationStart!.name}에서 ${_navigationEnd!.name}까지 경로가 표시되었습니다',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('🗺️ NavigationStateManager dispose 시작...');
    
    // 🔥 모든 상태 초기화로 메모리 정리
    _showNavigationStatus = false;
    _estimatedDistance = '';
    _estimatedTime = '';
    _navigationStart = null;
    _navigationEnd = null;
    
    debugPrint('✅ NavigationStateManager dispose 완료');
    super.dispose();
  }
}