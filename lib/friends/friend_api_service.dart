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
  Future<List<Friend>> fetchMyFriends(String myId) async {
    final res = await ApiHelper.get('$baseUrl/myfriend/$myId');
    print('[친구 목록 응답] ${res.body}');

    if (res.body.isEmpty || !res.body.trim().startsWith('[')) {
      print('[WARN] 친구 목록 응답이 비었거나 JSON 배열이 아님');
      return [];
    }

    try {
      final List data = jsonDecode(res.body);
      print('[친구 목록 파싱 데이터] $data');
      return data.map((e) => Friend.fromJson(e)).toList();
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
  Future<void> addFriend(String myId, String addId) async {
    if (addId.isEmpty) {
      print('[ERROR] 친구 추가 add_id가 비어있음! 요청 차단');
      throw Exception('상대방 ID가 올바르지 않습니다.');
    }

    print('[DEBUG] ===== 친구 추가 요청 시작 =====');
    print('[DEBUG] myId: $myId');
    print('[DEBUG] addId: $addId');

    // 🔥 서버에 직접 친구 요청 전송 (올바른 경로 사용)
    print('[DEBUG] 📤 서버에 친구 요청 전송 중...');
    print('[DEBUG] 요청 URL: $baseUrl/add');
    print('[DEBUG] 요청 바디: ${jsonEncode({'my_id': myId, 'add_id': addId})}');
    final res = await ApiHelper.post(
      '$baseUrl/add',
      body: {'my_id': myId, 'add_id': addId},
    );

    print('[DEBUG] 📥 서버 응답 수신');
    print('[DEBUG] 응답 상태: ${res.statusCode}');
    print('[DEBUG] 응답 내용: "${res.body}"');
    print('[DEBUG] 응답 길이: ${res.body.length}');
    print('[DEBUG] 응답 타입: ${res.body.runtimeType}');

    // 🔥 서버 응답에 따른 처리
    print('[DEBUG] 🔍 상태 코드 분석: ${res.statusCode}');
    print('[DEBUG] 🔍 응답 내용: "${res.body}"');
    
    if (res.statusCode == 200) {
      // 성공 응답
      print('[DEBUG] ✅ 친구 추가 성공 응답');
      
      // 응답 내용 확인 - 서버가 200을 반환하지만 에러 메시지를 포함할 수 있음
      final responseBody = res.body.toLowerCase();
      print('[DEBUG] 🔍 응답 내용 분석: $responseBody');
      
      if (responseBody.contains('존재하지 않는') || 
          responseBody.contains('not found') || 
          responseBody.contains('user not found') ||
          responseBody.contains('실패') ||
          responseBody.contains('fail') ||
          responseBody.contains('error') ||
          responseBody.contains('불가능') ||
          responseBody.contains('이미') ||
          responseBody.contains('자기 자신')) {
        print('[ERROR] ❌ 성공 응답이지만 실패 메시지 포함: ${res.body}');
        throw Exception('친구 추가에 실패했습니다: ${res.body}');
      }
      
      print('[DEBUG] ✅ 친구 추가 성공 완료');
    } else {
      // 실패 응답
      print('[ERROR] ❌ 친구 추가 실패: ${res.statusCode} ${res.body}');
      print('[DEBUG] 🔍 실패 응답 처리 시작 - 상태 코드: ${res.statusCode}');
      
      // 🔥 상태 코드별 에러 메시지
      String errorMessage = '친구 추가 실패';
      
      print('[DEBUG] 🔍 switch 문 시작 - 상태 코드: ${res.statusCode}');
      switch (res.statusCode) {
        case 400:
          print('[DEBUG] 🔍 400 케이스 실행');
          if (res.body.contains('자기 자신')) {
            errorMessage = '자기 자신을 친구로 추가할 수 없습니다';
          } else {
            errorMessage = '잘못된 요청입니다';
          }
          break;
        case 401:
          errorMessage = '인증이 필요합니다';
          break;
        case 403:
          errorMessage = '권한이 없습니다';
          break;
        case 404:
          print('[DEBUG] 🔍 404 상태 코드 감지됨');
          print('[DEBUG] 🔍 404 응답 내용: "${res.body}"');
          errorMessage = '존재하지 않는 사용자입니다';
          print('[DEBUG] 🔍 404 에러 메시지 설정: $errorMessage');
          break;
        case 409:
          errorMessage = '이미 친구이거나 요청을 보낸 사용자입니다';
          break;
        case 500:
          errorMessage = '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요';
          break;
        default:
          print('[DEBUG] 🔍 default 케이스 실행 - 상태 코드: ${res.statusCode}');
          // 🔥 서버 응답 내용에 따라 구체적인 에러 메시지 제공
          final responseBody = res.body.toLowerCase();
          
          if (responseBody.contains('이미 친구') || responseBody.contains('already friend')) {
            errorMessage = '이미 친구인 사용자입니다';
          } else if (responseBody.contains('존재하지 않는') || responseBody.contains('not found') || responseBody.contains('user not found')) {
            errorMessage = '존재하지 않는 사용자입니다';
          } else if (responseBody.contains('이미 요청') || responseBody.contains('already requested')) {
            errorMessage = '이미 친구 요청을 보낸 사용자입니다';
          } else if (responseBody.contains('자기 자신') || responseBody.contains('self')) {
            errorMessage = '자기 자신을 친구로 추가할 수 없습니다';
          } else if (responseBody.contains('invalid') || responseBody.contains('잘못된')) {
            errorMessage = '잘못된 사용자 ID입니다';
          } else {
            // 🔥 서버 응답 내용을 그대로 표시
            errorMessage = '친구 추가에 실패했습니다: ${res.body}';
          }
      }
      
      print('[ERROR] ❌ 최종 에러 메시지: $errorMessage');
      print('[DEBUG] 🚀 Exception 던지기: $errorMessage');
      print('[DEBUG] 🚀 Exception 타입: Exception');
      final exception = Exception(errorMessage);
      print('[DEBUG] 🚀 Exception 생성됨: $exception');
      print('[DEBUG] 🚀 Exception 던지기 직전...');
      throw exception;
    }
  }

  /// 받은 친구 요청 목록 조회
  Future<List<FriendRequest>> fetchFriendRequests(String myId) async {
    final res = await ApiHelper.get('$baseUrl/request_list/$myId');
    print('[친구 요청 응답] ${res.body}');

    if (res.body.isEmpty || !res.body.trim().startsWith('[')) {
      print('[WARN] 친구 요청 응답이 비었거나 JSON 배열이 아님');
      return [];
    }

    try {
      final List data = jsonDecode(res.body);
      print('[친구 요청 파싱 데이터] $data');
      return data
          .map((e) => FriendRequest.fromJson(e))
          .where((req) => req.fromUserId.isNotEmpty)
          .toList();
    } catch (e, stack) {
      print('[ERROR] 친구 요청 파싱 실패: $e');
      print(stack);
      return [];
    }
  }

  /// 내가 보낸 친구 요청 목록 조회
  Future<List<SentFriendRequest>> fetchSentFriendRequests(String myId) async {
    try {
      print('[DEBUG] ===== 보낸 친구 요청 조회 시작 =====');
      print('[DEBUG] myId: $myId');

      // 서버에서 실제 사용하는 경로를 찾기 위해 여러 URL 시도
      final List<String> possibleUrls = [
        '$baseUrl/my_request_list/$myId',  // 올바른 경로 (우선순위 1)
        '${ApiConfig.baseHost}:${ApiConfig.userPort}/friend/my_request_list/$myId',  // 대체 경로
        '${ApiConfig.baseHost}:${ApiConfig.userPort}/my_request_list/$myId',  // 대체 경로
        '${ApiConfig.baseHost}:${ApiConfig.userPort}/sent_requests/$myId',  // 대체 경로
        '${ApiConfig.baseHost}:${ApiConfig.userPort}/friend/sent_requests/$myId',  // 대체 경로
        '${ApiConfig.baseHost}:${ApiConfig.userPort}/my_requests/$myId',  // 대체 경로
        '${ApiConfig.baseHost}:${ApiConfig.userPort}/friend/my_requests/$myId',  // 대체 경로
      ];

      for (int i = 0; i < possibleUrls.length; i++) {
        final url = possibleUrls[i];
        print('[DEBUG] 보낸 요청 URL 시도 ${i + 1}: $url');

        try {
          final res = await ApiHelper.get(url);

          print('[DEBUG] 응답 상태: ${res.statusCode}');
          print('[DEBUG] 응답 본문: ${res.body}');

          if (res.statusCode == 200) {
            // 빈 응답 처리
            if (res.body.isEmpty || res.body.trim() == '[]') {
              print('[DEBUG] 보낸 친구 요청이 없음 (URL: $url)');
              return [];
            }

            // JSON 파싱
            final dynamic responseData = jsonDecode(res.body);

            if (responseData is List) {
              print('[DEBUG] 보낸 친구 요청 원시 데이터: $responseData');

              final requests = responseData
                  .map((e) => SentFriendRequest.fromJson(e as Map<String, dynamic>))
                  .where((req) => req.toUserId.isNotEmpty)
                  .toList();

              print('[DEBUG] 파싱된 보낸 친구 요청 수: ${requests.length}');

              // 각 요청의 세부 내용 로그
              for (int j = 0; j < requests.length; j++) {
                final req = requests[j];
                print(
                  '[DEBUG] 요청 ${j + 1}: ID=${req.toUserId}, 이름=${req.toUserName}',
                );
              }

              print('[DEBUG] ✅ 보낸 친구 요청 조회 성공 (URL: $url)');
              return requests;
            } else {
              print('[ERROR] 응답이 배열이 아님: $responseData');
              if (i < possibleUrls.length - 1) {
                print('[DEBUG] 다음 URL 시도...');
                continue;
              }
            }
          } else {
            print('[ERROR] 보낸 친구 요청 조회 실패: ${res.statusCode} ${res.body}');
            if (i < possibleUrls.length - 1) {
              print('[DEBUG] 다음 URL 시도...');
              continue;
            }
          }
        } catch (e) {
          print('[ERROR] URL 시도 ${i + 1} 실패: $e');
          if (i < possibleUrls.length - 1) {
            print('[DEBUG] 다음 URL 시도...');
            continue;
          }
        }
      }

      print('[ERROR] ❌ 모든 보낸 친구 요청 URL 시도 실패');
      return [];
    } catch (e, stack) {
      print('[ERROR] 보낸 친구 요청 조회 중 오류: $e');
      print('[ERROR] 스택 트레이스: $stack');
      return [];
    }
  }

  /// 친구 요청 수락
  Future<void> acceptFriendRequest(String myId, String addId) async {
    if (addId.isEmpty) {
      print('[ERROR] 친구 요청 수락 add_id가 비어있음! 요청 차단');
      throw Exception('친구 요청 정보가 올바르지 않습니다.');
    }

    print('[DEBUG] 친구 요청 수락 시도 - myId: $myId, addId: $addId');

    final res = await ApiHelper.post(
      '$baseUrl/accept',
      body: {'my_id': myId, 'add_id': addId},
    );

    print('[DEBUG] 친구 요청 수락 응답: ${res.statusCode} ${res.body}');

    if (res.statusCode != 200) {
      print('[ERROR] 친구 요청 수락 실패: ${res.body}');
      throw Exception('친구 요청 수락 실패');
    }
  }

  /// 친구 요청 거절
  Future<void> rejectFriendRequest(String myId, String addId) async {
    if (addId.isEmpty) {
      print('[ERROR] 친구 요청 거절 add_id가 비어있음! 요청 차단');
      throw Exception('친구 요청 정보가 올바르지 않습니다.');
    }

    print('[DEBUG] 친구 요청 거절 시도 - myId: $myId, addId: $addId');

    final res = await ApiHelper.post(
      '$baseUrl/reject',
      body: {'my_id': myId, 'add_id': addId},
    );

    print('[DEBUG] 친구 요청 거절 응답: ${res.statusCode} ${res.body}');

    if (res.statusCode != 200) {
      print('[ERROR] 친구 요청 거절 실패: ${res.body}');
      throw Exception('친구 요청 거절 실패');
    }
  }

  /// 내가 보낸 친구 요청 취소 (서버 명세 완벽 준수)
  Future<void> cancelSentFriendRequest(String myId, String friendId) async {
    if (friendId.isEmpty) {
      print('[ERROR] 친구 요청 취소 friend_id가 비어있음! 요청 차단');
      throw Exception('친구 요청 정보가 올바르지 않습니다.');
    }

    try {
      print('[DEBUG] ===== 친구 요청 취소 시작 =====');
      print('[DEBUG] myId: $myId, friendId: $friendId');
      print('[DEBUG] 요청 URL: $baseUrl/mistake/$myId');
      print('[DEBUG] 요청 Body: {"friend_id": "$friendId"}');

      final res = await ApiHelper.post(
        '$baseUrl/mistake/$myId',
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
  Future<void> deleteFriend(String myId, String addId) async {
    if (addId.isEmpty) {
      print('[ERROR] 친구 삭제 add_id가 비어있음! 요청 차단');
      throw Exception('친구 정보가 올바르지 않습니다.');
    }

    print('[DEBUG] 친구 삭제 시도 - myId: $myId, addId: $addId');

    final res = await ApiHelper.delete(
      '$baseUrl/delete',
      body: {'my_id': myId, 'add_id': addId},
    );

    print('[DEBUG] 친구 삭제 응답: ${res.statusCode} ${res.body}');

    if (res.statusCode != 200) {
      print('[ERROR] 친구 삭제 실패: ${res.body}');
      throw Exception('친구 삭제 실패');
    }
  }
}
