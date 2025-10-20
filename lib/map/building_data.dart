// lib/map/building_data.dart - 최적화된 버전

import 'package:flutter/material.dart';
import '../models/building.dart';
import '../generated/app_localizations.dart';

/// 건물 데이터 제공자
class BuildingDataProvider {
  
  /// 건물 데이터 목록 가져오기
  static List<Building> getBuildingData(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return [
      _createBuilding(
        name: l10n.woosong_library_w1,
        info: l10n.woosong_library_info,
        lat: 36.338133,
        lng: 127.446423,
        category: l10n.educational_facility,
        description: l10n.woosong_library_desc,
      ),
      _createBuilding(
        name: l10n.sol_cafe,
        info: l10n.sol_cafe_info,
        lat: 36.337923,
        lng: 127.445895,
        category: l10n.cafe,
        description: l10n.sol_cafe_desc,
      ),
      _createBuilding(
        name: l10n.cheongun_1_dormitory,
        info: l10n.cheongun_1_dormitory_info,
        lat: 36.338490,
        lng: 127.447739,
        category: l10n.dormitory,
        description: l10n.cheongun_1_dormitory_desc,
      ),
      _createBuilding(
        name: l10n.industry_cooperation_w2,
        info: l10n.industry_cooperation_info,
        lat: 36.339574,
        lng: 127.447216,
        category: l10n.educational_facility,
        description: l10n.industry_cooperation_desc,
      ),
      _createBuilding(
        name: l10n.rotc_w2_1,
        info: l10n.rotc_info,
        lat: 36.339525,
        lng: 127.447818,
        category: l10n.military_facility,
        description: l10n.rotc_desc,
      ),
      _createBuilding(
        name: l10n.international_dormitory_w3,
        info: l10n.international_dormitory_info,
        lat: 36.339512,
        lng: 127.446549,
        category: l10n.dormitory,
        description: l10n.international_dormitory_desc,
      ),
      _createBuilding(
        name: l10n.railway_logistics_w4,
        info: l10n.railway_logistics_info,
        lat: 36.338741,
        lng: 127.445409,
        category: l10n.educational_facility,
        description: l10n.railway_logistics_desc,
      ),
      _createBuilding(
        name: l10n.health_medical_science_w5,
        info: l10n.health_medical_science_info,
        lat: 36.338009,
        lng: 127.445167,
        category: l10n.educational_facility,
        description: l10n.health_medical_science_desc,
      ),
      _createBuilding(
        name: l10n.liberal_arts_w6,
        info: l10n.liberal_arts_info,
        lat: 36.337480,
        lng: 127.445583,
        category: l10n.educational_facility,
        description: l10n.liberal_arts_desc,
      ),
      _createBuilding(
        name: l10n.woosong_hall_w7,
        info: l10n.woosong_hall_info,
        lat: 36.336983,
        lng: 127.444985,
        category: l10n.educational_facility,
        description: l10n.woosong_hall_desc,
      ),
      _createBuilding(
        name: l10n.woosong_kindergarten_w8,
        info: l10n.woosong_kindergarten_info,
        lat: 36.337491,
        lng: 127.444331,
        category: l10n.kindergarten,
        description: l10n.woosong_kindergarten_desc,
      ),
      _createBuilding(
        name: l10n.west_campus_culinary_w9,
        info: l10n.west_campus_culinary_info,
        lat: 36.337128,
        lng: 127.444084,
        category: l10n.educational_facility,
        description: l10n.west_campus_culinary_desc,
      ),
      _createBuilding(
        name: l10n.social_welfare_w10,
        info: l10n.social_welfare_info,
        lat: 36.336578,
        lng: 127.443970,
        category: l10n.educational_facility,
        description: l10n.social_welfare_desc,
      ),
      _createBuilding(
        name: l10n.gymnasium_w11,
        info: l10n.gymnasium_info,
        lat: 36.335809,
        lng: 127.443327,
        category: l10n.sports_facility,
        description: l10n.gymnasium_desc,
        hours: '06:00 - 22:00',
        phone: '042-821-1234',
      ),
      _createBuilding(
        name: l10n.sica_w12,
        info: l10n.sica_info,
        lat: 36.335536,
        lng: 127.443725,
        category: l10n.educational_facility,
        description: l10n.sica_desc,
      ),
      _createBuilding(
        name: l10n.woosong_tower_w13,
        info: l10n.woosong_tower_info,
        lat: 36.335692,
        lng: 127.444340,
        category: l10n.complex_facility,
        description: l10n.woosong_tower_desc,
        hours: '07:00 - 21:00',
        phone: '042-821-9999',
      ),
      _createBuilding(
        name: l10n.culinary_center_w14,
        info: l10n.culinary_center_info,
        lat: 36.335448,
        lng: 127.444631,
        category: l10n.educational_facility,
        description: l10n.culinary_center_desc,
      ),
      _createBuilding(
        name: l10n.food_architecture_w15,
        info: l10n.food_architecture_info,
        lat: 36.335495,
        lng: 127.445258,
        category: l10n.educational_facility,
        description: l10n.food_architecture_desc,
      ),
      _createBuilding(
        name: l10n.student_hall_w16,
        info: l10n.student_hall_info,
        lat: 36.336193,
        lng: 127.445036,
        category: l10n.educational_facility,
        description: l10n.student_hall_desc,
      ),
      _createBuilding(
        name: l10n.media_convergence_w17,
        info: l10n.media_convergence_info,
        lat: 36.335814,
        lng: 127.445801,
        category: l10n.educational_facility,
        description: l10n.media_convergence_desc,
      ),
      _createBuilding(
        name: "W17-동관",
        info: "W17 동관 시설",
        lat: 36.335814,
        lng: 127.445801,
        category: l10n.educational_facility,
        description: "W17 동관",
      ),
      _createBuilding(
        name: "W17-서관",
        info: "W17 서관 시설",
        lat: 36.335814,
        lng: 127.445801,
        category: l10n.educational_facility,
        description: "W17 서관",
      ),
      _createBuilding(
        name: l10n.woosong_arts_center_w18,
        info: l10n.woosong_arts_center_info,
        lat: 36.336378,
        lng: 127.446187,
        category: l10n.educational_facility,
        description: l10n.woosong_arts_center_desc,
      ),
      _createBuilding(
        name: l10n.west_campus_andycut_w19,
        info: l10n.west_campus_andycut_info,
        lat: 36.336659,
        lng: 127.445674,
        category: l10n.educational_facility,
        description: l10n.west_campus_andycut_desc,
      ),
    ];
  }

  /// 건물 객체 생성 헬퍼 메서드 (중복 코드 제거)
  static Building _createBuilding({
    required String name,
    required String info,
    required double lat,
    required double lng,
    required String category,
    required String description,
    String hours = '08:00 - 18:00',
    String phone = '042-821-5678',
    String? imageUrl,
  }) {
    return Building(
      name: name,
      info: info,
      lat: lat,
      lng: lng,
      category: category,
      baseStatus: 'operating',
      hours: hours,
      phone: phone,
      imageUrl: imageUrl,
      description: description,
    );
  }
}
