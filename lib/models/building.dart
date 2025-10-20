// lib/models/building.dart - 최적화된 버전

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/generated/app_localizations.dart';

/// 건물 모델
class Building {
  final String name;
  final String info;
  final double lat;
  final double lng;
  final String category;
  final String baseStatus;
  final String hours;
  final String phone;
  final String? imageUrl;
  final List<String>? imageUrls;
  final String description;

  const Building({
    required this.name,
    required this.info,
    required this.lat,
    required this.lng,
    required this.category,
    required this.baseStatus,
    required this.hours,
    required this.phone,
    this.imageUrl,
    this.imageUrls,
    required this.description,
  });

  String get status => _calculateCurrentStatus();

  String _calculateCurrentStatus() {
    if (baseStatus != '운영중' && baseStatus != 'open') {
      return baseStatus;
    }

    final now = DateTime.now();
    final currentHour = now.hour;

    if (currentHour >= 9 && currentHour < 18) {
      return baseStatus == 'open' ? 'open' : '운영중';
    } else {
      return baseStatus == 'open' ? 'closed' : '운영종료';
    }
  }

  String getLocalizedStatus(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentStatus = status;

    switch (currentStatus) {
      case '운영중':
      case 'open':
        return l10n.status_open;
      case '운영종료':
      case 'closed':
        return l10n.status_closed;
      case '24시간':
      case '24hours':
        return l10n.status_24hours;
      case '임시휴무':
      case 'temp_closed':
        return l10n.status_temp_closed;
      case '영구휴업':
      case 'closed_permanently':
        return l10n.status_closed_permanently;
      default:
        return currentStatus;
    }
  }

  String getLocalizedNextStatusChangeTime(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final currentHour = now.hour;

    if (baseStatus != '운영중' && baseStatus != 'open') {
      return getLocalizedStatus(context);
    }

    if (currentHour < 9) {
      return l10n.status_next_open;
    } else if (currentHour < 18) {
      return l10n.status_next_close;
    } else {
      return l10n.status_next_open_tomorrow;
    }
  }

  bool get isOpen => status == '운영중' || status == 'open';

  bool get isMyLocation {
    const locationNames = {
      '내 위치',
      '내위치',
      'My Location',
      '当前位置',
      'Mi ubicación',
      'Мое местоположение',
      'マイ場所',
      '현재위치',
      'Current Location',
      'Ubicación actual',
      'Текущее местоположение',
      '現在地',
    };
    return locationNames.contains(name);
  }

  String get nextStatusChangeTime {
    final now = DateTime.now();
    final currentHour = now.hour;
    if (baseStatus != '운영중' && baseStatus != 'open') return baseStatus;
    if (currentHour < 9) {
      return '오전 9시에 운영 시작';
    } else if (currentHour < 18) {
      return '오후 6시에 운영 종료';
    } else {
      return '내일 오전 9시에 운영 시작';
    }
  }

  String get formattedHours {
    if (baseStatus != '운영중' && baseStatus != 'open') return baseStatus;
    return '09:00 - 18:00';
  }

  String get statusIcon {
    switch (status) {
      case '운영중':
      case 'open':
        return '🟢';
      case '운영종료':
      case 'closed':
        return '🔴';
      default:
        return '⚪';
    }
  }

  Color get statusColor {
    switch (status) {
      case '운영중':
      case 'open':
        return const Color(0xFF10B981);
      case '운영종료':
      case 'closed':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      name: json['name'] ?? '',
      info: json['info'] ?? '',
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
      category: json['category'] ?? '기타',
      baseStatus: json['baseStatus'] ?? json['status'] ?? '운영중',
      hours: json['hours'] ?? '09:00 - 18:00',
      phone: json['phone'] ?? '',
      imageUrl: json['imageUrl'],
      description: json['description'] ?? '',
    );
  }

  factory Building.fromServerJson(Map<String, dynamic> json) {
    try {
      if (kDebugMode) {
        debugPrint('📋 서버 응답 원본: $json');
      }

      final String buildingName = json['Building_Name'] ?? json['name'] ?? '';
      final String description =
          json['Description'] ?? json['info'] ?? json['description'] ?? '';

      double latitude = 0.0;
      double longitude = 0.0;

      // 좌표 값 파싱
      final locationField = json['Location'];
      if (locationField is String) {
        final cleaned = locationField.replaceAll('(', '').replaceAll(')', '');
        final coords = cleaned.split(',');
        if (coords.length == 2) {
          latitude = double.tryParse(coords[0].trim()) ?? 0.0;
          longitude = double.tryParse(coords[1].trim()) ?? 0.0;
        }
      } else if (locationField is Map<String, dynamic>) {
        latitude = (locationField['x'] ?? locationField['lat'] ?? 0.0).toDouble();
        longitude = (locationField['y'] ?? locationField['lng'] ?? 0.0).toDouble();
      }

      if (latitude == 0.0 && longitude == 0.0) {
        latitude = (json['lat'] ?? json['latitude'] ?? 0.0).toDouble();
        longitude = (json['lng'] ?? json['longitude'] ?? 0.0).toDouble();
      }

      if (kDebugMode) {
        debugPrint('📍 파싱된 좌표: ($latitude, $longitude)');
      }

      final String category = _mapBuildingNameToCategory(buildingName);
      final String baseStatus = json['baseStatus'] ?? json['status'] ?? 'open';

      // imageUrls 파싱
      List<String>? imageUrls;
      if (json['Image'] is List) {
        imageUrls = List<String>.from(json['Image']).map((url) => url.toString()).toList();
        if (kDebugMode) {
          debugPrint('🖼️ 서버 이미지 URL 배열: $imageUrls');
        }
      } else if (json['File'] is List) {
        imageUrls = List<String>.from(json['File']).map((url) => url.toString()).toList();
        if (kDebugMode) {
          debugPrint('🖼️ 서버 이미지 URL 배열 (File): $imageUrls');
        }
      } else if (json['imageUrls'] is List) {
        imageUrls = List<String>.from(json['imageUrls']).map((url) => url.toString()).toList();
        if (kDebugMode) {
          debugPrint('🖼️ 서버 이미지 URL 배열 (imageUrls): $imageUrls');
        }
      }

      return Building(
        name: buildingName,
        info: description,
        lat: latitude,
        lng: longitude,
        category: category,
        baseStatus: baseStatus,
        hours: json['hours'] ?? '09:00 - 18:00',
        phone: json['phone'] ?? '042-821-5678',
        imageUrl: imageUrls?.isNotEmpty == true ? imageUrls![0] : null,
        imageUrls: imageUrls,
        description: description,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Building.fromServerJson 오류: $e');
        debugPrint('📋 문제가 된 JSON: $json');
      }
      return Building(
        name: json['Building_Name']?.toString() ?? json['name']?.toString() ?? 'Unknown',
        info: json['Description']?.toString() ?? json['info']?.toString() ?? '',
        lat: 36.337,
        lng: 127.445,
        category: 'etc',
        baseStatus: 'open',
        hours: '09:00 - 18:00',
        phone: '042-821-5678',
        imageUrl: null,
        imageUrls: null,
        description: '',
      );
    }
  }

  static String _mapBuildingNameToCategory(String buildingName) {
    final name = buildingName.toLowerCase();
    if (name.contains('도서관') || name.contains('library')) {
      return '도서관';
    } else if (name.contains('기숙사') || name.contains('생활관') || name.contains('숙')) {
      return '기숙사';
    } else if (name.contains('카페') || name.contains('cafe') || name.contains('솔카페') || name.contains('스타리코')) {
      return '카페';
    } else if (name.contains('식당') || name.contains('restaurant') || name.contains('베이커리') || name.contains('레스토랑')) {
      return '식당';
    } else if (name.contains('체육관') || name.contains('스포츠') || name.contains('gym')) {
      return '체육시설';
    } else if (name.contains('유치원')) {
      return '유치원';
    } else if (name.contains('학군단')) {
      return '군사시설';
    } else if (name.contains('타워') || name.contains('tower')) {
      return '복합시설';
    } else if (name.contains('회관') || name.contains('관') || name.contains('center') ||
        name.contains('학과') || name.contains('전공') || name.contains('학부') ||
        name.contains('교육') || name.contains('강의') || name.contains('실습')) {
      return '교육시설';
    } else {
      return '기타';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'info': info,
      'lat': lat,
      'lng': lng,
      'category': category,
      'baseStatus': baseStatus,
      'status': status,
      'hours': hours,
      'phone': phone,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'description': description,
    };
  }

  Map<String, dynamic> toServerJson() {
    return {
      'Building_Name': name,
      'Location': '($lat,$lng)',
      'Description': info,
      'File': imageUrls ?? (imageUrl != null ? [imageUrl!] : []),
    };
  }

  Building copyWith({
    String? name,
    String? info,
    double? lat,
    double? lng,
    String? category,
    String? baseStatus,
    String? hours,
    String? phone,
    String? imageUrl,
    List<String>? imageUrls,
    String? description,
  }) {
    return Building(
      name: name ?? this.name,
      info: info ?? this.info,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      category: category ?? this.category,
      baseStatus: baseStatus ?? this.baseStatus,
      hours: hours ?? this.hours,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      description: description ?? this.description,
    );
  }

  static Building fromRoomInfo(Map<String, dynamic> roomInfo) {
    final String roomId = roomInfo['roomId'] ?? '';
    final String roomName = roomId.startsWith('R') ? roomId.substring(1) : roomId;
    final String buildingName = roomInfo['buildingName'] ?? '';
    final int? floorNumber = roomInfo['floorNumber'];

    return Building(
      name: '$buildingName $roomName호',
      info: '${floorNumber ?? ''}층 $roomName호',
      lat: 0.0,
      lng: 0.0,
      category: '강의실',
      baseStatus: '사용가능',
      hours: '',
      phone: '',
      imageUrl: '',
      description: '$buildingName ${floorNumber ?? ''}층 $roomName호',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Building &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() =>
      'Building(name: $name, lat: $lat, lng: $lng, category: $category, status: $status)';
}
