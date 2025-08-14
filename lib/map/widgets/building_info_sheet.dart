import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/category_fallback_data.dart';
import 'package:flutter_application_1/utils/CategoryLocalization.dart';
import 'package:flutter_application_1/generated/app_localizations.dart';

class BuildingInfoSheet extends StatelessWidget {
  final String buildingName;
  final String? category;
  final List<String> floors;
  final List<String>? categoryFloors; // 🔥 카테고리가 존재하는 층 정보 추가

  const BuildingInfoSheet({
    Key? key,
    required this.buildingName,
    this.category,
    required this.floors,
    this.categoryFloors, // 🔥 카테고리 층 정보 파라미터 추가
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // 🔥 카테고리가 선택된 경우 해당 카테고리가 존재하는 층만 필터링
    final displayFloors = category != null && categoryFloors != null && categoryFloors!.isNotEmpty
        ? categoryFloors!
        : floors;
        
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
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
          
          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                // 카테고리 아이콘
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(category),
                    color: _getCategoryColor(category),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                
                // 건물명과 카테고리 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        buildingName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (category != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          CategoryLocalization.getLabel(context, category!),
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
                
                // 닫기 버튼
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, thickness: 0.5),
          
          // 건물 정보 내용
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 층 정보
                Row(
                  children: [
                    Icon(
                      Icons.layers,
                      color: const Color(0xFF1E3A8A),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                                              l10n.total_floors(floors.length),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 층 목록
                if (displayFloors.isNotEmpty) ...[
                  Text(
                    category != null && categoryFloors != null && categoryFloors!.isNotEmpty
                        ? l10n.floor_with_category(CategoryLocalization.getLabel(context, category!))
                        : l10n.floor_info,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...displayFloors.map((floor) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A8A),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.floor_number(floor),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ] else ...[
                  Text(
                    l10n.no_floor_info,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),
                
                // 카테고리 정보
                if (category != null) ...[
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        color: _getCategoryColor(category),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${l10n.category}: ${CategoryLocalization.getLabel(context, category!)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  /// 카테고리 아이콘 가져오기
  IconData _getCategoryIcon(String? category) {
    if (category == null) return Icons.category;
    return CategoryFallbackData.getCategoryIcon(category);
  }
  
  /// 카테고리 색상 가져오기
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