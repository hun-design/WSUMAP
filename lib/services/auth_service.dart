// lib/services/auth_service.dart - 서버 API와 연동되는 인증 서비스

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'jwt_service.dart';
import 'api_helper.dart';

/// 인증 관련 서비스 클래스
class AuthService {
  static final String baseUrl = ApiConfig.userBase;

  /// 회원가입 API 호출
  static Future<AuthResult> register({
    required String id,
    required String pw,
    required String name,
    required String phone,
    String? stuNumber,
    String? email,
  }) async {
    try {
      debugPrint('=== 회원가입 API 요청 ===');
      debugPrint('URL: $baseUrl/register');

      final requestBody = {
        'id': id,
        'pw': pw,
        'name': name,
        'stu_number': stuNumber,
        'phone': phone,
        'email': email,
      };

      debugPrint('요청 데이터: $requestBody');

      final response = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('=== 회원가입 API 응답 ===');
      debugPrint('상태코드: ${response.statusCode}');
      debugPrint('응답 내용: ${response.body}');

      switch (response.statusCode) {
        case 201:
          // 성공
          final data = jsonDecode(response.body);
          return AuthResult.success(
            message: data['message'] ?? '회원가입이 완료되었습니다.',
          );
        case 400:
          return AuthResult.failure('모든 필수 항목을 입력해주세요.');
        case 409:
          return AuthResult.failure('이미 존재하는 아이디입니다.');
        case 500:
          return AuthResult.failure('회원가입 처리 중 서버 오류가 발생했습니다.');
        default:
          return AuthResult.failure(
            '알 수 없는 오류가 발생했습니다. (${response.statusCode})',
          );
      }
    } catch (e) {
      debugPrint('회원가입 네트워크 오류: $e');
      if (e.toString().contains('timeout') ||
          e.toString().contains('TimeoutException')) {
        return AuthResult.failure('서버 응답 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.');
      }
      if (e.toString().contains('SocketException') ||
          e.toString().contains('network')) {
        return AuthResult.failure('네트워크 연결에 실패했습니다. 인터넷 연결을 확인해주세요.');
      }
      return AuthResult.failure('예상치 못한 오류가 발생했습니다. 다시 시도해주세요.');
    }
  }

  /// 🔥 로그인 API 호출 (서버 DB 검증 강화)
  static Future<LoginResult> login({
    required String id,
    required String pw,
  }) async {
    try {
      debugPrint('=== 🔥 강화된 로그인 API 요청 ===');
      debugPrint('URL: $baseUrl/login');
      debugPrint('아이디: $id');
      debugPrint('🔍 서버 DB 검증 시작...');

      final requestBody = {'id': id, 'pw': pw};

      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('=== 🔥 강화된 로그인 API 응답 ===');
      debugPrint('상태코드: ${response.statusCode}');
      debugPrint('응답 내용: ${response.body}');

      switch (response.statusCode) {
        case 200:
          // 🔥 성공 - 서버 DB에서 사용자 존재 확인됨
          final data = jsonDecode(response.body);
          
          // 🔥 새로운 서버 응답 구조 처리
          if (data['success'] == true && data['user'] != null) {
            final userData = data['user'];
            
            // 🔥 사용자 정보 유효성 검증 강화
            if (userData['id'] == null || userData['name'] == null) {
              debugPrint('❌ 서버 응답에서 필수 사용자 정보 누락');
              return LoginResult.failure('서버에서 사용자 정보를 받을 수 없습니다.');
            }
            
            // 🔥 JWT 토큰 저장
            if (data['token'] != null) {
              await JwtService.saveToken(data['token']);
              debugPrint('🔐 JWT 토큰 저장 완료');
            }
            
            // is_tutorial 값을 정확하게 처리
            bool isTutorial = true; // 기본값
            if (userData.containsKey('is_tutorial')) {
              final tutorialValue = userData['is_tutorial'];
              if (tutorialValue is bool) {
                isTutorial = tutorialValue;
              } else if (tutorialValue is String) {
                isTutorial = tutorialValue.toLowerCase() == 'true';
              } else if (tutorialValue is int) {
                isTutorial = tutorialValue == 1;
              }
            }
            
            debugPrint('✅ 서버 DB 검증 성공 - 사용자 존재 확인');
            debugPrint('🔍 서버 응답에서 is_tutorial 원본 값: ${userData['is_tutorial']} (타입: ${userData['is_tutorial']?.runtimeType})');
            debugPrint('🔍 처리된 Is_Tutorial 값: $isTutorial (타입: ${isTutorial.runtimeType})');
            debugPrint('🔍 전체 서버 응답 데이터: $data');
            debugPrint('🔍 사용자 데이터: $userData');
            
            return LoginResult.success(
              userId: userData['id'],
              userName: userData['name'],
              isLogin: userData['islogin'] ?? userData['isLogin'] ?? userData['online'] ?? true,
              isTutorial: isTutorial, // 튜토리얼 표시 여부
            );
          } else {
            // 🔥 기존 응답 구조도 지원 (하위 호환성)
            if (data['id'] == null || data['name'] == null) {
              debugPrint('❌ 기존 응답 구조에서 필수 사용자 정보 누락');
              return LoginResult.failure('서버에서 사용자 정보를 받을 수 없습니다.');
            }
            
            bool isTutorial = true; // 기본값
            if (data.containsKey('is_tutorial')) {
              final tutorialValue = data['is_tutorial'];
              if (tutorialValue is bool) {
                isTutorial = tutorialValue;
              } else if (tutorialValue is String) {
                isTutorial = tutorialValue.toLowerCase() == 'true';
              } else if (tutorialValue is int) {
                isTutorial = tutorialValue == 1;
              }
            }
            
            debugPrint('✅ 서버 DB 검증 성공 - 사용자 존재 확인 (기존 구조)');
            debugPrint('🔍 기존 응답 구조 사용 - is_tutorial 원본 값: ${data['is_tutorial']} (타입: ${data['is_tutorial']?.runtimeType})');
            debugPrint('🔍 처리된 Is_Tutorial 값: $isTutorial (타입: ${isTutorial.runtimeType})');
            debugPrint('🔍 전체 서버 응답 데이터: $data');
            
            return LoginResult.success(
              userId: data['id'],
              userName: data['name'],
              isLogin: data['islogin'] ?? data['isLogin'] ?? data['online'] ?? true,
              isTutorial: isTutorial, // 튜토리얼 표시 여부
            );
          }
        case 400:
          debugPrint('❌ 서버 DB 검증 실패 - 잘못된 요청');
          return LoginResult.failure('아이디와 비밀번호를 입력하세요.');
        case 401:
          debugPrint('❌ 서버 DB 검증 실패 - 인증 실패');
          return LoginResult.failure('아이디 또는 비밀번호가 일치하지 않습니다.');
        case 404:
          debugPrint('❌ 서버 DB 검증 실패 - 사용자 존재하지 않음');
          return LoginResult.failure('존재하지 않는 사용자입니다.');
        case 500:
          debugPrint('❌ 서버 DB 검증 실패 - 서버 오류');
          return LoginResult.failure('로그인 처리 중 서버 오류가 발생했습니다.');
        default:
          debugPrint('❌ 서버 DB 검증 실패 - 알 수 없는 오류: ${response.statusCode}');
          return LoginResult.failure(
            '알 수 없는 오류가 발생했습니다. (${response.statusCode})',
          );
      }
    } catch (e) {
      debugPrint('❌ 로그인 네트워크 오류: $e');
      if (e.toString().contains('timeout') ||
          e.toString().contains('TimeoutException')) {
        return LoginResult.failure('서버 응답 시간이 초과되었습니다. 네트워크 연결을 확인해주세요.');
      }
      if (e.toString().contains('SocketException') ||
          e.toString().contains('network')) {
        return LoginResult.failure('네트워크 연결에 실패했습니다. 인터넷 연결을 확인해주세요.');
      }
      return LoginResult.failure('예상치 못한 오류가 발생했습니다. 다시 시도해주세요.');
    }
  }


  /// 🔥 로그아웃 API 호출 (JWT 토큰 포함)
  static Future<AuthResult> logout({required String id}) async {
    try {
      debugPrint('=== 🔥 JWT 토큰 포함 로그아웃 API 요청 ===');
      debugPrint('URL: $baseUrl/logout');
      debugPrint('아이디: $id');

      // 🔥 JWT 토큰을 포함한 로그아웃 요청 (서버에서 authMiddleware로 토큰 검증)
      final response = await ApiHelper.post(
        '$baseUrl/logout',
        body: {}, // 서버에서 토큰에서 사용자 ID를 추출하므로 body는 비워둠
      );

      debugPrint('=== 🔥 JWT 토큰 포함 로그아웃 API 응답 ===');
      debugPrint('상태코드: ${response.statusCode}');
      debugPrint('응답 내용: ${response.body}');

      switch (response.statusCode) {
        case 200:
          return AuthResult.success(message: '로그아웃되었습니다.');
        case 401:
          return AuthResult.failure('인증 토큰이 유효하지 않습니다.');
        case 404:
          return AuthResult.failure('존재하지 않는 사용자입니다.');
        case 500:
          return AuthResult.failure('로그아웃 처리 중 서버 오류가 발생했습니다.');
        default:
          return AuthResult.failure(
            '알 수 없는 오류가 발생했습니다. (${response.statusCode})',
          );
      }
    } catch (e) {
      debugPrint('❌ 로그아웃 네트워크 오류: $e');
      return AuthResult.failure('네트워크 연결에 실패했습니다.');
    }
  }

  /// 회원정보 수정 API 호출
  static Future<AuthResult> updateUserInfo({
    required String id,
    String? pw,
    String? phone,
    String? email,
  }) async {
    try {
      debugPrint('=== 회원정보 수정 API 요청 ===');

      final requestBody = <String, dynamic>{'id': id};

      if (pw != null && pw.isNotEmpty) requestBody['pw'] = pw;
      if (phone != null && phone.isNotEmpty) requestBody['phone'] = phone;
      if (email != null && email.isNotEmpty) requestBody['email'] = email;

      debugPrint('요청 데이터: $requestBody');

      final response = await ApiHelper.put(
        '$baseUrl/update',
        body: requestBody,
      );

      debugPrint('=== 회원정보 수정 API 응답 ===');
      debugPrint('상태코드: ${response.statusCode}');
      debugPrint('응답 내용: ${response.body}');

      switch (response.statusCode) {
        case 200:
          return AuthResult.success(message: '회원정보가 수정되었습니다.');
        case 400:
          final errorMsg = response.body.contains('필수')
              ? 'id는 필수입니다.'
              : '수정할 항목이 없습니다.';
          return AuthResult.failure(errorMsg);
        case 404:
          return AuthResult.failure('해당 id의 사용자가 없습니다.');
        case 500:
          return AuthResult.failure('회원정보 수정 중 서버 오류가 발생했습니다.');
        default:
          return AuthResult.failure(
            '알 수 없는 오류가 발생했습니다. (${response.statusCode})',
          );
      }
    } catch (e) {
      debugPrint('회원정보 수정 네트워크 오류: $e');
      return AuthResult.failure('네트워크 연결에 실패했습니다.');
    }
  }

  /// 회원 삭제(탈퇴) API 호출
  ///
  /// [id] : 삭제할 사용자 아이디
  ///
  /// 서버에 DELETE 요청을 보내 회원탈퇴를 처리합니다.
  /// 성공 시 '회원 삭제가 완료되었습니다.' 메시지를 반환합니다.
  /// 실패 시 상태코드에 따라 적절한 에러 메시지를 반환합니다.
  static Future<AuthResult> deleteUser({required String id}) async {
    try {
      final requestBody = {'id': id};

      final response = await ApiHelper.delete(
        '${ApiConfig.userBase}/delete',
        body: requestBody,
      );

      switch (response.statusCode) {
        case 200:
          return AuthResult.success(message: '회원 삭제가 완료되었습니다.');
        case 404:
          return AuthResult.failure('존재하지 않는 사용자입니다.');
        case 500:
          return AuthResult.failure('회원 삭제 처리 중 서버 오류가 발생했습니다.');
        default:
          return AuthResult.failure(
            '알 수 없는 오류가 발생했습니다. (${response.statusCode})',
          );
      }
    } catch (e) {
      return AuthResult.failure('네트워크 연결에 실패했습니다.');
    }
  }

  /// 서버 연결 테스트
  static Future<bool> testConnection() async {
    try {
      final response = await ApiHelper.get(baseUrl);

      debugPrint('서버 연결 테스트: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 404;
    } catch (e) {
      debugPrint('서버 연결 테스트 실패: $e');
      return false;
    }
  }

  /// 🔥 위치 공유 상태 업데이트 (개선된 버전 - 타임아웃 및 오류 처리 강화)
  Future<bool> updateShareLocation(String userId, bool isEnabled) async {
    try {
      debugPrint('=== 위치 공유 상태 업데이트 시작 ===');
      debugPrint('사용자 ID: $userId');
      debugPrint('위치 공유 활성화: $isEnabled');

      // 🔥 JWT 토큰을 포함한 위치 공유 상태 업데이트
      final response = await ApiHelper.put(
        '${ApiConfig.userBase}/update_share_location',
        body: {
          'id': userId,
          'Is_location_public': isEnabled, // 서버에서 기대하는 필드명으로 변경
        },
      );

      debugPrint('서버 응답 상태: ${response.statusCode}');
      debugPrint('서버 응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ 위치 공유 상태 업데이트 성공');
        return true;
      } else {
        debugPrint('❌ 위치 공유 상태 업데이트 실패: ${response.statusCode}');
        debugPrint('❌ 실패 응답 내용: ${response.body}');
        return false;
      }
    } on TimeoutException catch (e) {
      debugPrint('❌ 위치 공유 상태 업데이트 타임아웃: $e');
      return false;
    } on SocketException catch (e) {
      debugPrint('❌ 위치 공유 상태 업데이트 네트워크 오류: $e');
      return false;
    } on FormatException catch (e) {
      debugPrint('❌ 위치 공유 상태 업데이트 데이터 형식 오류: $e');
      return false;
    } on HttpException catch (e) {
      debugPrint('❌ 위치 공유 상태 업데이트 HTTP 오류: $e');
      return false;
    } catch (e) {
      debugPrint('❌ 위치 공유 상태 업데이트 알 수 없는 오류: $e');
      return false;
    }
  }

  /// 🔥 위치 공유 상태 조회
  Future<bool?> getShareLocationStatus(String userId) async {
    try {
      debugPrint('=== 위치 공유 상태 조회 시작 ===');
      debugPrint('사용자 ID: $userId');

      // 🔥 JWT 토큰을 포함한 사용자 목록 조회
      final response = await ApiHelper.get('${ApiConfig.userBase}/friend_request_list');

      debugPrint('서버 응답 상태: ${response.statusCode}');
      debugPrint('서버 응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final List<dynamic> data = jsonDecode(response.body);
          debugPrint('📋 파싱된 데이터 개수: ${data.length}');

          // 현재 사용자를 찾아서 Is_location_public 필드 확인
          for (final user in data) {
            if (user is Map<String, dynamic>) {
              final userIdFromServer = user['Id']?.toString();
              debugPrint('📋 확인 중인 사용자: $userIdFromServer');
              
              if (userIdFromServer == userId) {
                final isLocationPublic = user['Is_location_public'];
                debugPrint('📋 찾은 사용자의 Is_location_public: $isLocationPublic');
                
                if (isLocationPublic is bool) {
                  debugPrint('✅ 서버에서 받은 위치공유 상태: $isLocationPublic');
                  return isLocationPublic;
                } else if (isLocationPublic is String) {
                  final boolValue = isLocationPublic.toLowerCase() == 'true';
                  debugPrint('✅ 서버에서 받은 위치공유 상태 (문자열): $boolValue');
                  return boolValue;
                } else {
                  debugPrint('❌ Is_location_public 필드가 예상과 다른 타입: ${isLocationPublic.runtimeType}');
                }
              }
            }
          }
          
          debugPrint('❌ 사용자를 찾을 수 없음: $userId');
          return null;
        } catch (e) {
          debugPrint('❌ JSON 파싱 오류: $e');
          return null;
        }
      } else {
        debugPrint('❌ 위치 공유 상태 조회 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ 위치 공유 상태 조회 오류: $e');
      return null;
    }
  }

  /// 🔥 사용자 존재 여부 확인
  Future<bool> checkUserExists(String userId) async {
    try {
      debugPrint('=== 사용자 존재 여부 확인 시작 ===');
      debugPrint('확인할 사용자 ID: $userId');

      // 🔥 JWT 토큰을 포함한 사용자 존재 여부 확인 (기존 URL 방식 유지)
      final response = await ApiHelper.get('${ApiConfig.userBase}/check_user/$userId');

      debugPrint('서버 응답 상태: ${response.statusCode}');
      debugPrint('서버 응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body.toLowerCase();
        // 서버에서 사용자가 존재한다고 응답한 경우
        if (responseBody.contains('true') || responseBody.contains('존재') || responseBody.contains('exists')) {
          debugPrint('✅ 사용자가 존재함');
          return true;
        } else {
          debugPrint('❌ 사용자가 존재하지 않음');
          return false;
        }
      } else {
        debugPrint('❌ 사용자 확인 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ 사용자 확인 오류: $e');
      return false;
    }
  }

  /// 🔥 사용자 목록 조회 (친구 요청용)
  Future<List<Map<String, String>>> getUserList() async {
    try {
      debugPrint('=== 사용자 목록 조회 시작 ===');
      debugPrint('📡 요청 URL: ${ApiConfig.userBase}/friend_request_list');

      // 🔥 JWT 토큰을 포함한 사용자 목록 조회 (기존 엔드포인트 사용)
      final response = await ApiHelper.get('${ApiConfig.userBase}/friend_request_list');

      debugPrint('📡 서버 응답 상태: ${response.statusCode}');
      debugPrint('📡 서버 응답 내용 (원본): "${response.body}"');
      debugPrint('📡 응답 길이: ${response.body.length}');

      if (response.statusCode == 200) {
        try {
          // 🔥 서버 응답 구조에 맞게 파싱: {"success": true, "data": [...]}
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          debugPrint('📋 서버 응답 구조: $responseData');
          
          if (responseData['success'] != true) {
            debugPrint('❌ 서버에서 실패 응답: ${responseData['message'] ?? '알 수 없는 오류'}');
            return [];
          }
          
          final List<dynamic> data = responseData['data'] ?? [];
          debugPrint('📋 파싱된 데이터 타입: ${data.runtimeType}');
          debugPrint('📋 데이터 개수: ${data.length}');
          debugPrint('📋 전체 파싱된 데이터: $data');
          
          // 🔥 데이터 구조 분석
          if (data.isNotEmpty) {
            final firstItem = data.first;
            debugPrint('📋 첫 번째 항목 타입: ${firstItem.runtimeType}');
            if (firstItem is Map<String, dynamic>) {
              debugPrint('📋 첫 번째 항목 키들: ${firstItem.keys.toList()}');
              debugPrint('📋 첫 번째 항목 값들: ${firstItem.values.toList()}');
            }
          }
          
          final List<Map<String, String>> userList = [];
          
          for (int i = 0; i < data.length; i++) {
            final user = data[i];
            debugPrint('📋 사용자 $i (원본): $user');
            debugPrint('📋 사용자 $i 타입: ${user.runtimeType}');
            
            if (user is Map<String, dynamic>) {
              debugPrint('📋 사용자 $i 키들: ${user.keys.toList()}');
              
              // 🔥 다양한 필드명 시도
              String? id = user['Id']?.toString();
              String? name = user['Name']?.toString();
              
              // 🔥 대소문자 구분 없이 시도
              if (id == null) id = user['id']?.toString();
              if (name == null) name = user['name']?.toString();
              
              debugPrint('📋 사용자 $i - ID: "$id", Name: "$name"');
              
              if (id != null && id.isNotEmpty && name != null && name.isNotEmpty) {
                userList.add({
                  'id': id,
                  'name': name,
                });
                debugPrint('✅ 사용자 $i 추가됨: $name ($id)');
              } else {
                debugPrint('❌ 사용자 $i 건너뜀 - ID 또는 Name이 비어있음');
                debugPrint('  ID: "$id", Name: "$name"');
                debugPrint('  ID 길이: ${id?.length ?? 0}, Name 길이: ${name?.length ?? 0}');
              }
            } else {
              debugPrint('❌ 사용자 $i 건너뜀 - Map이 아님: ${user.runtimeType}');
            }
          }
          
          debugPrint('✅ 사용자 목록 조회 성공: ${userList.length}명');
          debugPrint('📋 최종 사용자 목록:');
          for (int i = 0; i < userList.length; i++) {
            final user = userList[i];
            debugPrint('  ${i + 1}. ${user['name']} (${user['id']})');
          }
          return userList;
        } catch (e) {
          debugPrint('❌ JSON 파싱 오류: $e');
          debugPrint('❌ 파싱 시도한 원본 데이터: "${response.body}"');
          return [];
        }
      } else {
        debugPrint('❌ 사용자 목록 조회 실패: ${response.statusCode}');
        debugPrint('❌ 실패 응답 내용: "${response.body}"');
        return [];
      }
    } catch (e) {
      debugPrint('❌ 사용자 목록 조회 오류: $e');
      return [];
    }
  }

  /// 🔥 서버와 동일한 방식으로 사용자 존재 여부 확인
  Future<bool> checkUserExistsDirect(String userId) async {
    try {
      debugPrint('=== 직접 사용자 존재 여부 확인 시작 ===');
      debugPrint('확인할 사용자 ID: $userId');

      // 🔥 JWT 토큰을 포함한 직접 사용자 존재 여부 확인
      final response = await ApiHelper.get('${ApiConfig.userBase}/check_user/$userId');

      debugPrint('서버 응답 상태: ${response.statusCode}');
      debugPrint('서버 응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body.toLowerCase();
        // 서버에서 사용자가 존재한다고 응답한 경우
        if (responseBody.contains('true') || responseBody.contains('존재') || responseBody.contains('exists')) {
          debugPrint('✅ 사용자가 존재함 (직접 확인)');
          return true;
        } else {
          debugPrint('❌ 사용자가 존재하지 않음 (직접 확인)');
          return false;
        }
      } else {
        debugPrint('❌ 사용자 확인 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ 사용자 존재 여부 확인 오류: $e');
      return false;
    }
  }

  /// 튜토리얼 표시 여부 업데이트 API 호출
  static Future<AuthResult> updateTutorial({required String id}) async {
    try {
      debugPrint('=== 튜토리얼 업데이트 API 요청 ===');
      debugPrint('URL: $baseUrl/update_tutorial');
      debugPrint('아이디: $id');

      final requestBody = {'id': id};

      // 🔥 JWT 토큰을 포함한 요청
      final response = await ApiHelper.put(
        '$baseUrl/update_tutorial',
        body: requestBody,
      );

      debugPrint('=== 튜토리얼 업데이트 API 응답 ===');
      debugPrint('상태코드: ${response.statusCode}');
      debugPrint('응답 내용: ${response.body}');

      switch (response.statusCode) {
        case 200:
          return AuthResult.success(message: '튜토리얼 설정이 업데이트되었습니다.');
        case 404:
          return AuthResult.failure('존재하지 않는 사용자입니다.');
        case 500:
          return AuthResult.failure('튜토리얼 업데이트 중 서버 오류가 발생했습니다.');
        default:
          return AuthResult.failure(
            '알 수 없는 오류가 발생했습니다. (${response.statusCode})',
          );
      }
    } catch (e) {
      debugPrint('튜토리얼 업데이트 네트워크 오류: $e');
      return AuthResult.failure('네트워크 연결에 실패했습니다.');
    }
  }
}

/// 인증 결과를 나타내는 클래스
class AuthResult {
  final bool isSuccess;
  final String message;

  AuthResult._({required this.isSuccess, required this.message});

  factory AuthResult.success({required String message}) {
    return AuthResult._(isSuccess: true, message: message);
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(isSuccess: false, message: message);
  }
}

/// 로그인 결과를 나타내는 클래스
class LoginResult extends AuthResult {
  final String? userId;
  final String? userName;
  final bool? isLogin;
  final bool? isTutorial;

  LoginResult._({
    required super.isSuccess,
    required super.message,
    this.userId,
    this.userName,
    this.isLogin,
    this.isTutorial,
  }) : super._();

  factory LoginResult.success({
    required String userId,
    required String userName,
    required bool isLogin,
    required bool isTutorial,
  }) {
    return LoginResult._(
      isSuccess: true,
      message: '로그인 성공',
      userId: userId,
      userName: userName,
      isLogin: isLogin,
      isTutorial: isTutorial,
    );
  }

  factory LoginResult.failure(String message) {
    return LoginResult._(isSuccess: false, message: message);
  }
}
