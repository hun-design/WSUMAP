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
  String get departurePoint => '出发';

  @override
  String get arrivalPoint => '到达';

  @override
  String get all => '全部';

  @override
  String get tutorial => '教程';

  @override
  String get tutorialTitleIntro => '跟随乌松使用方法';

  @override
  String get tutorialDescIntro => '使用吴松大学校园导航器，让您的校园生活更方便';

  @override
  String get tutorialTitleSearch => '详细搜索功能';

  @override
  String get tutorialDescSearch =>
      '在吴松大学，不仅可以搜索建筑物，还可以搜索教室！\n从教室位置到便利设施，详细搜索看看吧 😊';

  @override
  String get tutorialTitleSchedule => '时间表集成';

  @override
  String get tutorialDescSchedule => '同步您的课程表，并获得直到下一节课的最佳路线指南';

  @override
  String get tutorialTitleDirections => '路线导航';

  @override
  String get tutorialDescDirections => '校园内准确的路线导航，轻松快速到达目的地';

  @override
  String get tutorialTitleIndoorMap => '建筑内部平面图';

  @override
  String get tutorialDescIndoorMap => '使用建筑内部的详细平面图，轻松找到教室和便利设施';

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
  String get minute => '分钟';

  @override
  String get hour => '小时';

  @override
  String get less_than_one_minute => '不到1分钟';

  @override
  String get zero_minutes => '0分钟';

  @override
  String get calculation_failed => '计算失败';

  @override
  String get professor_name => '负责教授';

  @override
  String get building_name => '建筑';

  @override
  String floor_number(Object floor) {
    return '$floor层';
  }

  @override
  String get room_name => '教室';

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
  String get previous => '上一个';

  @override
  String get next => '下一个';

  @override
  String get done => '完成';

  @override
  String get image_load_error => '无法加载图像';

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
  String get departure => '出发地';

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
  String get auth_selection_title => '选择认证方法';

  @override
  String get auth_selection_subtitle => '请选择您想要的登录方法';

  @override
  String get select_auth_method => '选择认证方法';

  @override
  String total_floors(Object count) {
    return '共$count层';
  }

  @override
  String get floor_info => '楼层信息';

  @override
  String floor_with_category(Object category) {
    return '有$category的楼层';
  }

  @override
  String get floor_label => '层';

  @override
  String get category => '类别';

  @override
  String get excel_upload_success => '上传完成！';

  @override
  String get guest_timetable_disabled => '访客用户无法使用时间表功能。';

  @override
  String get guest_timetable_add_disabled => '访客用户无法添加时间表。';

  @override
  String get guest_timetable_edit_disabled => '访客用户无法编辑时间表。';

  @override
  String get guest_timetable_delete_disabled => '访客用户无法删除时间表。';

  @override
  String get timetable_load_failed => '无法加载时间表。';

  @override
  String get timetable_add_success => '时间表已成功添加。';

  @override
  String timetable_add_failed(Object error) {
    return '添加时间表失败：$error';
  }

  @override
  String get timetable_overlap => '同一时间已有注册的课程。';

  @override
  String get required_fields_missing => '请填写所有必填项目。';

  @override
  String get no_search_results => '没有搜索结果';

  @override
  String get excel_upload_refreshing => '正在刷新时间表...';

  @override
  String get logout_processing => '正在登出...';

  @override
  String get logout_error_message => '登出过程中发生错误，但正在跳转到初始界面。';

  @override
  String get data_to_be_deleted => '将被删除的数据';

  @override
  String get deleting_account => '正在删除账户...';

  @override
  String get excel_tutorial_title => 'Excel文件下载方法';

  @override
  String get edit_profile_section => '修改会员信息';

  @override
  String get delete_account_section => '退出会员';

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
  String get room_route_error => '房间路线计算过程中发生错误。请尝试按建筑单位搜索。';

  @override
  String get location_check_error => '无法确认当前位置。请重试。';

  @override
  String get server_connection_error => '服务器连接有问题。请稍后重试。';

  @override
  String get route_calculation_error => '路线计算过程中发生错误。请重试。';

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
  String get profile_edit_subtitle => '可以修改个人信息';

  @override
  String get account_delete_title => '删除账户';

  @override
  String get account_delete_subtitle => '永久删除账户';

  @override
  String get logout_title => '登出';

  @override
  String get logout_subtitle => '从当前账户登出';

  @override
  String get location_share_enabled_success => '位置共享已启用';

  @override
  String get location_share_disabled_success => '位置共享已禁用';

  @override
  String get profile_edit_error => '编辑个人资料过程中发生错误';

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
  String get friend_management => '朋友管理';

  @override
  String get excel_tutorial_file_select => '文件选择';

  @override
  String get excel_tutorial_help => '查看使用方法';

  @override
  String get excel_upload_file_cancelled => '文件选择已取消。';

  @override
  String get excel_upload_success_message => '时间表已更新！';

  @override
  String excel_upload_refresh_failed(String error) {
    return '刷新失败：$error';
  }

  @override
  String excel_upload_failed(String error) {
    return '上传失败：$error';
  }

  @override
  String get excel_tutorial_step_1 => '1. 登录乌松大学大学信息系统';

  @override
  String get excel_tutorial_url => 'https://wsinfo.wsu.ac.kr';

  @override
  String get excel_tutorial_image_load_error => '无法加载图像';

  @override
  String get excel_tutorial_unknown_page => '未知页面';

  @override
  String get campus_navigator => '校园导航器';

  @override
  String get user_info_not_found => '在登录响应中找不到用户信息';

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
  String get update_user_info => '修改会员信息';

  @override
  String get update_success => '会员信息已修改';

  @override
  String get update_error => '修改会员信息过程中发生意外错误';

  @override
  String get delete_account => '退出会员';

  @override
  String get delete_success => '退出会员完成';

  @override
  String get delete_error => '退出会员过程中发生意外错误';

  @override
  String get name => '姓名';

  @override
  String get phone => '电话号码';

  @override
  String get email => '电子邮件';

  @override
  String get student_number => '学号';

  @override
  String get user_type => '用户类型';

  @override
  String get optional => '选择事项';

  @override
  String get required_fields_empty => '请填写所有必填项目';

  @override
  String get password_mismatch => '密码不匹配';

  @override
  String get password_too_short => '密码必须至少6个字符';

  @override
  String get invalid_phone_format => '请输入正确的电话号码格式（例如：010-1234-5678）';

  @override
  String get invalid_email_format => '请输入正确的电子邮件格式';

  @override
  String get required_fields_notice => '* 标记的项目为必填项目';

  @override
  String get welcome_to_campus_navigator => '欢迎使用乌松大学校园导航器';

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
  String get validation_error => '请检查输入值';

  @override
  String get network_error => '发生网络错误';

  @override
  String get server_error => '发生服务器错误';

  @override
  String get unknown_error => '发生未知错误';

  @override
  String get woosong_campus_guide_service => '乌松大学校园导航服务';

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
  String get guest_mode_confirm => '确定要以访客模式进入吗？\n\n访客模式下无法使用朋友功能和位置共享功能。';

  @override
  String get app_name => '跟随乌松';

  @override
  String get welcome_to_ttarausong => '欢迎使用跟随乌松';

  @override
  String get guest_mode_description => '访客模式下只能查看基本的校园信息。\n要使用所有功能，请注册后登录。';

  @override
  String get continue_as_guest => '继续以访客身份';

  @override
  String get moved_to_my_location => '已自动移动到我的位置';

  @override
  String get friends_screen_bottom_sheet => '朋友界面以底部表单显示';

  @override
  String get finding_current_location => '正在查找当前位置...';

  @override
  String get home => '主页';

  @override
  String get timetable => '时间表';

  @override
  String get friends => '朋友';

  @override
  String get finish => '完成';

  @override
  String get profile => '个人资料';

  @override
  String get inquiry => '查询';

  @override
  String get my_inquiry => '我的查询';

  @override
  String get inquiry_type => '查询类型';

  @override
  String get inquiry_type_required => '请选择查询类型';

  @override
  String get inquiry_type_select_hint => '请选择查询类型';

  @override
  String get inquiry_title => '查询标题';

  @override
  String get inquiry_content => '查询内容';

  @override
  String get inquiry_content_hint => '请输入查询内容';

  @override
  String get inquiry_submit => '提交查询';

  @override
  String get inquiry_submit_success => '查询已成功提交';

  @override
  String get inquiry_submit_failed => '查询提交失败';

  @override
  String get no_inquiry_history => '没有查询历史';

  @override
  String get no_inquiry_history_hint => '还没有查询记录';

  @override
  String get inquiry_delete => '删除查询';

  @override
  String get inquiry_delete_confirm => '确定要删除此查询吗？';

  @override
  String get inquiry_delete_success => '查询已删除';

  @override
  String get inquiry_delete_failed => '删除查询失败';

  @override
  String get inquiry_detail => '查询详情';

  @override
  String get inquiry_category => '查询类别';

  @override
  String get inquiry_status => '查询状态';

  @override
  String get inquiry_created_at => '查询时间';

  @override
  String get inquiry_title_label => '查询标题';

  @override
  String get inquiry_type_bug => '错误报告';

  @override
  String get inquiry_type_feature => '功能建议';

  @override
  String get inquiry_type_improvement => '改进建议';

  @override
  String get inquiry_type_other => '其他查询';

  @override
  String get inquiry_status_pending => '等待答复';

  @override
  String get inquiry_status_in_progress => '处理中';

  @override
  String get inquiry_status_answered => '答复完成';

  @override
  String get phone_required => '电话号码是必需的';

  @override
  String get building_info => '建筑信息';

  @override
  String get directions => '路线导航';

  @override
  String get floor_detail_view => '楼层详细信息';

  @override
  String get no_floor_info => '没有楼层信息';

  @override
  String get floor_detail_info => '楼层详细信息';

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
  String get try_different_keyword => '请尝试其他关键词';

  @override
  String get enter_end_location => '请输入目的地';

  @override
  String get route_preview => '路线预览';

  @override
  String get calculating_optimal_route => '计算最佳路线中...';

  @override
  String get set_departure_and_destination => '请设置出发地和目的地';

  @override
  String get start_unified_navigation => '开始统一导航';

  @override
  String get departure_indoor => '出发地（室内）';

  @override
  String get to_building_exit => '前往建筑出口';

  @override
  String get outdoor_movement => '室外移动';

  @override
  String get to_destination_building => '前往目标建筑';

  @override
  String get arrival_indoor => '到达地（室内）';

  @override
  String get to_final_destination => '前往最终目的地';

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
  String get status_open => '营业中';

  @override
  String get status_closed => '营业结束';

  @override
  String get status_24hours => '24小时';

  @override
  String get status_temp_closed => '临时休业';

  @override
  String get status_closed_permanently => '永久关闭';

  @override
  String get status_next_open => '上午9点开始营业';

  @override
  String get status_next_close => '下午6点结束营业';

  @override
  String get status_next_open_tomorrow => '明天上午9点开始营业';

  @override
  String get set_start_point => '设置起点';

  @override
  String get set_end_point => '设置终点';

  @override
  String get scheduleDeleteTitle => '时间表删除';

  @override
  String get scheduleDeleteSubtitle => '请慎重决定';

  @override
  String get scheduleDeleteLabel => '要删除的时间表';

  @override
  String scheduleDeleteDescription(Object title) {
    return '「$title」课程将从时间表中删除。\n删除的时间表无法恢复。';
  }

  @override
  String get cancelButton => '取消';

  @override
  String get deleteButton => '删除';

  @override
  String get overlap_message => '此时间已有注册的课程';

  @override
  String friendDeleteSuccessMessage(Object userName) {
    return '$userName已从朋友列表中删除';
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
    return '$userName的位置信息已删除';
  }

  @override
  String friendLocationShown(String userName) {
    return '$userName的位置信息已显示';
  }

  @override
  String get errorCannotRemoveLocation => '无法删除位置信息';

  @override
  String get my_page => '我的页面';

  @override
  String get calculating_route => '路线计算中...';

  @override
  String get finding_optimal_route => '在服务器中搜索最佳路线';

  @override
  String get clear_route => '清除路线';

  @override
  String get location_permission_denied => '位置权限被拒绝。\n请在设置中启用位置权限。';

  @override
  String get estimated_time => '预计时间';

  @override
  String get location_share_update_failed => '位置共享设置更新失败';

  @override
  String get guest_location_share_success => '访客模式下仅在本地设置位置共享';

  @override
  String get no_changes => '没有变更';

  @override
  String get password_confirm_title => '确认密码';

  @override
  String get password_confirm_subtitle => '请输入密码以修改会员信息';

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
  String get excel_file_tutorial => 'Excel文件使用方法';

  @override
  String get image_attachment => '图片附件';

  @override
  String get max_one_image => '最多1张';

  @override
  String get photo_attachment => '照片附件';

  @override
  String get photo_attachment_complete => '照片附件完成';

  @override
  String get image_selection => '图像选择';

  @override
  String get select_image_method => '图像选择方法';

  @override
  String get select_from_gallery => '从相册选择';

  @override
  String get select_from_gallery_desc => '从相册中选择图像';

  @override
  String get select_from_file => '从文件选择';

  @override
  String get select_from_file_desc => '从文件中选择图像';

  @override
  String get max_one_image_error => '图像最多只能附加1张';

  @override
  String get image_selection_error => '图像选择过程中发生错误';

  @override
  String get inquiry_error_occurred => '查询处理过程中发生错误';

  @override
  String get inquiry_category_bug => '错误报告';

  @override
  String get inquiry_category_feature => '功能请求';

  @override
  String get inquiry_category_other => '其他查询';

  @override
  String get inquiry_category_route_error => '路线错误';

  @override
  String get inquiry_category_place_error => '地点错误';

  @override
  String get location_share_updating => '状态更新中...';

  @override
  String get schedule => '时间表';

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
  String get color_selection => '颜色选择';

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
    return '确定要删除$className课程吗？';
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
  String get map_feature_coming_soon => '地图功能即将推出';

  @override
  String current_year(int year) {
    return '当前年份';
  }

  @override
  String get my_friends => '我的朋友';

  @override
  String online_friends(int total, int online) {
    return '在线朋友';
  }

  @override
  String get add_friend => '添加朋友';

  @override
  String get friend_name_or_id => '朋友姓名或ID';

  @override
  String get friend_request_sent => '朋友请求已发送';

  @override
  String get in_class => '上课中';

  @override
  String last_location(String location) {
    return '最后位置';
  }

  @override
  String get central_library => '中央图书馆';

  @override
  String get engineering_building => '工程馆';

  @override
  String get student_center => '学生会馆';

  @override
  String get cafeteria => 'Cafeteria';

  @override
  String get message => '消息';

  @override
  String get call => '电话';

  @override
  String start_chat_with(String name) {
    return '开始聊天';
  }

  @override
  String view_location_on_map(String name) {
    return '在地图上查看位置';
  }

  @override
  String calling(String name) {
    return '通话中';
  }

  @override
  String get delete => '删除';

  @override
  String get search => '搜索';

  @override
  String get searchBuildings => '搜索建筑物';

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
  String get my_location_set_as_start => '我的位置已自动设为起点';

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
  String get setAsDestination => '设为目标地';

  @override
  String get navigateFromHere => '从这里导航';

  @override
  String get buildingInfo => '建筑信息';

  @override
  String get locationPermissionRequired => '需要位置权限';

  @override
  String get enableLocationServices => '请启用位置服务';

  @override
  String get noResults => '没有结果';

  @override
  String get settings => '设置';

  @override
  String get language => '语言';

  @override
  String get about => '关于';

  @override
  String friends_count_status(int total, int online) {
    return '朋友数量状态';
  }

  @override
  String get enter_friend_info => '输入朋友信息';

  @override
  String show_location_on_map(String name) {
    return '在地图上显示位置';
  }

  @override
  String get location_error => '位置错误';

  @override
  String get view_floor_plan => '查看平面图';

  @override
  String floor_plan_title(String buildingName) {
    return '平面图';
  }

  @override
  String get floor_plan_not_available => '无法使用平面图';

  @override
  String get floor_plan_default_text => '平面图默认文本';

  @override
  String get delete_account_success => '账户已成功删除';

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
  String get health_center => '保健所';

  @override
  String get gym => '体育馆';

  @override
  String get fitness_center => '健身房';

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
    return '请移动到目的地';
  }

  @override
  String get markerDeparture => 'Departure';

  @override
  String get markerArrival => 'Arrival';

  @override
  String get errorCannotOpenPhoneApp => 'Cannot open the phone app.';

  @override
  String get emailCopied => 'Email copied to clipboard.';

  @override
  String get description => 'Description';

  @override
  String get noDetailedInfoRegistered => 'No detailed information registered.';

  @override
  String get setDeparture => 'Set as Departure';

  @override
  String get setArrival => 'Set as Arrival';

  @override
  String errorOccurred(Object error) {
    return 'An error occurred: $error';
  }

  @override
  String get instructionExitToOutdoor => '请到室外';

  @override
  String instructionMoveToDestinationBuilding(String building) {
    return '请移动到目标建筑';
  }

  @override
  String get instructionMoveToRoom => '请移动到房间';

  @override
  String get instructionArrived => '已到达';

  @override
  String get no => '否';

  @override
  String get woosong_library_w1 => '乌松图书馆 (W1)';

  @override
  String get woosong_library_info =>
      'B2F\t停车场\nB1F\t小礼堂、机械室、电气室、停车场\n1F\t就业支援中心 (630-9976)、借阅台、信息休息室\n2F\t一般阅览室、小组学习室\n3F\t一般阅览室\n4F\t文学图书/西洋图书';

  @override
  String get educational_facility => 'Educational Facility';

  @override
  String get operating => 'Operating';

  @override
  String get woosong_library_desc => '乌松大学中央图书馆';

  @override
  String get sol_cafe => '索尔咖啡厅';

  @override
  String get sol_cafe_info => '1F\t餐厅\n2F\t咖啡厅';

  @override
  String get cafe => '咖啡厅';

  @override
  String get sol_cafe_desc => '校园内咖啡厅';

  @override
  String get cheongun_1_dormitory => '青云1宿舍';

  @override
  String get cheongun_1_dormitory_info =>
      '1F\t实习室\n2F\t学生餐厅\n2F\t青云1宿舍(女) (629-6542)\n2F\t生活馆\n3~5F\t生活馆';

  @override
  String get dormitory => '宿舍';

  @override
  String get cheongun_1_dormitory_desc => '女生宿舍';

  @override
  String get industry_cooperation_w2 => '产学合作团 (W2)';

  @override
  String get industry_cooperation_info =>
      '1F\t产学合作团\n2F\t建筑工程系 (630-9720)\n3F\t乌松大学融合技术研究所、产学研综合企业支援中心\n4F\t企业附属研究所、LG CNS教室、铁道数字学院教室';

  @override
  String get industry_cooperation_desc => '产学合作及研究设施';

  @override
  String get rotc_w2_1 => '学军团 (W2-1)';

  @override
  String get rotc_info => '\t学军团 (630-4601)';

  @override
  String get rotc_desc => '学军团设施';

  @override
  String get military_facility => '军事设施';

  @override
  String get international_dormitory_w3 => '留学生宿舍 (W3)';

  @override
  String get international_dormitory_info =>
      '1F\t留学生支援组 (629-6623)\n1F\t学生餐厅\n2F\t留学生宿舍 (629-6655)\n2F\t保健室\n3~12F\t生活馆';

  @override
  String get international_dormitory_desc => '留学生专用宿舍';

  @override
  String get railway_logistics_w4 => '铁道物流馆 (W4)';

  @override
  String get railway_logistics_info =>
      'B1F\t实习室\n1F\t实习室\n2F\t铁道建设系统学部 (629-6710)\n2F\t铁道车辆系统系 (629-6780)\n3F\t教室/实习室\n4F\t铁道系统学部 (630-6730,9700)\n5F\t消防防灾系 (629-6770)\n5F\t物流系统系 (630-9330)';

  @override
  String get railway_logistics_desc => '铁道及物流相关学系';

  @override
  String get health_medical_science_w5 => '保健医疗科学馆 (W5)';

  @override
  String get health_medical_science_info =>
      'B1F\t停车场\n1F\t视听室/停车场\n2F\t教室\n2F\t运动健康康复系 (630-9840)\n3F\t应急结构系 (630-9280)\n3F\t护理系 (630-9290)\n4F\t作业治疗系 (630-9820)\n4F\t语言治疗听觉康复系 (630-9220)\n5F\t物理治疗系 (630-4620)\n5F\t保健医疗经营系 (630-4610)\n5F\t教室\n6F\t铁道经营系 (630-9770)';

  @override
  String get health_medical_science_desc => '保健医疗相关学系';

  @override
  String get liberal_arts_w6 => '教养教育馆 (W6)';

  @override
  String get liberal_arts_info => '2F\t教室\n3F\t教室\n4F\t教室\n5F\t教室';

  @override
  String get liberal_arts_desc => '教养教室';

  @override
  String get woosong_hall_w7 => '乌松馆 (W7)';

  @override
  String get woosong_hall_info =>
      '1F\t入学处 (630-9627)\n1F\t教务处 (630-9622)\n1F\t设施处 (630-9970)\n1F\t管理组 (629-6658)\n1F\t产学合作团 (630-4653)\n1F\t对外合作处 (630-9636)\n2F\t战略企划处 (630-9102)\n2F\t总务处-总务、购买 (630-9653)\n2F\t企划处 (630-9661)\n3F\t总长室 (630-8501)\n3F\t国际交流处 (630-9373)\n3F\t幼儿教育系 (630-9360)\n3F\t经营学专业 (629-6640)\n3F\t金融/房地产学专业 (630-9350)\n4F\t大会会议室\n5F\t会议室';

  @override
  String get woosong_hall_desc => '大学本部建筑';

  @override
  String get woosong_kindergarten_w8 => '乌松幼儿园 (W8)';

  @override
  String get woosong_kindergarten_info => '1F, 2F\t乌松幼儿园 (629~6750~1)';

  @override
  String get woosong_kindergarten_desc => '大学附属幼儿园';

  @override
  String get kindergarten => '幼儿园';

  @override
  String get west_campus_culinary_w9 => '西校区料理学院 (W9)';

  @override
  String get west_campus_culinary_info => 'B1F\t实习室\n1F\t实习室\n2F\t实习室';

  @override
  String get west_campus_culinary_desc => '料理实习设施';

  @override
  String get social_welfare_w10 => '社会福利融合馆 (W10)';

  @override
  String get social_welfare_info =>
      '1F\t视听室/实习室\n2F\t教室/实习室\n3F\t社会福利系 (630-9830)\n3F\t全球儿童教育系 (630-9260)\n4F\t教室/实习室\n5F\t教室/实习室';

  @override
  String get social_welfare_desc => '社会福利相关学系';

  @override
  String get gymnasium_w11 => '体育馆 (W11)';

  @override
  String get gymnasium_info => '1F\t体能训练室\n2F~4F\t体育馆';

  @override
  String get gymnasium_desc => '体育设施';

  @override
  String get sports_facility => '体育设施';

  @override
  String get sica_w12 => 'SICA (W12)';

  @override
  String get sica_info =>
      'B1F\t实习室\n1F\t斯塔里科咖啡厅\n2F~3F\t教室\n5F\t全球料理学部 (629-6860)';

  @override
  String get sica_desc => '国际料理学院';

  @override
  String get woosong_tower_w13 => '乌松塔 (W13)';

  @override
  String get woosong_tower_info =>
      'B1~1F\t停车场\n2F\t停车场、索尔派恩面包店 (629-6429)\n4F\t研讨会室\n5F\t教室\n6F\t外食料理营养系 (630-9380,9740)\n7F\t教室\n8F\t外食、料理经营专业 (630-9250)\n9F\t教室/实习室\n10F\t外食料理专业 (629-6821)、全球韩食料理专业 (629-6560)\n11F, 12F\t实习室\n13F\t索尔派恩餐厅 (629-6610)';

  @override
  String get woosong_tower_desc => '综合教育设施';

  @override
  String get complex_facility => '综合设施';

  @override
  String get culinary_center_w14 => '料理中心 (W14)';

  @override
  String get culinary_center_info =>
      '1F\t教室/实习室\n2F\t教室/实习室\n3F\t教室/实习室\n4F\t教室/实习室\n5F\t教室/实习室';

  @override
  String get culinary_center_desc => '料理专业教育设施';

  @override
  String get food_architecture_w15 => '食品建筑馆 (W15)';

  @override
  String get food_architecture_info =>
      'B1F\t实习室\n1F\t实习室\n2F\t教室\n3F\t教室\n4F\t教室\n5F\t教室';

  @override
  String get food_architecture_desc => '食品及建筑相关学系';

  @override
  String get student_hall_w16 => '学生会馆 (W16)';

  @override
  String get student_hall_info =>
      '1F\t学生餐厅、校内书店 (629-6127)\n2F\t教职员餐厅\n3F\t社团室\n3F\t学生福利处-学生组 (630-9641)、奖学金组 (630-9876)\n3F\t残疾学生支援中心 (630-9903)\n3F\t社会服务团 (630-9904)\n3F\t学生咨询中心 (630-9645)\n4F\t复学支援中心 (630-9139)\n4F\t教授学习开发中心 (630-9285)';

  @override
  String get student_hall_desc => '学生福利设施';

  @override
  String get media_convergence_w17 => '媒体融合馆 (W17)';

  @override
  String get media_convergence_info =>
      'B1F\t教室/实习室\n1F\t媒体设计/影像专业 (630-9750)\n2F\t教室/实习室\n3F\t游戏多媒体专业 (630-9270)\n5F\t教室/实习室';

  @override
  String get media_convergence_desc => '媒体相关学系';

  @override
  String get woosong_arts_center_w18 => '乌松艺术会馆 (W18)';

  @override
  String get woosong_arts_center_info =>
      'B1F\t演出准备室\n1F\t乌松艺术会馆 (629-6363)\n2F\t实习室\n3F\t实习室\n4F\t实习室\n5F\t实习室';

  @override
  String get woosong_arts_center_desc => '艺术演出设施';

  @override
  String get west_campus_andycut_w19 => '西校区安迪卡特建筑 (W19)';

  @override
  String get west_campus_andycut_info =>
      '2F\t全球融合商务系 (630-9249)\n2F\t自由专业学部 (630-9390)\n2F\tAI/大数据系 (630-9807)\n2F\t全球酒店经营系 (630-9249)\n2F\t全球媒体影像系 (630-9346)\n2F\t全球医疗服务经营系 (630-9283)\n2F\t全球铁道/交通物流学部 (630-9347)\n2F\t全球外食创业系 (629-6860)';

  @override
  String get west_campus_andycut_desc => '全球学系建筑';

  @override
  String get search_campus_buildings => '搜索校园建筑';

  @override
  String get building_details => '详细信息';

  @override
  String get parking => '停车';

  @override
  String get accessibility => '便利设施';

  @override
  String get facilities => '设施';

  @override
  String get elevator => '电梯';

  @override
  String get restroom => '洗手间';

  @override
  String get navigate_from_current_location => '从当前位置导航';

  @override
  String get edit_profile => '编辑个人资料';

  @override
  String get nameRequired => '请输入姓名';

  @override
  String get emailRequired => '请输入电子邮件';

  @override
  String get save => '保存';

  @override
  String get saveSuccess => '个人资料已更新';

  @override
  String get app_info => '应用信息';

  @override
  String get app_version => '应用版本';

  @override
  String get developer => '开发者';

  @override
  String get developer_name => '团队成员：郑振英、朴哲贤、赵贤俊、崔成烈、韩承宪、李艺恩';

  @override
  String get developer_email => '电子邮件：wsumap41@gmail.com';

  @override
  String get developer_github => 'GitHub：github.com/WSU-YJB/WSUMAP';

  @override
  String get no_help_images => '没有帮助图像';

  @override
  String get description_hint => '请输入说明';

  @override
  String get my_info => '我的信息';

  @override
  String get guest_user => '访客用户';

  @override
  String get guest_role => '访客角色';

  @override
  String get user => '用户';

  @override
  String get edit_profile_subtitle => '可以修改个人信息';

  @override
  String get help_subtitle => '查看应用使用方法';

  @override
  String get support_contact_title => '客户支持';

  @override
  String get support_contact_description => '使用应用时如有问题，请通过个人资料＞咨询发送，或使用App Store应用信息中的支持网站。';

  @override
  String get support_go_to_inquiry => '联系我们';

  @override
  String get app_info_subtitle => '版本信息及开发者信息';

  @override
  String get delete_account_subtitle => '永久删除账户';

  @override
  String get login_message => '登录或注册\n要使用所有功能';

  @override
  String get login_signup => '登录 / 注册';

  @override
  String get delete_account_confirm => '删除账户';

  @override
  String get delete_account_message => '确定要删除账户吗？';

  @override
  String get logout_confirm => '登出';

  @override
  String get logout_message => '确定要登出吗？';

  @override
  String get yes => '是';

  @override
  String get feature_in_progress => '功能开发中';

  @override
  String get delete_feature_in_progress => '账户删除功能正在开发中';

  @override
  String get title => '编辑个人资料';

  @override
  String get email_required => '请输入电子邮件';

  @override
  String get name_required => '请输入姓名';

  @override
  String get cancelFriendRequest => '取消朋友请求';

  @override
  String cancelFriendRequestConfirm(String name) {
    return '确定要取消发送给$name的朋友请求吗？';
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
  String get cancelRequest => '取消请求';

  @override
  String get friendDeleteTitle => '删除朋友';

  @override
  String get friendDeleteWarning => '此操作无法撤销';

  @override
  String get friendDeleteHeader => '删除朋友';

  @override
  String get friendDeleteToConfirm => '请输入要删除的朋友姓名';

  @override
  String get friendDeleteCancel => '取消';

  @override
  String get friendDeleteButton => '删除';

  @override
  String get friendManagementAndRequests => '朋友管理及请求';

  @override
  String get realTimeSyncStatus => '实时同步状态';

  @override
  String get friendManagement => 'Friend Management';

  @override
  String get add => '添加';

  @override
  String sentRequestsCount(int count) {
    return '已发送请求 ($count)';
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
  String get indoorMap => 'Indoor Map';

  @override
  String get showBuildingMarker => 'Show Building Marker';

  @override
  String get search_hint => '搜索建筑物或房间';

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
  String get privacy_policy_subtitle => '请查看隐私政策';

  @override
  String get fire_extinguisher => 'Fire Extinguisher';

  @override
  String get my_location_route_calculating =>
      'Calculating route from my location to the building. Please wait a moment.';

  @override
  String get calculating => 'Calculating';

  @override
  String get set_both_locations => 'Please set both departure and destination';

  @override
  String get route_calculating => 'Calculating route...';

  @override
  String get search_error => '搜索错误';

  @override
  String get search_initial_guide => '搜索建筑物或房间';

  @override
  String get search_hint_example => '例如：W19、工程馆、401室';

  @override
  String get search_loading => '搜索中...';

  @override
  String get search_no_result => 'No search results found';

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
  String get friend_location_display_error => 'Cannot display friend location.';

  @override
  String get friend_location_remove_error => 'Cannot remove location.';

  @override
  String get phone_app_error => 'Cannot open phone app.';

  @override
  String get add_friend_error => 'Error occurred while adding friend';

  @override
  String get user_not_found => 'User not found';

  @override
  String get already_friend => 'User is already a friend';

  @override
  String get already_requested => 'Friend request already sent to this user';

  @override
  String get cannot_add_self => 'Cannot add yourself as a friend';

  @override
  String get invalid_user_id => 'Invalid user ID';

  @override
  String get server_error_retry =>
      'Server error occurred. Please try again later';

  @override
  String get cancel_request_description => 'Cancel sent friend request';

  @override
  String get enter_id_prompt => 'Please enter ID';

  @override
  String get friend_request_sent_success => 'Friend request sent successfully';

  @override
  String get already_adding_friend =>
      'Already adding friend. Preventing duplicate submission';

  @override
  String friends_location_displayed(int count) {
    return 'Displayed location of $count friends.';
  }

  @override
  String get offline_friends_dialog_title => 'Offline Friends';

  @override
  String friendRequestCancelled(String name) {
    return 'Cancelled friend request sent to $name.';
  }

  @override
  String get friendRequestCancelError =>
      'Error occurred while cancelling friend request.';

  @override
  String friendRequestAccepted(String name) {
    return 'Accepted friend request from $name.';
  }

  @override
  String get friendRequestAcceptError =>
      'Error occurred while accepting friend request.';

  @override
  String friendRequestRejected(String name) {
    return 'Rejected friend request from $name.';
  }

  @override
  String get friendRequestRejectError =>
      'Error occurred while rejecting friend request.';

  @override
  String get friendLocationRemovedFromMap =>
      'Friend locations have been removed from the map.';

  @override
  String get info => 'Info';

  @override
  String get room_info_processing_error =>
      'Error occurred while processing room information';

  @override
  String get selection_error =>
      'Error occurred during selection. Please try again';

  @override
  String get building_selection_error =>
      'Error occurred while selecting building. Please try again';

  @override
  String get navigation_start_error =>
      'Cannot start navigation. Please check the route again';

  @override
  String get item_selection_error => 'Error occurred while selecting item';

  @override
  String get dialog_display_error => 'Error occurred while displaying dialog';

  @override
  String get enter_start_location => 'Enter departure point';

  @override
  String get room_set_as_start => ' room has been set as departure point';

  @override
  String get room_set_as_end => ' room has been set as destination';

  @override
  String get building_set_as_start => ' has been set as departure point';

  @override
  String get building_set_as_end => ' has been set as destination';
}
