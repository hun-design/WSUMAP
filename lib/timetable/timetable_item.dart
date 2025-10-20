// lib/timetable/timetable_item.dart - 최적화된 버전

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 서버와 주고받는 시간표 데이터 모델
class ScheduleItem {
  final String? id;
  final String title;
  final String professor;
  final String buildingName;
  final String floorNumber;
  final String roomName;
  final int dayOfWeek; // 1~5 (월~금)
  final String startTime;
  final String endTime;
  final Color color;
  final String memo;

  const ScheduleItem({
    this.id,
    required this.title,
    required this.professor,
    required this.buildingName,
    required this.floorNumber,
    required this.roomName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.memo = '',
  });

  /// int(1~5) → 영어 요일 변환
  String get dayOfWeekText {
    const days = ['', 'mon', 'tue', 'wed', 'thu', 'fri'];
    return (dayOfWeek >= 1 && dayOfWeek <= 5) ? days[dayOfWeek] : '';
  }

  /// 서버에서 받은 JSON을 ScheduleItem 객체로 변환
  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id']?.toString(),
      title: json['title'] ?? '',
      professor: json['professor'] ?? '',
      buildingName: json['building_name'] ?? '',
      floorNumber: json['floor_number'] ?? '',
      roomName: json['room_name'] ?? '',
      dayOfWeek: _dayOfWeekInt(json['day_of_week']),
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      color: _parseColor(json['color']),
      memo: json['memo'] ?? '',
    );
  }

  /// 한글 요일 → int 변환 함수
  static int _dayOfWeekInt(dynamic value) {
    if (value is int) return value;
    if (value is! String) return 0;
    
    const dayMap = {
      'mon': 1,
      'tue': 2,
      'wed': 3,
      'thu': 4,
      'fri': 5,
    };
    
    if (dayMap.containsKey(value)) {
      return dayMap[value]!;
    }
    
    final parsed = int.tryParse(value);
    return parsed ?? 0;
  }

  /// 색상 파싱 함수
  static Color _parseColor(dynamic value) {
    if (value == null) return const Color(0xFF3B82F6);
    
    try {
      if (value is String) {
        if (value.startsWith('FF')) {
          return Color(int.parse(value, radix: 16));
        } else if (value.startsWith('#')) {
          return Color(int.parse(value.substring(1), radix: 16));
        } else {
          return Color(int.parse('FF$value', radix: 16));
        }
      } else if (value is int) {
        return Color(value);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('색상 파싱 오류: $value, $e');
      }
    }
    
    return const Color(0xFF3B82F6);
  }

  /// ScheduleItem 객체를 서버로 보낼 JSON으로 변환
  Map<String, dynamic> toJson() {
    final map = {
      'title': title,
      'professor': professor,
      'building_name': buildingName,
      'floor_number': floorNumber,
      'room_name': roomName,
      'day_of_week': dayOfWeekText,
      'start_time': startTime,
      'end_time': endTime,
      'color': color.value.toRadixString(16),
      'memo': memo,
    };
    
    if (id != null) {
      map['id'] = id!;
    }
    
    return map;
  }

  /// copyWith 메서드 추가
  ScheduleItem copyWith({
    String? id,
    String? title,
    String? professor,
    String? buildingName,
    String? floorNumber,
    String? roomName,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    Color? color,
    String? memo,
  }) {
    return ScheduleItem(
      id: id ?? this.id,
      title: title ?? this.title,
      professor: professor ?? this.professor,
      buildingName: buildingName ?? this.buildingName,
      floorNumber: floorNumber ?? this.floorNumber,
      roomName: roomName ?? this.roomName,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      memo: memo ?? this.memo,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          professor == other.professor &&
          buildingName == other.buildingName &&
          floorNumber == other.floorNumber &&
          roomName == other.roomName &&
          dayOfWeek == other.dayOfWeek &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          color == other.color &&
          memo == other.memo;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      professor.hashCode ^
      buildingName.hashCode ^
      floorNumber.hashCode ^
      roomName.hashCode ^
      dayOfWeek.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      color.hashCode ^
      memo.hashCode;

  @override
  String toString() {
    return 'ScheduleItem(id: $id, title: $title, dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime)';
  }
}
