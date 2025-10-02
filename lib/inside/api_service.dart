import 'dart:convert';
import 'package:flutter_application_1/config/api_config.dart';
import 'package:flutter_application_1/services/api_helper.dart';

/// 서버와 통신하는 API 서비스 클래스
class ApiService {
  final String _baseUrl = ApiConfig.pathBase;

  /// 서버에서 건물 목록을 받아오는 함수
  /// 🔥 서버 라우트: GET /building/names (building-service)
  Future<List<String>> fetchBuildingList() async {
    try {
      final response = await ApiHelper.get('${ApiConfig.buildingBase}/names');
      if (response.statusCode == 200) {
        // 서버 응답을 디코딩하여 buildingList 추출
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        
        // 서버에서 [{Building_Name: '...'}, ...] 형식으로 반환
        return data.map((item) {
          if (item is Map<String, dynamic> && item.containsKey('Building_Name')) {
            return item['Building_Name'].toString();
          }
          return item.toString();
        }).toList();
      } else {
        throw Exception('Failed to load building list from server');
      }
    } catch (e) {
      print('❌ fetchBuildingList 오류: $e');
      rethrow;
    }
  }

  /// 특정 건물의 층 목록을 받아오는 함수 (전체 Floor 정보 포함)
  /// 🔥 서버 라우트: GET /floor/:building (building-service)
  /// 반환: [{Floor_Id, Floor_Number, Building_Name, File}, ...]
  Future<List<dynamic>> fetchFloorList(String buildingName) async {
    try {
      // URL 인코딩 적용
      final encodedBuildingName = Uri.encodeComponent(buildingName);
      // 🔥 전체 Floor 정보를 가져오기 위해 /floor/:building 엔드포인트 사용
      final response = await ApiHelper.get('${ApiConfig.floorBase}/$encodedBuildingName');
      
      if (response.statusCode == 200) {
        // 서버 응답을 디코딩하여 floorList 추출
        final List<dynamic> floorList = json.decode(utf8.decode(response.bodyBytes));
        
        // 🔥 전체 Floor 객체를 반환 (Floor_Id, Floor_Number, Building_Name, File 포함)
        return floorList.map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          }
          return item;
        }).toList();
      } else {
        throw Exception('Failed to load floor list for $buildingName');
      }
    } catch (e) {
      print('❌ fetchFloorList 오류: $e');
      rethrow;
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
  /// 🔥 서버 라우트: GET /room/desc/:building/:floor/:room (building-service)
  /// buildingName: 건물 이름
  /// floorNumber: 층 번호 (String, 예: '4')
  /// roomName: 방 이름 (예: '401')
  Future<String> fetchRoomDescription({
    required String buildingName,
    required String floorNumber,
    required String roomName,
  }) async {
    try {
      // buildingName, roomName에 한글/특수문자 있을 수 있으니 encodeComponent로 인코딩
      final response = await ApiHelper.get(
        '${ApiConfig.roomBase}/desc/${Uri.encodeComponent(buildingName)}/$floorNumber/${Uri.encodeComponent(roomName)}'
      );
      
      if (response.statusCode == 200) {
        // 서버 응답에서 Room_Description 추출
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['Room_Description'] ?? '설명 없음';
      } else if (response.statusCode == 404) {
        return '설명 없음';
      } else {
        throw Exception('방 설명을 불러오지 못했습니다.');
      }
    } catch (e) {
      print('❌ fetchRoomDescription 오류: $e');
      return '설명 없음';
    }
  }

  /// 🔥 모든 호실 목록을 받아오는 함수
  /// 🔥 서버 라우트: GET /room (building-service)
  Future<List<Map<String, dynamic>>> fetchAllRooms() async {
    try {
      print('📞 API 호출: fetchAllRooms()');
      // 🔥 서버 라우트에 맞게 수정: /room (소문자)
      final response = await ApiHelper.get('${ApiConfig.roomBase}');
      
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
      rethrow;
    }
  }

  /// 🔥 특정 건물의 호실 목록을 받아오는 함수
  /// 🔥 서버 라우트: GET /room/:building (building-service)
  Future<List<Map<String, dynamic>>> fetchRoomsByBuilding(String buildingName) async {
    try {
      print('📞 API 호출: fetchRoomsByBuilding("$buildingName")');
      
      // 🔥 서버에서 직접 건물별 호실을 조회하도록 최적화
      final encodedBuildingName = Uri.encodeComponent(buildingName);
      final response = await ApiHelper.get('${ApiConfig.roomBase}/$encodedBuildingName');
      
      if (response.statusCode == 200) {
        final List<dynamic> roomList = json.decode(utf8.decode(response.bodyBytes));
        print('🏢 $buildingName 호실 수: ${roomList.length}개');
        return roomList.cast<Map<String, dynamic>>();
      } else {
        print('❌ API 오류 - 상태코드: ${response.statusCode}');
        throw Exception('Failed to load rooms for $buildingName');
      }
    } catch (e) {
      print('❌ fetchRoomsByBuilding 오류: $e');
      rethrow;
    }
  }
}