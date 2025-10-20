// lib/timetable/color_mapping_service.dart - 최적화된 버전

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'timetable_item.dart';

/// 수업 이름별 색상 매핑을 관리하는 서비스
class ColorMappingService {
  static final Map<String, Color> _subjectColorMap = {};
  static int _colorIndex = 0;
  
  // 사용 가능한 색상 팔레트
  static const List<Color> _colorPalette = [
    Color(0xFF3B82F6), // 파란색
    Color(0xFF10B981), // 초록색
    Color(0xFFEF4444), // 빨간색
    Color(0xFF8B5CF6), // 보라색
    Color(0xFFF59E0B), // 주황색
    Color(0xFF06B6D4), // 청록색
    Color(0xFFEC4899), // 분홍색
    Color(0xFF84CC16), // 라임색
    Color(0xFF6366F1), // 인디고색
    Color(0xFF14B8A6), // 틸색
    Color(0xFFDC2626), // 진한 빨간색
    Color(0xFF7C3AED), // 진한 보라색
    Color(0xFF059669), // 진한 초록색
    Color(0xFFDB2777), // 진한 분홍색
    Color(0xFF0891B2), // 진한 청록색
  ];

  /// 수업 이름에 따라 색상을 할당하거나 기존 색상을 반환
  static Color getColorForSubject(String subjectName) {
    if (subjectName.isEmpty) {
      return _colorPalette[0];
    }

    // 이미 매핑된 색상이 있으면 반환
    if (_subjectColorMap.containsKey(subjectName)) {
      return _subjectColorMap[subjectName]!;
    }

    // 새로운 색상 할당
    final usedColors = _subjectColorMap.values.toSet();
    Color selectedColor = _colorPalette[0];
    
    // 사용되지 않은 색상 찾기
    for (final color in _colorPalette) {
      if (!usedColors.contains(color)) {
        selectedColor = color;
        break;
      }
    }
    
    // 모든 색상이 사용된 경우 순환 할당
    if (usedColors.contains(selectedColor)) {
      selectedColor = _colorPalette[_colorIndex % _colorPalette.length];
      _colorIndex++;
    }
    
    _subjectColorMap[subjectName] = selectedColor;
    
    if (kDebugMode) {
      debugPrint('🎨 색상 할당: "$subjectName" → ${selectedColor.value.toRadixString(16)}');
    }
    
    return selectedColor;
  }

  /// 시간표 아이템 리스트에 색상을 자동 할당
  static List<ScheduleItem> assignColorsToScheduleItems(List<ScheduleItem> items) {
    final Map<String, List<ScheduleItem>> subjectGroups = {};
    
    // 수업 이름별로 그룹화
    for (final item in items) {
      subjectGroups.putIfAbsent(item.title, () => []).add(item);
    }

    // 각 그룹에 동일한 색상 할당
    final List<ScheduleItem> updatedItems = [];
    for (final entry in subjectGroups.entries) {
      final subjectName = entry.key;
      final subjectItems = entry.value;
      final assignedColor = getColorForSubject(subjectName);

      // 각 아이템에 색상 할당
      for (final item in subjectItems) {
        updatedItems.add(item.copyWith(color: assignedColor));
      }
    }

    return updatedItems;
  }

  /// 특정 수업 이름의 색상을 변경하고 관련된 모든 아이템 업데이트
  static List<ScheduleItem> updateColorForSubject(
    String subjectName, 
    Color newColor, 
    List<ScheduleItem> items
  ) {
    _subjectColorMap[subjectName] = newColor;
    
    return items.map((item) {
      if (item.title == subjectName) {
        return item.copyWith(color: newColor);
      }
      return item;
    }).toList();
  }

  /// 색상 매핑 초기화
  static void clearColorMapping() {
    if (kDebugMode) {
      debugPrint('🎨 색상 매핑 초기화');
    }
    _subjectColorMap.clear();
    _colorIndex = 0;
  }

  /// 현재 색상 매핑 상태 반환 (디버깅용)
  static Map<String, Color> getColorMapping() {
    return Map.from(_subjectColorMap);
  }

  /// 사용 가능한 색상 팔레트 반환
  static List<Color> getAvailableColors() {
    return List.from(_colorPalette);
  }

  /// 특정 수업의 색상 정보 반환
  static Color? getSubjectColor(String subjectName) {
    return _subjectColorMap[subjectName];
  }

  /// 수업 이름이 색상 매핑에 있는지 확인
  static bool hasSubjectColor(String subjectName) {
    return _subjectColorMap.containsKey(subjectName);
  }

  /// 색상 매핑 통계 반환
  static Map<String, dynamic> getColorMappingStats() {
    return {
      'totalSubjects': _subjectColorMap.length,
      'usedColors': _subjectColorMap.values.toSet().length,
      'availableColors': _colorPalette.length,
      'colorIndex': _colorIndex,
    };
  }
}
