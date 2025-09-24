// lib/services/unified_path_service.dart - 완전한 버전

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_application_1/models/building.dart';
import 'package:flutter_application_1/config/api_config.dart';
import 'api_helper.dart';

/// 통합 경로 요청 파라미터
class PathRequest {
  final String? fromBuilding;
  final int? fromFloor;
  final String? fromRoom;
  final String toBuilding;
  final int? toFloor;
  final String? toRoom;
  final NLatLng? fromLocation; // 현재 위치에서 출발하는 경우

  PathRequest({
    this.fromBuilding,
    this.fromFloor,
    this.fromRoom,
    required this.toBuilding,
    this.toFloor,
    this.toRoom,
    this.fromLocation,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    // 현재 위치가 있으면 from_location 추가
    if (fromLocation != null) {
      json['from_location'] = {
        'lat': fromLocation!.latitude,
        'lng': fromLocation!.longitude,
      };
    }

    // 출발 건물 정보
    if (fromBuilding != null) json['from_building'] = fromBuilding;
    if (fromFloor != null) json['from_floor'] = fromFloor;
    if (fromRoom != null) json['from_room'] = fromRoom;

    // 도착 건물 정보 (필수)
    json['to_building'] = toBuilding;
    if (toFloor != null) json['to_floor'] = toFloor;
    if (toRoom != null) json['to_room'] = toRoom;

    return json;
  }
}

/// 통합 경로 응답 모델
class UnifiedPathResponse {
  final String type;
  final PathResult result;

  UnifiedPathResponse({required this.type, required this.result});

  factory UnifiedPathResponse.fromJson(Map<String, dynamic> json) {
    return UnifiedPathResponse(
      type: json['type'],
      result: PathResult.fromJson(json['result']),
    );
  }
}

class PathResult {
  final IndoorPathData? departureIndoor;
  final OutdoorPathData? outdoor;
  final IndoorPathData? arrivalIndoor;

  PathResult({this.departureIndoor, this.outdoor, this.arrivalIndoor});

  factory PathResult.fromJson(Map<String, dynamic> json) {
    return PathResult(
      departureIndoor: json['departure_indoor'] != null
          ? IndoorPathData.fromJson(json['departure_indoor'])
          : null,
      outdoor: json['outdoor'] != null
          ? OutdoorPathData.fromJson(json['outdoor'])
          : null,
      arrivalIndoor: json['arrival_indoor'] != null
          ? IndoorPathData.fromJson(json['arrival_indoor'])
          : null,
    );
  }
}

class IndoorPathData {
  final String? startFloorImage; // SVG URL
  final String? endFloorImage; // SVG URL
  final PathInfo path;

  IndoorPathData({
    this.startFloorImage,
    this.endFloorImage,
    required this.path,
  });

  factory IndoorPathData.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('🔍 IndoorPathData 파싱 시작: ${json.keys}');

      // 🔥 start_floorImage 파싱 (DB 쿼리 결과 또는 문자열)
      String? startFloorImageUrl;
      final startFloorImageData = json['start_floorImage'];
      if (startFloorImageData != null) {
        if (startFloorImageData is String) {
          // 문자열인 경우 (base64 또는 URL)
          startFloorImageUrl = startFloorImageData;
        } else if (startFloorImageData is Map<String, dynamic>) {
          // DB 쿼리 결과인 경우
          try {
            final rows = startFloorImageData['rows'] as List?;
            if (rows != null &&
                rows.isNotEmpty &&
                rows[0] is Map<String, dynamic>) {
              final firstRow = rows[0] as Map<String, dynamic>;
              startFloorImageUrl = firstRow['File'] as String?;
              debugPrint('✅ start_floorImage URL 추출: $startFloorImageUrl');
            }
          } catch (e) {
            debugPrint('❌ start_floorImage DB 결과 파싱 오류: $e');
          }
        }
      }

      // 🔥 end_floorImage 파싱 (DB 쿼리 결과 또는 문자열)
      String? endFloorImageUrl;
      final endFloorImageData = json['end_floorImage'];
      if (endFloorImageData != null) {
        if (endFloorImageData is String) {
          // 문자열인 경우 (base64 또는 URL)
          endFloorImageUrl = endFloorImageData;
        } else if (endFloorImageData is Map<String, dynamic>) {
          // DB 쿼리 결과인 경우
          try {
            final rows = endFloorImageData['rows'] as List?;
            if (rows != null &&
                rows.isNotEmpty &&
                rows[0] is Map<String, dynamic>) {
              final firstRow = rows[0] as Map<String, dynamic>;
              endFloorImageUrl = firstRow['File'] as String?;
              debugPrint('✅ end_floorImage URL 추출: $endFloorImageUrl');
            }
          } catch (e) {
            debugPrint('❌ end_floorImage DB 결과 파싱 오류: $e');
          }
        }
      }

      debugPrint('🖼️ 최종 이미지 URL:');
      debugPrint('   start: $startFloorImageUrl');
      debugPrint('   end: $endFloorImageUrl');

      return IndoorPathData(
        startFloorImage: startFloorImageUrl,
        endFloorImage: endFloorImageUrl,
        path: PathInfo.fromJson(json['path'] as Map<String, dynamic>? ?? {}),
      );
    } catch (e) {
      debugPrint('❌ IndoorPathData 파싱 오류: $e');
      debugPrint('📄 오류 발생 JSON: $json');

      // 기본값으로 반환
      return IndoorPathData(
        startFloorImage: null,
        endFloorImage: null,
        path: PathInfo(distance: 0.0, path: []),
      );
    }
  }
}

class OutdoorPathData {
  final PathInfo path;

  OutdoorPathData({required this.path});

  factory OutdoorPathData.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('🔍 OutdoorPathData 파싱 시작: ${json.keys}');

      return OutdoorPathData(
        path: PathInfo.fromJson(json['path'] as Map<String, dynamic>? ?? {}),
      );
    } catch (e) {
      debugPrint('❌ OutdoorPathData 파싱 오류: $e');
      debugPrint('📄 오류 발생 JSON: $json');

      // 기본값으로 반환
      return OutdoorPathData(path: PathInfo(distance: 0.0, path: []));
    }
  }
}

class PathInfo {
  final double distance;
  final List<dynamic> path; // 실내는 노드 ID, 실외는 좌표

  PathInfo({required this.distance, required this.path});

  factory PathInfo.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('🔍 PathInfo 파싱 시작: $json');

      // distance 안전 파싱
      final distance = (json['distance'] as num?)?.toDouble() ?? 0.0;

      // path 안전 파싱
      dynamic pathData = json['path'];
      List<dynamic> pathList = [];

      if (pathData is List) {
        pathList = pathData;
      } else if (pathData is Map) {
        // path가 객체인 경우 - API 스펙과 다를 수 있음
        debugPrint('⚠️ path가 Map 형태입니다: $pathData');
        pathList = []; // 일단 빈 배열로 처리
      } else {
        debugPrint('⚠️ path가 예상과 다른 타입입니다: ${pathData.runtimeType}');
        pathList = [];
      }

      debugPrint(
        '✅ PathInfo 파싱 완료: distance=$distance, path개수=${pathList.length}',
      );

      return PathInfo(distance: distance, path: pathList);
    } catch (e) {
      debugPrint('❌ PathInfo 파싱 오류: $e');
      debugPrint('📄 오류 발생 JSON: $json');

      // 기본값으로 반환
      return PathInfo(distance: 0.0, path: []);
    }
  }
}

/// 통합 경로 API 서비스
class UnifiedPathService {
  // 🔥 수정: ApiConfig 사용
  static String get baseUrl => ApiConfig.pathBase;

  /// 메인 경로 요청 메서드
  static Future<UnifiedPathResponse?> requestPath(PathRequest request) async {
    try {
      debugPrint('🚀 통합 경로 요청: ${request.toJson()}');

      debugPrint('📡 요청 URL: $baseUrl/path');
      debugPrint('📡 요청 Body: ${jsonEncode(request.toJson())}');

      final response = await ApiHelper.post(
        '$baseUrl/path',
        body: request.toJson(),
      );

      debugPrint('📡 응답 상태: ${response.statusCode}');

      if (response.statusCode == 200) {
        // 🔥 원본 응답 로그 추가
        debugPrint('📡 원본 응답 Body: ${response.body}');

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('✅ 통합 경로 응답: ${data['type']}');

        // 🔥 안전한 파싱을 위한 try-catch 추가
        try {
          return UnifiedPathResponse.fromJson(data);
        } catch (parseError) {
          debugPrint('❌ JSON 파싱 오류: $parseError');
          debugPrint('📄 파싱 실패 데이터: $data');
          return null;
        }
      } else {
        debugPrint('❌ HTTP 오류: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ 통합 경로 요청 오류: $e');
      return null;
    }
  }

  /// 건물명에서 건물 코드 추출 (W1, W2 등)
  static String _extractBuildingCode(String buildingName) {
    final regex = RegExp(r'\(([WS]\d+)\)');
    final match = regex.firstMatch(buildingName);
    return match?.group(1) ?? buildingName;
  }

  /// Building 객체 간 경로 요청
  static Future<UnifiedPathResponse?> getPathBetweenBuildings({
    required Building fromBuilding,
    required Building toBuilding,
  }) async {
    // 🔥 "내 위치"인 경우 좌표 기반 요청으로 변경
    if (fromBuilding.isMyLocation) {
      debugPrint('🔄 "내 위치"를 좌표 기반 요청으로 변경');
      debugPrint('   좌표: (${fromBuilding.lat}, ${fromBuilding.lng})');

      return await getPathFromLocation(
        fromLocation: NLatLng(fromBuilding.lat, fromBuilding.lng),
        toBuilding: toBuilding,
      );
    }

    // 🔥 일반 건물인 경우 기존 로직
    final request = PathRequest(
      fromBuilding: _extractBuildingCode(fromBuilding.name),
      toBuilding: _extractBuildingCode(toBuilding.name),
    );
    return await requestPath(request);
  }

  /// 호실 간 경로 요청
  static Future<UnifiedPathResponse?> getPathBetweenRooms({
    required String fromBuilding,
    required int fromFloor,
    required String fromRoom,
    required String toBuilding,
    required int toFloor,
    required String toRoom,
  }) async {
    final request = PathRequest(
      fromBuilding: fromBuilding,
      fromFloor: fromFloor,
      fromRoom: fromRoom,
      toBuilding: toBuilding,
      toFloor: toFloor,
      toRoom: toRoom,
    );
    return await requestPath(request);
  }

  /// 호실에서 건물로의 경로 요청
  static Future<UnifiedPathResponse?> getPathFromRoom({
    required String fromBuilding,
    required int fromFloor,
    required String fromRoom,
    required Building toBuilding,
  }) async {
    final request = PathRequest(
      fromBuilding: fromBuilding,
      fromFloor: fromFloor,
      fromRoom: fromRoom,
      toBuilding: _extractBuildingCode(toBuilding.name),
    );
    return await requestPath(request);
  }

  /// 건물에서 호실로의 경로 요청
  static Future<UnifiedPathResponse?> getPathToRoom({
    required Building fromBuilding,
    required String toBuilding,
    required int toFloor,
    required String toRoom,
  }) async {
    // 🔥 "내 위치"인 경우 좌표 기반 요청으로 변경
    if (fromBuilding.isMyLocation) {
      debugPrint('🔄 "내 위치"를 좌표 기반 요청으로 변경');
      debugPrint('   좌표: (${fromBuilding.lat}, ${fromBuilding.lng})');

      return await getPathFromLocationToRoom(
        fromLocation: NLatLng(fromBuilding.lat, fromBuilding.lng),
        toBuilding: toBuilding,
        toFloor: toFloor,
        toRoom: toRoom,
      );
    }

    // 🔥 일반 건물인 경우 기존 로직
    final request = PathRequest(
      fromBuilding: _extractBuildingCode(fromBuilding.name),
      toBuilding: toBuilding,
      toFloor: toFloor,
      toRoom: toRoom,
    );
    return await requestPath(request);
  }

  /// 실외 경로에서 좌표 배열 추출
  static List<NLatLng> extractOutdoorCoordinates(OutdoorPathData outdoorData) {
    final coordinates = <NLatLng>[];

    for (final item in outdoorData.path.path) {
      if (item is Map<String, dynamic>) {
        final lat =
            (item['lat'] as num?)?.toDouble() ??
            (item['x'] as num?)?.toDouble();
        final lng =
            (item['lng'] as num?)?.toDouble() ??
            (item['y'] as num?)?.toDouble();

        if (lat != null && lng != null) {
          coordinates.add(NLatLng(lat, lng));
        }
      }
    }

    return coordinates;
  }

  /// 실내 경로에서 노드 ID 배열 추출
  static List<String> extractIndoorNodeIds(IndoorPathData indoorData) {
    final nodeIds = indoorData.path.path
        .where((item) => item is String)
        .cast<String>()
        .toList();

    // 🔥 계단 노드 정규화: to-east-stairs -> stairs, to-west-stairs -> stairs 등
    return nodeIds.map((nodeId) => _normalizeStairsNode(nodeId)).toList();
  }

  /// 🔥 계단 노드 정규화 메서드
  static String _normalizeStairsNode(String nodeId) {
    // 계단 관련 패턴들을 stairs로 정규화
    if (RegExp(r'to-[a-z]+-stairs', caseSensitive: false).hasMatch(nodeId)) {
      debugPrint('🔄 계단 노드 정규화: $nodeId -> stairs');
      return 'stairs';
    }

    // 다른 계단 패턴들도 정규화
    if (RegExp(r'[a-z]+-stairs', caseSensitive: false).hasMatch(nodeId) &&
        !nodeId.contains('@')) {
      debugPrint('🔄 계단 노드 정규화: $nodeId -> stairs');
      return 'stairs';
    }

    return nodeId;
  }

  static Future<UnifiedPathResponse?> getPathFromLocation({
    required NLatLng fromLocation,
    required Building toBuilding,
  }) async {
    debugPrint('📍 현재 위치에서 건물로 경로 요청');
    debugPrint(
      '   출발 좌표: (${fromLocation.latitude}, ${fromLocation.longitude})',
    );
    debugPrint('   도착 건물: ${toBuilding.name}');

    final request = PathRequest(
      fromLocation: fromLocation,
      toBuilding: _extractBuildingCode(toBuilding.name),
    );
    return await requestPath(request);
  }

  /// 현재 위치에서 호실로의 경로 요청 - 추가 메서드
  static Future<UnifiedPathResponse?> getPathFromLocationToRoom({
    required NLatLng fromLocation,
    required String toBuilding,
    required int toFloor,
    required String toRoom,
  }) async {
    debugPrint('📍 현재 위치에서 호실로 경로 요청');
    debugPrint(
      '   출발 좌표: (${fromLocation.latitude}, ${fromLocation.longitude})',
    );
    debugPrint('   도착 호실: $toBuilding $toFloor층 $toRoom호');

    final request = PathRequest(
      fromLocation: fromLocation,
      toBuilding: toBuilding,
      toFloor: toFloor,
      toRoom: toRoom,
    );
    return await requestPath(request);
  }

  /// 연결 테스트 - 🔥 서버에 health 엔드포인트가 없으므로 주석 처리
  /*
  static Future<bool> testConnection() async {
    try {
      // 🔥 수정: ApiConfig 사용하여 health check
      final url = Uri.parse('$baseUrl/health');
      debugPrint('🔍 서버 연결 테스트: $url');
      
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      debugPrint('📡 Health Check 응답: ${response.statusCode}');
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ 서버 연결 테스트 실패: $e');
      return false;
    }
  }
  */
}
