// timetable_screen.dart
//

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../generated/app_localizations.dart';
import 'timetable_item.dart';
import 'timetable_api_service.dart';
import '../map/widgets/directions_screen.dart'; // 폴더 구조에 맞게 경로 수정!

class ScheduleScreen extends StatefulWidget {
  final String userId;
  const ScheduleScreen({required this.userId, super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late String _currentSemester;
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
      _currentSemester = _getCurrentSemester();
    }
  }

  String _getCurrentSemester() {
    final now = DateTime.now();
    final month = now.month;
    final l10n = AppLocalizations.of(context);

    if (month >= 12 || month <= 2) {
      return l10n?.winter_semester ?? 'Winter';
    } else if (month >= 3 && month <= 5) {
      return l10n?.spring_semester ?? 'Spring';
    } else if (month >= 6 && month <= 8) {
      return l10n?.summer_semester ?? 'Summer';
    } else {
      return l10n?.fall_semester ?? 'Fall';
    }
  }

  int _getCurrentYear() => DateTime.now().year;

  Future<void> _loadScheduleItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await _apiService.fetchScheduleItems(widget.userId);
      if (mounted) setState(() => _scheduleItems = items);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '시간표를 불러오지 못했습니다.',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addScheduleItem(ScheduleItem item) async {
    await _apiService.addScheduleItem(item, widget.userId);
    await _loadScheduleItems();
  }

  Future<void> _updateScheduleItem(
    ScheduleItem originItem,
    ScheduleItem newItem,
  ) async {
    await _apiService.updateScheduleItem(
      userId: widget.userId,
      originTitle: originItem.title,
      originDayOfWeek: originItem.dayOfWeekText,
      newItem: newItem,
    );
    await _loadScheduleItems();
  }

  Future<void> _deleteScheduleItem(ScheduleItem item) async {
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
          item.id!.trim() == ignoreId.trim())
        continue;
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
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.timetable ?? 'Timetable',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      l10n?.current_year(_getCurrentYear()) ??
                          '${_getCurrentYear()}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _currentSemester,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showAddScheduleDialog,
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF1E3A8A),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

Widget _buildScheduleView() {
  return Container(
    width: double.infinity,
    height: double.infinity,
    margin: EdgeInsets.zero,
    padding: EdgeInsets.zero,
    decoration: BoxDecoration(
      color: const Color(0xFFFAFAFA),
      borderRadius: BorderRadius.zero,
      border: Border.all(color: Colors.grey.shade200, width: 1),
    ),
    child: Column(
      children: [
        _buildDayHeaders(), // 45px 고정 높이
        Expanded(
          child: _buildTimeTable(), // 나머지 공간
        ),
      ],
    ),
  );
}

  Widget _buildDayHeaders() {
    final l10n = AppLocalizations.of(context);
    final days = [
      l10n?.monday ?? 'Mon',
      l10n?.tuesday ?? 'Tue',
      l10n?.wednesday ?? 'Wed',
      l10n?.thursday ?? 'Thu',
      l10n?.friday ?? 'Fri',
    ];

    return Container(
      height: 45,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E3A8A).withOpacity(0.1),
            const Color(0xFF3B82F6).withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E3A8A).withOpacity(0.15),
                  const Color(0xFF3B82F6).withOpacity(0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                right: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Center(
              child: Text(
                l10n?.time ?? 'Time',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ),
          ),
          ...days.asMap().entries.map((entry) {
            int index = entry.key;
            String day = entry.value;
            return Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: index < days.length - 1
                        ? BorderSide(color: Colors.grey.shade200, width: 0.5)
                        : BorderSide.none,
                  ),
                ),
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

Widget _buildTimeTable() {
  final int slotCount = 10;
  final timeSlots = List.generate(slotCount, (i) => '${(9 + i).toString().padLeft(2, '0')}:00');

  return LayoutBuilder(
    builder: (context, constraints) {
      final tableHeight = constraints.maxHeight;
      final rowHeight = tableHeight / slotCount;

      // 딱 맞는 정수 픽셀을 위해
      final fixedTableHeight = rowHeight * slotCount;

      return SizedBox(
        height: fixedTableHeight,
        child: Stack(
          children: [
            Column(
              children: List.generate(
                slotCount,
                (idx) => _buildTimeRow(timeSlots[idx], idx, rowHeight),
              ),
            ),
            ..._buildUltraSafeBlocks(fixedTableHeight, constraints.maxWidth),
          ],
        ),
      );
    },
  );
}

List<Widget> _buildUltraSafeBlocks(double tableHeight, double screenWidth) {
  const int startMinute = 9 * 60;
  const int endMinute = 18 * 60;
  const int totalMinutes = endMinute - startMinute;

  List<Widget> blocks = [];
  for (final item in _scheduleItems) {
    final int start = _parseTime(item.startTime);
    final int end = _parseTime(item.endTime);
    if (start < startMinute || end > endMinute || end <= start) continue;

    double minuteToY(int minute) =>
      ((minute - startMinute) / totalMinutes) * tableHeight;
    final double top = minuteToY(start);
    final double height = minuteToY(end) - minuteToY(start);

    final double availableWidth = screenWidth - 55;
    final double columnWidth = availableWidth / 5;
    final double left = 55 + (item.dayOfWeek - 1) * columnWidth + 8;
    final double width = columnWidth - 16;

    blocks.add(
      Positioned(
        left: left,
        top: top,
        width: width,
        height: height,
        child: _buildScheduleBlock(item),
      ),
    );
  }
  return blocks;
}

Widget _buildTimeRow(String timeSlot, int index, double rowHeight) {
  bool isEvenRow = index % 2 == 0;
  return Container(
    height: rowHeight,
    // ⛔ constraints: BoxConstraints(...) 삭제!
    child: Row(
      children: [
        Container(
          width: 55,
          height: rowHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E3A8A).withOpacity(0.08),
                const Color(0xFF3B82F6).withOpacity(0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              right: BorderSide(color: Colors.grey.shade200, width: 1),
              bottom: index < 9
                  ? BorderSide(color: Colors.grey.shade200, width: 1)
                  : BorderSide.none,
            ),
          ),
          child: Center(
            child: Text(
              timeSlot,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
          ),
        ),
        ...List.generate(5, (dayIndex) {
          return Expanded(
            child: Container(
              height: rowHeight,
              decoration: BoxDecoration(
                color: isEvenRow
                    ? const Color(0xFFFDFDFD)
                    : const Color(0xFFF8F9FA),
                border: Border(
                  right: dayIndex < 4
                      ? BorderSide(color: Colors.grey.shade200, width: 0.5)
                      : BorderSide.none,
                  bottom: index < 9
                      ? BorderSide(color: Colors.grey.shade200, width: 1)
                      : BorderSide.none,
                ),
              ),
            ),
          );
        }),
      ],
    ),
  );
}

Widget _buildScheduleBlock(ScheduleItem item) {
  return GestureDetector(
    onTap: () => _showScheduleDetail(item),
    child: Container(
      margin: const EdgeInsets.all(1),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            item.color.withOpacity(0.15),
            item.color.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.color.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isSmall = constraints.maxHeight < 50;
          final bool isVerySmall = constraints.maxHeight < 35;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: TextStyle(
                  fontSize: isVerySmall ? 10 : 12,
                  fontWeight: FontWeight.w700,
                  color: item.color,
                  height: 1.2,
                ),
                maxLines: isVerySmall ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isVerySmall && item.professor.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  item.professor,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: item.color.withOpacity(0.85),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (!isSmall) ...[
                const SizedBox(height: 3),
                Text(
                  '${item.buildingName} ${item.floorNumber}-${item.roomName}',
                  style: TextStyle(
                    fontSize: 9,
                    color: item.color.withOpacity(0.75),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Spacer(),
              if (!isVerySmall)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_formatTimeDisplay(item.startTime)} - ${_formatTimeDisplay(item.endTime)}',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: item.color,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    ),
  );
}

List<String> _generateTimeSlots() {
  final slots = <String>[];
  for (int hour = 9; hour <= 18; hour++) {
    slots.add('${hour.toString().padLeft(2, '0')}:00');
  }
  return slots;
}

// 🔥 2. 드롭다운용 시간 슬롯 생성 (30분 단위)
List<String> _generateTimeOptions() {
  final options = <String>[];
  for (int hour = 9; hour <= 18; hour++) {
    options.add('${hour.toString().padLeft(2, '0')}:00');
    if (hour < 18) options.add('${hour.toString().padLeft(2, '0')}:30');
  }
  return options;
}

int _parseTime(String time) {
  try {
    final cleanTime = time.trim();
    // 예: "12:30:00" → [12, 30, 00], "12:30" → [12, 30]
    List<String> parts = cleanTime.split(':');
    if (parts.length >= 2) {
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);
      return hours * 60 + minutes;
    }
    // "0900", "1230" 등
    if (RegExp(r'^\d{4}$').hasMatch(cleanTime)) {
      return int.parse(cleanTime.substring(0, 2)) * 60
           + int.parse(cleanTime.substring(2, 4));
    }
    // "9", "12" 등
    if (RegExp(r'^\d{1,2}$').hasMatch(cleanTime)) {
      return int.parse(cleanTime) * 60;
    }
  } catch (e) {
    print('⚠️ Time parsing error: "$time"');
  }
  return 540; // fallback: 9:00
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

  String _formatTimeDisplay(String time) {
  try {
    String cleanTime = time.trim();
    
    if (cleanTime.contains(':')) {
      List<String> parts = cleanTime.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0].trim());
        int minute = int.parse(parts[1].trim());
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }
    }
    
    if (RegExp(r'^\d{4}$').hasMatch(cleanTime)) {
      String hour = cleanTime.substring(0, 2);
      String minute = cleanTime.substring(2, 4);
      return '$hour:$minute';
    }
    
    if (RegExp(r'^\d{1,2}$').hasMatch(cleanTime)) {
      int hour = int.parse(cleanTime);
      return '${hour.toString().padLeft(2, '0')}:00';
    }
    
  } catch (e) {
    print('⚠️ Format error: "$time"');
  }
  
  return time;
}

  Future<void> _showDeleteConfirmDialog(ScheduleItem item) async {
  final l10n = AppLocalizations.of(context);

  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔥 헤더 - 경고 스타일
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
                          '시간표 삭제',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '신중하게 결정해주세요',
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

            // 🔥 내용
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
                            const Text(
                              '삭제할 시간표',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '"${item.title}" 수업을 시간표에서 삭제하시겠습니까?\n삭제된 시간표는 복구할 수 없습니다.',
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

            // 🔥 버튼 영역
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
                    child: Container(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
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
                        child: const Text(
                          '삭제',
                          style: TextStyle(
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
  /// ===== 핵심! 입력 다이얼로그(수정/추가) 부분만 아래처럼 수정! =====

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

    // 🔥 컨트롤러를 미리 생성하고 초기값 설정
    final buildingFieldController = TextEditingController(
      text: initialItem?.buildingName ?? '',
    );
    final floorFieldController = TextEditingController(
      text: initialItem?.floorNumber ?? '',
    );
    final roomFieldController = TextEditingController(
      text: initialItem?.roomName ?? '',
    );

    // 선택된 값들 초기화
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

    // 🔥 초기 데이터 로드 (수정 모드일 때)
    if (initialItem != null) {
      try {
        floorList = await _apiService.fetchFloors(initialItem.buildingName);
        roomList = await _apiService.fetchRooms(
          initialItem.buildingName,
          initialItem.floorNumber,
        );
      } catch (e) {
        // 에러 처리
        print('Error loading initial data: $e');
      }
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
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 헤더 영역
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

                    // 컨텐츠 영역
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // 수업명 입력
                            _buildStyledInputField(
                              controller: titleController,
                              labelText: l10n?.class_name ?? 'Class Name',
                              icon: Icons.book,
                              autofocus: true,
                            ),
                            const SizedBox(height: 16),

                            // 교수명 입력
                            _buildStyledInputField(
                              controller: professorController,
                              labelText: l10n?.professor_name ?? 'Professor',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),

                            // 🔥 건물명 자동완성 (수정됨)
                            _buildStyledTypeAheadField(
                              controller: buildingFieldController,
                              labelText: l10n?.building_name ?? 'Building',
                              icon: Icons.business,
                              suggestionsCallback: (pattern) async {
                                // 🔥 빈 문자열이거나 공백만 있을 때 전체 리스트 반환
                                if (pattern.trim().isEmpty) {
                                  return buildingCodes;
                                }
                                // 🔥 패턴과 일치하는 항목들 필터링
                                return buildingCodes
                                    .where((code) => 
                                        code.toLowerCase().contains(pattern.toLowerCase()))
                                    .toList();
                              },
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
                                // 🔥 정확한 빌딩 코드일 때만 층 정보 로드
                                if (buildingCodes.contains(value)) {
                                  try {
                                    final fetchedFloors = await _apiService.fetchFloors(value);
                                    setState(() {
                                      floorList = fetchedFloors;
                                    });
                                  } catch (e) {
                                    print('Error fetching floors: $e');
                                  }
                                }
                              },
                              onSelected: (suggestion) async {
                                selectedBuilding = suggestion;
                                setState(() {
                                  selectedFloor = null;
                                  selectedRoom = null;
                                  floorFieldController.text = '';
                                  roomFieldController.text = '';
                                  floorList = [];
                                  roomList = [];
                                });
                                try {
                                  final fetchedFloors = await _apiService.fetchFloors(suggestion);
                                  setState(() {
                                    floorList = fetchedFloors;
                                  });
                                } catch (e) {
                                  print('Error fetching floors: $e');
                                }
                              },
                            ),
                            const SizedBox(height: 16),

                            // 🔥 층 자동완성 (수정됨)
                            _buildStyledTypeAheadField(
                              key: ValueKey('floor_${selectedBuilding ?? ""}'),
                              controller: floorFieldController,
                              labelText: l10n?.floor_number ?? 'Floor',
                              icon: Icons.layers,
                              enabled: selectedBuilding != null,
                              suggestionsCallback: (pattern) async {
                                if (pattern.trim().isEmpty) return floorList;
                                return floorList
                                    .where(
                                      (floor) => floor.toLowerCase().contains(
                                        pattern.toLowerCase(),
                                      ),
                                    )
                                    .toList();
                              },
                              onChanged: (value) async {
                                selectedFloor = value;
                                selectedRoom = null;
                                roomFieldController.text = '';
                                setState(() => roomList = []);
                                if (floorList.contains(value)) {
                                  final fetchedRooms = await _apiService
                                      .fetchRooms(selectedBuilding!, value);
                                  setState(() {
                                    roomList = fetchedRooms;
                                  });
                                }
                              },
                              onSelected: (suggestion) async {
                                selectedFloor = suggestion;
                                floorFieldController.text = suggestion;
                                selectedRoom = null;
                                roomFieldController.text = '';
                                final fetchedRooms = await _apiService
                                    .fetchRooms(selectedBuilding!, suggestion);
                                setState(() {
                                  roomList = fetchedRooms;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            // 🔥 강의실 자동완성 (수정됨)
                            _buildStyledTypeAheadField(
                              key: ValueKey(
                                'room_${selectedBuilding ?? ""}_${selectedFloor ?? ""}',
                              ),
                              controller: roomFieldController,
                              labelText: l10n?.room_name ?? 'Room',
                              icon: Icons.meeting_room,
                              enabled: selectedFloor != null,
                              suggestionsCallback: (pattern) async {
                                if (pattern.trim().isEmpty) return roomList;
                                return roomList
                                    .where(
                                      (room) => room.toLowerCase().contains(
                                        pattern.toLowerCase(),
                                      ),
                                    )
                                    .toList();
                              },
                              onChanged: (value) => selectedRoom = value,
                              onSelected: (suggestion) {
                                selectedRoom = suggestion;
                                roomFieldController.text = suggestion;
                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 16),

                            // 요일 선택
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

                            // 시간 선택 (가로 배치)
                              // 🔥 기존 시간 선택 Row를 이것으로 교체하세요!

// 시간 선택 (가로 배치) - 30분 단위
Row(
  children: [
    Expanded(
      child: _buildStyledDropdownField<String>(
        value: startTime,
        labelText: 'Start Time',
        icon: Icons.access_time,
        items: _generateTimeOptions()
          .where((time) => _parseTime(time) < 18 * 60)
          .map((time) => DropdownMenuItem(value: time, child: Text(time))).toList(),
        onChanged: (value) {
          setState(() {
            startTime = value!;
            final slotList = _generateTimeOptions();
            int idx = slotList.indexOf(startTime);
            if (_parseTime(endTime) <= _parseTime(startTime)) {
              endTime = slotList[(idx+1).clamp(0, slotList.length-1)];
            }
          });
        },
      ),
    ),
    SizedBox(width: 12),
    Expanded(
      child: _buildStyledDropdownField<String>(
        value: endTime,
        labelText: 'End Time',
        icon: Icons.access_time_filled,
        items: _generateTimeOptions()
          .where((time) => _parseTime(time) > _parseTime(startTime) && _parseTime(time) <= 18*60)
          .map((time) => DropdownMenuItem(value: time, child: Text(time))).toList(),
        onChanged: (value) => setState(() => endTime = value!),
      ),
    ),
  ],
),

                            const SizedBox(height: 24),

                            // 색상 선택
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

                            // 메모 입력
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

                    // 버튼 영역
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
                            child: Container(
                              height: 48,
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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
                            child: Container(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (titleController.text.isNotEmpty &&
                                      selectedBuilding?.isNotEmpty == true &&
                                      selectedFloor?.isNotEmpty == true &&
                                      selectedRoom?.isNotEmpty == true) {
                                    final newItem = ScheduleItem(
                                      id: initialItem?.id,
                                      title: titleController.text,
                                      professor: professorController.text,
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
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
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
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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

Widget _buildStyledTypeAheadField({
    Key? key,
    TextEditingController? controller,
    required String labelText,
    required IconData icon,
    bool enabled = true,
    required Future<List<String>> Function(String) suggestionsCallback,
    Function(String)? onChanged,
    Function(String)? onSelected,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled
              ? const Color(0xFFE2E8F0)
              : const Color(0xFFE2E8F0).withOpacity(0.5),
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: TypeAheadField<String>(
        key: key,
        controller: controller,
        suggestionsCallback: (pattern) async {
          print('Searching for pattern: "$pattern"');
          final results = await suggestionsCallback(pattern);
          print('Found ${results.length} results: $results');
          return results;
        },
        itemBuilder: (context, suggestion) => ListTile(
          dense: true,
          title: Text(
            suggestion,
            style: const TextStyle(
              fontSize: 16, 
              color: Color(0xFF1E3A8A),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        builder: (context, textController, focusNode) {
          return TextFormField(
            controller: textController,
            focusNode: focusNode,
            enabled: enabled,
            style: TextStyle(
              fontSize: 16,
              color: enabled
                  ? const Color(0xFF1E3A8A)
                  : const Color(0xFF64748B),
            ),
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: TextStyle(
                color: enabled
                    ? const Color(0xFF64748B)
                    : const Color(0xFF64748B).withOpacity(0.5),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                icon,
                color: enabled
                    ? const Color(0xFF1E3A8A)
                    : const Color(0xFF64748B).withOpacity(0.5),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
            onChanged: onChanged,
          );
        },
        onSelected: (suggestion) {
          // 🔥 선택 시 처리 - 컨트롤러에 전체 텍스트 명시적으로 설정
          print('TypeAhead onSelected called with: "$suggestion"');
          if (controller != null) {
            controller.text = suggestion; // 전체 텍스트 강제 설정
            // 🔥 추가: 다음 프레임에서 다시 한번 설정 (혹시 덮어써지는 경우 대비)
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (controller.text != suggestion) {
                controller.text = suggestion;
              }
            });
          }
          if (onSelected != null) {
            onSelected(suggestion);
          }
        },
        // suggestions 박스 스타일링
        decorationBuilder: (context, child) => Material(
          type: MaterialType.card,
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: child,
          ),
        ),
        // suggestions가 없을 때 표시할 위젯
        emptyBuilder: (context) => Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            '검색 결과가 없습니다',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // 로딩 중일 때 표시할 위젯
        loadingBuilder: (context) => Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF1E3A8A),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '검색 중...',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        // 🔥 드롭다운 자동 닫기 설정
        hideOnEmpty: true,
        hideOnError: true,
        debounceDuration: const Duration(milliseconds: 300),
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
        prefixIcon: Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
      dropdownColor: Colors.white, 
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1E3A8A)),
      // 🔥 드롭다운 메뉴 높이 제한
      menuMaxHeight: 200,
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

  // ----------- 이하 기존과 동일 ---------------------

  void _showAddScheduleDialog() {
    _showScheduleFormDialog(
      onSubmit: (item) async => await _addScheduleItem(item),
    );
  }

  void _showEditScheduleDialog(ScheduleItem item) {
    _showScheduleFormDialog(
      initialItem: item,
      onSubmit: (newItem) async => await _updateScheduleItem(item, newItem),
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

  void _showScheduleDetail(ScheduleItem item) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔥 헤더
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

              // 🔥 내용
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildStyledDetailRow(
                      Icons.person,
                      l10n?.professor_name ?? 'Professor',
                      item.professor,
                    ),
                    const SizedBox(height: 16),
                    _buildStyledDetailRow(
                      Icons.business,
                      l10n?.building_name ?? 'Building',
                      item.buildingName,
                    ),
                    const SizedBox(height: 16),
                    _buildStyledDetailRow(
                      Icons.layers,
                      l10n?.floor_number ?? 'Floor',
                      item.floorNumber,
                    ),
                    const SizedBox(height: 16),
                    _buildStyledDetailRow(
                      Icons.meeting_room,
                      l10n?.room_name ?? 'Room',
                      item.roomName,
                    ),
                    const SizedBox(height: 16),
                    _buildStyledDetailRow(
                      Icons.calendar_today,
                      l10n?.day_of_week ?? 'Day',
                      _getDayName(item.dayOfWeek),
                    ),
                    const SizedBox(height: 16),
                    _buildStyledDetailRow(
                      Icons.access_time,
                      l10n?.time ?? 'Time',
                      '${item.startTime} - ${item.endTime}',
                    ),
                    if (item.memo.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildStyledDetailRow(
                        Icons.note_alt_outlined,
                        l10n?.memo ?? 'Memo',
                        item.memo,
                      ),
                    ],
                  ],
                ),
              ),

              // 🔥 버튼 영역
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
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showRecommendRoute(item);
                              },
                              icon: const Icon(Icons.directions, size: 18),
                              label: const Text('추천경로'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showEditScheduleDialog(item);
                              },
                              icon: const Icon(Icons.edit, size: 18),
                              label: Text(l10n?.edit ?? 'Edit'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 44,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _showDeleteConfirmDialog(item);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Icon(Icons.delete, size: 18),
                          ),
                        ),
                      ],
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
                        child: const Text(
                          '닫기',
                          style: TextStyle(
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

  void _debugScheduleItem(ScheduleItem item) {
  print('🔍 === Schedule Item Debug ===');
  print('🔍 Title: ${item.title}');
  print('🔍 StartTime: "${item.startTime}" (type: ${item.startTime.runtimeType})');
  print('🔍 EndTime: "${item.endTime}" (type: ${item.endTime.runtimeType})');
  print('🔍 DayOfWeek: ${item.dayOfWeek}');
  print('🔍 Building: ${item.buildingName}');
  print('🔍 Floor: ${item.floorNumber}');
  print('🔍 Room: ${item.roomName}');
  print('🔍 === End Debug ===');
}
}
