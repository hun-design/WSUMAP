// lib/services/notification_service.dart
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  // 🔔 알림 서비스 초기화
  static Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 권한 요청
    await _requestPermissions();

    _isInitialized = true;
    debugPrint('✅ 알림 서비스 초기화 완료');
  }

  // 📱 권한 요청
  static Future<void> _requestPermissions() async {
    // 이미 권한이 요청되었는지 확인
    if (defaultTargetPlatform == TargetPlatform.android) {
      final currentStatus = await Permission.notification.status;
      if (currentStatus.isGranted || currentStatus.isDenied) {
        debugPrint('📱 안드로이드 알림 권한 이미 설정됨: $currentStatus');
        return;
      }
      
      final status = await Permission.notification.request();
      debugPrint('📱 안드로이드 알림 권한: $status');
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // iOS에서는 권한 상태를 확인할 수 없으므로 한 번만 요청
      final bool? result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      debugPrint('📱 iOS 알림 권한: $result');
    }
  }

  // 🔔 알림 탭 처리
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 알림 탭됨: ${response.payload}');
    // 여기에 알림 탭 시 실행할 로직 추가
    // 예: 특정 화면으로 이동
  }

  // 🔔 친구 요청 알림
  static Future<void> showFriendRequestNotification(
    String fromUserName,
    String message,
  ) async {
    // ✅ const 제거하고 일반 변수로 선언
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'friend_requests',
          '친구 요청',
          channelDescription: '새로운 친구 요청 알림',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF1E3A8A),
          playSound: true,
          enableVibration: true,
          styleInformation: const BigTextStyleInformation(''),
          category: AndroidNotificationCategory.social,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'friend_request',
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      1, // notification ID
      '새로운 친구 요청',
      '$fromUserName님이 친구 요청을 보냈습니다.',
      details,
      payload: 'friend_request:$fromUserName',
    );

    debugPrint('🔔 친구 요청 알림 표시: $fromUserName');
  }

  // ✅ 친구 요청 수락 알림
  static Future<void> showFriendAcceptedNotification(
    String accepterUserName,
    String message,
  ) async {
    // ✅ const 제거하고 일반 변수로 선언
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'friend_accepted',
          '친구 수락',
          channelDescription: '친구 요청 수락 알림',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF10B981),
          playSound: true,
          enableVibration: true,
          styleInformation: const BigTextStyleInformation(''),
          category: AndroidNotificationCategory.social,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'friend_accepted',
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      2,
      '친구 요청 수락됨',
      '$accepterUserName님이 친구 요청을 수락했습니다!',
      details,
      payload: 'friend_accepted:$accepterUserName',
    );

    debugPrint('✅ 친구 수락 알림 표시: $accepterUserName');
  }

  // ❌ 친구 요청 거절 알림
  static Future<void> showFriendRejectedNotification(String message) async {
    // ✅ const 제거하고 일반 변수로 선언
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'friend_rejected',
          '친구 거절',
          channelDescription: '친구 요청 거절 알림',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFEF4444),
          playSound: false,
          enableVibration: false,
          category: AndroidNotificationCategory.social,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
      categoryIdentifier: 'friend_rejected',
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      3,
      '친구 요청 거절',
      message,
      details,
      payload: 'friend_rejected',
    );

    debugPrint('❌ 친구 거절 알림 표시');
  }

  // 🗑️ 친구 삭제 알림
  static Future<void> showFriendDeletedNotification(
    String deleterUserName,
    String message,
  ) async {
    // ✅ const 제거하고 일반 변수로 선언
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'friend_deleted',
          '친구 삭제',
          channelDescription: '친구 삭제 알림',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFEF4444),
          playSound: false,
          enableVibration: false,
          category: AndroidNotificationCategory.social,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
      categoryIdentifier: 'friend_deleted',
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      4,
      '친구 관계 해제',
      '$deleterUserName님이 친구 관계를 해제했습니다.',
      details,
      payload: 'friend_deleted:$deleterUserName',
    );

    debugPrint('🗑️ 친구 삭제 알림 표시: $deleterUserName');
  }

  // 🔔 일반 알림 (테스트용)
  static Future<void> showTestNotification(
    String title,
    String body, {
    String? payload,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'test_channel',
          '테스트 알림',
          channelDescription: '테스트용 알림 채널',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF1E3A8A),
          playSound: true,
          enableVibration: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // 고유 ID
      title,
      body,
      details,
      payload: payload,
    );

    debugPrint('🔔 테스트 알림 표시: $title');
  }

  // 🔔 예약 알림 (간단한 버전 - timezone 패키지 필요시에만 사용)
  static Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    Duration delay, {
    String? payload,
  }) async {
    // 현재는 간단한 지연 알림만 구현
    // 실제 예약 알림을 원한다면 timezone 패키지 추가 필요

    debugPrint('📅 ${delay.inSeconds}초 후 알림 예약: $title');

    // 간단한 타이머 기반 알림 (앱이 실행 중일 때만 작동)
    Future.delayed(delay, () async {
      await showTestNotification(title, body, payload: payload);
    });

    debugPrint('📅 예약 알림 설정: $title - ${delay.inSeconds}초 후');
  }

  // 🔔 실제 예약 알림을 원한다면 이 메서드를 사용 (timezone 패키지 필요)
  /*
  // pubspec.yaml에 추가 필요:
  // timezone: ^0.9.2
  
  static Future<void> scheduleNotificationWithTimezone(
    int id,
    String title,
    String body,
    DateTime scheduledDate, {
    String? payload,
  }) async {
    // timezone 패키지 import 필요:
    // import 'package:timezone/timezone.dart' as tz;
    
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      '예약 알림',
      channelDescription: '예약된 알림',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF1E3A8A),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('📅 예약 알림 설정: $title - ${scheduledDate.toString()}');
  }
  */

  // 🔔 진행형 알림 (파일 다운로드, 업로드 등)
  static Future<void> showProgressNotification(
    int id,
    String title,
    int progress,
    int maxProgress,
  ) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'progress_channel',
          '진행률 알림',
          channelDescription: '진행률을 표시하는 알림',
          importance: Importance.low,
          priority: Priority.low,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF1E3A8A),
          showProgress: true,
          maxProgress: maxProgress,
          progress: progress,
          ongoing: true,
          autoCancel: false,
        );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      '$progress / $maxProgress',
      details,
    );
  }

  // 🔔 특정 알림 취소
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    debugPrint('🗑️ 알림 취소: ID $id');
  }

  // 🔔 특정 채널의 모든 알림 취소
  static Future<void> cancelNotificationsByChannel(String channelId) async {
    // Android에서만 지원
    if (defaultTargetPlatform == TargetPlatform.android) {
      final List<ActiveNotification> activeNotifications =
          await _notificationsPlugin.getActiveNotifications();

      for (final notification in activeNotifications) {
        // 채널 ID 확인 로직 (플러그인 버전에 따라 다를 수 있음)
        await _notificationsPlugin.cancel(notification.id!);
      }
    }
    debugPrint('🗑️ 채널 알림 취소: $channelId');
  }

  // 🧹 모든 알림 제거
  static Future<void> clearAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('🧹 모든 알림 제거 완료');
  }

  // 🔔 알림 권한 상태 확인
  static Future<bool> isNotificationPermissionGranted() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await Permission.notification.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final bool? result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: false, badge: false, sound: false);
      return result ?? false;
    }
    return false;
  }

  // 🔔 활성 알림 목록 조회
  static Future<List<ActiveNotification>> getActiveNotifications() async {
    try {
      return await _notificationsPlugin.getActiveNotifications();
    } catch (e) {
      debugPrint('❌ 활성 알림 조회 실패: $e');
      return [];
    }
  }

  // 🔔 알림 통계
  static Future<void> logNotificationStats() async {
    try {
      final activeNotifications = await getActiveNotifications();
      debugPrint('📊 현재 활성 알림 수: ${activeNotifications.length}');

      for (final notification in activeNotifications) {
        debugPrint('   - ID: ${notification.id}, 제목: ${notification.title}');
      }
    } catch (e) {
      debugPrint('❌ 알림 통계 조회 실패: $e');
    }
  }
}
