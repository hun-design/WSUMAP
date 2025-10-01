// models/category.dart - 개선된 버전
class Category {
  final String categoryName;
  final String? buildingName;
  final CategoryLocation? location;

  Category({
    required this.categoryName,
    this.buildingName,
    this.location,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryName: json['Category_Name']?.toString() ?? '',
      buildingName: json['Building_Name']?.toString(),
      location: json['Location'] != null 
          ? CategoryLocation.fromJson(json['Location'])
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
}

class CategoryLocation {
  final double x;
  final double y;

  CategoryLocation({
    required this.x,
    required this.y,
  });

  factory CategoryLocation.fromJson(Map<String, dynamic> json) {
    // 🔥 더 안전한 파싱
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return CategoryLocation(
      x: parseDouble(json['x']),
      y: parseDouble(json['y']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }

  @override
  String toString() {
    return 'CategoryLocation(x: $x, y: $y)';
  }
}


// 카테고리 마커 정보를 위한 클래스
class CategoryMarker {
  final String buildingName;
  final String categoryName;
  final CategoryLocation location;

  CategoryMarker({
    required this.buildingName,
    required this.categoryName,
    required this.location,
  });


  @override
  String toString() {
    return 'CategoryMarker(buildingName: $buildingName, categoryName: $categoryName, location: $location)';
  }
}