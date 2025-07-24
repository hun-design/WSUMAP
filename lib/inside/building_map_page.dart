// lib/page/building_map_page.dart - 완전한 전체 코드 1/10

import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

// 기존 imports
import '../inside/api_service.dart';
import '../inside/svg_data_parser.dart';
import '../inside/room_info.dart';
import '../inside/room_info_sheet.dart';
import '../inside/room_shape_painter.dart';
import '../inside/path_painter.dart';

// 새로 추가된 imports
import '../services/unified_path_service.dart';
import '../controllers/unified_navigation_controller.dart';
import 'dart:math';

class BuildingMapPage extends StatefulWidget {
  final String buildingName;
  final List<String>? navigationNodeIds;
  final bool isArrivalNavigation;
  final UnifiedNavigationController? navigationController;
  final String? targetRoomId;
  final int? targetFloorNumber;

  const BuildingMapPage({
    super.key,
    required this.buildingName,
    this.navigationNodeIds,
    this.isArrivalNavigation = false,
    this.navigationController,
    this.targetRoomId,
    this.targetFloorNumber,
  });

  @override
  State<BuildingMapPage> createState() => _BuildingMapPageState();
}

class _BuildingMapPageState extends State<BuildingMapPage> {
  // 기존 상태 변수들
  List<dynamic> _floorList = [];
  Map<String, dynamic>? _selectedFloor;
  String? _svgUrl;
  List<Map<String, dynamic>> _buttonData = [];
  Map<String, dynamic>? _startPoint;
  Map<String, dynamic>? _endPoint;
  List<Offset> _departurePath = [];
  List<Offset> _arrivalPath = [];
  List<Offset> _currentShortestPath = [];
  Map<String, String>? _transitionInfo;
  bool _isFloorListLoading = true;
  bool _isMapLoading = false;
  String? _error;
  String? _selectedRoomId;

  final ApiService _apiService = ApiService();
  final TransformationController _transformationController = TransformationController();
  Timer? _resetTimer;
  static const double svgScale = 0.9;
  bool _showTransitionPrompt = false;
  Timer? _promptTimer;

  // 통합 네비게이션 관련 상태
  bool _isNavigationMode = false;
  List<Offset> _navigationPath = [];

  // 검색 결과 자동 선택 관련 상태
  bool _shouldAutoSelectRoom = false;
  String? _autoSelectRoomId;

  // 🔥 디버그 정보 표시용 상태 변수들 - 초기값 설정
  String _debugInfo = '노드 매칭 대기 중...';
  List<String> _matchedNodes = [];
  List<String> _failedNodes = [];
  // 2/10 계속...

  @override
  void initState() {
    super.initState();
    _isNavigationMode = widget.navigationNodeIds != null;

    // 검색 결과에서 온 경우 자동 선택 준비
    _shouldAutoSelectRoom = widget.targetRoomId != null;
    _autoSelectRoomId = widget.targetRoomId;

    // 로딩 시작 알림
    if (_shouldAutoSelectRoom && widget.targetRoomId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${widget.targetRoomId} 호실 지도를 불러오는 중...'),
                ],
              ),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.indigo,
            ),
          );
        }
      });
    }

    if (_isNavigationMode && widget.navigationNodeIds!.isNotEmpty) {
      final firstNode = widget.navigationNodeIds!.firstWhere(
        (id) => id.contains('@'),
        orElse: () => '',
      );
      final floorNum = firstNode.split('@').length >= 2
          ? firstNode.split('@')[1]
          : '1';
      _loadFloorList(widget.buildingName, targetFloorNumber: floorNum);
    } else {
      final targetFloor = widget.targetFloorNumber?.toString();
      _loadFloorList(widget.buildingName, targetFloorNumber: targetFloor);
    }

    if (_isNavigationMode) {
      _setupNavigationMode();
    }
  }

  // 🔥 검색 결과 호실 자동 선택 처리
  void _handleAutoRoomSelection() {
    try {
      if (!_shouldAutoSelectRoom || 
          _autoSelectRoomId == null || 
          _autoSelectRoomId!.isEmpty ||
          _buttonData.isEmpty) {
        debugPrint('⚠️ 자동 선택 조건 불충족');
        return;
      }

      debugPrint('🎯 자동 호실 선택 시도: $_autoSelectRoomId');

      // 'R' 접두사 확인 및 추가
      final targetRoomId = _autoSelectRoomId!.startsWith('R') 
          ? _autoSelectRoomId! 
          : 'R$_autoSelectRoomId';

      // 안전한 버튼 찾기
      Map<String, dynamic>? targetButton;
      try {
        for (final button in _buttonData) {
          if (button['id'] == targetRoomId) {
            targetButton = button;
            break;
          }
        }
      } catch (e) {
        debugPrint('❌ 버튼 검색 중 오류: $e');
        targetButton = null;
      }

      if (targetButton != null && targetButton.isNotEmpty) {
        debugPrint('✅ 자동 선택할 호실 찾음: $targetRoomId');
        
        setState(() {
          _selectedRoomId = targetRoomId;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('$_autoSelectRoomId 호실을 찾는 중...'),
                ],
              ),
              duration: const Duration(milliseconds: 1500),
              backgroundColor: Colors.blue,
            ),
          );
        }
        
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _focusOnRoom(targetButton!);
          }
        });
        
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            _showRoomInfoSheet(context, targetRoomId);
          }
        });
        
        _shouldAutoSelectRoom = false;
        _autoSelectRoomId = null;
      } else {
        debugPrint('❌ 자동 선택할 호실을 찾지 못함: $targetRoomId');
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('호실 $_autoSelectRoomId을(를) 찾을 수 없습니다.'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });
        
        _shouldAutoSelectRoom = false;
        _autoSelectRoomId = null;
      }
    } catch (e) {
      debugPrint('❌ _handleAutoRoomSelection 전체 오류: $e');
      _shouldAutoSelectRoom = false;
      _autoSelectRoomId = null;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('호실 자동 선택 중 오류가 발생했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  // 3/10 계속...

  void _focusOnRoom(Map<String, dynamic> roomButton) {
    try {
      if (roomButton.isEmpty) {
        debugPrint('❌ roomButton이 비어있음');
        return;
      }

      Rect? bounds;
      try {
        if (roomButton['type'] == 'path') {
          final path = roomButton['path'] as Path?;
          if (path != null) {
            bounds = path.getBounds();
          }
        } else {
          bounds = roomButton['rect'] as Rect?;
        }
      } catch (e) {
        debugPrint('❌ bounds 계산 오류: $e');
        return;
      }
      
      if (bounds == null) {
        debugPrint('❌ bounds가 null');
        return;
      }
      
      final centerX = bounds.center.dx;
      final centerY = bounds.center.dy;
      
      debugPrint('📍 호실 중심점: ($centerX, $centerY)');
      
      try {
        final targetScale = 1.8;
        final translation = Matrix4.identity()
          ..scale(targetScale)
          ..translate(-centerX + 150, -centerY + 150);
        
        _transformationController.value = translation;
        
        _resetScaleAfterDelay(duration: 2000);
      } catch (e) {
        debugPrint('❌ 변환 매트릭스 적용 오류: $e');
      }
      
    } catch (e) {
      debugPrint('❌ _focusOnRoom 전체 오류: $e');
    }
  }

  void _setupNavigationMode() {
    debugPrint('🧭 네비게이션 모드 설정');
    debugPrint('   노드 개수: ${widget.navigationNodeIds?.length}');
    debugPrint('   도착 네비게이션: ${widget.isArrivalNavigation}');
    debugPrint('   전체 노드 ID들: ${widget.navigationNodeIds?.join(', ') ?? 'null'}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.navigationNodeIds != null) {
        _displayNavigationPath(widget.navigationNodeIds!);
      }
    });
  }

  Future<void> _displayNavigationPath(List<String> nodeIds) async {
    try {
      debugPrint('🗺️ 네비게이션 경로 표시 시작: ${nodeIds.length}개 노드');
      debugPrint('🗺️ 받은 노드 ID들: ${nodeIds.join(', ')}');

      final currentFloorNum = _selectedFloor?['Floor_Number'].toString() ?? '1';
      debugPrint('🗺️ 현재 선택된 층: $currentFloorNum');
      
      Map<String, Map<String, Offset>> floorNodesMap = {};
      await _loadNodesForFloor(currentFloorNum, floorNodesMap);

      // 🔥 현재 층의 모든 노드 확인
      final currentFloorNodes = floorNodesMap[currentFloorNum];
      if (currentFloorNodes != null) {
        debugPrint('🗺️ 현재 층 사용 가능한 노드들: ${currentFloorNodes.keys.toList()}');
      }

      final pathOffsets = _convertNodeIdsToOffsets(
        nodeIds,
        currentFloorNum,
        floorNodesMap,
      );

      if (pathOffsets.isNotEmpty) {
        setState(() {
          _navigationPath = pathOffsets;
          _currentShortestPath = pathOffsets;
        });

        debugPrint('✅ 네비게이션 경로 표시 완료: ${pathOffsets.length}개 좌표');
        debugPrint('✅ 경로 좌표들: ${pathOffsets.map((p) => '(${p.dx.toStringAsFixed(1)}, ${p.dy.toStringAsFixed(1)})').join(' -> ')}');
      } else {
        debugPrint('❌ 네비게이션 경로 변환 실패 - 좌표를 찾을 수 없음');
      }
    } catch (e) {
      debugPrint('❌ 네비게이션 경로 표시 오류: $e');
    }
  }
  // 4/10 계속...

  // 🔥 강화된 노드 ID 변환 로직 - 디버그 정보 포함
  List<Offset> _convertNodeIdsToOffsets(List<String> nodeIds, String floorNum, Map<String, Map<String, Offset>> floorNodesMap) {
  try {
    _matchedNodes.clear();
    _failedNodes.clear();
    
    debugPrint('🚀 === 노드 변환 시작 (단순화 버전) ===');
    debugPrint('🚀 받은 노드 ID들: ${nodeIds.join(', ')}');
    debugPrint('🚀 대상 층: $floorNum');
    
    if (nodeIds.isEmpty) {
      _debugInfo = '⚠️ nodeIds가 비어있음';
      debugPrint(_debugInfo);
      if (mounted) setState(() {});
      return [];
    }
    
    final nodeMap = floorNodesMap[floorNum];
    if (nodeMap == null || nodeMap.isEmpty) {
      _debugInfo = '⚠️ 층 $floorNum의 노드 맵이 비어있음';
      debugPrint(_debugInfo);
      debugPrint('🗺️ 사용 가능한 층들: ${floorNodesMap.keys.toList()}');
      if (mounted) setState(() {});
      return [];
    }

    debugPrint('🗺️ 현재 층 노드 개수: ${nodeMap.length}개');
    debugPrint('🗺️ 노드 샘플: ${nodeMap.keys.take(10).toList()}');

    final offsets = <Offset>[];
    
    for (String nodeId in nodeIds) {
      debugPrint('🔍 === 노드 처리: $nodeId ===');
      
      if (nodeId.isEmpty) {
        debugPrint('⚠️ 빈 nodeId 건너뛰기');
        continue;
      }

      Offset? foundOffset = _findNodeOffset(nodeId, nodeMap);
      
      if (foundOffset != null) {
        offsets.add(foundOffset);
        _matchedNodes.add(nodeId);
        debugPrint('✅ 매칭 성공: $nodeId -> $foundOffset');
      } else {
        _failedNodes.add(nodeId);
        debugPrint('❌ 매칭 실패: $nodeId');
        
        // 🔥 실패한 노드의 가능한 형태들을 로그로 출력
        List<String> tried = _generateSearchCandidates(nodeId);
        debugPrint('   시도한 형태들: ${tried.join(', ')}');
        debugPrint('   사용 가능한 노드 중 유사한 것: ${_findSimilarNodes(nodeId, nodeMap)}');
      }
    }

    _debugInfo = '노드 매칭: ${_matchedNodes.length}/${nodeIds.length} 성공';
    if (mounted) setState(() {});

    debugPrint('📊 === 노드 변환 완료 ===');
    debugPrint('📊 성공: ${offsets.length}개, 실패: ${nodeIds.length - offsets.length}개');
    
    return offsets;
    
  } catch (e) {
    _debugInfo = '❌ 노드 변환 오류: $e';
    if (mounted) setState(() {});
    debugPrint('❌ _convertNodeIdsToOffsets 전체 오류: $e');
    return [];
  }
}



/// 🔥 단일 노드의 오프셋 찾기 - 단계별 매칭
/// 🔥 단순화된 노드 오프셋 찾기
Offset? _findNodeOffset(String nodeId, Map<String, Offset> nodeMap) {
  debugPrint('🔍 노드 오프셋 찾기: $nodeId');
  
  // 후보들을 순서대로 확인
  List<String> candidates = _generateSearchCandidates(nodeId);
  
  for (String candidate in candidates) {
    if (nodeMap.containsKey(candidate)) {
      debugPrint('   ✅ 매칭 성공: $nodeId -> $candidate -> ${nodeMap[candidate]}');
      return nodeMap[candidate];
    } else {
      debugPrint('   ❌ 후보 실패: $candidate');
    }
  }
  
  debugPrint('   💀 모든 후보 실패: $nodeId');
  
  // 🔍 디버깅: 유사한 노드들 찾기
  final similar = nodeMap.keys.where((key) {
    String target = nodeId.split('@').last.toLowerCase();
    return key.toLowerCase().contains(target) || target.contains(key.toLowerCase());
  }).take(3).toList();
  
  if (similar.isNotEmpty) {
    debugPrint('   💡 유사한 노드들: ${similar.join(', ')}');
  }
  
  return null;
}


/// 🔥 검색 후보 생성 - 명확하고 순서가 있는 로직
/// 🔥 긴급 수정: API 노드 형태에 맞춘 검색 후보 생성
/// 🔥 간단한 노드 매칭: @ 뒤의 마지막 부분만 추출
/// 🔥 최종 수정: @ 구분자로 정확히 분할
List<String> _generateSearchCandidates(String nodeId) {
  final candidates = <String>[];
  
  debugPrint('🔍 후보 생성: $nodeId');
  
  // 1. 원본 그대로
  candidates.add(nodeId);
  
  // 2. @ 기호로 분할하여 각 부분 추출
  if (nodeId.contains('@')) {
    List<String> parts = nodeId.split('@');
    
    // 마지막 부분이 가장 중요 (실제 노드 ID)
    if (parts.isNotEmpty) {
      String lastPart = parts.last;
      candidates.add(lastPart);
      debugPrint('   핵심 노드: $lastPart');
      
      // R 접두사 버전도 시도
      if (!lastPart.startsWith('R')) {
        candidates.add('R$lastPart');
      }
    }
    
    // 모든 부분도 시도 (혹시 몰라서)
    for (String part in parts) {
      if (part.isNotEmpty && part != nodeId) {
        candidates.add(part);
      }
    }
  }
  
  // 중복 제거
  final uniqueCandidates = candidates.toSet().toList();
  debugPrint('   시도할 후보들: ${uniqueCandidates.join(', ')}');
  
  return uniqueCandidates;
}


/// 🔥 특수 노드를 호실 번호로 매핑
String? _mapSpecialNode(String nodeId) {
  // 네비게이션 노드를 가장 가까운 호실로 매핑
  final Map<String, String> nodeMapping = {
    // 입구/출구
    'enterence': '101',        // 입구는 101호 근처
    'entrance': '101',
    'exit': '101',
    
    // 계단
    'indoor-left-stairs': '112',   // 왼쪽 계단은 112호 근처
    'indoor-right-stairs': '101',  // 오른쪽 계단은 101호 근처
    'stairs-left': '112',
    'stairs-right': '101',
    'outdoor-left-stairs': '112',
    'outdoor-right-stairs': '101',
    
    // 복도 노드들 - 층과 위치에 따라 가장 가까운 호실로 매핑
    'b1': '101',
    'b2': '102', 
    'b3': '103',
    'b4': '104',
    'b5': '105',
    'b6': '106',
    'b7': '107',
    'b8': '108',
    'b9': '109',
    'b10': '110',
    'b11': '111',
    'b12': '112',
    
    // 2층 복도 노드들
    'b21': '201',
    'b22': '202',
    'b23': '203',
    'b24': '204',
    'b25': '205',
    'b26': '206',
    'b27': '207',
    'b28': '208',
    'b29': '209',
    'b30': '210',
  };
  
  return nodeMapping[nodeId.toLowerCase()];
}


/// 🔥 추가: SVG에 네비게이션 노드가 없을 때 가상 좌표 생성
Offset? _generateVirtualCoordinate(String nodeId, Map<String, Offset> nodeMap) {
  debugPrint('🔧 가상 좌표 생성 시도: $nodeId');
  
  // 현재 층의 호실들 중심점 계산
  final roomOffsets = nodeMap.entries
      .where((entry) => RegExp(r'^\d{3}$').hasMatch(entry.key))
      .map((entry) => entry.value)
      .toList();
  
  if (roomOffsets.isEmpty) return null;
  
  // 평균 위치 계산
  double avgX = roomOffsets.map((o) => o.dx).reduce((a, b) => a + b) / roomOffsets.length;
  double avgY = roomOffsets.map((o) => o.dy).reduce((a, b) => a + b) / roomOffsets.length;
  
  // 노드 타입에 따라 위치 조정
  if (nodeId.contains('entrance') || nodeId.contains('enterence')) {
    // 입구는 건물 중앙 하단
    return Offset(avgX, avgY + 50);
  } else if (nodeId.contains('stairs')) {
    // 계단은 건물 끝쪽
    if (nodeId.contains('left')) {
      return Offset(avgX - 100, avgY);
    } else {
      return Offset(avgX + 100, avgY);
    }
  } else if (nodeId.startsWith('b')) {
    // 복도 노드는 건물 중앙
    return Offset(avgX, avgY);
  }
  
  // 기본값: 건물 중앙
  return Offset(avgX, avgY);
}


/// 🔥 유사한 노드 찾기 (디버깅용)
List<String> _findSimilarNodes(String targetId, Map<String, Offset> nodeMap) {
  final target = targetId.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  
  return nodeMap.keys
      .where((nodeId) {
        final node = nodeId.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        return node.contains(target) || target.contains(node);
      })
      .take(3)
      .toList();
}


  void _onFloorChanged(Map<String, dynamic> newFloor) {
    final newFloorNumber = newFloor['Floor_Number'].toString();

    if (_selectedFloor?['Floor_Id'] == newFloor['Floor_Id'] && _error == null)
      return;

    setState(() {
      _selectedFloor = newFloor;

      if (_isNavigationMode && widget.navigationNodeIds != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _displayNavigationPath(widget.navigationNodeIds!);
        });
      } else {
        if (_transitionInfo != null) {
          if (newFloorNumber == _transitionInfo!['from']) {
            _currentShortestPath = _departurePath;
          } else if (newFloorNumber == _transitionInfo!['to']) {
            _currentShortestPath = _arrivalPath;
          } else {
            _currentShortestPath = [];
          }
        } else {
          final bool shouldResetPath =
              _startPoint?['floorId'] != newFloor['Floor_Id'] ||
              _endPoint?['floorId'] != newFloor['Floor_Id'];
          if (shouldResetPath) _currentShortestPath = [];
        }
      }
    });

    _loadMapData(newFloor);

    if (_transitionInfo != null) {
      _showAndFadePrompt();
    }
  }

  Future<void> _loadFloorList(
    String buildingName, {
    String? targetFloorNumber,
  }) async {
    setState(() {
      _isFloorListLoading = true;
      _error = null;
    });

    try {
      final floors = await _apiService.fetchFloorList(buildingName);

      if (mounted) {
        final allowedFloors = widget.navigationNodeIds
            ?.map((id) => id.split('@')[1])
            .toSet();

        final filteredFloors = allowedFloors != null
            ? floors
                  .where(
                    (f) => allowedFloors.contains(f['Floor_Number'].toString()),
                  )
                  .toList()
            : floors;

        setState(() {
          _floorList = filteredFloors;
          _isFloorListLoading = false;
        });

        if (_floorList.isNotEmpty) {
          final selectedFloor = targetFloorNumber != null
              ? _floorList.firstWhere(
                  (f) => f['Floor_Number'].toString() == targetFloorNumber,
                  orElse: () => _floorList.first,
                )
              : _floorList.first;

          selectedFloor['Floor_Number'] = selectedFloor['Floor_Number']
              .toString();
          _onFloorChanged(selectedFloor);
        } else {
          setState(() => _error = "이 건물의 층 정보를 찾을 수 없습니다.");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFloorListLoading = false;
          _error = '층 목록을 불러오는 데 실패했습니다: $e';
        });
      }
    }
  }

  Future<void> _loadMapData(Map<String, dynamic> floorInfo) async {
    setState(() => _isMapLoading = true);

    try {
      final svgUrl = floorInfo['File'] as String?;
      if (svgUrl == null || svgUrl.isEmpty)
        throw Exception('SVG URL이 유효하지 않습니다.');

      final svgResponse = await http
          .get(Uri.parse(svgUrl))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('SVG 로딩 시간 초과');
            },
          );

      if (svgResponse.statusCode != 200)
        throw Exception('SVG 파일을 다운로드할 수 없습니다');

      final svgContent = svgResponse.body;
      final buttons = SvgDataParser.parseButtonData(svgContent);

      if (mounted) {
        setState(() {
          _svgUrl = svgUrl;
          _buttonData = buttons;
          _isMapLoading = false;
        });

        if (_shouldAutoSelectRoom) {
          _handleAutoRoomSelection();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMapLoading = false;
          _error = '지도 데이터를 불러오는 데 실패했습니다: $e';
        });
      }
    }
  }

  Future<void> _loadNodesForFloor(
    String floorNumber,
    Map<String, Map<String, Offset>> targetMap,
  ) async {
    if (targetMap.containsKey(floorNumber)) {
      debugPrint('🔄 층 $floorNumber 노드는 이미 로드됨 (${targetMap[floorNumber]?.length}개)');
      return;
    }

    debugPrint('🔍 층 $floorNumber 노드 로딩 시작');

    final floorInfo = _floorList.firstWhere(
      (f) => f['Floor_Number'].toString() == floorNumber,
      orElse: () => null,
    );

    if (floorInfo != null) {
      final svgUrl = floorInfo['File'] as String?;
      debugPrint('🔍 층 $floorNumber SVG URL: $svgUrl');
      
      if (svgUrl != null && svgUrl.isNotEmpty) {
        try {
          final svgResponse = await http.get(Uri.parse(svgUrl));
          if (svgResponse.statusCode == 200) {
            final nodes = SvgDataParser.parseAllNodes(svgResponse.body);
            targetMap[floorNumber] = nodes;
            debugPrint('✅ 층 $floorNumber 노드 로딩 완료: ${nodes.length}개');
            debugPrint('📋 노드 샘플: ${nodes.keys.take(5).toList()}');
          } else {
            debugPrint('❌ SVG 다운로드 실패: ${svgResponse.statusCode}');
          }
        } catch (e) {
          debugPrint('❌ 층 $floorNumber 노드 로딩 오류: $e');
        }
      } else {
        debugPrint('❌ 층 $floorNumber SVG URL이 비어있음');
      }
    } else {
      debugPrint('❌ 층 $floorNumber 정보를 찾을 수 없음');
      debugPrint('사용 가능한 층들: ${_floorList.map((f) => f['Floor_Number'].toString()).toList()}');
    }
  }
  // 7/10 계속...

  void _setPoint(String type, String roomId) async {
    final pointData = {
      "floorId": _selectedFloor?['Floor_Id'],
      "floorNumber": _selectedFloor?['Floor_Number'],
      "roomId": roomId,
    };

    setState(() {
      if (type == 'start') {
        _startPoint = pointData;
      } else {
        _endPoint = pointData;
      }
    });

    if (mounted) Navigator.pop(context);

    if (_startPoint != null && _endPoint != null) {
      await _findAndDrawPath();
    }
  }

  Future<void> _findAndDrawPath() async {
    if (_startPoint == null || _endPoint == null) return;

    setState(() {
      _isMapLoading = true;
      _departurePath = [];
      _arrivalPath = [];
      _currentShortestPath = [];
      _transitionInfo = null;
    });

    try {
      final fromBuilding = widget.buildingName;
      final fromFloor = int.parse(_startPoint!['floorNumber'].toString());
      final fromRoom = (_startPoint!['roomId'] as String).replaceFirst('R', '');

      final toBuilding = _endPoint!['buildingName'] ?? widget.buildingName;
      final toFloor = int.parse(_endPoint!['floorNumber'].toString());
      final toRoom = (_endPoint!['roomId'] as String).replaceFirst('R', '');

      debugPrint('🚀 통합 API 경로 요청:');
      debugPrint('   출발: $fromBuilding $fromFloor층 $fromRoom호');
      debugPrint('   도착: $toBuilding $toFloor층 $toRoom호');

      final response = await UnifiedPathService.getPathBetweenRooms(
        fromBuilding: fromBuilding,
        fromFloor: fromFloor,
        fromRoom: fromRoom,
        toBuilding: toBuilding,
        toFloor: toFloor,
        toRoom: toRoom,
      );

      if (response == null) {
        throw Exception('통합 API에서 응답을 받지 못했습니다');
      }

      debugPrint('✅ 통합 API 응답: ${response.type}');
      await _processUnifiedPathResponse(response, fromFloor, toFloor);
    } catch (e) {
      _clearAllPathInfo();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('통합 길찾기 중 오류가 발생했습니다: $e'))
      );
      debugPrint('❌ 통합 길찾기 오류: $e');
    } finally {
      if (mounted) setState(() => _isMapLoading = false);
    }
  }

  Future<void> _processUnifiedPathResponse(
    UnifiedPathResponse response,
    int fromFloor,
    int toFloor,
  ) async {
    final type = response.type;
    final result = response.result;

    debugPrint('📋 통합 응답 처리: $type');

    switch (type) {
      case 'room-room':
        await _handleRoomToRoomResponse(result, fromFloor, toFloor);
        break;
      case 'room-building':
        await _handleRoomToBuildingResponse(result, fromFloor);
        break;
      case 'building-room':
        await _handleBuildingToRoomResponse(result, toFloor);
        break;
      case 'building-building':
        _handleBuildingToBuildingResponse(result);
        break;
      default:
        debugPrint('❌ 지원하지 않는 응답 타입: $type');
        throw Exception('지원하지 않는 경로 타입: $type');
    }
  }

  Future<void> _handleRoomToRoomResponse(
    PathResult result,
    int fromFloor,
    int toFloor,
  ) async {
    final departureIndoor = result.departureIndoor;
    final arrivalIndoor = result.arrivalIndoor;
    final outdoor = result.outdoor;

    debugPrint('🏠 _handleRoomToRoomResponse 시작');
    debugPrint('   departureIndoor: ${departureIndoor != null ? 'O' : 'X'}');
    debugPrint('   arrivalIndoor: ${arrivalIndoor != null ? 'O' : 'X'}');
    debugPrint('   outdoor: ${outdoor != null ? 'O' : 'X'}');

    if (departureIndoor != null && outdoor != null && arrivalIndoor != null) {
      debugPrint('🏢 다른 건물 간 호실 이동');
      final depNodeIds = UnifiedPathService.extractIndoorNodeIds(departureIndoor);
      debugPrint('🏢 출발지 노드 ID들: ${depNodeIds.join(', ')}');
      await _processIndoorPath(depNodeIds, fromFloor, true);
      _showOutdoorTransitionMessage(outdoor);
    } else if (arrivalIndoor != null) {
      debugPrint('🏠 같은 건물 내 호실 이동');
      final nodeIds = UnifiedPathService.extractIndoorNodeIds(arrivalIndoor);
      debugPrint('🏠 실내 노드 ID들: ${nodeIds.join(', ')}');
      await _processSameBuildingPath(nodeIds, fromFloor, toFloor);
    } else {
      debugPrint('❌ 예상치 못한 응답 구조');
    }
  }

  Future<void> _handleRoomToBuildingResponse(PathResult result, int fromFloor) async {
    final departureIndoor = result.departureIndoor;
    final outdoor = result.outdoor;

    if (departureIndoor != null) {
      debugPrint('🚪 호실에서 건물 출구까지');
      final nodeIds = UnifiedPathService.extractIndoorNodeIds(departureIndoor);
      await _processIndoorPath(nodeIds, fromFloor, true);
      if (outdoor != null) {
        _showOutdoorTransitionMessage(outdoor);
      }
    }
  }

  Future<void> _handleBuildingToRoomResponse(PathResult result, int toFloor) async {
    final outdoor = result.outdoor;
    final arrivalIndoor = result.arrivalIndoor;

    debugPrint('🏢 건물 입구에서 호실까지');
    if (outdoor != null) {
      _showOutdoorTransitionMessage(outdoor);
    }
    if (arrivalIndoor != null) {
      final nodeIds = UnifiedPathService.extractIndoorNodeIds(arrivalIndoor);
      debugPrint('📝 도착 후 실내 경로 준비: ${nodeIds.length}개 노드');
    }
  }

  void _handleBuildingToBuildingResponse(PathResult result) {
    final outdoor = result.outdoor;
    if (outdoor != null) {
      _showOutdoorTransitionMessage(outdoor);
    }
  }

  Future<void> _processIndoorPath(
    List<String> nodeIds,
    int floorNumber,
    bool isDeparture,
  ) async {
    debugPrint('🗺️ 실내 경로 처리: ${nodeIds.length}개 노드, 층: $floorNumber');

    final floorNumStr = floorNumber.toString();
    Map<String, Map<String, Offset>> floorNodesMap = {};
    await _loadNodesForFloor(floorNumStr, floorNodesMap);

    final pathOffsets = _convertNodeIdsToOffsets(nodeIds, floorNumStr, floorNodesMap);

    setState(() {
      if (isDeparture) {
        _departurePath = pathOffsets;
      } else {
        _arrivalPath = pathOffsets;
      }
      _currentShortestPath = pathOffsets;
    });

    debugPrint('✅ 실내 경로 표시: ${pathOffsets.length}개 좌표');
  }

  Future<void> _processSameBuildingPath(
    List<String> nodeIds,
    int fromFloor,
    int toFloor,
  ) async {
    debugPrint('🏠 같은 건물 내 경로 처리');

    final fromFloorStr = fromFloor.toString();
    final toFloorStr = toFloor.toString();
    final isCrossFloor = fromFloorStr != toFloorStr;

    Map<String, Map<String, Offset>> floorNodesMap = {};
    await _loadNodesForFloor(fromFloorStr, floorNodesMap);

    if (isCrossFloor) {
      await _loadNodesForFloor(toFloorStr, floorNodesMap);

      int splitIndex = nodeIds.indexWhere((id) => id.split('@')[1] != fromFloorStr);
      if (splitIndex == -1) splitIndex = nodeIds.length;

      final depOffsets = _convertNodeIdsToOffsets(
        nodeIds.sublist(0, splitIndex), fromFloorStr, floorNodesMap);
      final arrOffsets = _convertNodeIdsToOffsets(
        nodeIds.sublist(splitIndex), toFloorStr, floorNodesMap);

      setState(() {
        _departurePath = depOffsets;
        _arrivalPath = arrOffsets;
        _currentShortestPath = _selectedFloor?['Floor_Number'].toString() == fromFloorStr
            ? depOffsets : arrOffsets;
        _transitionInfo = {"from": fromFloorStr, "to": toFloorStr};
      });

      _showAndFadePrompt();
    } else {
      final sameFloorOffsets = _convertNodeIdsToOffsets(nodeIds, fromFloorStr, floorNodesMap);
      setState(() => _currentShortestPath = sameFloorOffsets);
    }
  }

  void _showOutdoorTransitionMessage(OutdoorPathData outdoorData) {
    final coordinates = UnifiedPathService.extractOutdoorCoordinates(outdoorData);
    final distance = outdoorData.path.distance;

    debugPrint('🌍 실외 경로 정보: ${coordinates.length}개 좌표, 거리: ${distance}m');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('실외 경로로 이동하세요 (거리: ${distance.toStringAsFixed(0)}m)'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  // 8/10 계속...

   void _showRoomInfoSheet(BuildContext context, String roomId) async {
  // 네비게이션 모드에서는 호실 정보 시트를 다르게 표시
  if (_isNavigationMode) {
    _showNavigationRoomSheet(context, roomId);
    return;
  }

  setState(() => _selectedRoomId = roomId);
  String roomIdNoR = roomId.startsWith('R') ? roomId.substring(1) : roomId;
  
  // 🔥 JSON 데이터에서 호실 정보 찾기
  Map<String, dynamic>? roomData;
  try {
    // 실제 JSON 데이터에서 해당 호실 정보 검색
    roomData = await _findRoomDataFromServer(
      buildingName: widget.buildingName,
      floorNumber: _selectedFloor?['Floor_Number']?.toString() ?? '',
      roomName: roomIdNoR,
    );
  } catch (e) {
    debugPrint('호실 데이터 검색 실패: $e');
    roomData = null;
  }

  // 🔥 실제 데이터가 있으면 사용하고, 없으면 기본값 사용
  String roomDesc = '';
  List<String> roomUsers = [];
  List<String>? userPhones;
  List<String>? userEmails;

  if (roomData != null) {
    // JSON 데이터에서 정보 추출
    roomDesc = roomData['Room_Description'] ?? '';
    roomUsers = _parseStringList(roomData['Room_User']);
    userPhones = _parseStringListNullable(roomData['User_Phone']);
    userEmails = _parseStringListNullable(roomData['User_Email']);
    
    debugPrint('🔍 호실 정보 찾음: $roomIdNoR');
    debugPrint('   설명: $roomDesc');
    debugPrint('   담당자: $roomUsers');
    debugPrint('   전화: $userPhones');
    debugPrint('   이메일: $userEmails');
  } else {
    // 기존 방식으로 설명만 가져오기
    try {
      roomDesc = await _apiService.fetchRoomDescription(
        buildingName: widget.buildingName,
        floorNumber: _selectedFloor?['Floor_Number']?.toString() ?? '',
        roomName: roomIdNoR,
      );
    } catch (e) {
      debugPrint(e.toString());
      roomDesc = '설명을 불러오지 못했습니다.';
    }
    
    debugPrint('⚠️ 호실 정보 없음, 기본 설명만 사용: $roomDesc');
    roomUsers = [];
    userPhones = null;
    userEmails = null;
  }

  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => RoomInfoSheet(
      roomInfo: RoomInfo(
        id: roomId,
        name: roomIdNoR,
        desc: roomDesc,
        users: roomUsers,
        phones: userPhones,
        emails: userEmails,
      ),
      onDeparture: () => _setPoint('start', roomId),
      onArrival: () => _setPoint('end', roomId),
      buildingName: widget.buildingName,
      floorNumber: _selectedFloor?['Floor_Number'],
    ),
  );

  if (mounted) setState(() => _selectedRoomId = null);
}

List<String> _parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value
        .where((item) => item != null && item.toString().trim().isNotEmpty)
        .map((item) => item.toString().trim())
        .toList();
  }
  return [];
}

// 🔥 서버에서 호실 데이터를 찾는 메서드 추가
Future<Map<String, dynamic>?> _findRoomDataFromServer({
  required String buildingName,
  required String floorNumber,
  required String roomName,
}) async {
  try {
    debugPrint('🔍 호실 검색: $buildingName $floorNumber층 $roomName호');
    
    // 🔥 실제 작동하는 API 메서드 사용
    final List<Map<String, dynamic>> allRooms = await _apiService.fetchAllRooms();
    
    debugPrint('📊 전체 호실 수: ${allRooms.length}개');
    
    // 🔥 해당 호실 찾기
    for (final room in allRooms) {
      final roomBuildingName = room['Building_Name']?.toString() ?? '';
      final roomFloorNumber = room['Floor_Number']?.toString() ?? '';
      final roomRoomName = room['Room_Name']?.toString() ?? '';
      
      debugPrint('🏠 비교: $roomBuildingName vs $buildingName, $roomFloorNumber vs $floorNumber, $roomRoomName vs $roomName');
      
      if (roomBuildingName == buildingName &&
          roomFloorNumber == floorNumber &&
          roomRoomName == roomName) {
        debugPrint('✅ 호실 찾음!');
        debugPrint('   설명: ${room['Room_Description']}');
        debugPrint('   담당자: ${room['Room_User']}');
        debugPrint('   전화: ${room['User_Phone']}');
        debugPrint('   이메일: ${room['User_Email']}');
        return room;
      }
    }
    
    debugPrint('❌ 호실을 찾지 못함: $buildingName $floorNumber층 $roomName호');
    return null;
    
  } catch (e) {
    debugPrint('❌ _findRoomDataFromServer 오류: $e');
    return null;
  }
}

List<String>? _parseStringListNullable(dynamic value) {
  if (value == null) return null;
  if (value is List) {
    final filtered = value
        .where((item) => item != null && item.toString().trim().isNotEmpty)
        .map((item) => item.toString().trim())
        .toList();
    return filtered.isEmpty ? null : filtered;
  }
  return null;
}

  void _showNavigationRoomSheet(BuildContext context, String roomId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '네비게이션 진행 중',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '현재 ${widget.isArrivalNavigation ? "목적지" : "출발지"} 건물의 실내 안내를 진행중입니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _completeNavigation();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('목적지 도착'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('계속 진행'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _completeNavigation() {
    if (widget.navigationController != null) {
      widget.navigationController!.proceedToNextStep();
    }
    Navigator.of(context).pop('completed');
  }

  void _showAndFadePrompt() {
    setState(() => _showTransitionPrompt = true);
    _promptTimer?.cancel();
    _promptTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showTransitionPrompt = false);
    });
  }

  void _clearAllPathInfo() {
    setState(() {
      _startPoint = null;
      _endPoint = null;
      _departurePath = [];
      _arrivalPath = [];
      _currentShortestPath = [];
      _navigationPath = [];
      _transitionInfo = null;
      _selectedRoomId = null;
    });

    _transformationController.value = Matrix4.identity();

    debugPrint('🧹 모든 경로 정보가 초기화되었습니다');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('경로가 초기화되었습니다'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.grey,
      ),
    );
  }

  String _getNavigationStartLabel() {
    if (widget.isArrivalNavigation) {
      return '건물 입구';
    } else {
      return '현재 위치';
    }
  }

  String _getNavigationEndLabel() {
    if (widget.isArrivalNavigation) {
      if (widget.targetRoomId != null) {
        final floorText = widget.targetFloorNumber != null 
            ? '${widget.targetFloorNumber}층 ' 
            : '';
        return '${floorText}${widget.targetRoomId}호';
      }
      return '목적지';
    } else {
      return '건물 출구';
    }
  }

  Widget _buildNavigationPointInfo(String title, String label, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
  // 9/10 계속...

  Widget _buildBodyContent() {
    if (_isFloorListLoading)
      return const Center(child: Text('층 목록을 불러오는 중...'));
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }
    if (_isMapLoading) return const Center(child: CircularProgressIndicator());
    if (_svgUrl == null) return const Center(child: Text('층을 선택해주세요.'));
    return _buildMapView();
  }

  Widget _buildMapView() {
    const double svgWidth = 210, svgHeight = 297;

    return LayoutBuilder(
      builder: (context, constraints) {
        final baseScale = min(
          constraints.maxWidth / svgWidth,
          constraints.maxHeight / svgHeight,
        );
        final totalScale = baseScale * 1.0;
        final svgDisplayWidth = svgWidth * totalScale * svgScale;
        final svgDisplayHeight = svgHeight * totalScale * svgScale;
        final leftOffset = (constraints.maxWidth - svgDisplayWidth) / 2;
        final topOffset = (constraints.maxHeight - svgDisplayHeight) / 2;

        return InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.5,
          maxScale: 4.0,
          onInteractionEnd: (details) => _resetScaleAfterDelay(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (TapDownDetails details) {
              final Offset scenePoint = _transformationController.toScene(
                details.localPosition,
              );
              final Offset svgTapPosition = Offset(
                (scenePoint.dx - leftOffset) / (totalScale * svgScale),
                (scenePoint.dy - topOffset) / (totalScale * svgScale),
              );

              for (var button in _buttonData.reversed) {
                bool isHit = false;
                if (button['type'] == 'path') {
                  isHit = (button['path'] as Path).contains(svgTapPosition);
                } else {
                  isHit = (button['rect'] as Rect).contains(svgTapPosition);
                }
                if (isHit) {
                  _showRoomInfoSheet(context, button['id']);
                  break;
                }
              }
            },
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: leftOffset,
                    top: topOffset,
                    child: SvgPicture.network(
                      _svgUrl!,
                      width: svgDisplayWidth,
                      height: svgDisplayHeight,
                      placeholderBuilder: (context) => Container(
                        width: svgDisplayWidth,
                        height: svgDisplayHeight,
                        color: Colors.grey.shade100,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                color: Colors.indigo,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '지도를 불러오는 중...',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (_currentShortestPath.isNotEmpty || _navigationPath.isNotEmpty)
                    Positioned(
                      left: leftOffset,
                      top: topOffset,
                      child: IgnorePointer(
                        child: CustomPaint(
                          size: Size(svgDisplayWidth, svgDisplayHeight),
                          painter: PathPainter(
                            pathPoints: _navigationPath.isNotEmpty
                                ? _navigationPath
                                : _currentShortestPath,
                            scale: totalScale * svgScale,
                            pathColor: _isNavigationMode ? Colors.blue : null,
                          ),
                        ),
                      ),
                    ),

                  if (_selectedRoomId != null)
                    ..._buttonData
                        .where((button) => button['id'] == _selectedRoomId)
                        .map((button) {
                          final Rect bounds = button['type'] == 'path'
                              ? (button['path'] as Path).getBounds()
                              : button['rect'];
                          final scaledRect = Rect.fromLTWH(
                            leftOffset + bounds.left * totalScale * svgScale,
                            topOffset + bounds.top * totalScale * svgScale,
                            bounds.width * totalScale * svgScale,
                            bounds.height * totalScale * svgScale,
                          );

                          return Positioned.fromRect(
                            rect: scaledRect,
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: RoomShapePainter(
                                  isSelected: true,
                                  shape: button['path'] ?? button['rect'],
                                ),
                                size: scaledRect.size,
                              ),
                            ),
                          );
                        })
                        .toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 🔥 디버그 정보 표시 위젯
  /// 🔥 강화된 디버깅 정보 표시 위젯
Widget _buildDebugInfo() {
  return Container(
    constraints: const BoxConstraints(maxWidth: 350, maxHeight: 500),
    child: Card(
      color: Colors.black.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Row(
              children: [
                const Icon(Icons.bug_report, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                Text(
                  '실시간 디버깅',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                // 새로고침 버튼
                GestureDetector(
                  onTap: () {
                    if (widget.navigationNodeIds != null) {
                      _displayNavigationPath(widget.navigationNodeIds!);
                    }
                  },
                  child: const Icon(Icons.refresh, color: Colors.blue, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // 기본 상태 정보
            Text(
              _debugInfo,
              style: TextStyle(
                color: _matchedNodes.length == widget.navigationNodeIds?.length 
                    ? Colors.green 
                    : Colors.orange, 
                fontSize: 12
              ),
            ),
            
            // 📊 통계 정보
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📊 변환 통계',
                    style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• 입력 노드: ${widget.navigationNodeIds?.length ?? 0}개',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    '• 성공: ${_matchedNodes.length}개',
                    style: const TextStyle(color: Colors.green, fontSize: 10),
                  ),
                  Text(
                    '• 실패: ${_failedNodes.length}개',
                    style: const TextStyle(color: Colors.red, fontSize: 10),
                  ),
                  Text(
                    '• 표시 좌표: ${_navigationPath.length}개',
                    style: const TextStyle(color: Colors.yellow, fontSize: 10),
                  ),
                ],
              ),
            ),
            
            // ✅ 성공한 노드들
            if (_matchedNodes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '✅ 성공한 노드들:',
                style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                constraints: const BoxConstraints(maxHeight: 80),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _matchedNodes.take(8).map((node) => Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 2),
                      child: Text(
                        '• $node',
                        style: const TextStyle(color: Colors.white, fontSize: 9),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )).toList(),
                  ),
                ),
              ),
              if (_matchedNodes.length > 8)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '... 외 ${_matchedNodes.length - 8}개',
                    style: const TextStyle(color: Colors.grey, fontSize: 9),
                  ),
                ),
            ],
            
            // ❌ 실패한 노드들
            if (_failedNodes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '❌ 실패한 노드들:',
                style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                constraints: const BoxConstraints(maxHeight: 60),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _failedNodes.take(5).map((node) => Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 2),
                      child: Text(
                        '• $node',
                        style: const TextStyle(color: Colors.red, fontSize: 9),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )).toList(),
                  ),
                ),
              ),
              if (_failedNodes.length > 5)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '... 외 ${_failedNodes.length - 5}개',
                    style: const TextStyle(color: Colors.grey, fontSize: 9),
                  ),
                ),
            ],
            
            // 🔍 현재 층 정보
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔍 현재 층 정보',
                    style: const TextStyle(color: Colors.purple, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• 층: ${_selectedFloor?['Floor_Number'] ?? 'N/A'}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    '• 버튼 개수: ${_buttonData.length}개',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


// 🔥 추가: 노드 매칭 실시간 테스트 메서드
void _testNodeMatching() {
  if (widget.navigationNodeIds == null || widget.navigationNodeIds!.isEmpty) {
    debugPrint('⚠️ 테스트할 노드가 없습니다');
    return;
  }
  
  debugPrint('🧪 === 노드 매칭 테스트 시작 ===');
  
  final currentFloorNum = _selectedFloor?['Floor_Number'].toString() ?? '1';
  Map<String, Map<String, Offset>> floorNodesMap = {};
  
  _loadNodesForFloor(currentFloorNum, floorNodesMap).then((_) {
    final nodeMap = floorNodesMap[currentFloorNum];
    if (nodeMap == null) {
      debugPrint('❌ 노드 맵이 없습니다');
      return;
    }
    
    debugPrint('🗺️ 사용 가능한 노드들 (처음 20개):');
    debugPrint('   ${nodeMap.keys.take(20).join(', ')}');
    
    for (String nodeId in widget.navigationNodeIds!) {
      debugPrint('🔍 테스트 노드: $nodeId');
      
      List<String> candidates = _generateSearchCandidates(nodeId);
      debugPrint('   후보들: ${candidates.join(', ')}');
      
      bool found = false;
      for (String candidate in candidates) {
        if (nodeMap.containsKey(candidate)) {
          debugPrint('   ✅ 매칭됨: $candidate -> ${nodeMap[candidate]}');
          found = true;
          break;
        }
      }
      
      if (!found) {
        debugPrint('   ❌ 매칭 실패');
        List<String> similar = _findSimilarNodes(nodeId, nodeMap);
        if (similar.isNotEmpty) {
          debugPrint('   💡 유사한 노드들: ${similar.join(', ')}');
        }
      }
    }
    
    debugPrint('🧪 === 노드 매칭 테스트 완료 ===');
  });
}

/// 🔥 API 응답 검증 및 상세 로깅
void _validateApiResponse(List<String> nodeIds) {
  debugPrint('🔍 === API 응답 검증 시작 ===');
  debugPrint('🔍 받은 노드 ID들: ${nodeIds.join(', ')}');
  
  // 1. 노드 ID 패턴 분석
  for (String nodeId in nodeIds) {
    debugPrint('📝 노드 분석: $nodeId');
    debugPrint('   - 길이: ${nodeId.length}');
    debugPrint('   - @ 포함: ${nodeId.contains('@')}');
    debugPrint('   - R 시작: ${nodeId.startsWith('R')}');
    debugPrint('   - 숫자만: ${nodeId.replaceAll(RegExp(r'[^0-9]'), '')}');
    
    if (nodeId.contains('@')) {
      List<String> parts = nodeId.split('@');
      debugPrint('   - @ 앞부분: ${parts[0]}');
      debugPrint('   - @ 뒷부분: ${parts.length > 1 ? parts[1] : 'N/A'}');
    }
  }
  
  // 2. 노드 연속성 확인
  _checkNodeSequence(nodeIds);
  
  // 3. 층 정보 일관성 확인
  _checkFloorConsistency(nodeIds);
  
  debugPrint('🔍 === API 응답 검증 완료 ===');
}



/// 노드 시퀀스 분석
void _checkNodeSequence(List<String> nodeIds) {
  debugPrint('🔗 노드 시퀀스 분석:');
  
  for (int i = 0; i < nodeIds.length - 1; i++) {
    String current = nodeIds[i];
    String next = nodeIds[i + 1];
    
    // 층 변경 감지
    String currentFloor = current.contains('@') ? current.split('@')[1] : '?';
    String nextFloor = next.contains('@') ? next.split('@')[1] : '?';
    
    if (currentFloor != nextFloor) {
      debugPrint('   🔄 층 변경 감지: $current ($currentFloor층) -> $next ($nextFloor층)');
    } else {
      debugPrint('   ➡️ 동일 층 이동: $current -> $next');
    }
  }
}

/// 층 정보 일관성 확인
void _checkFloorConsistency(List<String> nodeIds) {
  final Map<String, List<String>> floorNodes = {};
  
  for (String nodeId in nodeIds) {
    if (nodeId.contains('@')) {
      String floor = nodeId.split('@')[1];
      if (!floorNodes.containsKey(floor)) {
        floorNodes[floor] = [];
      }
      floorNodes[floor]!.add(nodeId);
    }
  }
  
  debugPrint('🏢 층별 노드 분포:');
  floorNodes.forEach((floor, nodes) {
    debugPrint('   $floor층: ${nodes.length}개 노드 (${nodes.join(', ')})');
  });
}

/// 🔥 SVG 노드 매핑 상태 실시간 확인
Future<void> _diagnoseSvgNodeMapping() async {
  debugPrint('🩺 === SVG 노드 매핑 진단 시작 ===');
  
  final currentFloorNum = _selectedFloor?['Floor_Number'].toString() ?? '1';
  Map<String, Map<String, Offset>> floorNodesMap = {};
  
  await _loadNodesForFloor(currentFloorNum, floorNodesMap);
  
  final nodeMap = floorNodesMap[currentFloorNum];
  if (nodeMap == null) {
    debugPrint('❌ SVG 노드 맵이 null입니다');
    return;
  }
  
  debugPrint('🗺️ SVG에서 파싱된 노드 정보:');
  debugPrint('   총 노드 개수: ${nodeMap.length}개');
  
  // 노드 타입별 분류
  final Map<String, List<String>> nodeTypes = {
    '3자리숫자': [],
    '2자리숫자': [],
    'R+숫자': [],
    '특수패턴': [],
    '기타': [],
  };
  
  for (String nodeId in nodeMap.keys) {
    if (RegExp(r'^\d{3}$').hasMatch(nodeId)) {
      nodeTypes['3자리숫자']!.add(nodeId);
    } else if (RegExp(r'^\d{2}$').hasMatch(nodeId)) {
      nodeTypes['2자리숫자']!.add(nodeId);
    } else if (RegExp(r'^R\d+$').hasMatch(nodeId)) {
      nodeTypes['R+숫자']!.add(nodeId);
    } else if (RegExp(r'^[a-zA-Z]\d+$').hasMatch(nodeId)) {
      nodeTypes['특수패턴']!.add(nodeId);
    } else {
      nodeTypes['기타']!.add(nodeId);
    }
  }
  
  nodeTypes.forEach((type, nodes) {
    if (nodes.isNotEmpty) {
      debugPrint('   $type: ${nodes.length}개 (${nodes.take(5).join(', ')}${nodes.length > 5 ? '...' : ''})');
    }
  });
  
  // API 노드와 매칭 테스트
  if (widget.navigationNodeIds != null) {
    debugPrint('🔄 API 노드와 SVG 노드 매칭 테스트:');
    for (String apiNode in widget.navigationNodeIds!) {
      List<String> candidates = _generateSearchCandidates(apiNode);
      List<String> found = candidates.where((c) => nodeMap.containsKey(c)).toList();
      
      if (found.isNotEmpty) {
        debugPrint('   ✅ $apiNode -> 매칭됨: ${found.first}');
      } else {
        debugPrint('   ❌ $apiNode -> 매칭 실패');
        debugPrint('      시도한 후보들: ${candidates.join(', ')}');
      }
    }
  }
  
  debugPrint('🩺 === SVG 노드 매핑 진단 완료 ===');
}

/// 🔥 경로 표시 상태 실시간 모니터링
void _monitorPathDisplayStatus() {
  debugPrint('📊 === 경로 표시 상태 모니터링 ===');
  debugPrint('   네비게이션 모드: $_isNavigationMode');
  debugPrint('   네비게이션 경로: ${_navigationPath.length}개 좌표');
  debugPrint('   현재 경로: ${_currentShortestPath.length}개 좌표');
  debugPrint('   선택된 층: ${_selectedFloor?['Floor_Number']}');
  debugPrint('   버튼 데이터: ${_buttonData.length}개');
  
  if (_navigationPath.isNotEmpty) {
    debugPrint('   첫 번째 좌표: ${_navigationPath.first}');
    debugPrint('   마지막 좌표: ${_navigationPath.last}');
    
    // 좌표 유효성 검사
    bool hasInvalidCoords = _navigationPath.any((coord) => 
      coord.dx.isNaN || coord.dy.isNaN || coord.dx.isInfinite || coord.dy.isInfinite);
    
    if (hasInvalidCoords) {
      debugPrint('   ⚠️ 유효하지 않은 좌표 발견!');
    } else {
      debugPrint('   ✅ 모든 좌표가 유효함');
    }
  }
  
  debugPrint('📊 === 모니터링 완료 ===');
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const Spacer(),
                if (_shouldAutoSelectRoom)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_autoSelectRoomId} 검색 중',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          Expanded(
            child: Stack(
              children: [
                _buildBodyContent(),
                
                if (!_isFloorListLoading && _error == null && _floorList.length > 1)
                  Positioned(
                    left: 16,
                    bottom: 100,
                    child: _buildFloorSelector(),
                  ),
                
                if (_showTransitionPrompt)
                  _buildTransitionPrompt(),

                // 🔥 우측 상단 - 디버그 정보 표시
                if (_isNavigationMode && (_matchedNodes.isNotEmpty || _failedNodes.isNotEmpty))
                  Positioned(
                    right: 16,
                    top: 16,
                    child: _buildDebugInfo(),
                  ),
              ],
            ),
          ),
          
          if (!_isFloorListLoading && _error == null)
            Container(
              margin: const EdgeInsets.all(16),
              child: _buildPathInfo(),
            ),
        ],
      ),
    );
  }
  // 10/10 마지막...

  Widget _buildFloorSelector() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Column(
          children: _floorList.reversed.map((floor) {
            final bool isSelected =
                _selectedFloor?['Floor_Id'] == floor['Floor_Id'];
            return GestureDetector(
              onTap: () => _onFloorChanged(floor),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (_isNavigationMode
                            ? Colors.blue.withOpacity(0.8)
                            : Colors.indigo.withOpacity(0.8))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${floor['Floor_Number']}F',
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTransitionPrompt() {
    String? promptText;
    if (_transitionInfo != null &&
        _selectedFloor?['Floor_Number'].toString() ==
            _transitionInfo!['from']) {
      promptText = '${_transitionInfo!['to']}층으로 이동하세요';
    }

    return AnimatedOpacity(
      opacity: _showTransitionPrompt && promptText != null ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: IgnorePointer(
        child: Positioned(
          bottom: 200,
          left: 0,
          right: 0,
          child: Center(
            child: Card(
              color: Colors.redAccent,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Text(
                  promptText ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPathInfo() {
    if (_isNavigationMode) {
      return Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavigationPointInfo(
                "출발", 
                _getNavigationStartLabel(), 
                Colors.green
              ),
              const Icon(Icons.arrow_forward_rounded, color: Colors.grey),
              _buildNavigationPointInfo(
                "도착", 
                _getNavigationEndLabel(), 
                Colors.blue
              ),
            ],
          ),
        ),
      );
    }
    
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildPointInfo("출발", _startPoint?['roomId'], Colors.green),
            const Icon(Icons.arrow_forward_rounded, color: Colors.grey),
            _buildPointInfo("도착", _endPoint?['roomId'], Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildPointInfo(String title, String? id, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          id ?? '미지정',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _resetScaleAfterDelay({int duration = 3000}) {
    _resetTimer?.cancel();
    _resetTimer = Timer(Duration(milliseconds: duration), () {
      if (mounted) {
        _transformationController.value = Matrix4.identity();
      }
    });
  }

  @override
  void didUpdateWidget(covariant BuildingMapPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.navigationNodeIds != null &&
        widget.navigationNodeIds != oldWidget.navigationNodeIds &&
        widget.navigationNodeIds!.isNotEmpty) {
      final firstNode = widget.navigationNodeIds!.firstWhere(
        (id) => id.contains('@'),
        orElse: () => '',
      );
      final floorNum = firstNode.split('@').length >= 2
          ? firstNode.split('@')[1]
          : '1';

      _loadFloorList(widget.buildingName, targetFloorNumber: floorNum);
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _resetTimer?.cancel();
    _promptTimer?.cancel();
    super.dispose();
  }
}