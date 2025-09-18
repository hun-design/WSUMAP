import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../generated/app_localizations.dart';
import 'timetable_item.dart';
import 'timetable_api_service.dart';
import '../map/widgets/directions_screen.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'excel_import_service.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

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
    _loadScheduleItems();
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
    debugPrint('📅 시간표 새로고침 시작 - userId: ${widget.userId}');
    
    if (Platform.isAndroid) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      if (widget.userId.startsWith('guest_')) {
        debugPrint('🚫 게스트 사용자는 시간표를 사용할 수 없습니다: ${widget.userId}');
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
              backgroundColor: const Color(0xFF3B82F6),
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

      final items = await _apiService.fetchScheduleItems(widget.userId);
      debugPrint('📅 서버에서 받은 시간표 개수: ${items.length}');
      
      // 안드로이드에서 UI 업데이트 전 추가 지연 처리
      if (Platform.isAndroid) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
      
      if (mounted) {
        setState(() => _scheduleItems = items);
        debugPrint('📅 시간표 UI 업데이트 완료');
      }
    } catch (e) {
      debugPrint('❌ 시간표 로드 오류: $e');
      
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
            backgroundColor: const Color(0xFFEF4444),
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
    // 🔥 게스트 사용자 체크
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
          backgroundColor: const Color(0xFF3B82F6),
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
      debugPrint('📅 시간표 추가 시작');
      await _apiService.addScheduleItem(item, widget.userId);
      debugPrint('📅 시간표 추가 완료');
      await _loadScheduleItems();
      
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
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ 시간표 추가 실패: $e');
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
            backgroundColor: const Color(0xFFEF4444),
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
    // 🔥 게스트 사용자 체크
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
          backgroundColor: const Color(0xFF3B82F6),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    await _apiService.updateScheduleItem(
      userId: widget.userId,
      originTitle: originItem.title,
      originDayOfWeek: originItem.dayOfWeekText,
      newItem: newItem,
    );
    await _loadScheduleItems();
  }

  Future<void> _deleteScheduleItem(ScheduleItem item) async {
    final l10n = AppLocalizations.of(context);
    // 🔥 게스트 사용자 체크
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
          backgroundColor: const Color(0xFF3B82F6),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    await _apiService.deleteScheduleItem(
      userId: widget.userId,
      title: item.title,
      dayOfWeek: item.dayOfWeekText,
    );
    await _loadScheduleItems();
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
      backgroundColor: const Color(0xFFF8FAFC),
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
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          l10n?.current_year(_getCurrentYear()) ??
                              '${_getCurrentYear()}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getCurrentSemester(),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: const Color(0xFF1E3A8A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
                          color: const Color(0xFF1E3A8A).withOpacity(0.1),
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
                      color: const Color(0xFF1E3A8A).withOpacity(0.1),
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
        color: isCurrentTime ? const Color(0xFF1E3A8A).withOpacity(0.05) : null,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
              child: Row(
          children: [
            Container(
              width: constraints.maxWidth < 400 ? 50 : 60,
              alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCurrentTime
                  ? const Color(0xFF1E3A8A).withOpacity(0.1)
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
                    ? const Color(0xFF1E3A8A)
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

    if (startHour < 9 || startHour > 18) return null;

    // 실제 시간 컬럼 너비와 일치하도록 동적 계산
    final timeColumnWidth = constraints.maxWidth < 400 ? 50.0 : 60.0;
    const containerPadding = 8.0;

    final availableWidth =
        constraints.maxWidth - timeColumnWidth - (containerPadding * 2);
    final dayColumnWidth = availableWidth / 5;

    // 동적 높이에 맞춰 위치 계산
    final startRowIndex = startHour - 9;
    final startPixelOffset = startMinute / 60.0 * rowHeight;
    final top = (startRowIndex * rowHeight) + startPixelOffset;

    final endRowIndex = endHour - 9;
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
            color: const Color(0xFFF8FAFC),
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
                          color: const Color(0xFF1E3A8A),
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
    for (int hour = 9; hour <= 18; hour++) {
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
    for (int hour = 9; hour <= 18; hour++) {
      slots.add('${hour.toString().padLeft(2, '0')}:00');
      if (hour < 18) {
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
                  color: const Color(0xFFF8FAFC),
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
    Color selectedColor = initialItem?.color ?? const Color(0xFF3B82F6);

    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
      const Color(0xFF06B6D4),
      const Color(0xFFEC4899),
      const Color(0xFF84CC16),
    ];

    final List<String> buildingCodes = [
      'W1',
      'W2',
      'W2-1',
      'W3',
      'W4',
      'W5',
      'W6',
      'W7',
      'W8',
      'W9',
      'W10',
      'W11',
      'W12',
      'W13',
      'W14',
      'W15',
      'W16',
      'W17-동관',
      'W17-서관',
      'W18',
      'W19',
    ];

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
                        color: const Color(0xFF1E3A8A).withOpacity(0.1),
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
                              color: const Color(0xFF1E3A8A).withOpacity(0.2),
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
                                debugPrint('🏢 건물 입력 변경: "$value"');
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
                                  debugPrint('🏢 건물 확인됨, 층 정보 가져오기: $value');
                                  final fetchedFloors = await _apiService
                                      .fetchFloors(value);
                                  setState(() {
                                    floorList = fetchedFloors;
                                  });
                                  debugPrint('🏢 층 정보 로드 완료: ${fetchedFloors.length}개');
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
                                debugPrint('🏢 층 입력 변경: "$value"');
                                selectedFloor = value;
                                setState(() {
                                  selectedRoom = null;
                                  roomFieldController.text = '';
                                  roomList = [];
                                });
                                if (floorList.contains(value)) {
                                  debugPrint('🏢 층 확인됨, 강의실 정보 가져오기: $value');
                                  final fetchedRooms = await _apiService
                                      .fetchRooms(selectedBuilding!, value);
                                  setState(() {
                                    roomList = fetchedRooms;
                                  });
                                  debugPrint('🏢 강의실 정보 로드 완료: ${fetchedRooms.length}개');
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
                                debugPrint('🏢 강의실 입력 변경: "$value"');
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
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
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
                                                  ? const Color(0xFF1E3A8A)
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
                        color: const Color(0xFFF8FAFC),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          // 🔥 반응형 버튼 레이아웃
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
                                                        const Color(0xFFEF4444),
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
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          prefixIcon: Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
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
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
              color: const Color(0xFF1E3A8A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
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
            color: const Color(0xFF1E3A8A).withOpacity(0.1),
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
            color: const Color(0xFF1E3A8A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
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
                color: const Color(0xFF1E3A8A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
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
    debugPrint('🏢 시간표에서 위치 보기 버튼 클릭됨');
    debugPrint('🏢 건물 이름: ${item.buildingName}');
    debugPrint('🏢 층수: ${item.floorNumber}');
    debugPrint('🏢 호실: ${item.roomName}');
    debugPrint('🏢 전체 아이템 정보: $item');

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

    debugPrint('🏢 네비게이션 완료');
  }

  // 🔥 액션 버튼 빌더 메서드
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isIconOnly = false,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: isIconOnly
            ? Icon(icon, size: 20)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showScheduleDetail(ScheduleItem item) {
  final l10n = AppLocalizations.of(context)!;

  showDialog(
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
            Padding(
              padding: const EdgeInsets.all(24),
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
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
                          backgroundColor: const Color(0xFF1E3A8A),
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
                          debugPrint('🔘 위치 보기 버튼 클릭됨!');
                          Navigator.pop(context);
                          _showBuildingLocation(item);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
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
                          backgroundColor: const Color(0xFF64748B),
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

                      Widget deleteButton = ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _showDeleteConfirmDialog(item);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          padding: EdgeInsets.zero, // 패딩 제거로 정확한 중앙 정렬
                        ),
                        child: const Center( // Center로 감싸서 정확한 중앙 정렬
                          child: Icon(Icons.delete, size: 18),
                        ),
                      );

                      if (isSmallScreen) {
                        // 작은 화면에서는 더 작은 화면인지 추가 확인
                        final isVerySmallScreen = constraints.maxWidth < 300;
                        
                        if (isVerySmallScreen) {
                          // 매우 작은 화면: 아이콘만 표시
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _showRecommendRoute(item);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF1E3A8A),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          elevation: 2,
                                        ),
                                        child: const Icon(Icons.directions, size: 18),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          debugPrint('🔘 위치 보기 버튼 클릭됨!');
                                          Navigator.pop(context);
                                          _showBuildingLocation(item);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF3B82F6),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          elevation: 2,
                                        ),
                                        child: const Icon(Icons.location_on, size: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _showEditScheduleDialog(item);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF64748B),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          elevation: 2,
                                        ),
                                        child: const Icon(Icons.edit, size: 18),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(width: 48, height: 48, child: deleteButton),
                                ],
                              ),
                            ],
                          );
                        } else {
                          // 작은 화면: 아이콘 + 텍스트 (오버플로우 방지)
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: SizedBox(height: 48, child: recommendRouteButton)),
                                  const SizedBox(width: 8),
                                  Expanded(child: SizedBox(height: 48, child: viewLocationButton)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(child: SizedBox(height: 48, child: editButton)),
                                  const SizedBox(width: 8),
                                  SizedBox(width: 48, height: 48, child: deleteButton),
                                ],
                              ),
                            ],
                          );
                        }
                      } else {
                        return Row(
                          children: [
                            Expanded(child: SizedBox(height: 48, child: recommendRouteButton)),
                            const SizedBox(width: 8),
                            Expanded(child: SizedBox(height: 48, child: viewLocationButton)),
                            const SizedBox(width: 8),
                            Expanded(child: SizedBox(height: 48, child: editButton)),
                            const SizedBox(width: 8),
                            SizedBox(width: 48, height: 48, child: deleteButton),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        l10n.close,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
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
                                debugPrint('뒤로가기 버튼 클릭');
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
                                        ? const Color(0xFF1E3A8A) 
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
                                  backgroundColor: const Color(0xFF1E3A8A),
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
              backgroundColor: const Color(0xFF1E3A8A),
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
              foregroundColor: const Color(0xFF1E3A8A),
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
  
  Widget _buildTutorialContent() {
    debugPrint('=== 튜토리얼 콘텐츠 빌드 시작 ===');
    debugPrint('현재 페이지: $_tutorialPage');
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.red.shade100, // 빨간색 배경으로 테스트
      child: Column(
        children: [
          // 헤더
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade100, // 파란색 배경으로 테스트
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    debugPrint('뒤로가기 버튼 클릭');
                    setState(() => _showTutorial = false);
                  },
                  icon: const Icon(Icons.arrow_back, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.excel_tutorial_title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          
          // 테스트 콘텐츠
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.green.shade100, // 초록색 배경으로 테스트
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      color: Colors.yellow.shade400,
                      child: const Center(
                        child: Text(
                          '테스트\n박스',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '튜토리얼 테스트',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '현재 페이지: $_tutorialPage',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        debugPrint('파일 선택 버튼 클릭');
                        _uploadExcelFile();
                      },
                      child: Text(AppLocalizations.of(context)!.excel_tutorial_file_select),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  List<Widget> _getTutorialPages() {
    return [
      // 페이지 0: 안내 텍스트
      _buildTextPage(),
      
      // 페이지 1-5: 이미지들 (테스트용)
      _buildTestImagePage('assets/timetable/tutorial/1.png'),
      _buildTestImagePage('assets/timetable/tutorial/2.png'),
      _buildTestImagePage('assets/timetable/tutorial/3.png'),
      _buildTestImagePage('assets/timetable/tutorial/4.png'),
      _buildTestImagePage('assets/timetable/tutorial/5.png'),
    ];
  }
  
  Widget _buildTestImagePage(String assetPath) {
    debugPrint('=== 이미지 테스트 시작: $assetPath ===');
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '테스트: $assetPath',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('❌ 이미지 로드 실패: $assetPath');
                  debugPrint('❌ 에러: $error');
                  return Container(
                    color: Colors.red.shade100,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 48, color: Colors.red.shade400),
                          const SizedBox(height: 8),
                          Text(
                            '이미지 로드 실패',
                            style: TextStyle(color: Colors.red.shade600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            assetPath,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Error: $error',
                            style: TextStyle(fontSize: 10, color: Colors.red.shade400),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
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
              color: const Color(0xFF1E3A8A),
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
    debugPrint('튜토리얼 페이지 빌드: $page');
    
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
    debugPrint('간단한 이미지 페이지: $assetPath');
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
          errorBuilder: (context, error, stackTrace) {
            debugPrint('이미지 로드 실패: $assetPath - $error');
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
  
  Widget _buildErrorWidget(String assetPath, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
                            Text(
                    AppLocalizations.of(context)!.excel_tutorial_image_load_error,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
          const SizedBox(height: 4),
          Text(
            assetPath,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Error: $error',
            style: TextStyle(
              color: Colors.red.shade400,
              fontSize: 10,
            ),
          ),
        ],
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
      debugPrint('🔓 업로드 중 화면 잠금 해제 활성화');
    } catch (e) {
      debugPrint('⚠️ Wakelock 활성화 실패: $e');
    }
    
    try {
      final success = await ExcelImportService.uploadExcelToServer(widget.userId);
      
      if (mounted) {
        if (success) {
          debugPrint('📤 엑셀 업로드 성공 후 리프레시 콜백 호출');
          
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
            
            // 새로고침 실행
            try {
              await widget.refreshCallback();
              debugPrint('✅ 시간표 새로고침 완료');
              
              // 성공 메시지 표시
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        Text(AppLocalizations.of(context)!.excel_upload_success_message),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } catch (error) {
              debugPrint('❌ 시간표 새로고침 실패: $error');
              
              // 새로고침 실패 시에도 성공 메시지 표시 (업로드는 성공했으므로)
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        Text(AppLocalizations.of(context)!.excel_upload_success_message),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          }
          
          // 작업 완료 후 wakelock 해제
          if (wakelockEnabled) {
            try {
              await WakelockPlus.disable();
              debugPrint('🔒 업로드 완료 후 화면 잠금 해제 비활성화');
            } catch (e) {
              debugPrint('⚠️ Wakelock 비활성화 실패: $e');
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
              debugPrint('🔒 파일 선택 취소 후 화면 잠금 해제 비활성화');
            } catch (e) {
              debugPrint('⚠️ Wakelock 비활성화 실패: $e');
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
            debugPrint('🔒 업로드 에러 후 화면 잠금 해제 비활성화');
          } catch (e) {
            debugPrint('⚠️ Wakelock 비활성화 실패: $e');
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
        debugPrint('🔧 안드로이드 시스템 UI 재설정 완료');
      } catch (e) {
        debugPrint('⚠️ 안드로이드 시스템 UI 재설정 실패: $e');
      }
    }
  }
}
