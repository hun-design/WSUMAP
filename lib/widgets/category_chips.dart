import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/services/category_api_service.dart';
import 'package:flutter_application_1/data/category_fallback_data.dart';
import 'package:flutter_application_1/utils/CategoryLocalization.dart';
import 'package:flutter_application_1/providers/category_provider.dart';
import 'package:flutter_application_1/providers/app_language_provider.dart';

class CategoryChips extends StatefulWidget {
  final Function(String, List<Map<String, dynamic>>) onCategorySelected;
  final String? selectedCategory;

  const CategoryChips({
    super.key,
    required this.onCategorySelected,
    this.selectedCategory,
  });

  // 외부에서 카테고리 선택을 위한 GlobalKey - 동적 생성으로 변경
  static GlobalKey<_CategoryChipsState>? _globalKey;
  
  static GlobalKey<_CategoryChipsState> get globalKey {
    _globalKey ??= GlobalKey<_CategoryChipsState>();
    return _globalKey!;
  }
  
  // GlobalKey 초기화 메서드 추가
  static void resetGlobalKey() {
    _globalKey = null;
  }

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  String? _selectedCategory;
  bool _isApiCalling = false;
  bool _isDisposed = false;

  // 외부에서 카테고리 선택을 위한 메서드
  void selectCategory(String category) {
    if (!mounted || _isDisposed) return;
    
    debugPrint('🎯 selectCategory 호출됨: $category');
    
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    if (categoryProvider.categories.contains(category)) {
      debugPrint('✅ 카테고리 찾음, 선택 처리 중: $category');
      setState(() {
        _selectedCategory = category;
      });
      _onCategoryTap(category);
    } else {
      debugPrint('❌ 카테고리를 찾을 수 없음: $category');
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
  }

  @override
  void didUpdateWidget(CategoryChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategory != oldWidget.selectedCategory && mounted && !_isDisposed) {
      setState(() {
        _selectedCategory = widget.selectedCategory;
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void refresh() {
    // 🔥 CategoryProvider의 새로고침 사용
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    categoryProvider.refreshCategories();
  }

  void _onCategoryTap(String? category) async {
    debugPrint('🎯 카테고리 탭: $category');

    if (_isApiCalling || !mounted || _isDisposed) {
      debugPrint('⚠️ API 호출 중이거나 위젯이 dispose됨');
      return;
    }

    if (category == null) {
      if (mounted && !_isDisposed) {
        setState(() {
          _selectedCategory = null;
        });
      }
      widget.onCategorySelected('', []);
      return;
    }

    if (_selectedCategory == category) {
      // 같은 카테고리를 다시 누르면 선택 해제
      debugPrint('🎯 같은 카테고리 재선택 → 해제: $category');
      if (mounted && !_isDisposed) {
        setState(() {
          _selectedCategory = null;
        });
      }
      widget.onCategorySelected('', []);
      return;
    }

    _isApiCalling = true;

    if (mounted && !_isDisposed) {
      setState(() {
        _selectedCategory = category;
      });
    }

    try {
      debugPrint('📡 카테고리 선택: $category');

      // 🔥 서버에서 건물 정보 가져오기
      final buildingInfoList = await _getCategoryBuildingInfoList(category);

      debugPrint('📡 카테고리 선택 완료: $category, 건물 수: ${buildingInfoList.length}');

      if (mounted && !_isDisposed) {
        widget.onCategorySelected(category, buildingInfoList);
      }
    } catch (e) {
      debugPrint('❌ 카테고리 선택 오류: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _selectedCategory = null;
        });
        widget.onCategorySelected('', []);
      }
    } finally {
      _isApiCalling = false;
    }
  }

  /// 카테고리별 건물 정보 가져오기 (서버 요청)
  Future<List<Map<String, dynamic>>> _getCategoryBuildingInfoList(String category) async {
    try {
      debugPrint('🔍 카테고리 건물 정보 조회: $category');
      
      // 🔥 층 정보가 포함된 건물 정보 가져오기
      final buildingInfoList = await CategoryApiService.getCategoryBuildingInfoList(category);
      debugPrint('🏢 건물+층 정보: $buildingInfoList');
      
      return buildingInfoList;
    } catch (e) {
      debugPrint('❌ 건물 정보 가져오기 실패: $e');
      return [];
    }
  }

@override
Widget build(BuildContext context) {
  return Consumer2<CategoryProvider, AppLanguageProvider>(
    builder: (context, categoryProvider, languageProvider, child) {
      return Container(
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: categoryProvider.categories.length, // +1 제거
          separatorBuilder: (context, index) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final category = categoryProvider.categories[index];
            return _buildCategoryChip(category);
          },
        ),
      );
    },
  );
}

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    // 🔥 카테고리 이름을 영어 ID로 변환하여 아이콘 가져오기
    final categoryId = _getCategoryId(category);
    final icon = CategoryFallbackData.getCategoryIcon(categoryId);

    return InkWell(
      onTap: () {
        if (mounted && !_isDisposed) {
          _onCategoryTap(category);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: isSelected 
              ? const LinearGradient(
                  colors: [
                    Color(0xFF667eea),
                    Color(0xFF764ba2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                ? const Color(0xFF667eea)
                : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.all(isSelected ? 3 : 2),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? Colors.white.withValues(alpha: 0.25)
                    : const Color(0xFF667eea).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  icon,
                  size: isSelected ? 14 : 12,
                  color: isSelected 
                    ? Colors.white 
                    : const Color(0xFF667eea),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                CategoryLocalization.getLabel(context, category),
                style: TextStyle(
                  fontSize: isSelected ? 11 : 10,
                  color: isSelected 
                    ? Colors.white 
                    : const Color(0xFF667eea),
                  fontWeight: isSelected 
                    ? FontWeight.w700 
                    : FontWeight.w600,
                  letterSpacing: isSelected ? 0.1 : 0.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔥 카테고리 이름을 영어 ID로 변환
  String _getCategoryId(String categoryName) {
    // 한국어 카테고리 이름을 영어 ID로 매핑
    switch (categoryName.toLowerCase().trim()) {
      case '카페':
        return 'cafe';
      case '식당':
        return 'restaurant';
      case '편의점':
        return 'convenience';
      case '자판기':
        return 'vending';
      case '화장실':
      case '정수기':
        return 'water';
      case '프린터':
        return 'printer';
      case '복사기':
        return 'copier';
      case 'atm':
      case '은행(atm)':
        return 'atm';
      case '의료':
      case '보건소':
        return 'medical';
      case '도서관':
        return 'library';
      case '체육관':
      case '헬스장':
        return 'gym';
      case '라운지':
        return 'lounge';
      case '소화기':
        return 'extinguisher';
      case '서점':
        return 'bookstore';
      case '우체국':
        return 'post';
      default:
        // 이미 영어 ID인 경우 그대로 반환
        return categoryName;
    }
  }
}
