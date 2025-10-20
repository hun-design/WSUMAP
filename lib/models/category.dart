// models/category.dart - 최적화된 버전

/// 카테고리 모델
class Category {
  final String categoryName;
  final String? buildingName;
  final CategoryLocation? location;

  const Category({
    required this.categoryName,
    this.buildingName,
    this.location,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryName: json['Category_Name']?.toString() ?? '',
      buildingName: json['Building_Name']?.toString(),
      location: json['Location'] != null 
          ? CategoryLocation.fromJson(json['Location'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Category_Name': categoryName,
      'Building_Name': buildingName,
      'Location': location?.toJson(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          categoryName == other.categoryName &&
          buildingName == other.buildingName &&
          location == other.location;

  @override
  int get hashCode =>
      categoryName.hashCode ^
      (buildingName?.hashCode ?? 0) ^
      (location?.hashCode ?? 0);

  @override
  String toString() =>
      'Category(categoryName: $categoryName, buildingName: $buildingName)';
}

/// 카테고리 위치 모델
class CategoryLocation {
  final double x;
  final double y;

  const CategoryLocation({
    required this.x,
    required this.y,
  });

  factory CategoryLocation.fromJson(Map<String, dynamic> json) {
    return CategoryLocation(
      x: _parseDouble(json['x']),
      y: _parseDouble(json['y']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryLocation &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => 'CategoryLocation(x: $x, y: $y)';

  /// 안전한 double 파싱 헬퍼 메서드
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// 카테고리 마커 모델
class CategoryMarker {
  final String buildingName;
  final String categoryName;
  final CategoryLocation location;

  const CategoryMarker({
    required this.buildingName,
    required this.categoryName,
    required this.location,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryMarker &&
          runtimeType == other.runtimeType &&
          buildingName == other.buildingName &&
          categoryName == other.categoryName &&
          location == other.location;

  @override
  int get hashCode =>
      buildingName.hashCode ^ categoryName.hashCode ^ location.hashCode;

  @override
  String toString() =>
      'CategoryMarker(buildingName: $buildingName, categoryName: $categoryName, location: $location)';
}
