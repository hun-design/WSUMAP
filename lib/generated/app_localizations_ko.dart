// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '따라우송';

  @override
  String get subtitle => '스마트 캠퍼스 가이드';

  @override
  String get woosong => '우송';

  @override
  String get start => '시작하기';

  @override
  String get login => '로그인';

  @override
  String get logout => '로그아웃';

  @override
  String get guest => '게스트';

  @override
  String get student_professor => '학생/교수';

  @override
  String get admin => '관리자';

  @override
  String get student => '학생';

  @override
  String get professor => '교수';

  @override
  String get external_user => '외부인';

  @override
  String get username => '아이디';

  @override
  String get password => '비밀번호';

  @override
  String get confirm_password => '비밀번호 확인';

  @override
  String get remember_me => '로그인 정보 기억하기';

  @override
  String get remember_me_description => '다음에 자동으로 로그인됩니다';

  @override
  String get login_as_guest => '게스트로 둘러보기';

  @override
  String get login_failed => '로그인 실패';

  @override
  String get login_success => '로그인 성공';

  @override
  String get logout_success => '로그아웃 되었습니다';

  @override
  String get enter_username => '아이디를 입력하세요';

  @override
  String get enter_password => '비밀번호를 입력하세요';

  @override
  String get password_hint => '6자 이상 입력하세요';

  @override
  String get confirm_password_hint => '비밀번호를 다시 입력하세요';

  @override
  String get username_password_required => '아이디와 비밀번호를 모두 입력해주세요';

  @override
  String get login_error => '로그인에 실패했습니다';

  @override
  String get find_password => '비밀번호 찾기';

  @override
  String get find_username => '아이디 찾기';

  @override
  String get back => '뒤로가기';

  @override
  String get confirm => '확인';

  @override
  String get cancel => '취소';

  @override
  String get coming_soon => '준비 중';

  @override
  String feature_coming_soon(String feature) {
    return '$feature 기능은 준비 중입니다.\n빠른 시일 내에 추가될 예정입니다.';
  }

  @override
  String get departurePoint => '출발';

  @override
  String get arrivalPoint => '도착지';

  @override
  String get all => '전체';

  @override
  String get tutorial => '사용법';

  @override
  String get tutorialTitleIntro => '따라우송 사용법';

  @override
  String get tutorialDescIntro => '우송대학교 캠퍼스 네비게이터로\n캠퍼스 생활을 더욱 편리하게 만들어보세요';

  @override
  String get tutorialTitleSearch => '디테일한 검색 기능';

  @override
  String get tutorialDescSearch =>
      '우송대에서는 건물뿐만이 아닌 강의실도 검색이 가능해요!\n강의실의 위치부터 편의시설까지 디테일하게 검색해 보세요 😊';

  @override
  String get tutorialTitleSchedule => '시간표 연동';

  @override
  String get tutorialDescSchedule =>
      '수업 시간표를 앱에 연동하여\n다음 수업까지의 최적 경로를 자동으로 안내받으세요';

  @override
  String get tutorialTitleDirections => '길찾기';

  @override
  String get tutorialDescDirections => '캠퍼스 내 정확한 경로 안내로\n목적지까지 쉽고 빠르게 도착하세요';

  @override
  String get tutorialTitleIndoorMap => '건물 내부 도면';

  @override
  String get tutorialDescIndoorMap => '건물 내부의 상세한 도면으로\n강의실과 편의시설을 쉽게 찾아보세요';

  @override
  String get dontShowAgain => '다시 보지 않기';

  @override
  String get goBack => '돌아가기';

  @override
  String get lectureRoom => '강의실';

  @override
  String get lectureRoomInfo => '강의실 정보';

  @override
  String get floor => '층';

  @override
  String get personInCharge => '담당자';

  @override
  String get viewLectureRoom => '강의실보기';

  @override
  String get viewBuilding => '건물보기';

  @override
  String get walk => '도보';

  @override
  String get minute => '분';

  @override
  String get hour => '시간';

  @override
  String get less_than_one_minute => '1분 이내';

  @override
  String get zero_minutes => '0분';

  @override
  String get calculation_failed => '계산 불가';

  @override
  String get professor_name => '교수명';

  @override
  String get building_name => '건물';

  @override
  String floor_number(Object floor) {
    return '$floor층';
  }

  @override
  String get room_name => '강의실';

  @override
  String get day_of_week => '요일';

  @override
  String get time => '시간';

  @override
  String get memo => '메모';

  @override
  String get recommend_route => '추천경로';

  @override
  String get view_location => '위치 보기';

  @override
  String get edit => '편집';

  @override
  String get close => '닫기';

  @override
  String get help => '사용법';

  @override
  String get help_intro_title => '따라우송 사용법';

  @override
  String get help_intro_description =>
      '우송대학교 캠퍼스 네비게이터로\n캠퍼스 생활을 더욱 편리하게 만들어보세요';

  @override
  String get help_detailed_search_title => '세부 검색';

  @override
  String get help_detailed_search_description =>
      '건물명, 강의실 번호, 편의시설까지\n정확하고 빠른 검색으로 원하는 곳을 찾아보세요';

  @override
  String get help_timetable_title => '시간표 연동';

  @override
  String get help_timetable_description =>
      '수업 시간표를 앱에 연동하여\n다음 수업까지의 최적 경로를 자동으로 안내받으세요';

  @override
  String get help_directions_title => '길찾기';

  @override
  String get help_directions_description =>
      '캠퍼스 내 정확한 경로 안내로\n목적지까지 쉽고 빠르게 도착하세요';

  @override
  String get help_building_map_title => '건물 내부 도면';

  @override
  String get help_building_map_description =>
      '건물 내부의 상세한 도면으로\n강의실과 편의시설을 쉽게 찾아보세요';

  @override
  String get previous => '이전';

  @override
  String get next => '다음';

  @override
  String get done => '완료';

  @override
  String get image_load_error => '이미지를 불러올 수 없습니다';

  @override
  String get start_campus_exploration => '캠퍼스 탐색을 시작해보세요';

  @override
  String get woosong_university => '우송대학교';

  @override
  String get excel_upload_title => '시간표 엑셀 파일 업로드';

  @override
  String get excel_upload_description => '우송대학교 시간표 엑셀 파일(.xlsx)을 선택해주세요';

  @override
  String get excel_file_select => '엑셀 파일 선택';

  @override
  String get excel_upload_uploading => '엑셀 파일을 업로드하고 있습니다...';

  @override
  String get language_selection => '언어 선택';

  @override
  String get language_selection_description => '사용하실 언어를 선택해주세요';

  @override
  String get departure => '출발';

  @override
  String get destination => '도착지';

  @override
  String get my_location => '내위치';

  @override
  String get current_location => '현재위치';

  @override
  String get welcome_subtitle_1 => '내 손 안의 따라우송,';

  @override
  String get welcome_subtitle_2 => '건물 정보가 다 여기에!';

  @override
  String get select_language => '언어 선택';

  @override
  String get auth_selection_title => '인증 방법 선택';

  @override
  String get auth_selection_subtitle => '원하시는 로그인 방법을 선택해주세요';

  @override
  String get select_auth_method => '인증 방법 선택';

  @override
  String total_floors(Object count) {
    return '총 $count층';
  }

  @override
  String get floor_info => '층별 정보';

  @override
  String floor_with_category(Object category) {
    return '$category이(가) 있는 층';
  }

  @override
  String get floor_label => '층';

  @override
  String get category => '분류';

  @override
  String get excel_upload_success => '업로드 완료!';

  @override
  String get guest_timetable_disabled => '게스트 사용자는 시간표 기능을 사용할 수 없습니다.';

  @override
  String get guest_timetable_add_disabled => '게스트 사용자는 시간표를 추가할 수 없습니다.';

  @override
  String get guest_timetable_edit_disabled => '게스트 사용자는 시간표를 수정할 수 없습니다.';

  @override
  String get guest_timetable_delete_disabled => '게스트 사용자는 시간표를 삭제할 수 없습니다.';

  @override
  String get timetable_load_failed => '시간표를 불러오지 못했습니다.';

  @override
  String get timetable_add_success => '시간표가 성공적으로 추가되었습니다.';

  @override
  String timetable_add_failed(Object error) {
    return '시간표 추가에 실패했습니다: $error';
  }

  @override
  String get timetable_overlap => '이미 같은 시간에 등록된 수업이 있습니다.';

  @override
  String get required_fields_missing => '필수 입력값을 모두 입력해 주세요.';

  @override
  String get no_search_results => '검색 결과가 없습니다';

  @override
  String get excel_upload_refreshing => '시간표를 새로고침하고 있습니다...';

  @override
  String get logout_processing => '로그아웃 중...';

  @override
  String get logout_error_message => '로그아웃 중 오류가 발생했지만 초기 화면으로 이동합니다.';

  @override
  String get data_to_be_deleted => '삭제될 데이터';

  @override
  String get deleting_account => '계정을 삭제하는 중...';

  @override
  String get excel_tutorial_title => '엑셀 파일 다운로드 방법';

  @override
  String get edit_profile_section => '회원정보 수정';

  @override
  String get delete_account_section => '회원탈퇴';

  @override
  String get logout_section => '로그아웃';

  @override
  String get location_share_title => '위치 공유';

  @override
  String get location_share_enabled => '위치 공유 활성화됨';

  @override
  String get location_share_disabled => '위치 공유 비활성화됨';

  @override
  String get excel_tutorial_previous => '이전';

  @override
  String get room_route_error => '호실 경로 계산 중 오류가 발생했습니다. 건물 단위로 검색해보세요.';

  @override
  String get location_check_error => '현재 위치를 확인할 수 없습니다. 다시 시도해주세요.';

  @override
  String get server_connection_error => '서버 연결에 문제가 있습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get route_calculation_error => '경로 계산 중 오류가 발생했습니다. 다시 시도해주세요.';

  @override
  String get try_again => '다시 시도';

  @override
  String get current_location_departure => '현재위치에서 출발';

  @override
  String get current_location_departure_default => '기본위치에서 출발';

  @override
  String get current_location_navigation_start => '현재 위치에서 길찾기를 시작합니다';

  @override
  String get excel_tutorial_next => '다음';

  @override
  String get profile_edit_title => '프로필 수정';

  @override
  String get profile_edit_subtitle => '개인정보를 수정할 수 있습니다';

  @override
  String get account_delete_title => '계정 삭제';

  @override
  String get account_delete_subtitle => '계정을 영구적으로 삭제합니다';

  @override
  String get logout_title => '로그아웃';

  @override
  String get logout_subtitle => '현재 계정에서 로그아웃합니다';

  @override
  String get location_share_enabled_success => '위치 공유가 활성화되었습니다';

  @override
  String get location_share_disabled_success => '위치 공유가 비활성화되었습니다';

  @override
  String get profile_edit_error => '프로필 수정 중 오류가 발생했습니다';

  @override
  String get inquiry_load_failed => 'Failed to load inquiry list';

  @override
  String get pull_to_refresh => 'Pull down to refresh';

  @override
  String get app_version_number => 'v1.0.0';

  @override
  String get developer_email_address => 'wsumap41@gmail.com';

  @override
  String get developer_github_url => 'https://github.com/WSU-YJB/WSUMAP';

  @override
  String get friend_management => '친구 관리';

  @override
  String get excel_tutorial_file_select => '파일 선택';

  @override
  String get excel_tutorial_help => '사용법 보기';

  @override
  String get excel_upload_file_cancelled => '파일 선택이 취소되었습니다.';

  @override
  String get excel_upload_success_message => '시간표가 업데이트되었습니다!';

  @override
  String excel_upload_refresh_failed(String error) {
    return '새로고침 실패: $error';
  }

  @override
  String excel_upload_failed(String error) {
    return '업로드 실패: $error';
  }

  @override
  String get excel_tutorial_step_1 => '1. 우송대학교 대학정보시스템에 로그인';

  @override
  String get excel_tutorial_url => 'https://wsinfo.wsu.ac.kr';

  @override
  String get excel_tutorial_image_load_error => '이미지를 불러올 수 없습니다';

  @override
  String get excel_tutorial_unknown_page => '알 수 없는 페이지';

  @override
  String get campus_navigator => '캠퍼스 네비게이터';

  @override
  String get user_info_not_found => '로그인 응답에서 사용자 정보를 찾을 수 없습니다';

  @override
  String get unexpected_login_error => '로그인 중 예상치 못한 오류가 발생했습니다';

  @override
  String get login_required => '로그인이 필요합니다';

  @override
  String get register => '회원가입';

  @override
  String get register_success => '회원가입이 완료되었습니다';

  @override
  String get register_success_message => '회원가입이 완료되었습니다!\n로그인 화면으로 이동합니다.';

  @override
  String get register_error => '회원가입 중 예상치 못한 오류가 발생했습니다';

  @override
  String get update_user_info => '회원정보 수정';

  @override
  String get update_success => '회원정보가 수정되었습니다';

  @override
  String get update_error => '회원정보 수정 중 예상치 못한 오류가 발생했습니다';

  @override
  String get delete_account => '회원 탈퇴';

  @override
  String get delete_success => '회원 탈퇴가 완료되었습니다';

  @override
  String get delete_error => '회원 탈퇴 중 예상치 못한 오류가 발생했습니다';

  @override
  String get name => '이름';

  @override
  String get phone => '전화번호';

  @override
  String get email => '이메일';

  @override
  String get student_number => '학번';

  @override
  String get user_type => '사용자 유형';

  @override
  String get optional => '선택사항';

  @override
  String get required_fields_empty => '모든 필수 항목을 입력해주세요';

  @override
  String get password_mismatch => '비밀번호가 일치하지 않습니다';

  @override
  String get password_too_short => '비밀번호는 6자 이상이어야 합니다';

  @override
  String get invalid_phone_format => '올바른 전화번호 형식을 입력해주세요 (예: 010-1234-5678)';

  @override
  String get invalid_email_format => '올바른 이메일 형식을 입력해주세요';

  @override
  String get required_fields_notice => '* 표시된 항목은 필수 입력 사항입니다';

  @override
  String get welcome_to_campus_navigator => '우송대 캠퍼스 네비게이터에 오신 것을 환영합니다';

  @override
  String get enter_real_name => '실명을 입력하세요';

  @override
  String get phone_format_hint => '010-1234-5678';

  @override
  String get enter_student_number => '학번 또는 교번을 입력하세요';

  @override
  String get email_hint => 'example@woosong.org';

  @override
  String get create_account => '계정 만들기';

  @override
  String get loading => '로딩 중...';

  @override
  String get error => '오류';

  @override
  String get success => '성공';

  @override
  String get validation_error => '입력값을 확인해주세요';

  @override
  String get network_error => '네트워크 오류가 발생했습니다';

  @override
  String get server_error => '서버 오류가 발생했습니다';

  @override
  String get unknown_error => '알 수 없는 오류가 발생했습니다';

  @override
  String get woosong_campus_guide_service => '우송대학교 캠퍼스 길안내 서비스';

  @override
  String get register_description => '새로운 계정을 만들어 모든 기능을 이용하세요';

  @override
  String get login_description => '기존 계정으로 로그인하여 서비스를 이용하세요';

  @override
  String get browse_as_guest => '게스트로 둘러보기';

  @override
  String get processing => '처리 중...';

  @override
  String get campus_navigator_version => 'Campus Navigator v1.0';

  @override
  String get guest_mode => '게스트 모드';

  @override
  String get guest_mode_confirm =>
      '게스트 모드로 입장하시겠습니까?\n\n게스트 모드에서는 친구 기능과 위치 공유 기능을 사용할 수 없습니다.';

  @override
  String get app_name => '따라우송';

  @override
  String get welcome_to_ttarausong => '따라우송에 오신 것을 환영합니다';

  @override
  String get guest_mode_description =>
      '게스트 모드에서는 기본적인 캠퍼스 정보만 확인할 수 있습니다.\n모든 기능을 이용하려면 회원가입 후 로그인해주세요.';

  @override
  String get continue_as_guest => '게스트로 계속';

  @override
  String get moved_to_my_location => '내 위치로 자동 이동했습니다';

  @override
  String get friends_screen_bottom_sheet => '친구 화면은 바텀 시트로 표시됩니다';

  @override
  String get finding_current_location => '현재 위치를 찾는 중...';

  @override
  String get home => '홈';

  @override
  String get timetable => '시간표';

  @override
  String get friends => '친구';

  @override
  String get finish => '완료';

  @override
  String get profile => '프로필';

  @override
  String get inquiry => '문의하기';

  @override
  String get my_inquiry => '내 문의';

  @override
  String get inquiry_type => '문의 유형';

  @override
  String get inquiry_type_required => '문의 유형을 선택해주세요';

  @override
  String get inquiry_type_select_hint => '문의 유형을 선택하세요';

  @override
  String get inquiry_title => '문의 제목';

  @override
  String get inquiry_content => '문의 내용';

  @override
  String get inquiry_content_hint => '문의 내용을 입력하세요';

  @override
  String get inquiry_submit => '문의 제출';

  @override
  String get inquiry_submit_success => '문의가 성공적으로 제출되었습니다';

  @override
  String get inquiry_submit_failed => '문의 제출에 실패했습니다';

  @override
  String get no_inquiry_history => '문의 내역이 없습니다';

  @override
  String get no_inquiry_history_hint => '아직 문의한 내역이 없습니다';

  @override
  String get inquiry_delete => '문의 삭제';

  @override
  String get inquiry_delete_confirm => '이 문의를 삭제하시겠습니까?';

  @override
  String get inquiry_delete_success => '문의가 삭제되었습니다';

  @override
  String get inquiry_delete_failed => '문의 삭제에 실패했습니다';

  @override
  String get inquiry_detail => '문의 상세';

  @override
  String get inquiry_category => '문의 카테고리';

  @override
  String get inquiry_status => '문의 상태';

  @override
  String get inquiry_created_at => '문의 일시';

  @override
  String get inquiry_title_label => '문의 제목';

  @override
  String get inquiry_type_bug => '버그 신고';

  @override
  String get inquiry_type_feature => '기능 제안';

  @override
  String get inquiry_type_improvement => '개선 제안';

  @override
  String get inquiry_type_other => '기타 문의';

  @override
  String get inquiry_status_pending => '답변 대기';

  @override
  String get inquiry_status_in_progress => '처리 중';

  @override
  String get inquiry_status_answered => '답변 완료';

  @override
  String get phone_required => '전화번호는 필수입니다';

  @override
  String get building_info => '건물 정보';

  @override
  String get directions => '길찾기';

  @override
  String get floor_detail_view => '층별 상세 정보';

  @override
  String get no_floor_info => '층 정보가 없습니다';

  @override
  String get floor_detail_info => '층별 상세 정보';

  @override
  String get search_start_location => '출발지 검색';

  @override
  String get search_end_location => '도착지 검색';

  @override
  String get unified_navigation_in_progress => '통합 내비게이션 진행 중';

  @override
  String get unified_navigation => '통합 내비게이션';

  @override
  String get recent_searches => 'Recent Searches';

  @override
  String get clear_all => 'All';

  @override
  String get searching => 'Searching...';

  @override
  String get try_different_keyword => 'Try a different keyword';

  @override
  String get enter_end_location => '도착지를 입력하세요';

  @override
  String get route_preview => '경로 미리보기';

  @override
  String get calculating_optimal_route => '최적 경로를 계산하고 있습니다';

  @override
  String get set_departure_and_destination => '출발지와 도착지를 설정하세요';

  @override
  String get start_unified_navigation => '통합 내비게이션 시작';

  @override
  String get departure_indoor => '실내 출발';

  @override
  String get to_building_exit => '건물 출구로';

  @override
  String get outdoor_movement => '실외 이동';

  @override
  String get to_destination_building => '목적지 건물로';

  @override
  String get arrival_indoor => '실내 도착';

  @override
  String get to_final_destination => '최종 목적지로';

  @override
  String get total_distance => '총 거리';

  @override
  String get route_type => '경로 유형';

  @override
  String get building_to_building => '건물 → 건물';

  @override
  String get room_to_building => '호실 → 건물';

  @override
  String get building_to_room => '건물 → 호실';

  @override
  String get room_to_room => '호실 → 호실';

  @override
  String get location_to_building => '현재 위치 → 건물';

  @override
  String get unified_route => '통합 경로';

  @override
  String get status_offline => 'Offline';

  @override
  String get status_open => 'Open';

  @override
  String get status_closed => 'Closed';

  @override
  String get status_24hours => '24 Hours';

  @override
  String get status_temp_closed => 'Temporarily Closed';

  @override
  String get status_closed_permanently => 'Permanently Closed';

  @override
  String get status_next_open => 'Opens at 9 AM';

  @override
  String get status_next_close => 'Closes at 6 PM';

  @override
  String get status_next_open_tomorrow => 'Opens tomorrow at 9 AM';

  @override
  String get set_start_point => '출발지 설정';

  @override
  String get set_end_point => '도착지 설정';

  @override
  String get scheduleDeleteTitle => '시간표 삭제';

  @override
  String get scheduleDeleteSubtitle => '신중하게 결정해주세요';

  @override
  String get scheduleDeleteLabel => '삭제할 시간표';

  @override
  String scheduleDeleteDescription(Object title) {
    return '\"$title\" 수업이 시간표에서 삭제됩니다.\n삭제된 시간표는 복구할 수 없습니다.';
  }

  @override
  String get cancelButton => '취소';

  @override
  String get deleteButton => '삭제';

  @override
  String get overlap_message =>
      'There is already a class registered at this time';

  @override
  String friendDeleteSuccessMessage(Object userName) {
    return '$userName has been removed from friends list';
  }

  @override
  String get enterFriendIdPrompt => '친구의 ID를 입력해주세요';

  @override
  String get friendId => '친구 ID';

  @override
  String get enterFriendId => '친구 ID 입력';

  @override
  String get sendFriendRequest => '친구 요청 보내기';

  @override
  String get realTimeSyncActive => '실시간 동기화 활성화';

  @override
  String get noSentRequests => '보낸 친구 요청이 없습니다';

  @override
  String newFriendRequests(int count) {
    return '$count개의 새로운 친구 요청';
  }

  @override
  String get noReceivedRequests => '받은 친구 요청이 없습니다';

  @override
  String get id => 'ID';

  @override
  String requestDate(String date) {
    return '요청일: $date';
  }

  @override
  String get newBadge => 'NEW';

  @override
  String get online => 'Online';

  @override
  String get offline => '오프라인';

  @override
  String get contact => '연락처';

  @override
  String get noContactInfo => '연락처 정보 없음';

  @override
  String get friendOfflineError => '오프라인 친구의 위치를 볼 수 없습니다';

  @override
  String get removeLocation => '위치제거';

  @override
  String get showLocation => '위치보기';

  @override
  String friendLocationRemoved(String userName) {
    return '$userName\'s location has been removed';
  }

  @override
  String friendLocationShown(String userName) {
    return '$userName\'s location has been shown';
  }

  @override
  String get errorCannotRemoveLocation => 'Cannot remove location';

  @override
  String get my_page => '내 페이지';

  @override
  String get calculating_route => 'Calculating route...';

  @override
  String get finding_optimal_route => 'Server is finding optimal route';

  @override
  String get clear_route => 'Clear Route';

  @override
  String get location_permission_denied =>
      'Location permission denied.\nPlease allow location permission in settings.';

  @override
  String get estimated_time => '예상 시간';

  @override
  String get location_share_update_failed => '위치 공유 설정 업데이트에 실패했습니다';

  @override
  String get guest_location_share_success => '게스트 모드에서는 로컬에서만 위치 공유가 설정됩니다';

  @override
  String get no_changes => '변경사항이 없습니다';

  @override
  String get password_confirm_title => '비밀번호 확인';

  @override
  String get password_confirm_subtitle => '회원정보 수정을 위해 비밀번호를 입력해주세요';

  @override
  String get password_confirm_button => '확인';

  @override
  String get password_required => '비밀번호를 입력해주세요';

  @override
  String get password_mismatch_confirm => '비밀번호가 일치하지 않습니다';

  @override
  String get profile_updated => '프로필이 수정되었습니다';

  @override
  String get my_page_subtitle => '내 정보';

  @override
  String get excel_file => '엑셀 파일';

  @override
  String get excel_file_tutorial => '엑셀 파일 사용법';

  @override
  String get image_attachment => '사진 첨부';

  @override
  String get max_one_image => '최대 1장';

  @override
  String get photo_attachment => '사진 첨부';

  @override
  String get photo_attachment_complete => '사진 첨부 완료';

  @override
  String get image_selection => '이미지 선택';

  @override
  String get select_image_method => '이미지 선택 방법';

  @override
  String get select_from_gallery => '갤러리에서 선택';

  @override
  String get select_from_gallery_desc => '갤러리에서 이미지를 선택합니다';

  @override
  String get select_from_file => '파일에서 선택';

  @override
  String get select_from_file_desc => '파일에서 이미지를 선택합니다';

  @override
  String get max_one_image_error => '이미지는 최대 1장만 첨부할 수 있습니다';

  @override
  String get image_selection_error => '이미지 선택 중 오류가 발생했습니다';

  @override
  String get inquiry_error_occurred => '문의 처리 중 오류가 발생했습니다';

  @override
  String get inquiry_category_bug => '버그 신고';

  @override
  String get inquiry_category_feature => '기능 제안';

  @override
  String get inquiry_category_other => '기타 문의';

  @override
  String get inquiry_category_route_error => '경로 안내 오류';

  @override
  String get inquiry_category_place_error => '장소/정보 오류';

  @override
  String get location_share_updating => '상태 업데이트 중...';

  @override
  String get schedule => '시간표';

  @override
  String get winter_semester => '겨울학기';

  @override
  String get spring_semester => '봄학기';

  @override
  String get summer_semester => '여름학기';

  @override
  String get fall_semester => '2학기';

  @override
  String get monday => '월';

  @override
  String get tuesday => '화';

  @override
  String get wednesday => '수';

  @override
  String get thursday => '목';

  @override
  String get friday => '금';

  @override
  String get add_class => '수업 추가';

  @override
  String get edit_class => '수업 편집';

  @override
  String get delete_class => '수업 삭제';

  @override
  String get class_name => '수업명';

  @override
  String get classroom => '강의실';

  @override
  String get start_time => '시작 시간';

  @override
  String get end_time => '종료 시간';

  @override
  String get color_selection => '색상 선택';

  @override
  String get monday_full => '월요일';

  @override
  String get tuesday_full => '화요일';

  @override
  String get wednesday_full => '수요일';

  @override
  String get thursday_full => '목요일';

  @override
  String get friday_full => '금요일';

  @override
  String get class_added => '수업이 추가되었습니다';

  @override
  String get class_updated => '수업이 수정되었습니다';

  @override
  String get class_deleted => '수업이 삭제되었습니다';

  @override
  String delete_class_confirm(String className) {
    return '$className 수업을 삭제하시겠습니까?';
  }

  @override
  String get view_on_map => '지도에서 보기';

  @override
  String get location => '위치';

  @override
  String get schedule_time => '시간';

  @override
  String get schedule_day => '요일';

  @override
  String get map_feature_coming_soon => '지도 기능은 곧 제공됩니다';

  @override
  String current_year(int year) {
    return '현재 연도';
  }

  @override
  String get my_friends => '내 친구';

  @override
  String online_friends(int total, int online) {
    return '온라인 친구';
  }

  @override
  String get add_friend => '친구 추가';

  @override
  String get friend_name_or_id => '친구 이름 또는 ID';

  @override
  String get friend_request_sent => '친구 요청이 전송되었습니다';

  @override
  String get in_class => '수업 중';

  @override
  String last_location(String location) {
    return '마지막 위치';
  }

  @override
  String get central_library => '중앙도서관';

  @override
  String get engineering_building => '공학관';

  @override
  String get student_center => '학생회관';

  @override
  String get cafeteria => 'Cafeteria';

  @override
  String get message => '메시지';

  @override
  String get call => '전화';

  @override
  String start_chat_with(String name) {
    return '채팅 시작';
  }

  @override
  String view_location_on_map(String name) {
    return '지도에서 위치 보기';
  }

  @override
  String calling(String name) {
    return '전화 중';
  }

  @override
  String get delete => '삭제';

  @override
  String get search => '검색';

  @override
  String get searchBuildings => '건물 검색';

  @override
  String get myLocation => '내 위치';

  @override
  String get navigation => '내비게이션';

  @override
  String get route => '경로';

  @override
  String get distance => '거리';

  @override
  String get minutes => '분';

  @override
  String get hours => '운영시간';

  @override
  String get within_minute => '1분 이내';

  @override
  String minutes_only(Object minutes) {
    return '$minutes분';
  }

  @override
  String hours_only(Object hours) {
    return '$hours시간';
  }

  @override
  String hours_and_minutes(Object hours, Object minutes) {
    return '$hours시간 $minutes분';
  }

  @override
  String get available => '사용가능';

  @override
  String get start_navigation_from_current_location => '현재 위치에서 길찾기를 시작합니다';

  @override
  String get my_location_set_as_start => '내위치가 출발지로 설정되었습니다';

  @override
  String get default_location_set_as_start => '기본위치가 출발지로 설정되었습니다';

  @override
  String get start_navigation => '길찾기 시작';

  @override
  String get navigation_ended => '길찾기가 종료되었습니다';

  @override
  String get arrival => '도착';

  @override
  String get outdoor_movement_distance => '실외 이동 거리';

  @override
  String get indoor_arrival => '실내 도착';

  @override
  String get indoor_departure => '실내 출발';

  @override
  String get complete => '완료';

  @override
  String get findRoute => '경로 찾기';

  @override
  String get clearRoute => '경로 지우기';

  @override
  String get setAsStart => '출발지로 설정';

  @override
  String get setAsDestination => '도착지로 설정';

  @override
  String get navigateFromHere => '여기서 내비게이션';

  @override
  String get buildingInfo => '건물 정보';

  @override
  String get locationPermissionRequired => '위치 권한이 필요합니다';

  @override
  String get enableLocationServices => '위치 서비스를 활성화해주세요';

  @override
  String get noResults => '결과가 없습니다';

  @override
  String get settings => '설정';

  @override
  String get language => '언어';

  @override
  String get about => '정보';

  @override
  String friends_count_status(int total, int online) {
    return '친구 수 상태';
  }

  @override
  String get enter_friend_info => '친구 정보 입력';

  @override
  String show_location_on_map(String name) {
    return '지도에서 위치 보기';
  }

  @override
  String get location_error => '위치 오류';

  @override
  String get view_floor_plan => '도면 보기';

  @override
  String floor_plan_title(String buildingName) {
    return '도면';
  }

  @override
  String get floor_plan_not_available => '도면을 사용할 수 없습니다';

  @override
  String get floor_plan_default_text => '도면 기본 텍스트';

  @override
  String get delete_account_success => '계정이 성공적으로 삭제되었습니다';

  @override
  String get convenience_store => '편의점';

  @override
  String get vending_machine => '자판기';

  @override
  String get printer => '프린터';

  @override
  String get copier => '복사기';

  @override
  String get atm => 'ATM';

  @override
  String get bank_atm => '은행(ATM)';

  @override
  String get medical => '의료';

  @override
  String get health_center => '보건소';

  @override
  String get gym => '체육관';

  @override
  String get fitness_center => '헬스장';

  @override
  String get lounge => '라운지';

  @override
  String get extinguisher => '소화기';

  @override
  String get water_purifier => '정수기';

  @override
  String get bookstore => '서점';

  @override
  String get post_office => '우체국';

  @override
  String instructionMoveToDestination(String place) {
    return '목적지로 이동하세요';
  }

  @override
  String get markerDeparture => '출발지';

  @override
  String get markerArrival => '도착지';

  @override
  String get errorCannotOpenPhoneApp => '전화앱을 열 수 없습니다.';

  @override
  String get emailCopied => '이메일이 복사되었습니다.';

  @override
  String get description => '설명';

  @override
  String get noDetailedInfoRegistered => '등록된 상세 정보가 없습니다.';

  @override
  String get setDeparture => '출발지 설정';

  @override
  String get setArrival => '도착지 설정';

  @override
  String errorOccurred(Object error) {
    return '오류가 발생했습니다: $error';
  }

  @override
  String get instructionExitToOutdoor => '실외로 나가세요';

  @override
  String instructionMoveToDestinationBuilding(String building) {
    return '목적지 건물로 이동하세요';
  }

  @override
  String get instructionMoveToRoom => '방으로 이동하세요';

  @override
  String get instructionArrived => '도착했습니다';

  @override
  String get no => '아니오';

  @override
  String get woosong_library_w1 => '우송도서관 (W1)';

  @override
  String get woosong_library_info =>
      'B2F\t주차장\nB1F\t소강당, 기계실, 전기실, 주차장\n1F\t취업지원센터 (630-9976), 대출대, 정보휴게실\n2F\t일반열람실, 그룹스터디룸\n3F\t일반열람실\n4F\t문학도서/서양도서';

  @override
  String get educational_facility => 'Educational Facility';

  @override
  String get operating => 'Operating';

  @override
  String get woosong_library_desc => '우송대학교 중앙도서관';

  @override
  String get sol_cafe => '솔카페';

  @override
  String get sol_cafe_info => '1F\t식당\n2F\t카페';

  @override
  String get cafe => '카페';

  @override
  String get sol_cafe_desc => '캠퍼스 내 카페';

  @override
  String get cheongun_1_dormitory => '청운1기숙사';

  @override
  String get cheongun_1_dormitory_info =>
      '1F\t실습실\n2F\t학생식당\n2F\t청운1기숙사(여) (629-6542)\n2F\t생활관\n3~5F\t생활관';

  @override
  String get dormitory => '기숙사';

  @override
  String get cheongun_1_dormitory_desc => '여학생 기숙사';

  @override
  String get industry_cooperation_w2 => '산학협력단 (W2)';

  @override
  String get industry_cooperation_info =>
      '1F\t산학협력단\n2F\t건축공학과 (630-9720)\n3F\t우송대학교융합기술연구소, 산학연종합기업지원센터\n4F\t기업부설연구소, LG CNS 교실, 철도디지털학원 교실';

  @override
  String get industry_cooperation_desc => '산학협력 및 연구시설';

  @override
  String get rotc_w2_1 => '학군단 (W2-1)';

  @override
  String get rotc_info => '\t학군단 (630-4601)';

  @override
  String get rotc_desc => '학군단 시설';

  @override
  String get military_facility => '군사시설';

  @override
  String get international_dormitory_w3 => '유학생기숙사 (W3)';

  @override
  String get international_dormitory_info =>
      '1F\t유학생지원팀 (629-6623)\n1F\t학생식당\n2F\t유학생기숙사 (629-6655)\n2F\t보건실\n3~12F\t생활관';

  @override
  String get international_dormitory_desc => '유학생 전용 기숙사';

  @override
  String get railway_logistics_w4 => '철도물류관 (W4)';

  @override
  String get railway_logistics_info =>
      'B1F\t실습실\n1F\t실습실\n2F\t철도건설시스템학부 (629-6710)\n2F\t철도차량시스템학과 (629-6780)\n3F\t교실/실습실\n4F\t철도시스템학부 (630-6730,9700)\n5F\t소방방재학과 (629-6770)\n5F\t물류시스템학과 (630-9330)';

  @override
  String get railway_logistics_desc => '철도 및 물류 관련 학과';

  @override
  String get health_medical_science_w5 => '보건의료과학관 (W5)';

  @override
  String get health_medical_science_info =>
      'B1F\t주차장\n1F\t시청각실/주차장\n2F\t교실\n2F\t운동건강재활학과 (630-9840)\n3F\t응급구조학과 (630-9280)\n3F\t간호학과 (630-9290)\n4F\t작업치료학과 (630-9820)\n4F\t언어치료청각재활학과 (630-9220)\n5F\t물리치료학과 (630-4620)\n5F\t보건의료경영학과 (630-4610)\n5F\t교실\n6F\t철도경영학과 (630-9770)';

  @override
  String get health_medical_science_desc => '보건의료 관련 학과';

  @override
  String get liberal_arts_w6 => '교양교육관 (W6)';

  @override
  String get liberal_arts_info => '2F\t교실\n3F\t교실\n4F\t교실\n5F\t교실';

  @override
  String get liberal_arts_desc => '교양 교실';

  @override
  String get woosong_hall_w7 => '우송관 (W7)';

  @override
  String get woosong_hall_info =>
      '1F\t입학처 (630-9627)\n1F\t교무처 (630-9622)\n1F\t시설처 (630-9970)\n1F\t관리팀 (629-6658)\n1F\t산학협력단 (630-4653)\n1F\t대외협력처 (630-9636)\n2F\t전략기획처 (630-9102)\n2F\t총무처-총무, 구매 (630-9653)\n2F\t기획처 (630-9661)\n3F\t총장실 (630-8501)\n3F\t국제교류처 (630-9373)\n3F\t유아교육과 (630-9360)\n3F\t경영학전공 (629-6640)\n3F\t금융/부동산학전공 (630-9350)\n4F\t대회의실\n5F\t회의실';

  @override
  String get woosong_hall_desc => '대학 본부 건물';

  @override
  String get woosong_kindergarten_w8 => '우송유치원 (W8)';

  @override
  String get woosong_kindergarten_info => '1F, 2F\t우송유치원 (629~6750~1)';

  @override
  String get woosong_kindergarten_desc => '대학 부속 유치원';

  @override
  String get kindergarten => '유치원';

  @override
  String get west_campus_culinary_w9 => '서캠퍼스조리학원 (W9)';

  @override
  String get west_campus_culinary_info => 'B1F\t실습실\n1F\t실습실\n2F\t실습실';

  @override
  String get west_campus_culinary_desc => '조리 실습 시설';

  @override
  String get social_welfare_w10 => '사회복지융합관 (W10)';

  @override
  String get social_welfare_info =>
      '1F\t시청각실/실습실\n2F\t교실/실습실\n3F\t사회복지학과 (630-9830)\n3F\t글로벌아동교육학과 (630-9260)\n4F\t교실/실습실\n5F\t교실/실습실';

  @override
  String get social_welfare_desc => '사회복지 관련 학과';

  @override
  String get gymnasium_w11 => '체육관 (W11)';

  @override
  String get gymnasium_info => '1F\t체력단련실\n2F~4F\t체육관';

  @override
  String get gymnasium_desc => '체육 시설';

  @override
  String get sports_facility => '체육시설';

  @override
  String get sica_w12 => 'SICA (W12)';

  @override
  String get sica_info =>
      'B1F\t실습실\n1F\t스타리코카페\n2F~3F\t교실\n5F\t글로벌조리학부 (629-6860)';

  @override
  String get sica_desc => '국제조리학원';

  @override
  String get woosong_tower_w13 => '우송타워 (W13)';

  @override
  String get woosong_tower_info =>
      'B1~1F\t주차장\n2F\t주차장, 솔파인베이커리 (629-6429)\n4F\t세미나실\n5F\t교실\n6F\t외식조리영양학과 (630-9380,9740)\n7F\t교실\n8F\t외식, 조리경영전공 (630-9250)\n9F\t교실/실습실\n10F\t외식조리전공 (629-6821), 글로벌한식조리전공 (629-6560)\n11F, 12F\t실습실\n13F\t솔파인레스토랑 (629-6610)';

  @override
  String get woosong_tower_desc => '종합 교육 시설';

  @override
  String get complex_facility => '종합시설';

  @override
  String get culinary_center_w14 => '조리센터 (W14)';

  @override
  String get culinary_center_info =>
      '1F\t교실/실습실\n2F\t교실/실습실\n3F\t교실/실습실\n4F\t교실/실습실\n5F\t교실/실습실';

  @override
  String get culinary_center_desc => '조리전공 교육 시설';

  @override
  String get food_architecture_w15 => '식품건축관 (W15)';

  @override
  String get food_architecture_info =>
      'B1F\t실습실\n1F\t실습실\n2F\t교실\n3F\t교실\n4F\t교실\n5F\t교실';

  @override
  String get food_architecture_desc => '식품 및 건축 관련 학과';

  @override
  String get student_hall_w16 => '학생회관 (W16)';

  @override
  String get student_hall_info =>
      '1F\t학생식당, 교내서점 (629-6127)\n2F\t교직원식당\n3F\t동아리방\n3F\t학생복지처-학생팀 (630-9641), 장학팀 (630-9876)\n3F\t장애학생지원센터 (630-9903)\n3F\t사회봉사단 (630-9904)\n3F\t학생상담센터 (630-9645)\n4F\t복학지원센터 (630-9139)\n4F\t교수학습개발센터 (630-9285)';

  @override
  String get student_hall_desc => '학생 복지 시설';

  @override
  String get media_convergence_w17 => '미디어융합관 (W17)';

  @override
  String get media_convergence_info =>
      'B1F\t교실/실습실\n1F\t미디어디자인/영상전공 (630-9750)\n2F\t교실/실습실\n3F\t게임멀티미디어전공 (630-9270)\n5F\t교실/실습실';

  @override
  String get media_convergence_desc => '미디어 관련 학과';

  @override
  String get woosong_arts_center_w18 => '우송예술회관 (W18)';

  @override
  String get woosong_arts_center_info =>
      'B1F\t공연준비실\n1F\t우송예술회관 (629-6363)\n2F\t실습실\n3F\t실습실\n4F\t실습실\n5F\t실습실';

  @override
  String get woosong_arts_center_desc => '예술 공연 시설';

  @override
  String get west_campus_andycut_w19 => '서캠퍼스앤디컷건물 (W19)';

  @override
  String get west_campus_andycut_info =>
      '2F\t글로벌융합비즈니스학과 (630-9249)\n2F\t자유전공학부 (630-9390)\n2F\tAI/빅데이터학과 (630-9807)\n2F\t글로벌호텔경영학과 (630-9249)\n2F\t글로벌미디어영상학과 (630-9346)\n2F\t글로벌의료서비스경영학과 (630-9283)\n2F\t글로벌철도/교통물류학부 (630-9347)\n2F\t글로벌외식창업학과 (629-6860)';

  @override
  String get west_campus_andycut_desc => '글로벌 학과 건물';

  @override
  String get search_campus_buildings => '캠퍼스 건물 검색';

  @override
  String get building_details => '상세 정보';

  @override
  String get parking => '주차';

  @override
  String get accessibility => '편의시설';

  @override
  String get facilities => '시설';

  @override
  String get elevator => '엘리베이터';

  @override
  String get restroom => '화장실';

  @override
  String get navigate_from_current_location => '현재 위치에서 내비게이션';

  @override
  String get edit_profile => '프로필 편집';

  @override
  String get nameRequired => '이름을 입력해주세요';

  @override
  String get emailRequired => '이메일을 입력해주세요';

  @override
  String get save => '저장';

  @override
  String get saveSuccess => '프로필이 업데이트되었습니다';

  @override
  String get app_info => '앱 정보';

  @override
  String get app_version => '앱 버전';

  @override
  String get developer => '개발자';

  @override
  String get developer_name => '팀원: 정진영, 박철현, 조현준, 최성열, 한승헌, 이예은';

  @override
  String get developer_email => '이메일: wsumap41@gmail.com';

  @override
  String get developer_github => 'GitHub: github.com/WSU-YJB/WSUMAP';

  @override
  String get no_help_images => '도움말 이미지가 없습니다';

  @override
  String get description_hint => '설명을 입력하세요';

  @override
  String get my_info => '내 정보';

  @override
  String get guest_user => '게스트 사용자';

  @override
  String get guest_role => '게스트 역할';

  @override
  String get user => '사용자';

  @override
  String get edit_profile_subtitle => '개인정보를 수정할 수 있습니다';

  @override
  String get help_subtitle => '앱 사용법을 확인하세요';

  @override
  String get app_info_subtitle => '버전 정보 및 개발자 정보';

  @override
  String get delete_account_subtitle => '계정을 영구적으로 삭제합니다';

  @override
  String get login_message => '로그인 또는 회원가입\n모든 기능을 사용하려면';

  @override
  String get login_signup => '로그인 / 회원가입';

  @override
  String get delete_account_confirm => '계정 삭제';

  @override
  String get delete_account_message => '계정을 삭제하시겠습니까?';

  @override
  String get logout_confirm => '로그아웃';

  @override
  String get logout_message => '로그아웃하시겠습니까?';

  @override
  String get yes => '예';

  @override
  String get feature_in_progress => '기능 개발 중';

  @override
  String get delete_feature_in_progress => '계정 삭제 기능은 개발 중입니다';

  @override
  String get title => '프로필 편집';

  @override
  String get email_required => '이메일을 입력해주세요';

  @override
  String get name_required => '이름을 입력해주세요';

  @override
  String get cancelFriendRequest => '친구 요청 취소';

  @override
  String cancelFriendRequestConfirm(String name) {
    return '$name님에게 보낸 친구 요청을 취소하시겠습니까?';
  }

  @override
  String get attached_image => '첨부된 이미지';

  @override
  String get answer_section_title => '답변';

  @override
  String get inquiry_default_answer => '문의에 대한 답변입니다. 추가 문의사항이 있으시면 언제든 연락주세요.';

  @override
  String get answer_date_prefix => '답변일:';

  @override
  String get waiting_answer_status => '답변 대기';

  @override
  String get waiting_answer_message => '문의 내용을 검토 중입니다. 최대한 빨리 답변드리겠습니다.';

  @override
  String get status_pending => '답변 대기';

  @override
  String get status_answered => '답변 완료';

  @override
  String get cancelRequest => '요청 취소';

  @override
  String get friendDeleteTitle => '친구 삭제';

  @override
  String get friendDeleteWarning => '이 작업은 되돌릴 수 없습니다';

  @override
  String get friendDeleteHeader => '친구 삭제';

  @override
  String get friendDeleteToConfirm => '삭제할 친구의 이름을 입력하세요';

  @override
  String get friendDeleteCancel => '취소';

  @override
  String get friendDeleteButton => '삭제';

  @override
  String get friendManagementAndRequests => '친구 관리 및 요청';

  @override
  String get realTimeSyncStatus => '실시간 동기화 상태';

  @override
  String get friendManagement => '친구 관리';

  @override
  String get add => '추가';

  @override
  String sentRequestsCount(int count) {
    return '보낸 요청 ($count)';
  }

  @override
  String receivedRequestsCount(int count) {
    return '받은 요청 ($count)';
  }

  @override
  String friendCount(int count) {
    return '내 친구 ($count)';
  }

  @override
  String get noFriends => '아직 친구가 없습니다.\n위의 + 버튼을 눌러 친구를 추가해보세요!';

  @override
  String get open_settings => '설정 열기';

  @override
  String get retry => '다시 시도';

  @override
  String get basic_info => '기본 정보';

  @override
  String get status => '상태';

  @override
  String get floor_plan => '도면';

  @override
  String get indoorMap => '내부도면';

  @override
  String get showBuildingMarker => '건물 마커 보기';

  @override
  String get search_hint => '캠퍼스 건물 검색';

  @override
  String get searchHint => '건물이나 호실로 검색';

  @override
  String get searchInitialGuide => '건물이나 호실을 검색해보세요';

  @override
  String get searchHintExample => '예: W19, 공학관, 401호';

  @override
  String get searchLoading => '검색 중...';

  @override
  String get searchNoResult => '검색 결과가 없습니다';

  @override
  String get searchTryAgain => '다른 검색어를 시도해보세요';

  @override
  String get required => '필수';

  @override
  String get enter_title => '제목 입력';

  @override
  String get content => '내용';

  @override
  String get enter_content => '내용 입력';

  @override
  String get restaurant => '식당';

  @override
  String get privacy_policy => '개인정보 처리방침';

  @override
  String get privacy_policy_subtitle => '개인정보 처리 방침을 확인하세요';

  @override
  String get fire_extinguisher => '소화기';

  @override
  String get my_location_route_calculating =>
      '내위치에서 건물로의 경로를 계산하고 있습니다. 잠시만 기다려주세요.';

  @override
  String get calculating => '계산 중';

  @override
  String get set_both_locations => '출발지와 도착지를 모두 설정해주세요';

  @override
  String get route_calculating => '경로를 계산하는 중...';

  @override
  String get search_error => '검색 오류';

  @override
  String get search_initial_guide => '건물이나 호실을 검색해보세요';

  @override
  String get search_hint_example => '예: W19, 공학관, 401호';

  @override
  String get search_loading => '검색 중...';

  @override
  String get search_no_result => '검색 결과가 없습니다';

  @override
  String get search_try_again => '다른 검색어를 시도해보세요';

  @override
  String get library => '도서관';

  @override
  String get setting => '설정';

  @override
  String location_setting_confirm(String buildingName, String locationType) {
    return '$buildingName을(를) $locationType로 설정하시겠습니까?';
  }

  @override
  String get set_room => '방 설정하기';

  @override
  String friend_location_permission_denied(String name) {
    return '$name님이 위치 공유를 허용하지 않았습니다';
  }

  @override
  String get no_friends_message => '친구가 없습니다.\n친구를 추가한 후 다시 시도해주세요.';

  @override
  String offline_friends_not_displayed(int count) {
    return '\n오프라인 친구 $count명은 표시되지 않습니다.';
  }

  @override
  String location_denied_friends_not_displayed(int count) {
    return '\n위치 공유 미허용 친구 $count명은 표시되지 않습니다.';
  }

  @override
  String both_offline_and_location_denied(int offlineCount, int locationCount) {
    return '\n오프라인 친구 $offlineCount명, 위치 공유 미허용 친구 $locationCount명은 표시되지 않습니다.';
  }

  @override
  String get all_friends_offline_or_location_denied =>
      '모든 친구가 오프라인이거나 위치 공유를 허용하지 않습니다.\n친구가 온라인에 접속하고 위치 공유를 허용하면 위치를 확인할 수 있습니다.';

  @override
  String get all_friends_offline =>
      '모든 친구가 오프라인 상태입니다.\n친구가 온라인에 접속하면 위치를 확인할 수 있습니다.';

  @override
  String get all_friends_location_denied =>
      '모든 친구가 위치 공유를 허용하지 않습니다.\n친구가 위치 공유를 허용하면 위치를 확인할 수 있습니다.';

  @override
  String friends_location_display_success(int count) {
    return '친구 $count명의 위치를 지도에 표시했습니다.';
  }

  @override
  String friends_location_display_error(String error) {
    return '친구 위치를 표시할 수 없습니다: $error';
  }

  @override
  String offline_friends_dialog_subtitle(int count) {
    return '현재 접속하지 않은 친구 $count명';
  }

  @override
  String get friend_location_display_error => '친구 위치를 표시할 수 없습니다.';

  @override
  String get friend_location_remove_error => '위치를 제거할 수 없습니다.';

  @override
  String get phone_app_error => '전화앱을 열 수 없습니다.';

  @override
  String get add_friend_error => '친구 추가 중 오류가 발생했습니다';

  @override
  String get user_not_found => '존재하지 않는 사용자입니다';

  @override
  String get already_friend => '이미 친구인 사용자입니다';

  @override
  String get already_requested => '이미 친구 요청을 보낸 사용자입니다';

  @override
  String get cannot_add_self => '자기 자신을 친구로 추가할 수 없습니다';

  @override
  String get invalid_user_id => '잘못된 사용자 ID입니다';

  @override
  String get server_error_retry => '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요';

  @override
  String get cancel_request_description => '보낸 친구 요청을 취소합니다';

  @override
  String get enter_id_prompt => '아이디를 입력하세요';

  @override
  String get friend_request_sent_success => '친구 요청이 성공적으로 전송되었습니다';

  @override
  String get already_adding_friend => '이미 친구 추가 중입니다. 중복 제출 방지';

  @override
  String friends_location_displayed(int count) {
    return '친구 $count명의 위치를 표시했습니다.';
  }

  @override
  String get offline_friends_dialog_title => '오프라인 친구';

  @override
  String friendRequestCancelled(String name) {
    return '$name님에게 보낸 친구 요청을 취소했습니다.';
  }

  @override
  String get friendRequestCancelError => '친구 요청 취소 중 오류가 발생했습니다.';

  @override
  String friendRequestAccepted(String name) {
    return '$name님의 친구 요청을 수락했습니다.';
  }

  @override
  String get friendRequestAcceptError => '친구 요청 수락 중 오류가 발생했습니다.';

  @override
  String friendRequestRejected(String name) {
    return '$name님의 친구 요청을 거절했습니다.';
  }

  @override
  String get friendRequestRejectError => '친구 요청 거절 중 오류가 발생했습니다.';

  @override
  String get friendLocationRemovedFromMap => '친구 위치를 지도에서 제거했습니다.';

  @override
  String get info => '알림';

  @override
  String get room_info_processing_error => '방 정보 처리 중 오류가 발생했습니다';

  @override
  String get selection_error => '선택 중 오류가 발생했습니다. 다시 시도해주세요';

  @override
  String get building_selection_error => '건물 선택 중 오류가 발생했습니다. 다시 시도해주세요';

  @override
  String get navigation_start_error => '네비게이션을 시작할 수 없습니다. 경로를 다시 확인해주세요';

  @override
  String get item_selection_error => '항목 선택 중 오류가 발생했습니다';

  @override
  String get dialog_display_error => '다이얼로그 표시 중 오류가 발생했습니다';

  @override
  String get enter_start_location => '출발지를 입력하세요';

  @override
  String get room_set_as_start => '호가 출발지로 설정되었습니다';

  @override
  String get room_set_as_end => '호가 도착지로 설정되었습니다';

  @override
  String get building_set_as_start => '이 출발지로 설정되었습니다';

  @override
  String get building_set_as_end => '이 도착지로 설정되었습니다';
}
