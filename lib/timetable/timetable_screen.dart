import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../generated/app_localizations.dart';
import 'timetable_item.dart';
import 'timetable_api_service.dart';
import 'timetable_storage_service.dart';
import '../map/widgets/directions_screen.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'excel_import_service.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'color_mapping_service.dart';
import '../config/api_config.dart';

// 상수 정의
class TimetableConstants {
  // 색상
  static const Color primaryColor = Color(0xFF1E3A8A);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color cardBackgroundColor = Colors.white;
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color textColor = Color(0xFF64748B);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor = Color(0xFF3B82F6);
  
  // 크기
  static const double borderRadius = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonHeight = 48.0;
  static const double iconSize = 20.0;
  static const double smallIconSize = 18.0;
  static const double largeIconSize = 24.0;
  
  // 시간표 관련
  static const int startHour = 9;
  static const int endHour = 18;
  static const int timeColumnWidth = 60;
  static const int smallTimeColumnWidth = 50;
  
  // 건물 코드
  static const List<String> buildingCodes = [
    'W1', 'W2', 'W2-1', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8', 'W9', 'W10',
    'W11', 'W12', 'W13', 'W14', 'W15', 'W16', 'W17-동관', 'W17-서관', 'W18', 'W19'
  ];
  
  // 색상 팔레트
  static const List<Color> colorPalette = [
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFFF59E0B),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
    Color(0xFF84CC16),
  ];
}

class ScheduleScreen extends StatefulWidget {
  final String userId;
  const ScheduleScreen({required this.userId, super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {

  List<ScheduleItem> _scheduleItems = [];
  bool _isInitialized = false;
  bool _isLoading = false;
  final TimetableApiService _apiService = TimetableApiService();

  @override
  void initState() {
    super.initState();
    _initializeTimetable();
  }
  
  /// 시간표 초기화 - 로컬 데이터 먼저 로드
  Future<void> _initializeTimetable() async {
    // 색상 매핑 초기화
    ColorMappingService.clearColorMapping();
    
    // 게스트 사용자가 아닌 경우에만 로컬 데이터 로드
    if (!widget.userId.startsWith('guest_')) {
      try {
        // 로컬 데이터 먼저 로드
        final localItems = await TimetableStorageService.loadTimetableData(widget.userId);
        if (localItems.isNotEmpty && mounted) {
          setState(() => _scheduleItems = localItems);
        }
      } catch (e) {
      }
    }
    
    // 그 다음 서버 데이터와 동기화
    await _loadScheduleItems();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
    }
  }

  String _getCurrentSemester() {
    final now = DateTime.now();
    final month = now.month;
    final l10n = AppLocalizations.of(context);

    if (month >= 12 || month <= 2) {
      return l10n?.winter_semester ?? '겨울학기';
    } else if (month >= 3 && month <= 5) {
      return l10n?.spring_semester ?? '봄학기';
    } else if (month >= 6 && month <= 8) {
      return l10n?.summer_semester ?? '여름학기';
    } else {
      return l10n?.fall_semester ?? '가을학기';
    }
  }

  int _getCurrentYear() => DateTime.now().year;

  Future<void> _loadScheduleItems() async {
    final l10n = AppLocalizations.of(context);
    
    // 색상 매핑 초기화 (새로운 데이터 로드 시)
    ColorMappingService.clearColorMapping();
    
    if (Platform.isAndroid) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      if (widget.userId.startsWith('guest_')) {
        if (mounted) {
          setState(() => _scheduleItems = []);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n?.guest_timetable_disabled ?? '게스트 사용자는 시간표 기능을 사용할 수 없습니다.',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: TimetableConstants.infoColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // 1. 먼저 로컬 데이터 로드
      final localItems = await TimetableStorageService.loadTimetableData(widget.userId);
      
      // 2. 로컬 데이터가 있으면 먼저 UI에 표시
      if (localItems.isNotEmpty && mounted) {
        setState(() => _scheduleItems = localItems);
      }
      
      // 3. 서버에서 최신 데이터 가져오기 시도
      try {
        final serverItems = await _apiService.fetchScheduleItems(widget.userId);
        
        // 4. 서버 데이터가 로컬 데이터와 다르면 업데이트
        if (serverItems.isNotEmpty) {
          // 로컬 저장소에 서버 데이터 저장
          await TimetableStorageService.saveTimetableData(widget.userId, serverItems);
          
          if (mounted) {
            setState(() => _scheduleItems = serverItems);
          }
        }
      } catch (serverError) {
        
        // 서버 로드 실패 시 로컬 데이터가 있으면 계속 사용
        if (localItems.isEmpty && mounted) {
          // 로컬 데이터도 없으면 오류 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.warning_outlined, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '시간표를 불러올 수 없습니다. 네트워크를 확인해주세요.',
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                  ),
                ],
              ),
              backgroundColor: TimetableConstants.warningColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      
      // 안드로이드에서 에러 처리 전 지연 처리
      if (Platform.isAndroid) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n?.timetable_load_failed ?? '시간표를 불러오지 못했습니다.',
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: TimetableConstants.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      // 안드로이드에서 로딩 상태 해제 전 지연 처리
      if (Platform.isAndroid) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addScheduleItem(ScheduleItem item) async {
    final l10n = AppLocalizations.of(context);
    // 게스트 사용자 체크
    if (widget.userId.startsWith('guest_')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n?.guest_timetable_add_disabled ?? '게스트 사용자는 시간표를 추가할 수 없습니다.',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: TimetableConstants.infoColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    try {
      // 1. 서버에 추가
      await _apiService.addScheduleItem(item, widget.userId);
      
      // 2. 로컬 저장소에도 추가 (색상 매핑 적용)
      final currentItems = List<ScheduleItem>.from(_scheduleItems);
      final itemWithColor = ScheduleItem(
        id: item.id,
        title: item.title,
        professor: item.professor,
        buildingName: item.buildingName,
        floorNumber: item.floorNumber,
        roomName: item.roomName,
        dayOfWeek: item.dayOfWeek,
        startTime: item.startTime,
        endTime: item.endTime,
        color: ColorMappingService.getColorForSubject(item.title),
        memo: item.memo,
      );
      currentItems.add(itemWithColor);
      await TimetableStorageService.saveTimetableData(widget.userId, currentItems);
      
      // 3. UI 업데이트
      if (mounted) {
        setState(() => _scheduleItems = currentItems);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n?.timetable_add_success ?? '시간표가 성공적으로 추가되었습니다.',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: TimetableConstants.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${l10n?.timetable_add_failed ?? '시간표 추가에 실패했습니다'}: ${e.toString().replaceAll('Exception: ', '')}',
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: TimetableConstants.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _updateScheduleItem(
    ScheduleItem originItem,
    ScheduleItem newItem,
  ) async {
    final l10n = AppLocalizations.of(context);
    // 게스트 사용자 체크
    if (widget.userId.startsWith('guest_')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n?.guest_timetable_edit_disabled ?? '게스트 사용자는 시간표를 수정할 수 없습니다.',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: TimetableConstants.infoColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // 1. 서버에 수정 요청
    await _apiService.updateScheduleItem(
      userId: widget.userId,
      originTitle: originItem.title,
      originDayOfWeek: originItem.dayOfWeekText,
      newItem: newItem,
    );
    
    // 2. 로컬 저장소에도 수정 (색상 매핑 적용)
    final newItemWithColor = ScheduleItem(
      id: newItem.id,
      title: newItem.title,
      professor: newItem.professor,
      buildingName: newItem.buildingName,
      floorNumber: newItem.floorNumber,
      roomName: newItem.roomName,
      dayOfWeek: newItem.dayOfWeek,
      startTime: newItem.startTime,
      endTime: newItem.endTime,
      color: ColorMappingService.getColorForSubject(newItem.title),
      memo: newItem.memo,
    );
    await TimetableStorageService.updateTimetableItem(widget.userId, originItem, newItemWithColor);
    
    // 3. UI 업데이트
    final currentItems = List<ScheduleItem>.from(_scheduleItems);
    for (int i = 0; i < currentItems.length; i++) {
      if (currentItems[i].title == originItem.title && 
          currentItems[i].dayOfWeek == originItem.dayOfWeek &&
          currentItems[i].startTime == originItem.startTime &&
          currentItems[i].endTime == originItem.endTime) {
        currentItems[i] = newItemWithColor;
        break;
      }
    }
    
    if (mounted) {
      setState(() => _scheduleItems = currentItems);
    }
  }

  Future<void> _deleteScheduleItem(ScheduleItem item) async {
    final l10n = AppLocalizations.of(context);
    // 게스트 사용자 체크
    if (widget.userId.startsWith('guest_')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n?.guest_timetable_delete_disabled ?? '게스트 사용자는 시간표를 삭제할 수 없습니다.',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: TimetableConstants.infoColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // 1. 서버에서 삭제
    await _apiService.deleteScheduleItem(
      userId: widget.userId,
      title: item.title,
      dayOfWeek: item.dayOfWeekText,
    );
    
    // 2. 로컬 저장소에서도 삭제
    await TimetableStorageService.removeTimetableItem(widget.userId, item);
    
    // 3. UI 업데이트
    final currentItems = List<ScheduleItem>.from(_scheduleItems);
    currentItems.removeWhere((existingItem) => 
      existingItem.title == item.title && 
      existingItem.dayOfWeek == item.dayOfWeek &&
      existingItem.startTime == item.startTime &&
      existingItem.endTime == item.endTime
    );
    
    if (mounted) {
      setState(() => _scheduleItems = currentItems);
    }
  }

  bool _isOverlapped(ScheduleItem newItem, {String? ignoreId}) {
    final newStart = _parseTime(newItem.startTime);
    final newEnd = _parseTime(newItem.endTime);

    for (final item in _scheduleItems) {
      if (ignoreId != null &&
          item.id != null &&
          item.id!.trim() == ignoreId.trim()) {
        continue;
      }
      if (item.dayOfWeek != newItem.dayOfWeek) continue;

      final existStart = _parseTime(item.startTime);
      final existEnd = _parseTime(item.endTime);

      if (newStart < existEnd && newEnd > existStart) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: TimetableConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildScheduleView()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 400;
          
          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.timetable ?? 'Timetable',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.w700,
                        color: TimetableConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '현재 학기 ',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: TimetableConstants.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: '${_getCurrentYear()}년 ${_getCurrentSemester()}',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: TimetableConstants.primaryColor.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap: _showExcelImportDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: TimetableConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.file_upload_outlined,
                              color: Color(0xFF1E3A8A),
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Flexible(
                              child: Text(
                                AppLocalizations.of(context)!.excel_file,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF1E3A8A),
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: TimetableConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: _showAddScheduleDialog,
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF1E3A8A),
                        size: 24,
                      ),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScheduleView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDayHeaders(),
          Expanded(
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: _buildOptimizedTimeTable(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizedTimeTable() {
    final timeSlots = _generateOptimizedTimeSlots();
    final currentTime = DateTime.now();
    final currentHour = currentTime.hour;
    final currentMinute = currentTime.minute;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 패딩을 고려해 사용 가능한 높이 계산
        const containerPadding = 8.0;
        final maxAvailableHeight =
            constraints.maxHeight - (containerPadding * 2);
        final rowHeight = maxAvailableHeight / timeSlots.length; // 동적 높이 계산
        final calculatedHeight = maxAvailableHeight; // 스크롤 없이 전체 높이 사용

        return Container(
          height: calculatedHeight, // 전체 높이를 명시적으로 제한
          padding: const EdgeInsets.all(containerPadding),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Column(
                children: timeSlots.asMap().entries.map((entry) {
                  final timeSlot = entry.value;
                  final isCurrentTime = _isCurrentTimeSlot(
                    timeSlot,
                    currentHour,
                    currentMinute,
                  );
                  return _buildTimeGridRow(timeSlot, isCurrentTime, rowHeight, constraints);
                }).toList(),
              ),
              ..._buildFloatingScheduleCards(constraints, rowHeight),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeGridRow(
    String timeSlot,
    bool isCurrentTime,
    double rowHeight,
    BoxConstraints constraints,
  ) {
    return Container(
      height: rowHeight, // 동적 높이 적용
      decoration: BoxDecoration(
        color: isCurrentTime ? TimetableConstants.primaryColor.withOpacity(0.05) : null,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
              child: Row(
          children: [
            Container(
              width: constraints.maxWidth < 400 ? TimetableConstants.smallTimeColumnWidth.toDouble() : TimetableConstants.timeColumnWidth.toDouble(),
              alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCurrentTime
                  ? TimetableConstants.primaryColor.withOpacity(0.1)
                  : Colors.grey.shade50,
              border: Border(
                right: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Text(
              timeSlot,
              style: TextStyle(
                fontSize: 10 * (rowHeight / 45.0).clamp(0.7, 1.0), // 동적 폰트 크기
                fontWeight: isCurrentTime ? FontWeight.w700 : FontWeight.w500,
                color: isCurrentTime
                    ? TimetableConstants.primaryColor
                    : Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: List.generate(5, (dayIndex) {
                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: dayIndex < 4
                            ? BorderSide(
                                color: Colors.grey.shade200,
                                width: 0.5,
                              )
                            : BorderSide.none,
                      ),
                    ),
                    height: rowHeight,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingScheduleCards(
    BoxConstraints constraints,
    double rowHeight,
  ) {
    final List<Widget> cards = [];

    for (int dayIndex = 0; dayIndex < 5; dayIndex++) {
      final daySchedules = _scheduleItems
          .where((item) => item.dayOfWeek == dayIndex + 1)
          .toList();

      for (final schedule in daySchedules) {
        final card = _buildAbsolutePositionedCard(
          schedule,
          dayIndex,
          constraints,
          rowHeight,
        );
        if (card != null) {
          cards.add(card);
        }
      }
    }

    return cards;
  }

  Widget? _buildAbsolutePositionedCard(
    ScheduleItem item,
    int dayIndex,
    BoxConstraints constraints,
    double rowHeight,
  ) {
    final startHour = int.parse(item.startTime.split(':')[0]);
    final startMinute = int.parse(item.startTime.split(':')[1]);
    final endHour = int.parse(item.endTime.split(':')[0]);
    final endMinute = int.parse(item.endTime.split(':')[1]);

    if (startHour < TimetableConstants.startHour || startHour > TimetableConstants.endHour) return null;

    // 실제 시간 컬럼 너비와 일치하도록 동적 계산
    final timeColumnWidth = constraints.maxWidth < 400 ? TimetableConstants.smallTimeColumnWidth.toDouble() : TimetableConstants.timeColumnWidth.toDouble();
    const containerPadding = 8.0;

    final availableWidth =
        constraints.maxWidth - timeColumnWidth - (containerPadding * 2);
    final dayColumnWidth = availableWidth / 5;

    // 동적 높이에 맞춰 위치 계산
    final startRowIndex = startHour - TimetableConstants.startHour;
    final startPixelOffset = startMinute / 60.0 * rowHeight;
    final top = (startRowIndex * rowHeight) + startPixelOffset;

    final endRowIndex = endHour - TimetableConstants.startHour;
    final endPixelOffset = endMinute / 60.0 * rowHeight;
    final cardHeight = (endRowIndex * rowHeight + endPixelOffset) - top;

    return Positioned(
      top: top,
      left: timeColumnWidth + (dayIndex * dayColumnWidth) + 1, // 미세 조정
      width: dayColumnWidth - 2, // 양쪽 여백 고려
      height: cardHeight.clamp(
        rowHeight * 0.5,
        constraints.maxHeight - top,
      ), // 오버플로우 방지
      child: GestureDetector(
        onTap: () => _showScheduleDetail(item),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 0.5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                item.color.withOpacity(0.9),
                item.color.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: item.color.withOpacity(0.2),
                blurRadius: 1,
                offset: const Offset(0, 0.5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 8 * (rowHeight / 45.0).clamp(0.7, 1.0),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                if (cardHeight > rowHeight * 0.6) ...[
                  const SizedBox(height: 1),
                  Text(
                    '${item.startTime}-${item.endTime}',
                    style: TextStyle(
                      fontSize: 6 * (rowHeight / 45.0).clamp(0.7, 1.0),
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
                if (cardHeight > rowHeight && item.roomName.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    '${item.buildingName} ${item.roomName}',
                    style: TextStyle(
                      fontSize: 6 * (rowHeight / 45.0).clamp(0.7, 1.0),
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayHeaders() {
    final l10n = AppLocalizations.of(context);
    final days = [
      l10n?.time ?? 'Time',
      l10n?.monday ?? 'Mon',
      l10n?.tuesday ?? 'Tue',
      l10n?.wednesday ?? 'Wed',
      l10n?.thursday ?? 'Thu',
      l10n?.friday ?? 'Fri',
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;
        
        return Container(
          height: isSmallScreen ? 40 : 50,
          decoration: BoxDecoration(
            color: TimetableConstants.backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: days
                .map(
                  (day) => Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 1 : 2,
                      ),
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 11 : 14,
                          fontWeight: FontWeight.w600,
                          color: TimetableConstants.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  List<String> _generateOptimizedTimeSlots() {
    final slots = <String>[];
    for (int hour = TimetableConstants.startHour; hour <= TimetableConstants.endHour; hour++) {
      slots.add('${hour.toString().padLeft(2, '0')}:00');
    }
    return slots;
  }

  bool _isCurrentTimeSlot(String timeSlot, int currentHour, int currentMinute) {
    final slotHour = int.parse(timeSlot.split(':')[0]);
    return currentHour == slotHour;
  }

  List<String> _generateTimeSlots() {
    final slots = <String>[];
    for (int hour = TimetableConstants.startHour; hour <= TimetableConstants.endHour; hour++) {
      slots.add('${hour.toString().padLeft(2, '0')}:00');
      if (hour < TimetableConstants.endHour) {
        slots.add('${hour.toString().padLeft(2, '0')}:30');
      }
    }
    return slots;
  }

  int _parseTime(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  String _getDayName(int dayOfWeek) {
    final l10n = AppLocalizations.of(context);

    switch (dayOfWeek) {
      case 1:
        return l10n?.monday_full ?? 'Monday';
      case 2:
        return l10n?.tuesday_full ?? 'Tuesday';
      case 3:
        return l10n?.wednesday_full ?? 'Wednesday';
      case 4:
        return l10n?.thursday_full ?? 'Thursday';
      case 5:
        return l10n?.friday_full ?? 'Friday';
      default:
        return '';
    }
  }

  Future<void> _showDeleteConfirmDialog(ScheduleItem item) async {
    final l10n = AppLocalizations.of(context)!; // null 체크 위해 '!' 추가

    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_outlined,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.scheduleDeleteTitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.scheduleDeleteSubtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.scheduleDeleteLabel,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.scheduleDeleteDescription(item.title),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: TimetableConstants.backgroundColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l10n.cancelButton,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            l10n.deleteButton,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      await _deleteScheduleItem(item);
    }
  }

  Future<void> _showScheduleFormDialog({
    ScheduleItem? initialItem,
    required Future<void> Function(ScheduleItem) onSubmit,
  }) async {
    final l10n = AppLocalizations.of(context);

    final titleController = TextEditingController(
      text: initialItem?.title ?? '',
    );
    final professorController = TextEditingController(
      text: initialItem?.professor ?? '',
    );
    final memoController = TextEditingController(text: initialItem?.memo ?? '');

    final buildingFieldController = TextEditingController(
      text: initialItem?.buildingName ?? '',
    );
    final floorFieldController = TextEditingController(
      text: initialItem?.floorNumber ?? '',
    );
    final roomFieldController = TextEditingController(
      text: initialItem?.roomName ?? '',
    );

    String? selectedBuilding = initialItem?.buildingName;
    String? selectedFloor = initialItem?.floorNumber;
    String? selectedRoom = initialItem?.roomName;

    int selectedDay = initialItem?.dayOfWeek ?? 1;
    String startTime = initialItem?.startTime.length == 5
        ? initialItem!.startTime
        : '09:00';
    String endTime = initialItem?.endTime.length == 5
        ? initialItem!.endTime
        : '10:30';
    Color selectedColor = initialItem?.color ?? TimetableConstants.infoColor;

    final colors = TimetableConstants.colorPalette;

    final List<String> buildingCodes = TimetableConstants.buildingCodes;

    List<String> floorList = [];
    List<String> roomList = [];

    if (initialItem != null) {
      floorList = await _apiService.fetchFloors(initialItem.buildingName);
      roomList = await _apiService.fetchRooms(
        initialItem.buildingName,
        initialItem.floorNumber,
      );
    }

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => SafeArea(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: TimetableConstants.primaryColor.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: TimetableConstants.primaryColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.schedule,
                              color: Color(0xFF1E3A8A),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              initialItem == null
                                  ? l10n?.add_class ?? 'Add Class'
                                  : l10n?.edit_class ?? 'Edit Class',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _buildStyledInputField(
                              controller: titleController,
                              labelText: l10n?.class_name ?? 'Class Name',
                              icon: Icons.book,
                              autofocus: false,
                            ),
                            const SizedBox(height: 16),
                            _buildStyledInputField(
                              controller: professorController,
                              labelText: l10n?.professor_name ?? 'Professor',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),
                            _buildTypeAheadField(
                              controller: buildingFieldController,
                              labelText: l10n?.building_name ?? 'Building',
                              icon: Icons.business,
                              items: buildingCodes,
                                onChanged: (value) async {
                                  selectedBuilding = value;
                                  setState(() {
                                    selectedFloor = null;
                                    selectedRoom = null;
                                    floorFieldController.text = '';
                                    roomFieldController.text = '';
                                    floorList = [];
                                    roomList = [];
                                  });
                                  if (buildingCodes.contains(value)) {
                                    final fetchedFloors = await _apiService.fetchFloors(value);
                                    setState(() {
                                      floorList = fetchedFloors;
                                    });
                                  }
                                },
                            ),
                            const SizedBox(height: 16),
                            _buildTypeAheadField(
                              controller: floorFieldController,
                              labelText: l10n?.floor_label ?? 'Floor',
                              icon: Icons.layers,
                              items: floorList,
                              onChanged: (value) async {
                                selectedFloor = value;
                                setState(() {
                                  selectedRoom = null;
                                  roomFieldController.text = '';
                                  roomList = [];
                                });
                                if (floorList.contains(value)) {
                                  final fetchedRooms = await _apiService.fetchRooms(selectedBuilding!, value);
                                  setState(() {
                                    roomList = fetchedRooms;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTypeAheadField(
                              controller: roomFieldController,
                              labelText: l10n?.room_name ?? 'Room',
                              icon: Icons.meeting_room,
                              items: roomList,
                              onChanged: (value) {
                                selectedRoom = value;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildStyledDropdownField<int>(
                              value: selectedDay,
                              labelText: l10n?.day_of_week ?? 'Day',
                              icon: Icons.calendar_today,
                              items: [
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text(l10n?.monday_full ?? 'Monday'),
                                ),
                                DropdownMenuItem(
                                  value: 2,
                                  child: Text(l10n?.tuesday_full ?? 'Tuesday'),
                                ),
                                DropdownMenuItem(
                                  value: 3,
                                  child: Text(
                                    l10n?.wednesday_full ?? 'Wednesday',
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 4,
                                  child: Text(
                                    l10n?.thursday_full ?? 'Thursday',
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 5,
                                  child: Text(l10n?.friday_full ?? 'Friday'),
                                ),
                              ],
                              onChanged: (value) =>
                                  setState(() => selectedDay = value!),
                            ),
                            const SizedBox(height: 16),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isSmallScreen =
                                    constraints.maxWidth < 400;

                                if (isSmallScreen) {
                                  // 작은 화면: 세로로 배치
                                  return Column(
                                    children: [
                                      _buildStyledDropdownField<String>(
                                        value: startTime,
                                        labelText:
                                            l10n?.start_time ?? 'Start Time',
                                        icon: Icons.access_time,
                                        items: _generateTimeSlots()
                                            .map(
                                              (time) => DropdownMenuItem(
                                                value: time,
                                                child: Text(time),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            startTime = value!;
                                            var slotList = _generateTimeSlots();
                                            int idx = slotList.indexOf(
                                              startTime,
                                            );
                                            if (_parseTime(endTime) <=
                                                _parseTime(startTime)) {
                                              endTime =
                                                  (idx + 1 < slotList.length)
                                                  ? slotList[idx + 1]
                                                  : slotList[idx];
                                            }
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      _buildStyledDropdownField<String>(
                                        value: endTime,
                                        labelText: l10n?.end_time ?? 'End Time',
                                        icon: Icons.access_time_filled,
                                        items: _generateTimeSlots()
                                            .where(
                                              (time) =>
                                                  _parseTime(time) >
                                                  _parseTime(startTime),
                                            )
                                            .map(
                                              (time) => DropdownMenuItem(
                                                value: time,
                                                child: Text(time),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) =>
                                            setState(() => endTime = value!),
                                      ),
                                    ],
                                  );
                                } else {
                                  // 큰 화면: 가로로 배치
                                  return Row(
                                    children: [
                                      Expanded(
                                        child:
                                            _buildStyledDropdownField<String>(
                                              value: startTime,
                                              labelText:
                                                  l10n?.start_time ??
                                                  'Start Time',
                                              icon: Icons.access_time,
                                              items: _generateTimeSlots()
                                                  .map(
                                                    (time) => DropdownMenuItem(
                                                      value: time,
                                                      child: Text(time),
                                                    ),
                                                  )
                                                  .toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  startTime = value!;
                                                  var slotList =
                                                      _generateTimeSlots();
                                                  int idx = slotList.indexOf(
                                                    startTime,
                                                  );
                                                  if (_parseTime(endTime) <=
                                                      _parseTime(startTime)) {
                                                    endTime =
                                                        (idx + 1 <
                                                            slotList.length)
                                                        ? slotList[idx + 1]
                                                        : slotList[idx];
                                                  }
                                                });
                                              },
                                            ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child:
                                            _buildStyledDropdownField<String>(
                                              value: endTime,
                                              labelText:
                                                  l10n?.end_time ?? 'End Time',
                                              icon: Icons.access_time_filled,
                                              items: _generateTimeSlots()
                                                  .where(
                                                    (time) =>
                                                        _parseTime(time) >
                                                        _parseTime(startTime),
                                                  )
                                                  .map(
                                                    (time) => DropdownMenuItem(
                                                      value: time,
                                                      child: Text(time),
                                                    ),
                                                  )
                                                  .toList(),
                                              onChanged: (value) => setState(
                                                () => endTime = value!,
                                              ),
                                            ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: TimetableConstants.backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: TimetableConstants.borderColor,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.palette,
                                        color: Color(0xFF1E3A8A),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n?.color_selection ?? 'Select Color',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E3A8A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 8,
                                    children: colors.map((color) {
                                      return GestureDetector(
                                        onTap: () => setState(
                                          () => selectedColor = color,
                                        ),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius: BorderRadius.circular(
                                              22,
                                            ),
                                            border: Border.all(
                                              color: selectedColor == color
                                                  ? TimetableConstants.primaryColor
                                                  : Colors.transparent,
                                              width: 3,
                                            ),
                                            boxShadow: selectedColor == color
                                                ? [
                                                    BoxShadow(
                                                      color: color.withOpacity(
                                                        0.3,
                                                      ),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ]
                                                : [],
                                          ),
                                          child: selectedColor == color
                                              ? const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 20,
                                                )
                                              : null,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildStyledInputField(
                              controller: memoController,
                              labelText: l10n?.memo ?? 'Memo',
                              icon: Icons.note_alt_outlined,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: TimetableConstants.backgroundColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          // 반응형 버튼 레이아웃
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isSmallScreen = constraints.maxWidth < 400;

                              if (isSmallScreen) {
                                // 작은 화면: 세로로 배치
                                return Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (titleController.text.isNotEmpty &&
                                              selectedBuilding?.isNotEmpty ==
                                                  true &&
                                              selectedFloor?.isNotEmpty ==
                                                  true &&
                                              selectedRoom?.isNotEmpty ==
                                                  true) {
                                            final newItem = ScheduleItem(
                                              id: initialItem?.id,
                                              title: titleController.text,
                                              professor:
                                                  professorController.text,
                                              buildingName: selectedBuilding!,
                                              floorNumber: selectedFloor!,
                                              roomName: selectedRoom!,
                                              dayOfWeek: selectedDay,
                                              startTime: startTime,
                                              endTime: endTime,
                                              color: selectedColor,
                                              memo: memoController.text,
                                            );
                                            if (_isOverlapped(
                                              newItem,
                                              ignoreId: initialItem?.id,
                                            )) {
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    l10n?.overlap_message ??
                                                        '이미 같은 시간에 등록된 수업이 있습니다.',
                                                  ),
                                                  backgroundColor: const Color(
                                                    0xFFEF4444,
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
                                            await onSubmit(newItem);
                                            Navigator.pop(context);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF1E3A8A,
                                          ),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 2,
                                        ),
                                        child: Text(
                                          initialItem == null
                                              ? l10n?.add ?? 'Add'
                                              : l10n?.save ?? 'Save',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: OutlinedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          l10n?.cancel ?? 'Cancel',
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                // 큰 화면: 가로로 배치
                                return Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 48,
                                        child: OutlinedButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: Color(0xFFE2E8F0),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            l10n?.cancel ?? 'Cancel',
                                            style: const TextStyle(
                                              color: Color(0xFF64748B),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: SizedBox(
                                        height: 48,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            if (titleController
                                                    .text
                                                    .isNotEmpty &&
                                                selectedBuilding?.isNotEmpty ==
                                                    true &&
                                                selectedFloor?.isNotEmpty ==
                                                    true &&
                                                selectedRoom?.isNotEmpty ==
                                                    true) {
                                              final newItem = ScheduleItem(
                                                id: initialItem?.id,
                                                title: titleController.text,
                                                professor:
                                                    professorController.text,
                                                buildingName: selectedBuilding!,
                                                floorNumber: selectedFloor!,
                                                roomName: selectedRoom!,
                                                dayOfWeek: selectedDay,
                                                startTime: startTime,
                                                endTime: endTime,
                                                color: selectedColor,
                                                memo: memoController.text,
                                              );
                                              if (_isOverlapped(
                                                newItem,
                                                ignoreId: initialItem?.id,
                                              )) {
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      l10n?.overlap_message ??
                                                          '이미 같은 시간에 등록된 수업이 있습니다.',
                                                    ),
                                                    backgroundColor:
                                                        TimetableConstants.errorColor,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                              await onSubmit(newItem);
                                              Navigator.pop(context);
                                            }
                                            else {
  FocusScope.of(context).unfocus();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('필수 입력값을 모두 입력해 주세요.'),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ),
  );
}
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF1E3A8A,
                                            ),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 2,
                                          ),
                                          child: Text(
                                            initialItem == null
                                                ? l10n?.add ?? 'Add'
                                                : l10n?.save ?? 'Save',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStyledInputField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool autofocus = false,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TimetableConstants.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        autofocus: autofocus,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 16, color: Color(0xFF1E3A8A)),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
          prefixIcon: Icon(icon, color: TimetableConstants.primaryColor, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
      ),
    );
  }



  Widget _buildStyledDropdownField<T>({
    required T? value,
    required String labelText,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TimetableConstants.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 16, color: Color(0xFF1E3A8A)),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TimetableConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: TimetableConstants.primaryColor, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        dropdownColor: Colors.white,
        icon: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: TimetableConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF1E3A8A),
            size: 20,
          ),
        ),
        iconSize: 24,
        elevation: 8,
        menuMaxHeight: 200,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildStyledDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: TimetableConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: TimetableConstants.primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddScheduleDialog() {
    _showScheduleFormDialog(
      onSubmit: (item) async => await _addScheduleItem(item),
    );
  }

  void _showExcelImportDialog() {
    _showSimpleExcelUploadDialog(context, widget.userId, _loadScheduleItems);
  }

  void _showEditScheduleDialog(ScheduleItem item) {
    _showScheduleFormDialog(
      initialItem: item,
      onSubmit: (newItem) async => await _updateScheduleItem(item, newItem),
    );
  }

  Widget _buildTypeAheadField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    TextEditingController? _internalController;
    return TypeAheadField<String>(
      suggestionsCallback: (pattern) async {
        if (pattern.isEmpty) return items;
        return items.where((item) =>
          item.toLowerCase().startsWith(pattern.toLowerCase())
        ).toList();
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion,
            style: const TextStyle(fontSize: 16, color: Color(0xFF1E3A8A)),
          ),
        );
      },
      onSelected: (suggestion) {
        // 동기화: 내부 컨트롤러와 외부 컨트롤러 모두 업데이트
        controller.text = suggestion;
        _internalController?.text = suggestion;
        onChanged(suggestion);
      },
      builder: (context, textController, focusNode) {
        // 내부 컨트롤러 참조 저장 (onSelected에서 텍스트 반영)
        _internalController = textController;
        return TextField(
          controller: textController,
          focusNode: focusNode,
          style: const TextStyle(fontSize: 16, color: Color(0xFF1E3A8A)),
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
            prefixIcon: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TimetableConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: TimetableConstants.primaryColor, size: 20),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
        );
      },
      emptyBuilder: (context) => const SizedBox(
        height: 40,
        child: Center(child: Text('검색 결과 없음', style: TextStyle(fontSize: 14))),
      ),
    );
  }

  void _showRecommendRoute(ScheduleItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DirectionsScreen(
          roomData: {
            "type": "end",
            "buildingName": item.buildingName,
            "floorNumber": item.floorNumber,
            "roomName": item.roomName,
          },
        ),
      ),
    );
  }

  void _showBuildingLocation(ScheduleItem item) {

    // 메인 지도 화면으로 이동하면서 건물 정보를 전달
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/map',
      (route) => false, // 모든 이전 화면 제거
      arguments: {
        'showBuilding': item.buildingName,
        'buildingInfo': {
          'name': item.buildingName,
          'floorNumber': item.floorNumber,
          'roomName': item.roomName,
        },
      },
    );

  }


  void _showScheduleDetail(ScheduleItem item) {
  final l10n = AppLocalizations.of(context)!;

  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.schedule, color: item.color, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: item.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_getDayName(item.dayOfWeek)} ${item.startTime} - ${item.endTime}',
                          style: TextStyle(
                            fontSize: 14,
                            color: item.color.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    _buildStyledDetailRow(
                      Icons.person,
                      l10n.professor_name,
                      item.professor,
                    ),
                    const SizedBox(height: 16),
                    _buildStyledDetailRow(
                      Icons.business,
                      l10n.building_name,
                      item.buildingName,
                    ),
                    const SizedBox(height: 16),
                    _buildStyledDetailRow(
                      Icons.layers,
                      l10n.floor_label,
                      item.floorNumber,
                    ),
                    const SizedBox(height: 16),
                    _buildStyledDetailRow(
                      Icons.meeting_room,
                      l10n.room_name,
                      item.roomName,
                    ),
                    const SizedBox(height: 16),
                    _buildStyledDetailRow(
                      Icons.calendar_today,
                      l10n.day_of_week,
                      _getDayName(item.dayOfWeek),
                    ),
                    const SizedBox(height: 16),
                    _buildStyledDetailRow(
                      Icons.access_time,
                      l10n.time,
                      '${item.startTime} - ${item.endTime}',
                    ),
                    if (item.memo.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildStyledDetailRow(
                        Icons.note_alt_outlined,
                        l10n.memo,
                        item.memo,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: TimetableConstants.backgroundColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmallScreen = constraints.maxWidth < 350;

                      Widget recommendRouteButton = ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showRecommendRoute(item);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TimetableConstants.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.directions, size: 18),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                l10n.recommend_route,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );

                      Widget viewLocationButton = ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showBuildingLocation(item);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TimetableConstants.infoColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, size: 18),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                l10n.view_location,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );

                      Widget editButton = ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditScheduleDialog(item);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TimetableConstants.textColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.edit, size: 18),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                l10n.edit,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );


                      if (isSmallScreen) {
                        // 작은 화면에서는 더 작은 화면인지 추가 확인
                        final isVerySmallScreen = constraints.maxWidth < 300;
                        
                        if (isVerySmallScreen) {
                          // 매우 작은 화면: 아이콘만 표시, 높이 축소
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 42,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _showRecommendRoute(item);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: TimetableConstants.primaryColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          elevation: 1,
                                        ),
                                        child: const Icon(Icons.directions, size: 16),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: SizedBox(
                                      height: 42,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _showBuildingLocation(item);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: TimetableConstants.infoColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          elevation: 1,
                                        ),
                                        child: const Icon(Icons.location_on, size: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 42,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _showEditScheduleDialog(item);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: TimetableConstants.textColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          elevation: 1,
                                        ),
                                        child: const Icon(Icons.edit, size: 16),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  SizedBox(
                                    width: 42, 
                                    height: 42, 
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await _showDeleteConfirmDialog(item);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: TimetableConstants.errorColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        elevation: 1,
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: const Icon(Icons.delete, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else {
                          // 작은 화면: 아이콘 + 텍스트 (오버플로우 방지), 높이 축소
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: SizedBox(height: 44, child: recommendRouteButton)),
                                  const SizedBox(width: 6),
                                  Expanded(child: SizedBox(height: 44, child: viewLocationButton)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(child: SizedBox(height: 44, child: editButton)),
                                  const SizedBox(width: 6),
                                  SizedBox(
                                    width: 44, 
                                    height: 44, 
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await _showDeleteConfirmDialog(item);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: TimetableConstants.errorColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        elevation: 1,
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: const Icon(Icons.delete, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                      } else {
                        return Row(
                          children: [
                            Expanded(child: SizedBox(height: 44, child: recommendRouteButton)),
                            const SizedBox(width: 8),
                            Expanded(child: SizedBox(height: 44, child: viewLocationButton)),
                            const SizedBox(width: 8),
                            Expanded(child: SizedBox(height: 44, child: editButton)),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 44, 
                              height: 44, 
                              child: ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await _showDeleteConfirmDialog(item);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: TimetableConstants.errorColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 1,
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Icon(Icons.delete, size: 16),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: TimetableConstants.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        l10n.close,
                        style: const TextStyle(
                          color: TimetableConstants.textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    ),
  );
  }
}

// 간단하고 직관적인 엑셀 업로드 다이얼로그
void _showSimpleExcelUploadDialog(BuildContext context, String userId, Future<void> Function() refreshCallback) {
  showDialog(
    context: context,
    barrierDismissible: true, // 사용자가 외부 클릭으로 닫을 수 있도록 허용
    builder: (context) => _SimpleExcelUploadDialog(
      userId: userId,
      refreshCallback: refreshCallback,
    ),
  );
}

// 상태를 가진 간단한 엑셀 업로드 다이얼로그
class _SimpleExcelUploadDialog extends StatefulWidget {
  final String userId;
  final Future<void> Function() refreshCallback;
  
  const _SimpleExcelUploadDialog({
    required this.userId,
    required this.refreshCallback,
  });
  
  @override
  State<_SimpleExcelUploadDialog> createState() => _SimpleExcelUploadDialogState();
}

class _SimpleExcelUploadDialogState extends State<_SimpleExcelUploadDialog> {
  bool _isUploading = false;
  bool _showTutorial = false;
  bool _uploadSuccess = false;
  int _tutorialPage = 0;
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: _showTutorial 
            ? MediaQuery.of(context).size.height * 0.75  // 튜토리얼일 때 더 큰 높이
            : null,  // 기본 업로드 화면일 때는 내용에 맞춤
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목
            Row(
              children: [
                const Icon(Icons.file_upload_outlined, color: Color(0xFF1E3A8A), size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.excel_upload_title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ),
                if (!_isUploading && !_uploadSuccess)
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_isUploading) ...[
              // 업로드 중 표시
              const CircularProgressIndicator(color: Color(0xFF1E3A8A)),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.excel_upload_uploading,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ] else if (_uploadSuccess) ...[
              // 업로드 성공 표시
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.excel_upload_success,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.excel_upload_refreshing,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ] else if (_showTutorial) ...[
              // 튜토리얼 표시
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Column(
                    children: [
                      // 헤더
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Colors.grey.shade50,
                        child: Row(
                          children: [
                            IconButton(
                onPressed: () {
                  setState(() => _showTutorial = false);
                },
                              icon: const Icon(Icons.arrow_back, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${AppLocalizations.of(context)!.excel_tutorial_title} (${_tutorialPage + 1}/6)',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                                            // 콘텐츠 영역
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          child: _buildTutorialPage(_tutorialPage),
                        ),
                      ),
                      
                      // 네비게이션
                      Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_tutorialPage > 0)
                              OutlinedButton(
                                onPressed: () => setState(() => _tutorialPage--),
                                child: Text(AppLocalizations.of(context)!.excel_tutorial_previous),
                              )
                            else
                              const SizedBox(width: 80),
                            
                            Row(
                              children: List.generate(
                                6,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: index == _tutorialPage 
                                        ? TimetableConstants.primaryColor 
                                        : Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                            
                            if (_tutorialPage < 5)
                              OutlinedButton(
                                onPressed: () => setState(() => _tutorialPage++),
                                child: Text(AppLocalizations.of(context)!.excel_tutorial_next),
                              )
                            else
                              OutlinedButton(
                                onPressed: _uploadExcelFile,
                                child: Text(AppLocalizations.of(context)!.excel_tutorial_file_select),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: TimetableConstants.primaryColor,
                                  side: const BorderSide(color: Color(0xFF1E3A8A)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // 기본 업로드 화면
              _buildUploadContent(),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildUploadContent() {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.excel_upload_description,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        
        // 엑셀 파일 선택 버튼
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _uploadExcelFile,
            icon: const Icon(Icons.folder_open, size: 20),
            label: Text(AppLocalizations.of(context)!.excel_file_select, style: const TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: TimetableConstants.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 튜토리얼 보기 버튼
        SizedBox(
          width: double.infinity,
          height: 42,
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _showTutorial = true),
            icon: const Icon(Icons.help_outline, size: 18),
            label: Text(AppLocalizations.of(context)!.excel_tutorial_help, style: const TextStyle(fontSize: 14)),
            style: OutlinedButton.styleFrom(
              foregroundColor: TimetableConstants.primaryColor,
              side: const BorderSide(color: Color(0xFF1E3A8A)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  
  
  
  Widget _buildTextPage() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: TimetableConstants.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.excel_tutorial_step_1,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                AppLocalizations.of(context)!.excel_tutorial_url,
                style: const TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

          ],
        ),
      ),
    );
  }
  
  Widget _buildTutorialPage(int page) {
    
    switch (page) {
      case 0:
        return _buildTextPage();
      case 1:
        return _buildSimpleImagePage('assets/timetable/tutorial/1.png');
      case 2:
        return _buildSimpleImagePage('assets/timetable/tutorial/2.png');
      case 3:
        return _buildSimpleImagePage('assets/timetable/tutorial/3.png');
      case 4:
        return _buildSimpleImagePage('assets/timetable/tutorial/4.png');
      case 5:
        return _buildSimpleImagePage('assets/timetable/tutorial/5.png');
      default:
        return Container(
          color: Colors.red.shade100,
          child: Center(
            child: Text(AppLocalizations.of(context)!.excel_tutorial_unknown_page),
          ),
        );
    }
  }
  
  Widget _buildSimpleImagePage(String assetPath) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          // 이미지 캐싱 최적화
          cacheWidth: 400,
          cacheHeight: 600,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 48, color: Colors.red.shade400),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.excel_tutorial_image_load_error,
                    style: TextStyle(color: Colors.red.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    assetPath,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  
  Future<void> _uploadExcelFile() async {
    if (!mounted) return;
    
    setState(() => _isUploading = true);
    
    // 안드로이드에서 화면 잠금 해제를 더 안전하게 처리
    bool wakelockEnabled = false;
    try {
      await WakelockPlus.enable();
      wakelockEnabled = true;
    } catch (e) {
      // Wakelock 활성화 실패 시 무시
    }
    
    try {
      final success = await ExcelImportService.uploadExcelToServer(widget.userId);
      
      if (mounted) {
        if (success) {
          
          // 업로드 중 상태 해제
          if (mounted) {
            setState(() => _isUploading = false);
          }
          
          // 다이얼로그를 먼저 닫고 UI 상태를 안정화
          if (mounted) {
            Navigator.pop(context);
            
            // 안드로이드에서 시스템 UI 재설정
            _resetSystemUIForAndroid();
            
            // UI 상태 안정화를 위한 지연 처리
            await Future.delayed(const Duration(milliseconds: 500));
            
            // 🔥 엑셀 업로드 후 명시적으로 서버에서 시간표 다시 불러오기
            try {
              // 색상 매핑 초기화 (새로운 엑셀 데이터에 대해 색상 재할당)
              ColorMappingService.clearColorMapping();
              
              final apiService = TimetableApiService();
              debugPrint('[DEBUG] ⏳ 엑셀 업로드 후 시간표 데이터 새로고침 시작...');
              debugPrint('[DEBUG] 📡 서버에서 시간표 조회 요청: ${ApiConfig.timetableBase}');
              
              // 서버에서 최신 시간표 데이터 가져오기
              final latestItems = await apiService.fetchScheduleItems(widget.userId);
              debugPrint('[DEBUG] ✅ 시간표 데이터 조회 완료: ${latestItems.length}개 항목');
              
              // 로컬 저장소에 최신 데이터 저장
              await TimetableStorageService.saveTimetableData(widget.userId, latestItems);
              debugPrint('[DEBUG] ✅ 로컬 저장소 업데이트 완료');
              
              // refreshCallback 호출하여 부모 위젯(_ScheduleScreenState)에서 UI 업데이트
              try {
                await widget.refreshCallback();
                debugPrint('[DEBUG] ✅ refreshCallback 완료: UI 업데이트됨 (${latestItems.length}개 항목)');
              } catch (e) {
                debugPrint('[WARNING] refreshCallback 실행 중 오류 (무시): $e');
              }
              
              // 성공 메시지 표시
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.excel_upload_success_message,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
              
            } catch (e, stackTrace) {
              // 시간표 새로고침 실패 시 상세 에러 로그 출력
              debugPrint('[ERROR] ❌ 시간표 새로고침 실패: $e');
              debugPrint('[ERROR] ❌ 스택 트레이스: $stackTrace');
              // 릴리스 빌드에서도 에러 확인을 위해 콘솔에 출력
              print('ERROR: 시간표 새로고침 실패 - $e');
              print('ERROR: 스택 트레이스 - $stackTrace');
              
              // 새로고침 실패 시에도 성공 메시지 표시 (업로드는 성공했으므로)
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.excel_upload_success_message,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                    action: SnackBarAction(
                      label: '수동 새로고침',
                      textColor: Colors.white,
                      onPressed: () {
                        widget.refreshCallback();
                      },
                    ),
                  ),
                );
              }
            }
            
            // 성공 메시지 표시 (에러가 발생하지 않은 경우 - catch 블록에서 이미 표시했으므로 여기서는 제외)
          }
          
          // 작업 완료 후 wakelock 해제
          if (wakelockEnabled) {
            try {
              await WakelockPlus.disable();
            } catch (e) {
              // Wakelock 비활성화 실패 시 무시
            }
          }
        } else {
          // 파일 선택 취소
          setState(() => _isUploading = false);
          Navigator.pop(context);
          
          // 안드로이드에서 시스템 UI 재설정
          _resetSystemUIForAndroid();
          
          // wakelock 해제
          if (wakelockEnabled) {
            try {
              await WakelockPlus.disable();
            } catch (e) {
              // Wakelock 비활성화 실패 시 무시
            }
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(AppLocalizations.of(context)!.excel_upload_file_cancelled),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        Navigator.pop(context);
        
        // 안드로이드에서 시스템 UI 재설정
        _resetSystemUIForAndroid();
        
        // 에러 시에도 wakelock 해제
        if (wakelockEnabled) {
          try {
            await WakelockPlus.disable();
          } catch (e) {
            // Wakelock 비활성화 실패 시 무시
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(AppLocalizations.of(context)!.excel_upload_failed(e.toString()))),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  
  /// 안드로이드에서 시스템 UI 재설정 함수
  void _resetSystemUIForAndroid() {
    if (Platform.isAndroid) {
      try {
        // 안드로이드에서 immersiveSticky 모드로 재설정
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.immersiveSticky,
          overlays: [SystemUiOverlay.top],
        );
      } catch (e) {
        // 시스템 UI 재설정 실패 시 무시
      }
    }
  }
}
