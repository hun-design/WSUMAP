// lib/timetable/timetable_storage_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'timetable_item.dart';

/// 시간표 데이터를 로컬에 저장하고 불러오는 서비스
class TimetableStorageService {
  static const String _storageKey = 'timetable_data';
  static const String _lastSyncKey = 'timetable_last_sync';
  
  /// 시간표 데이터를 로컬에 저장
  static Future<void> saveTimetableData(String userId, List<ScheduleItem> items) async {
    try {
      debugPrint('💾 시간표 데이터 로컬 저장 시작: ${items.length}개');
      
      final prefs = await SharedPreferences.getInstance();
      
      // 사용자별 키 생성
      final userKey = '${_storageKey}_$userId';
      final syncKey = '${_lastSyncKey}_$userId';
      
      // ScheduleItem 리스트를 JSON 문자열로 변환
      final jsonList = items.map((item) => item.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      
      // 로컬 저장소에 저장
      await prefs.setString(userKey, jsonString);
      await prefs.setString(syncKey, DateTime.now().toIso8601String());
      
      debugPrint('✅ 시간표 데이터 로컬 저장 완료');
    } catch (e) {
      debugPrint('❌ 시간표 데이터 로컬 저장 실패: $e');
    }
  }
  
  /// 시간표 데이터를 로컬에서 불러오기
  static Future<List<ScheduleItem>> loadTimetableData(String userId) async {
    try {
      debugPrint('📂 시간표 데이터 로컬 로드 시작');
      
      final prefs = await SharedPreferences.getInstance();
      final userKey = '${_storageKey}_$userId';
      
      final jsonString = prefs.getString(userKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        debugPrint('📂 로컬에 저장된 시간표 데이터 없음');
        return [];
      }
      
      // JSON 문자열을 ScheduleItem 리스트로 변환
      final jsonList = jsonDecode(jsonString) as List;
      final items = jsonList.map((json) => ScheduleItem.fromJson(json)).toList();
      
      debugPrint('✅ 시간표 데이터 로컬 로드 완료: ${items.length}개');
      return items;
    } catch (e) {
      debugPrint('❌ 시간표 데이터 로컬 로드 실패: $e');
      return [];
    }
  }
  
  /// 마지막 동기화 시간 가져오기
  static Future<DateTime?> getLastSyncTime(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final syncKey = '${_lastSyncKey}_$userId';
      
      final syncString = prefs.getString(syncKey);
      if (syncString == null || syncString.isEmpty) {
        return null;
      }
      
      return DateTime.parse(syncString);
    } catch (e) {
      debugPrint('❌ 마지막 동기화 시간 조회 실패: $e');
      return null;
    }
  }
  
  /// 로컬 시간표 데이터 삭제
  static Future<void> clearTimetableData(String userId) async {
    try {
      debugPrint('🗑️ 시간표 데이터 로컬 삭제 시작');
      
      final prefs = await SharedPreferences.getInstance();
      final userKey = '${_storageKey}_$userId';
      final syncKey = '${_lastSyncKey}_$userId';
      
      await prefs.remove(userKey);
      await prefs.remove(syncKey);
      
      debugPrint('✅ 시간표 데이터 로컬 삭제 완료');
    } catch (e) {
      debugPrint('❌ 시간표 데이터 로컬 삭제 실패: $e');
    }
  }
  
  /// 로컬에 저장된 시간표 데이터가 있는지 확인
  static Future<bool> hasLocalTimetableData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = '${_storageKey}_$userId';
      
      final jsonString = prefs.getString(userKey);
      return jsonString != null && jsonString.isNotEmpty;
    } catch (e) {
      debugPrint('❌ 로컬 시간표 데이터 존재 여부 확인 실패: $e');
      return false;
    }
  }
  
  /// 특정 시간표 항목을 로컬에서 삭제
  static Future<void> removeTimetableItem(String userId, ScheduleItem item) async {
    try {
      debugPrint('🗑️ 시간표 항목 로컬 삭제 시작: ${item.title}');
      
      final items = await loadTimetableData(userId);
      items.removeWhere((existingItem) => 
        existingItem.title == item.title && 
        existingItem.dayOfWeek == item.dayOfWeek &&
        existingItem.startTime == item.startTime &&
        existingItem.endTime == item.endTime
      );
      
      await saveTimetableData(userId, items);
      debugPrint('✅ 시간표 항목 로컬 삭제 완료');
    } catch (e) {
      debugPrint('❌ 시간표 항목 로컬 삭제 실패: $e');
    }
  }
  
  /// 특정 시간표 항목을 로컬에서 업데이트
  static Future<void> updateTimetableItem(String userId, ScheduleItem oldItem, ScheduleItem newItem) async {
    try {
      debugPrint('📝 시간표 항목 로컬 업데이트 시작: ${oldItem.title} -> ${newItem.title}');
      
      final items = await loadTimetableData(userId);
      
      // 기존 항목 찾아서 교체
      for (int i = 0; i < items.length; i++) {
        if (items[i].title == oldItem.title && 
            items[i].dayOfWeek == oldItem.dayOfWeek &&
            items[i].startTime == oldItem.startTime &&
            items[i].endTime == oldItem.endTime) {
          items[i] = newItem;
          break;
        }
      }
      
      await saveTimetableData(userId, items);
      debugPrint('✅ 시간표 항목 로컬 업데이트 완료');
    } catch (e) {
      debugPrint('❌ 시간표 항목 로컬 업데이트 실패: $e');
    }
  }
}
