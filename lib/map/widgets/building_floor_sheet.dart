import 'package:flutter/material.dart';
import 'package:flutter_application_1/inside/building_map_page.dart';
import 'package:flutter_application_1/utils/CategoryLocalization.dart';
import 'package:flutter_application_1/map/widgets/building_info_sheet.dart';
import 'package:flutter_application_1/map/widgets/directions_screen.dart';
import 'package:flutter_application_1/models/building.dart';
import 'package:flutter_application_1/generated/app_localizations.dart';

class BuildingFloorSheet extends StatefulWidget {
  final String buildingName;
  final List<String> floors;
  final String? category; // 카테고리 정보 추가
  final List<String>? categoryFloors; // 🔥 카테고리가 존재하는 층 정보 추가

  const BuildingFloorSheet({
    Key? key,
    required this.buildingName,
    required this.floors,
    this.category, // 카테고리 파라미터 추가
    this.categoryFloors, // 🔥 카테고리 층 정보 파라미터 추가
  }) : super(key: key);

  @override
  State<BuildingFloorSheet> createState() => _BuildingFloorSheetState();
}

class _BuildingFloorSheetState extends State<BuildingFloorSheet> {
  final ScrollController _scrollController = ScrollController();
  bool _isExpanded = false;
  double _lastScrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    // 바텀시트가 열린 후 고정된 위치로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isExpanded = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏢 BuildingFloorSheet - 건물: ${widget.buildingName}, 카테고리: ${widget.category}, 층: ${widget.floors}, 카테고리층: ${widget.categoryFloors}');
    
    // 🔥 카테고리가 선택된 경우 해당 카테고리가 존재하는 층만 필터링
    final displayFloors = widget.category != null && widget.categoryFloors != null && widget.categoryFloors!.isNotEmpty
        ? widget.categoryFloors!
        : widget.floors;
    
    return DraggableScrollableSheet(
      initialChildSize: 0.6, // 높이를 0.4에서 0.6으로 증가
      minChildSize: 0.5, // 최소 높이를 0.25에서 0.5로 증가
      maxChildSize: 0.85, // 최대 높이를 0.75에서 0.85로 증가
      snap: true, // 스냅 기능 추가
      snapSizes: const [0.5, 0.6, 0.85], // 스냅 위치 정의
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 드래그 핸들
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // 🔥 헤더 섹션 (고정)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    // 🔥 카테고리 아이콘
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(widget.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.category,
                        color: _getCategoryColor(widget.category),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // 🔥 건물명과 카테고리 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.buildingName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (widget.category != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              CategoryLocalization.getLabel(context, widget.category!),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // 🔥 닫기 버튼
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1, thickness: 0.5),
              
              // 🔥 액션 버튼들 (고정)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    // 🔥 첫 번째 행: 건물 정보, 도면
                    Row(
                      children: [
                        // 🔥 건물 정보 보기 버튼
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                // 건물 정보 바텀시트 표시
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => BuildingInfoSheet(
                                    buildingName: widget.buildingName,
                                    category: widget.category,
                                    floors: widget.floors,
                                    categoryFloors: widget.categoryFloors, // 🔥 카테고리 층 정보 전달
                                  ),
                                );
                              },
                              icon: const Icon(Icons.info_outline, size: 18),
                              label: Text(AppLocalizations.of(context)!.building_info),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1E3A8A),
                                side: const BorderSide(color: Color(0xFF1E3A8A)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // 🔥 도면 버튼
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                // 도면 버튼 클릭 시 해당 건물 아이콘을 지도에 표시
                                _showBuildingOnMap(context);
                              },
                              icon: const Icon(Icons.map, size: 18),
                              label: Text(AppLocalizations.of(context)!.floor_plan),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 🔥 두 번째 행: 길찾기 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // 길찾기 화면으로 이동 (도착지에 건물 설정)
                          final building = Building(
                            name: widget.buildingName,
                            info: '',
                            lat: 0.0,
                            lng: 0.0,
                            category: widget.category ?? '',
                            baseStatus: '',
                            hours: '',
                            phone: '',
                            imageUrl: '',
                            description: '',
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DirectionsScreen(
                                presetEnd: building,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.directions, size: 18),
                        label: Text(AppLocalizations.of(context)!.directions),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 🔥 층 정보 섹션 (고정)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.layers,
                      color: const Color(0xFF1E3A8A),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.category != null && widget.categoryFloors != null && widget.categoryFloors!.isNotEmpty
                            ? '${CategoryLocalization.getLabel(context, widget.category!)}이(가) 있는 층'
                            : AppLocalizations.of(context)!.floor_detail_view,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 🔥 층 목록 (스크롤 가능)
              if (displayFloors.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.grey.shade500,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppLocalizations.of(context)!.no_floor_info,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController, // 별도의 스크롤 컨트롤러 사용
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: displayFloors.length,
                    physics: const BouncingScrollPhysics(), // 부드러운 스크롤 효과
                    itemBuilder: (context, idx) {
                      final floor = displayFloors[idx];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              debugPrint('🏢 층 선택: ${widget.buildingName} ${floor}층 (카테고리: ${widget.category})');
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BuildingMapPage(
                                    buildingName: widget.buildingName,
                                    targetFloorNumber: int.tryParse(floor),
                                    initialCategory: widget.category, // 🔥 카테고리 정보 전달
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E3A8A).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.layers,
                                      color: const Color(0xFF1E3A8A),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${floor}층',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          AppLocalizations.of(context)!.floor_detail_info,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey.shade400,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  /// 🔥 도면 버튼 클릭 시 해당 건물을 지도에 표시
  void _showBuildingOnMap(BuildContext context) {
    debugPrint('🗺️ 도면 버튼 클릭: ${widget.buildingName}');
    
    // 지도 화면으로 돌아가서 해당 건물을 선택하도록 네비게이션
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/map',
      (route) => false, // 모든 이전 화면 제거
      arguments: {
        'showBuilding': widget.buildingName,
        'buildingInfo': {
          'name': widget.buildingName,
          'category': widget.category,
          'floors': widget.floors,
        }
      },
    );
  }
  
  /// 🔥 카테고리 색상 가져오기
  Color _getCategoryColor(String? category) {
    if (category == null) return const Color(0xFF1E3A8A);
    
    // 카테고리별 색상 매핑
    switch (category) {
      case 'cafe':
        return const Color(0xFF8B5CF6); // 보라색
      case 'restaurant':
        return const Color(0xFFEF4444); // 빨간색
      case 'convenience':
        return const Color(0xFF10B981); // 초록색
      case 'vending':
        return const Color(0xFFF59E0B); // 주황색
      case 'atm':
      case 'bank':
        return const Color(0xFF059669); // 진한 초록색
      case 'library':
        return const Color(0xFF3B82F6); // 파란색
      case 'fitness':
      case 'gym':
        return const Color(0xFFDC2626); // 진한 빨간색
      case 'lounge':
        return const Color(0xFF7C3AED); // 보라색
      case 'extinguisher':
      case 'fire_extinguisher':
        return const Color(0xFFEA580C); // 주황색
      case 'water':
      case 'water_purifier':
        return const Color(0xFF0891B2); // 청록색
      case 'bookstore':
        return const Color(0xFF059669); // 초록색
      case 'post':
        return const Color(0xFF7C2D12); // 갈색
      default:
        return const Color(0xFF1E3A8A); // Woosong Blue
    }
  }
} 