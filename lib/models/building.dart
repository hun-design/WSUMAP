import 'package:flutter/material.dart';
import 'package:flutter_application_1/generated/app_localizations.dart';

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
  final List<String>? imageUrls; // 서버에서 받아온 이미지 URL 배열
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

  String get status => calculateCurrentStatus();

  String calculateCurrentStatus() {
    print('🔍 calculateCurrentStatus 호출됨');
    print('🔍 baseStatus: $baseStatus');

    if (baseStatus != '운영중' && baseStatus != 'open') {
      print('🔍 baseStatus가 운영중/open이 아님, 반환: $baseStatus');
      return baseStatus;
    }

    final now = DateTime.now();
    final currentHour = now.hour;
    print('🔍 현재 시간: ${now.hour}시');

    if (currentHour >= 9 && currentHour < 18) {
      final result = baseStatus == 'open' ? 'open' : '운영중';
      print('🔍 운영 시간대, 반환: $result');
      return result;
    } else {
      final result = baseStatus == 'open' ? 'closed' : '운영종료';
      print('🔍 비운영 시간대, 반환: $result');
      return result;
    }
  }

  String getLocalizedStatus(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentStatus = status;

    switch (currentStatus) {
      case '운영중':
      case 'open':
        return l10n.status_open; // "Open"
      case '운영종료':
      case 'closed':
        return l10n.status_closed; // "Closed"
      case '24시간':
      case '24hours':
        return l10n.status_24hours; // "24 Hours"
      case '임시휴무':
      case 'temp_closed':
        return l10n.status_temp_closed; // "Temporarily Closed"
      case '영구휴업':
      case 'closed_permanently':
        return l10n.status_closed_permanently; // "Permanently Closed"
      default:
        return currentStatus; // 그 외 상태 문자열 그대로 출력
    }
  }

  String getLocalizedNextStatusChangeTime(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final currentHour = now.hour;

    // baseStatus도 영어, 한글 둘 다 처리
    if (baseStatus != '운영중' && baseStatus != 'open')
      return getLocalizedStatus(context);

    if (currentHour < 9) {
      return l10n.status_next_open; // 예: Opens at 9:00 AM
    } else if (currentHour < 18) {
      return l10n.status_next_close; // 예: Closes at 6:00 PM
    } else {
      return l10n.status_next_open_tomorrow; // 예: Opens tomorrow at 9:00 AM
    }
  }

  bool get isOpen => status == '운영중' || status == 'open';
  
  /// 현재 위치인지 확인하는 getter
  bool get isMyLocation {
    return name == '내 위치' ||
           name == '내위치' ||
           name == 'My Location' ||
           name == '当前位置' ||
           name == 'Mi ubicación' ||
           name == 'Мое местоположение' ||
           name == 'マイ場所' ||
           name == '현재위치' ||
           name == 'Current Location' ||
           name == 'Ubicación actual' ||
           name == 'Текущее местоположение' ||
           name == '現在地';
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
      print('📋 서버 응답 원본: $json');

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
        latitude = (locationField['x'] ?? locationField['lat'] ?? 0.0)
            .toDouble();
        longitude = (locationField['y'] ?? locationField['lng'] ?? 0.0)
            .toDouble();
      }

      if (latitude == 0.0 && longitude == 0.0) {
        latitude = (json['lat'] ?? json['latitude'] ?? 0.0).toDouble();
        longitude = (json['lng'] ?? json['longitude'] ?? 0.0).toDouble();
      }

      print('📍 파싱된 좌표: ($latitude, $longitude)');

      // category를 다국어 키로 매핑
      final String category = _mapBuildingNameToCategory(buildingName);

      // status는 서버로부터 영어 키 혹은 상태 문자열로 받는다
      final String baseStatus =
          json['baseStatus'] ?? json['status'] ?? 'open'; // English key!

      // imageUrls 파싱 - Image 필드가 배열로 오는 경우 처리
      List<String>? imageUrls;
      if (json['Image'] is List) {
        imageUrls = List<String>.from(
          json['Image'],
        ).map((url) => url.toString()).toList();
        print('🖼️ 서버 이미지 URL 배열: $imageUrls');
      } else if (json['File'] is List) {
        imageUrls = List<String>.from(
          json['File'],
        ).map((url) => url.toString()).toList();
        print('🖼️ 서버 이미지 URL 배열 (File): $imageUrls');
      } else if (json['imageUrls'] is List) {
        imageUrls = List<String>.from(
          json['imageUrls'],
        ).map((url) => url.toString()).toList();
        print('🖼️ 서버 이미지 URL 배열 (imageUrls): $imageUrls');
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
        imageUrl: imageUrls?.isNotEmpty == true
            ? imageUrls![0]
            : null, // 첫 번째 이미지를 기본 이미지로 사용
        imageUrls: imageUrls,
        description: description,
      );
    } catch (e) {
      print('❌ Building.fromServerJson 오류: $e');
      print('📋 문제가 된 JSON: $json');
      return Building(
        name:
            json['Building_Name']?.toString() ??
            json['name']?.toString() ??
            'Unknown',
        info: json['Description']?.toString() ?? json['info']?.toString() ?? '',
        lat: 36.337,
        lng: 127.445,
        category: 'etc', // 영어 key로 fallback
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
    } else if (name.contains('기숙사') ||
        name.contains('생활관') ||
        name.contains('숙')) {
      return '기숙사';
    } else if (name.contains('카페') ||
        name.contains('cafe') ||
        name.contains('솔카페') ||
        name.contains('스타리코')) {
      return '카페';
    } else if (name.contains('식당') ||
        name.contains('restaurant') ||
        name.contains('베이커리') ||
        name.contains('레스토랑')) {
      return '식당';
    } else if (name.contains('체육관') ||
        name.contains('스포츠') ||
        name.contains('gym')) {
      return '체육시설';
    } else if (name.contains('유치원')) {
      return '유치원';
    } else if (name.contains('학군단')) {
      return '군사시설';
    } else if (name.contains('타워') || name.contains('tower')) {
      return '복합시설';
    } else if (name.contains('회관') ||
        name.contains('관') ||
        name.contains('center') ||
        name.contains('학과') ||
        name.contains('전공') ||
        name.contains('학부') ||
        name.contains('교육') ||
        name.contains('강의') ||
        name.contains('실습')) {
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

  // 🔥 추가: 방 정보로부터 Building 객체를 생성하는 팩토리 메서드
  static Building fromRoomInfo(Map<String, dynamic> roomInfo) {
    final String roomId = roomInfo['roomId'] ?? '';
    final String roomName = roomId.startsWith('R')
        ? roomId.substring(1)
        : roomId;
    final String buildingName = roomInfo['buildingName'] ?? '';
    final int? floorNumber = roomInfo['floorNumber'];

    return Building(
      name: '$buildingName $roomName호',
      info: '${floorNumber ?? ''}층 $roomName호',
      lat: 0.0, // 실제 좌표는 API에서 가져와야 함
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
  String toString() {
    return 'Building(name: $name, lat: $lat, lng: $lng, category: $category, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Building && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
