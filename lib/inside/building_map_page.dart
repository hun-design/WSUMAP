// lib/page/building_map_page.dart - 완전한 전체 코드 1/10

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/generated/app_localizations.dart';
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
import '../data/category_fallback_data.dart'; // CategoryUtils를 위한 import
import '../utils/CategoryLocalization.dart'; // CategoryLocalization을 위한 import
import '../controllers/location_controllers.dart'; // 현재 위치 표시를 위한 import

class BuildingMapPage extends StatefulWidget {
  final String buildingName;
  final List<String>? navigationNodeIds;
  final bool isArrivalNavigation;
  final UnifiedNavigationController? navigationController;
  final String? targetRoomId;
  final int? targetFloorNumber;
  final String? locationType; // 출발지/도착지 설정용
  final String? initialCategory; // 🔥 초기 카테고리 설정용

  const BuildingMapPage({
    super.key,
    required this.buildingName,
    this.navigationNodeIds,
    this.isArrivalNavigation = false,
    this.navigationController,
    this.targetRoomId,
    this.targetFloorNumber,
    this.locationType, // 출발지/도착지 설정용
    this.initialCategory, // 🔥 초기 카테고리 설정용
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
  final TransformationController _transformationController =
      TransformationController();
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

  // 🔥 카테고리 필터링 관련 상태 변수들
  Set<String> _selectedCategories = {}; // 🔥 다중 선택을 위해 Set으로 변경
  List<Map<String, dynamic>> _categoryData = []; // 카테고리 데이터
  List<Map<String, dynamic>> _filteredCategoryData = []; // 필터링된 카테고리 데이터
  List<String> _availableCategories = [];
  bool _isCategoryFiltering = false;
  bool _showAllCategories = false; // 🔥 전체 카테고리 표시 여부

  // 🔥 디버그 정보 표시용 상태 변수들 - 초기값 설정
  String _debugInfo = '노드 매칭 대기 중...';
  final List<String> _matchedNodes = [];
  final List<String> _failedNodes = [];

  // 🔥 현재 위치 표시 관련 상태 변수들
  late LocationController _locationController;
  bool _showCurrentLocation = false;
  Offset? _currentLocationOffset;
  // 2/10 계속...

  @override
  void initState() {
    super.initState();
    _isNavigationMode = widget.navigationNodeIds != null;

    // 🔥 위치 컨트롤러 초기화
    _locationController = LocationController();

    // 검색 결과에서 온 경우 자동 선택 준비
    _shouldAutoSelectRoom = widget.targetRoomId != null;
    _autoSelectRoomId = widget.targetRoomId;

    // 🔥 초기 카테고리 설정
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      _selectedCategories.add(widget.initialCategory!);
      debugPrint('🔥 초기 카테고리 설정: ${widget.initialCategory}');
    }

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

  // 🔥 현재 위치 표시 메서드
  void _showCurrentLocationOnMap() async {
    try {
      await _locationController.requestCurrentLocation();

      // 현재 위치를 SVG 좌표로 변환 (간단한 예시)
      // 실제로는 건물의 실제 좌표와 SVG 좌표 간의 매핑이 필요
      if (_selectedFloor != null) {
        // 임시로 화면 중앙에 위치 표시
        final size = MediaQuery.of(context).size;
        _currentLocationOffset = Offset(size.width / 2, size.height / 2);
        _showCurrentLocation = true;
        setState(() {});
        debugPrint('✅ 실내 지도에서 현재 위치 표시 완료');
      }
    } catch (e) {
      debugPrint('❌ 실내 지도에서 현재 위치 표시 실패: $e');
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
    debugPrint(
      '   전체 노드 ID들: ${widget.navigationNodeIds?.join(', ') ?? 'null'}',
    );

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
        debugPrint(
          '✅ 경로 좌표들: ${pathOffsets.map((p) => '(${p.dx.toStringAsFixed(1)}, ${p.dy.toStringAsFixed(1)})').join(' -> ')}',
        );
      } else {
        debugPrint('❌ 네비게이션 경로 변환 실패 - 좌표를 찾을 수 없음');
      }
    } catch (e) {
      debugPrint('❌ 네비게이션 경로 표시 오류: $e');
    }
  }
  // 4/10 계속...

  // 🔥 강화된 노드 ID 변환 로직 - 디버그 정보 포함
  List<Offset> _convertNodeIdsToOffsets(
    List<String> nodeIds,
    String floorNum,
    Map<String, Map<String, Offset>> floorNodesMap,
  ) {
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
          debugPrint(
            '   사용 가능한 노드 중 유사한 것: ${_findSimilarNodes(nodeId, nodeMap)}',
          );
        }
      }

      _debugInfo = '노드 매칭: ${_matchedNodes.length}/${nodeIds.length} 성공';
      if (mounted) setState(() {});

      debugPrint('📊 === 노드 변환 완료 ===');
      debugPrint(
        '📊 성공: ${offsets.length}개, 실패: ${nodeIds.length - offsets.length}개',
      );

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
        debugPrint(
          '   ✅ 매칭 성공: $nodeId -> $candidate -> ${nodeMap[candidate]}',
        );
        return nodeMap[candidate];
      } else {
        debugPrint('   ❌ 후보 실패: $candidate');
      }
    }

    debugPrint('   💀 모든 후보 실패: $nodeId');

    // 🔍 디버깅: 유사한 노드들 찾기
    final similar = nodeMap.keys
        .where((key) {
          String target = nodeId.split('@').last.toLowerCase();
          return key.toLowerCase().contains(target) ||
              target.contains(key.toLowerCase());
        })
        .take(3)
        .toList();

    if (similar.isNotEmpty) {
      debugPrint('   💡 유사한 노드들: ${similar.join(', ')}');
    }

    return null;
  }

  /// 🔥 검색 후보 생성 - 명확하고 순서가 있는 로직
  /// 🔥 긴급 수정: API 노드 형태에 맞춘 검색 후보 생성
  /// 🔥 간단한 노드 매칭: @ 뒤의 마지막 부분만 추출
  /// 🔥 최종 수정: @ 구분자로 정확히 분할
  /// 🔥 계단 노드 매칭 개선
  List<String> _generateSearchCandidates(String nodeId) {
    final candidates = <String>[];

    debugPrint('🔍 후보 생성: $nodeId');

    // 1. 원본 그대로
    candidates.add(nodeId);

    // 2. 계단 노드 특별 처리
    if (nodeId == 'stairs') {
      // stairs 노드의 다양한 형태들을 시도
      candidates.addAll([
        'stairs',
        'stair',
        '계단',
        'staircase',
        'stairway',
        'steps',
        'step',
      ]);
      debugPrint('   🏢 계단 노드 후보들 추가');
    }

    // 3. @ 기호로 분할하여 각 부분 추출
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

        // 계단 노드인 경우 추가 후보들
        if (lastPart == 'stairs') {
          candidates.addAll([
            'stair',
            '계단',
            'staircase',
            'stairway',
            'steps',
            'step',
          ]);
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

  /// 🔥 유사한 노드 찾기 (디버깅용)
  List<String> _findSimilarNodes(String targetId, Map<String, Offset> nodeMap) {
    final target = targetId.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

    return nodeMap.keys
        .where((nodeId) {
          final node = nodeId.toLowerCase().replaceAll(
            RegExp(r'[^a-z0-9]'),
            '',
          );
          return node.contains(target) || target.contains(node);
        })
        .take(3)
        .toList();
  }

  void _onFloorChanged(Map<String, dynamic> newFloor) {
    final newFloorNumber = newFloor['Floor_Number'].toString();

    if (_selectedFloor?['Floor_Id'] == newFloor['Floor_Id'] && _error == null) {
      return;
    }

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
          
          // 🔥 게스트 사용자에게 더 친화적인 에러 메시지
          final errorMessage = e.toString();
          if (errorMessage.contains('인증') || errorMessage.contains('401') || errorMessage.contains('403')) {
            _error = '게스트 사용자는 건물 도면을 볼 수 없습니다.\n로그인 후 다시 시도해주세요.';
          } else {
            _error = '층 목록을 불러오는 데 실패했습니다.\n${e.toString().replaceAll('Exception: ', '')}';
          }
        });
      }
      
      if (kDebugMode) {
        debugPrint('❌ _loadFloorList 오류: $e');
      }
    }
  }

  Future<void> _loadMapData(Map<String, dynamic> floorInfo) async {
    setState(() => _isMapLoading = true);

    try {
      final svgUrl = floorInfo['File'] as String?;
      if (svgUrl == null || svgUrl.isEmpty) {
        throw Exception('SVG URL이 유효하지 않습니다.');
      }

      final svgResponse = await http
          .get(Uri.parse(svgUrl))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('SVG 로딩 시간 초과');
            },
          );

      if (svgResponse.statusCode != 200) {
        throw Exception('SVG 파일을 다운로드할 수 없습니다');
      }

      final svgContent = svgResponse.body;
      final buttons = SvgDataParser.parseButtonData(svgContent);
      final categories = SvgDataParser.parseCategoryData(
        svgContent,
      ); // 🔥 카테고리 데이터 로드

      if (mounted) {
        setState(() {
          _svgUrl = svgUrl;
          _buttonData = buttons;
          _categoryData = categories; // 🔥 카테고리 데이터 저장
          _isMapLoading = false;
        });

        // 🔥 카테고리 추출 및 필터링 초기화
        _extractCategoriesFromCategoryData();

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

  /// 🔥 카테고리 데이터에서 사용 가능한 카테고리 추출
  void _extractCategoriesFromCategoryData() {
    final categories = <String>{};
    for (final category in _categoryData) {
      final categoryName = category['category']?.toString() ?? '';
      if (categoryName.isNotEmpty) {
        categories.add(categoryName);
      }
    }

    // 메인과 동일하게 알파벳 순으로 정렬
    _availableCategories = categories.toList()..sort();
    debugPrint('🎯 사용 가능한 카테고리: $_availableCategories');
  }

  Future<void> _loadNodesForFloor(
    String floorNumber,
    Map<String, Map<String, Offset>> targetMap,
  ) async {
    if (targetMap.containsKey(floorNumber)) {
      debugPrint(
        '🔄 층 $floorNumber 노드는 이미 로드됨 (${targetMap[floorNumber]?.length}개)',
      );
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
      debugPrint(
        '사용 가능한 층들: ${_floorList.map((f) => f['Floor_Number'].toString()).toList()}',
      );
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('통합 길찾기 중 오류가 발생했습니다: $e')));
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
      final depNodeIds = UnifiedPathService.extractIndoorNodeIds(
        departureIndoor,
      );
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

  Future<void> _handleRoomToBuildingResponse(
    PathResult result,
    int fromFloor,
  ) async {
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

  Future<void> _handleBuildingToRoomResponse(
    PathResult result,
    int toFloor,
  ) async {
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

    final pathOffsets = _convertNodeIdsToOffsets(
      nodeIds,
      floorNumStr,
      floorNodesMap,
    );

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

      int splitIndex = nodeIds.indexWhere(
        (id) => id.split('@')[1] != fromFloorStr,
      );
      if (splitIndex == -1) splitIndex = nodeIds.length;

      final depOffsets = _convertNodeIdsToOffsets(
        nodeIds.sublist(0, splitIndex),
        fromFloorStr,
        floorNodesMap,
      );
      final arrOffsets = _convertNodeIdsToOffsets(
        nodeIds.sublist(splitIndex),
        toFloorStr,
        floorNodesMap,
      );

      setState(() {
        _departurePath = depOffsets;
        _arrivalPath = arrOffsets;
        _currentShortestPath =
            _selectedFloor?['Floor_Number'].toString() == fromFloorStr
            ? depOffsets
            : arrOffsets;
        _transitionInfo = {"from": fromFloorStr, "to": toFloorStr};
      });

      _showAndFadePrompt();
    } else {
      final sameFloorOffsets = _convertNodeIdsToOffsets(
        nodeIds,
        fromFloorStr,
        floorNodesMap,
      );
      setState(() => _currentShortestPath = sameFloorOffsets);
    }
  }

  void _showOutdoorTransitionMessage(OutdoorPathData outdoorData) {
    final coordinates = UnifiedPathService.extractOutdoorCoordinates(
      outdoorData,
    );
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
      final List<Map<String, dynamic>> allRooms = await _apiService
          .fetchAllRooms();

      debugPrint('📊 전체 호실 수: ${allRooms.length}개');

      // 🔥 해당 호실 찾기
      for (final room in allRooms) {
        final roomBuildingName = room['Building_Name']?.toString() ?? '';
        final roomFloorNumber = room['Floor_Number']?.toString() ?? '';
        final roomRoomName = room['Room_Name']?.toString() ?? '';

        debugPrint(
          '🏠 비교: $roomBuildingName vs $buildingName, $roomFloorNumber vs $floorNumber, $roomRoomName vs $roomName',
        );

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

  Widget _buildBodyContent() {
    if (_isFloorListLoading) {
      return const Center(child: Text('층 목록을 불러오는 중...'));
    }
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

              // 🔥 카테고리 필터링 중일 때는 카테고리 데이터만 체크
              if (_isCategoryFiltering && _selectedCategories.isNotEmpty) {
                for (var category in _filteredCategoryData.reversed) {
                  bool isHit = false;
                  if (category['type'] == 'rect') {
                    isHit = (category['rect'] as Rect).contains(svgTapPosition);
                  }
                  if (isHit) {
                    _showCategoryInfoSheet(context, category);
                    break;
                  }
                }
              } else {
                // 일반적인 버튼 데이터 체크
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

                  if (_currentShortestPath.isNotEmpty ||
                      _navigationPath.isNotEmpty)
                    Positioned(
                      left: leftOffset,
                      top: topOffset,
                      child: IgnorePointer(
                        child: CustomPaint(
                          size: Size(svgDisplayWidth, svgDisplayHeight),
                          painter: PathPainter(
                            context: context,
                            pathPoints: _navigationPath.isNotEmpty
                                ? _navigationPath
                                : _currentShortestPath,
                            scale: totalScale * svgScale,
                            pathColor: _isNavigationMode ? Colors.blue : null,
                          ),
                        ),
                      ),
                    ),

                  if (_selectedRoomId != null && !_isCategoryFiltering)
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
                        }),

                  // 🔥 카테고리 마커 표시 (다중 선택 지원)
                  if (_isCategoryFiltering && _selectedCategories.isNotEmpty)
                    ..._filteredCategoryData.map((category) {
                      final rect = category['rect'] as Rect;
                      final categoryName =
                          category['category']?.toString() ?? '';

                      // 🔥 마커 위치를 rect의 중심으로 설정
                      final centerX = rect.left + rect.width / 2;
                      final centerY = rect.top + rect.height / 2;
                      final markerSize = 7.0; // 🔥 마커 크기 아주 조금 더 줄임 (9 -> 7)

                      final scaledCenterX =
                          leftOffset + centerX * totalScale * svgScale;
                      final scaledCenterY =
                          topOffset + centerY * totalScale * svgScale;
                      final scaledMarkerSize =
                          markerSize * totalScale * svgScale;

                      final markerRect = Rect.fromCenter(
                        center: Offset(scaledCenterX, scaledCenterY),
                        width: scaledMarkerSize,
                        height: scaledMarkerSize,
                      );

                      return Positioned.fromRect(
                        rect: markerRect,
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getCategoryColor(
                                categoryName,
                              ), // 🔥 각 카테고리별 색상 사용
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 0.5, // 테두리 유지
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _getCategoryColor(
                                    categoryName,
                                  ).withOpacity(0.15), // 🔥 각 카테고리별 색상 사용
                                  blurRadius: 2,
                                  offset: const Offset(0, 0.5),
                                ),
                              ],
                            ),
                            child: Icon(
                              _getCategoryIcon(
                                categoryName,
                              ), // 🔥 각 카테고리별 아이콘 사용
                              color: Colors.white,
                              size: scaledMarkerSize * 0.7, // 아이콘 크기 유지
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        );
      },
    );
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
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black87,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: const EdgeInsets.all(12),
                  ),
                ),

                // 🔥 카테고리 필터링 버튼들을 뒤로가기 버튼 옆으로 이동
                if (!_isFloorListLoading &&
                    _error == null &&
                    _availableCategories.isNotEmpty)
                  Expanded(
                    child: Container(
                      height: 50,
                      margin: const EdgeInsets.only(left: 12, right: 12),
                      child: _buildCategoryChips(),
                    ),
                  ),

                // 자동선택 버튼을 더 작게 만들거나 조건부로 표시
                if (_shouldAutoSelectRoom)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$_autoSelectRoomId',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
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

                if (!_isFloorListLoading &&
                    _error == null &&
                    _floorList.length > 1)
                  Positioned(
                    left: 16,
                    bottom: 20,
                    child: _buildFloorSelector(),
                  ),

                if (_showTransitionPrompt) _buildTransitionPrompt(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 카테고리 칩 위젯 (컴팩트 버전)
Widget _buildCategoryChips() {
  final l10n = AppLocalizations.of(context)!;

  return ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: _availableCategories.length + 1, // +1 for "전체" 버튼
    itemBuilder: (context, index) {
      if (index == 0) {
        // "전체" 버튼
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: _buildCategoryChip(l10n.all, null, _showAllCategories),
        );
      } else {
        final category = _availableCategories[index - 1];
        final isSelected = _selectedCategories.contains(category);
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: _buildCategoryChip(
            _getCategoryDisplayName(category),
            category,
            isSelected,
          ),
        );
      }
    },
  );
}


  /// 🔥 카테고리 칩 (컴팩트 버전)
  Widget _buildCategoryChip(
    String displayName,
    String? category,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (category == null) {
            // 전체 버튼 클릭
            if (_showAllCategories ||
                _selectedCategories.length == _availableCategories.length) {
              // 전체가 이미 선택되어 있으면 모두 해제
              _selectedCategories.clear();
              _showAllCategories = false;
              _isCategoryFiltering = false;
              _filteredCategoryData.clear();
            } else {
              // 전체 선택
              _selectedCategories = _availableCategories.toSet();
              _showAllCategories = true;
              _isCategoryFiltering = true;
              _filteredCategoryData = _categoryData.where((cat) {
                final catName = cat['category']?.toString() ?? '';
                return _selectedCategories.contains(catName);
              }).toList();
            }
          } else {
            // 개별 카테고리 버튼 클릭
            if (_selectedCategories.contains(category)) {
              // 이미 선택된 카테고리 해제
              _selectedCategories.remove(category);
              _showAllCategories = false;
              _isCategoryFiltering = _selectedCategories.isNotEmpty;
              if (_selectedCategories.isEmpty) {
                _filteredCategoryData.clear();
              } else {
                _filteredCategoryData = _categoryData.where((cat) {
                  final catName = cat['category']?.toString() ?? '';
                  return _selectedCategories.contains(catName);
                }).toList();
              }
            } else {
              // 새로운 카테고리 추가
              _selectedCategories.add(category);
              _showAllCategories =
                  _selectedCategories.length == _availableCategories.length;
              _isCategoryFiltering = true;
              _filteredCategoryData = _categoryData.where((cat) {
                final catName = cat['category']?.toString() ?? '';
                return _selectedCategories.contains(catName);
              }).toList();
            }
          }
        });
        debugPrint(
          '🎯 카테고리 선택 변경: $_selectedCategories -> ${_filteredCategoryData.length}개 카테고리',
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1E3A8A)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1E3A8A).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 12,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 3),
            Text(
              displayName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 카테고리 표시 이름 가져오기 (메인 화면과 동일)
  String _getCategoryDisplayName(String? category) {
    if (category == null) return '전체';

    // bank를 atm으로 매핑 (SVG의 bank ID를 ATM으로 표시)
    final displayCategory = category == 'bank' ? 'atm' : category;

    // 메인 화면과 동일하게 CategoryLocalization 사용
    return CategoryLocalization.getLabel(context, displayCategory);
  }

  /// 🔥 카테고리 아이콘 가져오기 (메인 화면과 동일)
  IconData _getCategoryIcon(String? category) {
    if (category == null) return Icons.list;

    // bank를 atm으로 매핑 (SVG의 bank ID를 ATM으로 표시)
    final mappedCategory = category == 'bank' ? 'atm' : category;

    return CategoryFallbackData.getCategoryIcon(mappedCategory);
  }

  /// 🔥 카테고리 정보 시트 표시
  void _showCategoryInfoSheet(
    BuildContext context,
    Map<String, dynamic> categoryData,
  ) {
    final categoryName = categoryData['category']?.toString() ?? '알 수 없음';
    final categoryDesc = categoryData['description']?.toString() ?? '설명이 없습니다.';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 드래그 핸들
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(categoryName).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(categoryName),
                      color: _getCategoryColor(categoryName),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          CategoryLocalization.getLabel(context, categoryName),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          categoryName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 0.5),
            // 내용
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                categoryDesc,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 🔥 카테고리 색상 가져오기
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'cafe':
        return const Color(0xFF8B5CF6); // 보라색
      case 'restaurant':
        return const Color(0xFFEF4444); // 빨간색
      case 'convenience':
        return const Color(0xFF10B981); // 초록색
      case 'vending':
        return const Color(0xFFF59E0B); // 주황색
      case 'atm':
      case 'bank':
        return const Color(0xFF059669); // 진한 초록색
      case 'library':
        return const Color(0xFF3B82F6); // 파란색
      case 'fitness':
      case 'gym':
        return const Color(0xFFDC2626); // 진한 빨간색
      case 'lounge':
        return const Color(0xFF7C3AED); // 보라색
      case 'extinguisher':
      case 'fire_extinguisher':
        return const Color(0xFFEA580C); // 주황색
      case 'water':
      case 'water_purifier':
        return const Color(0xFF0891B2); // 청록색
      case 'bookstore':
        return const Color(0xFF059669); // 초록색
      case 'post':
        return const Color(0xFF7C2D12); // 갈색
      default:
        return const Color(0xFF1E3A8A); // Woosong Blue
    }
  }

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

    // 🔥 위치 컨트롤러 정리
    _locationController.dispose();

    super.dispose();
  }
}
