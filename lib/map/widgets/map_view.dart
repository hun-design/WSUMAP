//map_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_application_1/constants/map_constants.dart';

class MapView extends StatefulWidget {
  final Function(NaverMapController) onMapReady;
  final VoidCallback onTap;
  final Function(double)? onMapRotationChanged; // 지도 회전 감지 콜백

  const MapView({
    super.key,
    required this.onMapReady,
    required this.onTap,
    this.onMapRotationChanged,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  NaverMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: NaverMap(
        options: const NaverMapViewOptions(
          initialCameraPosition: MapConstants.initialCameraPosition,
          locationButtonEnable: false,
          logoMargin: EdgeInsets.only(right: 100, left: 8, bottom: 8), // 로고 마진 조정
          scaleBarEnable: false,
        ),
        onMapReady: (controller) async {
          _mapController = controller;
          await widget.onMapReady(controller);
        },
        onCameraChange: (cameraUpdate, isGesture) async {
          // 제스처로 인한 지도 회전 감지
          if (widget.onMapRotationChanged != null && isGesture && _mapController != null) {
            try {
              // 지도 컨트롤러에서 현재 카메라 상태 가져오기
              final cameraPosition = await _mapController!.getCameraPosition();
              widget.onMapRotationChanged!(cameraPosition.bearing);
            } catch (e) {
              debugPrint('❌ 지도 회전 감지 실패: $e');
            }
          }
        },
      ),
    );
  }
}