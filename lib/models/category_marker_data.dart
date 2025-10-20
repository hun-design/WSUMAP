// lib/models/category_marker_data.dart - 최적화된 버전

import 'package:flutter/material.dart';

/// 카테고리 마커 데이터 모델
class CategoryMarkerData {
  final String buildingName;
  final double lat;
  final double lng;
  final String category;
  final IconData icon;
  final List<String> floors;
  final List<String>? categoryFloors;

  const CategoryMarkerData({
    required this.buildingName,
    required this.lat,
    required this.lng,
    required this.category,
    required this.icon,
    required this.floors,
    this.categoryFloors,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryMarkerData &&
          runtimeType == other.runtimeType &&
          buildingName == other.buildingName &&
          lat == other.lat &&
          lng == other.lng &&
          category == other.category &&
          icon == icon &&
          _listEquals(other.floors, floors) &&
          _listEquals(other.categoryFloors ?? [], categoryFloors ?? []);

  @override
  int get hashCode =>
      buildingName.hashCode ^
      lat.hashCode ^
      lng.hashCode ^
      category.hashCode ^
      icon.hashCode ^
      floors.hashCode ^
      (categoryFloors?.hashCode ?? 0);

  @override
  String toString() =>
      'CategoryMarkerData(buildingName: $buildingName, lat: $lat, lng: $lng, category: $category, floors: $floors, categoryFloors: $categoryFloors)';
}

/// 리스트 비교 헬퍼 함수
bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// 위치 정보 모델 (기존 코드 호환성 유지)
class Location {
  final double x;
  final double y;

  const Location({
    required this.x,
    required this.y,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => 'Location(x: $x, y: $y)';
}
