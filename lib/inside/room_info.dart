// lib/inside/room_info.dart - 최적화된 버전

/// 강의실 정보 모델 클래스
class RoomInfo {
  final String id;
  final String name;
  final String desc;
  final List<String> users;
  final List<String>? phones;
  final List<String>? emails;

  const RoomInfo({
    required this.id,
    required this.name,
    required this.desc,
    required this.users,
    this.phones,
    this.emails,
  });

  factory RoomInfo.fromJson(Map<String, dynamic> json) {
    return RoomInfo(
      id: json['Room_Name'] as String? ?? '',
      name: json['Room_Name'] as String? ?? '',
      desc: json['Room_Description'] as String? ?? '',
      users: _parseStringList(json['Room_User']),
      phones: _parseStringListNullable(json['User_Phone']),
      emails: _parseStringListNullable(json['User_Email']),
    );
  }

  /// copyWith 메서드 추가 (불변성 유지)
  RoomInfo copyWith({
    String? id,
    String? name,
    String? desc,
    List<String>? users,
    List<String>? phones,
    List<String>? emails,
  }) {
    return RoomInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      users: users ?? this.users,
      phones: phones ?? this.phones,
      emails: emails ?? this.emails,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          desc == other.desc;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ desc.hashCode;

  @override
  String toString() {
    return 'RoomInfo(id: $id, name: $name, users: ${users.length})';
  }

  /// null이나 빈 문자열을 필터링하는 헬퍼 메서드
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .where((item) => item != null && item.toString().trim().isNotEmpty)
          .map((item) => item.toString().trim())
          .toList();
    }
    return [];
  }

  /// null이나 빈 문자열을 필터링하는 헬퍼 메서드 (nullable)
  static List<String>? _parseStringListNullable(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      final filtered = value
          .where((item) => item != null && item.toString().trim().isNotEmpty)
          .map((item) => item.toString().trim())
          .toList();
      return filtered.isEmpty ? null : filtered;
    }
    return null;
  }
}
