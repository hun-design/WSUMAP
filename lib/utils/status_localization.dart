// lib/utils/status_localization.dart - 최적화된 버전

import 'package:flutter/material.dart';
import 'package:flutter_application_1/generated/app_localizations.dart';

/// 상태 텍스트를 다국어로 변환
String getLocalizedStatusText(BuildContext context, String status) {
  final l10n = AppLocalizations.of(context)!;
  
  switch (status) {
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
    case '휴무':
    case 'closed_permanently':
      return l10n.status_closed_permanently;
    default:
      return status;
  }
}
