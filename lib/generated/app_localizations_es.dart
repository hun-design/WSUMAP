// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Seguir Woosong';

  @override
  String get subtitle => 'Guía del Campus Inteligente';

  @override
  String get woosong => 'Woosong';

  @override
  String get start => 'Comenzar';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get guest => 'Invitado';

  @override
  String get student_professor => 'Estudiante/Profesor';

  @override
  String get admin => 'Administrador';

  @override
  String get student => 'Estudiante';

  @override
  String get professor => 'Profesor';

  @override
  String get external_user => 'Usuario Externo';

  @override
  String get username => 'Nombre de Usuario';

  @override
  String get password => 'Contraseña';

  @override
  String get confirm_password => 'Confirmar Contraseña';

  @override
  String get remember_me => 'Recordar Información de Inicio de Sesión';

  @override
  String get remember_me_description =>
      'Se iniciará sesión automáticamente la próxima vez';

  @override
  String get login_as_guest => 'Explorar como Invitado';

  @override
  String get login_failed => 'Error de Inicio de Sesión';

  @override
  String get login_success => 'Inicio de Sesión Exitoso';

  @override
  String get logout_success => 'Sesión Cerrada Exitosamente';

  @override
  String get enter_username => 'Por favor ingrese su nombre de usuario';

  @override
  String get enter_password => 'Por favor ingrese su contraseña';

  @override
  String get password_hint => 'Ingrese al menos 6 caracteres';

  @override
  String get confirm_password_hint =>
      'Por favor ingrese su contraseña nuevamente';

  @override
  String get username_password_required =>
      'Por favor ingrese tanto el nombre de usuario como la contraseña';

  @override
  String get login_error => 'Error al iniciar sesión';

  @override
  String get find_password => 'Encontrar Contraseña';

  @override
  String get find_username => 'Encontrar Nombre de Usuario';

  @override
  String get back => 'Atrás';

  @override
  String get confirm => 'Confirmar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get coming_soon => 'Próximamente';

  @override
  String feature_coming_soon(String feature) {
    return 'La función $feature estará disponible próximamente.\nSe agregará pronto.';
  }

  @override
  String get departurePoint => 'Salida';

  @override
  String get arrivalPoint => 'Punto de llegada';

  @override
  String get all => 'Todos';

  @override
  String get tutorial => 'Tutorial';

  @override
  String get tutorialTitleIntro => 'Cómo Usar Seguir Woosong';

  @override
  String get tutorialDescIntro =>
      'Haga su vida en el campus más conveniente\ncon el Navegador del Campus de la Universidad de Woosong';

  @override
  String get tutorialTitleSearch => 'Función de Búsqueda Detallada';

  @override
  String get tutorialDescSearch =>
      '¡En Woosong University puede buscar no solo edificios sino también aulas!\nBusque detalladamente desde la ubicación del aula hasta las instalaciones 😊';

  @override
  String get tutorialTitleSchedule => 'Integración de Horarios';

  @override
  String get tutorialDescSchedule =>
      'Integre su horario de clases en la aplicación y\nreciba automáticamente la ruta óptima hasta la próxima clase';

  @override
  String get tutorialTitleDirections => 'Navegación';

  @override
  String get tutorialDescDirections =>
      'Llegue fácil y rápidamente a su destino\ncon la guía de ruta precisa dentro del campus';

  @override
  String get tutorialTitleIndoorMap => 'Plano Interior del Edificio';

  @override
  String get tutorialDescIndoorMap =>
      'Encuentre fácilmente aulas e instalaciones\ncon planos detallados del interior del edificio';

  @override
  String get dontShowAgain => 'No Mostrar de Nuevo';

  @override
  String get goBack => 'Volver';

  @override
  String get lectureRoom => 'Aula';

  @override
  String get lectureRoomInfo => 'Información del Aula';

  @override
  String get floor => 'Piso';

  @override
  String get personInCharge => 'Persona a cargo';

  @override
  String get viewLectureRoom => 'Ver Aula';

  @override
  String get viewBuilding => 'Ver Edificio';

  @override
  String get walk => 'Caminar';

  @override
  String get minute => 'min';

  @override
  String get hour => 'hr';

  @override
  String get less_than_one_minute => 'Menos de 1 min';

  @override
  String get zero_minutes => '0 min';

  @override
  String get calculation_failed => 'Cálculo fallido';

  @override
  String get professor_name => 'Nombre del profesor';

  @override
  String get building_name => 'Nombre del edificio';

  @override
  String floor_number(Object floor) {
    return 'Piso $floor';
  }

  @override
  String get room_name => 'Número de habitación';

  @override
  String get day_of_week => 'Día de la semana';

  @override
  String get time => 'Hora';

  @override
  String get memo => 'Memo';

  @override
  String get recommend_route => 'Ruta Recomendada';

  @override
  String get view_location => 'Ver ubicación';

  @override
  String get edit => 'Editar';

  @override
  String get close => 'Cerrar';

  @override
  String get help => 'Cómo usar';

  @override
  String get help_intro_title => 'Cómo Usar Seguir Woosong';

  @override
  String get help_intro_description =>
      'Haga su vida en el campus más conveniente\ncon el Navegador del Campus de la Universidad de Woosong';

  @override
  String get help_detailed_search_title => 'Búsqueda Detallada';

  @override
  String get help_detailed_search_description =>
      'Encuentre el lugar que desea con búsqueda precisa y rápida\nincluyendo nombres de edificios, números de aulas e instalaciones';

  @override
  String get help_timetable_title => 'Integración de Horarios';

  @override
  String get help_timetable_description =>
      'Integre su horario de clases en la aplicación y\nreciba automáticamente la ruta óptima hasta la próxima clase';

  @override
  String get help_directions_title => 'Navegación';

  @override
  String get help_directions_description =>
      'Llegue fácil y rápidamente a su destino\ncon la guía de ruta precisa dentro del campus';

  @override
  String get help_building_map_title => 'Plano Interior del Edificio';

  @override
  String get help_building_map_description =>
      'Encuentre fácilmente aulas e instalaciones\ncon planos detallados del interior del edificio';

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Siguiente';

  @override
  String get done => 'Completado';

  @override
  String get image_load_error => 'No se puede cargar la imagen';

  @override
  String get start_campus_exploration => '¡Comience a explorar el campus!';

  @override
  String get woosong_university => 'Universidad de Woosong';

  @override
  String get excel_upload_title => 'Cargar Archivo Excel de Horario';

  @override
  String get excel_upload_description =>
      'Por favor seleccione un archivo Excel de horario (.xlsx) de la Universidad de Woosong';

  @override
  String get excel_file_select => 'Seleccionar archivo Excel';

  @override
  String get excel_upload_uploading => 'Subiendo archivo Excel...';

  @override
  String get language_selection => 'Selección de Idioma';

  @override
  String get language_selection_description =>
      'Por favor seleccione su idioma preferido';

  @override
  String get departure => 'Origen';

  @override
  String get destination => 'Destino';

  @override
  String get my_location => 'Mi Ubicación';

  @override
  String get current_location => 'Ubicación Actual';

  @override
  String get welcome_subtitle_1 => 'Sigue Woosong en tus manos,';

  @override
  String get welcome_subtitle_2 =>
      '¡Toda la información de edificios está aquí!';

  @override
  String get select_language => 'Seleccionar Idioma';

  @override
  String get auth_selection_title => 'Selección de Método de Autenticación';

  @override
  String get auth_selection_subtitle =>
      'Por favor seleccione su método de inicio de sesión preferido';

  @override
  String get select_auth_method => 'Selección de Método de Autenticación';

  @override
  String total_floors(Object count) {
    return 'Total $count pisos';
  }

  @override
  String get floor_info => 'Información de Pisos';

  @override
  String floor_with_category(Object category) {
    return 'Piso con $category';
  }

  @override
  String get floor_label => 'Piso';

  @override
  String get category => 'Categoría';

  @override
  String get excel_upload_success => '¡Carga completada!';

  @override
  String get guest_timetable_disabled =>
      'Los usuarios invitados no pueden usar la función de horario.';

  @override
  String get guest_timetable_add_disabled =>
      'Los usuarios invitados no pueden agregar horarios.';

  @override
  String get guest_timetable_edit_disabled =>
      'Los usuarios invitados no pueden editar horarios.';

  @override
  String get guest_timetable_delete_disabled =>
      'Los usuarios invitados no pueden eliminar horarios.';

  @override
  String get timetable_load_failed => 'No se pudo cargar el horario.';

  @override
  String get timetable_add_success => 'Horario agregado exitosamente.';

  @override
  String timetable_add_failed(Object error) {
    return 'Error al agregar horario';
  }

  @override
  String get timetable_overlap =>
      'Ya hay una clase registrada a la misma hora.';

  @override
  String get required_fields_missing =>
      'Por favor complete todos los campos requeridos.';

  @override
  String get no_search_results => 'Sin resultados de búsqueda';

  @override
  String get excel_upload_refreshing => 'Actualizando horario...';

  @override
  String get logout_processing => 'Cerrando sesión...';

  @override
  String get logout_error_message =>
      'Ocurrió un error al cerrar sesión, pero moviéndose a la pantalla inicial.';

  @override
  String get data_to_be_deleted => 'Datos a eliminar';

  @override
  String get deleting_account => 'Eliminando cuenta...';

  @override
  String get excel_tutorial_title => 'Cómo descargar archivo Excel';

  @override
  String get edit_profile_section => 'Editar Perfil';

  @override
  String get delete_account_section => 'Eliminar Cuenta';

  @override
  String get logout_section => 'Cerrar Sesión';

  @override
  String get location_share_title => 'Compartir Ubicación';

  @override
  String get location_share_enabled => 'Compartir ubicación está habilitado';

  @override
  String get location_share_disabled =>
      'Compartir ubicación está deshabilitado';

  @override
  String get excel_tutorial_previous => 'Anterior';

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
  String get current_location_departure => 'Salir desde la ubicación actual';

  @override
  String get current_location_departure_default =>
      'Salir desde la ubicación actual (ubicación predeterminada)';

  @override
  String get current_location_navigation_start =>
      'Start navigation from current location';

  @override
  String get excel_tutorial_next => 'Siguiente';

  @override
  String get profile_edit_title => 'Editar Perfil';

  @override
  String get profile_edit_subtitle => 'Puede modificar su información personal';

  @override
  String get account_delete_title => 'Eliminar Cuenta';

  @override
  String get account_delete_subtitle => 'Eliminar permanentemente su cuenta';

  @override
  String get logout_title => 'Cerrar Sesión';

  @override
  String get logout_subtitle => 'Cerrar sesión de la cuenta actual';

  @override
  String get location_share_enabled_success =>
      'Compartir ubicación ha sido habilitado';

  @override
  String get location_share_disabled_success =>
      'Compartir ubicación ha sido deshabilitado';

  @override
  String get profile_edit_error => 'Ocurrió un error al editar el perfil';

  @override
  String get inquiry_load_failed => 'Error al cargar lista de consultas';

  @override
  String get pull_to_refresh => 'Desliza hacia abajo para actualizar';

  @override
  String get app_version_number => 'v1.0.0';

  @override
  String get developer_email_address => 'wsumap41@gmail.com';

  @override
  String get developer_github_url => 'https://github.com/WSU-YJB/WSUMAP';

  @override
  String get friend_management => 'Gestión de Amigos';

  @override
  String get excel_tutorial_file_select => 'Seleccionar archivo';

  @override
  String get excel_tutorial_help => 'Ver instrucciones';

  @override
  String get excel_upload_file_cancelled => 'Selección de archivo cancelada.';

  @override
  String get excel_upload_success_message => '¡El horario ha sido actualizado!';

  @override
  String excel_upload_refresh_failed(String error) {
    return 'Error al actualizar: $error';
  }

  @override
  String excel_upload_failed(String error) {
    return 'Error al subir: $error';
  }

  @override
  String get excel_tutorial_step_1 =>
      '1. Inicia sesión en el sistema de información de la Universidad de Woosong';

  @override
  String get excel_tutorial_url => 'https://wsinfo.wsu.ac.kr';

  @override
  String get excel_tutorial_image_load_error => 'No se puede cargar la imagen';

  @override
  String get excel_tutorial_unknown_page => 'Página desconocida';

  @override
  String get campus_navigator => 'Navegador del Campus';

  @override
  String get user_info_not_found =>
      'No se pudo encontrar información del usuario en la respuesta de inicio de sesión';

  @override
  String get unexpected_login_error =>
      'Ocurrió un error inesperado durante el inicio de sesión';

  @override
  String get login_required => 'Se requiere inicio de sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get register_success => 'Registro completado';

  @override
  String get register_success_message =>
      '¡Registro completado!\nRedirigiendo a la pantalla de inicio de sesión.';

  @override
  String get register_error =>
      'Ocurrió un error inesperado durante el registro';

  @override
  String get update_user_info => 'Actualizar información del usuario';

  @override
  String get update_success => 'Información del usuario actualizada';

  @override
  String get update_error =>
      'Ocurrió un error inesperado al actualizar la información del usuario';

  @override
  String get delete_account => 'Eliminar cuenta';

  @override
  String get delete_success => 'Eliminación de cuenta completada';

  @override
  String get delete_error =>
      'Ocurrió un error inesperado al eliminar la cuenta';

  @override
  String get name => 'Nombre';

  @override
  String get phone => 'Teléfono';

  @override
  String get email => 'Correo electrónico';

  @override
  String get student_number => 'Número de estudiante';

  @override
  String get user_type => 'Tipo de usuario';

  @override
  String get optional => 'Opcional';

  @override
  String get required_fields_empty =>
      'Por favor complete todos los campos requeridos';

  @override
  String get password_mismatch => 'Las contraseñas no coinciden';

  @override
  String get password_too_short =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get invalid_phone_format =>
      'Por favor ingrese el formato correcto de teléfono (ej: 010-1234-5678)';

  @override
  String get invalid_email_format =>
      'Por favor ingrese el formato correcto de correo electrónico';

  @override
  String get required_fields_notice => '* Los campos marcados son obligatorios';

  @override
  String get welcome_to_campus_navigator =>
      'Bienvenido al Navegador del Campus de Woosong';

  @override
  String get enter_real_name => 'Por favor ingrese su nombre real';

  @override
  String get phone_format_hint => '010-1234-5678';

  @override
  String get enter_student_number =>
      'Por favor ingrese su número de estudiante o profesor';

  @override
  String get email_hint => 'example@woosong.org';

  @override
  String get create_account => 'Crear cuenta';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Éxito';

  @override
  String get validation_error => 'Por favor revise su entrada';

  @override
  String get network_error => 'Ocurrió un error de red';

  @override
  String get server_error => 'Ocurrió un error del servidor';

  @override
  String get unknown_error => 'Ocurrió un error desconocido';

  @override
  String get woosong_campus_guide_service =>
      'Servicio de guía del campus de la Universidad de Woosong';

  @override
  String get register_description =>
      'Crea una nueva cuenta para usar todas las funciones';

  @override
  String get login_description =>
      'Inicia sesión con tu cuenta existente para usar el servicio';

  @override
  String get browse_as_guest => 'Explorar como invitado';

  @override
  String get processing => 'Procesando...';

  @override
  String get campus_navigator_version => 'Campus Navigator v1.0';

  @override
  String get guest_mode => 'Modo Invitado';

  @override
  String get guest_mode_confirm =>
      '¿Deseas entrar en modo invitado?\n\nEn modo invitado, no puedes usar funciones de amigos ni compartir ubicación.';

  @override
  String get app_name => 'Seguir Woosong';

  @override
  String get welcome_to_ttarausong => 'Bienvenido a Seguir Woosong';

  @override
  String get guest_mode_description =>
      'En modo invitado solo puedes ver información básica del campus.\nPara usar todas las funciones, por favor regístrate e inicia sesión.';

  @override
  String get continue_as_guest => 'Continuar como invitado';

  @override
  String get moved_to_my_location => 'Movido automáticamente a mi ubicación';

  @override
  String get friends_screen_bottom_sheet =>
      'La pantalla de amigos se muestra como hoja inferior';

  @override
  String get finding_current_location => 'Buscando ubicación actual...';

  @override
  String get home => 'Inicio';

  @override
  String get timetable => 'Horario';

  @override
  String get friends => 'Amigos';

  @override
  String get finish => 'Completar';

  @override
  String get profile => 'Perfil';

  @override
  String get inquiry => 'Consultas';

  @override
  String get my_inquiry => 'Mis consultas';

  @override
  String get inquiry_type => 'Tipo de consulta';

  @override
  String get inquiry_type_required =>
      'Por favor seleccione el tipo de consulta';

  @override
  String get inquiry_type_select_hint => 'Seleccione el tipo de consulta';

  @override
  String get inquiry_title => 'Título de la consulta';

  @override
  String get inquiry_content => 'Contenido de la consulta';

  @override
  String get inquiry_content_hint =>
      'Por favor ingrese el contenido de la consulta';

  @override
  String get inquiry_submit => 'Enviar consulta';

  @override
  String get inquiry_submit_success => 'Consulta enviada exitosamente';

  @override
  String get inquiry_submit_failed => 'Error al enviar la consulta';

  @override
  String get no_inquiry_history => 'No hay historial de consultas';

  @override
  String get no_inquiry_history_hint => 'Aún no hay consultas';

  @override
  String get inquiry_delete => 'Eliminar consulta';

  @override
  String get inquiry_delete_confirm => '¿Desea eliminar esta consulta?';

  @override
  String get inquiry_delete_success => 'Consulta eliminada';

  @override
  String get inquiry_delete_failed => 'Error al eliminar la consulta';

  @override
  String get inquiry_detail => 'Detalle de consulta';

  @override
  String get inquiry_category => 'Categoría de la consulta';

  @override
  String get inquiry_status => 'Estado de la consulta';

  @override
  String get inquiry_created_at => 'Fecha de la consulta';

  @override
  String get inquiry_title_label => 'Título de la consulta';

  @override
  String get inquiry_type_bug => 'Reporte de error';

  @override
  String get inquiry_type_feature => 'Solicitud de función';

  @override
  String get inquiry_type_improvement => 'Sugerencia de mejora';

  @override
  String get inquiry_type_other => 'Otra consulta';

  @override
  String get inquiry_status_pending => 'Pendiente';

  @override
  String get inquiry_status_in_progress => 'En progreso';

  @override
  String get inquiry_status_answered => 'Respondida';

  @override
  String get phone_required => 'El número de teléfono es obligatorio';

  @override
  String get building_info => 'Información del edificio';

  @override
  String get directions => 'Direcciones';

  @override
  String get floor_detail_view => 'Vista detallada del piso';

  @override
  String get no_floor_info => 'No hay información del piso';

  @override
  String get floor_detail_info => 'Información detallada del piso';

  @override
  String get search_start_location => 'Buscar ubicación de inicio';

  @override
  String get search_end_location => 'Buscar ubicación de destino';

  @override
  String get unified_navigation_in_progress =>
      'Navegación unificada en progreso';

  @override
  String get unified_navigation => 'Navegación unificada';

  @override
  String get recent_searches => 'Búsquedas recientes';

  @override
  String get clear_all => 'Limpiar todo';

  @override
  String get searching => 'Buscando...';

  @override
  String get try_different_keyword => 'Intente con una palabra clave diferente';

  @override
  String get enter_end_location => 'Ingrese el destino';

  @override
  String get route_preview => 'Vista previa de la ruta';

  @override
  String get calculating_optimal_route => 'Calculando ruta óptima...';

  @override
  String get set_departure_and_destination =>
      'Configure el punto de partida y destino';

  @override
  String get start_unified_navigation => 'Iniciar navegación unificada';

  @override
  String get departure_indoor => 'Punto de partida (interior)';

  @override
  String get to_building_exit => 'Hacia la salida del edificio';

  @override
  String get outdoor_movement => 'Movimiento al aire libre';

  @override
  String get to_destination_building => 'Hacia el edificio de destino';

  @override
  String get arrival_indoor => 'Llegada (interior)';

  @override
  String get to_final_destination => 'Hacia el destino final';

  @override
  String get total_distance => 'Distancia total';

  @override
  String get route_type => 'Tipo de ruta';

  @override
  String get building_to_building => 'De edificio a edificio';

  @override
  String get room_to_building => 'De habitación a edificio';

  @override
  String get building_to_room => 'De edificio a habitación';

  @override
  String get room_to_room => 'De habitación a habitación';

  @override
  String get location_to_building => 'De ubicación actual a edificio';

  @override
  String get unified_route => 'Ruta unificada';

  @override
  String get status_offline => 'Desconectado';

  @override
  String get status_open => 'Abierto';

  @override
  String get status_closed => 'Cerrado';

  @override
  String get status_24hours => '24 horas';

  @override
  String get status_temp_closed => 'Cerrado temporalmente';

  @override
  String get status_closed_permanently => 'Cerrado permanentemente';

  @override
  String get status_next_open => 'Abre a las 9 AM';

  @override
  String get status_next_close => 'Cierra a las 6 PM';

  @override
  String get status_next_open_tomorrow => 'Abre mañana a las 9 AM';

  @override
  String get set_start_point => 'Establecer punto de partida';

  @override
  String get set_end_point => 'Establecer punto de destino';

  @override
  String get scheduleDeleteTitle => 'Eliminar horario';

  @override
  String get scheduleDeleteSubtitle => 'Por favor decida cuidadosamente';

  @override
  String get scheduleDeleteLabel => 'Horario a eliminar';

  @override
  String scheduleDeleteDescription(Object title) {
    return 'La clase \"$title\" será eliminada del horario.\nEl horario eliminado no se puede recuperar.';
  }

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get deleteButton => 'Eliminar';

  @override
  String get overlap_message => 'Ya hay una clase registrada a esta hora';

  @override
  String friendDeleteSuccessMessage(Object userName) {
    return '$userName ha sido removido de su lista de amigos';
  }

  @override
  String get enterFriendIdPrompt =>
      'Por favor ingrese el ID del amigo que desea agregar';

  @override
  String get friendId => 'ID del amigo';

  @override
  String get enterFriendId => 'Ingrese ID del amigo';

  @override
  String get sendFriendRequest => 'Enviar solicitud de amistad';

  @override
  String get realTimeSyncActive =>
      'Sincronización en tiempo real activada • Actualización automática';

  @override
  String get noSentRequests => 'No hay solicitudes de amistad enviadas';

  @override
  String newFriendRequests(int count) {
    return '$count nuevas solicitudes de amistad';
  }

  @override
  String get noReceivedRequests => 'No hay solicitudes de amistad recibidas';

  @override
  String get id => 'ID';

  @override
  String requestDate(String date) {
    return 'Fecha de solicitud: $date';
  }

  @override
  String get newBadge => 'NUEVO';

  @override
  String get online => 'En línea';

  @override
  String get offline => 'Offline';

  @override
  String get contact => 'Contacto';

  @override
  String get noContactInfo => 'No hay información de contacto';

  @override
  String get friendOfflineError => 'El amigo está desconectado';

  @override
  String get removeLocation => 'Remover ubicación';

  @override
  String get showLocation => 'Mostrar ubicación';

  @override
  String friendLocationRemoved(String userName) {
    return 'La ubicación de $userName ha sido removida';
  }

  @override
  String friendLocationShown(String userName) {
    return 'La ubicación de $userName ha sido mostrada';
  }

  @override
  String get errorCannotRemoveLocation => 'No se puede remover la ubicación';

  @override
  String get my_page => 'Mi página';

  @override
  String get calculating_route => 'Calculando ruta...';

  @override
  String get finding_optimal_route => 'Buscando la ruta óptima en el servidor';

  @override
  String get clear_route => 'Limpiar ruta';

  @override
  String get location_permission_denied =>
      'Se ha denegado el permiso de ubicación.\nPor favor permita el permiso de ubicación en la configuración.';

  @override
  String get estimated_time => 'Tiempo estimado';

  @override
  String get location_share_update_failed =>
      'Error al actualizar la configuración de compartir ubicación';

  @override
  String get guest_location_share_success =>
      'En modo invitado, compartir ubicación solo se configura localmente';

  @override
  String get no_changes => 'No hay cambios';

  @override
  String get password_confirm_title => 'Confirmar contraseña';

  @override
  String get password_confirm_subtitle =>
      'Por favor ingrese su contraseña para modificar la información de la cuenta';

  @override
  String get password_confirm_button => 'Confirmar';

  @override
  String get password_required => 'Por favor ingrese su contraseña';

  @override
  String get password_mismatch_confirm => 'Las contraseñas no coinciden';

  @override
  String get profile_updated => 'El perfil ha sido actualizado';

  @override
  String get my_page_subtitle => 'Mi información';

  @override
  String get excel_file => 'Archivo Excel';

  @override
  String get excel_file_tutorial => 'Cómo usar archivo Excel';

  @override
  String get image_attachment => 'Adjuntar imagen';

  @override
  String get max_one_image => 'Máximo 1 imagen';

  @override
  String get photo_attachment => 'Adjuntar foto';

  @override
  String get photo_attachment_complete => 'Foto adjuntada';

  @override
  String get image_selection => 'Selección de imagen';

  @override
  String get select_image_method => 'Método de selección de imagen';

  @override
  String get select_from_gallery => 'Seleccionar de galería';

  @override
  String get select_from_gallery_desc => 'Seleccionar imagen de la galería';

  @override
  String get select_from_file => 'Seleccionar de archivo';

  @override
  String get select_from_file_desc => 'Seleccionar imagen del archivo';

  @override
  String get max_one_image_error =>
      'Solo se puede adjuntar una imagen como máximo';

  @override
  String get image_selection_error => 'Error al seleccionar imagen';

  @override
  String get inquiry_error_occurred => 'Error al procesar la consulta';

  @override
  String get inquiry_category_bug => 'Reporte de error';

  @override
  String get inquiry_category_feature => 'Solicitud de función';

  @override
  String get inquiry_category_other => 'Otra consulta';

  @override
  String get inquiry_category_route_error => 'Error de guía de ruta';

  @override
  String get inquiry_category_place_error => 'Error de ubicación/información';

  @override
  String get schedule => 'Horario';

  @override
  String get winter_semester => 'Semestre de invierno';

  @override
  String get spring_semester => 'Semestre de primavera';

  @override
  String get summer_semester => 'Semestre de verano';

  @override
  String get fall_semester => 'Semestre de otoño';

  @override
  String get monday => 'Lun';

  @override
  String get tuesday => 'Mar';

  @override
  String get wednesday => 'Mié';

  @override
  String get thursday => 'Jue';

  @override
  String get friday => 'Vie';

  @override
  String get add_class => 'Agregar clase';

  @override
  String get edit_class => 'Editar clase';

  @override
  String get delete_class => 'Eliminar clase';

  @override
  String get class_name => 'Nombre de la clase';

  @override
  String get classroom => 'Aula';

  @override
  String get start_time => 'Hora de inicio';

  @override
  String get end_time => 'Hora de finalización';

  @override
  String get color_selection => 'Selección de color';

  @override
  String get monday_full => 'Lunes';

  @override
  String get tuesday_full => 'Martes';

  @override
  String get wednesday_full => 'Miércoles';

  @override
  String get thursday_full => 'Jueves';

  @override
  String get friday_full => 'Viernes';

  @override
  String get class_added => 'Clase agregada';

  @override
  String get class_updated => 'Clase actualizada';

  @override
  String get class_deleted => 'Clase eliminada';

  @override
  String delete_class_confirm(String className) {
    return '¿Desea eliminar la clase $className?';
  }

  @override
  String get view_on_map => 'Ver en el mapa';

  @override
  String get location => 'Ubicación';

  @override
  String get schedule_time => 'Hora';

  @override
  String get schedule_day => 'Día';

  @override
  String get map_feature_coming_soon =>
      'La función del mapa estará disponible pronto';

  @override
  String current_year(int year) {
    return 'Año actual';
  }

  @override
  String get my_friends => 'Mis amigos';

  @override
  String online_friends(int total, int online) {
    return 'Amigos en línea';
  }

  @override
  String get add_friend => 'Agregar amigo';

  @override
  String get friend_name_or_id => 'Nombre o ID del amigo';

  @override
  String get friend_request_sent => 'Solicitud de amistad enviada';

  @override
  String get in_class => 'En clase';

  @override
  String last_location(String location) {
    return 'Última ubicación';
  }

  @override
  String get central_library => 'Biblioteca Central';

  @override
  String get engineering_building => 'Edificio de Ingeniería';

  @override
  String get student_center => 'Centro de Estudiantes';

  @override
  String get cafeteria => 'Cafeteria';

  @override
  String get message => 'Mensaje';

  @override
  String get call => 'Llamar';

  @override
  String start_chat_with(String name) {
    return 'Iniciar chat';
  }

  @override
  String view_location_on_map(String name) {
    return 'Ver ubicación en el mapa';
  }

  @override
  String calling(String name) {
    return 'Llamando';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get search => 'Buscar';

  @override
  String get searchBuildings => 'Buscar edificios';

  @override
  String get myLocation => 'Mi ubicación';

  @override
  String get navigation => 'Navegación';

  @override
  String get route => 'Ruta';

  @override
  String get distance => 'Distancia';

  @override
  String get minutes => 'minutos';

  @override
  String get hours => 'Horario de operación';

  @override
  String get within_minute => 'Menos de 1 minuto';

  @override
  String minutes_only(Object minutes) {
    return '$minutes minutos';
  }

  @override
  String hours_only(Object hours) {
    return '$hours horas';
  }

  @override
  String hours_and_minutes(Object hours, Object minutes) {
    return '$hours horas $minutes minutos';
  }

  @override
  String get available => 'Disponible';

  @override
  String get start_navigation_from_current_location =>
      'Iniciar navegación desde la ubicación actual';

  @override
  String get my_location_set_as_start =>
      'Mi ubicación ha sido establecida como punto de partida';

  @override
  String get default_location_set_as_start =>
      'La ubicación predeterminada ha sido establecida como punto de partida';

  @override
  String get start_navigation => 'Iniciar navegación';

  @override
  String get navigation_ended => 'Navegación terminada';

  @override
  String get arrival => 'Llegada';

  @override
  String get outdoor_movement_distance =>
      'Distancia de movimiento al aire libre';

  @override
  String get indoor_arrival => 'Llegada interior';

  @override
  String get indoor_departure => 'Salida interior';

  @override
  String get complete => 'Completar';

  @override
  String get findRoute => 'Encontrar ruta';

  @override
  String get clearRoute => 'Limpiar ruta';

  @override
  String get setAsStart => 'Establecer como salida';

  @override
  String get setAsDestination => 'Establecer como destino';

  @override
  String get navigateFromHere => 'Navegar desde aquí';

  @override
  String get buildingInfo => 'Información del edificio';

  @override
  String get locationPermissionRequired => 'Se requiere permiso de ubicación';

  @override
  String get enableLocationServices =>
      'Por favor habilite los servicios de ubicación';

  @override
  String get noResults => 'No hay resultados';

  @override
  String get settings => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get about => 'Acerca de';

  @override
  String friends_count_status(int total, int online) {
    return 'Estado del número de amigos';
  }

  @override
  String get enter_friend_info => 'Ingrese información del amigo';

  @override
  String show_location_on_map(String name) {
    return 'Mostrar ubicación en el mapa';
  }

  @override
  String get location_error => 'Error de ubicación';

  @override
  String get view_floor_plan => 'Ver plano';

  @override
  String floor_plan_title(String buildingName) {
    return 'Plano';
  }

  @override
  String get floor_plan_not_available => 'El plano no está disponible';

  @override
  String get floor_plan_default_text => 'Texto predeterminado del plano';

  @override
  String get delete_account_success => 'Cuenta eliminada exitosamente';

  @override
  String get convenience_store => 'Tienda de conveniencia';

  @override
  String get vending_machine => 'Máquina expendedora';

  @override
  String get printer => 'Impresora';

  @override
  String get copier => 'Fotocopiadora';

  @override
  String get atm => 'ATM';

  @override
  String get bank_atm => 'Banco (ATM)';

  @override
  String get medical => 'Médico';

  @override
  String get health_center => 'Centro de salud';

  @override
  String get gym => 'Gimnasio';

  @override
  String get fitness_center => 'Centro de fitness';

  @override
  String get lounge => 'Sala de descanso';

  @override
  String get extinguisher => 'Extintor';

  @override
  String get water_purifier => 'Purificador de agua';

  @override
  String get bookstore => 'Librería';

  @override
  String get post_office => 'Oficina de correos';

  @override
  String instructionMoveToDestination(String place) {
    return 'Muévase hacia el destino';
  }

  @override
  String get markerDeparture => 'Punto de partida';

  @override
  String get markerArrival => 'Punto de llegada';

  @override
  String get errorCannotOpenPhoneApp =>
      'No se puede abrir la aplicación de teléfono.';

  @override
  String get emailCopied => 'Correo electrónico copiado';

  @override
  String get description => 'Descripción';

  @override
  String get noDetailedInfoRegistered =>
      'No hay información detallada registrada';

  @override
  String get setDeparture => 'Establecer punto de partida';

  @override
  String get setArrival => 'Establecer punto de llegada';

  @override
  String errorOccurred(Object error) {
    return 'Ocurrió un error: $error';
  }

  @override
  String get instructionExitToOutdoor => 'Salga al exterior';

  @override
  String instructionMoveToDestinationBuilding(String building) {
    return 'Muévase hacia el edificio de destino';
  }

  @override
  String get instructionMoveToRoom => 'Muévase hacia la habitación';

  @override
  String get instructionArrived => 'Ha llegado';

  @override
  String get no => 'No';

  @override
  String get woosong_library_w1 => 'Biblioteca Woosong (W1)';

  @override
  String get woosong_library_info =>
      'B2F\tEstacionamiento\nB1F\tAuditorio, Sala de máquinas, Sala eléctrica, Estacionamiento\n1F\tCentro de apoyo al empleo (630-9976), Préstamo, Sala de descanso\n2F\tSala de lectura general, Sala de estudio grupal\n3F\tSala de lectura general\n4F\tLibros de literatura/Libros occidentales';

  @override
  String get educational_facility => 'Educational Facility';

  @override
  String get operating => 'Operating';

  @override
  String get woosong_library_desc =>
      'Biblioteca central de la Universidad de Woosong';

  @override
  String get sol_cafe => 'Café Sol';

  @override
  String get sol_cafe_info => '1F\tRestaurante\n2F\tCafé';

  @override
  String get cafe => 'Café';

  @override
  String get sol_cafe_desc => 'Café del campus';

  @override
  String get cheongun_1_dormitory => 'Dormitorio Cheongun 1';

  @override
  String get cheongun_1_dormitory_info =>
      '1F\tLaboratorio\n2F\tComedor de estudiantes\n2F\tDormitorio Cheongun 1 (mujeres) (629-6542)\n2F\tCentro de vida\n3~5F\tCentro de vida';

  @override
  String get dormitory => 'Dormitorio';

  @override
  String get cheongun_1_dormitory_desc => 'Dormitorio para mujeres';

  @override
  String get industry_cooperation_w2 =>
      'Centro de cooperación industria-academia (W2)';

  @override
  String get industry_cooperation_info =>
      '1F\tCentro de cooperación industria-academia\n2F\tDepartamento de Ingeniería Arquitectónica (630-9720)\n3F\tInstituto de Tecnología Convergente, Centro de apoyo empresarial\n4F\tLaboratorio corporativo, Aula LG CNS, Academia digital ferroviaria';

  @override
  String get industry_cooperation_desc =>
      'Instalaciones de cooperación industria-academia e investigación';

  @override
  String get rotc_w2_1 => 'Cuerpo de oficiales de reserva (W2-1)';

  @override
  String get rotc_info => '\tCuerpo de oficiales de reserva (630-4601)';

  @override
  String get rotc_desc => 'Instalaciones del cuerpo de oficiales de reserva';

  @override
  String get military_facility => 'Instalación militar';

  @override
  String get international_dormitory_w3 => 'Dormitorio internacional (W3)';

  @override
  String get international_dormitory_info =>
      '1F\tEquipo de apoyo a estudiantes internacionales (629-6623)\n1F\tComedor de estudiantes\n2F\tDormitorio internacional (629-6655)\n2F\tClínica de salud\n3~12F\tCentro de vida';

  @override
  String get international_dormitory_desc =>
      'Dormitorio exclusivo para estudiantes internacionales';

  @override
  String get railway_logistics_w4 => 'Centro ferroviario y logístico (W4)';

  @override
  String get railway_logistics_info =>
      'B1F\tLaboratorio\n1F\tLaboratorio\n2F\tDepartamento de sistemas de construcción ferroviaria (629-6710)\n2F\tDepartamento de sistemas de vehículos ferroviarios (629-6780)\n3F\tAula/Laboratorio\n4F\tDepartamento de sistemas ferroviarios (630-6730,9700)\n5F\tDepartamento de prevención de incendios (629-6770)\n5F\tDepartamento de sistemas logísticos (630-9330)';

  @override
  String get railway_logistics_desc =>
      'Departamentos relacionados con ferrocarriles y logística';

  @override
  String get health_medical_science_w5 =>
      'Centro de ciencias médicas y de salud (W5)';

  @override
  String get health_medical_science_info =>
      'B1F\tEstacionamiento\n1F\tSala audiovisual/Estacionamiento\n2F\tAula\n2F\tDepartamento de rehabilitación de salud y ejercicio (630-9840)\n3F\tDepartamento de servicios de emergencia (630-9280)\n3F\tDepartamento de enfermería (630-9290)\n4F\tDepartamento de terapia ocupacional (630-9820)\n4F\tDepartamento de terapia del habla y rehabilitación auditiva (630-9220)\n5F\tDepartamento de fisioterapia (630-4620)\n5F\tDepartamento de gestión de servicios médicos (630-4610)\n5F\tAula\n6F\tDepartamento de gestión ferroviaria (630-9770)';

  @override
  String get health_medical_science_desc =>
      'Departamentos relacionados con ciencias médicas y de salud';

  @override
  String get liberal_arts_w6 => 'Centro de educación liberal (W6)';

  @override
  String get liberal_arts_info => '2F\tAula\n3F\tAula\n4F\tAula\n5F\tAula';

  @override
  String get liberal_arts_desc => 'Aulas de educación liberal';

  @override
  String get woosong_hall_w7 => 'Sala Woosong (W7)';

  @override
  String get woosong_hall_info =>
      '1F\tOficina de admisiones (630-9627)\n1F\tOficina de asuntos académicos (630-9622)\n1F\tOficina de instalaciones (630-9970)\n1F\tEquipo de administración (629-6658)\n1F\tCentro de cooperación industria-academia (630-4653)\n1F\tOficina de cooperación externa (630-9636)\n2F\tOficina de planificación estratégica (630-9102)\n2F\tOficina general-Gestión, Compras (630-9653)\n2F\tOficina de planificación (630-9661)\n3F\tOficina del presidente (630-8501)\n3F\tOficina de intercambio internacional (630-9373)\n3F\tDepartamento de educación infantil (630-9360)\n3F\tAdministración de empresas (629-6640)\n3F\tFinanzas/Administración inmobiliaria (630-9350)\n4F\tSala de conferencias principal\n5F\tSala de conferencias';

  @override
  String get woosong_hall_desc => 'Edificio principal de la universidad';

  @override
  String get woosong_kindergarten_w8 => 'Jardín de infantes Woosong (W8)';

  @override
  String get woosong_kindergarten_info =>
      '1F, 2F\tJardín de infantes Woosong (629~6750~1)';

  @override
  String get woosong_kindergarten_desc =>
      'Jardín de infantes afiliado a la universidad';

  @override
  String get kindergarten => 'Jardín de infantes';

  @override
  String get west_campus_culinary_w9 =>
      'Academia culinaria del campus oeste (W9)';

  @override
  String get west_campus_culinary_info =>
      'B1F\tLaboratorio\n1F\tLaboratorio\n2F\tLaboratorio';

  @override
  String get west_campus_culinary_desc => 'Instalaciones de práctica culinaria';

  @override
  String get social_welfare_w10 => 'Centro de bienestar social (W10)';

  @override
  String get social_welfare_info =>
      '1F\tSala audiovisual/Laboratorio\n2F\tAula/Laboratorio\n3F\tDepartamento de bienestar social (630-9830)\n3F\tDepartamento de educación infantil global (630-9260)\n4F\tAula/Laboratorio\n5F\tAula/Laboratorio';

  @override
  String get social_welfare_desc =>
      'Departamentos relacionados con bienestar social';

  @override
  String get gymnasium_w11 => 'Gimnasio (W11)';

  @override
  String get gymnasium_info =>
      '1F\tSala de entrenamiento físico\n2F~4F\tGimnasio';

  @override
  String get gymnasium_desc => 'Instalaciones deportivas';

  @override
  String get sports_facility => 'Instalación deportiva';

  @override
  String get sica_w12 => 'SICA (W12)';

  @override
  String get sica_info =>
      'B1F\tLaboratorio\n1F\tCafé Starrico\n2F~3F\tAula\n5F\tDepartamento de artes culinarias globales (629-6860)';

  @override
  String get sica_desc => 'Academia internacional de artes culinarias';

  @override
  String get woosong_tower_w13 => 'Torre Woosong (W13)';

  @override
  String get woosong_tower_info =>
      'B1~1F\tEstacionamiento\n2F\tEstacionamiento, Panadería Solpine (629-6429)\n4F\tSala de seminarios\n5F\tAula\n6F\tDepartamento de nutrición culinaria (630-9380,9740)\n7F\tAula\n8F\tGestión de restaurantes y cocina (630-9250)\n9F\tAula/Laboratorio\n10F\tArtes culinarias (629-6821), Cocina coreana global (629-6560)\n11F, 12F\tLaboratorio\n13F\tRestaurante Solpine (629-6610)';

  @override
  String get woosong_tower_desc => 'Instalación educativa integral';

  @override
  String get complex_facility => 'Instalación compleja';

  @override
  String get culinary_center_w14 => 'Centro culinario (W14)';

  @override
  String get culinary_center_info =>
      '1F\tAula/Laboratorio\n2F\tAula/Laboratorio\n3F\tAula/Laboratorio\n4F\tAula/Laboratorio\n5F\tAula/Laboratorio';

  @override
  String get culinary_center_desc =>
      'Instalación educativa de artes culinarias';

  @override
  String get food_architecture_w15 =>
      'Centro de arquitectura alimentaria (W15)';

  @override
  String get food_architecture_info =>
      'B1F\tLaboratorio\n1F\tLaboratorio\n2F\tAula\n3F\tAula\n4F\tAula\n5F\tAula';

  @override
  String get food_architecture_desc =>
      'Departamentos relacionados con alimentos y arquitectura';

  @override
  String get student_hall_w16 => 'Centro de estudiantes (W16)';

  @override
  String get student_hall_info =>
      '1F\tComedor de estudiantes, Librería del campus (629-6127)\n2F\tComedor de empleados\n3F\tSala de clubes\n3F\tOficina de bienestar estudiantil-Equipo de estudiantes (630-9641), Equipo de becas (630-9876)\n3F\tCentro de apoyo a estudiantes con discapacidad (630-9903)\n3F\tEquipo de servicio social (630-9904)\n3F\tCentro de asesoramiento estudiantil (630-9645)\n4F\tCentro de apoyo al regreso (630-9139)\n4F\tCentro de desarrollo de enseñanza y aprendizaje (630-9285)';

  @override
  String get student_hall_desc => 'Instalaciones de bienestar estudiantil';

  @override
  String get media_convergence_w17 => 'Centro de convergencia de medios (W17)';

  @override
  String get media_convergence_info =>
      'B1F\tAula/Laboratorio\n1F\tDiseño de medios/Producción de video (630-9750)\n2F\tAula/Laboratorio\n3F\tJuegos y multimedia (630-9270)\n5F\tAula/Laboratorio';

  @override
  String get media_convergence_desc => 'Departamentos relacionados con medios';

  @override
  String get woosong_arts_center_w18 => 'Centro de artes Woosong (W18)';

  @override
  String get woosong_arts_center_info =>
      'B1F\tSala de preparación de presentaciones\n1F\tCentro de artes Woosong (629-6363)\n2F\tLaboratorio\n3F\tLaboratorio\n4F\tLaboratorio\n5F\tLaboratorio';

  @override
  String get woosong_arts_center_desc =>
      'Instalación de presentaciones artísticas';

  @override
  String get west_campus_andycut_w19 =>
      'Edificio Andycut del campus oeste (W19)';

  @override
  String get west_campus_andycut_info =>
      '2F\tDepartamento de negocios globales convergentes (630-9249)\n2F\tFacultad de estudios libres (630-9390)\n2F\tDepartamento de IA/Big Data (630-9807)\n2F\tDepartamento de gestión hotelera global (630-9249)\n2F\tDepartamento de medios y video globales (630-9346)\n2F\tDepartamento de gestión de servicios médicos globales (630-9283)\n2F\tFacultad de ferrocarriles/logística de transporte global (630-9347)\n2F\tDepartamento de emprendimiento culinario global (629-6860)';

  @override
  String get west_campus_andycut_desc => 'Edificio de departamentos globales';

  @override
  String get search_campus_buildings => 'Buscar edificios del campus';

  @override
  String get building_details => 'Información detallada';

  @override
  String get parking => 'Estacionamiento';

  @override
  String get accessibility => 'Instalaciones de conveniencia';

  @override
  String get facilities => 'Instalaciones';

  @override
  String get elevator => 'Ascensor';

  @override
  String get restroom => 'Baño';

  @override
  String get navigate_from_current_location =>
      'Navegar desde la ubicación actual';

  @override
  String get edit_profile => 'Editar perfil';

  @override
  String get nameRequired => 'Por favor ingrese su nombre';

  @override
  String get emailRequired => 'Por favor ingrese su correo electrónico';

  @override
  String get save => 'Guardar';

  @override
  String get saveSuccess => 'El perfil ha sido actualizado';

  @override
  String get app_info => 'Información de la aplicación';

  @override
  String get app_version => 'Versión de la aplicación';

  @override
  String get developer => 'Desarrollador';

  @override
  String get developer_name =>
      'Equipo: Jung Jin-young, Park Cheol-hyun, Cho Hyun-jun, Choi Seong-yeol, Han Seung-heon, Lee Ye-eun';

  @override
  String get developer_email => 'Correo: wsumap41@gmail.com';

  @override
  String get developer_github => 'GitHub: github.com/WSU-YJB/WSUMAP';

  @override
  String get no_help_images => 'No hay imágenes de ayuda';

  @override
  String get description_hint => 'Ingrese una descripción';

  @override
  String get my_info => 'Mi información';

  @override
  String get guest_user => 'Usuario invitado';

  @override
  String get guest_role => 'Rol de invitado';

  @override
  String get user => 'Usuario';

  @override
  String get edit_profile_subtitle => 'Puede modificar su información personal';

  @override
  String get help_subtitle => 'Verifique cómo usar la aplicación';

  @override
  String get app_info_subtitle => 'Información de versión y desarrollador';

  @override
  String get delete_account_subtitle => 'Eliminar la cuenta permanentemente';

  @override
  String get login_message =>
      'Iniciar sesión o registrarse\nPara usar todas las funciones';

  @override
  String get login_signup => 'Iniciar sesión / Registrarse';

  @override
  String get delete_account_confirm => 'Eliminar cuenta';

  @override
  String get delete_account_message => '¿Desea eliminar su cuenta?';

  @override
  String get logout_confirm => 'Cerrar sesión';

  @override
  String get logout_message => '¿Desea cerrar sesión?';

  @override
  String get yes => 'Sí';

  @override
  String get feature_in_progress => 'Función en desarrollo';

  @override
  String get delete_feature_in_progress =>
      'La función de eliminación de cuenta está en desarrollo';

  @override
  String get title => 'Editar perfil';

  @override
  String get email_required => 'Por favor ingrese su correo electrónico';

  @override
  String get name_required => 'Por favor ingrese su nombre';

  @override
  String get cancelFriendRequest => 'Cancelar solicitud de amistad';

  @override
  String cancelFriendRequestConfirm(String name) {
    return '¿Desea cancelar la solicitud de amistad enviada a $name?';
  }

  @override
  String get attached_image => 'Imagen adjunta';

  @override
  String get answer_section_title => 'Respuesta';

  @override
  String get inquiry_default_answer =>
      'Esta es la respuesta a su consulta. Si tiene preguntas adicionales, no dude en contactarnos en cualquier momento.';

  @override
  String get answer_date_prefix => 'Fecha de respuesta:';

  @override
  String get waiting_answer_status => 'Esperando respuesta';

  @override
  String get waiting_answer_message =>
      'Estamos revisando su consulta. Le responderemos lo antes posible.';

  @override
  String get status_pending => 'Pendiente de respuesta';

  @override
  String get status_answered => 'Respondido';

  @override
  String get cancelRequest => 'Cancelar solicitud';

  @override
  String get friendDeleteTitle => 'Eliminar amigo';

  @override
  String get friendDeleteWarning => 'Esta acción no se puede deshacer';

  @override
  String get friendDeleteHeader => 'Eliminar amigo';

  @override
  String get friendDeleteToConfirm => 'Ingrese el nombre del amigo a eliminar';

  @override
  String get friendDeleteCancel => 'Cancelar';

  @override
  String get friendDeleteButton => 'Eliminar';

  @override
  String get friendManagementAndRequests => 'Gestión y solicitudes de amigos';

  @override
  String get realTimeSyncStatus => 'Estado de sincronización en tiempo real';

  @override
  String get friendManagement => 'Gestión de amigos';

  @override
  String get add => 'Agregar';

  @override
  String sentRequestsCount(int count) {
    return 'Solicitudes enviadas ($count)';
  }

  @override
  String receivedRequestsCount(int count) {
    return 'Solicitudes recibidas ($count)';
  }

  @override
  String friendCount(int count) {
    return 'Mis amigos ($count)';
  }

  @override
  String get noFriends =>
      'Aún no tienes amigos.\n¡Presiona el botón + de arriba para agregar amigos!';

  @override
  String get open_settings => 'Abrir configuración';

  @override
  String get retry => 'Reintentar';

  @override
  String get basic_info => 'Información básica';

  @override
  String get status => 'Estado';

  @override
  String get floor_plan => 'Plano';

  @override
  String get indoorMap => 'Plano interior';

  @override
  String get showBuildingMarker => 'Mostrar marcador del edificio';

  @override
  String get search_hint => 'Buscar edificios del campus';

  @override
  String get searchHint => 'Buscar por edificio o habitación';

  @override
  String get searchInitialGuide => 'Busque edificios o habitaciones';

  @override
  String get searchHintExample =>
      'ej. W19, Edificio de Ingeniería, Habitación 401';

  @override
  String get searchLoading => 'Buscando...';

  @override
  String get searchNoResult => 'No hay resultados de búsqueda';

  @override
  String get searchTryAgain => 'Intente con diferentes palabras clave';

  @override
  String get required => 'Requerido';

  @override
  String get enter_title => 'Ingrese título';

  @override
  String get content => 'Contenido';

  @override
  String get enter_content => 'Ingrese contenido';

  @override
  String get restaurant => 'Restaurante';

  @override
  String get privacy_policy => 'Política de Privacidad';

  @override
  String get privacy_policy_subtitle => 'Consulte la Política de Privacidad';

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
  String get library => 'Biblioteca';

  @override
  String get setting => 'Configuración';

  @override
  String location_setting_confirm(String buildingName, String locationType) {
    return '¿Desea establecer $locationType?';
  }

  @override
  String get set_room => 'Establecer habitación';

  @override
  String friend_location_permission_denied(String name) {
    return '$name no permite compartir ubicación';
  }

  @override
  String get no_friends_message =>
      'No tienes amigos.\nPor favor agregue amigos y intente nuevamente.';

  @override
  String offline_friends_not_displayed(int count) {
    return '\n$count amigos offline no se muestran.';
  }

  @override
  String location_denied_friends_not_displayed(int count) {
    return '\n$count amigos que denegaron compartir ubicación no se muestran.';
  }

  @override
  String both_offline_and_location_denied(int offlineCount, int locationCount) {
    return '\n$offlineCount amigos offline y $locationCount amigos que denegaron compartir ubicación no se muestran.';
  }

  @override
  String get all_friends_offline_or_location_denied =>
      'Todos los amigos están offline o han denegado compartir ubicación.\nPuede verificar su ubicación cuando estén online y permitan compartir ubicación.';

  @override
  String get all_friends_offline =>
      'Todos los amigos están offline.\nPuede verificar su ubicación cuando estén online.';

  @override
  String get all_friends_location_denied =>
      'Todos los amigos han denegado compartir ubicación.\nPuede verificar su ubicación cuando permitan compartir ubicación.';

  @override
  String friends_location_display_success(int count) {
    return 'Se mostró la ubicación de $count amigos en el mapa.';
  }

  @override
  String friends_location_display_error(String error) {
    return 'No se pueden mostrar las ubicaciones de amigos: $error';
  }

  @override
  String offline_friends_dialog_subtitle(int count) {
    return '$count amigos actualmente offline';
  }

  @override
  String get friend_location_display_error =>
      'No se puede mostrar la ubicación del amigo';

  @override
  String get friend_location_remove_error => 'No se puede remover la ubicación';

  @override
  String get phone_app_error => 'No se puede abrir la aplicación de teléfono';

  @override
  String get add_friend_error => 'Error al agregar amigo';

  @override
  String get user_not_found => 'Usuario no encontrado';

  @override
  String get already_friend => 'El usuario ya es tu amigo';

  @override
  String get already_requested => 'Ya se envió una solicitud de amistad';

  @override
  String get cannot_add_self => 'No puedes agregarte a ti mismo como amigo';

  @override
  String get invalid_user_id => 'ID de usuario inválido';

  @override
  String get server_error_retry =>
      'Error del servidor. Por favor intente nuevamente más tarde';

  @override
  String get cancel_request_description =>
      'Cancelar solicitud de amistad enviada';

  @override
  String get enter_id_prompt => 'Ingrese ID';

  @override
  String get friend_request_sent_success =>
      'Solicitud de amistad enviada exitosamente';

  @override
  String get already_adding_friend =>
      'Ya estás agregando un amigo. Evite envíos duplicados';

  @override
  String friends_location_displayed(int count) {
    return 'Se mostró la ubicación de $count amigos.';
  }

  @override
  String get offline_friends_dialog_title => 'Amigos Offline';

  @override
  String friendRequestCancelled(String name) {
    return 'Solicitud de amistad cancelada enviada a $name.';
  }

  @override
  String get friendRequestCancelError =>
      'Error al cancelar solicitud de amistad.';

  @override
  String friendRequestAccepted(String name) {
    return 'Solicitud de amistad aceptada de $name.';
  }

  @override
  String get friendRequestAcceptError =>
      'Error al aceptar solicitud de amistad.';

  @override
  String friendRequestRejected(String name) {
    return 'Solicitud de amistad rechazada de $name.';
  }

  @override
  String get friendRequestRejectError =>
      'Error al rechazar solicitud de amistad.';

  @override
  String get friendLocationRemovedFromMap =>
      'Las ubicaciones de amigos han sido removidas del mapa.';

  @override
  String get info => 'Información';

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
