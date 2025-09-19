// lib/utils/ios_location_utils.dart - iOS 위치 서비스 최적화 유틸리티

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;

/// iOS 위치 서비스 최적화 유틸리티
class IOSLocationUtils {
  /// iOS에서 위치 요청 시 권장 설정
  static Map<String, dynamic> getIOSLocationSettings() {
    if (Platform.isIOS) {
      return {
        'accuracy': loc.LocationAccuracy.high,
        'distanceFilter': 1, // 1미터마다 업데이트
      };
    } else {
      return {
        'accuracy': loc.LocationAccuracy.high,
        'distanceFilter': 1,
      };
    }
  }

  /// iOS에서 위치 권한 요청 시 권장 설정
  static Map<String, dynamic> getIOSPermissionSettings() {
    if (Platform.isIOS) {
      return {
        'accuracy': loc.LocationAccuracy.high,
        'distanceFilter': 1,
      };
    } else {
      return {
        'accuracy': loc.LocationAccuracy.high,
        'distanceFilter': 1,
      };
    }
  }

  /// iOS에서 위치 데이터 유효성 검증 강화
  static bool isValidIOSLocation(loc.LocationData? locationData) {
    if (locationData == null) return false;
    
    // 기본 유효성 검사
    if (locationData.latitude == null || locationData.longitude == null) {
      return false;
    }

    // iOS 특화 검사
    if (Platform.isIOS) {
      // iOS에서는 정확도가 더 중요
      if (locationData.accuracy != null && locationData.accuracy! > 100) {
        debugPrint('⚠️ iOS 위치 정확도 부족: ${locationData.accuracy}m');
        return false;
      }

      // iOS에서는 시간 정보도 중요
      if (locationData.time != null) {
        final locationTime = DateTime.fromMillisecondsSinceEpoch(
          locationData.time!.toInt(),
        );
        final now = DateTime.now();
        final timeDiff = now.difference(locationTime);
        
        // 5분 이상 된 위치는 무효
        if (timeDiff.inMinutes > 5) {
          debugPrint('⚠️ iOS 위치 시간 초과: ${timeDiff.inMinutes}분 전');
          return false;
        }
      }
    }

    return true;
  }

  /// iOS에서 위치 요청 타임아웃 설정
  static Duration getIOSLocationTimeout() {
    return Platform.isIOS 
        ? const Duration(seconds: 8)  // iOS는 더 긴 시간 필요
        : const Duration(seconds: 5); // Android는 상대적으로 빠름
  }

  /// iOS에서 권한 요청 타임아웃 설정
  static Duration getIOSPermissionTimeout() {
    return Platform.isIOS 
        ? const Duration(seconds: 10)  // iOS 권한 요청은 더 오래 걸림
        : const Duration(seconds: 5);
  }

  /// iOS에서 위치 서비스 활성화 요청 타임아웃 설정
  static Duration getIOSServiceTimeout() {
    return Platform.isIOS 
        ? const Duration(seconds: 8)  // iOS 서비스 요청도 더 오래 걸림
        : const Duration(seconds: 3);
  }

  /// iOS 위치 에러 메시지 처리
  static String getIOSLocationErrorMessage(dynamic error) {
    if (Platform.isIOS) {
      if (error.toString().contains('denied')) {
        return 'iOS에서 위치 권한이 거부되었습니다. 설정에서 위치 권한을 허용해주세요.';
      } else if (error.toString().contains('disabled')) {
        return 'iOS에서 위치 서비스가 비활성화되었습니다. 설정에서 위치 서비스를 켜주세요.';
      } else if (error.toString().contains('timeout')) {
        return 'iOS에서 위치 요청 시간이 초과되었습니다. 잠시 후 다시 시도해주세요.';
      }
    }
    
    return '위치를 찾을 수 없습니다. 잠시 후 다시 시도해주세요.';
  }

  /// iOS 위치 요청 재시도 간격
  static Duration getIOSRetryInterval() {
    return Platform.isIOS 
        ? const Duration(seconds: 2)  // iOS는 더 긴 간격 필요
        : const Duration(seconds: 1);
  }

  /// iOS에서 위치 캐시 유효 시간
  static Duration getIOSCacheValidDuration() {
    return Platform.isIOS 
        ? const Duration(minutes: 3)  // iOS는 더 긴 캐시 유효 시간
        : const Duration(minutes: 2);
  }
}
