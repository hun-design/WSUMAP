import 'dart:convert';
import 'package:flutter_application_1/config/api_config.dart';
import 'package:flutter_application_1/services/api_helper.dart';

/// 서버와 통신하는 API 서비스 클래스
class ApiService {
  final String _baseUrl = ApiConfig.pathBase;

  /// 서버에서 건물 목록을 받아오는 함수
  Future<List<String>> fetchBuildingList() async {
    // GET /buildings 요청
    final response = await ApiHelper.get('$_baseUrl/buildings');
    if (response.statusCode == 200) {
      // 서버 응답을 디코딩하여 buildingList 추출
      final data = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> buildingList = data['buildings'];
      return buildingList.cast<String>();
    } else {
      throw Exception('Failed to load building list from server');
    }
  }

  /// 특정 건물의 층 목록을 받아오는 함수
  Future<List<dynamic>> fetchFloorList(String buildingName) async {
    // GET /floor/{buildingName} 요청
    final response = await ApiHelper.get('$_baseUrl/floor/$buildingName');
    if (response.statusCode == 200) {
      // 서버 응답을 디코딩하여 floorList 추출
      final List<dynamic> floorList = json.decode(utf8.decode(response.bodyBytes));
      return floorList;
    } else {
      throw Exception('Failed to load floor list for $buildingName');
    }
  }

  /// 길찾기(경로 탐색) 요청 함수
  Future<Map<String, dynamic>> findPath({
    required String fromBuilding,
    int? fromFloor,
    String? fromRoom,
    required String toBuilding,
    int? toFloor,
    String? toRoom,
  }) async {
    // POST /path 요청 (JSON body 포함)
    final response = await ApiHelper.post(
      '$_baseUrl/path',
      body: {
        'from_building': fromBuilding,
        'from_floor': fromFloor,
        'from_room': fromRoom,
        'to_building': toBuilding,
        'to_floor': toFloor,
        'to_room': toRoom,
      },
    );
    if (response.statusCode == 200) {
      // 서버 응답을 디코딩하여 반환
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to find path');
    }
  }

  /// GET 방식으로 방(강의실) 설명을 받아오는 함수
  /// buildingName: 건물 이름
  /// floorNumber: 층 번호 (String, 예: '4')
  /// roomName: 방 이름 (예: '401')
  Future<String> fetchRoomDescription({
    required String buildingName,
    required String floorNumber,
    required String roomName,
  }) async {
    // GET /room/desc/{buildingName}/{floorNumber}/{roomName} 요청
    // buildingName, roomName에 한글/특수문자 있을 수 있으니 encodeComponent로 인코딩
    final response = await ApiHelper.get('$_baseUrl/room/desc/${Uri.encodeComponent(buildingName)}/$floorNumber/${Uri.encodeComponent(roomName)}');
    if (response.statusCode == 200) {
      // 서버 응답에서 Room_Description 추출
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data['Room_Description'] ?? '설명 없음';
    } else if (response.statusCode == 404) {
      return '설명 없음';
    } else {
      throw Exception('방 설명을 불러오지 못했습니다.');
    }
  }

  /// 🔥 모든 호실 목록을 받아오는 함수
  Future<List<Map<String, dynamic>>> fetchAllRooms() async {
    try {
      print('📞 API 호출: fetchAllRooms()');
      final response = await ApiHelper.get('$_baseUrl/Room');
      
      print('📡 응답 상태 코드: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> roomList = json.decode(utf8.decode(response.bodyBytes));
        print('✅ 전체 호실 수: ${roomList.length}개');
        
        // 첫 번째 호실 데이터 구조 확인
        if (roomList.isNotEmpty) {
          print('🏠 첫 번째 호실 예시: ${roomList[0]}');
        }
        
        return roomList.cast<Map<String, dynamic>>();
      } else {
        print('❌ API 오류 - 상태코드: ${response.statusCode}');
        throw Exception('Failed to load room list from server');
      }
    } catch (e) {
      print('❌ fetchAllRooms 오류: $e');
      throw e;
    }
  }

  /// 🔥 특정 건물의 호실 목록을 받아오는 함수
  Future<List<Map<String, dynamic>>> fetchRoomsByBuilding(String buildingName) async {
    try {
      print('📞 API 호출: fetchRoomsByBuilding("$buildingName")');
      final allRooms = await fetchAllRooms();
      
      // 특정 건물의 호실만 필터링
      final buildingRooms = allRooms.where((room) {
        final roomBuildingName = room['Building_Name'] as String?;
        return roomBuildingName != null && 
               roomBuildingName.toLowerCase() == buildingName.toLowerCase();
      }).toList();
      
      print('🏢 $buildingName 호실 수: ${buildingRooms.length}개');
      
      return buildingRooms;
    } catch (e) {
      print('❌ fetchRoomsByBuilding 오류: $e');
      throw e;
    }
  }
}