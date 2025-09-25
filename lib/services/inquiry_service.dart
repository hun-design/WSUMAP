// lib/services/inquiry_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import 'api_helper.dart';

class InquiryService {
  // 🔥 서버 라우터 구조에 맞게 URL 수정: router.get('/', authMiddleware, inquiryController.getInquiry)
  static String get baseUrl => '${ApiConfig.baseHost}:3001/inquiry';

  /// 문의하기 작성
  static Future<bool> createInquiry({
    required String category,
    required String title,
    required String content,
    File? imageFile,
  }) async {
    try {
      debugPrint('=== 문의하기 작성 시작 ===');
      debugPrint('카테고리: $category');
      debugPrint('제목: $title');
      debugPrint('내용: $content');
      debugPrint('이미지 파일: ${imageFile?.path ?? "없음"}');

      // 🔥 카테고리 유효성 검증
      final validCategories = ['place_error', 'bug', 'feature', 'route_error', 'other'];
      if (!validCategories.contains(category)) {
        debugPrint('❌ 유효하지 않은 카테고리: $category');
        debugPrint('유효한 카테고리: $validCategories');
        return false;
      }
      debugPrint('✅ 유효한 카테고리 확인: $category');

      // 필드 검증
      if (category.isEmpty) {
        debugPrint('❌ 카테고리가 비어있음');
        return false;
      }
      if (title.isEmpty) {
        debugPrint('❌ 제목이 비어있음');
        return false;
      }
      if (content.isEmpty) {
        debugPrint('❌ 내용이 비어있음');
        return false;
      }

      // 먼저 multipart 요청 시도
      bool success = await _tryMultipartRequest(
        category,
        title,
        content,
        imageFile,
      );

      if (!success) {
        debugPrint('multipart 요청 실패, JSON 요청 시도...');
        success = await _tryJsonRequest(category, title, content);
      }

      return success;
    } catch (e) {
      debugPrint('❌ 문의하기 작성 오류: $e');
      return false;
    }
  }

  /// multipart 요청 시도
  static Future<bool> _tryMultipartRequest(
    String category,
    String title,
    String content,
    File? imageFile,
  ) async {
    try {
      debugPrint('=== multipart 요청 시도 ===');

      // 🔥 서버 라우트: router.post('/', authMiddleware, inquiryController.createInquiry)
      final List<String> possibleUrls = [
        '${ApiConfig.baseHost}:3001/inquiry', // 🔥 JWT 토큰에서 사용자 ID 추출
        '${ApiConfig.baseHost}:3001/user/inquiry', // 대안 경로
      ];

      for (int i = 0; i < possibleUrls.length; i++) {
        final url = possibleUrls[i];
        debugPrint('URL 시도 ${i + 1}: $url');

        // multipart 요청 생성 (JWT 토큰 포함)
        final request = await ApiHelper.createMultipartRequest('POST', url);

        // 🔥 Accept-Language 헤더 제거 - 서버에서 언어 인식 문제 방지

        // 텍스트 필드 추가
        request.fields['category'] = category;
        request.fields['title'] = title;
        request.fields['content'] = content;

        // 🔥 JWT 토큰에서 사용자 ID를 추출하므로 body에 id 추가하지 않음

        debugPrint('요청 필드 확인:');
        debugPrint('  category: ${request.fields['category']}');
        debugPrint('  title: ${request.fields['title']}');
        debugPrint('  content: ${request.fields['content']}');

        // 이미지 파일이 있는 경우 추가
        if (imageFile != null) {
          try {
            final imageStream = http.ByteStream(imageFile.openRead());
            final imageLength = await imageFile.length();

            final multipartFile = http.MultipartFile(
              'image',
              imageStream,
              imageLength,
              filename:
                  'inquiry_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
            );

            request.files.add(multipartFile);
            debugPrint('이미지 파일 추가됨: ${imageFile.path}');
            debugPrint('이미지 파일 크기: $imageLength bytes');
          } catch (e) {
            debugPrint('이미지 파일 처리 중 오류: $e');
          }
        }

        debugPrint('요청 URL: ${request.url}');
        debugPrint('요청 헤더: ${request.headers}');
        debugPrint('요청 필드 수: ${request.fields.length}');
        debugPrint('요청 파일 수: ${request.files.length}');

        // 요청 전송
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        debugPrint('multipart 응답 상태: ${response.statusCode}');
        debugPrint('multipart 응답 헤더: ${response.headers}');
        debugPrint('multipart 응답 내용: $responseBody');

        if (response.statusCode == 201 || response.statusCode == 200) {
          debugPrint('✅ multipart 문의하기 작성 성공 (URL: $url)');
          return true;
        } else if (response.statusCode == 500) {
          debugPrint('⚠️ 서버 내부 오류 (URL: $url): $responseBody');
          debugPrint('⚠️ 서버 로그를 확인해주세요. 필수 필드 누락 또는 형식 오류일 수 있습니다.');
          // 500 에러는 서버 문제이므로 다음 URL 시도
          if (i < possibleUrls.length - 1) {
            debugPrint('다음 URL 시도...');
          } else {
            debugPrint('❌ 모든 multipart URL 시도 실패');
          }
        } else {
          debugPrint(
            '❌ multipart 문의하기 작성 실패 (URL: $url): ${response.statusCode}',
          );
          if (i < possibleUrls.length - 1) {
            debugPrint('다음 URL 시도...');
          } else {
            debugPrint('❌ 모든 multipart URL 시도 실패');
          }
        }
      }

      debugPrint('❌ 모든 multipart URL 시도 실패');
      return false;
    } catch (e) {
      debugPrint('❌ multipart 요청 오류: $e');
      return false;
    }
  }

  /// JSON 요청 시도 (이미지 없이)
  static Future<bool> _tryJsonRequest(
    String category,
    String title,
    String content,
  ) async {
    try {
      debugPrint('=== JSON 요청 시도 ===');

      // 🔥 서버 라우트: router.post('/', authMiddleware, inquiryController.createInquiry)
      final List<String> possibleUrls = [
        '${ApiConfig.baseHost}:3001/inquiry', // 🔥 JWT 토큰에서 사용자 ID 추출
        '${ApiConfig.baseHost}:3001/user/inquiry', // 대안 경로
      ];

      for (int i = 0; i < possibleUrls.length; i++) {
        final url = possibleUrls[i];
        debugPrint('JSON URL 시도 ${i + 1}: $url');

        // 🔥 요청 바디 준비 (JWT 토큰에서 사용자 ID 추출하므로 id 제외)
        Map<String, dynamic> requestBody = {
          'category': category,
          'title': title,
          'content': content,
        };

        final response = await ApiHelper.post(url, body: requestBody);

        debugPrint('JSON 요청 URL: ${response.request?.url}');
        debugPrint('JSON 요청 헤더: ${response.request?.headers}');
        debugPrint('JSON 요청 바디: ${jsonEncode(requestBody)}');

        debugPrint('JSON 응답 상태: ${response.statusCode}');
        debugPrint('JSON 응답 헤더: ${response.headers}');
        debugPrint('JSON 응답 내용: ${response.body}');

        if (response.statusCode == 201 || response.statusCode == 200) {
          debugPrint('✅ JSON 문의하기 작성 성공 (URL: $url)');
          return true;
        } else if (response.statusCode == 500) {
          debugPrint('⚠️ 서버 내부 오류 (URL: $url): ${response.body}');
          debugPrint('⚠️ 서버 로그를 확인해주세요. 필수 필드 누락 또는 형식 오류일 수 있습니다.');
          if (i < possibleUrls.length - 1) {
            debugPrint('다음 JSON URL 시도...');
          }
        } else {
          debugPrint('❌ JSON 문의하기 작성 실패 (URL: $url): ${response.statusCode}');
          if (i < possibleUrls.length - 1) {
            debugPrint('다음 JSON URL 시도...');
          }
        }
      }

      debugPrint('❌ 모든 JSON URL 시도 실패');
      return false;
    } catch (e) {
      debugPrint('❌ JSON 요청 오류: $e');
      return false;
    }
  }

  /// 문의하기 목록 조회 (필요시 구현)
  static Future<List<Map<String, dynamic>>> getInquiryList() async {
    try {
      debugPrint('=== 문의하기 목록 조회 시작 ===');

      // 🔥 서버 라우트: router.get('/', authMiddleware, inquiryController.getInquiry)
      final response = await ApiHelper.get(baseUrl);

      debugPrint('응답 상태: ${response.statusCode}');
      debugPrint('응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        // 🔥 서버 응답 구조에 맞게 파싱: {"success": true, "data": [...]}
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        debugPrint('📊 서버 응답 구조: $responseData');
        
        if (responseData['success'] != true) {
          debugPrint('❌ 서버에서 실패 응답: ${responseData['message'] ?? '알 수 없는 오류'}');
          return [];
        }
        
        final List<dynamic> data = responseData['data'] ?? [];
        debugPrint('✅ 문의하기 목록 조회 성공: ${data.length}개');
        return data.cast<Map<String, dynamic>>();
      } else {
        debugPrint('❌ 문의하기 목록 조회 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ 문의하기 목록 조회 오류: $e');
      return [];
    }
  }

  /// 문의하기 상세 조회 (필요시 구현)
  static Future<Map<String, dynamic>?> getInquiryDetail(
    String inquiryId,
  ) async {
    try {
      debugPrint('=== 문의하기 상세 조회 시작 ===');
      debugPrint('문의 ID: $inquiryId');

      // 🔥 서버 라우트 확인 필요: 상세 조회 라우터 구조에 따라 조정
      final response = await ApiHelper.get('$baseUrl/detail/$inquiryId');

      debugPrint('응답 상태: ${response.statusCode}');
      debugPrint('응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        // 🔥 서버 응답 구조에 맞게 파싱: {"success": true, "data": {...}}
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        debugPrint('📊 서버 응답 구조: $responseData');
        
        if (responseData['success'] != true) {
          debugPrint('❌ 서버에서 실패 응답: ${responseData['message'] ?? '알 수 없는 오류'}');
          return null;
        }
        
        final data = responseData['data'];
        debugPrint('✅ 문의하기 상세 조회 성공');
        return data;
      } else {
        debugPrint('❌ 문의하기 상세 조회 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ 문의하기 상세 조회 오류: $e');
      return null;
    }
  }

  /// 서버에서 사용 가능한 경로 테스트
  static Future<void> testServerRoutes(String userId) async {
    debugPrint('=== 서버 경로 테스트 시작 ===');

    final List<String> testUrls = [
      '${ApiConfig.baseHost}:3001/user/inquiry',
      '${ApiConfig.baseHost}:3001/inquiry/$userId',
      '${ApiConfig.baseHost}:3001/user/inquiry/$userId',
      '${ApiConfig.baseHost}:3001/inquiry',
    ];

    for (int i = 0; i < testUrls.length; i++) {
      final url = testUrls[i];
      debugPrint('테스트 URL ${i + 1}: $url');

      try {
        // 🔥 JWT 토큰을 포함한 테스트 요청
        final response = await ApiHelper.get(url);
        debugPrint('GET $url: ${response.statusCode}');

        final postResponse = await ApiHelper.post(
          url,
          body: {'test': 'test'},
        );
        debugPrint('POST $url: ${postResponse.statusCode}');
      } catch (e) {
        debugPrint('오류 $url: $e');
      }
    }
  }

  /// 문의 목록 조회
  static Future<List<InquiryItem>> getInquiries() async {
    try {
      debugPrint('=== 문의 목록 조회 시작 ===');
      debugPrint('API 기본 URL: ${ApiConfig.baseHost}:3001');

      final List<String> possibleUrls = [
        '${ApiConfig.baseHost}:3001/inquiry/my', // 🔥 서버 라우트: router.get('/my', authMiddleware, inquiryController.getInquiry)
        '${ApiConfig.baseHost}:3001/inquiry', // 대안 경로
        '${ApiConfig.baseHost}:3001/user/inquiry', // 대안 경로
      ];

      for (int i = 0; i < possibleUrls.length; i++) {
        final url = possibleUrls[i];
        debugPrint('URL 시도 ${i + 1}: $url');

        try {
          final response = await ApiHelper.get(url);

          debugPrint('응답 상태: ${response.statusCode}');
          debugPrint('응답 내용: ${response.body}');

          if (response.statusCode == 200) {
            debugPrint('✅ 200 응답 받음');
            
            // 🔥 서버 응답 구조에 맞게 파싱: {"success": true, "data": [...]}
            final Map<String, dynamic> responseData = jsonDecode(response.body);
            debugPrint('📊 서버 응답 구조: $responseData');
            
            if (responseData['success'] != true) {
              debugPrint('❌ 서버에서 실패 응답: ${responseData['message'] ?? '알 수 없는 오류'}');
              return [];
            }
            
            final List<dynamic> data = responseData['data'] ?? [];
            debugPrint('파싱된 데이터 개수: ${data.length}');
            debugPrint('데이터 내용: $data');

            // 서버에서 빈 배열이 반환되는 경우 빈 리스트 반환
            if (data.isEmpty) {
              debugPrint('⚠️ 서버에서 빈 배열이 반환되었습니다. 빈 리스트를 반환합니다.');
              return [];
            }

            // 데이터가 있는 경우 파싱
            final List<InquiryItem> inquiries = data.map((item) {
              debugPrint('=== 개별 문의 파싱 시작 ===');
              debugPrint('원본 데이터: $item');

              // 서버 상태값을 한국어로 변환
              String status = item['Status']?.toString() ?? 'pending';
              String displayStatus = _convertStatusToKorean(status);
              debugPrint('상태 변환: $status → $displayStatus');

              // 날짜 포맷팅 (시간 정보 포함, 18시간 보정)
              String createdAt = '';
              if (item['Created_At'] != null) {
                try {
                  DateTime date = DateTime.parse(item['Created_At']);
                  
                  // 🔥 18시간을 더해서 정확한 시간으로 보정
                  DateTime correctedTime = date.add(const Duration(hours: 18));
                  
                  debugPrint('📅 서버 날짜 파싱: ${item['Created_At']}');
                  debugPrint('   원본 시간: $date');
                  debugPrint('   보정된 시간: $correctedTime');
                  
                  createdAt = correctedTime.toIso8601String();
                  
                  debugPrint('   최종 저장: $createdAt');
                } catch (e) {
                  debugPrint('❌ 날짜 파싱 실패: ${item['Created_At']}, 오류: $e');
                  createdAt = item['Created_At'].toString();
                }
              }

              // 답변일 포맷팅 (시간 정보 포함, 18시간 보정)
              String? answeredAt;
              if (item['Answered_At'] != null) {
                try {
                  DateTime date = DateTime.parse(item['Answered_At']);
                  
                  // 🔥 18시간을 더해서 정확한 시간으로 보정
                  DateTime correctedTime = date.add(const Duration(hours: 18));
                  
                  debugPrint('📅 답변일 파싱: ${item['Answered_At']}');
                  debugPrint('   원본 시간: $date');
                  debugPrint('   보정된 시간: $correctedTime');
                  
                  answeredAt = correctedTime.toIso8601String();
                  
                  debugPrint('   최종 저장: $answeredAt');
                } catch (e) {
                  debugPrint('❌ 답변일 파싱 실패: ${item['Answered_At']}, 오류: $e');
                  answeredAt = item['Answered_At'].toString();
                }
              }

              final inquiryItem = InquiryItem(
                id: item['Inquiry_Code']?.toString() ?? '',
                category: item['Category']?.toString() ?? '',
                title: item['Title']?.toString() ?? '',
                content: item['Content']?.toString() ?? '',
                status: displayStatus,
                createdAt: createdAt,
                hasImage:
                    item['Image_Path'] != null &&
                    item['Image_Path'].toString().isNotEmpty,
                inquiryCode: item['Inquiry_Code']?.toString() ?? '',
                answer: item['Answer']?.toString(),
                answeredAt: answeredAt,
                imagePath: item['Image_Path']?.toString(),
              );

              debugPrint(
                '파싱된 문의: ${inquiryItem.title} (${inquiryItem.status})',
              );
              return inquiryItem;
            }).toList();

            debugPrint('✅ 문의 목록 조회 성공: ${inquiries.length}개');
            return inquiries;
          } else if (response.statusCode == 404) {
            debugPrint('⚠️ 404 응답: 문의를 찾을 수 없습니다.');
            debugPrint('응답 내용: ${response.body}');
            
            // 서버에서 문의가 없을 때 404를 반환하므로 빈 리스트 반환
            return [];
          } else {
            debugPrint('❌ 문의 목록 조회 실패: ${response.statusCode}');
            debugPrint('응답 내용: ${response.body}');
          }
        } catch (e) {
          debugPrint('❌ URL 시도 ${i + 1} 실패: $e');
        }
      }

      // 모든 URL 시도가 실패한 경우 빈 리스트 반환 (테스트 데이터 비활성화)
      debugPrint('⚠️ 모든 API URL 시도가 실패했습니다. 빈 리스트를 반환합니다.');
      return [];
    } catch (e) {
      debugPrint('❌ 문의 목록 조회 오류: $e');
      return [];
    }
  }

  /// 서버 상태값을 한국어로 변환
  static String _convertStatusToKorean(String serverStatus) {
    switch (serverStatus.toLowerCase()) {
      case 'pending':
        return '답변 대기';
      case 'answered':
        return '답변 완료';
      default:
        return '답변 대기';
    }
  }

  /// 문의 삭제
  static Future<bool> deleteInquiry(String userId, String inquiryCode) async {
    try {
      debugPrint('=== 문의 삭제 시작 ===');
      debugPrint('사용자 ID: $userId');
      debugPrint('문의 코드: $inquiryCode');

      final List<String> possibleUrls = [
        '${ApiConfig.baseHost}:3001/user/inquiry/$userId',
        '${ApiConfig.baseHost}:3001/inquiry/$userId',
      ];

      for (int i = 0; i < possibleUrls.length; i++) {
        final url = possibleUrls[i];
        debugPrint('URL 시도 ${i + 1}: $url');

        try {
          final response = await ApiHelper.delete(url, body: {'inquiry_code': inquiryCode});

          debugPrint('응답 상태: ${response.statusCode}');
          debugPrint('응답 내용: ${response.body}');

          if (response.statusCode == 200) {
            debugPrint('✅ 문의 삭제 성공');
            return true;
          } else {
            debugPrint('❌ 문의 삭제 실패: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('❌ URL 시도 ${i + 1} 실패: $e');
        }
      }

      debugPrint('❌ 모든 URL 시도 실패');
      return false;
    } catch (e) {
      debugPrint('❌ 문의 삭제 오류: $e');
      return false;
    }
  }
}

// 문의 아이템 모델
class InquiryItem {
  final String id;
  final String category;
  final String title;
  final String content;
  final String status;
  final String createdAt;
  final bool hasImage;
  final String inquiryCode;
  final String? answer;
  final String? answeredAt;
  final String? imagePath;

  InquiryItem({
    required this.id,
    required this.category,
    required this.title,
    required this.content,
    required this.status,
    required this.createdAt,
    required this.hasImage,
    required this.inquiryCode,
    this.answer,
    this.answeredAt,
    this.imagePath,
  });
}
