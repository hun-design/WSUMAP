// lib/inside/api_service.dart - 최적화된 버전

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/config/api_config.dart';
import 'package:flutter_application_1/services/api_helper.dart';
import 'package:flutter_application_1/services/jwt_service.dart';

/// 서버와 통신하는 API 서비스 클래스
class ApiService {
  final String _baseUrl = ApiConfig.pathBase;

  /// 서버에서 건물 목록을 받아오는 함수
  /// 🔥 서버 라우트: GET /building/names (building-service)
  Future<List<String>> fetchBuildingList() async {
    try {
      final response = await ApiHelper.get('${ApiConfig.buildingBase}/names');
      
      if (response.statusCode == 200) {
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
      if (kDebugMode) {
        debugPrint('❌ fetchBuildingList 오류: $e');
      }
      rethrow;
    }
  }

  /// 특정 건물의 층 목록을 받아오는 함수 (전체 Floor 정보 포함)
  /// 🔥 서버 라우트: GET /floor/:building (building-service)
  /// 반환: [{Floor_Id, Floor_Number, Building_Name, File}, ...]
  Future<List<dynamic>> fetchFloorList(String buildingName, {bool forceRefresh = false}) async {
    try {
      // 🔥 게스트 사용자인지 확인 (userId가 guest_로 시작하는지 확인)
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final isGuestUser = userId == null || userId.startsWith('guest_');
      
      // 🔥 게스트 사용자인 경우 항상 캐시 무시하고 최신 데이터 가져오기
      final hasToken = await JwtService.isTokenValid();
      final shouldForceRefresh = forceRefresh || isGuestUser || !hasToken;
      
      final encodedBuildingName = Uri.encodeComponent(buildingName);
      final url = '${ApiConfig.floorBase}/$encodedBuildingName';
      
      if (kDebugMode) {
        debugPrint('📞 fetchFloorList API 호출: $url');
        debugPrint('🏢 건물명: $buildingName');
        debugPrint('🔐 JWT 토큰 유효성: $hasToken');
        debugPrint('🔄 강제 새로고침: $shouldForceRefresh (원래: $forceRefresh)');
      }
      
      final response = await ApiHelper.get(url, forceRefresh: shouldForceRefresh);
      
      if (kDebugMode) {
        debugPrint('📡 fetchFloorList 응답 상태: ${response.statusCode}');
        debugPrint('📡 fetchFloorList 응답 본문: ${response.body}');
      }
      
      if (response.statusCode == 200) {
        try {
          final List<dynamic> floorList = json.decode(utf8.decode(response.bodyBytes));
          if (kDebugMode) {
            debugPrint('✅ 층 목록 로드 성공: ${floorList.length}개');
          }
          
          if (floorList.isEmpty) {
            throw Exception('이 건물에는 층 정보가 없습니다.');
          }
          
          return floorList;
        } catch (jsonError) {
          if (kDebugMode) {
            debugPrint('❌ JSON 파싱 오류: $jsonError');
            debugPrint('❌ 응답 본문: ${response.body}');
          }
          throw Exception('서버 응답을 파싱하는데 실패했습니다: $jsonError');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // 🔥 인증 오류 - 게스트 사용자일 때 더 자세한 메시지
        if (kDebugMode) {
          debugPrint('⚠️ 인증 오류 (${response.statusCode}): 서버가 게스트 요청을 거부했습니다.');
          debugPrint('⚠️ 응답 본문: ${response.body}');
          debugPrint('⚠️ 요청 URL: $url');
          debugPrint('⚠️ 서버가 X-Guest-User 헤더를 인식하지 못하는 것 같습니다.');
          debugPrint('⚠️ 서버 개발자에게 확인 필요: 게스트 사용자 요청 허용 설정');
        }
        // 🔥 게스트 사용자에게 더 명확한 안내
        throw Exception('게스트 사용자는 건물 도면을 볼 수 없습니다.\n로그인 후 다시 시도해주세요.');
      } else if (response.statusCode == 404) {
        if (kDebugMode) {
          debugPrint('❌ 건물을 찾을 수 없음 (404): $buildingName');
          debugPrint('❌ 응답 본문: ${response.body}');
        }
        throw Exception('건물 "$buildingName"을(를) 찾을 수 없습니다.\n건물명이 정확한지 확인해주세요.');
      } else if (response.statusCode >= 500) {
        if (kDebugMode) {
          debugPrint('❌ 서버 오류 (${response.statusCode})');
          debugPrint('❌ 응답 본문: ${response.body}');
        }
        throw Exception('서버 오류가 발생했습니다.\n잠시 후 다시 시도해주세요. (오류 코드: ${response.statusCode})');
      } else {
        if (kDebugMode) {
          debugPrint('❌ API 오류: 상태 코드 ${response.statusCode}');
          debugPrint('❌ 응답 본문: ${response.body}');
          debugPrint('❌ 요청 URL: $url');
        }
        throw Exception('층 목록을 불러오는데 실패했습니다.\n오류 코드: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ fetchFloorList 오류: $e');
        debugPrint('❌ 오류 타입: ${e.runtimeType}');
        debugPrint('❌ 스택 트레이스: ${StackTrace.current}');
      }
      
      // 🔥 타임아웃이나 네트워크 오류인 경우 더 친화적인 메시지
      if (e.toString().contains('Timeout') || e.toString().contains('timeout')) {
        throw Exception('요청 시간이 초과되었습니다.\n네트워크 연결을 확인하고 다시 시도해주세요.');
      } else if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        throw Exception('네트워크 연결에 실패했습니다.\n인터넷 연결을 확인해주세요.');
      }
      
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
    try {
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
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to find path');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ findPath 오류: $e');
      }
      rethrow;
    }
  }

  /// GET 방식으로 방(강의실) 설명을 받아오는 함수
  /// 🔥 서버 라우트: GET /room/desc/:building/:floor/:room (building-service)
  Future<String> fetchRoomDescription({
    required String buildingName,
    required String floorNumber,
    required String roomName,
  }) async {
    try {
      final response = await ApiHelper.get(
        '${ApiConfig.roomBase}/desc/${Uri.encodeComponent(buildingName)}/$floorNumber/${Uri.encodeComponent(roomName)}'
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['Room_Description'] ?? '설명 없음';
      } else if (response.statusCode == 404) {
        return '설명 없음';
      } else {
        throw Exception('방 설명을 불러오지 못했습니다.');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ fetchRoomDescription 오류: $e');
      }
      return '설명 없음';
    }
  }

  /// 🔥 모든 호실 목록을 받아오는 함수
  /// 🔥 서버 라우트: GET /room (building-service)
  Future<List<Map<String, dynamic>>> fetchAllRooms() async {
    try {
      if (kDebugMode) {
        debugPrint('📞 API 호출: fetchAllRooms()');
      }
      
      final response = await ApiHelper.get('${ApiConfig.roomBase}');
      
      if (response.statusCode == 200) {
        final List<dynamic> roomList = json.decode(utf8.decode(response.bodyBytes));
        
        if (kDebugMode) {
          debugPrint('✅ 전체 호실 수: ${roomList.length}개');
          if (roomList.isNotEmpty) {
            debugPrint('🏠 첫 번째 호실 예시: ${roomList[0]}');
          }
        }
        
        return roomList.cast<Map<String, dynamic>>();
      } else {
        if (kDebugMode) {
          debugPrint('❌ API 오류 - 상태코드: ${response.statusCode}');
        }
        throw Exception('Failed to load room list from server');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ fetchAllRooms 오류: $e');
      }
      rethrow;
    }
  }

  /// 🔥 특정 건물의 호실 목록을 받아오는 함수
  /// 🔥 서버 라우트: GET /room/:building (building-service)
  Future<List<Map<String, dynamic>>> fetchRoomsByBuilding(String buildingName) async {
    try {
      if (kDebugMode) {
        debugPrint('📞 API 호출: fetchRoomsByBuilding("$buildingName")');
      }
      
      final encodedBuildingName = Uri.encodeComponent(buildingName);
      final response = await ApiHelper.get('${ApiConfig.roomBase}/$encodedBuildingName');
      
      if (response.statusCode == 200) {
        final List<dynamic> roomList = json.decode(utf8.decode(response.bodyBytes));
        
        if (kDebugMode) {
          debugPrint('🏢 $buildingName 호실 수: ${roomList.length}개');
        }
        
        return roomList.cast<Map<String, dynamic>>();
      } else {
        if (kDebugMode) {
          debugPrint('❌ API 오류 - 상태코드: ${response.statusCode}');
        }
        throw Exception('Failed to load rooms for $buildingName');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ fetchRoomsByBuilding 오류: $e');
      }
      rethrow;
    }
  }
}
