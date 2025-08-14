// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '跟随乌松';

  @override
  String get subtitle => '智能校园指南';

  @override
  String get woosong => '乌松';

  @override
  String get start => '开始';

  @override
  String get login => '登录';

  @override
  String get logout => '登出';

  @override
  String get guest => '访客';

  @override
  String get student_professor => '学生/教授';

  @override
  String get admin => '管理员';

  @override
  String get student => '学生';

  @override
  String get professor => '教授';

  @override
  String get external_user => '外部用户';

  @override
  String get username => '用户名';

  @override
  String get password => '密码';

  @override
  String get confirm_password => '确认密码';

  @override
  String get remember_me => '记住登录信息';

  @override
  String get remember_me_description => '下次自动登录';

  @override
  String get login_as_guest => '以访客身份浏览';

  @override
  String get login_failed => '登录失败';

  @override
  String get login_success => '登录成功';

  @override
  String get logout_success => '已成功登出';

  @override
  String get enter_username => '请输入用户名';

  @override
  String get enter_password => '请输入密码';

  @override
  String get password_hint => '请输入至少6个字符';

  @override
  String get confirm_password_hint => '请再次输入密码';

  @override
  String get username_password_required => '请输入用户名和密码';

  @override
  String get login_error => '登录失败';

  @override
  String get find_password => '找回密码';

  @override
  String get find_username => '找回用户名';

  @override
  String get back => '返回';

  @override
  String get confirm => '确认';

  @override
  String get cancel => '取消';

  @override
  String get coming_soon => '即将推出';

  @override
  String feature_coming_soon(String feature) {
    return '$feature功能即将推出。\n很快会添加。';
  }

  @override
  String get departurePoint => '出发点';

  @override
  String get arrivalPoint => '目的地';

  @override
  String get all => '全部';

  @override
  String get tutorial => '教程';

  @override
  String get tutorialTitleIntro => 'TaraWoosong 使用方法';

  @override
  String get tutorialDescIntro => '使用宇松大学校园导航器，让您的校园生活更加便利。';

  @override
  String get tutorialTitleSearch => '详细搜索功能';

  @override
  String get tutorialDescSearch => '在宇松大学，您不仅可以搜索建筑物，还可以搜索教室！\n详细了解教室的位置及设施 😊';

  @override
  String get tutorialTitleSchedule => '课表同步';

  @override
  String get tutorialDescSchedule => '将课程时间表同步到应用程序，自动为您规划到下一节课的最佳路线。';

  @override
  String get tutorialTitleDirections => '路线指引';

  @override
  String get tutorialDescDirections => '校园内精准的路线指导，让您轻松快速抵达目的地。';

  @override
  String get tutorialTitleIndoorMap => '楼宇内部地图';

  @override
  String get tutorialDescIndoorMap => '通过详细的楼宇内部地图，轻松查找教室和便利设施。';

  @override
  String get dontShowAgain => '不再显示';

  @override
  String get goBack => '返回';

  @override
  String get lectureRoom => '教室';

  @override
  String get lectureRoomInfo => '教室信息';

  @override
  String get floor => '楼层';

  @override
  String get personInCharge => '负责人';

  @override
  String get viewLectureRoom => '查看教室';

  @override
  String get viewBuilding => '查看建筑物';

  @override
  String get walk => '步行';

  @override
  String get minute => '分';

  @override
  String get hour => '小时';

  @override
  String get less_than_one_minute => '1分钟以内';

  @override
  String get zero_minutes => '0分钟';

  @override
  String get calculation_failed => '计算失败';

  @override
  String get professor_name => '教授';

  @override
  String get building_name => '建筑名称';

  @override
  String floor_number(Object floor) {
    return '楼层';
  }

  @override
  String get room_name => '房间';

  @override
  String get day_of_week => '星期';

  @override
  String get time => '时间';

  @override
  String get memo => '备注';

  @override
  String get recommend_route => '推荐路线';

  @override
  String get view_location => '查看位置';

  @override
  String get edit => '编辑';

  @override
  String get close => '关闭';

  @override
  String get help => '帮助';

  @override
  String get help_intro_title => '使用TarauSong';

  @override
  String get help_intro_description => '使用吴松大学校园导航器，让您的校园生活更方便。';

  @override
  String get help_detailed_search_title => '详细搜索';

  @override
  String get help_detailed_search_description => '包括建筑名称、教室号码和设施，快速准确地查找所需位置。';

  @override
  String get help_timetable_title => '时间表集成';

  @override
  String get help_timetable_description => '同步您的课程表，并获得直到下一节课的最佳路线指南。';

  @override
  String get help_directions_title => '路线导航';

  @override
  String get help_directions_description => '在校园内准确导航，轻松快速到达目的地。';

  @override
  String get help_building_map_title => '建筑楼层地图';

  @override
  String get help_building_map_description => '使用详细的楼层地图轻松找到教室和设施。';

  @override
  String get previous => '上一页';

  @override
  String get next => '下一页';

  @override
  String get done => '完成';

  @override
  String get image_load_error => '无法加载图片';

  @override
  String get start_campus_exploration => '开始探索校园';

  @override
  String get woosong_university => '乌松大学';

  @override
  String get excel_upload_title => '上传课程表Excel文件';

  @override
  String get excel_upload_description => '请选择乌松大学课程表Excel文件(.xlsx)';

  @override
  String get excel_file_select => '选择Excel文件';

  @override
  String get excel_upload_uploading => '正在上传Excel文件...';

  @override
  String get language_selection => '语言选择';

  @override
  String get language_selection_description => '请选择您偏好的语言';

  @override
  String get departure => '出发';

  @override
  String get destination => '目的地';

  @override
  String get my_location => '我的位置';

  @override
  String get current_location => '当前位置';

  @override
  String get welcome_subtitle_1 => '手中的跟随乌松，';

  @override
  String get welcome_subtitle_2 => '建筑信息都在这里！';

  @override
  String get select_language => '选择语言';

  @override
  String get auth_selection_title => '认证方式选择';

  @override
  String get auth_selection_subtitle => '请选择您偏好的登录方式';

  @override
  String get select_auth_method => '选择认证方式';

  @override
  String total_floors(Object count) {
    return '共 $count 层';
  }

  @override
  String get floor_info => '楼层信息';

  @override
  String floor_with_category(Object category) {
    return '有 $category 的楼层';
  }

  @override
  String get floor_label => '层';

  @override
  String get category => '类别';

  @override
  String get excel_upload_success => '上传完成！';

  @override
  String get guest_timetable_disabled => '访客用户无法使用课程表功能。';

  @override
  String get guest_timetable_add_disabled => '访客用户无法添加课程表。';

  @override
  String get guest_timetable_edit_disabled => '访客用户无法编辑课程表。';

  @override
  String get guest_timetable_delete_disabled => '访客用户无法删除课程表。';

  @override
  String get timetable_load_failed => '无法加载课程表。';

  @override
  String get timetable_add_success => '课程表添加成功。';

  @override
  String timetable_add_failed(Object error) {
    return '添加时间表失败';
  }

  @override
  String get timetable_overlap => '同一时间已有注册的课程。';

  @override
  String get required_fields_missing => '请填写所有必填字段。';

  @override
  String get no_search_results => '无搜索结果';

  @override
  String get excel_upload_refreshing => '正在刷新课程表...';

  @override
  String get logout_processing => '正在登出...';

  @override
  String get logout_error_message => '登出过程中发生错误，但正在移动到初始屏幕。';

  @override
  String get data_to_be_deleted => '将被删除的数据';

  @override
  String get deleting_account => '正在删除账户...';

  @override
  String get excel_tutorial_title => '如何下载Excel文件';

  @override
  String get edit_profile_section => '编辑个人资料';

  @override
  String get delete_account_section => '删除账户';

  @override
  String get logout_section => '登出';

  @override
  String get location_share_title => '位置共享';

  @override
  String get location_share_enabled => '位置共享已启用';

  @override
  String get location_share_disabled => '位置共享已禁用';

  @override
  String get excel_tutorial_previous => '上一个';

  @override
  String get room_route_error => '计算房间路径时出错。请按建筑物搜索。';

  @override
  String get location_check_error => '无法检查当前位置。请重试。';

  @override
  String get server_connection_error => '服务器连接有问题。请稍后重试。';

  @override
  String get route_calculation_error => '计算路径时出错。请重试。';

  @override
  String get try_again => '重试';

  @override
  String get current_location_departure => '从当前位置出发';

  @override
  String get current_location_departure_default => '从默认位置出发';

  @override
  String get current_location_navigation_start => '从当前位置开始导航';

  @override
  String get excel_tutorial_next => '下一个';

  @override
  String get profile_edit_title => '编辑个人资料';

  @override
  String get profile_edit_subtitle => '您可以修改您的个人信息';

  @override
  String get account_delete_title => '删除账户';

  @override
  String get account_delete_subtitle => '永久删除您的账户';

  @override
  String get logout_title => '登出';

  @override
  String get logout_subtitle => '从当前账户登出';

  @override
  String get location_share_enabled_success => '位置共享已启用';

  @override
  String get location_share_disabled_success => '位置共享已禁用';

  @override
  String get profile_edit_error => '编辑个人资料时发生错误';

  @override
  String get inquiry_load_failed => '加载查询列表失败';

  @override
  String get pull_to_refresh => '下拉刷新';

  @override
  String get app_version_number => 'v1.0.0';

  @override
  String get developer_email_address => 'wsumap41@gmail.com';

  @override
  String get developer_github_url => 'https://github.com/WSU-YJB/WSUMAP';

  @override
  String get friend_management => '朋友管理';

  @override
  String get excel_tutorial_file_select => '选择文件';

  @override
  String get excel_tutorial_help => '查看说明';

  @override
  String get excel_upload_file_cancelled => '文件选择已取消。';

  @override
  String get excel_upload_success_message => '课程表已更新！';

  @override
  String excel_upload_refresh_failed(String error) {
    return '刷新失败：$error';
  }

  @override
  String excel_upload_failed(String error) {
    return '上传失败：$error';
  }

  @override
  String get excel_tutorial_step_1 => '1. 登录乌松大学信息系统';

  @override
  String get excel_tutorial_url => 'https://wsinfo.wsu.ac.kr';

  @override
  String get excel_tutorial_image_load_error => '无法加载图片';

  @override
  String get excel_tutorial_unknown_page => '未知页面';

  @override
  String get campus_navigator => '校园导航器';

  @override
  String get user_info_not_found => '登录响应中未找到用户信息';

  @override
  String get unexpected_login_error => '登录过程中发生意外错误';

  @override
  String get login_required => '需要登录';

  @override
  String get register => '注册';

  @override
  String get register_success => '注册完成';

  @override
  String get register_success_message => '注册完成！\n正在跳转到登录界面。';

  @override
  String get register_error => '注册过程中发生意外错误';

  @override
  String get update_user_info => '更新用户信息';

  @override
  String get update_success => '用户信息已更新';

  @override
  String get update_error => '更新用户信息时发生意外错误';

  @override
  String get delete_account => '删除账户';

  @override
  String get delete_success => '账户删除完成';

  @override
  String get delete_error => '删除账户时发生意外错误';

  @override
  String get name => '姓名';

  @override
  String get phone => '电话';

  @override
  String get email => '电子邮件';

  @override
  String get student_number => '学号';

  @override
  String get user_type => '用户类型';

  @override
  String get optional => '可选';

  @override
  String get required_fields_empty => '请填写所有必填项';

  @override
  String get password_mismatch => '密码不匹配';

  @override
  String get password_too_short => '密码至少需要6个字符';

  @override
  String get invalid_phone_format => '请输入正确的电话号码格式（例如：010-1234-5678）';

  @override
  String get invalid_email_format => '请输入正确的邮箱格式';

  @override
  String get required_fields_notice => '*标记的字段为必填项';

  @override
  String get welcome_to_campus_navigator => '欢迎使用乌松校园导航器';

  @override
  String get enter_real_name => '请输入真实姓名';

  @override
  String get phone_format_hint => '010-1234-5678';

  @override
  String get enter_student_number => '请输入学号或教工号';

  @override
  String get email_hint => 'example@woosong.org';

  @override
  String get create_account => '创建账户';

  @override
  String get loading => '加载中...';

  @override
  String get error => '错误';

  @override
  String get success => '成功';

  @override
  String get validation_error => '请检查您的输入';

  @override
  String get network_error => '发生网络错误';

  @override
  String get server_error => '发生服务器错误';

  @override
  String get unknown_error => '发生未知错误';

  @override
  String get woosong_campus_guide_service => '乌松大学校园指南服务';

  @override
  String get register_description => '创建新账户以使用所有功能';

  @override
  String get login_description => '使用现有账户登录以使用服务';

  @override
  String get browse_as_guest => '以访客身份浏览';

  @override
  String get processing => '处理中...';

  @override
  String get campus_navigator_version => '校园导航器 v1.0';

  @override
  String get guest_mode => '访客模式';

  @override
  String get guest_mode_confirm => '您要进入访客模式吗？\n\n在访客模式下，您无法使用好友功能和位置共享。';

  @override
  String get app_name => '达拉乌松';

  @override
  String get welcome_to_ttarausong => '欢迎来到达拉乌松';

  @override
  String get guest_mode_description => '在访客模式下，您只能查看基本的校园信息。\n要使用所有功能，请注册并登录。';

  @override
  String get continue_as_guest => '以访客身份继续';

  @override
  String get moved_to_my_location => '已自动移动到我的位置';

  @override
  String get friends_screen_bottom_sheet => '好友界面以底部表单显示';

  @override
  String get finding_current_location => '正在查找当前位置...';

  @override
  String get home => '首页';

  @override
  String get timetable => '课程表';

  @override
  String get friends => '好友';

  @override
  String get finish => '完成';

  @override
  String get profile => '个人资料';

  @override
  String get inquiry => '咨询';

  @override
  String get my_inquiry => '我的咨询';

  @override
  String get inquiry_type => '咨询类型';

  @override
  String get inquiry_type_required => '请选择咨询类型';

  @override
  String get inquiry_type_select_hint => '选择咨询类型';

  @override
  String get inquiry_title => '咨询标题';

  @override
  String get inquiry_content => '咨询内容';

  @override
  String get inquiry_content_hint => '请输入咨询内容';

  @override
  String get inquiry_submit => '提交咨询';

  @override
  String get inquiry_submit_success => '咨询提交成功';

  @override
  String get inquiry_submit_failed => '咨询提交失败';

  @override
  String get no_inquiry_history => '无咨询历史';

  @override
  String get no_inquiry_history_hint => '暂无咨询记录';

  @override
  String get inquiry_delete => '删除咨询';

  @override
  String get inquiry_delete_confirm => '您要删除此咨询吗？';

  @override
  String get inquiry_delete_success => '咨询已删除';

  @override
  String get inquiry_delete_failed => '删除咨询失败';

  @override
  String get inquiry_detail => '咨询详情';

  @override
  String get inquiry_category => '咨询类别';

  @override
  String get inquiry_status => '咨询状态';

  @override
  String get inquiry_created_at => '咨询时间';

  @override
  String get inquiry_title_label => '咨询标题';

  @override
  String get inquiry_type_bug => '错误报告';

  @override
  String get inquiry_type_feature => '功能请求';

  @override
  String get inquiry_type_improvement => '改进建议';

  @override
  String get inquiry_type_other => '其他';

  @override
  String get inquiry_status_pending => '等待回复';

  @override
  String get inquiry_status_in_progress => '处理中';

  @override
  String get inquiry_status_answered => '已回答';

  @override
  String get phone_required => '电话号码为必填项';

  @override
  String get building_info => '建筑信息';

  @override
  String get directions => '路线';

  @override
  String get floor_detail_view => '楼层详情视图';

  @override
  String get no_floor_info => '无楼层信息';

  @override
  String get floor_detail_info => '楼层详情信息';

  @override
  String get search_start_location => '搜索起点';

  @override
  String get search_end_location => '搜索终点';

  @override
  String get unified_navigation_in_progress => '统一导航进行中';

  @override
  String get unified_navigation => '统一导航';

  @override
  String get recent_searches => '最近搜索';

  @override
  String get clear_all => '全部清除';

  @override
  String get searching => '搜索中...';

  @override
  String get try_different_keyword => '尝试其他关键词';

  @override
  String get enter_end_location => '输入目的地';

  @override
  String get route_preview => '路线预览';

  @override
  String get calculating_optimal_route => '计算最佳路线...';

  @override
  String get set_departure_and_destination => '设置起点和终点';

  @override
  String get start_unified_navigation => '开始统一导航';

  @override
  String get departure_indoor => '起点（室内）';

  @override
  String get to_building_exit => '到建筑出口';

  @override
  String get outdoor_movement => '室外移动';

  @override
  String get to_destination_building => '到目的地建筑';

  @override
  String get arrival_indoor => '终点（室内）';

  @override
  String get to_final_destination => '到最终目的地';

  @override
  String get total_distance => '总距离';

  @override
  String get route_type => '路线类型';

  @override
  String get building_to_building => '建筑间移动';

  @override
  String get room_to_building => '房间到建筑';

  @override
  String get building_to_room => '建筑到房间';

  @override
  String get room_to_room => '房间间移动';

  @override
  String get location_to_building => '当前位置到建筑';

  @override
  String get unified_route => '统一路线';

  @override
  String get status_offline => '离线';

  @override
  String get status_open => '开放';

  @override
  String get status_closed => '关闭';

  @override
  String get status_24hours => '24小时';

  @override
  String get status_temp_closed => '临时关闭';

  @override
  String get status_closed_permanently => '永久关闭';

  @override
  String get status_next_open => '上午9点开放';

  @override
  String get status_next_close => '下午6点关闭';

  @override
  String get status_next_open_tomorrow => '明天上午9点开放';

  @override
  String get set_start_point => '设置起点';

  @override
  String get set_end_point => '设置终点';

  @override
  String get scheduleDeleteTitle => '删除课程';

  @override
  String get scheduleDeleteSubtitle => '请谨慎决定';

  @override
  String get scheduleDeleteLabel => '要删除的课程';

  @override
  String scheduleDeleteDescription(Object title) {
    return '\"$title\"课程将从课程表中删除。\n删除的课程无法恢复。';
  }

  @override
  String get cancelButton => '取消';

  @override
  String get deleteButton => '删除';

  @override
  String get overlap_message => '此时间已有注册的课程';

  @override
  String friendDeleteSuccessMessage(Object userName) {
    return '$userName已从好友列表中移除';
  }

  @override
  String get enterFriendIdPrompt => '请输入您朋友的ID';

  @override
  String get friendId => '朋友ID';

  @override
  String get enterFriendId => '输入朋友ID';

  @override
  String get sendFriendRequest => '发送朋友请求';

  @override
  String get realTimeSyncActive => '实时同步激活';

  @override
  String get noSentRequests => '没有发送的请求';

  @override
  String newFriendRequests(int count) {
    return '$count个新的朋友请求';
  }

  @override
  String get noReceivedRequests => '没有收到的请求';

  @override
  String get id => 'ID';

  @override
  String requestDate(String date) {
    return '请求日期: $date';
  }

  @override
  String get newBadge => '新';

  @override
  String get online => '在线';

  @override
  String get offline => '离线';

  @override
  String get contact => '联系方式';

  @override
  String get noContactInfo => '无联系信息';

  @override
  String get friendOfflineError => '无法查看离线朋友的位置';

  @override
  String get removeLocation => '移除位置';

  @override
  String get showLocation => '显示位置';

  @override
  String friendLocationRemoved(String userName) {
    return '$userName的位置已移除';
  }

  @override
  String friendLocationShown(String userName) {
    return '$userName的位置已显示';
  }

  @override
  String get errorCannotRemoveLocation => '无法移除位置';

  @override
  String get my_page => '我的页面';

  @override
  String get calculating_route => '计算路线中...';

  @override
  String get finding_optimal_route => '服务器正在寻找最佳路线';

  @override
  String get clear_route => '清除路线';

  @override
  String get location_permission_denied => '位置权限被拒绝。\n请在设置中允许位置权限。';

  @override
  String get estimated_time => '预计时间';

  @override
  String get location_share_update_failed => '位置共享设置更新失败';

  @override
  String get guest_location_share_success => '访客模式下仅在本地设置位置共享';

  @override
  String get no_changes => '无更改';

  @override
  String get password_confirm_title => '密码确认';

  @override
  String get password_confirm_subtitle => '请输入密码以修改账户信息';

  @override
  String get password_confirm_button => '确认';

  @override
  String get password_required => '请输入密码';

  @override
  String get password_mismatch_confirm => '密码不匹配';

  @override
  String get profile_updated => '个人资料已更新';

  @override
  String get my_page_subtitle => '我的信息';

  @override
  String get excel_file => 'Excel文件';

  @override
  String get excel_file_tutorial => 'Excel文件教程';

  @override
  String get image_attachment => 'Image Attachment';

  @override
  String get max_one_image => '最多1张';

  @override
  String get photo_attachment => '照片附件';

  @override
  String get photo_attachment_complete => '照片附件完成';

  @override
  String get image_selection => '图片选择';

  @override
  String get select_image_method => '请选择选择图片的方法';

  @override
  String get select_from_gallery => '从相册选择';

  @override
  String get select_from_gallery_desc => '从相册选择图片';

  @override
  String get select_from_file => '从文件选择';

  @override
  String get select_from_file_desc => '从文件选择图片';

  @override
  String get max_one_image_error => '一次只能附加一张图片';

  @override
  String get image_selection_error => '选择图片时发生错误';

  @override
  String get inquiry_error_occurred => '处理您的咨询时发生错误';

  @override
  String get inquiry_category_bug => '错误报告';

  @override
  String get inquiry_category_feature => '功能请求';

  @override
  String get inquiry_category_other => '其他';

  @override
  String get inquiry_category_route_error => '路线指导错误';

  @override
  String get inquiry_category_place_error => '地点/信息错误';

  @override
  String get schedule => '课程表';

  @override
  String get winter_semester => '冬季学期';

  @override
  String get spring_semester => '春季学期';

  @override
  String get summer_semester => '夏季学期';

  @override
  String get fall_semester => '秋季学期';

  @override
  String get monday => '周一';

  @override
  String get tuesday => '周二';

  @override
  String get wednesday => '周三';

  @override
  String get thursday => '周四';

  @override
  String get friday => '周五';

  @override
  String get add_class => '添加课程';

  @override
  String get edit_class => '编辑课程';

  @override
  String get delete_class => '删除课程';

  @override
  String get class_name => '课程名称';

  @override
  String get classroom => '教室';

  @override
  String get start_time => '开始时间';

  @override
  String get end_time => '结束时间';

  @override
  String get color_selection => '选择颜色';

  @override
  String get monday_full => '星期一';

  @override
  String get tuesday_full => '星期二';

  @override
  String get wednesday_full => '星期三';

  @override
  String get thursday_full => '星期四';

  @override
  String get friday_full => '星期五';

  @override
  String get class_added => '课程已添加';

  @override
  String get class_updated => '课程已更新';

  @override
  String get class_deleted => '课程已删除';

  @override
  String delete_class_confirm(String className) {
    return '您要删除$className课程吗？';
  }

  @override
  String get view_on_map => '在地图上查看';

  @override
  String get location => '位置';

  @override
  String get schedule_time => '时间';

  @override
  String get schedule_day => '星期';

  @override
  String get map_feature_coming_soon => '地图功能将在稍后添加';

  @override
  String current_year(int year) {
    return '$year';
  }

  @override
  String get my_friends => '我的好友';

  @override
  String online_friends(int total, int online) {
    return '总计 $total • 在线 $online';
  }

  @override
  String get add_friend => '添加好友';

  @override
  String get friend_name_or_id => '输入好友姓名或学号';

  @override
  String get friend_request_sent => '好友请求已发送';

  @override
  String get in_class => '上课中';

  @override
  String last_location(String location) {
    return '最后位置: $location';
  }

  @override
  String get central_library => '中央图书馆';

  @override
  String get engineering_building => '工程楼201';

  @override
  String get student_center => '学生中心';

  @override
  String get cafeteria => '学生食堂';

  @override
  String get message => '消息';

  @override
  String get call => '通话';

  @override
  String start_chat_with(String name) {
    return '开始与$name聊天';
  }

  @override
  String view_location_on_map(String name) {
    return '在地图上查看$name的位置';
  }

  @override
  String calling(String name) {
    return '正在呼叫$name';
  }

  @override
  String get delete => '删除';

  @override
  String get search => '搜索';

  @override
  String get searchBuildings => '搜索建筑...';

  @override
  String get myLocation => '我的位置';

  @override
  String get navigation => '导航';

  @override
  String get route => '路线';

  @override
  String get distance => '距离';

  @override
  String get minutes => '分钟';

  @override
  String get hours => '小时';

  @override
  String get within_minute => '1分钟内';

  @override
  String minutes_only(Object minutes) {
    return '$minutes分钟';
  }

  @override
  String hours_only(Object hours) {
    return '$hours小时';
  }

  @override
  String hours_and_minutes(Object hours, Object minutes) {
    return '$hours小时$minutes分钟';
  }

  @override
  String get available => '可用';

  @override
  String get start_navigation_from_current_location => '从当前位置开始导航';

  @override
  String get my_location_set_as_start => '我的位置已设为起点';

  @override
  String get default_location_set_as_start => '默认位置已设为起点';

  @override
  String get start_navigation => '开始导航';

  @override
  String get navigation_ended => '导航已结束';

  @override
  String get arrival => '到达';

  @override
  String get outdoor_movement_distance => '室外移动距离';

  @override
  String get indoor_arrival => '室内到达';

  @override
  String get indoor_departure => '室内出发';

  @override
  String get complete => '完成';

  @override
  String get findRoute => '查找路线';

  @override
  String get clearRoute => '清除路线';

  @override
  String get setAsStart => '设为起点';

  @override
  String get setAsDestination => '设为目的地的';

  @override
  String get navigateFromHere => '从这里导航';

  @override
  String get buildingInfo => '建筑信息';

  @override
  String get locationPermissionRequired => '需要位置权限';

  @override
  String get enableLocationServices => '请启用位置服务';

  @override
  String get noResults => '未找到结果';

  @override
  String get settings => '设置';

  @override
  String get language => '语言';

  @override
  String get about => '关于';

  @override
  String friends_count_status(int total, int online) {
    return '总计 $total • 在线 $online';
  }

  @override
  String get enter_friend_info => '输入好友姓名或学号';

  @override
  String show_location_on_map(String name) {
    return '在地图上显示$name的位置';
  }

  @override
  String get location_error => '无法找到您的位置';

  @override
  String get view_floor_plan => '查看楼层平面图';

  @override
  String floor_plan_title(String buildingName) {
    return '$buildingName楼层平面图';
  }

  @override
  String get floor_plan_not_available => '无法加载楼层平面图';

  @override
  String get floor_plan_default_text => '楼层平面图';

  @override
  String get delete_account_success => '您的账户已被删除';

  @override
  String get convenience_store => '便利店';

  @override
  String get vending_machine => '自动售货机';

  @override
  String get printer => '打印机';

  @override
  String get copier => '复印机';

  @override
  String get atm => 'ATM';

  @override
  String get bank_atm => '银行(ATM)';

  @override
  String get medical => '医疗';

  @override
  String get health_center => '保健中心';

  @override
  String get gym => '体育馆';

  @override
  String get fitness_center => '健身中心';

  @override
  String get lounge => '休息室';

  @override
  String get extinguisher => '灭火器';

  @override
  String get water_purifier => '净水器';

  @override
  String get bookstore => '书店';

  @override
  String get post_office => '邮局';

  @override
  String instructionMoveToDestination(String place) {
    return '移动到$place';
  }

  @override
  String get markerDeparture => '出发地';

  @override
  String get markerArrival => '到达地';

  @override
  String get errorCannotOpenPhoneApp => '无法打开电话应用程序。';

  @override
  String get emailCopied => '电子邮件已复制到剪贴板。';

  @override
  String get description => '描述';

  @override
  String get noDetailedInfoRegistered => '未注册详细信息。';

  @override
  String get setDeparture => '设置为出发地';

  @override
  String get setArrival => '设置为目的地';

  @override
  String errorOccurred(Object error) {
    return '发生错误：$error';
  }

  @override
  String get instructionExitToOutdoor => '移动到建筑出口';

  @override
  String instructionMoveToDestinationBuilding(String building) {
    return '移动到$building建筑';
  }

  @override
  String get instructionMoveToRoom => '移动到目的地房间';

  @override
  String get instructionArrived => '您已到达目的地！';

  @override
  String get no => '否';

  @override
  String get woosong_library_w1 => '乌松图书馆 (W1)';

  @override
  String get woosong_library_info =>
      'B2F\t停车场\nB1F\t小礼堂、设备室、电气室、停车场\n1F\t就业支持中心 (630-9976)、借阅台、信息休息室\n2F\t普通阅览室、团体学习室\n3F\t普通阅览室\n4F\t文学图书/西方图书';

  @override
  String get educational_facility => 'Educational Facility';

  @override
  String get operating => 'Operating';

  @override
  String get woosong_library_desc => '乌松大学中央图书馆';

  @override
  String get sol_cafe => 'Sol Cafe';

  @override
  String get sol_cafe_info => '1F\tRestaurant\n2F\tCafe';

  @override
  String get cafe => 'Cafe';

  @override
  String get sol_cafe_desc => 'Campus cafe';

  @override
  String get cheongun_1_dormitory => 'Cheongun 1 Dormitory';

  @override
  String get cheongun_1_dormitory_info =>
      '1F\tPractice Room\n2F\tStudent Cafeteria\n2F\tCheongun 1 Dormitory (Female) (629-6542)\n2F\tLiving Hall\n3~5F\tLiving Hall';

  @override
  String get dormitory => 'Dormitory';

  @override
  String get cheongun_1_dormitory_desc => 'Female student dormitory';

  @override
  String get industry_cooperation_w2 => 'Industry Cooperation (W2)';

  @override
  String get industry_cooperation_info =>
      '1F\tIndustry Cooperation\n2F\tArchitectural Engineering (630-9720)\n3F\tWoosong University Convergence Technology Institute, Industry-University-Research Comprehensive Enterprise Support Center\n4F\tCorporate Research Institute, LG CNS Classroom, Railway Digital Academy Classroom';

  @override
  String get industry_cooperation_desc =>
      'Industry cooperation and research facilities';

  @override
  String get rotc_w2_1 => 'ROTC (W2-1)';

  @override
  String get rotc_info => '\tROTC (630-4601)';

  @override
  String get rotc_desc => 'ROTC facilities';

  @override
  String get military_facility => 'Military Facility';

  @override
  String get international_dormitory_w3 => 'International Dormitory (W3)';

  @override
  String get international_dormitory_info =>
      '1F\tInternational Student Support Team (629-6623)\n1F\tStudent Cafeteria\n2F\tInternational Dormitory (629-6655)\n2F\tHealth Center\n3~12F\tLiving Hall';

  @override
  String get international_dormitory_desc => 'International student dormitory';

  @override
  String get railway_logistics_w4 => 'Railway Logistics (W4)';

  @override
  String get railway_logistics_info =>
      'B1F\tPractice Room\n1F\tPractice Room\n2F\tRailway Construction System Department (629-6710)\n2F\tRailway Vehicle System Department (629-6780)\n3F\tClassroom/Practice Room\n4F\tRailway System Department (630-6730,9700)\n5F\tFire Prevention Department (629-6770)\n5F\tLogistics System Department (630-9330)';

  @override
  String get railway_logistics_desc =>
      'Railway and logistics related departments';

  @override
  String get health_medical_science_w5 => 'Health Medical Science (W5)';

  @override
  String get health_medical_science_info =>
      'B1F\tParking\n1F\tAudio-Visual Room/Parking\n2F\tClassroom\n2F\tExercise Health Rehabilitation Department (630-9840)\n3F\tEmergency Medical Department (630-9280)\n3F\tNursing Department (630-9290)\n4F\tOccupational Therapy Department (630-9820)\n4F\tSpeech Therapy Hearing Rehabilitation Department (630-9220)\n5F\tPhysical Therapy Department (630-4620)\n5F\tHealth Medical Management Department (630-4610)\n5F\tClassroom\n6F\tRailway Management Department (630-9770)';

  @override
  String get health_medical_science_desc =>
      'Health and medical related departments';

  @override
  String get liberal_arts_w6 => 'Liberal Arts Education (W6)';

  @override
  String get liberal_arts_info =>
      '2F\tClassroom\n3F\tClassroom\n4F\tClassroom\n5F\tClassroom';

  @override
  String get liberal_arts_desc => 'Liberal arts classroom';

  @override
  String get woosong_hall_w7 => 'Woosong Hall (W7)';

  @override
  String get woosong_hall_info =>
      '1F\tAdmissions Office (630-9627)\n1F\tAcademic Affairs Office (630-9622)\n1F\tFacilities Office (630-9970)\n1F\tManagement Team (629-6658)\n1F\tIndustry Cooperation (630-4653)\n1F\tExternal Cooperation Office (630-9636)\n2F\tStrategic Planning Office (630-9102)\n2F\tGeneral Affairs Office-General Affairs, Procurement (630-9653)\n2F\tPlanning Office (630-9661)\n3F\tPresident\'s Office (630-8501)\n3F\tInternational Exchange Office (630-9373)\n3F\tEarly Childhood Education Department (630-9360)\n3F\tBusiness Administration Major (629-6640)\n3F\tFinance/Real Estate Major (630-9350)\n4F\tLarge Conference Room\n5F\tConference Room';

  @override
  String get woosong_hall_desc => 'University headquarters building';

  @override
  String get woosong_kindergarten_w8 => 'Woosong Kindergarten (W8)';

  @override
  String get woosong_kindergarten_info =>
      '1F, 2F\tWoosong Kindergarten (629~6750~1)';

  @override
  String get woosong_kindergarten_desc => 'University affiliated kindergarten';

  @override
  String get kindergarten => 'Kindergarten';

  @override
  String get west_campus_culinary_w9 => 'West Campus Culinary Academy (W9)';

  @override
  String get west_campus_culinary_info =>
      'B1F\tPractice Room\n1F\tPractice Room\n2F\tPractice Room';

  @override
  String get west_campus_culinary_desc => 'Culinary practice facilities';

  @override
  String get social_welfare_w10 => 'Social Welfare Convergence (W10)';

  @override
  String get social_welfare_info =>
      '1F\tAudio-Visual Room/Practice Room\n2F\tClassroom/Practice Room\n3F\tSocial Welfare Department (630-9830)\n3F\tGlobal Child Education Department (630-9260)\n4F\tClassroom/Practice Room\n5F\tClassroom/Practice Room';

  @override
  String get social_welfare_desc => 'Social welfare related departments';

  @override
  String get gymnasium_w11 => 'Gymnasium (W11)';

  @override
  String get gymnasium_info => '1F\tPhysical Training Room\n2F~4F\tGymnasium';

  @override
  String get gymnasium_desc => 'Sports facilities';

  @override
  String get sports_facility => 'Sports Facility';

  @override
  String get sica_w12 => 'SICA (W12)';

  @override
  String get sica_info =>
      'B1F\tPractice Room\n1F\tStarrico Cafe\n2F~3F\tClassroom\n5F\tGlobal Culinary Department (629-6860)';

  @override
  String get sica_desc => 'International Culinary Academy';

  @override
  String get woosong_tower_w13 => 'Woosong Tower (W13)';

  @override
  String get woosong_tower_info =>
      'B1~1F\tParking\n2F\tParking, Solpine Bakery (629-6429)\n4F\tSeminar Room\n5F\tClassroom\n6F\tFood Service Culinary Nutrition Department (630-9380,9740)\n7F\tClassroom\n8F\tFood Service, Culinary Management Major (630-9250)\n9F\tClassroom/Practice Room\n10F\tFood Service Culinary Major (629-6821), Global Korean Cuisine Major (629-6560)\n11F, 12F\tPractice Room\n13F\tSolpine Restaurant (629-6610)';

  @override
  String get woosong_tower_desc => 'Comprehensive education facility';

  @override
  String get complex_facility => 'Complex Facility';

  @override
  String get culinary_center_w14 => 'Culinary Center (W14)';

  @override
  String get culinary_center_info =>
      '1F\tClassroom/Practice Room\n2F\tClassroom/Practice Room\n3F\tClassroom/Practice Room\n4F\tClassroom/Practice Room\n5F\tClassroom/Practice Room';

  @override
  String get culinary_center_desc => 'Culinary major education facility';

  @override
  String get food_architecture_w15 => 'Food Architecture (W15)';

  @override
  String get food_architecture_info =>
      'B1F\tPractice Room\n1F\tPractice Room\n2F\tClassroom\n3F\tClassroom\n4F\tClassroom\n5F\tClassroom';

  @override
  String get food_architecture_desc =>
      'Food and architecture related departments';

  @override
  String get student_hall_w16 => 'Student Hall (W16)';

  @override
  String get student_hall_info =>
      '1F\tStudent Cafeteria, Campus Bookstore (629-6127)\n2F\tFaculty Cafeteria\n3F\tClub Room\n3F\tStudent Welfare Office-Student Team (630-9641), Scholarship Team (630-9876)\n3F\tDisabled Student Support Center (630-9903)\n3F\tSocial Service Corps (630-9904)\n3F\tStudent Counseling Center (630-9645)\n4F\tReturn to School Support Center (630-9139)\n4F\tTeaching and Learning Development Center (630-9285)';

  @override
  String get student_hall_desc => 'Student welfare facility';

  @override
  String get media_convergence_w17 => 'Media Convergence (W17)';

  @override
  String get media_convergence_info =>
      'B1F\tClassroom/Practice Room\n1F\tMedia Design/Video Major (630-9750)\n2F\tClassroom/Practice Room\n3F\tGame Multimedia Major (630-9270)\n5F\tClassroom/Practice Room';

  @override
  String get media_convergence_desc => 'Media related departments';

  @override
  String get woosong_arts_center_w18 => 'Woosong Arts Center (W18)';

  @override
  String get woosong_arts_center_info =>
      'B1F\tPerformance Preparation Room\n1F\tWoosong Arts Center (629-6363)\n2F\tPractice Room\n3F\tPractice Room\n4F\tPractice Room\n5F\tPractice Room';

  @override
  String get woosong_arts_center_desc => 'Arts performance facility';

  @override
  String get west_campus_andycut_w19 => 'West Campus AndyCut Building (W19)';

  @override
  String get west_campus_andycut_info =>
      '2F\tGlobal Convergence Business Department (630-9249)\n2F\tLiberal Studies Department (630-9390)\n2F\tAI/Big Data Department (630-9807)\n2F\tGlobal Hotel Management Department (630-9249)\n2F\tGlobal Media Video Department (630-9346)\n2F\tGlobal Medical Service Management Department (630-9283)\n2F\tGlobal Railway/Transportation Logistics Department (630-9347)\n2F\tGlobal Food Service Entrepreneurship Department (629-6860)';

  @override
  String get west_campus_andycut_desc => 'Global department building';

  @override
  String get search_campus_buildings => 'Search campus buildings';

  @override
  String get building_details => 'Details';

  @override
  String get parking => 'Parking';

  @override
  String get accessibility => 'Accessibility';

  @override
  String get facilities => 'Facilities';

  @override
  String get elevator => 'Elevator';

  @override
  String get restroom => 'Restroom';

  @override
  String get navigate_from_current_location => 'Navigate from current location';

  @override
  String get edit_profile => 'Edit Profile';

  @override
  String get nameRequired => 'Please enter name';

  @override
  String get emailRequired => 'Please enter email';

  @override
  String get save => 'Save';

  @override
  String get saveSuccess => 'Profile updated';

  @override
  String get app_info => 'App Info';

  @override
  String get app_version => 'App Version';

  @override
  String get developer => 'Developer';

  @override
  String get developer_name => 'Name: Hong Gil-dong';

  @override
  String get developer_email => 'Email: wsumap41@gmail.com';

  @override
  String get developer_github => 'GitHub: github.com/WSU-YJB/WSUMAP';

  @override
  String get no_help_images => 'No help images';

  @override
  String get description_hint => 'Enter description';

  @override
  String get my_info => 'My Info';

  @override
  String get guest_user => 'Guest User';

  @override
  String get guest_role => 'Guest Role';

  @override
  String get user => 'User';

  @override
  String get edit_profile_subtitle =>
      'You can modify your personal information';

  @override
  String get help_subtitle => 'Check app usage';

  @override
  String get app_info_subtitle =>
      'Version information and developer information';

  @override
  String get delete_account_subtitle => 'Permanently delete your account';

  @override
  String get login_message => 'Login or register\nTo use all features';

  @override
  String get login_signup => 'Login / Register';

  @override
  String get delete_account_confirm => 'Delete Account';

  @override
  String get delete_account_message => 'Do you want to delete your account?';

  @override
  String get logout_confirm => 'Logout';

  @override
  String get logout_message => 'Do you want to logout?';

  @override
  String get yes => 'Yes';

  @override
  String get feature_in_progress => 'Feature in progress';

  @override
  String get delete_feature_in_progress =>
      'Account deletion feature is in progress';

  @override
  String get title => 'Edit Profile';

  @override
  String get email_required => 'Please enter email';

  @override
  String get name_required => 'Please enter name';

  @override
  String get cancelFriendRequest => 'Cancel Friend Request';

  @override
  String cancelFriendRequestConfirm(String name) {
    return 'Do you want to cancel the friend request sent to $name?';
  }

  @override
  String get attached_image => '附加图片';

  @override
  String get answer_section_title => '答复';

  @override
  String get inquiry_default_answer => '这是您查询的答复。如有其他问题，请随时联系我们。';

  @override
  String get answer_date_prefix => '答复日期：';

  @override
  String get waiting_answer_status => '等待答复';

  @override
  String get waiting_answer_message => '我们正在审核您的查询，将尽快回复。';

  @override
  String get status_pending => '等待中';

  @override
  String get status_answered => '已答复';

  @override
  String get cancelRequest => 'Cancel Request';

  @override
  String get friendDeleteTitle => 'Delete Friend';

  @override
  String get friendDeleteWarning => 'This action cannot be undone';

  @override
  String get friendDeleteHeader => 'Delete Friend';

  @override
  String get friendDeleteToConfirm =>
      'Please enter the name of the friend to delete';

  @override
  String get friendDeleteCancel => 'Cancel';

  @override
  String get friendDeleteButton => 'Delete';

  @override
  String get friendManagementAndRequests => 'Friend Management and Requests';

  @override
  String get realTimeSyncStatus => '实时同步状态';

  @override
  String get friendManagement => 'Friend Management';

  @override
  String get add => 'Add';

  @override
  String sentRequestsCount(int count) {
    return 'Sent ($count)';
  }

  @override
  String receivedRequestsCount(int count) {
    return 'Received ($count)';
  }

  @override
  String friendCount(int count) {
    return 'My Friends ($count)';
  }

  @override
  String get noFriends =>
      'You don\'t have any friends yet.\nTap the + button above to add friends!';

  @override
  String get open_settings => 'Open Settings';

  @override
  String get retry => 'Retry';

  @override
  String get basic_info => 'Basic Info';

  @override
  String get status => 'Status';

  @override
  String get floor_plan => 'Floor Plan';

  @override
  String get indoorMap => '室内地图';

  @override
  String get showBuildingMarker => '显示建筑标记';

  @override
  String get search_hint => 'Search campus buildings';

  @override
  String get searchHint => '按建筑物或房间搜索';

  @override
  String get searchInitialGuide => 'Search for a building or room';

  @override
  String get searchHintExample => '例如：W19、工程馆、401室';

  @override
  String get searchLoading => 'Searching...';

  @override
  String get searchNoResult => 'No results found';

  @override
  String get searchTryAgain => 'Try a different search term';

  @override
  String get required => 'Required';

  @override
  String get enter_title => 'Please enter a title';

  @override
  String get content => 'Content';

  @override
  String get enter_content => 'Please enter content';

  @override
  String get restaurant => 'Restaurant';

  @override
  String get privacy_policy => '隐私政策';

  @override
  String get fire_extinguisher => '灭火器';

  @override
  String get my_location_route_calculating => '正在计算从我的位置到建筑物的路线。请稍等片刻。';

  @override
  String get calculating => '计算中';

  @override
  String get set_both_locations => '请设置出发地和目的地';

  @override
  String get route_calculating => '正在计算路线...';

  @override
  String get search_error => '搜索错误';

  @override
  String get search_initial_guide => '搜索建筑物或房间';

  @override
  String get search_hint_example => '例如：W19、工程馆、401室';

  @override
  String get search_loading => '搜索中...';

  @override
  String get search_no_result => '未找到搜索结果';

  @override
  String get search_try_again => '尝试其他搜索词';

  @override
  String get library => 'Library';

  @override
  String get setting => '设置';

  @override
  String location_setting_confirm(String buildingName, String locationType) {
    return '将$buildingName设置为$locationType？';
  }

  @override
  String get set_room => '设置房间';

  @override
  String friend_location_permission_denied(String name) {
    return '$name不允许位置共享';
  }

  @override
  String get no_friends_message => '您没有朋友。\n请添加朋友后重试。';

  @override
  String offline_friends_not_displayed(int count) {
    return '\n$count个离线朋友未显示。';
  }

  @override
  String location_denied_friends_not_displayed(int count) {
    return '\n$count个拒绝位置共享的朋友未显示。';
  }

  @override
  String both_offline_and_location_denied(int offlineCount, int locationCount) {
    return '\n$offlineCount个离线朋友和$locationCount个拒绝位置共享的朋友未显示。';
  }

  @override
  String get all_friends_offline_or_location_denied =>
      '所有朋友都离线或拒绝位置共享。\n当朋友上线并允许位置共享时，您可以查看他们的位置。';

  @override
  String get all_friends_offline => '所有朋友都离线。\n当朋友上线时，您可以查看他们的位置。';

  @override
  String get all_friends_location_denied =>
      '所有朋友都拒绝位置共享。\n当朋友允许位置共享时，您可以查看他们的位置。';

  @override
  String friends_location_display_success(int count) {
    return '在地图上显示了$count位朋友的位置。';
  }

  @override
  String friends_location_display_error(String error) {
    return '无法显示朋友位置: $error';
  }

  @override
  String offline_friends_dialog_subtitle(int count) {
    return '当前离线的$count位朋友';
  }

  @override
  String get friend_location_display_error => '无法显示好友位置。';

  @override
  String get friend_location_remove_error => '无法移除位置。';

  @override
  String get phone_app_error => '无法打开电话应用。';

  @override
  String get add_friend_error => '添加好友时发生错误';

  @override
  String get user_not_found => '用户不存在';

  @override
  String get already_friend => '用户已经是好友';

  @override
  String get already_requested => '已向该用户发送好友请求';

  @override
  String get cannot_add_self => '无法将自己添加为好友';

  @override
  String get invalid_user_id => '无效的用户ID';

  @override
  String get server_error_retry => '服务器错误，请稍后重试';

  @override
  String get cancel_request_description => '取消已发送的好友请求';

  @override
  String get enter_id_prompt => '请输入ID';

  @override
  String get friend_request_sent_success => '好友请求发送成功';

  @override
  String get already_adding_friend => '正在添加好友，防止重复提交';

  @override
  String friends_location_displayed(int count) {
    return '显示了 $count 位好友的位置。';
  }

  @override
  String get offline_friends_dialog_title => '离线好友';

  @override
  String friendRequestCancelled(String name) {
    return '已取消发送给 $name 的好友请求。';
  }

  @override
  String get friendRequestCancelError => '取消好友请求时发生错误。';

  @override
  String friendRequestAccepted(String name) {
    return '已接受 $name 的好友请求。';
  }

  @override
  String get friendRequestAcceptError => '接受好友请求时发生错误。';

  @override
  String friendRequestRejected(String name) {
    return '已拒绝 $name 的好友请求。';
  }

  @override
  String get friendRequestRejectError => '拒绝好友请求时发生错误。';

  @override
  String get friendLocationRemovedFromMap => '已从地图中移除好友位置。';

  @override
  String get info => '信息';
}
