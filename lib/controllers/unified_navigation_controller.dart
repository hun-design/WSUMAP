// lib/controllers/unified_navigation_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/inside/building_map_page.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_application_1/models/building.dart';
import 'package:flutter_application_1/services/unified_path_service.dart';
import 'package:flutter_application_1/generated/app_localizations.dart';

/// 네비게이션 단계 정의
enum NavigationStep {
  departureIndoor,  // 출발지 실내 (호실 → 건물 출구)
  outdoor,          // 실외 (건물 간 이동)
  arrivalIndoor,    // 도착지 실내 (건물 입구 → 호실)
  completed,        // 완료
}

/// 네비게이션 상태
class NavigationState {
  final NavigationStep currentStep;
  final String? instruction;
  final double? remainingDistance;
  final String? estimatedTime;
  final bool isActive;

  NavigationState({
    required this.currentStep,
    this.instruction,
    this.remainingDistance,
    this.estimatedTime,
    this.isActive = false,
  });

  NavigationState copyWith({
    NavigationStep? currentStep,
    String? instruction,
    double? remainingDistance,
    String? estimatedTime,
    bool? isActive,
  }) {
    return NavigationState(
      currentStep: currentStep ?? this.currentStep,
      instruction: instruction ?? this.instruction,
      remainingDistance: remainingDistance ?? this.remainingDistance,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// 통합 네비게이션 컨트롤러
class UnifiedNavigationController extends ChangeNotifier {
  NavigationState _state = NavigationState(currentStep: NavigationStep.completed);
  UnifiedPathResponse? _currentPathResponse;
  
  // 네비게이션 데이터
  Building? _startBuilding;
  Building? _endBuilding;
  
  // 단계별 데이터
  List<NLatLng>? _outdoorCoordinates;
  List<String>? _departureIndoorNodes;
  List<String>? _arrivalIndoorNodes;
  
  // UI 컨트롤러 참조
  BuildContext? _context;

  // Getters
  NavigationState get state => _state;
  bool get isNavigating => _state.isActive;
  NavigationStep get currentStep => _state.currentStep;
  String? get currentInstruction => _state.instruction;
  UnifiedPathResponse? get currentPathResponse => _currentPathResponse;

  /// 컨텍스트 설정
  void setContext(BuildContext context) {
    _context = context;
  }

  /// 건물 간 네비게이션 시작
  Future<bool> startNavigationBetweenBuildings({
    required Building fromBuilding,
    required Building toBuilding,
  }) async {
    try {
      debugPrint('🚀 건물 간 네비게이션 시작: ${fromBuilding.name} → ${toBuilding.name}');
      
      _startBuilding = fromBuilding;
      _endBuilding = toBuilding;
      
      final response = await UnifiedPathService.getPathBetweenBuildings(
        fromBuilding: fromBuilding,
        toBuilding: toBuilding,
      );
      
      if (response != null) {
        return await _processPathResponse(response);
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ 건물 간 네비게이션 시작 오류: $e');
      return false;
    }
  }

  /// 현재 위치에서 건물로 네비게이션 시작
  Future<bool> startNavigationFromCurrentLocation({
    required NLatLng currentLocation,
    required Building toBuilding,
  }) async {
    try {
      debugPrint('🚀 현재 위치에서 네비게이션 시작: 내 위치 → ${toBuilding.name}');
      
      _endBuilding = toBuilding;
      
      final response = await UnifiedPathService.getPathFromLocation(
        fromLocation: currentLocation,
        toBuilding: toBuilding,
      );
      
      if (response != null) {
        return await _processPathResponse(response);
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ 현재 위치 네비게이션 시작 오류: $e');
      return false;
    }
  }

  /// 호실 간 네비게이션 시작
  Future<bool> startNavigationBetweenRooms({
    required String fromBuilding,
    required int fromFloor,
    required String fromRoom,
    required String toBuilding,
    required int toFloor,
    required String toRoom,
  }) async {
    try {
      debugPrint('🚀 호실 간 네비게이션 시작: $fromBuilding $fromRoom호 → $toBuilding $toRoom호');
      
      final response = await UnifiedPathService.getPathBetweenRooms(
        fromBuilding: fromBuilding,
        fromFloor: fromFloor,
        fromRoom: fromRoom,
        toBuilding: toBuilding,
        toFloor: toFloor,
        toRoom: toRoom,
      );
      
      if (response != null) {
        return await _processPathResponse(response);
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ 호실 간 네비게이션 시작 오류: $e');
      return false;
    }
  }

  /// 경로 응답 처리 및 네비게이션 시작
  Future<bool> _processPathResponse(UnifiedPathResponse response) async {
    try {
      _currentPathResponse = response;
      
      debugPrint('📋 경로 응답 처리: ${response.type}');
      
      // 응답 타입별 처리
      switch (response.type) {
        case 'building-building':
          return await _handleBuildingToBuildingNavigation(response);
          
        case 'room-building':
          return await _handleRoomToBuildingNavigation(response);
          
        case 'building-room':
          return await _handleBuildingToRoomNavigation(response);
          
        case 'room-room':
          return await _handleRoomToRoomNavigation(response);
          
        case 'location-building':
          return await _handleLocationToBuildingNavigation(response);
          
        default:
          debugPrint('❌ 지원하지 않는 경로 타입: ${response.type}');
          return false;
      }
    } catch (e) {
      debugPrint('❌ 경로 응답 처리 오류: $e');
      return false;
    }
  }

  /// 건물 → 건물 네비게이션
Future<bool> _handleBuildingToBuildingNavigation(UnifiedPathResponse response) async {
  final outdoorData = response.result.outdoor;
  if (outdoorData == null) return false;

  _outdoorCoordinates = UnifiedPathService.extractOutdoorCoordinates(outdoorData);

  _updateState(NavigationState(
    currentStep: NavigationStep.outdoor,
    instruction: AppLocalizations.of(_context!)!
        .instructionMoveToDestination(_endBuilding?.name ?? '목적지'),
    isActive: true,
  ));

  return await _startOutdoorNavigation();
}


  /// 호실 → 건물 네비게이션
  Future<bool> _handleRoomToBuildingNavigation(UnifiedPathResponse response) async {
    final departureData = response.result.departureIndoor;
    final outdoorData = response.result.outdoor;
    
    if (departureData != null) {
      _departureIndoorNodes = UnifiedPathService.extractIndoorNodeIds(departureData);
      
   _updateState(NavigationState(
  currentStep: NavigationStep.departureIndoor,
  instruction: AppLocalizations.of(_context!)!.instructionExitToOutdoor,
  isActive: true,
));
      
      // 출발지 실내 네비게이션 시작
      await _startIndoorNavigation(_departureIndoorNodes!, isArrival: false);
      
      // 실외 준비
      if (outdoorData != null) {
        _outdoorCoordinates = UnifiedPathService.extractOutdoorCoordinates(outdoorData);
      }
      
      return true;
    }
    
    return false;
  }

  /// 건물 → 호실 네비게이션
Future<bool> _handleBuildingToRoomNavigation(UnifiedPathResponse response) async {
  final outdoorData = response.result.outdoor;
  final arrivalData = response.result.arrivalIndoor;

  if (outdoorData != null) {
    _outdoorCoordinates = UnifiedPathService.extractOutdoorCoordinates(outdoorData);

    if (arrivalData != null) {
      _arrivalIndoorNodes = UnifiedPathService.extractIndoorNodeIds(arrivalData);
    }

    _updateState(NavigationState(
      currentStep: NavigationStep.outdoor,
      instruction: AppLocalizations.of(_context!)!
          .instructionMoveToDestinationBuilding(_endBuilding?.name ?? '목적지'),
      isActive: true,
    ));

    return await _startOutdoorNavigation();
  }

  return false;
}


  /// 호실 → 호실 네비게이션
  Future<bool> _handleRoomToRoomNavigation(UnifiedPathResponse response) async {
    final departureData = response.result.departureIndoor;
    final outdoorData = response.result.outdoor;
    final arrivalData = response.result.arrivalIndoor;
    
    // 같은 건물 내 이동
    if (departureData == null && outdoorData == null && arrivalData != null) {
      _arrivalIndoorNodes = UnifiedPathService.extractIndoorNodeIds(arrivalData);
      
_updateState(NavigationState(
  currentStep: NavigationStep.arrivalIndoor,
  instruction: AppLocalizations.of(_context!)!.instructionMoveToRoom,
  isActive: true,
));
      
      return await _startIndoorNavigation(_arrivalIndoorNodes!, isArrival: true);
    }
    
    // 다른 건물 간 이동
    if (departureData != null) {
      _departureIndoorNodes = UnifiedPathService.extractIndoorNodeIds(departureData);
      
      if (outdoorData != null) {
        _outdoorCoordinates = UnifiedPathService.extractOutdoorCoordinates(outdoorData);
      }
      
      if (arrivalData != null) {
        _arrivalIndoorNodes = UnifiedPathService.extractIndoorNodeIds(arrivalData);
      }
      
      _updateState(NavigationState(
        currentStep: NavigationStep.departureIndoor,
        instruction: '건물 출구까지 이동하세요',
        isActive: true,
      ));
      
      return await _startIndoorNavigation(_departureIndoorNodes!, isArrival: false);
    }
    
    return false;
  }

  /// 현재 위치 → 건물 네비게이션
  Future<bool> _handleLocationToBuildingNavigation(UnifiedPathResponse response) async {
  final outdoorData = response.result.outdoor;
  final arrivalData = response.result.arrivalIndoor;

  if (outdoorData != null) {
    _outdoorCoordinates = UnifiedPathService.extractOutdoorCoordinates(outdoorData);

    if (arrivalData != null) {
      _arrivalIndoorNodes = UnifiedPathService.extractIndoorNodeIds(arrivalData);
    }

    _updateState(NavigationState(
      currentStep: NavigationStep.outdoor,
      instruction: AppLocalizations.of(_context!)!
          .instructionMoveToDestination(_endBuilding?.name ?? '목적지'),
      isActive: true,
    ));

    return await _startOutdoorNavigation();
  }

  return false;
}


  /// 실내 네비게이션 시작
  Future<bool> _startIndoorNavigation(List<String> nodeIds, {required bool isArrival}) async {
    if (_context == null || _startBuilding == null) return false;
    
    try {
      debugPrint('🏢 실내 네비게이션 시작: ${nodeIds.length}개 노드');
      
      // BuildingMapPage로 이동
      final result = await Navigator.of(_context!).push(
        MaterialPageRoute(
          builder: (context) => BuildingMapPage(
            buildingName: isArrival ? (_endBuilding?.name ?? '') : (_startBuilding?.name ?? ''),
            // 추가 파라미터로 네비게이션 데이터 전달
            navigationNodeIds: nodeIds,
            isArrivalNavigation: isArrival,
          ),
        ),
      );
      
      // 실내 네비게이션 완료 후 처리
      if (result == 'completed') {
        return await _onIndoorNavigationCompleted(isArrival);
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ 실내 네비게이션 시작 오류: $e');
      return false;
    }
  }

  /// 실외 네비게이션 시작
  Future<bool> _startOutdoorNavigation() async {
    if (_outdoorCoordinates == null || _outdoorCoordinates!.isEmpty) return false;
    
    try {
      debugPrint('🌍 실외 네비게이션 시작: ${_outdoorCoordinates!.length}개 좌표');
      
      // 실외 지도에 경로 표시 (기존 MapController 사용)
      // 이 부분은 기존 map_controller.dart의 로직을 활용
      
      return true;
    } catch (e) {
      debugPrint('❌ 실외 네비게이션 시작 오류: $e');
      return false;
    }
  }

  /// 실내 네비게이션 완료 처리
Future<bool> _onIndoorNavigationCompleted(bool wasArrival) async {
  if (wasArrival) {
    _updateState(NavigationState(
      currentStep: NavigationStep.completed,
      instruction: AppLocalizations.of(_context!)!.instructionArrived,
      isActive: false,
    ));
  } else {
    _updateState(NavigationState(
      currentStep: NavigationStep.outdoor,
      instruction: AppLocalizations.of(_context!)!
          .instructionMoveToDestination(_endBuilding?.name ?? '목적지'),
      isActive: true,
    ));
  }
  return true;
}


  /// 실외 네비게이션 완료 처리
Future<bool> onOutdoorNavigationCompleted() async {
  if (_arrivalIndoorNodes != null && _arrivalIndoorNodes!.isNotEmpty) {
    _updateState(NavigationState(
      currentStep: NavigationStep.arrivalIndoor,
      instruction: AppLocalizations.of(_context!)!.instructionMoveToRoom,
      isActive: true,
    ));
    return true;
  } else {
    _updateState(NavigationState(
      currentStep: NavigationStep.completed,
      instruction: AppLocalizations.of(_context!)!.instructionArrived,
      isActive: false,
    ));
    return true;
  }
}


  /// 네비게이션 중단
  void stopNavigation() {
    debugPrint('🛑 네비게이션 중단');
    
    _updateState(NavigationState(
      currentStep: NavigationStep.completed,
      isActive: false,
    ));
    
    _currentPathResponse = null;
    _startBuilding = null;
    _endBuilding = null;
    _outdoorCoordinates = null;
    _departureIndoorNodes = null;
    _arrivalIndoorNodes = null;
  }

  /// 상태 업데이트
  void _updateState(NavigationState newState) {
    _state = newState;
    notifyListeners();
    debugPrint('📍 네비게이션 상태 변경: ${newState.currentStep} - ${newState.instruction}');
  }

  /// 다음 단계로 진행
Future<void> proceedToNextStep() async {
  switch (_state.currentStep) {
    case NavigationStep.departureIndoor:
      if (_outdoorCoordinates != null) {
        _updateState(_state.copyWith(
          currentStep: NavigationStep.outdoor,
          instruction: AppLocalizations.of(_context!)!
              .instructionMoveToDestination(_endBuilding?.name ?? '목적지'),
        ));
        await _startOutdoorNavigation();
      }
      break;

    case NavigationStep.outdoor:
      await onOutdoorNavigationCompleted();
      break;

    case NavigationStep.arrivalIndoor:
      _updateState(_state.copyWith(
        currentStep: NavigationStep.completed,
        instruction: AppLocalizations.of(_context!)!.instructionArrived,
        isActive: false,
      ));
      break;

    case NavigationStep.completed:
      break;
  }
}

  @override
  void dispose() {
    stopNavigation();
    super.dispose();
  }
}