// lib/inside/path_models.dart - 최적화된 버전

/// API 응답 전체를 감싸는 최상위 모델 클래스
class PathResponse {
  final String type;
  final PathResult? result;

  const PathResponse({required this.type, this.result});

  /// JSON 데이터를 PathResponse 객체로 변환하는 팩토리 생성자
  factory PathResponse.fromJson(Map<String, dynamic> json) {
    return PathResponse(
      type: json['type'] as String,
      result: json['result'] != null ? PathResult.fromJson(json['result'] as Map<String, dynamic>) : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PathResponse &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          result == other.result;

  @override
  int get hashCode => type.hashCode ^ result.hashCode;
}

/// "result" 필드에 해당하는 모델 클래스
class PathResult {
  final IndoorPath? departureIndoor;
  final OutdoorPath? outdoor;
  final IndoorPath? arrivalIndoor;

  const PathResult({this.departureIndoor, this.outdoor, this.arrivalIndoor});

  factory PathResult.fromJson(Map<String, dynamic> json) {
    return PathResult(
      departureIndoor: json['departure_indoor'] != null
          ? IndoorPath.fromJson(json['departure_indoor'] as Map<String, dynamic>)
          : null,
      outdoor: json['outdoor'] != null 
          ? OutdoorPath.fromJson(json['outdoor'] as Map<String, dynamic>) 
          : null,
      arrivalIndoor: json['arrival_indoor'] != null
          ? IndoorPath.fromJson(json['arrival_indoor'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PathResult &&
          runtimeType == other.runtimeType &&
          departureIndoor == other.departureIndoor &&
          outdoor == other.outdoor &&
          arrivalIndoor == other.arrivalIndoor;

  @override
  int get hashCode => departureIndoor.hashCode ^ outdoor.hashCode ^ arrivalIndoor.hashCode;
}

/// 실내 경로(Indoor) 정보를 담는 모델 클래스
class IndoorPath {
  final PathInfo path;

  const IndoorPath({required this.path});

  factory IndoorPath.fromJson(Map<String, dynamic> json) {
    return IndoorPath(
      path: PathInfo.fromJson(json['path'] as Map<String, dynamic>),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndoorPath &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;
}

/// 실외 경로(Outdoor) 정보를 담는 모델 클래스
class OutdoorPath {
  final PathInfo path;

  const OutdoorPath({required this.path});

  factory OutdoorPath.fromJson(Map<String, dynamic> json) {
    return OutdoorPath(
      path: PathInfo.fromJson(json['path'] as Map<String, dynamic>),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutdoorPath &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;
}

/// 경로의 거리(distance)와 실제 노드 리스트(path)를 담는 모델 클래스
class PathInfo {
  final double distance;
  final List<IndoorPathNode> path;

  const PathInfo({required this.distance, required this.path});

  factory PathInfo.fromJson(Map<String, dynamic> json) {
    final pathList = json['path'] as List;
    final nodes = pathList.map((i) => IndoorPathNode.fromJson(i)).toList();
    
    return PathInfo(
      distance: (json['distance'] as num).toDouble(),
      path: nodes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PathInfo &&
          runtimeType == other.runtimeType &&
          distance == other.distance &&
          path == other.path;

  @override
  int get hashCode => distance.hashCode ^ path.hashCode;
}

/// 실내 경로를 구성하는 각 노드의 ID 정보를 담는 모델 클래스
class IndoorPathNode {
  final String id;
  final String? name;

  const IndoorPathNode({required this.id, this.name});

  /// API 응답의 경로 리스트 요소가 단순 문자열("R101@2")일 경우를 처리
  factory IndoorPathNode.fromJson(dynamic json) {
    if (json is String) {
      return IndoorPathNode(
        id: json, 
        name: json.contains('계단') ? '계단' : null,
      );
    }
    // API가 {"id": "...", "name": "..."} 객체 형태인 경우
    final map = json as Map<String, dynamic>;
    return IndoorPathNode(
      id: map['id'] as String,
      name: map['name'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndoorPathNode &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ (name?.hashCode ?? 0);

  @override
  String toString() => 'IndoorPathNode(id: $id, name: $name)';
}
