// lib/services/path_api_service.dart - from_location 추가된 버전

import 'package:flutter_application_1/config/api_config.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_application_1/models/building.dart';
import 'api_helper.dart';

class PathApiService {
  static final String baseUrl = ApiConfig.pathBase;

  /// MapController에서 사용하는 메인 메서드 (Building 간 경로)
  static Future<List<NLatLng>> getRoute(Building startBuilding, Building endBuilding) async {
    try {
      // 서버 API 호출 (방/층 정보는 null로 전달)
      final apiResponse = await requestPathBetweenBuildings(
        fromBuilding: startBuilding,
        toBuilding: endBuilding,
      );
      
      if (apiResponse != null) {
        // 서버 응답에서 좌표 배열 추출
        List<NLatLng> coordinates = _parseServerResponse(apiResponse);
        
        if (coordinates.isNotEmpty) {
          return coordinates;
        }
      }
      
      // 서버 실패 시 직선 경로 반환
      return [
        NLatLng(startBuilding.lat, startBuilding.lng),
        NLatLng(endBuilding.lat, endBuilding.lng),
      ];
      
    } catch (e) {
      debugPrint('경로 요청 오류: $e');
      
      // 오류 시 직선 경로 반환
      return [
        NLatLng(startBuilding.lat, startBuilding.lng),
        NLatLng(endBuilding.lat, endBuilding.lng),
      ];
    }
  }

  /// 현재 위치에서 건물로의 경로 요청
  static Future<List<NLatLng>> getRouteFromLocation(NLatLng currentLocation, Building endBuilding) async {
    try {
      // 서버 API 호출 (from_location 사용)
      final apiResponse = await requestPathFromLocation(
        fromLocation: currentLocation,
        toBuilding: endBuilding,
      );
      
      if (apiResponse != null) {
        // 서버 응답에서 좌표 배열 추출
        List<NLatLng> coordinates = _parseServerResponse(apiResponse);
        
        if (coordinates.isNotEmpty) {
          return coordinates;
        }
      }
      
      // 서버 실패 시 직선 경로 반환
      return [
        currentLocation,
        NLatLng(endBuilding.lat, endBuilding.lng),
      ];
      
    } catch (e) {
      debugPrint('위치 기반 경로 요청 오류: $e');
      
      // 오류 시 직선 경로 반환
      return [
        currentLocation,
        NLatLng(endBuilding.lat, endBuilding.lng),
      ];
    }
  }

  /// 서버 응답 파싱
  static List<NLatLng> _parseServerResponse(Map<String, dynamic> response) {
    try {
      // 응답 타입 확인
      final String? responseType = response['type'] as String?;
      if (responseType == null) return [];
      
      // result 객체 가져오기
      final Map<String, dynamic>? result = response['result'] as Map<String, dynamic>?;
      if (result == null) return [];
      
      List<NLatLng> coordinates = [];
      
      // 응답 타입에 따른 처리
      switch (responseType) {
        case 'building-building':
        case 'room-building':
        case 'building-room':
        case 'room-room':
        case 'location-building': // 새로운 타입 추가
          coordinates = _parseOutdoorPath(result);
          break;
          
        default:
          return [];
      }
      
      return coordinates;
      
    } catch (e) {
      debugPrint('응답 파싱 오류: $e');
      return [];
    }
  }

  /// 실외 경로 좌표 추출
  static List<NLatLng> _parseOutdoorPath(Map<String, dynamic> result) {
    try {
      // result.outdoor.path.path 경로 추출
      final Map<String, dynamic>? outdoor = result['outdoor'] as Map<String, dynamic>?;
      if (outdoor == null) return [];
      
      final Map<String, dynamic>? pathObj = outdoor['path'] as Map<String, dynamic>?;
      if (pathObj == null) return [];
      
      final List<dynamic>? pathArray = pathObj['path'] as List<dynamic>?;
      if (pathArray == null || pathArray.isEmpty) return [];
      
      List<NLatLng> coordinates = [];
      
      // 좌표 배열 처리 - x,y 형식
      for (final item in pathArray) {
        if (item is Map<String, dynamic>) {
          // API에서 x,y 형식으로 받아오므로 x→lat, y→lng로 매핑
          final double? lat = (item['x'] as num?)?.toDouble();  // x → lat (위도)
          final double? lng = (item['y'] as num?)?.toDouble();  // y → lng (경도)
          
          if (lat != null && lng != null) {
            coordinates.add(NLatLng(lat, lng));
          } else {
            // 다른 형식도 시도
            final double? altLat = (item['lat'] as num?)?.toDouble();
            final double? altLng = (item['lng'] as num?)?.toDouble();
            if (altLat != null && altLng != null) {
              coordinates.add(NLatLng(altLat, altLng));
            }
          }
        }
      }
      
      return coordinates;
      
    } catch (e) {
      debugPrint('실외 경로 파싱 오류: $e');
      return [];
    }
  }

  /// 건물명에서 건물 코드 추출 (W1, W2, W3 등)
  static String _extractBuildingCode(String buildingName) {
    // "우송도서관(W1)" -> "W1"
    // "산학협력단(W2)" -> "W2"
    final regex = RegExp(r'\(([WS]\d+)\)');
    final match = regex.firstMatch(buildingName);
    if (match != null) {
      return match.group(1)!;
    }
    
    // 매칭되지 않으면 건물명 그대로 반환
    return buildingName;
  }

  /// Building 객체를 사용해서 경로 요청
  static Future<Map<String, dynamic>?> requestPathBetweenBuildings({
    required Building fromBuilding,
    required Building toBuilding,
  }) async {
    return await requestPath(
      fromBuilding: fromBuilding.name,
      toBuilding: toBuilding.name,
      fromFloor: null,
      fromRoom: null,
      toFloor: null,
      toRoom: null,
    );
  }

  /// 현재 위치에서 건물로의 경로 요청 (위도, 경도 직접 사용)
  static Future<Map<String, dynamic>?> requestPathFromLocation({
    required NLatLng fromLocation,
    required Building toBuilding,
  }) async {
    debugPrint('🚀 현재 위치에서 ${toBuilding.name}까지 경로 요청');
    debugPrint('📍 출발 위치: ${fromLocation.latitude}, ${fromLocation.longitude}');
    debugPrint('🏢 도착 건물: ${toBuilding.name}');
    
    return await requestPath(
      fromLocation: fromLocation,
      toBuilding: toBuilding.name,
      fromFloor: null,
      fromRoom: null,
      toFloor: null,
      toRoom: null,
    );
  }

  /// 서버에 경로 요청을 보내는 메인 함수
  static Future<Map<String, dynamic>?> requestPath({
    NLatLng? fromLocation,  // 새로 추가
    String? fromBuilding,   // 이제 선택적
    required String toBuilding,
    String? fromFloor,
    String? fromRoom,
    String? toFloor,
    String? toRoom,
  }) async {
    try {
      // 건물명을 코드로 변환
      final String? fromBuildingCode = fromBuilding != null ? _extractBuildingCode(fromBuilding) : null;
      final toBuildingCode = _extractBuildingCode(toBuilding);
      
      // 요청 바디 구성 (from_location을 맨 앞에 배치)
      final Map<String, dynamic> requestBody = {};

      // from_location이 있으면 맨 앞에 추가
      if (fromLocation != null) {
        requestBody['from_location'] = {
          'lat': fromLocation.latitude,
          'lng': fromLocation.longitude,
        };
      }

      // from_building 관련 정보 추가 (선택적)
      if (fromBuildingCode != null) {
        requestBody['from_building'] = fromBuildingCode;
      }
      if (fromFloor != null) {
        requestBody['from_floor'] = fromFloor;
      }
      if (fromRoom != null) {
        requestBody['from_room'] = fromRoom;
      }

      // to_ 관련 정보를 마지막에 추가
      requestBody['to_building'] = toBuildingCode;
      if (toFloor != null) {
        requestBody['to_floor'] = toFloor;
      }
      if (toRoom != null) {
        requestBody['to_room'] = toRoom;
      }
      
      final response = await ApiHelper.post(
        '$baseUrl/path',
        body: requestBody,
      );
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return data;
        } catch (e) {
          debugPrint('JSON 파싱 실패: $e');
          return null;
        }
      } else {
        debugPrint('HTTP 오류: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('네트워크 오류: $e');
      return null;
    }
  }

  /// API 연결 테스트 함수 - 🔥 서버에 health 엔드포인트가 없으므로 주석 처리
  /*
  static Future<bool> testConnection() async {
    try {
      final url = Uri.parse('$baseUrl/health');
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('서버 연결 테스트 실패: $e');
      return false;
    }
  }
  */
}