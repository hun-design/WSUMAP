import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'timetable_item.dart';
import 'package:flutter_application_1/config/api_config.dart';
import 'package:uuid/uuid.dart';
import 'color_mapping_service.dart';

class TimetableApiService {
  static String get timetableBase => ApiConfig.timetableBase;
  static String get floorBase => ApiConfig.floorBase;
  static String get roomBase => ApiConfig.roomBase;

  /// 시간표 전체 조회
  Future<List<ScheduleItem>> fetchScheduleItems(String userId) async {
    // 🔥 게스트 사용자는 시간표 요청 차단
    if (userId.startsWith('guest_')) {
      debugPrint('🚫 게스트 사용자는 시간표 요청이 차단됩니다: $userId');
      return [];
    }

    final url = '$timetableBase/$userId';
    debugPrint('🔄 시간표 조회 요청 URL: $url');
    
    try {
      final res = await http.get(Uri.parse(url));
      debugPrint('📡 서버 응답 상태 코드: ${res.statusCode}');
      debugPrint('📡 서버 응답 본문: ${res.body}');
      
      if (res.statusCode != 200) {
        debugPrint('❌ 시간표 조회 실패: ${res.statusCode}');
        throw Exception('시간표 조회 실패 (${res.statusCode})');
      }
      
      final List data = jsonDecode(res.body);
      debugPrint('📊 파싱된 데이터 개수: ${data.length}');

      // 서버에서 오는 데이터 구조에 맞게 파싱
      final uuid = Uuid();
      final items = data.map((e) {
        // 서버에서 오는 데이터 필드명에 맞게 매핑
        final mappedData = {
          'id': e['id'] ?? uuid.v4(),
          'title': e['title'] ?? e['subject'] ?? '',
          'professor': e['professor'] ?? e['teacher'] ?? '',
          'building_name': e['building_name'] ?? e['building'] ?? '',
          'floor_number': e['floor_number'] ?? e['floor'] ?? '',
          'room_name': e['room_name'] ?? e['room'] ?? '',
          'day_of_week': e['day_of_week'] ?? e['day'] ?? '',
          'start_time': e['start_time'] ?? e['start'] ?? '',
          'end_time': e['end_time'] ?? e['end'] ?? '',
          'color': e['color'] ?? 'FF3B82F6', // 기본 파란색
          'memo': e['memo'] ?? e['note'] ?? '',
        };
        
        debugPrint('📝 매핑된 데이터: $mappedData');
        return ScheduleItem.fromJson(mappedData);
      }).toList();
      
      // 수업 이름별로 색상 자동 할당
      final itemsWithColors = ColorMappingService.assignColorsToScheduleItems(items);
      
      debugPrint('✅ 시간표 항목 변환 완료: ${itemsWithColors.length}개');
      debugPrint('🎨 색상 매핑 상태: ${ColorMappingService.getColorMapping()}');
      debugPrint('📊 색상 매핑 통계: ${ColorMappingService.getColorMappingStats()}');
      return itemsWithColors;
    } catch (e) {
      debugPrint('❌ 시간표 조회 중 오류 발생: $e');
      rethrow;
    }
  }

  /// 시간표 항목 추가
  Future<void> addScheduleItem(ScheduleItem item, String userId) async {
    // 🔥 게스트 사용자는 시간표 추가 차단
    if (userId.startsWith('guest_')) {
      debugPrint('🚫 게스트 사용자는 시간표 추가가 차단됩니다: $userId');
      return;
    }

    try {
      debugPrint('📤 시간표 추가 요청 시작');
      debugPrint('📤 URL: $timetableBase/$userId');
      debugPrint('📤 요청 데이터: ${item.toJson()}');

      final res = await http.post(
        Uri.parse('$timetableBase/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item.toJson()),
      ).timeout(const Duration(seconds: 10));

      debugPrint('📥 시간표 추가 응답 상태: ${res.statusCode}');
      debugPrint('📥 시간표 추가 응답 내용: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        debugPrint('✅ 시간표 추가 성공');
      } else {
        debugPrint('❌ 시간표 추가 실패: ${res.statusCode}');
        throw Exception('시간표 추가 실패 (${res.statusCode}): ${res.body}');
      }
    } catch (e) {
      debugPrint('❌ 시간표 추가 중 오류: $e');
      if (e.toString().contains('timeout')) {
        throw Exception('서버 응답 시간이 초과되었습니다.');
      }
      rethrow;
    }
  }

  /// 시간표 항목 수정
  Future<void> updateScheduleItem({
    required String userId,
    required String originTitle,
    required String originDayOfWeek,
    required ScheduleItem newItem,
  }) async {
    // 🔥 게스트 사용자는 시간표 수정 차단
    if (userId.startsWith('guest_')) {
      debugPrint('🚫 게스트 사용자는 시간표 수정이 차단됩니다: $userId');
      return;
    }

    final res = await http.put(
      Uri.parse('$timetableBase/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "origin_title": originTitle,
        "origin_day_of_week": originDayOfWeek,
        "new_title": newItem.title,
        "new_day_of_week": newItem.dayOfWeekText,
        "start_time": newItem.startTime,
        "end_time": newItem.endTime,
        "building_name": newItem.buildingName,
        "floor_number": newItem.floorNumber,
        "room_name": newItem.roomName,
        "professor": newItem.professor,
        "color": newItem.color.value.toRadixString(16),
        "memo": newItem.memo,
      }),
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('시간표 수정 실패');
    }
  }

  /// 시간표 항목 삭제
  Future<void> deleteScheduleItem({
    required String userId,
    required String title,
    required String dayOfWeek,
  }) async {
    // 🔥 게스트 사용자는 시간표 삭제 차단
    if (userId.startsWith('guest_')) {
      debugPrint('🚫 게스트 사용자는 시간표 삭제가 차단됩니다: $userId');
      return;
    }

    final res = await http.delete(
      Uri.parse('$timetableBase/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'day_of_week': dayOfWeek}),
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('시간표 삭제 실패');
    }
  }

  /// 건물에 해당하는 층 조회 - (GET /floor/names/:building) 서버 구조에 100% 맞춤
  Future<List<String>> fetchFloors(String building) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.floorBase}/names/$building'),
    );
    debugPrint('층수 응답 status: ${res.statusCode}, body: ${res.body}');
    if (res.statusCode != 200) throw Exception('층수 조회 실패');
    final arr = jsonDecode(res.body) as List;
    debugPrint('층수 파싱 결과: $arr');
    return arr.map((e) => e['Floor_Number'].toString()).toList();
  }

  /// 건물+층에 해당하는 강의실 조회 - (GET /room/:building/:floor) 서버 구조에 100% 맞춤
  Future<List<String>> fetchRooms(String building, String floor) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.roomBase}/$building/$floor'),
    );
    if (res.statusCode != 200) throw Exception('강의실 조회 실패');
    final arr = jsonDecode(res.body) as List;
    return arr.map((e) => e['Room_Name'].toString()).toList();
  }
}
