// lib/models/search_result.dart - 최적화된 버전

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/models/building.dart';

enum SearchResultType {
  building,
  room,
}

/// 검색 결과 모델
class SearchResult {
  final SearchResultType type;
  final String displayName;
  final String searchText;
  final Building building;
  final String? roomNumber;
  final int? floorNumber;
  final String? roomDescription;
  final List<String>? roomUser;
  final List<String>? roomPhone;
  final List<String>? roomEmail;

  const SearchResult({
    required this.type,
    required this.displayName,
    required this.searchText,
    required this.building,
    this.roomNumber,
    this.floorNumber,
    this.roomDescription,
    this.roomUser,
    this.roomPhone,
    this.roomEmail,
  });

  /// 건물 검색 결과 생성
  factory SearchResult.fromBuilding(Building building) {
    final buildingName = building.name.isNotEmpty ? building.name : '알 수 없는 건물';
    final searchTextParts = <String>[
      buildingName,
      building.info.isNotEmpty ? building.info : '',
      building.category.isNotEmpty ? building.category : '',
      building.description.isNotEmpty ? building.description : '',
    ].where((part) => part.isNotEmpty).toList();

    return SearchResult(
      type: SearchResultType.building,
      displayName: buildingName,
      searchText: searchTextParts.join(' '),
      building: building,
    );
  }

  /// 호실 검색 결과 생성
  factory SearchResult.fromRoom({
    required Building building,
    required String roomNumber,
    required int floorNumber,
    String? roomDescription,
    List<String>? roomUser,
    List<String>? roomPhone,
    List<String>? roomEmail,
  }) {
    if (roomNumber.isEmpty) {
      throw ArgumentError('Room number cannot be empty');
    }

    final buildingName = building.name.isNotEmpty ? building.name : '알 수 없는 건물';
    final safeRoomNumber = roomNumber.isNotEmpty ? roomNumber : '알 수 없는 호실';
    final displayName = '$buildingName ${safeRoomNumber}호';

    final searchTextParts = <String>[
      buildingName,
      '${safeRoomNumber}호',
      roomDescription?.isNotEmpty == true ? roomDescription! : '',
      if (roomUser != null && roomUser.isNotEmpty)
        roomUser.where((u) => u.isNotEmpty).join(' '),
    ].where((part) => part.isNotEmpty).toList();

    return SearchResult(
      type: SearchResultType.room,
      displayName: displayName,
      searchText: searchTextParts.join(' '),
      building: building,
      roomNumber: safeRoomNumber,
      floorNumber: floorNumber,
      roomDescription: roomDescription,
      roomUser: roomUser,
      roomPhone: roomPhone,
      roomEmail: roomEmail,
    );
  }

  bool get isBuilding => type == SearchResultType.building;

  bool get isRoom => type == SearchResultType.room && roomNumber != null && roomNumber!.isNotEmpty;

  String get fullDisplayName {
    if (isRoom) {
      final buildingName = building.name.isNotEmpty ? building.name : '알 수 없는 건물';
      final floor = floorNumber != null && floorNumber! > 0 ? '${floorNumber}층 ' : '';
      final room = roomNumber != null && roomNumber!.isNotEmpty ? '${roomNumber}호' : '알 수 없는 호실';
      return '$buildingName $floor$room';
    }
    return displayName.isNotEmpty ? displayName : '알 수 없는 건물';
  }

  String get searchableText {
    final parts = <String>[];

    if (building.name.isNotEmpty) parts.add(building.name.toLowerCase());
    if (displayName.isNotEmpty) parts.add(displayName.toLowerCase());
    if (roomNumber != null && roomNumber!.isNotEmpty) parts.add(roomNumber!.toLowerCase());
    if (roomDescription != null && roomDescription!.isNotEmpty) parts.add(roomDescription!.toLowerCase());

    if (roomUser != null && roomUser!.isNotEmpty) {
      parts.add(roomUser!
          .where((user) => user.isNotEmpty)
          .map((user) => user.toLowerCase())
          .join(' '));
    }

    return parts.join(' ');
  }

  Building toBuildingWithRoomLocation() {
    if (isRoom) {
      final buildingName = building.name.isNotEmpty ? building.name : '알 수 없는 건물';
      final roomInfo = roomNumber != null && roomNumber!.isNotEmpty ? roomNumber! : '알 수 없는 호실';
      final description = 'floor:${floorNumber ?? 1},room:$roomInfo';

      return Building(
        name: buildingName,
        info: roomDescription?.isNotEmpty == true ? roomDescription! : '$buildingName ${roomInfo}호',
        lat: building.lat,
        lng: building.lng,
        category: building.category.isNotEmpty ? building.category : '강의실',
        baseStatus: building.baseStatus.isNotEmpty ? building.baseStatus : '사용가능',
        hours: building.hours,
        phone: building.phone,
        imageUrl: building.imageUrl,
        description: description,
      );
    }
    return building;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchResult &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          building == other.building &&
          displayName == other.displayName &&
          roomNumber == other.roomNumber &&
          floorNumber == other.floorNumber &&
          listEquals(other.roomUser, roomUser);

  @override
  int get hashCode =>
      type.hashCode ^
      building.hashCode ^
      displayName.hashCode ^
      (roomNumber?.hashCode ?? 0) ^
      (floorNumber?.hashCode ?? 0) ^
      (roomUser?.join('').hashCode ?? 0);

  @override
  String toString() =>
      'SearchResult{type: $type, building: ${building.name}, displayName: $displayName, roomNumber: $roomNumber, floorNumber: $floorNumber, roomUser: $roomUser}';
}

/// 검색 결과 그룹화 확장
extension SearchResultGrouping on List<SearchResult> {
  Map<Building, List<SearchResult>> groupByBuilding() {
    final Map<Building, List<SearchResult>> grouped = {};
    for (final result in this) {
      grouped.putIfAbsent(result.building, () => []).add(result);
    }
    return grouped;
  }

  Map<SearchResultType, List<SearchResult>> groupByType() {
    final Map<SearchResultType, List<SearchResult>> grouped = {};
    for (final result in this) {
      grouped.putIfAbsent(result.type, () => []).add(result);
    }
    return grouped;
  }

  List<SearchResult> get buildingsOnly => where((result) => result.isBuilding).toList();

  List<SearchResult> get roomsOnly => where((result) => result.isRoom).toList();

  List<SearchResult> fromBuilding(Building building) =>
      where((result) => result.building == building).toList();
}
