// lib/inside/svg_data_parser.dart - 수정된 버전

import 'dart:ui';
import 'package:xml/xml.dart';
import 'package:path_drawing/path_drawing.dart';

class SvgDataParser {
  static List<Map<String, dynamic>> parseButtonData(String svgContent) {
    final List<Map<String, dynamic>> buttons = [];
    final document = XmlDocument.parse(svgContent);

    // 1. <rect> 태그 파싱
    final rects = document.findAllElements('rect');
    for (var rect in rects) {
      String? id =
          rect.getAttribute('inkscape:label') ?? rect.getAttribute('id');
      if (id != null && (id.startsWith('R') || int.tryParse(id) != null)) {
        final x = double.tryParse(rect.getAttribute('x') ?? '');
        final y = double.tryParse(rect.getAttribute('y') ?? '');
        final width = double.tryParse(rect.getAttribute('width') ?? '');
        final height = double.tryParse(rect.getAttribute('height') ?? '');
        if (x != null && y != null && width != null && height != null) {
          buttons.add({
            'id': id,
            'type': 'rect',
            'rect': Rect.fromLTWH(x, y, width, height),
          });
        }
      }
    }

    // 2. <path> 태그 파싱
    final paths = document.findAllElements('path');
    for (var pathElement in paths) {
      String? id =
          pathElement.getAttribute('inkscape:label') ??
          pathElement.getAttribute('id');
      final dAttribute = pathElement.getAttribute('d');
      if (id != null && id.startsWith('R') && dAttribute != null) {
        try {
          final Path path = parseSvgPathData(dAttribute);
          buttons.add({'id': id, 'type': 'path', 'path': path});
        } catch (e) {
          print("SVG Path 파싱 중 오류 발생 (ID: $id): $e");
        }
      }
    }
    return buttons;
  }

  /// 🔥 카테고리 요소들 파싱 (새로 추가)
  static List<Map<String, dynamic>> parseCategoryData(String svgContent) {
    final List<Map<String, dynamic>> categories = [];
    final document = XmlDocument.parse(svgContent);

    try {
      // Category 그룹 찾기
      final categoryGroups = document.findAllElements('g').where((g) {
        final id = g.getAttribute('id');
        return id != null && id.toLowerCase().contains('category');
      });

      for (var categoryGroup in categoryGroups) {
        print('🔍 Category 그룹 발견: ${categoryGroup.getAttribute('id')}');

        // Category 그룹 안의 rect 요소들 찾기
        final rects = categoryGroup.findAllElements('rect');
        for (var rect in rects) {
          String? id = rect.getAttribute('id');
          if (id != null && id.isNotEmpty) {
            final x = double.tryParse(rect.getAttribute('x') ?? '');
            final y = double.tryParse(rect.getAttribute('y') ?? '');
            final width = double.tryParse(rect.getAttribute('width') ?? '');
            final height = double.tryParse(rect.getAttribute('height') ?? '');

            if (x != null && y != null && width != null && height != null) {
              // 카테고리 ID에서 숫자 부분 제거 (예: water_purifier-2 -> water_purifier)
              final cleanId = _cleanCategoryId(id);

              categories.add({
                'id': id,
                'category': cleanId,
                'type': 'rect',
                'rect': Rect.fromLTWH(x, y, width, height),
              });

              print('✅ 카테고리 요소 발견: $id -> $cleanId');
            }
          }
        }
      }

      print('🎯 카테고리 파싱 완료: ${categories.length}개');
    } catch (e) {
      print('❌ 카테고리 파싱 오류: $e');
    }

    return categories;
  }

  /// 🔥 카테고리 ID 정리 (숫자 부분 제거)
  static String _cleanCategoryId(String id) {
    // "-숫자" 패턴 제거
    final regex = RegExp(r'^(.+?)-\d+$');
    final match = regex.firstMatch(id);
    if (match != null) {
      return match.group(1) ?? id;
    }
    return id;
  }

  /// 🔥 완전히 새로 작성한 노드 파싱 함수 - 가상 노드 제거
  static Map<String, Offset> parseAllNodes(String svgContent) {
    final Map<String, Offset> nodes = {};

    try {
      final document = XmlDocument.parse(svgContent);
      print('🔍 강화된 SVG 노드 파싱 시작');

      final allElements = document.descendants.whereType<XmlElement>().toList();
      print('📊 전체 XML 요소 개수: ${allElements.length}');

      // 🔥 모든 가능한 속성에서 ID 추출
      final allFoundIds = <String>[];
      final processedNodes = <String, Offset>{};

      for (var element in allElements) {
        // 🔥 다양한 방법으로 ID 추출
        List<String> possibleIds = _extractAllPossibleIds(element);

        for (String id in possibleIds) {
          if (id.isEmpty || processedNodes.containsKey(id)) continue;

          // 🔥 더 관대한 노드 인식
          if (_isAnyValidNode(id)) {
            allFoundIds.add(id);

            Offset? offset = _extractOffsetFromAnyElement(element);
            if (offset != null) {
              processedNodes[id] = offset;
              _addNodeWithVariants(nodes, id, offset);
              print('✅ 노드 발견: $id -> $offset');
            }
          }
        }
      }

      print('✅ 강화된 노드 파싱 완료: ${nodes.length}개');

      // 🔥 상세한 노드 분류 출력
      _printDetailedNodeAnalysis(nodes);
    } catch (e) {
      print('❌ SVG 노드 파싱 오류: $e');
    }

    return nodes;
  }

  /// 🔥 요소에서 모든 가능한 ID 추출 (강화)
  static List<String> _extractAllPossibleIds(XmlElement element) {
    final ids = <String>[];

    // 1. 기본 속성들
    final attributes = [
      'inkscape:label',
      'id',
      'name',
      'class',
      'data-name',
      'data-id',
      'title',
    ];

    for (String attr in attributes) {
      String? value = element.getAttribute(attr);
      if (value != null && value.trim().isNotEmpty) {
        ids.add(value.trim());
      }
    }

    // 2. 텍스트 콘텐츠
    if (element.name.local == 'text' || element.name.local == 'tspan') {
      String? textContent = element.innerText.trim();
      if (textContent != null && textContent.isNotEmpty) {
        ids.add(textContent);

        // 텍스트에서 여러 단어 분리
        List<String> words = textContent.split(RegExp(r'\s+'));
        for (String word in words) {
          if (word.trim().isNotEmpty) {
            ids.add(word.trim());
          }
        }
      }
    }

    // 3. style 속성에서 ID 추출 (혹시 주석 형태로 있을 수 있음)
    String? style = element.getAttribute('style');
    if (style != null) {
      // /* node-id: b10 */ 같은 패턴
      RegExp commentPattern = RegExp(r'/\*.*?([a-zA-Z0-9\-_]+).*?\*/');
      Iterable<RegExpMatch> matches = commentPattern.allMatches(style);
      for (RegExpMatch match in matches) {
        String? commentId = match.group(1);
        if (commentId != null) {
          ids.add(commentId);
        }
      }
    }

    // 4. 모든 속성 값에서 패턴 매칭
    for (var attr in element.attributes) {
      String value = attr.value;

      // b숫자, entrance, stairs 패턴 찾기 - 개선된 패턴
      RegExp patterns = RegExp(
        r'\b(b\d+|entrance|enterence|stairs?|staircase|stairway|steps?|elevator|indoor|outdoor)\b',
        caseSensitive: false,
      );
      Iterable<RegExpMatch> matches = patterns.allMatches(value);
      for (RegExpMatch match in matches) {
        String? patternId = match.group(1);
        if (patternId != null) {
          ids.add(patternId);
        }
      }
    }

    return ids.toSet().toList(); // 중복 제거
  }

  /// 🔥 더 관대한 노드 인식 (기존보다 포용적)
  static bool _isAnyValidNode(String id) {
    if (id.isEmpty || id.length > 50) return false;

    // 🔥 복도 노드 (b + 숫자)
    if (RegExp(r'^b\d+$', caseSensitive: false).hasMatch(id)) {
      print('🚶 복도 노드 인식: $id');
      return true;
    }

    // 🔥 호실 번호들
    if (RegExp(r'^\d{2,3}$').hasMatch(id)) return true;
    if (RegExp(r'^R\d{2,3}$', caseSensitive: false).hasMatch(id)) return true;

    // 🔥 입구/출구 (철자 실수도 포함)
    if (RegExp(
      r'(entrance|enterence|entry|exit|door)',
      caseSensitive: false,
    ).hasMatch(id)) {
      print('🚪 입구/출구 노드 인식: $id');
      return true;
    }

    // 🔥 계단 (다양한 형태) - 개선된 패턴
    if (RegExp(
      r'(stair|step|계단|staircase|stairway|steps)',
      caseSensitive: false,
    ).hasMatch(id)) {
      print('🏢 계단 노드 인식: $id');
      return true;
    }

    // 🔥 실내/실외 구분
    if (RegExp(
      r'(indoor|outdoor|inside|outside)',
      caseSensitive: false,
    ).hasMatch(id)) {
      print('🏠 실내/실외 노드 인식: $id');
      return true;
    }

    // 🔥 엘리베이터
    if (RegExp(r'(elevator|lift|엘리베이터)', caseSensitive: false).hasMatch(id)) {
      print('🛗 엘리베이터 노드 인식: $id');
      return true;
    }

    // 🔥 하이픈이 포함된 복합 노드 (indoor-right-stairs 등)
    if (RegExp(
      r'^[a-zA-Z]+-[a-zA-Z]+-[a-zA-Z]+$',
      caseSensitive: false,
    ).hasMatch(id)) {
      print('🔗 복합 노드 인식: $id');
      return true;
    }

    // 🔥 @ 포함 패턴
    if (id.contains('@')) {
      String baseId = id.split('@')[0];
      return _isAnyValidNode(baseId);
    }

    // 🔥 특수 문자가 포함된 패턴도 허용 (-, _, 공백)
    if (RegExp(r'^[a-zA-Z0-9\-_\s]+$').hasMatch(id) && id.length >= 2) {
      // 최소한 글자나 숫자가 포함되어야 함
      if (RegExp(r'[a-zA-Z0-9]').hasMatch(id)) {
        print('🔤 일반 노드 인식: $id');
        return true;
      }
    }

    return false;
  }

  /// 🔥 모든 요소 타입에서 좌표 추출 (강화)
  static Offset? _extractOffsetFromAnyElement(XmlElement element) {
    try {
      switch (element.name.local) {
        case 'rect':
          return _extractRectOffset(element);
        case 'circle':
          return _extractCircleOffset(element);
        case 'ellipse':
          return _extractEllipseOffset(element);
        case 'path':
          return _extractPathOffset(element);
        case 'text':
        case 'tspan':
          return _extractTextOffset(element);
        case 'g': // 그룹 요소
          return _extractGroupOffset(element);
        case 'use': // 재사용 요소
          return _extractUseOffset(element);
        case 'image':
          return _extractImageOffset(element);
        case 'polygon':
        case 'polyline':
          return _extractPolygonOffset(element);
        case 'line':
          return _extractLineOffset(element);
        default:
          // 알려지지 않은 요소도 시도
          return _extractGenericOffset(element);
      }
    } catch (e) {
      print('❌ 좌표 추출 오류 (${element.name.local}): $e');
      return null;
    }
  }

  /// 각 요소 타입별 좌표 추출 메서드들
  static Offset? _extractRectOffset(XmlElement element) {
    final x = double.tryParse(element.getAttribute('x') ?? '');
    final y = double.tryParse(element.getAttribute('y') ?? '');
    final width = double.tryParse(element.getAttribute('width') ?? '');
    final height = double.tryParse(element.getAttribute('height') ?? '');

    if (x != null && y != null && width != null && height != null) {
      return Offset(x + width / 2, y + height / 2);
    }
    return null;
  }

  static Offset? _extractCircleOffset(XmlElement element) {
    final cx = double.tryParse(element.getAttribute('cx') ?? '');
    final cy = double.tryParse(element.getAttribute('cy') ?? '');
    if (cx != null && cy != null) {
      return Offset(cx, cy);
    }
    return null;
  }

  static Offset? _extractEllipseOffset(XmlElement element) {
    final cx = double.tryParse(element.getAttribute('cx') ?? '');
    final cy = double.tryParse(element.getAttribute('cy') ?? '');
    if (cx != null && cy != null) {
      return Offset(cx, cy);
    }
    return null;
  }

  static Offset? _extractPathOffset(XmlElement element) {
    final d = element.getAttribute('d');
    if (d != null && d.isNotEmpty) {
      return _extractPathCenter(d);
    }
    return null;
  }

  static Offset? _extractTextOffset(XmlElement element) {
    final x = double.tryParse(element.getAttribute('x') ?? '');
    final y = double.tryParse(element.getAttribute('y') ?? '');
    if (x != null && y != null) {
      return Offset(x, y);
    }
    return null;
  }

  static Offset? _extractGroupOffset(XmlElement element) {
    // 그룹의 transform 속성 확인
    final transform = element.getAttribute('transform');
    if (transform != null) {
      // translate(x,y) 패턴 추출
      RegExp translatePattern = RegExp(
        r'translate\(\s*([-+]?\d*\.?\d+)\s*,\s*([-+]?\d*\.?\d+)\s*\)',
      );
      RegExpMatch? match = translatePattern.firstMatch(transform);
      if (match != null) {
        final x = double.tryParse(match.group(1) ?? '');
        final y = double.tryParse(match.group(2) ?? '');
        if (x != null && y != null) {
          return Offset(x, y);
        }
      }
    }

    // 그룹 내 첫 번째 자식 요소의 위치 사용
    for (var child in element.children.whereType<XmlElement>()) {
      Offset? childOffset = _extractOffsetFromAnyElement(child);
      if (childOffset != null) {
        return childOffset;
      }
    }

    return null;
  }

  static Offset? _extractUseOffset(XmlElement element) {
    final x = double.tryParse(element.getAttribute('x') ?? '');
    final y = double.tryParse(element.getAttribute('y') ?? '');
    if (x != null && y != null) {
      return Offset(x, y);
    }
    return null;
  }

  static Offset? _extractImageOffset(XmlElement element) {
    final x = double.tryParse(element.getAttribute('x') ?? '');
    final y = double.tryParse(element.getAttribute('y') ?? '');
    final width = double.tryParse(element.getAttribute('width') ?? '');
    final height = double.tryParse(element.getAttribute('height') ?? '');

    if (x != null && y != null && width != null && height != null) {
      return Offset(x + width / 2, y + height / 2);
    }
    return null;
  }

  static Offset? _extractPolygonOffset(XmlElement element) {
    final points = element.getAttribute('points');
    if (points != null && points.isNotEmpty) {
      // points="x1,y1 x2,y2 x3,y3" 형태 파싱
      List<String> coords = points.trim().split(RegExp(r'\s+'));
      if (coords.isNotEmpty) {
        List<String> firstPoint = coords.first.split(',');
        if (firstPoint.length >= 2) {
          final x = double.tryParse(firstPoint[0]);
          final y = double.tryParse(firstPoint[1]);
          if (x != null && y != null) {
            return Offset(x, y);
          }
        }
      }
    }
    return null;
  }

  static Offset? _extractLineOffset(XmlElement element) {
    final x1 = double.tryParse(element.getAttribute('x1') ?? '');
    final y1 = double.tryParse(element.getAttribute('y1') ?? '');
    final x2 = double.tryParse(element.getAttribute('x2') ?? '');
    final y2 = double.tryParse(element.getAttribute('y2') ?? '');

    if (x1 != null && y1 != null && x2 != null && y2 != null) {
      return Offset((x1 + x2) / 2, (y1 + y2) / 2); // 중점
    }
    return null;
  }

  static Offset? _extractGenericOffset(XmlElement element) {
    // 일반적인 x, y 속성 시도
    final x = double.tryParse(element.getAttribute('x') ?? '');
    final y = double.tryParse(element.getAttribute('y') ?? '');
    if (x != null && y != null) {
      return Offset(x, y);
    }

    // cx, cy 속성 시도
    final cx = double.tryParse(element.getAttribute('cx') ?? '');
    final cy = double.tryParse(element.getAttribute('cy') ?? '');
    if (cx != null && cy != null) {
      return Offset(cx, cy);
    }

    return null;
  }

  /// 🔥 상세한 노드 분석 출력
  static void _printDetailedNodeAnalysis(Map<String, Offset> nodes) {
    final nodeCategories = <String, List<String>>{
      '복도 노드 (b*)': [],
      '호실 노드': [],
      '입구/출구': [],
      '계단': [],
      '특수 시설': [],
      '기타': [],
    };

    for (String nodeId in nodes.keys) {
      if (RegExp(r'^b\d+$', caseSensitive: false).hasMatch(nodeId)) {
        nodeCategories['복도 노드 (b*)']!.add(nodeId);
      } else if (RegExp(r'^\d{2,3}$').hasMatch(nodeId) ||
          RegExp(r'^R\d{2,3}$').hasMatch(nodeId)) {
        nodeCategories['호실 노드']!.add(nodeId);
      } else if (RegExp(
        r'(entrance|enterence|entry|exit)',
        caseSensitive: false,
      ).hasMatch(nodeId)) {
        nodeCategories['입구/출구']!.add(nodeId);
      } else if (RegExp(
        r'(stair|step)',
        caseSensitive: false,
      ).hasMatch(nodeId)) {
        nodeCategories['계단']!.add(nodeId);
      } else if (RegExp(
        r'(elevator|indoor|outdoor)',
        caseSensitive: false,
      ).hasMatch(nodeId)) {
        nodeCategories['특수 시설']!.add(nodeId);
      } else {
        nodeCategories['기타']!.add(nodeId);
      }
    }

    print('📊 === 노드 분석 결과 ===');
    nodeCategories.forEach((category, nodeList) {
      if (nodeList.isNotEmpty) {
        print('$category (${nodeList.length}개): ${nodeList.join(', ')}');
      }
    });
  }

  /// Path에서 중심점 추출
  static Offset? _extractPathCenter(String pathData) {
    try {
      final Path path = parseSvgPathData(pathData);
      final bounds = path.getBounds();
      if (!bounds.isEmpty) {
        return bounds.center;
      }
    } catch (e) {
      print('❌ Path 중심점 추출 오류: $e');
    }

    return null;
  }

  /// 🔥 노드의 다양한 변형을 맵에 추가
  static void _addNodeWithVariants(
    Map<String, Offset> nodes,
    String originalId,
    Offset offset,
  ) {
    final variants = <String>{originalId}; // Set으로 중복 방지

    print('🔍 노드 추가: $originalId -> $offset');

    // 기본 ID
    variants.add(originalId);

    // R 접두사 처리
    String cleanId = originalId;
    if (cleanId.startsWith('R')) {
      cleanId = cleanId.substring(1);
      variants.add(cleanId);
    } else {
      variants.add('R$originalId');
    }

    // @ 기호 제거
    if (cleanId.contains('@')) {
      String baseId = cleanId.split('@')[0];
      variants.add(baseId);
      variants.add('R$baseId');
    }

    // 모든 변형을 맵에 추가
    for (String variant in variants) {
      nodes[variant] = offset;
      print('  ✅ 변형 추가: $variant');
    }
  }

  /// 특정 노드 ID로 좌표를 직접 찾는 메서드
  static Offset? findNodeById(String svgContent, String targetId) {
    final allNodes = parseAllNodes(svgContent);

    // 다양한 형태로 매칭 시도
    List<String> candidates = [
      targetId,
      targetId.startsWith('R') ? targetId.substring(1) : 'R$targetId',
      targetId.contains('@') ? targetId.split('@')[0] : targetId,
    ];

    // 🔥 계단 노드 특별 처리
    if (targetId == 'stairs') {
      candidates.addAll([
        'stair',
        '계단',
        'staircase',
        'stairway',
        'steps',
        'step',
      ]);
    }

    for (String candidate in candidates) {
      if (allNodes.containsKey(candidate)) {
        print('✅ 노드 찾기 성공: $targetId -> $candidate -> ${allNodes[candidate]}');
        return allNodes[candidate];
      }
    }

    print('❌ 노드 찾기 실패: $targetId');
    return null;
  }

  /// 디버깅용 노드 통계
  static Map<String, dynamic> getNodeStatistics(String svgContent) {
    final nodes = parseAllNodes(svgContent);
    final stats = <String, dynamic>{};

    stats['totalNodes'] = nodes.length;
    stats['nodeTypes'] = <String, int>{};

    // 노드 타입별 분류
    for (String nodeId in nodes.keys) {
      String type = 'unknown';

      if (RegExp(r'^\d{3}$').hasMatch(nodeId)) {
        type = 'room_3digit';
      } else if (RegExp(r'^\d{2}$').hasMatch(nodeId)) {
        type = 'room_2digit';
      } else if (nodeId.startsWith('R')) {
        type = 'room_with_R';
      } else if (nodeId.contains('@')) {
        type = 'floor_specific';
      } else if (RegExp(
        r'(stair|elevator)',
        caseSensitive: false,
      ).hasMatch(nodeId)) {
        type = 'facility';
      }

      stats['nodeTypes'][type] = (stats['nodeTypes'][type] ?? 0) + 1;
    }

    return stats;
  }
}
