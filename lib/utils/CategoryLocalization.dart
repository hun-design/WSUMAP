// lib/utils/category_localization.dart - 최적화된 버전

import 'package:flutter/material.dart';
import 'package:flutter_application_1/generated/app_localizations.dart';

/// 카테고리 다국어 변환
class CategoryLocalization {
  static String getLabel(BuildContext context, String id) {
    final l10n = AppLocalizations.of(context)!;

    // 영어 ID들
    switch (id) {
      case 'cafe':
      case '카페':
        return l10n.cafe;
      case 'restaurant':
      case '식당':
        return l10n.restaurant;
      case 'convenience':
      case '편의점':
        return l10n.convenience_store;
      case 'vending':
      case '자판기':
        return l10n.vending_machine;
      case 'water':
      case 'water_purifier':
      case '정수기':
        return l10n.water_purifier;
      case 'printer':
      case '프린터':
        return l10n.printer;
      case 'copier':
      case '복사기':
        return l10n.copier;
      case 'atm':
      case 'bank':
      case 'ATM':
      case '은행(atm)':
      case 'bank_atm':
        return l10n.atm;
      case 'fire_extinguisher':
      case 'extinguisher':
      case '소화기':
        return l10n.extinguisher;
      case 'post_office':
      case 'post':
      case '우체국':
        return l10n.post_office;
      case 'medical':
      case '의료':
        return l10n.medical;
      case 'health_center':
      case '보건소':
        return l10n.health_center;
      case 'library':
      case '도서관':
        return l10n.library;
      case 'bookstore':
      case '서점':
        return l10n.bookstore;
      case 'gym':
      case '헬스장':
        return l10n.gym;
      case 'fitness_center':
      case '체육관':
        return l10n.fitness_center;
      case 'lounge':
      case '라운지':
        return l10n.lounge;
      default:
        return id;
    }
  }
}
