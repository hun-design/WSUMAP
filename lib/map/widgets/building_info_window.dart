// lib/map/widgets/building_info_window.dart - 서버 이미지만 사용

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/building.dart';
import '../../generated/app_localizations.dart';
import 'package:flutter_application_1/inside/building_map_page.dart';
import 'package:flutter_application_1/map/widgets/directions_screen.dart';

class BuildingInfoWindow extends StatefulWidget {
  final Building building;
  final VoidCallback onClose;
  final Function(Building) onShowDetails;
  final Function(dynamic)? onSetStart;
  final Function(dynamic)? onSetEnd;
  final Function(Building)? onShowFloorPlan;

  const BuildingInfoWindow({
    super.key,
    required this.building,
    required this.onClose,
    required this.onShowDetails,
    this.onSetStart,
    this.onSetEnd,
    this.onShowFloorPlan,
  });

  @override
  State<BuildingInfoWindow> createState() => _BuildingInfoWindowState();
}

class _BuildingInfoWindowState extends State<BuildingInfoWindow> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        // 배경 터치 영역
        Positioned.fill(
          child: GestureDetector(
            onTap: () => widget.onClose(),
            child: Container(color: Colors.transparent),
          ),
        ),
        // 건물 정보 UI
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [_buildDragHandle(), _buildContent(context, l10n)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDragHandle() {
    return GestureDetector(
      onTap: () => widget.onClose(),
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n) {
    // 서버에서 받아온 이미지만 사용
    List<String> imagePaths = [];
    bool isNetworkImage = false;

    if (widget.building.imageUrls != null &&
        widget.building.imageUrls!.isNotEmpty) {
      imagePaths = widget.building.imageUrls!;
      isNetworkImage = true;
    } else if (widget.building.imageUrl != null &&
        widget.building.imageUrl!.isNotEmpty) {
      imagePaths = [widget.building.imageUrl!];
      isNetworkImage = true;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 서버 이미지가 있을 때만 갤러리 표시
          if (imagePaths.isNotEmpty) ...[
            _buildImageGallery(imagePaths, isNetworkImage),
            const SizedBox(height: 12),
          ],
          _buildHeader(),
          const SizedBox(height: 12),
          _buildLocationInfo(l10n),
          const SizedBox(height: 16),
          _buildStatusAndHours(l10n),
          const SizedBox(height: 20),
          _buildFloorPlanButton(l10n, context),
          const SizedBox(height: 20),
          _buildActionButtons(l10n, context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 🔥 대표 사진만 표시하는 위젯
  Widget _buildImageGallery(List<String> imagePaths, bool isNetworkImage) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 대표 사진 (첫 번째 이미지만 표시)
        GestureDetector(
          onTap: () => _showImageDialog(imagePaths, 0, isNetworkImage),
          child: Stack(
            children: [
              // 🎯 대표 이미지 (버퍼 최적화)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imagePaths.first,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  // 🎯 ImageReader_JNI 로그 방지를 위한 캐시 및 버퍼 최적화
                  cacheWidth: 120, // 정확한 해상도로 캐시하여 메모리 절약
                  cacheHeight: 120,
                  filterQuality: FilterQuality.medium, // 고품질 필터 비활성화로 성능 향상
                  headers: {
                    'Cache-Control': 'max-age=3600', // 1시간 캐시 설정
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.error, color: Colors.grey),
                    );
                  },
                ),
              ),
              // 여러 이미지가 있을 때 갤러리 아이콘 표시
              if (imagePaths.length > 1)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${imagePaths.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        // 이미지 개수 표시 (여러 장일 때만)
        if (imagePaths.length > 1) ...[
          const SizedBox(height: 8),
          Text(
            '${imagePaths.length}${l10n.max_one_image}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  /// 🔥 이미지 전체화면 다이얼로그
  void _showImageDialog(
    List<String> imagePaths,
    int initialIndex,
    bool isNetworkImage,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _ImageDialog(
        imagePaths: imagePaths,
        initialIndex: initialIndex,
        isNetworkImage: isNetworkImage,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.building.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        IconButton(
          onPressed: widget.onClose,
          icon: const Icon(Icons.close, color: Colors.grey, size: 24),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildLocationInfo(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.building.category} · ${l10n.woosong_university}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.building.info,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildStatusAndHours(AppLocalizations l10n) {
    final statusColor = widget.building.statusColor;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.building.getLocalizedStatus(context),
            style: TextStyle(
              fontSize: 12,
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          widget.building.hours,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildFloorPlanButton(AppLocalizations l10n, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => widget.onShowFloorPlan?.call(widget.building),
        icon: const Icon(Icons.map_outlined),
        label: Text(l10n.floor_plan),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showLocationSettingDialog(l10n.set_start_point),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.set_start_point),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showLocationSettingDialog(l10n.set_end_point),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.set_end_point),
          ),
        ),
      ],
    );
  }

  void _showLocationSettingDialog(String locationType) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => _LocationSettingDialog(
        buildingName: widget.building.name,
        locationType: locationType,
        onConfirm: () {
          Navigator.of(context).pop();

          // 길찾기 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DirectionsScreen(
                presetStart: locationType == l10n.set_start_point
                    ? widget.building
                    : null,
                presetEnd: locationType == l10n.set_end_point
                    ? widget.building
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 🔥 이미지 다이얼로그 위젯
class _ImageDialog extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;
  final bool isNetworkImage;

  const _ImageDialog({
    required this.imagePaths,
    required this.initialIndex,
    required this.isNetworkImage,
  });

  @override
  State<_ImageDialog> createState() => _ImageDialogState();
}

class _ImageDialogState extends State<_ImageDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // 이미지 뷰어
          PageView.builder(
            itemCount: widget.imagePaths.length,
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Center(
                child: InteractiveViewer(
                  child: Image.network(
                    widget.imagePaths[index],
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    // 🎯 ImageReader_JNI 로그 방지를 위한 대화상자용 최적화
                    filterQuality: FilterQuality.medium, // 품질과 성능 균형
                    headers: {
                      'Cache-Control': 'max-age=7200', // 2시간 캐시 (더 긴 캐시)
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              l10n.image_load_error,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          // 닫기 버튼
          Positioned(
            top: 32,
            right: 32,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          // 이미지 인덱스 표시 (여러 이미지인 경우)
          if (widget.imagePaths.length > 1)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.imagePaths.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 🔥 위치 설정 다이얼로그
class _LocationSettingDialog extends StatelessWidget {
  final String buildingName;
  final String locationType;
  final VoidCallback onConfirm;

  const _LocationSettingDialog({
    required this.buildingName,
    required this.locationType,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 제목
                Row(
                  children: [
                    Icon(
                      locationType == l10n.set_start_point
                          ? Icons.play_arrow
                          : Icons.flag,
                      color: locationType == l10n.set_start_point
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$locationType ${l10n.setting}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 내용
                Text(
                  l10n.location_setting_confirm(buildingName, locationType),
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // 방 설정 버튼
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // 내부도면 페이지로 이동하여 방 선택
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BuildingMapPage(
                            buildingName: buildingName,
                            locationType: locationType,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.room, size: 18),
                    label: Text(l10n.set_room),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E3A8A),
                      side: const BorderSide(color: Color(0xFF1E3A8A)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 버튼들
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(l10n.confirm),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
