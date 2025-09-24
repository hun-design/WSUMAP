import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/api_helper.dart';

class ExcelImportService {
  /// 엑셀 파일을 서버로 업로드 (xlsx만 허용)
  /// 업로드 성공 시 true, 취소 시 false, 실패 시 예외 throw
  static Future<bool> uploadExcelToServer(String userId) async {
    try {
      print('[DEBUG] 엑셀 파일 선택 시작');

      // 안드로이드에서 파일 선택 전에 잠시 대기하여 UI 상태 안정화
      await Future.delayed(const Duration(milliseconds: 100));

      // 파일 선택 (xlsx만 허용)
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result == null || result.files.isEmpty) {
        print('[DEBUG] 파일 선택이 취소되었거나 없음');
        return false;
      }

      final file = File(result.files.first.path!);
      print('[DEBUG] 선택된 파일 경로: ${file.path}');

      if (!await file.exists()) {
        print('[DEBUG] 선택된 파일이 존재하지 않음');
        throw Exception('선택된 파일을 찾을 수 없습니다.');
      }

      if (!file.path.toLowerCase().endsWith('.xlsx')) {
        print('[DEBUG] 확장자 오류: ${file.path}');
        throw Exception('xlsx 파일만 업로드할 수 있습니다.');
      }

      // 🔥 서버 라우터: POST /upload (authMiddleware 적용)
      final uploadUrl = '${ApiConfig.timetableUploadBase}/upload';
      print('[DEBUG] 업로드 요청 URI: $uploadUrl');

      // 🔥 JWT 토큰을 포함한 MultipartRequest 생성
      final request = await ApiHelper.createMultipartRequest('POST', uploadUrl);
      request.files.add(await http.MultipartFile.fromPath('excelFile', file.path));

      print('[DEBUG] MultipartRequest 준비 완료 (JWT 토큰 포함), 업로드 시작');
      print('[DEBUG] 요청 헤더: ${request.headers}');
      print('[DEBUG] 요청 파일 수: ${request.files.length}');

      final response = await request.send();

      print('[DEBUG] 서버에서 받은 응답 상태 코드: ${response.statusCode}');
      print('[DEBUG] 응답 헤더: ${response.headers}');
      final respStr = await response.stream.bytesToString();
      print('[DEBUG] 서버 응답 본문: $respStr');

      if (response.statusCode == 200) {
        print('[DEBUG] 파일 업로드 성공');
        
        // 안드로이드에서 업로드 완료 후 UI 상태 안정화를 위한 대기
        await Future.delayed(const Duration(milliseconds: 200));
        
        return true;
      } else {
        print('[DEBUG] 파일 업로드 실패, 상태 코드: ${response.statusCode}');
        throw Exception('서버 업로드 실패: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('[ERROR] 엑셀 파일 서버 업로드 중 오류 발생: $e');
      print(stackTrace);
      rethrow;
    }
  }
}