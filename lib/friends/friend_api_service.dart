// lib/friends/friend_api_service.dart
import 'dart:convert';
import 'friend.dart';
import 'package:flutter_application_1/config/api_config.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/api_helper.dart';

class FriendApiService {
  static String get baseUrl => ApiConfig.friendBase;

  /// 🔥 사용자 존재 여부 확인
  Future<bool> checkUserExists(String userId) async {
    try {
      print('[DEBUG] 사용자 존재 여부 확인: $userId');
      
      final authService = AuthService();
      return await authService.checkUserExists(userId);
    } catch (e) {
      print('[ERROR] 사용자 존재 여부 확인 실패: $e');
      return false;
    }
  }

  /// 내 친구 목록 조회
  Future<List<Friend>> fetchMyFriends() async {
    final res = await ApiHelper.get('$baseUrl/myfriend');
    print('[친구 목록 응답] ${res.body}');

    if (res.body.isEmpty || res.body.trim() == '{}') {
      print('[WARN] 친구 목록 응답이 비었거나 빈 객체임');
      return [];
    }

    try {
      // 🔥 서버 응답 구조에 맞게 파싱: {"success": true, "data": [...]}
      final Map<String, dynamic> responseData = jsonDecode(res.body);
      print('[친구 목록 파싱 데이터] $responseData');

      if (responseData['success'] == true && responseData['data'] != null) {
        final List<dynamic> dataList = responseData['data'];
        return dataList.map((e) => Friend.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        print('[ERROR] 서버 응답 구조가 올바르지 않음: $responseData');
        return [];
      }
    } catch (e, stack) {
      print('[ERROR] 친구 목록 파싱 실패: $e');
      print(stack);
      return [];
    }
  }

  /// 친구 상세 정보 조회
  Future<Friend?> fetchFriendInfo(String friendId) async {
    final res = await ApiHelper.get('$baseUrl/info/$friendId');
    print('[친구 정보 응답] ${res.body}');

    if (res.statusCode != 200) {
      print('[ERROR] 친구 정보 조회 실패: ${res.body}');
      return null;
    }

    try {
      final Map<String, dynamic> data = jsonDecode(res.body);
      print('[친구 정보 파싱 데이터] $data');
      return Friend.fromJson(data);
    } catch (e, stack) {
      print('[ERROR] 친구 정보 파싱 실패: $e');
      print(stack);
      return null;
    }
  }

  /// 친구 추가 요청
  Future<void> addFriend(String addId) async {
    if (addId.isEmpty) {
      throw Exception('상대방 ID가 올바르지 않습니다.');
    }

    final res = await ApiHelper.post(
      '$baseUrl/add',
      body: {'add_id': addId},
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      // 성공 응답 체크
      final responseBody = res.body.toLowerCase();
      
      if (responseBody.contains('존재하지 않는') || 
          responseBody.contains('not found') || 
          responseBody.contains('user not found') ||
          responseBody.contains('실패') ||
          responseBody.contains('fail') ||
          responseBody.contains('error') ||
          responseBody.contains('불가능') ||
          responseBody.contains('이미') ||
          responseBody.contains('자기 자신')) {
        throw Exception('친구 추가에 실패했습니다: ${res.body}');
      }
    } else {
      // 에러 응답 처리
      String errorMessage = _getErrorMessageFromResponse(res.statusCode, res.body);
      throw Exception(errorMessage);
    }
  }

  // 상태 코드별 에러 메시지 생성
  String _getErrorMessageFromResponse(int statusCode, String responseBody) {
    switch (statusCode) {
      case 400:
        if (responseBody.contains('자기 자신')) {
          return '자기 자신을 친구로 추가할 수 없습니다';
        }
        return '잘못된 요청입니다';
      case 401:
        return '인증이 필요합니다';
      case 403:
        return '권한이 없습니다';
      case 404:
        return '존재하지 않는 사용자입니다';
      case 409:
        return '이미 친구이거나 요청을 보낸 사용자입니다';
      case 500:
        return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요';
      default:
        return _parseErrorMessageFromBody(responseBody);
    }
  }

  // 응답 본문에서 에러 메시지 파싱
  String _parseErrorMessageFromBody(String responseBody) {
    final lowerBody = responseBody.toLowerCase();
    
    if (lowerBody.contains('이미 친구') || lowerBody.contains('already friend')) {
      return '이미 친구인 사용자입니다';
    } else if (lowerBody.contains('존재하지 않는') || lowerBody.contains('not found')) {
      return '존재하지 않는 사용자입니다';
    } else if (lowerBody.contains('이미 요청') || lowerBody.contains('already requested')) {
      return '이미 친구 요청을 보낸 사용자입니다';
    } else if (lowerBody.contains('자기 자신') || lowerBody.contains('self')) {
      return '자기 자신을 친구로 추가할 수 없습니다';
    } else {
      return '친구 추가에 실패했습니다: $responseBody';
    }
  }

  /// 받은 친구 요청 목록 조회
  Future<List<FriendRequest>> fetchFriendRequests() async {
    final res = await ApiHelper.get('$baseUrl/request_list');
    print('[친구 요청 응답] ${res.body}');

    if (res.body.isEmpty || res.body.trim() == '{}') {
      print('[WARN] 친구 요청 응답이 비었거나 빈 객체임');
      return [];
    }

    try {
      // 🔥 서버 응답 구조에 맞게 파싱: {"success": true, "data": [...]}
      final Map<String, dynamic> responseData = jsonDecode(res.body);
      print('[친구 요청 파싱 데이터] $responseData');

      if (responseData['success'] == true && responseData['data'] != null) {
        final List<dynamic> dataList = responseData['data'];
        return dataList
            .map((e) => FriendRequest.fromJson(e as Map<String, dynamic>))
            .where((req) => req.fromUserId.isNotEmpty)
            .toList();
      } else {
        print('[ERROR] 서버 응답 구조가 올바르지 않음: $responseData');
        return [];
      }
    } catch (e, stack) {
      print('[ERROR] 친구 요청 파싱 실패: $e');
      print(stack);
      return [];
    }
  }

  /// 내가 보낸 친구 요청 목록 조회
  Future<List<SentFriendRequest>> fetchSentFriendRequests() async {
    try {
      print('[DEBUG] ===== 보낸 친구 요청 조회 시작 =====');

      // 🔥 서버 로그에 따르면 올바른 경로는 /friend/my_request_list (JWT 토큰에서 사용자 ID 추출)
      final List<String> possibleUrls = [
        '$baseUrl/my_request_list',  // 🔥 JWT 토큰에서 사용자 ID 추출
      ];

      // 🔥 서버 로그에서 확인된 올바른 경로만 사용
      final url = possibleUrls.first;
      print('[DEBUG] 보낸 친구 요청 조회 URL: $url');

      final res = await ApiHelper.get(url);
      print('[DEBUG] 응답 상태: ${res.statusCode}');
      print('[DEBUG] 응답 본문: ${res.body}');

      if (res.statusCode == 200) {
        // 빈 응답 처리
        if (res.body.isEmpty || res.body.trim() == '{}') {
          print('[DEBUG] 보낸 친구 요청이 없음');
          return [];
        }

        // 🔥 서버 응답 구조에 맞게 파싱: {"success": true, "data": [...]}
        final Map<String, dynamic> responseData = jsonDecode(res.body);
        print('[DEBUG] 🔍 서버 응답 원시 데이터: $responseData');
        print('[DEBUG] 🔍 응답 데이터 타입: ${responseData.runtimeType}');

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> dataList = responseData['data'];
          print('[DEBUG] 보낸 친구 요청 원시 데이터: $dataList');
          print('[DEBUG] 🔍 배열 길이: ${dataList.length}');

          final requests = dataList
              .map((e) {
                print('[DEBUG] 🔍 개별 항목 파싱: $e');
                return SentFriendRequest.fromJson(e as Map<String, dynamic>);
              })
              .where((req) => req.toUserId.isNotEmpty)
              .toList();

          print('[DEBUG] 파싱된 보낸 친구 요청 수: ${requests.length}');
          print('[DEBUG] 🔍 파싱된 요청들: ${requests.map((r) => '${r.toUserId}(${r.toUserName})').join(', ')}');
          print('[DEBUG] ✅ 보낸 친구 요청 조회 성공');
          return requests;
        } else {
          print('[ERROR] 서버 응답 구조가 올바르지 않음: $responseData');
          return [];
        }
      } else {
        print('[ERROR] 보낸 친구 요청 조회 실패: ${res.statusCode} ${res.body}');
        return [];
      }
    } catch (e, stack) {
      print('[ERROR] 보낸 친구 요청 조회 중 오류: $e');
      print('[ERROR] 스택 트레이스: $stack');
      return [];
    }
  }

  /// 친구 요청 수락
  Future<void> acceptFriendRequest(String addId) async {
    if (addId.isEmpty) {
      throw Exception('친구 요청 정보가 올바르지 않습니다.');
    }

    final res = await ApiHelper.post(
      '$baseUrl/accept',
      body: {'add_id': addId},
    );

    if (res.statusCode != 200) {
      throw Exception('친구 요청 수락 실패');
    }
  }

  /// 친구 요청 거절
  Future<void> rejectFriendRequest(String addId) async {
    if (addId.isEmpty) {
      print('[ERROR] 친구 요청 거절 add_id가 비어있음! 요청 차단');
      throw Exception('친구 요청 정보가 올바르지 않습니다.');
    }

    print('[DEBUG] 친구 요청 거절 시도 - addId: $addId');

    final res = await ApiHelper.post(
      '$baseUrl/reject',
      body: {'add_id': addId},
    );

    print('[DEBUG] 친구 요청 거절 응답: ${res.statusCode} ${res.body}');

    if (res.statusCode != 200) {
      print('[ERROR] 친구 요청 거절 실패: ${res.body}');
      throw Exception('친구 요청 거절 실패');
    }
  }

  /// 내가 보낸 친구 요청 취소 (서버 명세 완벽 준수)
  Future<void> cancelSentFriendRequest(String friendId) async {
    if (friendId.isEmpty) {
      print('[ERROR] 친구 요청 취소 friend_id가 비어있음! 요청 차단');
      throw Exception('친구 요청 정보가 올바르지 않습니다.');
    }

    try {
      print('[DEBUG] ===== 친구 요청 취소 시작 =====');
      print('[DEBUG] friendId: $friendId');
      print('[DEBUG] 요청 URL: $baseUrl/mistake');
      print('[DEBUG] 요청 Body: {"friend_id": "$friendId"}');

      final res = await ApiHelper.post(
        '$baseUrl/mistake',
        body: {'friend_id': friendId},
      );

      print('[DEBUG] 친구 요청 취소 응답 상태: ${res.statusCode}');
      print('[DEBUG] 친구 요청 취소 응답 본문: ${res.body}');

      if (res.statusCode == 200) {
        print('[SUCCESS] 친구 요청 취소 성공');

        // 서버 응답 메시지 확인
        try {
          final responseData = jsonDecode(res.body);
          if (responseData['message'] == "실수 인정") {
            print('[DEBUG] 서버 확인 메시지: ${responseData['message']}');
          } else {
            print('[DEBUG] 예상과 다른 응답 메시지: ${responseData['message']}');
          }
        } catch (e) {
          print('[DEBUG] 응답 메시지 파싱 실패: $e');
          print('[DEBUG] 하지만 상태코드 200이므로 성공으로 처리');
        }

        return;
      } else {
        print('[ERROR] 친구 요청 취소 실패 - 상태코드: ${res.statusCode}');
        print('[ERROR] 응답 내용: ${res.body}');
        throw Exception('친구 요청 취소 실패: ${res.statusCode}');
      }
    } catch (e) {
      print('[ERROR] 친구 요청 취소 API 호출 실패: $e');
      throw Exception('친구 요청 취소 중 오류가 발생했습니다: $e');
    }
  }

  /// 친구 삭제
  Future<void> deleteFriend(String addId) async {
    if (addId.isEmpty) {
      print('[ERROR] 친구 삭제 add_id가 비어있음! 요청 차단');
      throw Exception('친구 정보가 올바르지 않습니다.');
    }

    print('[DEBUG] 친구 삭제 시도 - addId: $addId');

    final res = await ApiHelper.delete(
      '$baseUrl/delete',
      body: {'add_id': addId},
    );

    print('[DEBUG] 친구 삭제 응답: ${res.statusCode} ${res.body}');

    if (res.statusCode != 200) {
      print('[ERROR] 친구 삭제 실패: ${res.body}');
      throw Exception('친구 삭제 실패');
    }
  }
}
