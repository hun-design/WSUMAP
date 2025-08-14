// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'ウソンに従う';

  @override
  String get subtitle => 'スマートキャンパスガイド';

  @override
  String get woosong => 'ウソン';

  @override
  String get start => '開始';

  @override
  String get login => 'ログイン';

  @override
  String get logout => 'ログアウト';

  @override
  String get guest => 'ゲスト';

  @override
  String get student_professor => '学生/教授';

  @override
  String get admin => '管理者';

  @override
  String get student => '学生';

  @override
  String get professor => '教授';

  @override
  String get external_user => '外部利用者';

  @override
  String get username => 'ユーザーID';

  @override
  String get password => 'パスワード';

  @override
  String get confirm_password => 'パスワード確認';

  @override
  String get remember_me => 'ログイン情報を記憶する';

  @override
  String get remember_me_description => '次回は自動的にログインされます';

  @override
  String get login_as_guest => 'ゲストとして閲覧';

  @override
  String get login_failed => 'ログイン失敗';

  @override
  String get login_success => 'ログイン成功';

  @override
  String get logout_success => 'ログアウトしました';

  @override
  String get enter_username => 'ユーザーIDを入力してください';

  @override
  String get enter_password => 'パスワードを入力してください';

  @override
  String get password_hint => '6文字以上で入力してください';

  @override
  String get confirm_password_hint => 'パスワードを再入力してください';

  @override
  String get username_password_required => 'ユーザーIDとパスワードを両方入力してください';

  @override
  String get login_error => 'ログインに失敗しました';

  @override
  String get find_password => 'パスワードを探す';

  @override
  String get find_username => 'ユーザーIDを探す';

  @override
  String get back => '戻る';

  @override
  String get confirm => '確認';

  @override
  String get cancel => 'キャンセル';

  @override
  String get coming_soon => '準備中';

  @override
  String feature_coming_soon(String feature) {
    return '$feature機能は準備中です。\n近日中に追加される予定です。';
  }

  @override
  String get departurePoint => '出発';

  @override
  String get arrivalPoint => '도착지';

  @override
  String get all => 'すべて';

  @override
  String get tutorial => '使い方';

  @override
  String get tutorialTitleIntro => 'ウソンに従うの使い方';

  @override
  String get tutorialDescIntro => 'ウソン大学のキャンパスナビゲーターで\nキャンパスライフをより便利にしましょう';

  @override
  String get tutorialTitleSearch => '詳細な検索機能';

  @override
  String get tutorialDescSearch =>
      'ウソン大学では建物だけでなく講義室も検索できます！\n講義室の場所から便利施設まで詳細に検索してみてください 😊';

  @override
  String get tutorialTitleSchedule => '時間割連携';

  @override
  String get tutorialDescSchedule =>
      '授業時間割をアプリに連携して\n次の授業までの最適ルートを自動で案内してもらいましょう';

  @override
  String get tutorialTitleDirections => '道案内';

  @override
  String get tutorialDescDirections => 'キャンパス内の正確なルート案内で\n目的地まで簡単に素早く到着しましょう';

  @override
  String get tutorialTitleIndoorMap => '建物内部図面';

  @override
  String get tutorialDescIndoorMap => '建物内部の詳細な図面で\n講義室と便利施設を簡単に見つけてみてください';

  @override
  String get dontShowAgain => '再表示しない';

  @override
  String get goBack => '戻る';

  @override
  String get lectureRoom => '講義室';

  @override
  String get lectureRoomInfo => '講義室情報';

  @override
  String get floor => '階';

  @override
  String get personInCharge => '担当者';

  @override
  String get viewLectureRoom => '講義室を見る';

  @override
  String get viewBuilding => '建物を見る';

  @override
  String get walk => '徒歩';

  @override
  String get minute => '分';

  @override
  String get hour => '時間';

  @override
  String get less_than_one_minute => '1分以内';

  @override
  String get zero_minutes => '0分';

  @override
  String get calculation_failed => '計算不可';

  @override
  String get professor_name => '教授名';

  @override
  String get building_name => '建物名';

  @override
  String floor_number(Object floor) {
    return '$floor 階';
  }

  @override
  String get room_name => '講義室';

  @override
  String get day_of_week => '曜日';

  @override
  String get time => '時間';

  @override
  String get memo => 'メモ';

  @override
  String get recommend_route => '推奨ルート';

  @override
  String get view_location => '場所表示';

  @override
  String get edit => '編集';

  @override
  String get close => '閉じる';

  @override
  String get help => '使い方';

  @override
  String get help_intro_title => 'ウソンに従うの使い方';

  @override
  String get help_intro_description =>
      'ウソン大学のキャンパスナビゲーターで\nキャンパスライフをより便利にしましょう';

  @override
  String get help_detailed_search_title => '詳細検索';

  @override
  String get help_detailed_search_description =>
      '建物名、講義室番号、便利施設まで\n正確で素早い検索でお探しの場所を見つけてください';

  @override
  String get help_timetable_title => '時間割連携';

  @override
  String get help_timetable_description =>
      '授業時間割をアプリに連携して\n次の授業までの最適ルートを自動で案内してもらいましょう';

  @override
  String get help_directions_title => '道案内';

  @override
  String get help_directions_description =>
      'キャンパス内の正確なルート案内で\n目的地まで簡単に素早く到着しましょう';

  @override
  String get help_building_map_title => '建物内部図面';

  @override
  String get help_building_map_description =>
      '建物内部の詳細な図面で\n講義室と便利施設を簡単に見つけてみてください';

  @override
  String get previous => '前へ';

  @override
  String get next => '次へ';

  @override
  String get done => '完了';

  @override
  String get image_load_error => '画像を読み込めません';

  @override
  String get start_campus_exploration => 'キャンパス探索を始めてみましょう';

  @override
  String get woosong_university => 'ウソン大学';

  @override
  String get excel_upload_title => '時間割エクセルファイルアップロード';

  @override
  String get excel_upload_description => 'ウソン大学の時間割エクセルファイル(.xlsx)を選択してください';

  @override
  String get excel_file_select => 'エクセルファイル選択';

  @override
  String get excel_upload_uploading => 'エクセルファイルをアップロード中...';

  @override
  String get language_selection => '言語選択';

  @override
  String get language_selection_description => '使用する言語を選択してください';

  @override
  String get departure => '出発地';

  @override
  String get destination => '目的地';

  @override
  String get my_location => '現在地';

  @override
  String get current_location => '現在位置';

  @override
  String get welcome_subtitle_1 => '手の中のウソン、';

  @override
  String get welcome_subtitle_2 => '建物情報がすべてここに！';

  @override
  String get select_language => '言語選択';

  @override
  String get auth_selection_title => '認証方法選択';

  @override
  String get auth_selection_subtitle => '希望するログイン方法を選択してください';

  @override
  String get select_auth_method => '認証方法選択';

  @override
  String total_floors(Object count) {
    return '合計 $count 階';
  }

  @override
  String get floor_info => '階層情報';

  @override
  String floor_with_category(Object category) {
    return '$categoryがある階';
  }

  @override
  String get floor_label => '階';

  @override
  String get category => 'カテゴリ';

  @override
  String get excel_upload_success => 'アップロード完了！';

  @override
  String get guest_timetable_disabled => 'ゲストユーザーは時間割機能を使用できません。';

  @override
  String get guest_timetable_add_disabled => 'ゲストユーザーは時間割を追加できません。';

  @override
  String get guest_timetable_edit_disabled => 'ゲストユーザーは時間割を編集できません。';

  @override
  String get guest_timetable_delete_disabled => 'ゲストユーザーは時間割を削除できません。';

  @override
  String get timetable_load_failed => '時間割の読み込みに失敗しました。';

  @override
  String get timetable_add_success => '時間割が正常に追加されました。';

  @override
  String timetable_add_failed(Object error) {
    return '時間割の追加に失敗しました';
  }

  @override
  String get timetable_overlap => '同じ時間に既に登録された授業があります。';

  @override
  String get required_fields_missing => '必須項目をすべて入力してください。';

  @override
  String get no_search_results => '検索結果がありません';

  @override
  String get excel_upload_refreshing => '時間割を更新中...';

  @override
  String get logout_processing => 'ログアウト中...';

  @override
  String get logout_error_message => 'ログアウト中にエラーが発生しましたが、初期画面に移動します。';

  @override
  String get data_to_be_deleted => '削除されるデータ';

  @override
  String get deleting_account => 'アカウントを削除中...';

  @override
  String get excel_tutorial_title => 'エクセルファイルダウンロード方法';

  @override
  String get edit_profile_section => 'プロフィール編集';

  @override
  String get delete_account_section => 'アカウント削除';

  @override
  String get logout_section => 'ログアウト';

  @override
  String get location_share_title => '位置情報共有';

  @override
  String get location_share_enabled => '位置情報共有が有効になっています';

  @override
  String get location_share_disabled => '位置情報共有が無効になっています';

  @override
  String get excel_tutorial_previous => '前へ';

  @override
  String get room_route_error =>
      'Error calculating room route. Please search by building.';

  @override
  String get location_check_error =>
      'Unable to check current location. Please try again.';

  @override
  String get server_connection_error =>
      'There is a problem with server connection. Please try again later.';

  @override
  String get route_calculation_error =>
      'Error occurred while calculating route. Please try again.';

  @override
  String get try_again => 'Try Again';

  @override
  String get current_location_departure => '現在地から出発';

  @override
  String get current_location_departure_default => '現在地から出発（デフォルト場所）';

  @override
  String get current_location_navigation_start =>
      'Start navigation from current location';

  @override
  String get excel_tutorial_next => '次へ';

  @override
  String get profile_edit_title => 'プロフィール編集';

  @override
  String get profile_edit_subtitle => '個人情報を修正できます';

  @override
  String get account_delete_title => 'アカウント削除';

  @override
  String get account_delete_subtitle => 'アカウントを永続的に削除します';

  @override
  String get logout_title => 'ログアウト';

  @override
  String get logout_subtitle => '現在のアカウントからログアウトします';

  @override
  String get location_share_enabled_success => '位置情報共有が有効になりました';

  @override
  String get location_share_disabled_success => '位置情報共有が無効になりました';

  @override
  String get profile_edit_error => 'プロフィール編集中にエラーが発生しました';

  @override
  String get inquiry_load_failed => 'お問い合わせリストの読み込みに失敗しました';

  @override
  String get pull_to_refresh => '下にスワイプして更新';

  @override
  String get app_version_number => 'v1.0.0';

  @override
  String get developer_email_address => 'wsumap41@gmail.com';

  @override
  String get developer_github_url => 'https://github.com/WSU-YJB/WSUMAP';

  @override
  String get friend_management => '友達管理';

  @override
  String get excel_tutorial_file_select => 'ファイル選択';

  @override
  String get excel_tutorial_help => '使い方を見る';

  @override
  String get excel_upload_file_cancelled => 'ファイル選択がキャンセルされました。';

  @override
  String get excel_upload_success_message => '時間割が更新されました！';

  @override
  String excel_upload_refresh_failed(String error) {
    return '更新に失敗しました: $error';
  }

  @override
  String excel_upload_failed(String error) {
    return 'アップロード失敗: $error';
  }

  @override
  String get excel_tutorial_step_1 => '1. ウソン大学の大学情報システムにログイン';

  @override
  String get excel_tutorial_url => 'https://wsinfo.wsu.ac.kr';

  @override
  String get excel_tutorial_image_load_error => '画像を読み込めません';

  @override
  String get excel_tutorial_unknown_page => '不明なページ';

  @override
  String get campus_navigator => 'キャンパスナビゲーター';

  @override
  String get user_info_not_found => 'ログイン応答でユーザー情報が見つかりません';

  @override
  String get unexpected_login_error => 'ログイン中に予期しないエラーが発生しました';

  @override
  String get login_required => 'ログインが必要です';

  @override
  String get register => '会員登録';

  @override
  String get register_success => '会員登録が完了しました';

  @override
  String get register_success_message => '会員登録が完了しました！\nログイン画面に移動します。';

  @override
  String get register_error => '会員登録中に予期しないエラーが発生しました';

  @override
  String get update_user_info => '会員情報修正';

  @override
  String get update_success => '会員情報が修正されました';

  @override
  String get update_error => '会員情報修正中に予期しないエラーが発生しました';

  @override
  String get delete_account => '会員退会';

  @override
  String get delete_success => '会員退会が完了しました';

  @override
  String get delete_error => '会員退会中に予期しないエラーが発生しました';

  @override
  String get name => '名前';

  @override
  String get phone => '電話番号';

  @override
  String get email => 'メールアドレス';

  @override
  String get student_number => '学番';

  @override
  String get user_type => 'ユーザータイプ';

  @override
  String get optional => '選択項目';

  @override
  String get required_fields_empty => 'すべての必須項目を入力してください';

  @override
  String get password_mismatch => 'パスワードが一致しません';

  @override
  String get password_too_short => 'パスワードは6文字以上である必要があります';

  @override
  String get invalid_phone_format => '正しい電話番号形式を入力してください (例: 010-1234-5678)';

  @override
  String get invalid_email_format => '正しいメールアドレス形式を入力してください';

  @override
  String get required_fields_notice => '* マークされた項目は必須入力項目です';

  @override
  String get welcome_to_campus_navigator => 'ウソン大学キャンパスナビゲーターへようこそ';

  @override
  String get enter_real_name => '実名を入力してください';

  @override
  String get phone_format_hint => '010-1234-5678';

  @override
  String get enter_student_number => '学番または教番を入力してください';

  @override
  String get email_hint => 'example@woosong.org';

  @override
  String get create_account => 'アカウント作成';

  @override
  String get loading => '読み込み中...';

  @override
  String get error => 'エラー';

  @override
  String get success => '成功';

  @override
  String get validation_error => '入力値を確認してください';

  @override
  String get network_error => 'ネットワークエラーが発生しました';

  @override
  String get server_error => 'サーバーエラーが発生しました';

  @override
  String get unknown_error => '不明なエラーが発生しました';

  @override
  String get woosong_campus_guide_service => 'ウソン大学キャンパス案内サービス';

  @override
  String get register_description => '新しいアカウントを作成してすべての機能をご利用ください';

  @override
  String get login_description => '既存のアカウントでログインしてサービスをご利用ください';

  @override
  String get browse_as_guest => 'ゲストとして閲覧';

  @override
  String get processing => '処理中...';

  @override
  String get campus_navigator_version => 'Campus Navigator v1.0';

  @override
  String get guest_mode => 'ゲストモード';

  @override
  String get guest_mode_confirm =>
      'ゲストモードで入場しますか？\n\nゲストモードでは、友達機能と位置共有機能を使用できません。';

  @override
  String get app_name => 'タラウソン';

  @override
  String get welcome_to_ttarausong => 'タラウソンへようこそ';

  @override
  String get guest_mode_description =>
      'ゲストモードでは基本的なキャンパス情報のみ確認できます。\nすべての機能を利用するには会員登録後にログインしてください。';

  @override
  String get continue_as_guest => 'ゲストとして続行';

  @override
  String get moved_to_my_location => '私の位置に自動移動しました';

  @override
  String get friends_screen_bottom_sheet => '友達画面はボトムシートで表示されます';

  @override
  String get finding_current_location => '現在位置を探しています...';

  @override
  String get home => 'ホーム';

  @override
  String get timetable => '時間割';

  @override
  String get friends => '友達';

  @override
  String get finish => '完了';

  @override
  String get profile => 'プロフィール';

  @override
  String get inquiry => 'お問い合わせ';

  @override
  String get my_inquiry => '私のお問い合わせ';

  @override
  String get inquiry_type => 'お問い合わせタイプ';

  @override
  String get inquiry_type_required => 'お問い合わせタイプを選択してください';

  @override
  String get inquiry_type_select_hint => 'お問い合わせタイプを選択してください';

  @override
  String get inquiry_title => 'お問い合わせタイトル';

  @override
  String get inquiry_content => 'お問い合わせ内容';

  @override
  String get inquiry_content_hint => 'お問い合わせ内容を入力してください';

  @override
  String get inquiry_submit => 'お問い合わせ送信';

  @override
  String get inquiry_submit_success => 'お問い合わせが正常に送信されました';

  @override
  String get inquiry_submit_failed => 'お問い合わせ送信に失敗しました';

  @override
  String get no_inquiry_history => 'お問い合わせ履歴がありません';

  @override
  String get no_inquiry_history_hint => 'まだお問い合わせした履歴がありません';

  @override
  String get inquiry_delete => 'お問い合わせ削除';

  @override
  String get inquiry_delete_confirm => 'このお問い合わせを削除しますか？';

  @override
  String get inquiry_delete_success => 'お問い合わせが削除されました';

  @override
  String get inquiry_delete_failed => 'お問い合わせ削除に失敗しました';

  @override
  String get inquiry_detail => 'お問い合わせ詳細';

  @override
  String get inquiry_category => 'お問い合わせカテゴリ';

  @override
  String get inquiry_status => 'お問い合わせ状況';

  @override
  String get inquiry_created_at => 'お問い合わせ日時';

  @override
  String get inquiry_title_label => 'お問い合わせタイトル';

  @override
  String get inquiry_type_bug => 'バグ報告';

  @override
  String get inquiry_type_feature => '機能提案';

  @override
  String get inquiry_type_improvement => '改善提案';

  @override
  String get inquiry_type_other => 'その他のお問い合わせ';

  @override
  String get inquiry_status_pending => '回答待ち';

  @override
  String get inquiry_status_in_progress => '処理中';

  @override
  String get inquiry_status_answered => '回答完了';

  @override
  String get phone_required => '電話番号は必須です';

  @override
  String get building_info => '建物情報';

  @override
  String get directions => '道案内';

  @override
  String get floor_detail_view => '階層別詳細情報';

  @override
  String get no_floor_info => '階層情報がありません';

  @override
  String get floor_detail_info => '階層別詳細情報';

  @override
  String get search_start_location => '出発地検索';

  @override
  String get search_end_location => '目的地検索';

  @override
  String get unified_navigation_in_progress => '統合ナビゲーション進行中';

  @override
  String get unified_navigation => '統合ナビゲーション';

  @override
  String get recent_searches => '最近の検索';

  @override
  String get clear_all => 'すべてクリア';

  @override
  String get searching => '検索中...';

  @override
  String get try_different_keyword => '別のキーワードを試してください';

  @override
  String get enter_end_location => '目的地を入力してください';

  @override
  String get route_preview => 'ルートプレビュー';

  @override
  String get calculating_optimal_route => '最適ルート計算中...';

  @override
  String get set_departure_and_destination => '出発地と目的地を設定してください';

  @override
  String get start_unified_navigation => '統合ナビゲーション開始';

  @override
  String get departure_indoor => '出発地（屋内）';

  @override
  String get to_building_exit => '建物出口へ';

  @override
  String get outdoor_movement => '屋外移動';

  @override
  String get to_destination_building => '目的地建物へ';

  @override
  String get arrival_indoor => '到着地（屋内）';

  @override
  String get to_final_destination => '最終目的地へ';

  @override
  String get total_distance => '総距離';

  @override
  String get route_type => 'ルートタイプ';

  @override
  String get building_to_building => '建物間移動';

  @override
  String get room_to_building => '部屋から建物へ';

  @override
  String get building_to_room => '建物から部屋へ';

  @override
  String get room_to_room => '部屋間移動';

  @override
  String get location_to_building => '現在位置から建物へ';

  @override
  String get unified_route => '統合ルート';

  @override
  String get status_offline => 'オフライン';

  @override
  String get status_open => '営業中';

  @override
  String get status_closed => '営業終了';

  @override
  String get status_24hours => '24時間';

  @override
  String get status_temp_closed => '臨時休業';

  @override
  String get status_closed_permanently => '永久閉鎖';

  @override
  String get status_next_open => '午前9時に営業開始';

  @override
  String get status_next_close => '午後6時に営業終了';

  @override
  String get status_next_open_tomorrow => '明日午前9時に営業開始';

  @override
  String get set_start_point => '出発地設定';

  @override
  String get set_end_point => '目的地設定';

  @override
  String get scheduleDeleteTitle => 'スケジュール削除';

  @override
  String get scheduleDeleteSubtitle => '慎重に決定してください';

  @override
  String get scheduleDeleteLabel => '削除するスケジュール';

  @override
  String scheduleDeleteDescription(Object title) {
    return '「$title」の授業がスケジュールから削除されます。\n削除されたスケジュールは復元できません。';
  }

  @override
  String get cancelButton => 'キャンセル';

  @override
  String get deleteButton => '削除';

  @override
  String get overlap_message => 'この時間に既に登録された授業があります';

  @override
  String friendDeleteSuccessMessage(Object userName) {
    return '$userNameが友達リストから削除されました';
  }

  @override
  String get enterFriendIdPrompt => '追加する友達のIDを入力してください';

  @override
  String get friendId => '友達ID';

  @override
  String get enterFriendId => '友達ID入力';

  @override
  String get sendFriendRequest => '友達リクエスト送信';

  @override
  String get realTimeSyncActive => 'リアルタイム同期が有効 • 自動更新';

  @override
  String get noSentRequests => '送信した友達リクエストがありません';

  @override
  String newFriendRequests(int count) {
    return '$count件の新しい友達リクエスト';
  }

  @override
  String get noReceivedRequests => '受信した友達リクエストがありません';

  @override
  String get id => 'ID';

  @override
  String requestDate(String date) {
    return 'リクエスト日：$date';
  }

  @override
  String get newBadge => 'NEW';

  @override
  String get online => 'オンライン';

  @override
  String get offline => '오프라인';

  @override
  String get contact => '連絡先';

  @override
  String get noContactInfo => '連絡先情報がありません';

  @override
  String get friendOfflineError => '友達がオフライン状態です';

  @override
  String get removeLocation => '位置情報削除';

  @override
  String get showLocation => '位置情報表示';

  @override
  String friendLocationRemoved(String userName) {
    return '$userNameの位置情報が削除されました';
  }

  @override
  String friendLocationShown(String userName) {
    return '$userNameの位置情報が表示されました';
  }

  @override
  String get errorCannotRemoveLocation => '位置情報を削除できません';

  @override
  String get my_page => 'マイページ';

  @override
  String get calculating_route => 'ルート計算中...';

  @override
  String get finding_optimal_route => 'サーバーで最適ルートを検索中';

  @override
  String get clear_route => 'ルートクリア';

  @override
  String get location_permission_denied =>
      '位置情報の許可が拒否されました。\n設定で位置情報の許可を有効にしてください。';

  @override
  String get estimated_time => '予想時間';

  @override
  String get location_share_update_failed => '位置情報共有設定の更新に失敗しました';

  @override
  String get guest_location_share_success => 'ゲストモードではローカルのみで位置情報共有が設定されます';

  @override
  String get no_changes => '変更がありません';

  @override
  String get password_confirm_title => 'パスワード確認';

  @override
  String get password_confirm_subtitle => '会員情報修正のためにパスワードを入力してください';

  @override
  String get password_confirm_button => '確認';

  @override
  String get password_required => 'パスワードを入力してください';

  @override
  String get password_mismatch_confirm => 'パスワードが一致しません';

  @override
  String get profile_updated => 'プロフィールが修正されました';

  @override
  String get my_page_subtitle => 'マイ情報';

  @override
  String get excel_file => 'エクセルファイル';

  @override
  String get excel_file_tutorial => 'エクセルファイルの使い方';

  @override
  String get image_attachment => 'Image Attachment';

  @override
  String get max_one_image => '最大1枚';

  @override
  String get photo_attachment => '写真添付';

  @override
  String get photo_attachment_complete => '写真添付完了';

  @override
  String get image_selection => '画像選択';

  @override
  String get select_image_method => '画像選択方法';

  @override
  String get select_from_gallery => 'ギャラリーから選択';

  @override
  String get select_from_gallery_desc => 'ギャラリーから画像を選択します';

  @override
  String get select_from_file => 'ファイルから選択';

  @override
  String get select_from_file_desc => 'ファイルから画像を選択します';

  @override
  String get max_one_image_error => '画像は最大1枚のみ添付できます';

  @override
  String get image_selection_error => '画像選択中にエラーが発生しました';

  @override
  String get inquiry_error_occurred => 'お問い合わせ処理中にエラーが発生しました';

  @override
  String get inquiry_category_bug => 'バグ報告';

  @override
  String get inquiry_category_feature => '機能提案';

  @override
  String get inquiry_category_other => 'その他お問い合わせ';

  @override
  String get inquiry_category_route_error => 'ルート案内エラー';

  @override
  String get inquiry_category_place_error => '場所・情報エラー';

  @override
  String get schedule => '時間割';

  @override
  String get winter_semester => '冬学期';

  @override
  String get spring_semester => '春学期';

  @override
  String get summer_semester => '夏学期';

  @override
  String get fall_semester => '秋学期';

  @override
  String get monday => '月';

  @override
  String get tuesday => '火';

  @override
  String get wednesday => '水';

  @override
  String get thursday => '木';

  @override
  String get friday => '金';

  @override
  String get add_class => '授業追加';

  @override
  String get edit_class => '授業編集';

  @override
  String get delete_class => '授業削除';

  @override
  String get class_name => '授業名';

  @override
  String get classroom => '講義室';

  @override
  String get start_time => '開始時間';

  @override
  String get end_time => '終了時間';

  @override
  String get color_selection => '色選択';

  @override
  String get monday_full => '月曜日';

  @override
  String get tuesday_full => '火曜日';

  @override
  String get wednesday_full => '水曜日';

  @override
  String get thursday_full => '木曜日';

  @override
  String get friday_full => '金曜日';

  @override
  String get class_added => '授業が追加されました';

  @override
  String get class_updated => '授業が修正されました';

  @override
  String get class_deleted => '授業が削除されました';

  @override
  String delete_class_confirm(String className) {
    return '$classNameの授業を削除しますか？';
  }

  @override
  String get view_on_map => '地図で表示';

  @override
  String get location => '場所';

  @override
  String get schedule_time => '時間';

  @override
  String get schedule_day => '曜日';

  @override
  String get map_feature_coming_soon => '地図機能は近日提供予定です';

  @override
  String current_year(int year) {
    return '現在の年';
  }

  @override
  String get my_friends => 'マイ友達';

  @override
  String online_friends(int total, int online) {
    return 'オンライン友達';
  }

  @override
  String get add_friend => '友達追加';

  @override
  String get friend_name_or_id => '友達の名前またはID';

  @override
  String get friend_request_sent => '友達リクエストが送信されました';

  @override
  String get in_class => '授業中';

  @override
  String last_location(String location) {
    return '最後の場所';
  }

  @override
  String get central_library => '中央図書館';

  @override
  String get engineering_building => '工学館';

  @override
  String get student_center => '学生会館';

  @override
  String get cafeteria => 'Cafeteria';

  @override
  String get message => 'メッセージ';

  @override
  String get call => '電話';

  @override
  String start_chat_with(String name) {
    return 'チャット開始';
  }

  @override
  String view_location_on_map(String name) {
    return '地図で場所表示';
  }

  @override
  String calling(String name) {
    return '通話中';
  }

  @override
  String get delete => '削除';

  @override
  String get search => '検索';

  @override
  String get searchBuildings => '建物検索';

  @override
  String get myLocation => 'マイ場所';

  @override
  String get navigation => 'ナビゲーション';

  @override
  String get route => 'ルート';

  @override
  String get distance => '距離';

  @override
  String get minutes => '分';

  @override
  String get hours => '営業時間';

  @override
  String get within_minute => '1分以内';

  @override
  String minutes_only(Object minutes) {
    return '$minutes分';
  }

  @override
  String hours_only(Object hours) {
    return '$hours時間';
  }

  @override
  String hours_and_minutes(Object hours, Object minutes) {
    return '$hours時間$minutes分';
  }

  @override
  String get available => '利用可能';

  @override
  String get start_navigation_from_current_location => '現在地からルート検索を開始します';

  @override
  String get my_location_set_as_start => 'マイ場所が出発地として自動設定されました';

  @override
  String get default_location_set_as_start => 'デフォルト場所が出発地として設定されました';

  @override
  String get start_navigation => 'ルート検索開始';

  @override
  String get navigation_ended => 'ルート検索が終了しました';

  @override
  String get arrival => '到着';

  @override
  String get outdoor_movement_distance => '屋外移動距離';

  @override
  String get indoor_arrival => '屋内到着';

  @override
  String get indoor_departure => '屋内出発';

  @override
  String get complete => '完了';

  @override
  String get findRoute => 'ルート検索';

  @override
  String get clearRoute => 'ルートクリア';

  @override
  String get setAsStart => '出発地として設定';

  @override
  String get setAsDestination => '目的地として設定';

  @override
  String get navigateFromHere => 'ここからナビゲーション';

  @override
  String get buildingInfo => '建物情報';

  @override
  String get locationPermissionRequired => '位置情報の許可が必要です';

  @override
  String get enableLocationServices => '位置情報サービスを有効にしてください';

  @override
  String get noResults => '結果がありません';

  @override
  String get settings => '設定';

  @override
  String get language => '言語';

  @override
  String get about => '情報';

  @override
  String friends_count_status(int total, int online) {
    return '友達数状態';
  }

  @override
  String get enter_friend_info => '友達情報入力';

  @override
  String show_location_on_map(String name) {
    return '地図で場所表示';
  }

  @override
  String get location_error => '場所エラー';

  @override
  String get view_floor_plan => '図面表示';

  @override
  String floor_plan_title(String buildingName) {
    return '図面';
  }

  @override
  String get floor_plan_not_available => '図面を利用できません';

  @override
  String get floor_plan_default_text => '図面デフォルトテキスト';

  @override
  String get delete_account_success => 'アカウントが正常に削除されました';

  @override
  String get convenience_store => 'コンビニ';

  @override
  String get vending_machine => '自動販売機';

  @override
  String get printer => 'プリンター';

  @override
  String get copier => 'コピー機';

  @override
  String get atm => 'ATM';

  @override
  String get bank_atm => '銀行(ATM)';

  @override
  String get medical => '医療';

  @override
  String get health_center => '保健所';

  @override
  String get gym => '体育館';

  @override
  String get fitness_center => 'ジム';

  @override
  String get lounge => 'ラウンジ';

  @override
  String get extinguisher => '消火器';

  @override
  String get water_purifier => '浄水器';

  @override
  String get bookstore => '書店';

  @override
  String get post_office => '郵便局';

  @override
  String instructionMoveToDestination(String place) {
    return '目的地に移動してください';
  }

  @override
  String get markerDeparture => '出発地';

  @override
  String get markerArrival => '到着地';

  @override
  String get errorCannotOpenPhoneApp => '電話アプリを開けません';

  @override
  String get emailCopied => 'メールアドレスがコピーされました';

  @override
  String get description => '説明';

  @override
  String get noDetailedInfoRegistered => '登録された詳細情報がありません';

  @override
  String get setDeparture => '出発地設定';

  @override
  String get setArrival => '到着地設定';

  @override
  String errorOccurred(Object error) {
    return 'エラーが発生しました：$error';
  }

  @override
  String get instructionExitToOutdoor => '屋外に出てください';

  @override
  String instructionMoveToDestinationBuilding(String building) {
    return '目的地の建物に移動してください';
  }

  @override
  String get instructionMoveToRoom => '部屋に移動してください';

  @override
  String get instructionArrived => '到着しました';

  @override
  String get no => 'いいえ';

  @override
  String get woosong_library_w1 => 'ウソン図書館 (W1)';

  @override
  String get woosong_library_info =>
      'B2F\t駐車場\nB1F\t小講堂、機械室、電気室、駐車場\n1F\t就職支援センター (630-9976)、貸出カウンター、情報休憩室\n2F\t一般閲覧室、グループスタディルーム\n3F\t一般閲覧室\n4F\t文学図書/西洋図書';

  @override
  String get educational_facility => 'Educational Facility';

  @override
  String get operating => 'Operating';

  @override
  String get woosong_library_desc => 'ウソン大学中央図書館';

  @override
  String get sol_cafe => 'ソルカフェ';

  @override
  String get sol_cafe_info => '1F\t食堂\n2F\tカフェ';

  @override
  String get cafe => 'カフェ';

  @override
  String get sol_cafe_desc => 'キャンパス内カフェ';

  @override
  String get cheongun_1_dormitory => 'チョングン1寮';

  @override
  String get cheongun_1_dormitory_info =>
      '1F\t実習室\n2F\t学生食堂\n2F\tチョングン1寮(女子) (629-6542)\n2F\t生活館\n3~5F\t生活館';

  @override
  String get dormitory => '寮';

  @override
  String get cheongun_1_dormitory_desc => '女子学生寮';

  @override
  String get industry_cooperation_w2 => '産学協力団 (W2)';

  @override
  String get industry_cooperation_info =>
      '1F\t産学協力団\n2F\t建築工学科 (630-9720)\n3F\tウソン大学融合技術研究所、産学研総合企業支援センター\n4F\t企業附設研究所、LG CNS教室、鉄道デジタルアカデミー教室';

  @override
  String get industry_cooperation_desc => '産学協力・研究施設';

  @override
  String get rotc_w2_1 => '学軍団 (W2-1)';

  @override
  String get rotc_info => '\t学軍団 (630-4601)';

  @override
  String get rotc_desc => '学軍団施設';

  @override
  String get military_facility => '軍事施設';

  @override
  String get international_dormitory_w3 => '留学生寮 (W3)';

  @override
  String get international_dormitory_info =>
      '1F\t留学生支援チーム (629-6623)\n1F\t学生食堂\n2F\t留学生寮 (629-6655)\n2F\t保健室\n3~12F\t生活館';

  @override
  String get international_dormitory_desc => '留学生専用寮';

  @override
  String get railway_logistics_w4 => '鉄道物流館 (W4)';

  @override
  String get railway_logistics_info =>
      'B1F\t実習室\n1F\t実習室\n2F\t鉄道建設システム学部 (629-6710)\n2F\t鉄道車両システム学科 (629-6780)\n3F\t教室/実習室\n4F\t鉄道システム学部 (630-6730,9700)\n5F\t消防防災学科 (629-6770)\n5F\t物流システム学科 (630-9330)';

  @override
  String get railway_logistics_desc => '鉄道・物流関連学科';

  @override
  String get health_medical_science_w5 => '保健医療科学館 (W5)';

  @override
  String get health_medical_science_info =>
      'B1F\t駐車場\n1F\t視聴覚室/駐車場\n2F\t教室\n2F\t運動健康リハビリ学科 (630-9840)\n3F\t応急救助学科 (630-9280)\n3F\t看護学科 (630-9290)\n4F\t作業療法学科 (630-9820)\n4F\t言語療法聴覚リハビリ学科 (630-9220)\n5F\t物理療法学科 (630-4620)\n5F\t保健医療経営学科 (630-4610)\n5F\t教室\n6F\t鉄道経営学科 (630-9770)';

  @override
  String get health_medical_science_desc => '保健医療関連学科';

  @override
  String get liberal_arts_w6 => '教養教育館 (W6)';

  @override
  String get liberal_arts_info => '2F\t教室\n3F\t教室\n4F\t教室\n5F\t教室';

  @override
  String get liberal_arts_desc => '教養教室';

  @override
  String get woosong_hall_w7 => 'ウソン館 (W7)';

  @override
  String get woosong_hall_info =>
      '1F\t入学処 (630-9627)\n1F\t教務処 (630-9622)\n1F\t施設処 (630-9970)\n1F\t管理チーム (629-6658)\n1F\t産学協力団 (630-4653)\n1F\t対外協力処 (630-9636)\n2F\t戦略企画処 (630-9102)\n2F\t総務処-総務、購買 (630-9653)\n2F\t企画処 (630-9661)\n3F\t総長室 (630-8501)\n3F\t国際交流処 (630-9373)\n3F\t幼児教育学科 (630-9360)\n3F\t経営学専攻 (629-6640)\n3F\t金融/不動産学専攻 (630-9350)\n4F\t大会議室\n5F\t会議室';

  @override
  String get woosong_hall_desc => '大学本部建物';

  @override
  String get woosong_kindergarten_w8 => 'ウソン幼稚園 (W8)';

  @override
  String get woosong_kindergarten_info => '1F, 2F\tウソン幼稚園 (629~6750~1)';

  @override
  String get woosong_kindergarten_desc => '大学附属幼稚園';

  @override
  String get kindergarten => '幼稚園';

  @override
  String get west_campus_culinary_w9 => '西キャンパス調理学院 (W9)';

  @override
  String get west_campus_culinary_info => 'B1F\t実習室\n1F\t実習室\n2F\t実習室';

  @override
  String get west_campus_culinary_desc => '調理実習施設';

  @override
  String get social_welfare_w10 => '社会福祉融合館 (W10)';

  @override
  String get social_welfare_info =>
      '1F\t視聴覚室/実習室\n2F\t教室/実習室\n3F\t社会福祉学科 (630-9830)\n3F\tグローバル児童教育学科 (630-9260)\n4F\t教室/実習室\n5F\t教室/実習室';

  @override
  String get social_welfare_desc => '社会福祉関連学科';

  @override
  String get gymnasium_w11 => '体育館 (W11)';

  @override
  String get gymnasium_info => '1F\t体力鍛錬室\n2F~4F\t体育館';

  @override
  String get gymnasium_desc => '体育施設';

  @override
  String get sports_facility => '体育施設';

  @override
  String get sica_w12 => 'SICA (W12)';

  @override
  String get sica_info =>
      'B1F\t実習室\n1F\tスタリコカフェ\n2F~3F\t教室\n5F\tグローバル調理学部 (629-6860)';

  @override
  String get sica_desc => '国際調理学院';

  @override
  String get woosong_tower_w13 => 'ウソンタワー (W13)';

  @override
  String get woosong_tower_info =>
      'B1~1F\t駐車場\n2F\t駐車場、ソルパインベーカリー (629-6429)\n4F\tセミナー室\n5F\t教室\n6F\t外食調理栄養学科 (630-9380,9740)\n7F\t教室\n8F\t外食・調理経営専攻 (630-9250)\n9F\t教室/実習室\n10F\t外食調理専攻 (629-6821)、グローバル韓食調理専攻 (629-6560)\n11F, 12F\t実習室\n13F\tソルパインレストラン (629-6610)';

  @override
  String get woosong_tower_desc => '総合教育施設';

  @override
  String get complex_facility => '総合施設';

  @override
  String get culinary_center_w14 => '調理センター (W14)';

  @override
  String get culinary_center_info =>
      '1F\t教室/実習室\n2F\t教室/実習室\n3F\t教室/実습실\n4F\t教室/実習室\n5F\t教室/実習室';

  @override
  String get culinary_center_desc => '調理専攻教育施設';

  @override
  String get food_architecture_w15 => '食品建築館 (W15)';

  @override
  String get food_architecture_info =>
      'B1F\t実習室\n1F\t実習室\n2F\t教室\n3F\t教室\n4F\t教室\n5F\t教室';

  @override
  String get food_architecture_desc => '食品・建築関連学科';

  @override
  String get student_hall_w16 => '学生会館 (W16)';

  @override
  String get student_hall_info =>
      '1F\t学生食堂、校内書店 (629-6127)\n2F\t教職員食堂\n3F\tサークル室\n3F\t学生福祉処-学生チーム (630-9641)、奨学チーム (630-9876)\n3F\t障害学生支援センター (630-9903)\n3F\t社会奉仕団 (630-9904)\n3F\t学生相談センター (630-9645)\n4F\t復学支援センター (630-9139)\n4F\t教授学習開発センター (630-9285)';

  @override
  String get student_hall_desc => '学生福祉施設';

  @override
  String get media_convergence_w17 => 'メディア融合館 (W17)';

  @override
  String get media_convergence_info =>
      'B1F\t教室/実習室\n1F\tメディアデザイン/映像専攻 (630-9750)\n2F\t教室/実習室\n3F\tゲームマルチメディア専攻 (630-9270)\n5F\t教室/実習室';

  @override
  String get media_convergence_desc => 'メディア関連学科';

  @override
  String get woosong_arts_center_w18 => 'ウソン芸術会館 (W18)';

  @override
  String get woosong_arts_center_info =>
      'B1F\t公演準備室\n1F\tウソン芸術会館 (629-6363)\n2F\t実習室\n3F\t実習室\n4F\t実習室\n5F\t実習室';

  @override
  String get woosong_arts_center_desc => '芸術公演施設';

  @override
  String get west_campus_andycut_w19 => '西キャンパスアンディカット建物 (W19)';

  @override
  String get west_campus_andycut_info =>
      '2F\tグローバル融合ビジネス学科 (630-9249)\n2F\t自由専攻学部 (630-9390)\n2F\tAI/ビッグデータ学科 (630-9807)\n2F\tグローバルホテル経営学科 (630-9249)\n2F\tグローバルメディア映像学科 (630-9346)\n2F\tグローバル医療サービス経営学科 (630-9283)\n2F\tグローバル鉄道/交通物流学部 (630-9347)\n2F\tグローバル外食創業学科 (629-6860)';

  @override
  String get west_campus_andycut_desc => 'グローバル学科建物';

  @override
  String get search_campus_buildings => 'キャンパス建物検索';

  @override
  String get building_details => '詳細情報';

  @override
  String get parking => '駐車場';

  @override
  String get accessibility => '便利施設';

  @override
  String get facilities => '施設';

  @override
  String get elevator => 'エレベーター';

  @override
  String get restroom => 'トイレ';

  @override
  String get navigate_from_current_location => '現在地からナビゲーション';

  @override
  String get edit_profile => 'プロフィール編集';

  @override
  String get nameRequired => '名前を入力してください';

  @override
  String get emailRequired => 'メールアドレスを入力してください';

  @override
  String get save => '保存';

  @override
  String get saveSuccess => 'プロフィールが更新されました';

  @override
  String get app_info => 'アプリ情報';

  @override
  String get app_version => 'アプリバージョン';

  @override
  String get developer => '開発者';

  @override
  String get developer_name =>
      'チームメンバー：チョン・ジニョン、パク・チョルヒョン、チョ・ヒョンジュン、チェ・ソンヨル、ハン・スンホン、イ・イェウン';

  @override
  String get developer_email => 'メール：wsumap41@gmail.com';

  @override
  String get developer_github => 'GitHub：github.com/WSU-YJB/WSUMAP';

  @override
  String get no_help_images => 'ヘルプ画像がありません';

  @override
  String get description_hint => '説明を入力してください';

  @override
  String get my_info => 'マイ情報';

  @override
  String get guest_user => 'ゲストユーザー';

  @override
  String get guest_role => 'ゲスト役割';

  @override
  String get user => 'ユーザー';

  @override
  String get edit_profile_subtitle => '個人情報を修正できます';

  @override
  String get help_subtitle => 'アプリの使い方を確認してください';

  @override
  String get app_info_subtitle => 'バージョン情報・開発者情報';

  @override
  String get delete_account_subtitle => 'アカウントを永続的に削除します';

  @override
  String get login_message => 'ログインまたは会員登録\nすべての機能を使用するには';

  @override
  String get login_signup => 'ログイン / 会員登録';

  @override
  String get delete_account_confirm => 'アカウント削除';

  @override
  String get delete_account_message => 'アカウントを削除しますか？';

  @override
  String get logout_confirm => 'ログアウト';

  @override
  String get logout_message => 'ログアウトしますか？';

  @override
  String get yes => 'はい';

  @override
  String get feature_in_progress => '機能開発中';

  @override
  String get delete_feature_in_progress => 'アカウント削除機能は開発中です';

  @override
  String get title => 'プロフィール編集';

  @override
  String get email_required => 'メールアドレスを入力してください';

  @override
  String get name_required => '名前を入力してください';

  @override
  String get cancelFriendRequest => '友達リクエストキャンセル';

  @override
  String cancelFriendRequestConfirm(String name) {
    return '$nameに送信した友達リクエストをキャンセルしますか？';
  }

  @override
  String get attached_image => '添付画像';

  @override
  String get answer_section_title => '回答';

  @override
  String get inquiry_default_answer =>
      'お問い合わせいただいた内容への回答です。追加のご質問がございましたら、いつでもお気軽にお問い合わせください。';

  @override
  String get answer_date_prefix => '回答日：';

  @override
  String get waiting_answer_status => '回答待ち';

  @override
  String get waiting_answer_message => 'お問い合わせいただいた内容を確認中です。できるだけ早く回答いたします。';

  @override
  String get status_pending => '回答待ち';

  @override
  String get status_answered => '回答完了';

  @override
  String get cancelRequest => 'リクエストキャンセル';

  @override
  String get friendDeleteTitle => '友達削除';

  @override
  String get friendDeleteWarning => 'この操作は元に戻せません';

  @override
  String get friendDeleteHeader => '友達削除';

  @override
  String get friendDeleteToConfirm => '削除する友達の名前を入力してください';

  @override
  String get friendDeleteCancel => 'キャンセル';

  @override
  String get friendDeleteButton => '削除';

  @override
  String get friendManagementAndRequests => '友達管理・リクエスト';

  @override
  String get realTimeSyncStatus => 'リアルタイム同期状態';

  @override
  String get friendManagement => '友達管理';

  @override
  String get add => '追加';

  @override
  String sentRequestsCount(int count) {
    return '送信リクエスト ($count)';
  }

  @override
  String receivedRequestsCount(int count) {
    return '受信リクエスト ($count)';
  }

  @override
  String friendCount(int count) {
    return 'マイ友達 ($count)';
  }

  @override
  String get noFriends => 'まだ友達がいません。\n上の+ボタンを押して友達を追加してみてください！';

  @override
  String get open_settings => '設定を開く';

  @override
  String get retry => '再試行';

  @override
  String get basic_info => '基本情報';

  @override
  String get status => '状態';

  @override
  String get floor_plan => '図面';

  @override
  String get indoorMap => '内部図面';

  @override
  String get showBuildingMarker => '建物マーカー表示';

  @override
  String get search_hint => 'キャンパス建物検索';

  @override
  String get searchHint => '建物や部屋で検索';

  @override
  String get searchInitialGuide => '建物や部屋を検索してください';

  @override
  String get searchHintExample => '例：W19、工学館、401室';

  @override
  String get searchLoading => '検索中...';

  @override
  String get searchNoResult => '検索結果がありません';

  @override
  String get searchTryAgain => '別のキーワードを試してください';

  @override
  String get required => '必須';

  @override
  String get enter_title => 'タイトル入力';

  @override
  String get content => '内容';

  @override
  String get enter_content => '内容入力';

  @override
  String get restaurant => 'レストラン';

  @override
  String get privacy_policy => 'Privacy Policy';

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
  String get search_error => 'Search Error';

  @override
  String get search_initial_guide => 'Search for a building or room';

  @override
  String get search_hint_example => 'e.g. W19, Engineering Hall, Room 401';

  @override
  String get search_loading => 'Searching...';

  @override
  String get search_no_result => 'No search results found';

  @override
  String get search_try_again => 'Try a different search term';

  @override
  String get library => '図書館';

  @override
  String get setting => '設定';

  @override
  String location_setting_confirm(String buildingName, String locationType) {
    return '$locationTypeとして設定しますか？';
  }

  @override
  String get set_room => '部屋設定';

  @override
  String friend_location_permission_denied(String name) {
    return '$nameが位置情報共有を許可していません';
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
  String get info => '情報';
}
