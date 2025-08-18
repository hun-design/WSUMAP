import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ko'),
    Locale('en'),
    Locale('zh'),
    Locale('es'),
    Locale('ja'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow Woosong'**
  String get appTitle;

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Campus Guide'**
  String get subtitle;

  /// No description provided for @woosong.
  ///
  /// In en, this message translates to:
  /// **'Woosong'**
  String get woosong;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @student_professor.
  ///
  /// In en, this message translates to:
  /// **'Student/Professor'**
  String get student_professor;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @professor.
  ///
  /// In en, this message translates to:
  /// **'Professor'**
  String get professor;

  /// No description provided for @external_user.
  ///
  /// In en, this message translates to:
  /// **'External User'**
  String get external_user;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirm_password;

  /// No description provided for @remember_me.
  ///
  /// In en, this message translates to:
  /// **'Remember Login Info'**
  String get remember_me;

  /// No description provided for @remember_me_description.
  ///
  /// In en, this message translates to:
  /// **'Auto login next time'**
  String get remember_me_description;

  /// No description provided for @login_as_guest.
  ///
  /// In en, this message translates to:
  /// **'Browse as Guest'**
  String get login_as_guest;

  /// No description provided for @login_failed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get login_failed;

  /// No description provided for @login_success.
  ///
  /// In en, this message translates to:
  /// **'Login Success'**
  String get login_success;

  /// No description provided for @logout_success.
  ///
  /// In en, this message translates to:
  /// **'Logged out successfully'**
  String get logout_success;

  /// No description provided for @enter_username.
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get enter_username;

  /// No description provided for @enter_password.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get enter_password;

  /// No description provided for @password_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter at least 6 characters'**
  String get password_hint;

  /// No description provided for @confirm_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Please enter password again'**
  String get confirm_password_hint;

  /// No description provided for @username_password_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter both username and password'**
  String get username_password_required;

  /// No description provided for @login_error.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get login_error;

  /// No description provided for @find_password.
  ///
  /// In en, this message translates to:
  /// **'Find Password'**
  String get find_password;

  /// No description provided for @find_username.
  ///
  /// In en, this message translates to:
  /// **'Find Username'**
  String get find_username;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get coming_soon;

  /// No description provided for @feature_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'{feature} feature is coming soon.\nIt will be added soon.'**
  String feature_coming_soon(String feature);

  /// No description provided for @departurePoint.
  ///
  /// In en, this message translates to:
  /// **'Departure'**
  String get departurePoint;

  /// No description provided for @arrivalPoint.
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get arrivalPoint;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @tutorial.
  ///
  /// In en, this message translates to:
  /// **'Tutorial'**
  String get tutorial;

  /// No description provided for @tutorialTitleIntro.
  ///
  /// In en, this message translates to:
  /// **'How to Use TaraWoosong'**
  String get tutorialTitleIntro;

  /// No description provided for @tutorialDescIntro.
  ///
  /// In en, this message translates to:
  /// **'Make your campus life easier with Woosong University Campus Navigator.'**
  String get tutorialDescIntro;

  /// No description provided for @tutorialTitleSearch.
  ///
  /// In en, this message translates to:
  /// **'Detailed Search Function'**
  String get tutorialTitleSearch;

  /// No description provided for @tutorialDescSearch.
  ///
  /// In en, this message translates to:
  /// **'You can search not only buildings but also lecture rooms at Woosong University!\nFind detailed information including lecture room location and facilities 😊'**
  String get tutorialDescSearch;

  /// No description provided for @tutorialTitleSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule Integration'**
  String get tutorialTitleSchedule;

  /// No description provided for @tutorialDescSchedule.
  ///
  /// In en, this message translates to:
  /// **'Link your class schedule to the app and get optimized routes to your next class automatically.'**
  String get tutorialDescSchedule;

  /// No description provided for @tutorialTitleDirections.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get tutorialTitleDirections;

  /// No description provided for @tutorialDescDirections.
  ///
  /// In en, this message translates to:
  /// **'Get accurate route guidance within campus and arrive at your destination easily and quickly.'**
  String get tutorialDescDirections;

  /// No description provided for @tutorialTitleIndoorMap.
  ///
  /// In en, this message translates to:
  /// **'Indoor Building Map'**
  String get tutorialTitleIndoorMap;

  /// No description provided for @tutorialDescIndoorMap.
  ///
  /// In en, this message translates to:
  /// **'Find lecture rooms and amenities easily with detailed indoor maps of the buildings.'**
  String get tutorialDescIndoorMap;

  /// No description provided for @dontShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show again'**
  String get dontShowAgain;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @lectureRoom.
  ///
  /// In en, this message translates to:
  /// **'Lecture Room'**
  String get lectureRoom;

  /// No description provided for @lectureRoomInfo.
  ///
  /// In en, this message translates to:
  /// **'Lecture Room Info'**
  String get lectureRoomInfo;

  /// No description provided for @floor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get floor;

  /// No description provided for @personInCharge.
  ///
  /// In en, this message translates to:
  /// **'Person in Charge'**
  String get personInCharge;

  /// No description provided for @viewLectureRoom.
  ///
  /// In en, this message translates to:
  /// **'View Lecture Room'**
  String get viewLectureRoom;

  /// No description provided for @viewBuilding.
  ///
  /// In en, this message translates to:
  /// **'View Building'**
  String get viewBuilding;

  /// No description provided for @walk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get walk;

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minute;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'hr'**
  String get hour;

  /// No description provided for @less_than_one_minute.
  ///
  /// In en, this message translates to:
  /// **'Less than 1 min'**
  String get less_than_one_minute;

  /// No description provided for @zero_minutes.
  ///
  /// In en, this message translates to:
  /// **'0 min'**
  String get zero_minutes;

  /// No description provided for @calculation_failed.
  ///
  /// In en, this message translates to:
  /// **'Calculation failed'**
  String get calculation_failed;

  /// No description provided for @professor_name.
  ///
  /// In en, this message translates to:
  /// **'Professor'**
  String get professor_name;

  /// No description provided for @building_name.
  ///
  /// In en, this message translates to:
  /// **'Building Name'**
  String get building_name;

  /// No description provided for @floor_number.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String floor_number(Object floor);

  /// No description provided for @room_name.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get room_name;

  /// No description provided for @day_of_week.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day_of_week;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @memo.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get memo;

  /// No description provided for @recommend_route.
  ///
  /// In en, this message translates to:
  /// **'Recommend Route'**
  String get recommend_route;

  /// No description provided for @view_location.
  ///
  /// In en, this message translates to:
  /// **'View Location'**
  String get view_location;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @help_intro_title.
  ///
  /// In en, this message translates to:
  /// **'Using TarauSong'**
  String get help_intro_title;

  /// No description provided for @help_intro_description.
  ///
  /// In en, this message translates to:
  /// **'Make your campus life easier with Woosong University Campus Navigator.'**
  String get help_intro_description;

  /// No description provided for @help_detailed_search_title.
  ///
  /// In en, this message translates to:
  /// **'Detailed Search'**
  String get help_detailed_search_title;

  /// No description provided for @help_detailed_search_description.
  ///
  /// In en, this message translates to:
  /// **'Find locations precisely and quickly including building names, room numbers, and amenities.'**
  String get help_detailed_search_description;

  /// No description provided for @help_timetable_title.
  ///
  /// In en, this message translates to:
  /// **'Timetable Integration'**
  String get help_timetable_title;

  /// No description provided for @help_timetable_description.
  ///
  /// In en, this message translates to:
  /// **'Sync your class timetable and get optimal route guidance until the next class.'**
  String get help_timetable_description;

  /// No description provided for @help_directions_title.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get help_directions_title;

  /// No description provided for @help_directions_description.
  ///
  /// In en, this message translates to:
  /// **'Navigate accurately on campus to reach your destination easily and quickly.'**
  String get help_directions_description;

  /// No description provided for @help_building_map_title.
  ///
  /// In en, this message translates to:
  /// **'Building Floor Maps'**
  String get help_building_map_title;

  /// No description provided for @help_building_map_description.
  ///
  /// In en, this message translates to:
  /// **'Use detailed floor maps to find classrooms and amenities easily.'**
  String get help_building_map_description;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @image_load_error.
  ///
  /// In en, this message translates to:
  /// **'Cannot load image'**
  String get image_load_error;

  /// No description provided for @start_campus_exploration.
  ///
  /// In en, this message translates to:
  /// **'Start exploring the campus'**
  String get start_campus_exploration;

  /// No description provided for @woosong_university.
  ///
  /// In en, this message translates to:
  /// **'Woosong University'**
  String get woosong_university;

  /// No description provided for @excel_upload_title.
  ///
  /// In en, this message translates to:
  /// **'Upload Timetable Excel File'**
  String get excel_upload_title;

  /// No description provided for @excel_upload_description.
  ///
  /// In en, this message translates to:
  /// **'Please select a Woosong University timetable Excel file (.xlsx)'**
  String get excel_upload_description;

  /// No description provided for @excel_file_select.
  ///
  /// In en, this message translates to:
  /// **'Select Excel File'**
  String get excel_file_select;

  /// No description provided for @excel_upload_uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading Excel file...'**
  String get excel_upload_uploading;

  /// No description provided for @language_selection.
  ///
  /// In en, this message translates to:
  /// **'Language Selection'**
  String get language_selection;

  /// No description provided for @language_selection_description.
  ///
  /// In en, this message translates to:
  /// **'Please select your preferred language'**
  String get language_selection_description;

  /// No description provided for @departure.
  ///
  /// In en, this message translates to:
  /// **'Departure'**
  String get departure;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @my_location.
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get my_location;

  /// No description provided for @current_location.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get current_location;

  /// No description provided for @welcome_subtitle_1.
  ///
  /// In en, this message translates to:
  /// **'Follow Woosong in your hands,'**
  String get welcome_subtitle_1;

  /// No description provided for @welcome_subtitle_2.
  ///
  /// In en, this message translates to:
  /// **'All building information is here!'**
  String get welcome_subtitle_2;

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get select_language;

  /// No description provided for @auth_selection_title.
  ///
  /// In en, this message translates to:
  /// **'Authentication Method Selection'**
  String get auth_selection_title;

  /// No description provided for @auth_selection_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Please select your preferred login method'**
  String get auth_selection_subtitle;

  /// No description provided for @select_auth_method.
  ///
  /// In en, this message translates to:
  /// **'Select Authentication Method'**
  String get select_auth_method;

  /// No description provided for @total_floors.
  ///
  /// In en, this message translates to:
  /// **'Total {count} floors'**
  String total_floors(Object count);

  /// No description provided for @floor_info.
  ///
  /// In en, this message translates to:
  /// **'Floor Information'**
  String get floor_info;

  /// No description provided for @floor_with_category.
  ///
  /// In en, this message translates to:
  /// **'Floor with {category}'**
  String floor_with_category(Object category);

  /// No description provided for @floor_label.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get floor_label;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @excel_upload_success.
  ///
  /// In en, this message translates to:
  /// **'Upload Complete!'**
  String get excel_upload_success;

  /// No description provided for @guest_timetable_disabled.
  ///
  /// In en, this message translates to:
  /// **'Guest users cannot use the timetable feature.'**
  String get guest_timetable_disabled;

  /// No description provided for @guest_timetable_add_disabled.
  ///
  /// In en, this message translates to:
  /// **'Guest users cannot add timetables.'**
  String get guest_timetable_add_disabled;

  /// No description provided for @guest_timetable_edit_disabled.
  ///
  /// In en, this message translates to:
  /// **'Guest users cannot edit timetables.'**
  String get guest_timetable_edit_disabled;

  /// No description provided for @guest_timetable_delete_disabled.
  ///
  /// In en, this message translates to:
  /// **'Guest users cannot delete timetables.'**
  String get guest_timetable_delete_disabled;

  /// No description provided for @timetable_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load timetable.'**
  String get timetable_load_failed;

  /// No description provided for @timetable_add_success.
  ///
  /// In en, this message translates to:
  /// **'Timetable added successfully.'**
  String get timetable_add_success;

  /// No description provided for @timetable_add_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add timetable'**
  String timetable_add_failed(Object error);

  /// No description provided for @timetable_overlap.
  ///
  /// In en, this message translates to:
  /// **'There is already a class registered at the same time.'**
  String get timetable_overlap;

  /// No description provided for @required_fields_missing.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields.'**
  String get required_fields_missing;

  /// No description provided for @no_search_results.
  ///
  /// In en, this message translates to:
  /// **'No search results'**
  String get no_search_results;

  /// No description provided for @excel_upload_refreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing timetable...'**
  String get excel_upload_refreshing;

  /// No description provided for @logout_processing.
  ///
  /// In en, this message translates to:
  /// **'Logging out...'**
  String get logout_processing;

  /// No description provided for @logout_error_message.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during logout, but moving to the initial screen.'**
  String get logout_error_message;

  /// No description provided for @data_to_be_deleted.
  ///
  /// In en, this message translates to:
  /// **'Data to be deleted'**
  String get data_to_be_deleted;

  /// No description provided for @deleting_account.
  ///
  /// In en, this message translates to:
  /// **'Deleting account...'**
  String get deleting_account;

  /// No description provided for @excel_tutorial_title.
  ///
  /// In en, this message translates to:
  /// **'How to Download Excel File'**
  String get excel_tutorial_title;

  /// No description provided for @edit_profile_section.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile_section;

  /// No description provided for @delete_account_section.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get delete_account_section;

  /// No description provided for @logout_section.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout_section;

  /// No description provided for @location_share_title.
  ///
  /// In en, this message translates to:
  /// **'Location Sharing'**
  String get location_share_title;

  /// No description provided for @location_share_enabled.
  ///
  /// In en, this message translates to:
  /// **'Location sharing enabled'**
  String get location_share_enabled;

  /// No description provided for @location_share_disabled.
  ///
  /// In en, this message translates to:
  /// **'Location sharing disabled'**
  String get location_share_disabled;

  /// No description provided for @excel_tutorial_previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get excel_tutorial_previous;

  /// No description provided for @room_route_error.
  ///
  /// In en, this message translates to:
  /// **'Error calculating room route. Please search by building.'**
  String get room_route_error;

  /// No description provided for @location_check_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to check current location. Please try again.'**
  String get location_check_error;

  /// No description provided for @server_connection_error.
  ///
  /// In en, this message translates to:
  /// **'There is a problem with server connection. Please try again later.'**
  String get server_connection_error;

  /// No description provided for @route_calculation_error.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while calculating route. Please try again.'**
  String get route_calculation_error;

  /// No description provided for @try_again.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get try_again;

  /// No description provided for @current_location_departure.
  ///
  /// In en, this message translates to:
  /// **'Depart from Current Location'**
  String get current_location_departure;

  /// No description provided for @current_location_departure_default.
  ///
  /// In en, this message translates to:
  /// **'Depart from Default Location'**
  String get current_location_departure_default;

  /// No description provided for @current_location_navigation_start.
  ///
  /// In en, this message translates to:
  /// **'Start navigation from current location'**
  String get current_location_navigation_start;

  /// No description provided for @excel_tutorial_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get excel_tutorial_next;

  /// No description provided for @profile_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profile_edit_title;

  /// No description provided for @profile_edit_subtitle.
  ///
  /// In en, this message translates to:
  /// **'You can modify your personal information'**
  String get profile_edit_subtitle;

  /// No description provided for @account_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get account_delete_title;

  /// No description provided for @account_delete_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account'**
  String get account_delete_subtitle;

  /// No description provided for @logout_title.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout_title;

  /// No description provided for @logout_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Logout from current account'**
  String get logout_subtitle;

  /// No description provided for @location_share_enabled_success.
  ///
  /// In en, this message translates to:
  /// **'Location sharing has been enabled'**
  String get location_share_enabled_success;

  /// No description provided for @location_share_disabled_success.
  ///
  /// In en, this message translates to:
  /// **'Location sharing has been disabled'**
  String get location_share_disabled_success;

  /// No description provided for @profile_edit_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while editing profile'**
  String get profile_edit_error;

  /// No description provided for @inquiry_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load inquiry list'**
  String get inquiry_load_failed;

  /// No description provided for @pull_to_refresh.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh'**
  String get pull_to_refresh;

  /// No description provided for @app_version_number.
  ///
  /// In en, this message translates to:
  /// **'v1.0.0'**
  String get app_version_number;

  /// No description provided for @developer_email_address.
  ///
  /// In en, this message translates to:
  /// **'wsumap41@gmail.com'**
  String get developer_email_address;

  /// No description provided for @developer_github_url.
  ///
  /// In en, this message translates to:
  /// **'https://github.com/WSU-YJB/WSUMAP'**
  String get developer_github_url;

  /// No description provided for @friend_management.
  ///
  /// In en, this message translates to:
  /// **'Friend Management'**
  String get friend_management;

  /// No description provided for @excel_tutorial_file_select.
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get excel_tutorial_file_select;

  /// No description provided for @excel_tutorial_help.
  ///
  /// In en, this message translates to:
  /// **'View Instructions'**
  String get excel_tutorial_help;

  /// No description provided for @excel_upload_file_cancelled.
  ///
  /// In en, this message translates to:
  /// **'File selection was cancelled.'**
  String get excel_upload_file_cancelled;

  /// No description provided for @excel_upload_success_message.
  ///
  /// In en, this message translates to:
  /// **'Timetable has been updated!'**
  String get excel_upload_success_message;

  /// No description provided for @excel_upload_refresh_failed.
  ///
  /// In en, this message translates to:
  /// **'Refresh failed: {error}'**
  String excel_upload_refresh_failed(String error);

  /// No description provided for @excel_upload_failed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String excel_upload_failed(String error);

  /// No description provided for @excel_tutorial_step_1.
  ///
  /// In en, this message translates to:
  /// **'1. Login to Woosong University Information System'**
  String get excel_tutorial_step_1;

  /// No description provided for @excel_tutorial_url.
  ///
  /// In en, this message translates to:
  /// **'https://wsinfo.wsu.ac.kr'**
  String get excel_tutorial_url;

  /// No description provided for @excel_tutorial_image_load_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to load image'**
  String get excel_tutorial_image_load_error;

  /// No description provided for @excel_tutorial_unknown_page.
  ///
  /// In en, this message translates to:
  /// **'Unknown page'**
  String get excel_tutorial_unknown_page;

  /// No description provided for @campus_navigator.
  ///
  /// In en, this message translates to:
  /// **'Campus Navigator'**
  String get campus_navigator;

  /// No description provided for @user_info_not_found.
  ///
  /// In en, this message translates to:
  /// **'User information not found in login response'**
  String get user_info_not_found;

  /// No description provided for @unexpected_login_error.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error occurred during login'**
  String get unexpected_login_error;

  /// No description provided for @login_required.
  ///
  /// In en, this message translates to:
  /// **'Login required'**
  String get login_required;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @register_success.
  ///
  /// In en, this message translates to:
  /// **'Registration completed'**
  String get register_success;

  /// No description provided for @register_success_message.
  ///
  /// In en, this message translates to:
  /// **'Registration completed!\nMoving to login screen.'**
  String get register_success_message;

  /// No description provided for @register_error.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error occurred during registration'**
  String get register_error;

  /// No description provided for @update_user_info.
  ///
  /// In en, this message translates to:
  /// **'Update User Info'**
  String get update_user_info;

  /// No description provided for @update_success.
  ///
  /// In en, this message translates to:
  /// **'User info updated'**
  String get update_success;

  /// No description provided for @update_error.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error occurred during user info update'**
  String get update_error;

  /// No description provided for @delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get delete_account;

  /// No description provided for @delete_success.
  ///
  /// In en, this message translates to:
  /// **'Account deletion completed'**
  String get delete_success;

  /// No description provided for @delete_error.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error occurred during account deletion'**
  String get delete_error;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @student_number.
  ///
  /// In en, this message translates to:
  /// **'Student Number'**
  String get student_number;

  /// No description provided for @user_type.
  ///
  /// In en, this message translates to:
  /// **'User Type'**
  String get user_type;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @required_fields_empty.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields'**
  String get required_fields_empty;

  /// No description provided for @password_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get password_mismatch;

  /// No description provided for @password_too_short.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get password_too_short;

  /// No description provided for @invalid_phone_format.
  ///
  /// In en, this message translates to:
  /// **'Please enter correct phone format (e.g., 010-1234-5678)'**
  String get invalid_phone_format;

  /// No description provided for @invalid_email_format.
  ///
  /// In en, this message translates to:
  /// **'Please enter correct email format'**
  String get invalid_email_format;

  /// No description provided for @required_fields_notice.
  ///
  /// In en, this message translates to:
  /// **'* Marked fields are required'**
  String get required_fields_notice;

  /// No description provided for @welcome_to_campus_navigator.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Woosong Campus Navigator'**
  String get welcome_to_campus_navigator;

  /// No description provided for @enter_real_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter your real name'**
  String get enter_real_name;

  /// No description provided for @phone_format_hint.
  ///
  /// In en, this message translates to:
  /// **'010-1234-5678'**
  String get phone_format_hint;

  /// No description provided for @enter_student_number.
  ///
  /// In en, this message translates to:
  /// **'Please enter student number or professor number'**
  String get enter_student_number;

  /// No description provided for @email_hint.
  ///
  /// In en, this message translates to:
  /// **'example@woosong.org'**
  String get email_hint;

  /// No description provided for @create_account.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get create_account;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @validation_error.
  ///
  /// In en, this message translates to:
  /// **'Please check your input'**
  String get validation_error;

  /// No description provided for @network_error.
  ///
  /// In en, this message translates to:
  /// **'Network error occurred'**
  String get network_error;

  /// No description provided for @server_error.
  ///
  /// In en, this message translates to:
  /// **'Server error occurred'**
  String get server_error;

  /// No description provided for @unknown_error.
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred'**
  String get unknown_error;

  /// No description provided for @woosong_campus_guide_service.
  ///
  /// In en, this message translates to:
  /// **'Woosong University Campus Guide Service'**
  String get woosong_campus_guide_service;

  /// No description provided for @register_description.
  ///
  /// In en, this message translates to:
  /// **'Create a new account to use all features'**
  String get register_description;

  /// No description provided for @login_description.
  ///
  /// In en, this message translates to:
  /// **'Login with existing account to use the service'**
  String get login_description;

  /// No description provided for @browse_as_guest.
  ///
  /// In en, this message translates to:
  /// **'Browse as Guest'**
  String get browse_as_guest;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @campus_navigator_version.
  ///
  /// In en, this message translates to:
  /// **'Campus Navigator v1.0'**
  String get campus_navigator_version;

  /// No description provided for @guest_mode.
  ///
  /// In en, this message translates to:
  /// **'Guest Mode'**
  String get guest_mode;

  /// No description provided for @guest_mode_confirm.
  ///
  /// In en, this message translates to:
  /// **'Would you like to enter guest mode?\n\nIn guest mode, you cannot use friend features and location sharing.'**
  String get guest_mode_confirm;

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Ttarausong'**
  String get app_name;

  /// No description provided for @welcome_to_ttarausong.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Ttarausong'**
  String get welcome_to_ttarausong;

  /// No description provided for @guest_mode_description.
  ///
  /// In en, this message translates to:
  /// **'In guest mode, you can only view basic campus information.\nTo use all features, please register and login.'**
  String get guest_mode_description;

  /// No description provided for @continue_as_guest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continue_as_guest;

  /// No description provided for @moved_to_my_location.
  ///
  /// In en, this message translates to:
  /// **'Automatically moved to my location'**
  String get moved_to_my_location;

  /// No description provided for @friends_screen_bottom_sheet.
  ///
  /// In en, this message translates to:
  /// **'Friends screen is displayed as bottom sheet'**
  String get friends_screen_bottom_sheet;

  /// No description provided for @finding_current_location.
  ///
  /// In en, this message translates to:
  /// **'Finding current location...'**
  String get finding_current_location;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @timetable.
  ///
  /// In en, this message translates to:
  /// **'Timetable'**
  String get timetable;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @inquiry.
  ///
  /// In en, this message translates to:
  /// **'Inquiry'**
  String get inquiry;

  /// No description provided for @my_inquiry.
  ///
  /// In en, this message translates to:
  /// **'My Inquiry'**
  String get my_inquiry;

  /// No description provided for @inquiry_type.
  ///
  /// In en, this message translates to:
  /// **'Inquiry Type'**
  String get inquiry_type;

  /// No description provided for @inquiry_type_required.
  ///
  /// In en, this message translates to:
  /// **'Please select inquiry type'**
  String get inquiry_type_required;

  /// No description provided for @inquiry_type_select_hint.
  ///
  /// In en, this message translates to:
  /// **'Select inquiry type'**
  String get inquiry_type_select_hint;

  /// No description provided for @inquiry_title.
  ///
  /// In en, this message translates to:
  /// **'Inquiry Title'**
  String get inquiry_title;

  /// No description provided for @inquiry_content.
  ///
  /// In en, this message translates to:
  /// **'Inquiry Content'**
  String get inquiry_content;

  /// No description provided for @inquiry_content_hint.
  ///
  /// In en, this message translates to:
  /// **'Please enter inquiry content'**
  String get inquiry_content_hint;

  /// No description provided for @inquiry_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit Inquiry'**
  String get inquiry_submit;

  /// No description provided for @inquiry_submit_success.
  ///
  /// In en, this message translates to:
  /// **'Inquiry submitted successfully'**
  String get inquiry_submit_success;

  /// No description provided for @inquiry_submit_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit inquiry'**
  String get inquiry_submit_failed;

  /// No description provided for @no_inquiry_history.
  ///
  /// In en, this message translates to:
  /// **'No inquiry history'**
  String get no_inquiry_history;

  /// No description provided for @no_inquiry_history_hint.
  ///
  /// In en, this message translates to:
  /// **'No inquiries yet'**
  String get no_inquiry_history_hint;

  /// No description provided for @inquiry_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete Inquiry'**
  String get inquiry_delete;

  /// No description provided for @inquiry_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this inquiry?'**
  String get inquiry_delete_confirm;

  /// No description provided for @inquiry_delete_success.
  ///
  /// In en, this message translates to:
  /// **'Inquiry deleted'**
  String get inquiry_delete_success;

  /// No description provided for @inquiry_delete_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete inquiry'**
  String get inquiry_delete_failed;

  /// No description provided for @inquiry_detail.
  ///
  /// In en, this message translates to:
  /// **'Inquiry Detail'**
  String get inquiry_detail;

  /// No description provided for @inquiry_category.
  ///
  /// In en, this message translates to:
  /// **'Inquiry Category'**
  String get inquiry_category;

  /// No description provided for @inquiry_status.
  ///
  /// In en, this message translates to:
  /// **'Inquiry Status'**
  String get inquiry_status;

  /// No description provided for @inquiry_created_at.
  ///
  /// In en, this message translates to:
  /// **'Inquiry Date'**
  String get inquiry_created_at;

  /// No description provided for @inquiry_title_label.
  ///
  /// In en, this message translates to:
  /// **'Inquiry Title'**
  String get inquiry_title_label;

  /// No description provided for @inquiry_type_bug.
  ///
  /// In en, this message translates to:
  /// **'Bug Report'**
  String get inquiry_type_bug;

  /// No description provided for @inquiry_type_feature.
  ///
  /// In en, this message translates to:
  /// **'Feature Request'**
  String get inquiry_type_feature;

  /// No description provided for @inquiry_type_improvement.
  ///
  /// In en, this message translates to:
  /// **'Improvement Suggestion'**
  String get inquiry_type_improvement;

  /// No description provided for @inquiry_type_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get inquiry_type_other;

  /// No description provided for @inquiry_status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get inquiry_status_pending;

  /// No description provided for @inquiry_status_in_progress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inquiry_status_in_progress;

  /// No description provided for @inquiry_status_answered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get inquiry_status_answered;

  /// No description provided for @phone_required.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phone_required;

  /// No description provided for @building_info.
  ///
  /// In en, this message translates to:
  /// **'Building Info'**
  String get building_info;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @floor_detail_view.
  ///
  /// In en, this message translates to:
  /// **'Floor Detail View'**
  String get floor_detail_view;

  /// No description provided for @no_floor_info.
  ///
  /// In en, this message translates to:
  /// **'No floor information'**
  String get no_floor_info;

  /// No description provided for @floor_detail_info.
  ///
  /// In en, this message translates to:
  /// **'Floor Detail Info'**
  String get floor_detail_info;

  /// No description provided for @search_start_location.
  ///
  /// In en, this message translates to:
  /// **'Search Start Location'**
  String get search_start_location;

  /// No description provided for @search_end_location.
  ///
  /// In en, this message translates to:
  /// **'Search End Location'**
  String get search_end_location;

  /// No description provided for @unified_navigation_in_progress.
  ///
  /// In en, this message translates to:
  /// **'Unified Navigation in Progress'**
  String get unified_navigation_in_progress;

  /// No description provided for @unified_navigation.
  ///
  /// In en, this message translates to:
  /// **'Unified Navigation'**
  String get unified_navigation;

  /// No description provided for @recent_searches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recent_searches;

  /// No description provided for @clear_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get clear_all;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @try_different_keyword.
  ///
  /// In en, this message translates to:
  /// **'Try a different keyword'**
  String get try_different_keyword;

  /// No description provided for @enter_end_location.
  ///
  /// In en, this message translates to:
  /// **'Enter destination'**
  String get enter_end_location;

  /// No description provided for @route_preview.
  ///
  /// In en, this message translates to:
  /// **'Route Preview'**
  String get route_preview;

  /// No description provided for @calculating_optimal_route.
  ///
  /// In en, this message translates to:
  /// **'Calculating optimal route'**
  String get calculating_optimal_route;

  /// No description provided for @set_departure_and_destination.
  ///
  /// In en, this message translates to:
  /// **'Set departure and destination'**
  String get set_departure_and_destination;

  /// No description provided for @start_unified_navigation.
  ///
  /// In en, this message translates to:
  /// **'Start Unified Navigation'**
  String get start_unified_navigation;

  /// No description provided for @departure_indoor.
  ///
  /// In en, this message translates to:
  /// **'Indoor Departure'**
  String get departure_indoor;

  /// No description provided for @to_building_exit.
  ///
  /// In en, this message translates to:
  /// **'To building exit'**
  String get to_building_exit;

  /// No description provided for @outdoor_movement.
  ///
  /// In en, this message translates to:
  /// **'Outdoor Movement'**
  String get outdoor_movement;

  /// No description provided for @to_destination_building.
  ///
  /// In en, this message translates to:
  /// **'To destination building'**
  String get to_destination_building;

  /// No description provided for @arrival_indoor.
  ///
  /// In en, this message translates to:
  /// **'Indoor Arrival'**
  String get arrival_indoor;

  /// No description provided for @to_final_destination.
  ///
  /// In en, this message translates to:
  /// **'To final destination'**
  String get to_final_destination;

  /// No description provided for @total_distance.
  ///
  /// In en, this message translates to:
  /// **'Total Distance'**
  String get total_distance;

  /// No description provided for @route_type.
  ///
  /// In en, this message translates to:
  /// **'Route Type'**
  String get route_type;

  /// No description provided for @building_to_building.
  ///
  /// In en, this message translates to:
  /// **'Building → Building'**
  String get building_to_building;

  /// No description provided for @room_to_building.
  ///
  /// In en, this message translates to:
  /// **'Room → Building'**
  String get room_to_building;

  /// No description provided for @building_to_room.
  ///
  /// In en, this message translates to:
  /// **'Building → Room'**
  String get building_to_room;

  /// No description provided for @room_to_room.
  ///
  /// In en, this message translates to:
  /// **'Room → Room'**
  String get room_to_room;

  /// No description provided for @location_to_building.
  ///
  /// In en, this message translates to:
  /// **'Current Location → Building'**
  String get location_to_building;

  /// No description provided for @unified_route.
  ///
  /// In en, this message translates to:
  /// **'Unified Route'**
  String get unified_route;

  /// No description provided for @status_offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get status_offline;

  /// No description provided for @status_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get status_open;

  /// No description provided for @status_closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get status_closed;

  /// No description provided for @status_24hours.
  ///
  /// In en, this message translates to:
  /// **'24 Hours'**
  String get status_24hours;

  /// No description provided for @status_temp_closed.
  ///
  /// In en, this message translates to:
  /// **'Temporarily Closed'**
  String get status_temp_closed;

  /// No description provided for @status_closed_permanently.
  ///
  /// In en, this message translates to:
  /// **'Permanently Closed'**
  String get status_closed_permanently;

  /// No description provided for @status_next_open.
  ///
  /// In en, this message translates to:
  /// **'Opens at 9 AM'**
  String get status_next_open;

  /// No description provided for @status_next_close.
  ///
  /// In en, this message translates to:
  /// **'Closes at 6 PM'**
  String get status_next_close;

  /// No description provided for @status_next_open_tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Opens tomorrow at 9 AM'**
  String get status_next_open_tomorrow;

  /// No description provided for @set_start_point.
  ///
  /// In en, this message translates to:
  /// **'Set Start Point'**
  String get set_start_point;

  /// No description provided for @set_end_point.
  ///
  /// In en, this message translates to:
  /// **'Set End Point'**
  String get set_end_point;

  /// No description provided for @scheduleDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Schedule'**
  String get scheduleDeleteTitle;

  /// No description provided for @scheduleDeleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please decide carefully'**
  String get scheduleDeleteSubtitle;

  /// No description provided for @scheduleDeleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Schedule to Delete'**
  String get scheduleDeleteLabel;

  /// No description provided for @scheduleDeleteDescription.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" class will be deleted from schedule.\nDeleted schedule cannot be recovered.'**
  String scheduleDeleteDescription(Object title);

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @overlap_message.
  ///
  /// In en, this message translates to:
  /// **'There is already a class registered at this time'**
  String get overlap_message;

  /// No description provided for @friendDeleteSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'{userName} has been removed from friends list'**
  String friendDeleteSuccessMessage(Object userName);

  /// No description provided for @enterFriendIdPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your friend\'s ID'**
  String get enterFriendIdPrompt;

  /// No description provided for @friendId.
  ///
  /// In en, this message translates to:
  /// **'Friend ID'**
  String get friendId;

  /// No description provided for @enterFriendId.
  ///
  /// In en, this message translates to:
  /// **'Enter Friend ID'**
  String get enterFriendId;

  /// No description provided for @sendFriendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Friend Request'**
  String get sendFriendRequest;

  /// No description provided for @realTimeSyncActive.
  ///
  /// In en, this message translates to:
  /// **'Real-time Sync Active'**
  String get realTimeSyncActive;

  /// No description provided for @noSentRequests.
  ///
  /// In en, this message translates to:
  /// **'No sent requests'**
  String get noSentRequests;

  /// No description provided for @newFriendRequests.
  ///
  /// In en, this message translates to:
  /// **'{count} New Friend Requests'**
  String newFriendRequests(int count);

  /// No description provided for @noReceivedRequests.
  ///
  /// In en, this message translates to:
  /// **'No received requests'**
  String get noReceivedRequests;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get id;

  /// No description provided for @requestDate.
  ///
  /// In en, this message translates to:
  /// **'Request Date: {date}'**
  String requestDate(String date);

  /// No description provided for @newBadge.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newBadge;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @noContactInfo.
  ///
  /// In en, this message translates to:
  /// **'No contact info'**
  String get noContactInfo;

  /// No description provided for @friendOfflineError.
  ///
  /// In en, this message translates to:
  /// **'Cannot view offline friend\'s location'**
  String get friendOfflineError;

  /// No description provided for @removeLocation.
  ///
  /// In en, this message translates to:
  /// **'Remove Location'**
  String get removeLocation;

  /// No description provided for @showLocation.
  ///
  /// In en, this message translates to:
  /// **'Show Location'**
  String get showLocation;

  /// No description provided for @friendLocationRemoved.
  ///
  /// In en, this message translates to:
  /// **'{userName}\'s location has been removed'**
  String friendLocationRemoved(String userName);

  /// No description provided for @friendLocationShown.
  ///
  /// In en, this message translates to:
  /// **'{userName}\'s location has been shown'**
  String friendLocationShown(String userName);

  /// No description provided for @errorCannotRemoveLocation.
  ///
  /// In en, this message translates to:
  /// **'Cannot remove location'**
  String get errorCannotRemoveLocation;

  /// No description provided for @my_page.
  ///
  /// In en, this message translates to:
  /// **'My Page'**
  String get my_page;

  /// No description provided for @calculating_route.
  ///
  /// In en, this message translates to:
  /// **'Calculating route...'**
  String get calculating_route;

  /// No description provided for @finding_optimal_route.
  ///
  /// In en, this message translates to:
  /// **'Server is finding optimal route'**
  String get finding_optimal_route;

  /// No description provided for @clear_route.
  ///
  /// In en, this message translates to:
  /// **'Clear Route'**
  String get clear_route;

  /// No description provided for @location_permission_denied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied.\nPlease allow location permission in settings.'**
  String get location_permission_denied;

  /// No description provided for @estimated_time.
  ///
  /// In en, this message translates to:
  /// **'Estimated Time'**
  String get estimated_time;

  /// No description provided for @location_share_update_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update location sharing settings'**
  String get location_share_update_failed;

  /// No description provided for @guest_location_share_success.
  ///
  /// In en, this message translates to:
  /// **'Location sharing is set locally only in guest mode'**
  String get guest_location_share_success;

  /// No description provided for @no_changes.
  ///
  /// In en, this message translates to:
  /// **'No changes'**
  String get no_changes;

  /// No description provided for @password_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Password Confirmation'**
  String get password_confirm_title;

  /// No description provided for @password_confirm_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password to modify account information'**
  String get password_confirm_subtitle;

  /// No description provided for @password_confirm_button.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get password_confirm_button;

  /// No description provided for @password_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get password_required;

  /// No description provided for @password_mismatch_confirm.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get password_mismatch_confirm;

  /// No description provided for @profile_updated.
  ///
  /// In en, this message translates to:
  /// **'Profile has been updated'**
  String get profile_updated;

  /// No description provided for @my_page_subtitle.
  ///
  /// In en, this message translates to:
  /// **'My Information'**
  String get my_page_subtitle;

  /// No description provided for @excel_file.
  ///
  /// In en, this message translates to:
  /// **'Excel File'**
  String get excel_file;

  /// No description provided for @excel_file_tutorial.
  ///
  /// In en, this message translates to:
  /// **'Excel File Tutorial'**
  String get excel_file_tutorial;

  /// No description provided for @image_attachment.
  ///
  /// In en, this message translates to:
  /// **'Image Attachment'**
  String get image_attachment;

  /// No description provided for @max_one_image.
  ///
  /// In en, this message translates to:
  /// **'Max 1 image'**
  String get max_one_image;

  /// No description provided for @photo_attachment.
  ///
  /// In en, this message translates to:
  /// **'Photo Attachment'**
  String get photo_attachment;

  /// No description provided for @photo_attachment_complete.
  ///
  /// In en, this message translates to:
  /// **'Photo Attachment Complete'**
  String get photo_attachment_complete;

  /// No description provided for @image_selection.
  ///
  /// In en, this message translates to:
  /// **'Image Selection'**
  String get image_selection;

  /// No description provided for @select_image_method.
  ///
  /// In en, this message translates to:
  /// **'Please select a method to choose an image'**
  String get select_image_method;

  /// No description provided for @select_from_gallery.
  ///
  /// In en, this message translates to:
  /// **'Select from Gallery'**
  String get select_from_gallery;

  /// No description provided for @select_from_gallery_desc.
  ///
  /// In en, this message translates to:
  /// **'Select image from gallery'**
  String get select_from_gallery_desc;

  /// No description provided for @select_from_file.
  ///
  /// In en, this message translates to:
  /// **'Select from File'**
  String get select_from_file;

  /// No description provided for @select_from_file_desc.
  ///
  /// In en, this message translates to:
  /// **'Select image from file'**
  String get select_from_file_desc;

  /// No description provided for @max_one_image_error.
  ///
  /// In en, this message translates to:
  /// **'You can only attach one image at a time'**
  String get max_one_image_error;

  /// No description provided for @image_selection_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while selecting an image'**
  String get image_selection_error;

  /// No description provided for @inquiry_error_occurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while processing your inquiry'**
  String get inquiry_error_occurred;

  /// No description provided for @inquiry_category_bug.
  ///
  /// In en, this message translates to:
  /// **'Bug Report'**
  String get inquiry_category_bug;

  /// No description provided for @inquiry_category_feature.
  ///
  /// In en, this message translates to:
  /// **'Feature Request'**
  String get inquiry_category_feature;

  /// No description provided for @inquiry_category_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get inquiry_category_other;

  /// No description provided for @inquiry_category_route_error.
  ///
  /// In en, this message translates to:
  /// **'Route Error'**
  String get inquiry_category_route_error;

  /// No description provided for @inquiry_category_place_error.
  ///
  /// In en, this message translates to:
  /// **'Place Error'**
  String get inquiry_category_place_error;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @winter_semester.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get winter_semester;

  /// No description provided for @spring_semester.
  ///
  /// In en, this message translates to:
  /// **'Spring'**
  String get spring_semester;

  /// No description provided for @summer_semester.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get summer_semester;

  /// No description provided for @fall_semester.
  ///
  /// In en, this message translates to:
  /// **'Fall'**
  String get fall_semester;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// No description provided for @add_class.
  ///
  /// In en, this message translates to:
  /// **'Add Class'**
  String get add_class;

  /// No description provided for @edit_class.
  ///
  /// In en, this message translates to:
  /// **'Edit Class'**
  String get edit_class;

  /// No description provided for @delete_class.
  ///
  /// In en, this message translates to:
  /// **'Delete Class'**
  String get delete_class;

  /// No description provided for @class_name.
  ///
  /// In en, this message translates to:
  /// **'Class Name'**
  String get class_name;

  /// No description provided for @classroom.
  ///
  /// In en, this message translates to:
  /// **'Classroom'**
  String get classroom;

  /// No description provided for @start_time.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get start_time;

  /// No description provided for @end_time.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get end_time;

  /// No description provided for @color_selection.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get color_selection;

  /// No description provided for @monday_full.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday_full;

  /// No description provided for @tuesday_full.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday_full;

  /// No description provided for @wednesday_full.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday_full;

  /// No description provided for @thursday_full.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday_full;

  /// No description provided for @friday_full.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday_full;

  /// No description provided for @class_added.
  ///
  /// In en, this message translates to:
  /// **'Class has been added'**
  String get class_added;

  /// No description provided for @class_updated.
  ///
  /// In en, this message translates to:
  /// **'Class has been updated'**
  String get class_updated;

  /// No description provided for @class_deleted.
  ///
  /// In en, this message translates to:
  /// **'Class has been deleted'**
  String get class_deleted;

  /// No description provided for @delete_class_confirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete {className}?'**
  String delete_class_confirm(String className);

  /// No description provided for @view_on_map.
  ///
  /// In en, this message translates to:
  /// **'View on Map'**
  String get view_on_map;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @schedule_time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get schedule_time;

  /// No description provided for @schedule_day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get schedule_day;

  /// No description provided for @map_feature_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Map feature will be added later'**
  String get map_feature_coming_soon;

  /// No description provided for @current_year.
  ///
  /// In en, this message translates to:
  /// **'{year}'**
  String current_year(int year);

  /// No description provided for @my_friends.
  ///
  /// In en, this message translates to:
  /// **'My Friends'**
  String get my_friends;

  /// No description provided for @online_friends.
  ///
  /// In en, this message translates to:
  /// **'Total {total} • Online {online}'**
  String online_friends(int total, int online);

  /// No description provided for @add_friend.
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get add_friend;

  /// No description provided for @friend_name_or_id.
  ///
  /// In en, this message translates to:
  /// **'Enter friend\'s name or student ID'**
  String get friend_name_or_id;

  /// No description provided for @friend_request_sent.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent'**
  String get friend_request_sent;

  /// No description provided for @in_class.
  ///
  /// In en, this message translates to:
  /// **'In Class'**
  String get in_class;

  /// No description provided for @last_location.
  ///
  /// In en, this message translates to:
  /// **'Last location: {location}'**
  String last_location(String location);

  /// No description provided for @central_library.
  ///
  /// In en, this message translates to:
  /// **'Central Library'**
  String get central_library;

  /// No description provided for @engineering_building.
  ///
  /// In en, this message translates to:
  /// **'Engineering Building 201'**
  String get engineering_building;

  /// No description provided for @student_center.
  ///
  /// In en, this message translates to:
  /// **'Student Center'**
  String get student_center;

  /// No description provided for @cafeteria.
  ///
  /// In en, this message translates to:
  /// **'Cafeteria'**
  String get cafeteria;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @start_chat_with.
  ///
  /// In en, this message translates to:
  /// **'Starting chat with {name}'**
  String start_chat_with(String name);

  /// No description provided for @view_location_on_map.
  ///
  /// In en, this message translates to:
  /// **'View {name}\'s location on map'**
  String view_location_on_map(String name);

  /// No description provided for @calling.
  ///
  /// In en, this message translates to:
  /// **'Calling {name}'**
  String calling(String name);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchBuildings.
  ///
  /// In en, this message translates to:
  /// **'Search buildings...'**
  String get searchBuildings;

  /// No description provided for @myLocation.
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get myLocation;

  /// No description provided for @navigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigation;

  /// No description provided for @route.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @within_minute.
  ///
  /// In en, this message translates to:
  /// **'within 1 minute'**
  String get within_minute;

  /// No description provided for @minutes_only.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String minutes_only(Object minutes);

  /// No description provided for @hours_only.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours'**
  String hours_only(Object hours);

  /// No description provided for @hours_and_minutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours {minutes} minutes'**
  String hours_and_minutes(Object hours, Object minutes);

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @start_navigation_from_current_location.
  ///
  /// In en, this message translates to:
  /// **'Start navigation from current location'**
  String get start_navigation_from_current_location;

  /// No description provided for @my_location_set_as_start.
  ///
  /// In en, this message translates to:
  /// **'My location set as start point'**
  String get my_location_set_as_start;

  /// No description provided for @default_location_set_as_start.
  ///
  /// In en, this message translates to:
  /// **'Default location set as start point'**
  String get default_location_set_as_start;

  /// No description provided for @start_navigation.
  ///
  /// In en, this message translates to:
  /// **'Start Navigation'**
  String get start_navigation;

  /// No description provided for @navigation_ended.
  ///
  /// In en, this message translates to:
  /// **'Navigation has ended'**
  String get navigation_ended;

  /// No description provided for @arrival.
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get arrival;

  /// No description provided for @outdoor_movement_distance.
  ///
  /// In en, this message translates to:
  /// **'Outdoor Movement Distance'**
  String get outdoor_movement_distance;

  /// No description provided for @indoor_arrival.
  ///
  /// In en, this message translates to:
  /// **'Indoor Arrival'**
  String get indoor_arrival;

  /// No description provided for @indoor_departure.
  ///
  /// In en, this message translates to:
  /// **'Indoor Departure'**
  String get indoor_departure;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @findRoute.
  ///
  /// In en, this message translates to:
  /// **'Find Route'**
  String get findRoute;

  /// No description provided for @clearRoute.
  ///
  /// In en, this message translates to:
  /// **'Clear Route'**
  String get clearRoute;

  /// No description provided for @setAsStart.
  ///
  /// In en, this message translates to:
  /// **'Set as Start'**
  String get setAsStart;

  /// No description provided for @setAsDestination.
  ///
  /// In en, this message translates to:
  /// **'Set as Destination'**
  String get setAsDestination;

  /// No description provided for @navigateFromHere.
  ///
  /// In en, this message translates to:
  /// **'Navigate from Here'**
  String get navigateFromHere;

  /// No description provided for @buildingInfo.
  ///
  /// In en, this message translates to:
  /// **'Building Information'**
  String get buildingInfo;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required'**
  String get locationPermissionRequired;

  /// No description provided for @enableLocationServices.
  ///
  /// In en, this message translates to:
  /// **'Please enable location services'**
  String get enableLocationServices;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @friends_count_status.
  ///
  /// In en, this message translates to:
  /// **'Total {total} • Online {online}'**
  String friends_count_status(int total, int online);

  /// No description provided for @enter_friend_info.
  ///
  /// In en, this message translates to:
  /// **'Enter friend\'s name or student ID'**
  String get enter_friend_info;

  /// No description provided for @show_location_on_map.
  ///
  /// In en, this message translates to:
  /// **'Show {name}\'s location on map'**
  String show_location_on_map(String name);

  /// No description provided for @location_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to find your location'**
  String get location_error;

  /// No description provided for @view_floor_plan.
  ///
  /// In en, this message translates to:
  /// **'View Floor Plan'**
  String get view_floor_plan;

  /// No description provided for @floor_plan_title.
  ///
  /// In en, this message translates to:
  /// **'{buildingName} Floor Plan'**
  String floor_plan_title(String buildingName);

  /// No description provided for @floor_plan_not_available.
  ///
  /// In en, this message translates to:
  /// **'Unable to load floor plan image'**
  String get floor_plan_not_available;

  /// No description provided for @floor_plan_default_text.
  ///
  /// In en, this message translates to:
  /// **'Floor Plan'**
  String get floor_plan_default_text;

  /// No description provided for @delete_account_success.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted'**
  String get delete_account_success;

  /// No description provided for @convenience_store.
  ///
  /// In en, this message translates to:
  /// **'Convenience Store'**
  String get convenience_store;

  /// No description provided for @vending_machine.
  ///
  /// In en, this message translates to:
  /// **'Vending Machine'**
  String get vending_machine;

  /// No description provided for @printer.
  ///
  /// In en, this message translates to:
  /// **'Printer'**
  String get printer;

  /// No description provided for @copier.
  ///
  /// In en, this message translates to:
  /// **'Copier'**
  String get copier;

  /// No description provided for @atm.
  ///
  /// In en, this message translates to:
  /// **'ATM'**
  String get atm;

  /// No description provided for @bank_atm.
  ///
  /// In en, this message translates to:
  /// **'Bank(ATM)'**
  String get bank_atm;

  /// No description provided for @medical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get medical;

  /// No description provided for @health_center.
  ///
  /// In en, this message translates to:
  /// **'Health Center'**
  String get health_center;

  /// No description provided for @gym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get gym;

  /// No description provided for @fitness_center.
  ///
  /// In en, this message translates to:
  /// **'Fitness Center'**
  String get fitness_center;

  /// No description provided for @lounge.
  ///
  /// In en, this message translates to:
  /// **'Lounge'**
  String get lounge;

  /// No description provided for @extinguisher.
  ///
  /// In en, this message translates to:
  /// **'Extinguisher'**
  String get extinguisher;

  /// No description provided for @water_purifier.
  ///
  /// In en, this message translates to:
  /// **'Water Purifier'**
  String get water_purifier;

  /// No description provided for @bookstore.
  ///
  /// In en, this message translates to:
  /// **'Bookstore'**
  String get bookstore;

  /// No description provided for @post_office.
  ///
  /// In en, this message translates to:
  /// **'Post Office'**
  String get post_office;

  /// No description provided for @instructionMoveToDestination.
  ///
  /// In en, this message translates to:
  /// **'Move to {place}'**
  String instructionMoveToDestination(String place);

  /// No description provided for @markerDeparture.
  ///
  /// In en, this message translates to:
  /// **'Departure'**
  String get markerDeparture;

  /// No description provided for @markerArrival.
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get markerArrival;

  /// No description provided for @errorCannotOpenPhoneApp.
  ///
  /// In en, this message translates to:
  /// **'Cannot open the phone app.'**
  String get errorCannotOpenPhoneApp;

  /// No description provided for @emailCopied.
  ///
  /// In en, this message translates to:
  /// **'Email copied to clipboard.'**
  String get emailCopied;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @noDetailedInfoRegistered.
  ///
  /// In en, this message translates to:
  /// **'No detailed information registered.'**
  String get noDetailedInfoRegistered;

  /// No description provided for @setDeparture.
  ///
  /// In en, this message translates to:
  /// **'Set as Departure'**
  String get setDeparture;

  /// No description provided for @setArrival.
  ///
  /// In en, this message translates to:
  /// **'Set as Arrival'**
  String get setArrival;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String errorOccurred(Object error);

  /// No description provided for @instructionExitToOutdoor.
  ///
  /// In en, this message translates to:
  /// **'Move to building exit'**
  String get instructionExitToOutdoor;

  /// No description provided for @instructionMoveToDestinationBuilding.
  ///
  /// In en, this message translates to:
  /// **'Move to {building} building'**
  String instructionMoveToDestinationBuilding(String building);

  /// No description provided for @instructionMoveToRoom.
  ///
  /// In en, this message translates to:
  /// **'Move to destination room'**
  String get instructionMoveToRoom;

  /// No description provided for @instructionArrived.
  ///
  /// In en, this message translates to:
  /// **'You have arrived at your destination!'**
  String get instructionArrived;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @woosong_library_w1.
  ///
  /// In en, this message translates to:
  /// **'Woosong Library (W1)'**
  String get woosong_library_w1;

  /// No description provided for @woosong_library_info.
  ///
  /// In en, this message translates to:
  /// **'B2F\tParking\nB1F\tSmall Auditorium, Equipment Room, Electrical Room, Parking\n1F\tCareer Support Center (630-9976), Loan Desk, Information Lounge\n2F\tGeneral Reading Room, Group Study Room\n3F\tGeneral Reading Room\n4F\tLiterature Books/Western Books'**
  String get woosong_library_info;

  /// No description provided for @educational_facility.
  ///
  /// In en, this message translates to:
  /// **'Educational Facility'**
  String get educational_facility;

  /// No description provided for @operating.
  ///
  /// In en, this message translates to:
  /// **'Operating'**
  String get operating;

  /// No description provided for @woosong_library_desc.
  ///
  /// In en, this message translates to:
  /// **'Woosong University Central Library'**
  String get woosong_library_desc;

  /// No description provided for @sol_cafe.
  ///
  /// In en, this message translates to:
  /// **'Sol Cafe'**
  String get sol_cafe;

  /// No description provided for @sol_cafe_info.
  ///
  /// In en, this message translates to:
  /// **'1F\tRestaurant\n2F\tCafe'**
  String get sol_cafe_info;

  /// No description provided for @cafe.
  ///
  /// In en, this message translates to:
  /// **'Cafe'**
  String get cafe;

  /// No description provided for @sol_cafe_desc.
  ///
  /// In en, this message translates to:
  /// **'Campus cafe'**
  String get sol_cafe_desc;

  /// No description provided for @cheongun_1_dormitory.
  ///
  /// In en, this message translates to:
  /// **'Cheongun 1 Dormitory'**
  String get cheongun_1_dormitory;

  /// No description provided for @cheongun_1_dormitory_info.
  ///
  /// In en, this message translates to:
  /// **'1F\tPractice Room\n2F\tStudent Cafeteria\n2F\tCheongun 1 Dormitory (Female) (629-6542)\n2F\tLiving Hall\n3~5F\tLiving Hall'**
  String get cheongun_1_dormitory_info;

  /// No description provided for @dormitory.
  ///
  /// In en, this message translates to:
  /// **'Dormitory'**
  String get dormitory;

  /// No description provided for @cheongun_1_dormitory_desc.
  ///
  /// In en, this message translates to:
  /// **'Female student dormitory'**
  String get cheongun_1_dormitory_desc;

  /// No description provided for @industry_cooperation_w2.
  ///
  /// In en, this message translates to:
  /// **'Industry Cooperation (W2)'**
  String get industry_cooperation_w2;

  /// No description provided for @industry_cooperation_info.
  ///
  /// In en, this message translates to:
  /// **'1F\tIndustry Cooperation\n2F\tArchitectural Engineering (630-9720)\n3F\tWoosong University Convergence Technology Institute, Industry-University-Research Comprehensive Enterprise Support Center\n4F\tCorporate Research Institute, LG CNS Classroom, Railway Digital Academy Classroom'**
  String get industry_cooperation_info;

  /// No description provided for @industry_cooperation_desc.
  ///
  /// In en, this message translates to:
  /// **'Industry cooperation and research facilities'**
  String get industry_cooperation_desc;

  /// No description provided for @rotc_w2_1.
  ///
  /// In en, this message translates to:
  /// **'ROTC (W2-1)'**
  String get rotc_w2_1;

  /// No description provided for @rotc_info.
  ///
  /// In en, this message translates to:
  /// **'\tROTC (630-4601)'**
  String get rotc_info;

  /// No description provided for @rotc_desc.
  ///
  /// In en, this message translates to:
  /// **'ROTC facilities'**
  String get rotc_desc;

  /// No description provided for @military_facility.
  ///
  /// In en, this message translates to:
  /// **'Military Facility'**
  String get military_facility;

  /// No description provided for @international_dormitory_w3.
  ///
  /// In en, this message translates to:
  /// **'International Dormitory (W3)'**
  String get international_dormitory_w3;

  /// No description provided for @international_dormitory_info.
  ///
  /// In en, this message translates to:
  /// **'1F\tInternational Student Support Team (629-6623)\n1F\tStudent Cafeteria\n2F\tInternational Dormitory (629-6655)\n2F\tHealth Center\n3~12F\tLiving Hall'**
  String get international_dormitory_info;

  /// No description provided for @international_dormitory_desc.
  ///
  /// In en, this message translates to:
  /// **'International student dormitory'**
  String get international_dormitory_desc;

  /// No description provided for @railway_logistics_w4.
  ///
  /// In en, this message translates to:
  /// **'Railway Logistics (W4)'**
  String get railway_logistics_w4;

  /// No description provided for @railway_logistics_info.
  ///
  /// In en, this message translates to:
  /// **'B1F\tPractice Room\n1F\tPractice Room\n2F\tRailway Construction System Department (629-6710)\n2F\tRailway Vehicle System Department (629-6780)\n3F\tClassroom/Practice Room\n4F\tRailway System Department (630-6730,9700)\n5F\tFire Prevention Department (629-6770)\n5F\tLogistics System Department (630-9330)'**
  String get railway_logistics_info;

  /// No description provided for @railway_logistics_desc.
  ///
  /// In en, this message translates to:
  /// **'Railway and logistics related departments'**
  String get railway_logistics_desc;

  /// No description provided for @health_medical_science_w5.
  ///
  /// In en, this message translates to:
  /// **'Health Medical Science (W5)'**
  String get health_medical_science_w5;

  /// No description provided for @health_medical_science_info.
  ///
  /// In en, this message translates to:
  /// **'B1F\tParking\n1F\tAudio-Visual Room/Parking\n2F\tClassroom\n2F\tExercise Health Rehabilitation Department (630-9840)\n3F\tEmergency Medical Department (630-9280)\n3F\tNursing Department (630-9290)\n4F\tOccupational Therapy Department (630-9820)\n4F\tSpeech Therapy Hearing Rehabilitation Department (630-9220)\n5F\tPhysical Therapy Department (630-4620)\n5F\tHealth Medical Management Department (630-4610)\n5F\tClassroom\n6F\tRailway Management Department (630-9770)'**
  String get health_medical_science_info;

  /// No description provided for @health_medical_science_desc.
  ///
  /// In en, this message translates to:
  /// **'Health and medical related departments'**
  String get health_medical_science_desc;

  /// No description provided for @liberal_arts_w6.
  ///
  /// In en, this message translates to:
  /// **'Liberal Arts Education (W6)'**
  String get liberal_arts_w6;

  /// No description provided for @liberal_arts_info.
  ///
  /// In en, this message translates to:
  /// **'2F\tClassroom\n3F\tClassroom\n4F\tClassroom\n5F\tClassroom'**
  String get liberal_arts_info;

  /// No description provided for @liberal_arts_desc.
  ///
  /// In en, this message translates to:
  /// **'Liberal arts classroom'**
  String get liberal_arts_desc;

  /// No description provided for @woosong_hall_w7.
  ///
  /// In en, this message translates to:
  /// **'Woosong Hall (W7)'**
  String get woosong_hall_w7;

  /// No description provided for @woosong_hall_info.
  ///
  /// In en, this message translates to:
  /// **'1F\tAdmissions Office (630-9627)\n1F\tAcademic Affairs Office (630-9622)\n1F\tFacilities Office (630-9970)\n1F\tManagement Team (629-6658)\n1F\tIndustry Cooperation (630-4653)\n1F\tExternal Cooperation Office (630-9636)\n2F\tStrategic Planning Office (630-9102)\n2F\tGeneral Affairs Office-General Affairs, Procurement (630-9653)\n2F\tPlanning Office (630-9661)\n3F\tPresident\'s Office (630-8501)\n3F\tInternational Exchange Office (630-9373)\n3F\tEarly Childhood Education Department (630-9360)\n3F\tBusiness Administration Major (629-6640)\n3F\tFinance/Real Estate Major (630-9350)\n4F\tLarge Conference Room\n5F\tConference Room'**
  String get woosong_hall_info;

  /// No description provided for @woosong_hall_desc.
  ///
  /// In en, this message translates to:
  /// **'University headquarters building'**
  String get woosong_hall_desc;

  /// No description provided for @woosong_kindergarten_w8.
  ///
  /// In en, this message translates to:
  /// **'Woosong Kindergarten (W8)'**
  String get woosong_kindergarten_w8;

  /// No description provided for @woosong_kindergarten_info.
  ///
  /// In en, this message translates to:
  /// **'1F, 2F\tWoosong Kindergarten (629~6750~1)'**
  String get woosong_kindergarten_info;

  /// No description provided for @woosong_kindergarten_desc.
  ///
  /// In en, this message translates to:
  /// **'University affiliated kindergarten'**
  String get woosong_kindergarten_desc;

  /// No description provided for @kindergarten.
  ///
  /// In en, this message translates to:
  /// **'Kindergarten'**
  String get kindergarten;

  /// No description provided for @west_campus_culinary_w9.
  ///
  /// In en, this message translates to:
  /// **'West Campus Culinary Academy (W9)'**
  String get west_campus_culinary_w9;

  /// No description provided for @west_campus_culinary_info.
  ///
  /// In en, this message translates to:
  /// **'B1F\tPractice Room\n1F\tPractice Room\n2F\tPractice Room'**
  String get west_campus_culinary_info;

  /// No description provided for @west_campus_culinary_desc.
  ///
  /// In en, this message translates to:
  /// **'Culinary practice facilities'**
  String get west_campus_culinary_desc;

  /// No description provided for @social_welfare_w10.
  ///
  /// In en, this message translates to:
  /// **'Social Welfare Convergence (W10)'**
  String get social_welfare_w10;

  /// No description provided for @social_welfare_info.
  ///
  /// In en, this message translates to:
  /// **'1F\tAudio-Visual Room/Practice Room\n2F\tClassroom/Practice Room\n3F\tSocial Welfare Department (630-9830)\n3F\tGlobal Child Education Department (630-9260)\n4F\tClassroom/Practice Room\n5F\tClassroom/Practice Room'**
  String get social_welfare_info;

  /// No description provided for @social_welfare_desc.
  ///
  /// In en, this message translates to:
  /// **'Social welfare related departments'**
  String get social_welfare_desc;

  /// No description provided for @gymnasium_w11.
  ///
  /// In en, this message translates to:
  /// **'Gymnasium (W11)'**
  String get gymnasium_w11;

  /// No description provided for @gymnasium_info.
  ///
  /// In en, this message translates to:
  /// **'1F\tPhysical Training Room\n2F~4F\tGymnasium'**
  String get gymnasium_info;

  /// No description provided for @gymnasium_desc.
  ///
  /// In en, this message translates to:
  /// **'Sports facilities'**
  String get gymnasium_desc;

  /// No description provided for @sports_facility.
  ///
  /// In en, this message translates to:
  /// **'Sports Facility'**
  String get sports_facility;

  /// No description provided for @sica_w12.
  ///
  /// In en, this message translates to:
  /// **'SICA (W12)'**
  String get sica_w12;

  /// No description provided for @sica_info.
  ///
  /// In en, this message translates to:
  /// **'B1F\tPractice Room\n1F\tStarrico Cafe\n2F~3F\tClassroom\n5F\tGlobal Culinary Department (629-6860)'**
  String get sica_info;

  /// No description provided for @sica_desc.
  ///
  /// In en, this message translates to:
  /// **'International Culinary Academy'**
  String get sica_desc;

  /// No description provided for @woosong_tower_w13.
  ///
  /// In en, this message translates to:
  /// **'Woosong Tower (W13)'**
  String get woosong_tower_w13;

  /// No description provided for @woosong_tower_info.
  ///
  /// In en, this message translates to:
  /// **'B1~1F\tParking\n2F\tParking, Solpine Bakery (629-6429)\n4F\tSeminar Room\n5F\tClassroom\n6F\tFood Service Culinary Nutrition Department (630-9380,9740)\n7F\tClassroom\n8F\tFood Service, Culinary Management Major (630-9250)\n9F\tClassroom/Practice Room\n10F\tFood Service Culinary Major (629-6821), Global Korean Cuisine Major (629-6560)\n11F, 12F\tPractice Room\n13F\tSolpine Restaurant (629-6610)'**
  String get woosong_tower_info;

  /// No description provided for @woosong_tower_desc.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive education facility'**
  String get woosong_tower_desc;

  /// No description provided for @complex_facility.
  ///
  /// In en, this message translates to:
  /// **'Complex Facility'**
  String get complex_facility;

  /// No description provided for @culinary_center_w14.
  ///
  /// In en, this message translates to:
  /// **'Culinary Center (W14)'**
  String get culinary_center_w14;

  /// No description provided for @culinary_center_info.
  ///
  /// In en, this message translates to:
  /// **'1F\tClassroom/Practice Room\n2F\tClassroom/Practice Room\n3F\tClassroom/Practice Room\n4F\tClassroom/Practice Room\n5F\tClassroom/Practice Room'**
  String get culinary_center_info;

  /// No description provided for @culinary_center_desc.
  ///
  /// In en, this message translates to:
  /// **'Culinary major education facility'**
  String get culinary_center_desc;

  /// No description provided for @food_architecture_w15.
  ///
  /// In en, this message translates to:
  /// **'Food Architecture (W15)'**
  String get food_architecture_w15;

  /// No description provided for @food_architecture_info.
  ///
  /// In en, this message translates to:
  /// **'B1F\tPractice Room\n1F\tPractice Room\n2F\tClassroom\n3F\tClassroom\n4F\tClassroom\n5F\tClassroom'**
  String get food_architecture_info;

  /// No description provided for @food_architecture_desc.
  ///
  /// In en, this message translates to:
  /// **'Food and architecture related departments'**
  String get food_architecture_desc;

  /// No description provided for @student_hall_w16.
  ///
  /// In en, this message translates to:
  /// **'Student Hall (W16)'**
  String get student_hall_w16;

  /// No description provided for @student_hall_info.
  ///
  /// In en, this message translates to:
  /// **'1F\tStudent Cafeteria, Campus Bookstore (629-6127)\n2F\tFaculty Cafeteria\n3F\tClub Room\n3F\tStudent Welfare Office-Student Team (630-9641), Scholarship Team (630-9876)\n3F\tDisabled Student Support Center (630-9903)\n3F\tSocial Service Corps (630-9904)\n3F\tStudent Counseling Center (630-9645)\n4F\tReturn to School Support Center (630-9139)\n4F\tTeaching and Learning Development Center (630-9285)'**
  String get student_hall_info;

  /// No description provided for @student_hall_desc.
  ///
  /// In en, this message translates to:
  /// **'Student welfare facility'**
  String get student_hall_desc;

  /// No description provided for @media_convergence_w17.
  ///
  /// In en, this message translates to:
  /// **'Media Convergence (W17)'**
  String get media_convergence_w17;

  /// No description provided for @media_convergence_info.
  ///
  /// In en, this message translates to:
  /// **'B1F\tClassroom/Practice Room\n1F\tMedia Design/Video Major (630-9750)\n2F\tClassroom/Practice Room\n3F\tGame Multimedia Major (630-9270)\n5F\tClassroom/Practice Room'**
  String get media_convergence_info;

  /// No description provided for @media_convergence_desc.
  ///
  /// In en, this message translates to:
  /// **'Media related departments'**
  String get media_convergence_desc;

  /// No description provided for @woosong_arts_center_w18.
  ///
  /// In en, this message translates to:
  /// **'Woosong Arts Center (W18)'**
  String get woosong_arts_center_w18;

  /// No description provided for @woosong_arts_center_info.
  ///
  /// In en, this message translates to:
  /// **'B1F\tPerformance Preparation Room\n1F\tWoosong Arts Center (629-6363)\n2F\tPractice Room\n3F\tPractice Room\n4F\tPractice Room\n5F\tPractice Room'**
  String get woosong_arts_center_info;

  /// No description provided for @woosong_arts_center_desc.
  ///
  /// In en, this message translates to:
  /// **'Arts performance facility'**
  String get woosong_arts_center_desc;

  /// No description provided for @west_campus_andycut_w19.
  ///
  /// In en, this message translates to:
  /// **'West Campus AndyCut Building (W19)'**
  String get west_campus_andycut_w19;

  /// No description provided for @west_campus_andycut_info.
  ///
  /// In en, this message translates to:
  /// **'2F\tGlobal Convergence Business Department (630-9249)\n2F\tLiberal Studies Department (630-9390)\n2F\tAI/Big Data Department (630-9807)\n2F\tGlobal Hotel Management Department (630-9249)\n2F\tGlobal Media Video Department (630-9346)\n2F\tGlobal Medical Service Management Department (630-9283)\n2F\tGlobal Railway/Transportation Logistics Department (630-9347)\n2F\tGlobal Food Service Entrepreneurship Department (629-6860)'**
  String get west_campus_andycut_info;

  /// No description provided for @west_campus_andycut_desc.
  ///
  /// In en, this message translates to:
  /// **'Global department building'**
  String get west_campus_andycut_desc;

  /// No description provided for @search_campus_buildings.
  ///
  /// In en, this message translates to:
  /// **'Search campus buildings'**
  String get search_campus_buildings;

  /// No description provided for @building_details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get building_details;

  /// No description provided for @parking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get parking;

  /// No description provided for @accessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// No description provided for @facilities.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get facilities;

  /// No description provided for @elevator.
  ///
  /// In en, this message translates to:
  /// **'Elevator'**
  String get elevator;

  /// No description provided for @restroom.
  ///
  /// In en, this message translates to:
  /// **'Restroom'**
  String get restroom;

  /// No description provided for @navigate_from_current_location.
  ///
  /// In en, this message translates to:
  /// **'Navigate from current location'**
  String get navigate_from_current_location;

  /// No description provided for @edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter name'**
  String get nameRequired;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get emailRequired;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get saveSuccess;

  /// No description provided for @app_info.
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get app_info;

  /// No description provided for @app_version.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get app_version;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @developer_name.
  ///
  /// In en, this message translates to:
  /// **'Name: Hong Gil-dong'**
  String get developer_name;

  /// No description provided for @developer_email.
  ///
  /// In en, this message translates to:
  /// **'Email: wsumap41@gmail.com'**
  String get developer_email;

  /// No description provided for @developer_github.
  ///
  /// In en, this message translates to:
  /// **'GitHub: github.com/WSU-YJB/WSUMAP'**
  String get developer_github;

  /// No description provided for @no_help_images.
  ///
  /// In en, this message translates to:
  /// **'No help images'**
  String get no_help_images;

  /// No description provided for @description_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get description_hint;

  /// No description provided for @my_info.
  ///
  /// In en, this message translates to:
  /// **'My Info'**
  String get my_info;

  /// No description provided for @guest_user.
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guest_user;

  /// No description provided for @guest_role.
  ///
  /// In en, this message translates to:
  /// **'Guest Role'**
  String get guest_role;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @edit_profile_subtitle.
  ///
  /// In en, this message translates to:
  /// **'You can modify your personal information'**
  String get edit_profile_subtitle;

  /// No description provided for @help_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Check app usage'**
  String get help_subtitle;

  /// No description provided for @app_info_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Version information and developer information'**
  String get app_info_subtitle;

  /// No description provided for @delete_account_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account'**
  String get delete_account_subtitle;

  /// No description provided for @login_message.
  ///
  /// In en, this message translates to:
  /// **'Login or register\nTo use all features'**
  String get login_message;

  /// No description provided for @login_signup.
  ///
  /// In en, this message translates to:
  /// **'Login / Register'**
  String get login_signup;

  /// No description provided for @delete_account_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get delete_account_confirm;

  /// No description provided for @delete_account_message.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete your account?'**
  String get delete_account_message;

  /// No description provided for @logout_confirm.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout_confirm;

  /// No description provided for @logout_message.
  ///
  /// In en, this message translates to:
  /// **'Do you want to logout?'**
  String get logout_message;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @feature_in_progress.
  ///
  /// In en, this message translates to:
  /// **'Feature in progress'**
  String get feature_in_progress;

  /// No description provided for @delete_feature_in_progress.
  ///
  /// In en, this message translates to:
  /// **'Account deletion feature is in progress'**
  String get delete_feature_in_progress;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get title;

  /// No description provided for @email_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get email_required;

  /// No description provided for @name_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter name'**
  String get name_required;

  /// No description provided for @cancelFriendRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Friend Request'**
  String get cancelFriendRequest;

  /// No description provided for @cancelFriendRequestConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to cancel the friend request sent to {name}?'**
  String cancelFriendRequestConfirm(String name);

  /// No description provided for @attached_image.
  ///
  /// In en, this message translates to:
  /// **'Attached Image'**
  String get attached_image;

  /// No description provided for @answer_section_title.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get answer_section_title;

  /// No description provided for @inquiry_default_answer.
  ///
  /// In en, this message translates to:
  /// **'This is the answer to your inquiry. If you have any additional questions, please feel free to contact us.'**
  String get inquiry_default_answer;

  /// No description provided for @answer_date_prefix.
  ///
  /// In en, this message translates to:
  /// **'Answered on:'**
  String get answer_date_prefix;

  /// No description provided for @waiting_answer_status.
  ///
  /// In en, this message translates to:
  /// **'Waiting for answer'**
  String get waiting_answer_status;

  /// No description provided for @waiting_answer_message.
  ///
  /// In en, this message translates to:
  /// **'We are reviewing your inquiry and will reply as soon as possible.'**
  String get waiting_answer_message;

  /// No description provided for @status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get status_pending;

  /// No description provided for @status_answered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get status_answered;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get cancelRequest;

  /// No description provided for @friendDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Friend'**
  String get friendDeleteTitle;

  /// No description provided for @friendDeleteWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get friendDeleteWarning;

  /// No description provided for @friendDeleteHeader.
  ///
  /// In en, this message translates to:
  /// **'Delete Friend'**
  String get friendDeleteHeader;

  /// No description provided for @friendDeleteToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Please enter the name of the friend to delete'**
  String get friendDeleteToConfirm;

  /// No description provided for @friendDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get friendDeleteCancel;

  /// No description provided for @friendDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get friendDeleteButton;

  /// No description provided for @friendManagementAndRequests.
  ///
  /// In en, this message translates to:
  /// **'Friend Management and Requests'**
  String get friendManagementAndRequests;

  /// No description provided for @realTimeSyncStatus.
  ///
  /// In en, this message translates to:
  /// **'Real-time Sync Status'**
  String get realTimeSyncStatus;

  /// No description provided for @friendManagement.
  ///
  /// In en, this message translates to:
  /// **'Friend Management'**
  String get friendManagement;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @sentRequestsCount.
  ///
  /// In en, this message translates to:
  /// **'Sent ({count})'**
  String sentRequestsCount(int count);

  /// No description provided for @receivedRequestsCount.
  ///
  /// In en, this message translates to:
  /// **'Received ({count})'**
  String receivedRequestsCount(int count);

  /// No description provided for @friendCount.
  ///
  /// In en, this message translates to:
  /// **'My Friends ({count})'**
  String friendCount(int count);

  /// No description provided for @noFriends.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any friends yet.\nTap the + button above to add friends!'**
  String get noFriends;

  /// No description provided for @open_settings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get open_settings;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @basic_info.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basic_info;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @floor_plan.
  ///
  /// In en, this message translates to:
  /// **'Floor Plan'**
  String get floor_plan;

  /// No description provided for @indoorMap.
  ///
  /// In en, this message translates to:
  /// **'Indoor Map'**
  String get indoorMap;

  /// No description provided for @showBuildingMarker.
  ///
  /// In en, this message translates to:
  /// **'Show Building Marker'**
  String get showBuildingMarker;

  /// No description provided for @search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search campus buildings'**
  String get search_hint;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by building or room'**
  String get searchHint;

  /// No description provided for @searchInitialGuide.
  ///
  /// In en, this message translates to:
  /// **'Search for a building or room'**
  String get searchInitialGuide;

  /// No description provided for @searchHintExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. W19, Engineering Hall, Room 401'**
  String get searchHintExample;

  /// No description provided for @searchLoading.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searchLoading;

  /// No description provided for @searchNoResult.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get searchNoResult;

  /// No description provided for @searchTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get searchTryAgain;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @enter_title.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get enter_title;

  /// No description provided for @content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// No description provided for @enter_content.
  ///
  /// In en, this message translates to:
  /// **'Please enter content'**
  String get enter_content;

  /// No description provided for @restaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurant;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @fire_extinguisher.
  ///
  /// In en, this message translates to:
  /// **'Fire Extinguisher'**
  String get fire_extinguisher;

  /// No description provided for @my_location_route_calculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating route from my location to the building. Please wait a moment.'**
  String get my_location_route_calculating;

  /// No description provided for @calculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating'**
  String get calculating;

  /// No description provided for @set_both_locations.
  ///
  /// In en, this message translates to:
  /// **'Please set both departure and destination'**
  String get set_both_locations;

  /// No description provided for @route_calculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating route...'**
  String get route_calculating;

  /// No description provided for @search_error.
  ///
  /// In en, this message translates to:
  /// **'Search Error'**
  String get search_error;

  /// No description provided for @search_initial_guide.
  ///
  /// In en, this message translates to:
  /// **'Search for a building or room'**
  String get search_initial_guide;

  /// No description provided for @search_hint_example.
  ///
  /// In en, this message translates to:
  /// **'e.g. W19, Engineering Hall, Room 401'**
  String get search_hint_example;

  /// No description provided for @search_loading.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get search_loading;

  /// No description provided for @search_no_result.
  ///
  /// In en, this message translates to:
  /// **'No search results found'**
  String get search_no_result;

  /// No description provided for @search_try_again.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get search_try_again;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get setting;

  /// No description provided for @location_setting_confirm.
  ///
  /// In en, this message translates to:
  /// **'Would you like to set {buildingName} as {locationType}?'**
  String location_setting_confirm(String buildingName, String locationType);

  /// No description provided for @set_room.
  ///
  /// In en, this message translates to:
  /// **'Set Room'**
  String get set_room;

  /// No description provided for @friend_location_permission_denied.
  ///
  /// In en, this message translates to:
  /// **'{name} has not allowed location sharing'**
  String friend_location_permission_denied(String name);

  /// No description provided for @no_friends_message.
  ///
  /// In en, this message translates to:
  /// **'You have no friends.\nPlease add friends and try again.'**
  String get no_friends_message;

  /// No description provided for @offline_friends_not_displayed.
  ///
  /// In en, this message translates to:
  /// **'\n{count} offline friends are not displayed.'**
  String offline_friends_not_displayed(int count);

  /// No description provided for @location_denied_friends_not_displayed.
  ///
  /// In en, this message translates to:
  /// **'\n{count} friends who denied location sharing are not displayed.'**
  String location_denied_friends_not_displayed(int count);

  /// No description provided for @both_offline_and_location_denied.
  ///
  /// In en, this message translates to:
  /// **'\n{offlineCount} offline friends and {locationCount} friends who denied location sharing are not displayed.'**
  String both_offline_and_location_denied(int offlineCount, int locationCount);

  /// No description provided for @all_friends_offline_or_location_denied.
  ///
  /// In en, this message translates to:
  /// **'All friends are offline or have denied location sharing.\nYou can check their location when they come online and allow location sharing.'**
  String get all_friends_offline_or_location_denied;

  /// No description provided for @all_friends_offline.
  ///
  /// In en, this message translates to:
  /// **'All friends are offline.\nYou can check their location when they come online.'**
  String get all_friends_offline;

  /// No description provided for @all_friends_location_denied.
  ///
  /// In en, this message translates to:
  /// **'All friends have denied location sharing.\nYou can check their location when they allow location sharing.'**
  String get all_friends_location_denied;

  /// No description provided for @friends_location_display_success.
  ///
  /// In en, this message translates to:
  /// **'Displayed location of {count} friends on the map.'**
  String friends_location_display_success(int count);

  /// No description provided for @friends_location_display_error.
  ///
  /// In en, this message translates to:
  /// **'Cannot display friend locations: {error}'**
  String friends_location_display_error(String error);

  /// No description provided for @offline_friends_dialog_subtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} friends currently offline'**
  String offline_friends_dialog_subtitle(int count);

  /// No description provided for @friend_location_display_error.
  ///
  /// In en, this message translates to:
  /// **'Cannot display friend location.'**
  String get friend_location_display_error;

  /// No description provided for @friend_location_remove_error.
  ///
  /// In en, this message translates to:
  /// **'Cannot remove location.'**
  String get friend_location_remove_error;

  /// No description provided for @phone_app_error.
  ///
  /// In en, this message translates to:
  /// **'Cannot open phone app.'**
  String get phone_app_error;

  /// No description provided for @add_friend_error.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while adding friend'**
  String get add_friend_error;

  /// No description provided for @user_not_found.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get user_not_found;

  /// No description provided for @already_friend.
  ///
  /// In en, this message translates to:
  /// **'User is already a friend'**
  String get already_friend;

  /// No description provided for @already_requested.
  ///
  /// In en, this message translates to:
  /// **'Friend request already sent to this user'**
  String get already_requested;

  /// No description provided for @cannot_add_self.
  ///
  /// In en, this message translates to:
  /// **'Cannot add yourself as a friend'**
  String get cannot_add_self;

  /// No description provided for @invalid_user_id.
  ///
  /// In en, this message translates to:
  /// **'Invalid user ID'**
  String get invalid_user_id;

  /// No description provided for @server_error_retry.
  ///
  /// In en, this message translates to:
  /// **'Server error occurred. Please try again later'**
  String get server_error_retry;

  /// No description provided for @cancel_request_description.
  ///
  /// In en, this message translates to:
  /// **'Cancel sent friend request'**
  String get cancel_request_description;

  /// No description provided for @enter_id_prompt.
  ///
  /// In en, this message translates to:
  /// **'Please enter ID'**
  String get enter_id_prompt;

  /// No description provided for @friend_request_sent_success.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent successfully'**
  String get friend_request_sent_success;

  /// No description provided for @already_adding_friend.
  ///
  /// In en, this message translates to:
  /// **'Already adding friend. Preventing duplicate submission'**
  String get already_adding_friend;

  /// No description provided for @friends_location_displayed.
  ///
  /// In en, this message translates to:
  /// **'Displayed location of {count} friends.'**
  String friends_location_displayed(int count);

  /// No description provided for @offline_friends_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Offline Friends'**
  String get offline_friends_dialog_title;

  /// No description provided for @friendRequestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled friend request sent to {name}.'**
  String friendRequestCancelled(String name);

  /// No description provided for @friendRequestCancelError.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while cancelling friend request.'**
  String get friendRequestCancelError;

  /// No description provided for @friendRequestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted friend request from {name}.'**
  String friendRequestAccepted(String name);

  /// No description provided for @friendRequestAcceptError.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while accepting friend request.'**
  String get friendRequestAcceptError;

  /// No description provided for @friendRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected friend request from {name}.'**
  String friendRequestRejected(String name);

  /// No description provided for @friendRequestRejectError.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while rejecting friend request.'**
  String get friendRequestRejectError;

  /// No description provided for @friendLocationRemovedFromMap.
  ///
  /// In en, this message translates to:
  /// **'Friend locations have been removed from the map.'**
  String get friendLocationRemovedFromMap;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @room_info_processing_error.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while processing room information'**
  String get room_info_processing_error;

  /// No description provided for @selection_error.
  ///
  /// In en, this message translates to:
  /// **'Error occurred during selection. Please try again'**
  String get selection_error;

  /// No description provided for @building_selection_error.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while selecting building. Please try again'**
  String get building_selection_error;

  /// No description provided for @navigation_start_error.
  ///
  /// In en, this message translates to:
  /// **'Cannot start navigation. Please check the route again'**
  String get navigation_start_error;

  /// No description provided for @item_selection_error.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while selecting item'**
  String get item_selection_error;

  /// No description provided for @dialog_display_error.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while displaying dialog'**
  String get dialog_display_error;

  /// No description provided for @enter_start_location.
  ///
  /// In en, this message translates to:
  /// **'Enter departure point'**
  String get enter_start_location;

  /// No description provided for @room_set_as_start.
  ///
  /// In en, this message translates to:
  /// **' room has been set as departure point'**
  String get room_set_as_start;

  /// No description provided for @room_set_as_end.
  ///
  /// In en, this message translates to:
  /// **' room has been set as destination'**
  String get room_set_as_end;

  /// No description provided for @building_set_as_start.
  ///
  /// In en, this message translates to:
  /// **' has been set as departure point'**
  String get building_set_as_start;

  /// No description provided for @building_set_as_end.
  ///
  /// In en, this message translates to:
  /// **' has been set as destination'**
  String get building_set_as_end;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'es',
    'ja',
    'ko',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
