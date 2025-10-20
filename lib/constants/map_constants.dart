import 'package:flutter_naver_map/flutter_naver_map.dart';

/// 지도 관련 상수 정의
class MapConstants {
  // 초기 카메라 위치
  static const NCameraPosition initialCameraPosition = NCameraPosition(
    target: NLatLng(36.3304, 127.4579),
    zoom: 18,
  );

  // 기본 줌 레벨
  static const double defaultZoom = 15;
  static const double buildingDetailZoom = 18;

  // 경로 스타일
  static const double pathWidth = 8;
  static const double pathOutlineWidth = 2;

  // 거리 임계값
  static const double nodeConnectionThreshold = 10; // 미터

  /// 건물 이름을 ID로 변환
  static String? getBuildingId(String buildingName) {
    return buildingNameToId[buildingName];
  }

  /// 건물 이름이 매핑에 있는지 확인
  static bool hasBuildingMapping(String buildingName) {
    return buildingNameToId.containsKey(buildingName);
  }

  // 건물 이름 매핑 (private으로 변경)
  static const Map<String, String> buildingNameToId = {
    '청운1숙': '1suk',
    '솔카페': 'solcafe',
    '유학생기숙사(W3)': 'W3',
    '우송관(W7)': 'W7',
    'W1': 'W1',
    'W2': 'W2',
    'W3': 'W3',
    'W4': 'W4',
    'W5': 'W5',
    'W6': 'W6',
    'W7': 'W7',
    'W8': 'W8',
    'W9': 'W9',
    'W10': 'W10',
    'W11': 'W11',
    'W12': 'W12',
    'W13': 'W13',
    'W14': 'W14',
    'W15': 'W15',
    'W16': 'W16',
    'W17': 'W17',
    'W18': 'W18',
    'W19': 'W19',
    '우송도서관(W1)': 'W1',
    '산학협력단(W2)': 'W2',
    '학군단(W2-1)': 'W2-1',
    '우송도서관(W4)': 'W4',
    '보건의료과학관(W5)': 'W5',
    '교양교육관(W6)': 'W6',
    '우송유치원(W8)': 'W8',
    '서캠퍼스정례원(W9)': 'W9',
    '사회복지융합관(W10)': 'W10',
    '체육관(W11)': 'W11',
    'SICA(W12)': 'W12',
    '우송타워(W13)': 'W13',
    'Culinary Center(W14)': 'W14',
    '식품건축관(W15)': 'W15',
    '학생회관(W16)': 'W16',
    '미디어융합관(W17-서관)': 'W17-서관',
    '미디어융합관(W17-동관)': 'W17-동관',
    '우송예술회관(W18)': 'W18',
    '서캠퍼스앤디컷빌딩(W19)': 'W19',
  };
}