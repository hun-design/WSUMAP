// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Следуй за Усунгом';

  @override
  String get subtitle => 'Умный гид по кампусу';

  @override
  String get woosong => 'Усунг';

  @override
  String get start => 'Начать';

  @override
  String get login => 'Войти';

  @override
  String get logout => 'Выйти';

  @override
  String get guest => 'Гость';

  @override
  String get student_professor => 'Студент/Профессор';

  @override
  String get admin => 'Администратор';

  @override
  String get student => 'Студент';

  @override
  String get professor => 'Профессор';

  @override
  String get external_user => 'Внешний пользователь';

  @override
  String get username => 'Имя пользователя';

  @override
  String get password => 'Пароль';

  @override
  String get confirm_password => 'Подтвердить пароль';

  @override
  String get remember_me => 'Запомнить данные для входа';

  @override
  String get remember_me_description =>
      'В следующий раз вы автоматически войдете в систему';

  @override
  String get login_as_guest => 'Просмотр как гость';

  @override
  String get login_failed => 'Ошибка входа';

  @override
  String get login_success => 'Успешный вход';

  @override
  String get logout_success => 'Успешный выход';

  @override
  String get enter_username => 'Пожалуйста, введите имя пользователя';

  @override
  String get enter_password => 'Пожалуйста, введите пароль';

  @override
  String get password_hint => 'Введите не менее 6 символов';

  @override
  String get confirm_password_hint => 'Пожалуйста, введите пароль еще раз';

  @override
  String get username_password_required =>
      'Пожалуйста, введите имя пользователя и пароль';

  @override
  String get login_error => 'Ошибка входа в систему';

  @override
  String get find_password => 'Найти пароль';

  @override
  String get find_username => 'Найти имя пользователя';

  @override
  String get back => 'Назад';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get cancel => 'Отмена';

  @override
  String get coming_soon => 'Скоро';

  @override
  String feature_coming_soon(String feature) {
    return 'Функция $feature скоро будет доступна.\nОна будет добавлена в ближайшее время.';
  }

  @override
  String get departurePoint => 'Отправление';

  @override
  String get arrivalPoint => 'Точка прибытия';

  @override
  String get all => 'Все';

  @override
  String get tutorial => 'Руководство';

  @override
  String get tutorialTitleIntro => 'Как использовать Следуй за Усунгом';

  @override
  String get tutorialDescIntro =>
      'Сделайте жизнь в кампусе более удобной\nс помощью Навигатора кампуса Университета Усунг';

  @override
  String get tutorialTitleSearch => 'Детальная функция поиска';

  @override
  String get tutorialDescSearch =>
      'В Университете Усунг можно искать не только здания, но и аудитории!\nИщите детально от местоположения аудитории до удобств 😊';

  @override
  String get tutorialTitleSchedule => 'Интеграция расписания';

  @override
  String get tutorialDescSchedule =>
      'Интегрируйте расписание занятий в приложение и\nавтоматически получайте оптимальный маршрут до следующего занятия';

  @override
  String get tutorialTitleDirections => 'Навигация';

  @override
  String get tutorialDescDirections =>
      'Легко и быстро добирайтесь до места назначения\nс точным руководством по маршруту в кампусе';

  @override
  String get tutorialTitleIndoorMap => 'План внутренних помещений здания';

  @override
  String get tutorialDescIndoorMap =>
      'Легко находите аудитории и удобства\nс детальными планами внутренних помещений здания';

  @override
  String get dontShowAgain => 'Больше не показывать';

  @override
  String get goBack => 'Вернуться';

  @override
  String get lectureRoom => 'Аудитория';

  @override
  String get lectureRoomInfo => 'Информация об аудитории';

  @override
  String get floor => 'Этаж';

  @override
  String get personInCharge => 'Ответственное лицо';

  @override
  String get viewLectureRoom => 'Посмотреть аудиторию';

  @override
  String get viewBuilding => 'Посмотреть здание';

  @override
  String get walk => 'Пешком';

  @override
  String get minute => 'мин';

  @override
  String get hour => 'ч';

  @override
  String get less_than_one_minute => 'Менее 1 мин';

  @override
  String get zero_minutes => '0 мин';

  @override
  String get calculation_failed => 'Расчет невозможен';

  @override
  String get professor_name => 'Имя профессора';

  @override
  String get building_name => 'Название здания';

  @override
  String floor_number(Object floor) {
    return '$floor этаж';
  }

  @override
  String get room_name => 'Номер комнаты';

  @override
  String get day_of_week => 'День недели';

  @override
  String get time => 'Время';

  @override
  String get memo => 'Заметка';

  @override
  String get recommend_route => 'Рекомендуемый маршрут';

  @override
  String get view_location => 'Посмотреть местоположение';

  @override
  String get edit => 'Редактировать';

  @override
  String get close => 'Закрыть';

  @override
  String get help => 'Как использовать';

  @override
  String get help_intro_title => 'Как использовать Следуй за Усунгом';

  @override
  String get help_intro_description =>
      'Сделайте жизнь в кампусе более удобной\nс помощью Навигатора кампуса Университета Усунг';

  @override
  String get help_detailed_search_title => 'Детальный поиск';

  @override
  String get help_detailed_search_description =>
      'Найдите нужное место с помощью точного и быстрого поиска\nвключая названия зданий, номера аудиторий и удобства';

  @override
  String get help_timetable_title => 'Интеграция расписания';

  @override
  String get help_timetable_description =>
      'Интегрируйте расписание занятий в приложение и\nавтоматически получайте оптимальный маршрут до следующего занятия';

  @override
  String get help_directions_title => 'Навигация';

  @override
  String get help_directions_description =>
      'Легко и быстро добирайтесь до места назначения\nс точным руководством по маршруту в кампусе';

  @override
  String get help_building_map_title => 'План внутренних помещений здания';

  @override
  String get help_building_map_description =>
      'Легко находите аудитории и удобства\nс детальными планами внутренних помещений здания';

  @override
  String get previous => 'Предыдущий';

  @override
  String get next => 'Следующий';

  @override
  String get done => 'Готово';

  @override
  String get image_load_error => 'Не удается загрузить изображение';

  @override
  String get start_campus_exploration => 'Начните исследовать кампус!';

  @override
  String get woosong_university => 'Университет Усунг';

  @override
  String get excel_upload_title => 'Загрузка файла Excel с расписанием';

  @override
  String get excel_upload_description =>
      'Пожалуйста, выберите файл Excel с расписанием (.xlsx) Университета Усунг';

  @override
  String get excel_file_select => 'Выбрать файл Excel';

  @override
  String get excel_upload_uploading => 'Загружаю файл Excel...';

  @override
  String get language_selection => 'Выбор языка';

  @override
  String get language_selection_description =>
      'Пожалуйста, выберите предпочитаемый язык';

  @override
  String get departure => 'Отправление';

  @override
  String get destination => 'Назначение';

  @override
  String get my_location => 'Мое местоположение';

  @override
  String get current_location => 'Текущее местоположение';

  @override
  String get welcome_subtitle_1 => 'Следуй за Вусунгом в своих руках,';

  @override
  String get welcome_subtitle_2 => 'Вся информация о зданиях здесь!';

  @override
  String get select_language => 'Выбрать язык';

  @override
  String get auth_selection_title => 'Выбор метода аутентификации';

  @override
  String get auth_selection_subtitle =>
      'Пожалуйста, выберите предпочитаемый метод входа';

  @override
  String get select_auth_method => 'Выбор метода аутентификации';

  @override
  String total_floors(Object count) {
    return 'Всего $count этажей';
  }

  @override
  String get floor_info => 'Информация об этажах';

  @override
  String floor_with_category(Object category) {
    return 'Этаж с $category';
  }

  @override
  String get floor_label => 'Этаж';

  @override
  String get category => 'Категория';

  @override
  String get excel_upload_success => 'Загрузка завершена!';

  @override
  String get guest_timetable_disabled =>
      'Гостевые пользователи не могут использовать функцию расписания.';

  @override
  String get guest_timetable_add_disabled =>
      'Гостевые пользователи не могут добавлять расписания.';

  @override
  String get guest_timetable_edit_disabled =>
      'Гостевые пользователи не могут редактировать расписания.';

  @override
  String get guest_timetable_delete_disabled =>
      'Гостевые пользователи не могут удалять расписания.';

  @override
  String get timetable_load_failed => 'Не удалось загрузить расписание.';

  @override
  String get timetable_add_success => 'Расписание успешно добавлено.';

  @override
  String timetable_add_failed(Object error) {
    return 'Не удалось добавить расписание';
  }

  @override
  String get timetable_overlap =>
      'Уже есть занятие, зарегистрированное в то же время.';

  @override
  String get required_fields_missing =>
      'Пожалуйста, заполните все обязательные поля.';

  @override
  String get no_search_results => 'Результатов поиска нет';

  @override
  String get excel_upload_refreshing => 'Обновляю расписание...';

  @override
  String get logout_processing => 'Выход из системы...';

  @override
  String get logout_error_message =>
      'Произошла ошибка при выходе из системы, но переход на начальный экран.';

  @override
  String get data_to_be_deleted => 'Данные для удаления';

  @override
  String get deleting_account => 'Удаление аккаунта...';

  @override
  String get excel_tutorial_title => 'Как скачать файл Excel';

  @override
  String get edit_profile_section => 'Редактировать профиль';

  @override
  String get delete_account_section => 'Удалить аккаунт';

  @override
  String get logout_section => 'Выйти';

  @override
  String get location_share_title => 'Поделиться местоположением';

  @override
  String get location_share_enabled => 'Поделиться местоположением включено';

  @override
  String get location_share_disabled => 'Поделиться местоположением отключено';

  @override
  String get excel_tutorial_previous => 'Предыдущий';

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
  String get current_location_departure =>
      'Отправление с текущего местоположения';

  @override
  String get current_location_departure_default =>
      'Отправление с текущего местоположения (местоположение по умолчанию)';

  @override
  String get current_location_navigation_start =>
      'Start navigation from current location';

  @override
  String get excel_tutorial_next => 'Следующий';

  @override
  String get profile_edit_title => 'Редактировать профиль';

  @override
  String get profile_edit_subtitle => 'Вы можете изменить личную информацию';

  @override
  String get account_delete_title => 'Удалить аккаунт';

  @override
  String get account_delete_subtitle => 'Навсегда удалить ваш аккаунт';

  @override
  String get logout_title => 'Выйти';

  @override
  String get logout_subtitle => 'Выйти из текущего аккаунта';

  @override
  String get location_share_enabled_success =>
      'Поделиться местоположением включено';

  @override
  String get location_share_disabled_success =>
      'Поделиться местоположением отключено';

  @override
  String get profile_edit_error =>
      'Произошла ошибка при редактировании профиля';

  @override
  String get inquiry_load_failed => 'Не удалось загрузить список запросов';

  @override
  String get pull_to_refresh => 'Потяните вниз для обновления';

  @override
  String get app_version_number => 'v1.0.0';

  @override
  String get developer_email_address => 'wsumap41@gmail.com';

  @override
  String get developer_github_url => 'https://github.com/WSU-YJB/WSUMAP';

  @override
  String get friend_management => 'Управление друзьями';

  @override
  String get excel_tutorial_file_select => 'Выбрать файл';

  @override
  String get excel_tutorial_help => 'Посмотреть инструкцию';

  @override
  String get excel_upload_file_cancelled => 'Выбор файла был отменен.';

  @override
  String get excel_upload_success_message => 'Расписание обновлено!';

  @override
  String excel_upload_refresh_failed(String error) {
    return 'Ошибка обновления: $error';
  }

  @override
  String excel_upload_failed(String error) {
    return 'Ошибка загрузки: $error';
  }

  @override
  String get excel_tutorial_step_1 =>
      '1. Войдите в систему информации университета Усунг';

  @override
  String get excel_tutorial_url => 'https://wsinfo.wsu.ac.kr';

  @override
  String get excel_tutorial_image_load_error =>
      'Не удается загрузить изображение';

  @override
  String get excel_tutorial_unknown_page => 'Неизвестная страница';

  @override
  String get campus_navigator => 'Навигатор кампуса';

  @override
  String get user_info_not_found =>
      'Не удалось найти информацию о пользователе в ответе на вход';

  @override
  String get unexpected_login_error =>
      'Произошла неожиданная ошибка во время входа';

  @override
  String get login_required => 'Требуется вход в систему';

  @override
  String get register => 'Регистрация';

  @override
  String get register_success => 'Регистрация завершена';

  @override
  String get register_success_message =>
      'Регистрация завершена!\nПеренаправление на экран входа.';

  @override
  String get register_error =>
      'Произошла неожиданная ошибка во время регистрации';

  @override
  String get update_user_info => 'Обновить информацию пользователя';

  @override
  String get update_success => 'Информация пользователя обновлена';

  @override
  String get update_error =>
      'Произошла неожиданная ошибка при обновлении информации пользователя';

  @override
  String get delete_account => 'Удалить аккаунт';

  @override
  String get delete_success => 'Удаление аккаунта завершено';

  @override
  String get delete_error =>
      'Произошла неожиданная ошибка при удалении аккаунта';

  @override
  String get name => 'Имя';

  @override
  String get phone => 'Телефон';

  @override
  String get email => 'Электронная почта';

  @override
  String get student_number => 'Номер студента';

  @override
  String get user_type => 'Тип пользователя';

  @override
  String get optional => 'Необязательно';

  @override
  String get required_fields_empty =>
      'Пожалуйста, заполните все обязательные поля';

  @override
  String get password_mismatch => 'Пароли не совпадают';

  @override
  String get password_too_short =>
      'Пароль должен содержать не менее 6 символов';

  @override
  String get invalid_phone_format =>
      'Пожалуйста, введите правильный формат телефона (например: 010-1234-5678)';

  @override
  String get invalid_email_format =>
      'Пожалуйста, введите правильный формат электронной почты';

  @override
  String get required_fields_notice =>
      '* Поля, отмеченные звездочкой, являются обязательными';

  @override
  String get welcome_to_campus_navigator =>
      'Добро пожаловать в навигатор кампуса Усунг';

  @override
  String get enter_real_name => 'Пожалуйста, введите ваше настоящее имя';

  @override
  String get phone_format_hint => '010-1234-5678';

  @override
  String get enter_student_number =>
      'Пожалуйста, введите номер студента или преподавателя';

  @override
  String get email_hint => 'example@woosong.org';

  @override
  String get create_account => 'Создать аккаунт';

  @override
  String get loading => 'Загрузка...';

  @override
  String get error => 'Ошибка';

  @override
  String get success => 'Успех';

  @override
  String get validation_error => 'Пожалуйста, проверьте ваш ввод';

  @override
  String get network_error => 'Произошла сетевая ошибка';

  @override
  String get server_error => 'Произошла ошибка сервера';

  @override
  String get unknown_error => 'Произошла неизвестная ошибка';

  @override
  String get woosong_campus_guide_service =>
      'Сервис навигации по кампусу Университета Усунг';

  @override
  String get register_description =>
      'Создайте новую учетную запись для использования всех функций';

  @override
  String get login_description =>
      'Войдите в систему с существующей учетной записью для использования сервиса';

  @override
  String get browse_as_guest => 'Просмотр как гость';

  @override
  String get processing => 'Обработка...';

  @override
  String get campus_navigator_version => 'Campus Navigator v1.0';

  @override
  String get guest_mode => 'Гостевой режим';

  @override
  String get guest_mode_confirm =>
      'Хотите войти в гостевом режиме?\n\nВ гостевом режиме вы не можете использовать функции друзей и делиться местоположением.';

  @override
  String get app_name => 'Ттараусонг';

  @override
  String get welcome_to_ttarausong => 'Добро пожаловать в Ттараусонг';

  @override
  String get guest_mode_description =>
      'В гостевом режиме вы можете просматривать только основную информацию о кампусе.\nДля использования всех функций, пожалуйста, зарегистрируйтесь и войдите в систему.';

  @override
  String get continue_as_guest => 'Продолжить как гость';

  @override
  String get moved_to_my_location =>
      'Автоматически перемещено в мое местоположение';

  @override
  String get friends_screen_bottom_sheet =>
      'Экран друзей отображается как нижний лист';

  @override
  String get finding_current_location => 'Поиск текущего местоположения...';

  @override
  String get home => 'Главная';

  @override
  String get timetable => 'Расписание';

  @override
  String get friends => 'Друзья';

  @override
  String get finish => 'Завершить';

  @override
  String get profile => 'Профиль';

  @override
  String get inquiry => 'Запросы';

  @override
  String get my_inquiry => 'Мои запросы';

  @override
  String get inquiry_type => 'Тип запроса';

  @override
  String get inquiry_type_required => 'Пожалуйста, выберите тип запроса';

  @override
  String get inquiry_type_select_hint => 'Выберите тип запроса';

  @override
  String get inquiry_title => 'Заголовок запроса';

  @override
  String get inquiry_content => 'Содержание запроса';

  @override
  String get inquiry_content_hint => 'Пожалуйста, введите содержание запроса';

  @override
  String get inquiry_submit => 'Отправить запрос';

  @override
  String get inquiry_submit_success => 'Запрос успешно отправлен';

  @override
  String get inquiry_submit_failed => 'Не удалось отправить запрос';

  @override
  String get no_inquiry_history => 'История запросов отсутствует';

  @override
  String get no_inquiry_history_hint => 'Пока нет запросов';

  @override
  String get inquiry_delete => 'Удалить запрос';

  @override
  String get inquiry_delete_confirm => 'Вы хотите удалить этот запрос?';

  @override
  String get inquiry_delete_success => 'Запрос удален';

  @override
  String get inquiry_delete_failed => 'Не удалось удалить запрос';

  @override
  String get inquiry_detail => 'Детали запроса';

  @override
  String get inquiry_category => 'Категория запроса';

  @override
  String get inquiry_status => 'Статус запроса';

  @override
  String get inquiry_created_at => 'Время запроса';

  @override
  String get inquiry_title_label => 'Заголовок запроса';

  @override
  String get inquiry_type_bug => 'Сообщение об ошибке';

  @override
  String get inquiry_type_feature => 'Предложение функции';

  @override
  String get inquiry_type_improvement => 'Предложение улучшения';

  @override
  String get inquiry_type_other => 'Другой запрос';

  @override
  String get inquiry_status_pending => 'Ожидание ответа';

  @override
  String get inquiry_status_in_progress => 'В обработке';

  @override
  String get inquiry_status_answered => 'Ответ получен';

  @override
  String get phone_required => 'Номер телефона обязателен';

  @override
  String get building_info => 'Информация о здании';

  @override
  String get directions => 'Направления';

  @override
  String get floor_detail_view => 'Детальная информация по этажам';

  @override
  String get no_floor_info => 'Информация об этажах отсутствует';

  @override
  String get floor_detail_info => 'Детальная информация по этажам';

  @override
  String get search_start_location => 'Поиск места отправления';

  @override
  String get search_end_location => 'Поиск места назначения';

  @override
  String get unified_navigation_in_progress =>
      'Объединенная навигация в процессе';

  @override
  String get unified_navigation => 'Объединенная навигация';

  @override
  String get recent_searches => 'Недавние поиски';

  @override
  String get clear_all => 'Очистить все';

  @override
  String get searching => 'Поиск...';

  @override
  String get try_different_keyword => 'Попробуйте другое ключевое слово';

  @override
  String get enter_end_location => 'Введите место назначения';

  @override
  String get route_preview => 'Предварительный просмотр маршрута';

  @override
  String get calculating_optimal_route => 'Расчет оптимального маршрута...';

  @override
  String get set_departure_and_destination =>
      'Установите место отправления и назначения';

  @override
  String get start_unified_navigation => 'Начать объединенную навигацию';

  @override
  String get departure_indoor => 'Место отправления (в помещении)';

  @override
  String get to_building_exit => 'К выходу здания';

  @override
  String get outdoor_movement => 'Движение на улице';

  @override
  String get to_destination_building => 'К зданию назначения';

  @override
  String get arrival_indoor => 'Место прибытия (в помещении)';

  @override
  String get to_final_destination => 'К конечному месту назначения';

  @override
  String get total_distance => 'Общее расстояние';

  @override
  String get route_type => 'Тип маршрута';

  @override
  String get building_to_building => 'От здания к зданию';

  @override
  String get room_to_building => 'От комнаты к зданию';

  @override
  String get building_to_room => 'От здания к комнате';

  @override
  String get room_to_room => 'От комнаты к комнате';

  @override
  String get location_to_building => 'От текущего местоположения к зданию';

  @override
  String get unified_route => 'Объединенный маршрут';

  @override
  String get status_offline => 'Не в сети';

  @override
  String get status_open => 'Открыто';

  @override
  String get status_closed => 'Закрыто';

  @override
  String get status_24hours => '24 часа';

  @override
  String get status_temp_closed => 'Временно закрыто';

  @override
  String get status_closed_permanently => 'Закрыто навсегда';

  @override
  String get status_next_open => 'Открывается в 9:00 утра';

  @override
  String get status_next_close => 'Закрывается в 6:00 вечера';

  @override
  String get status_next_open_tomorrow => 'Завтра открывается в 9:00 утра';

  @override
  String get set_start_point => 'Установить точку отправления';

  @override
  String get set_end_point => 'Установить точку назначения';

  @override
  String get scheduleDeleteTitle => 'Удалить расписание';

  @override
  String get scheduleDeleteSubtitle => 'Пожалуйста, решите осторожно';

  @override
  String get scheduleDeleteLabel => 'Расписание для удаления';

  @override
  String scheduleDeleteDescription(Object title) {
    return 'Занятие \"$title\" будет удалено из расписания.\nУдаленное расписание не может быть восстановлено.';
  }

  @override
  String get cancelButton => 'Отмена';

  @override
  String get deleteButton => 'Удалить';

  @override
  String get overlap_message =>
      'Уже есть занятие, зарегистрированное в это время';

  @override
  String friendDeleteSuccessMessage(Object userName) {
    return '$userName был удален из вашего списка друзей';
  }

  @override
  String get enterFriendIdPrompt =>
      'Пожалуйста, введите ID друга, которого хотите добавить';

  @override
  String get friendId => 'ID друга';

  @override
  String get enterFriendId => 'Введите ID друга';

  @override
  String get sendFriendRequest => 'Отправить запрос дружбы';

  @override
  String get realTimeSyncActive =>
      'Синхронизация в реальном времени активна • Автоматическое обновление';

  @override
  String get noSentRequests => 'Нет отправленных запросов дружбы';

  @override
  String newFriendRequests(int count) {
    return '$count новых запросов дружбы';
  }

  @override
  String get noReceivedRequests => 'Нет полученных запросов дружбы';

  @override
  String get id => 'ID';

  @override
  String requestDate(String date) {
    return 'Дата запроса: $date';
  }

  @override
  String get newBadge => 'НОВЫЙ';

  @override
  String get online => 'В сети';

  @override
  String get offline => 'Не в сети';

  @override
  String get contact => 'Контакт';

  @override
  String get noContactInfo => 'Нет контактной информации';

  @override
  String get friendOfflineError => 'Друг не в сети';

  @override
  String get removeLocation => 'Убрать местоположение';

  @override
  String get showLocation => 'Показать местоположение';

  @override
  String friendLocationRemoved(String userName) {
    return 'Местоположение $userName было убрано';
  }

  @override
  String friendLocationShown(String userName) {
    return 'Местоположение $userName было показано';
  }

  @override
  String get errorCannotRemoveLocation => 'Не удается убрать местоположение';

  @override
  String get my_page => 'Моя страница';

  @override
  String get calculating_route => 'Расчет маршрута...';

  @override
  String get finding_optimal_route => 'Поиск оптимального маршрута на сервере';

  @override
  String get clear_route => 'Очистить маршрут';

  @override
  String get location_permission_denied =>
      'Разрешение на местоположение было отклонено.\nПожалуйста, разрешите доступ к местоположению в настройках.';

  @override
  String get estimated_time => 'Предполагаемое время';

  @override
  String get location_share_update_failed =>
      'Не удалось обновить настройки поделиться местоположением';

  @override
  String get guest_location_share_success =>
      'В гостевом режиме поделиться местоположением настраивается только локально';

  @override
  String get no_changes => 'Нет изменений';

  @override
  String get password_confirm_title => 'Подтвердить пароль';

  @override
  String get password_confirm_subtitle =>
      'Пожалуйста, введите пароль для изменения информации аккаунта';

  @override
  String get password_confirm_button => 'Подтвердить';

  @override
  String get password_required => 'Пожалуйста, введите пароль';

  @override
  String get password_mismatch_confirm => 'Пароли не совпадают';

  @override
  String get profile_updated => 'Профиль был обновлен';

  @override
  String get my_page_subtitle => 'Моя информация';

  @override
  String get excel_file => 'Файл Excel';

  @override
  String get excel_file_tutorial => 'Как использовать файл Excel';

  @override
  String get image_attachment => 'Image Attachment';

  @override
  String get max_one_image => 'Максимум 1 изображение';

  @override
  String get photo_attachment => 'Прикрепить фото';

  @override
  String get photo_attachment_complete => 'Фото прикреплено';

  @override
  String get image_selection => 'Выбор изображения';

  @override
  String get select_image_method => 'Способ выбора изображения';

  @override
  String get select_from_gallery => 'Выбрать из галереи';

  @override
  String get select_from_gallery_desc => 'Выбрать изображение из галереи';

  @override
  String get select_from_file => 'Выбрать из файла';

  @override
  String get select_from_file_desc => 'Выбрать изображение из файла';

  @override
  String get max_one_image_error => 'Можно прикрепить только одно изображение';

  @override
  String get image_selection_error => 'Произошла ошибка при выборе изображения';

  @override
  String get inquiry_error_occurred => 'Произошла ошибка при обработке запроса';

  @override
  String get inquiry_category_bug => 'Сообщение об ошибке';

  @override
  String get inquiry_category_feature => 'Предложение функции';

  @override
  String get inquiry_category_other => 'Другой запрос';

  @override
  String get inquiry_category_route_error => 'Ошибка навигации';

  @override
  String get inquiry_category_place_error => 'Ошибка местоположения/информации';

  @override
  String get schedule => 'Расписание';

  @override
  String get winter_semester => 'Зимний семестр';

  @override
  String get spring_semester => 'Весенний семестр';

  @override
  String get summer_semester => 'Летний семестр';

  @override
  String get fall_semester => 'Осенний семестр';

  @override
  String get monday => 'Пн';

  @override
  String get tuesday => 'Вт';

  @override
  String get wednesday => 'Ср';

  @override
  String get thursday => 'Чт';

  @override
  String get friday => 'Пт';

  @override
  String get add_class => 'Добавить занятие';

  @override
  String get edit_class => 'Редактировать занятие';

  @override
  String get delete_class => 'Удалить занятие';

  @override
  String get class_name => 'Название занятия';

  @override
  String get classroom => 'Аудитория';

  @override
  String get start_time => 'Время начала';

  @override
  String get end_time => 'Время окончания';

  @override
  String get color_selection => 'Выбор цвета';

  @override
  String get monday_full => 'Понедельник';

  @override
  String get tuesday_full => 'Вторник';

  @override
  String get wednesday_full => 'Среда';

  @override
  String get thursday_full => 'Четверг';

  @override
  String get friday_full => 'Пятница';

  @override
  String get class_added => 'Занятие добавлено';

  @override
  String get class_updated => 'Занятие обновлено';

  @override
  String get class_deleted => 'Занятие удалено';

  @override
  String delete_class_confirm(String className) {
    return 'Вы хотите удалить занятие $className?';
  }

  @override
  String get view_on_map => 'Посмотреть на карте';

  @override
  String get location => 'Местоположение';

  @override
  String get schedule_time => 'Время';

  @override
  String get schedule_day => 'День';

  @override
  String get map_feature_coming_soon => 'Функция карты будет доступна скоро';

  @override
  String current_year(int year) {
    return 'Текущий год';
  }

  @override
  String get my_friends => 'Мои друзья';

  @override
  String online_friends(int total, int online) {
    return 'Друзья в сети';
  }

  @override
  String get add_friend => 'Добавить друга';

  @override
  String get friend_name_or_id => 'Имя или ID друга';

  @override
  String get friend_request_sent => 'Запрос дружбы отправлен';

  @override
  String get in_class => 'На занятии';

  @override
  String last_location(String location) {
    return 'Последнее местоположение';
  }

  @override
  String get central_library => 'Центральная библиотека';

  @override
  String get engineering_building => 'Инженерное здание';

  @override
  String get student_center => 'Студенческий центр';

  @override
  String get cafeteria => 'Cafeteria';

  @override
  String get message => 'Сообщение';

  @override
  String get call => 'Позвонить';

  @override
  String start_chat_with(String name) {
    return 'Начать чат';
  }

  @override
  String view_location_on_map(String name) {
    return 'Посмотреть местоположение на карте';
  }

  @override
  String calling(String name) {
    return 'Звоню';
  }

  @override
  String get delete => 'Удалить';

  @override
  String get search => 'Поиск';

  @override
  String get searchBuildings => 'Поиск зданий';

  @override
  String get myLocation => 'Мое местоположение';

  @override
  String get navigation => 'Навигация';

  @override
  String get route => 'Маршрут';

  @override
  String get distance => 'Расстояние';

  @override
  String get minutes => 'минут';

  @override
  String get hours => 'Часы работы';

  @override
  String get within_minute => 'Менее 1 минуты';

  @override
  String minutes_only(Object minutes) {
    return '$minutes минут';
  }

  @override
  String hours_only(Object hours) {
    return '$hours часов';
  }

  @override
  String hours_and_minutes(Object hours, Object minutes) {
    return '$hours часов $minutes минут';
  }

  @override
  String get available => 'Доступно';

  @override
  String get start_navigation_from_current_location =>
      'Начать навигацию с текущего местоположения';

  @override
  String get my_location_set_as_start =>
      'Мое местоположение автоматически установлено как точка отправления';

  @override
  String get default_location_set_as_start =>
      'Местоположение по умолчанию установлено как точка отправления';

  @override
  String get start_navigation => 'Начать навигацию';

  @override
  String get navigation_ended => 'Навигация завершена';

  @override
  String get arrival => 'Прибытие';

  @override
  String get outdoor_movement_distance => 'Расстояние движения на улице';

  @override
  String get indoor_arrival => 'Прибытие в помещении';

  @override
  String get indoor_departure => 'Отправление в помещении';

  @override
  String get complete => 'Завершить';

  @override
  String get findRoute => 'Найти маршрут';

  @override
  String get clearRoute => 'Очистить маршрут';

  @override
  String get setAsStart => 'Установить как отправление';

  @override
  String get setAsDestination => 'Установить как назначение';

  @override
  String get navigateFromHere => 'Навигация отсюда';

  @override
  String get buildingInfo => 'Информация о здании';

  @override
  String get locationPermissionRequired =>
      'Требуется разрешение на местоположение';

  @override
  String get enableLocationServices =>
      'Пожалуйста, включите службы местоположения';

  @override
  String get noResults => 'Нет результатов';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get about => 'О приложении';

  @override
  String friends_count_status(int total, int online) {
    return 'Статус количества друзей';
  }

  @override
  String get enter_friend_info => 'Введите информацию о друге';

  @override
  String show_location_on_map(String name) {
    return 'Показать местоположение на карте';
  }

  @override
  String get location_error => 'Ошибка местоположения';

  @override
  String get view_floor_plan => 'Посмотреть план';

  @override
  String floor_plan_title(String buildingName) {
    return 'План';
  }

  @override
  String get floor_plan_not_available => 'План недоступен';

  @override
  String get floor_plan_default_text => 'Текст плана по умолчанию';

  @override
  String get delete_account_success => 'Аккаунт успешно удален';

  @override
  String get convenience_store => 'Магазин';

  @override
  String get vending_machine => 'Торговый автомат';

  @override
  String get printer => 'Принтер';

  @override
  String get copier => 'Копировальный аппарат';

  @override
  String get atm => 'Банкомат';

  @override
  String get bank_atm => 'Банк (Банкомат)';

  @override
  String get medical => 'Медицинский';

  @override
  String get health_center => 'Медицинский центр';

  @override
  String get gym => 'Гимнастический зал';

  @override
  String get fitness_center => 'Фитнес-центр';

  @override
  String get lounge => 'Комната отдыха';

  @override
  String get extinguisher => 'Огнетушитель';

  @override
  String get water_purifier => 'Водоочиститель';

  @override
  String get bookstore => 'Книжный магазин';

  @override
  String get post_office => 'Почтовое отделение';

  @override
  String instructionMoveToDestination(String place) {
    return 'Двигайтесь к месту назначения';
  }

  @override
  String get markerDeparture => 'Точка отправления';

  @override
  String get markerArrival => 'Точка прибытия';

  @override
  String get errorCannotOpenPhoneApp =>
      'Не удается открыть приложение телефона.';

  @override
  String get emailCopied => 'Электронная почта скопирована';

  @override
  String get description => 'Описание';

  @override
  String get noDetailedInfoRegistered =>
      'Нет зарегистрированной подробной информации';

  @override
  String get setDeparture => 'Установить точку отправления';

  @override
  String get setArrival => 'Установить точку прибытия';

  @override
  String errorOccurred(Object error) {
    return 'Произошла ошибка: $error';
  }

  @override
  String get instructionExitToOutdoor => 'Выйдите на улицу';

  @override
  String instructionMoveToDestinationBuilding(String building) {
    return 'Двигайтесь к зданию назначения';
  }

  @override
  String get instructionMoveToRoom => 'Двигайтесь к комнате';

  @override
  String get instructionArrived => 'Вы прибыли';

  @override
  String get no => 'Нет';

  @override
  String get woosong_library_w1 => 'Библиотека Усунг (W1)';

  @override
  String get woosong_library_info =>
      'B2F\tПарковка\nB1F\tАудитория, Машинный зал, Электрический зал, Парковка\n1F\tЦентр поддержки трудоустройства (630-9976), Выдача, Информационный зал отдыха\n2F\tОбщий читальный зал, Групповая учебная комната\n3F\tОбщий читальный зал\n4F\tЛитературные книги/Западные книги';

  @override
  String get educational_facility => 'Educational Facility';

  @override
  String get operating => 'Operating';

  @override
  String get woosong_library_desc =>
      'Центральная библиотека Университета Усунг';

  @override
  String get sol_cafe => 'Кафе Сол';

  @override
  String get sol_cafe_info => '1F\tРесторан\n2F\tКафе';

  @override
  String get cafe => 'Кафе';

  @override
  String get sol_cafe_desc => 'Кафе в кампусе';

  @override
  String get cheongun_1_dormitory => 'Общежитие Чонгун 1';

  @override
  String get cheongun_1_dormitory_info =>
      '1F\tЛаборатория\n2F\tСтуденческая столовая\n2F\tОбщежитие Чонгун 1 (женщины) (629-6542)\n2F\tЦентр жизни\n3~5F\tЦентр жизни';

  @override
  String get dormitory => 'Общежитие';

  @override
  String get cheongun_1_dormitory_desc => 'Женское общежитие';

  @override
  String get industry_cooperation_w2 =>
      'Центр сотрудничества промышленности и академии (W2)';

  @override
  String get industry_cooperation_info =>
      '1F\tЦентр сотрудничества промышленности и академии\n2F\tОтдел архитектурной инженерии (630-9720)\n3F\tИнститут конвергентных технологий, Центр поддержки предприятий\n4F\tКорпоративная лаборатория, Аудитория LG CNS, Цифровая железнодорожная академия';

  @override
  String get industry_cooperation_desc =>
      'Объекты сотрудничества промышленности и академии и исследований';

  @override
  String get rotc_w2_1 => 'Корпус офицеров запаса (W2-1)';

  @override
  String get rotc_info => '\tКорпус офицеров запаса (630-4601)';

  @override
  String get rotc_desc => 'Объекты корпуса офицеров запаса';

  @override
  String get military_facility => 'Военный объект';

  @override
  String get international_dormitory_w3 => 'Международное общежитие (W3)';

  @override
  String get international_dormitory_info =>
      '1F\tКоманда поддержки иностранных студентов (629-6623)\n1F\tСтуденческая столовая\n2F\tМеждународное общежитие (629-6655)\n2F\tМедицинский кабинет\n3~12F\tЦентр жизни';

  @override
  String get international_dormitory_desc =>
      'Общежитие исключительно для иностранных студентов';

  @override
  String get railway_logistics_w4 =>
      'Железнодорожный и логистический центр (W4)';

  @override
  String get railway_logistics_info =>
      'B1F\tЛаборатория\n1F\tЛаборатория\n2F\tОтдел систем железнодорожного строительства (629-6710)\n2F\tОтдел систем железнодорожных транспортных средств (629-6780)\n3F\tАудитория/Лаборатория\n4F\tОтдел железнодорожных систем (630-6730,9700)\n5F\tОтдел пожарной безопасности (629-6770)\n5F\tОтдел логистических систем (630-9330)';

  @override
  String get railway_logistics_desc =>
      'Отделы, связанные с железными дорогами и логистикой';

  @override
  String get health_medical_science_w5 =>
      'Центр медицинских наук и здравоохранения (W5)';

  @override
  String get health_medical_science_info =>
      'B1F\tПарковка\n1F\tАудиовизуальный зал/Парковка\n2F\tАудитория\n2F\tОтдел реабилитации здоровья и физических упражнений (630-9840)\n3F\tОтдел неотложной помощи (630-9280)\n3F\tОтдел сестринского дела (630-9290)\n4F\tОтдел трудотерапии (630-9820)\n4F\tОтдел речевой терапии и слуховой реабилитации (630-9220)\n5F\tОтдел физиотерапии (630-4620)\n5F\tОтдел управления медицинскими услугами (630-4610)\n5F\tАудитория\n6F\tОтдел железнодорожного управления (630-9770)';

  @override
  String get health_medical_science_desc =>
      'Отделы, связанные с медицинскими науками и здравоохранением';

  @override
  String get liberal_arts_w6 => 'Центр гуманитарного образования (W6)';

  @override
  String get liberal_arts_info =>
      '2F\tАудитория\n3F\tАудитория\n4F\tАудитория\n5F\tАудитория';

  @override
  String get liberal_arts_desc => 'Аудитории гуманитарного образования';

  @override
  String get woosong_hall_w7 => 'Зал Усунг (W7)';

  @override
  String get woosong_hall_info =>
      '1F\tОфис приема (630-9627)\n1F\tОфис академических дел (630-9622)\n1F\tОфис объектов (630-9970)\n1F\tКоманда управления (629-6658)\n1F\tЦентр сотрудничества промышленности и академии (630-4653)\n1F\tОфис внешнего сотрудничества (630-9636)\n2F\tОфис стратегического планирования (630-9102)\n2F\tОбщий офис-Управление, Закупки (630-9653)\n2F\tОфис планирования (630-9661)\n3F\tОфис президента (630-8501)\n3F\tОфис международного обмена (630-9373)\n3F\tОтдел дошкольного образования (630-9360)\n3F\tБизнес-администрирование (629-6640)\n3F\tФинансы/Управление недвижимостью (630-9350)\n4F\tГлавная конференц-зал\n5F\tКонференц-зал';

  @override
  String get woosong_hall_desc => 'Главное здание университета';

  @override
  String get woosong_kindergarten_w8 => 'Детский сад Усунг (W8)';

  @override
  String get woosong_kindergarten_info =>
      '1F, 2F\tДетский сад Усунг (629~6750~1)';

  @override
  String get woosong_kindergarten_desc =>
      'Детский сад, принадлежащий университету';

  @override
  String get kindergarten => 'Детский сад';

  @override
  String get west_campus_culinary_w9 =>
      'Кулинарная академия западного кампуса (W9)';

  @override
  String get west_campus_culinary_info =>
      'B1F\tЛаборатория\n1F\tЛаборатория\n2F\tЛаборатория';

  @override
  String get west_campus_culinary_desc => 'Кулинарные учебные объекты';

  @override
  String get social_welfare_w10 => 'Центр социального обеспечения (W10)';

  @override
  String get social_welfare_info =>
      '1F\tАудиовизуальный зал/Лаборатория\n2F\tАудитория/Лаборатория\n3F\tОтдел социального обеспечения (630-9830)\n3F\tОтдел глобального детского образования (630-9260)\n4F\tАудитория/Лаборатория\n5F\tАудитория/Лаборатория';

  @override
  String get social_welfare_desc =>
      'Отделы, связанные с социальным обеспечением';

  @override
  String get gymnasium_w11 => 'Гимнастический зал (W11)';

  @override
  String get gymnasium_info =>
      '1F\tЗал физической подготовки\n2F~4F\tГимнастический зал';

  @override
  String get gymnasium_desc => 'Спортивные объекты';

  @override
  String get sports_facility => 'Спортивный объект';

  @override
  String get sica_w12 => 'SICA (W12)';

  @override
  String get sica_info =>
      'B1F\tЛаборатория\n1F\tКафе Старрико\n2F~3F\tАудитория\n5F\tОтдел глобальных кулинарных искусств (629-6860)';

  @override
  String get sica_desc => 'Международная кулинарная академия';

  @override
  String get woosong_tower_w13 => 'Башня Усунг (W13)';

  @override
  String get woosong_tower_info =>
      'B1~1F\tПарковка\n2F\tПарковка, Пекарня Солпайн (629-6429)\n4F\tСеминарная комната\n5F\tАудитория\n6F\tОтдел кулинарного питания (630-9380,9740)\n7F\tАудитория\n8F\tУправление ресторанами и кулинарией (630-9250)\n9F\tАудитория/Лаборатория\n10F\tКулинарные искусства (629-6821), Глобальная корейская кухня (629-6560)\n11F, 12F\tЛаборатория\n13F\tРесторан Солпайн (629-6610)';

  @override
  String get woosong_tower_desc => 'Комплексное образовательное учреждение';

  @override
  String get complex_facility => 'Комплексное учреждение';

  @override
  String get culinary_center_w14 => 'Кулинарный центр (W14)';

  @override
  String get culinary_center_info =>
      '1F\tАудитория/Лаборатория\n2F\tАудитория/Лаборатория\n3F\tАудитория/Лаборатория\n4F\tАудитория/Лаборатория\n5F\tАудитория/Лаборатория';

  @override
  String get culinary_center_desc =>
      'Образовательное учреждение кулинарных искусств';

  @override
  String get food_architecture_w15 => 'Центр пищевой архитектуры (W15)';

  @override
  String get food_architecture_info =>
      'B1F\tЛаборатория\n1F\tЛаборатория\n2F\tАудитория\n3F\tАудитория\n4F\tАудитория\n5F\tАудитория';

  @override
  String get food_architecture_desc =>
      'Отделы, связанные с продуктами питания и архитектурой';

  @override
  String get student_hall_w16 => 'Студенческий центр (W16)';

  @override
  String get student_hall_info =>
      '1F\tСтуденческая столовая, Книжный магазин кампуса (629-6127)\n2F\tСтоловая сотрудников\n3F\tКомнаты клубов\n3F\tОфис студенческого благосостояния-Студенческая команда (630-9641), Команда стипендий (630-9876)\n3F\tЦентр поддержки студентов с ограниченными возможностями (630-9903)\n3F\tКоманда социального обслуживания (630-9904)\n3F\tСтуденческий консультационный центр (630-9645)\n4F\tЦентр поддержки возвращения (630-9139)\n4F\tЦентр развития преподавания и обучения (630-9285)';

  @override
  String get student_hall_desc => 'Объекты студенческого благосостояния';

  @override
  String get media_convergence_w17 => 'Центр медиа-конвергенции (W17)';

  @override
  String get media_convergence_info =>
      'B1F\tАудитория/Лаборатория\n1F\tМедиа-дизайн/Видео-производство (630-9750)\n2F\tАудитория/Лаборатория\n3F\tИгры и мультимедиа (630-9270)\n5F\tАудитория/Лаборатория';

  @override
  String get media_convergence_desc => 'Отделы, связанные с медиа';

  @override
  String get woosong_arts_center_w18 => 'Художественный центр Усунг (W18)';

  @override
  String get woosong_arts_center_info =>
      'B1F\tКомната подготовки выступлений\n1F\tХудожественный центр Усунг (629-6363)\n2F\tЛаборатория\n3F\tЛаборатория\n4F\tЛаборатория\n5F\tЛаборатория';

  @override
  String get woosong_arts_center_desc => 'Объект художественных выступлений';

  @override
  String get west_campus_andycut_w19 =>
      'Здание Эндикат западного кампуса (W19)';

  @override
  String get west_campus_andycut_info =>
      '2F\tОтдел глобальных конвергентных бизнес-наук (630-9249)\n2F\tФакультет свободных исследований (630-9390)\n2F\tОтдел ИИ/Больших данных (630-9807)\n2F\tОтдел глобального управления отелями (630-9249)\n2F\tОтдел глобальных медиа и видео (630-9346)\n2F\tОтдел глобального управления медицинскими услугами (630-9283)\n2F\tФакультет глобальных железных дорог/транспортной логистики (630-9347)\n2F\tОтдел глобального кулинарного предпринимательства (629-6860)';

  @override
  String get west_campus_andycut_desc => 'Здание глобальных отделов';

  @override
  String get search_campus_buildings => 'Поиск зданий кампуса';

  @override
  String get building_details => 'Подробная информация';

  @override
  String get parking => 'Парковка';

  @override
  String get accessibility => 'Удобства';

  @override
  String get facilities => 'Объекты';

  @override
  String get elevator => 'Лифт';

  @override
  String get restroom => 'Туалет';

  @override
  String get navigate_from_current_location =>
      'Навигация с текущего местоположения';

  @override
  String get edit_profile => 'Редактировать профиль';

  @override
  String get nameRequired => 'Пожалуйста, введите имя';

  @override
  String get emailRequired => 'Пожалуйста, введите электронную почту';

  @override
  String get save => 'Сохранить';

  @override
  String get saveSuccess => 'Профиль обновлен';

  @override
  String get app_info => 'Информация о приложении';

  @override
  String get app_version => 'Версия приложения';

  @override
  String get developer => 'Разработчик';

  @override
  String get developer_name =>
      'Команда: Чон Джин-ён, Пак Чхоль-хён, Чо Хён-джун, Чхве Сон-ёль, Хан Сын-хон, Ли Йе-ын';

  @override
  String get developer_email => 'Электронная почта: wsumap41@gmail.com';

  @override
  String get developer_github => 'GitHub: github.com/WSU-YJB/WSUMAP';

  @override
  String get no_help_images => 'Нет изображений помощи';

  @override
  String get description_hint => 'Введите описание';

  @override
  String get my_info => 'Моя информация';

  @override
  String get guest_user => 'Гостевой пользователь';

  @override
  String get guest_role => 'Гостевая роль';

  @override
  String get user => 'Пользователь';

  @override
  String get edit_profile_subtitle => 'Вы можете изменить личную информацию';

  @override
  String get help_subtitle => 'Проверьте, как использовать приложение';

  @override
  String get app_info_subtitle => 'Информация о версии и разработчике';

  @override
  String get delete_account_subtitle => 'Навсегда удалить аккаунт';

  @override
  String get login_message =>
      'Войти или зарегистрироваться\nДля использования всех функций';

  @override
  String get login_signup => 'Войти / Зарегистрироваться';

  @override
  String get delete_account_confirm => 'Удалить аккаунт';

  @override
  String get delete_account_message => 'Вы хотите удалить аккаунт?';

  @override
  String get logout_confirm => 'Выйти';

  @override
  String get logout_message => 'Вы хотите выйти?';

  @override
  String get yes => 'Да';

  @override
  String get feature_in_progress => 'Функция в разработке';

  @override
  String get delete_feature_in_progress =>
      'Функция удаления аккаунта в разработке';

  @override
  String get title => 'Редактировать профиль';

  @override
  String get email_required => 'Пожалуйста, введите электронную почту';

  @override
  String get name_required => 'Пожалуйста, введите имя';

  @override
  String get cancelFriendRequest => 'Отменить запрос дружбы';

  @override
  String cancelFriendRequestConfirm(String name) {
    return 'Вы хотите отменить запрос дружбы, отправленный $name?';
  }

  @override
  String get attached_image => 'Прикрепленное изображение';

  @override
  String get answer_section_title => 'Ответ';

  @override
  String get inquiry_default_answer =>
      'Это ответ на ваш запрос. Если у вас есть дополнительные вопросы, не стесняйтесь обращаться к нам в любое время.';

  @override
  String get answer_date_prefix => 'Дата ответа:';

  @override
  String get waiting_answer_status => 'Ожидание ответа';

  @override
  String get waiting_answer_message =>
      'Мы рассматриваем ваш запрос. Мы ответим вам как можно скорее.';

  @override
  String get status_pending => 'Ожидание ответа';

  @override
  String get status_answered => 'Ответ получен';

  @override
  String get cancelRequest => 'Отменить запрос';

  @override
  String get friendDeleteTitle => 'Удалить друга';

  @override
  String get friendDeleteWarning => 'Это действие нельзя отменить';

  @override
  String get friendDeleteHeader => 'Удалить друга';

  @override
  String get friendDeleteToConfirm => 'Введите имя друга для удаления';

  @override
  String get friendDeleteCancel => 'Отмена';

  @override
  String get friendDeleteButton => 'Удалить';

  @override
  String get friendManagementAndRequests => 'Управление друзьями и запросы';

  @override
  String get realTimeSyncStatus => 'Статус синхронизации в реальном времени';

  @override
  String get friendManagement => 'Управление друзьями';

  @override
  String get add => 'Добавить';

  @override
  String sentRequestsCount(int count) {
    return 'Отправленные запросы ($count)';
  }

  @override
  String receivedRequestsCount(int count) {
    return 'Полученные запросы ($count)';
  }

  @override
  String friendCount(int count) {
    return 'Мои друзья ($count)';
  }

  @override
  String get noFriends =>
      'У вас пока нет друзей.\nНажмите кнопку + выше, чтобы добавить друзей!';

  @override
  String get open_settings => 'Открыть настройки';

  @override
  String get retry => 'Повторить';

  @override
  String get basic_info => 'Основная информация';

  @override
  String get status => 'Статус';

  @override
  String get floor_plan => 'План';

  @override
  String get indoorMap => 'Внутренний план';

  @override
  String get showBuildingMarker => 'Показать маркер здания';

  @override
  String get search_hint => 'Поиск зданий кампуса';

  @override
  String get searchHint => 'Поиск по зданию или комнате';

  @override
  String get searchInitialGuide => 'Поиск зданий или комнат';

  @override
  String get searchHintExample =>
      'например: W19, Инженерное здание, комната 401';

  @override
  String get searchLoading => 'Поиск...';

  @override
  String get searchNoResult => 'Нет результатов поиска';

  @override
  String get searchTryAgain => 'Попробуйте другие ключевые слова';

  @override
  String get required => 'Обязательно';

  @override
  String get enter_title => 'Введите заголовок';

  @override
  String get content => 'Содержание';

  @override
  String get enter_content => 'Введите содержание';

  @override
  String get restaurant => 'Ресторан';

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
  String get library => 'Библиотека';

  @override
  String get setting => 'Настройки';

  @override
  String location_setting_confirm(String buildingName, String locationType) {
    return 'Вы хотите установить $locationType?';
  }

  @override
  String get set_room => 'Установить комнату';

  @override
  String friend_location_permission_denied(String name) {
    return '$name не разрешает делиться местоположением';
  }

  @override
  String get no_friends_message =>
      'У вас нет друзей.\nПожалуйста, добавьте друзей и попробуйте снова.';

  @override
  String offline_friends_not_displayed(int count) {
    return '\n$count друзей не в сети не показаны.';
  }

  @override
  String location_denied_friends_not_displayed(int count) {
    return '\n$count друзей, которые отклонили обмен местоположением, не показаны.';
  }

  @override
  String both_offline_and_location_denied(int offlineCount, int locationCount) {
    return '\n$offlineCount друзей не в сети и $locationCount друзей, которые отклонили обмен местоположением, не показаны.';
  }

  @override
  String get all_friends_offline_or_location_denied =>
      'Все друзья не в сети или отклонили обмен местоположением.\nВы можете проверить их местоположение, когда они будут в сети и разрешат обмен местоположением.';

  @override
  String get all_friends_offline =>
      'Все друзья не в сети.\nВы можете проверить их местоположение, когда они будут в сети.';

  @override
  String get all_friends_location_denied =>
      'Все друзья отклонили обмен местоположением.\nВы можете проверить их местоположение, когда они разрешат обмен местоположением.';

  @override
  String friends_location_display_success(int count) {
    return 'Местоположение $count друзей показано на карте.';
  }

  @override
  String friends_location_display_error(String error) {
    return 'Не удается показать местоположения друзей: $error';
  }

  @override
  String offline_friends_dialog_subtitle(int count) {
    return '$count друзей в настоящее время не в сети';
  }

  @override
  String get friend_location_display_error =>
      'Не удается показать местоположение друга';

  @override
  String get friend_location_remove_error => 'Не удается убрать местоположение';

  @override
  String get phone_app_error => 'Не удается открыть приложение телефона';

  @override
  String get add_friend_error => 'Ошибка при добавлении друга';

  @override
  String get user_not_found => 'Пользователь не найден';

  @override
  String get already_friend => 'Пользователь уже ваш друг';

  @override
  String get already_requested => 'Запрос дружбы уже отправлен';

  @override
  String get cannot_add_self => 'Вы не можете добавить себя как друга';

  @override
  String get invalid_user_id => 'Недействительный ID пользователя';

  @override
  String get server_error_retry =>
      'Ошибка сервера. Пожалуйста, попробуйте позже';

  @override
  String get cancel_request_description =>
      'Отменить отправленный запрос дружбы';

  @override
  String get enter_id_prompt => 'Введите ID';

  @override
  String get friend_request_sent_success => 'Запрос дружбы успешно отправлен';

  @override
  String get already_adding_friend =>
      'Вы уже добавляете друга. Избегайте дублирования';

  @override
  String friends_location_displayed(int count) {
    return 'Показано местоположение $count друзей.';
  }

  @override
  String get offline_friends_dialog_title => 'Друзья не в сети';

  @override
  String friendRequestCancelled(String name) {
    return 'Запрос дружбы, отправленный $name, был отменен.';
  }

  @override
  String get friendRequestCancelError => 'Ошибка при отмене запроса дружбы.';

  @override
  String friendRequestAccepted(String name) {
    return 'Запрос дружбы от $name был принят.';
  }

  @override
  String get friendRequestAcceptError => 'Ошибка при принятии запроса дружбы.';

  @override
  String friendRequestRejected(String name) {
    return 'Запрос дружбы от $name был отклонен.';
  }

  @override
  String get friendRequestRejectError =>
      'Ошибка при отклонении запроса дружбы.';

  @override
  String get friendLocationRemovedFromMap =>
      'Местоположения друзей были убраны с карты.';

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
