import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'map_state.dart';

class NaverMapScreen extends StatefulWidget {
  const NaverMapScreen({super.key});

  @override
  State<NaverMapScreen> createState() => _NaverMapScreenState();
}

class _NaverMapScreenState extends State<NaverMapScreen> {
  NaverMapController? _mapController;
  StreamSubscription? _sensorsSubscription;
  final NLatLng myPosition = const NLatLng(37.5665, 126.9780); // 예시: 서울시청

  @override
  void initState() {
    super.initState();
    // 위젯이 빌드된 후에 센서 리스닝을 시작합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startListeningToSensors();
    });
  }

  @override
  void dispose() {
    _sensorsSubscription?.cancel();
    super.dispose();
  }

  void _startListeningToSensors() {
    final mapState = context.read<MapState>();
    // 자력계 센서 구독
    _sensorsSubscription = magnetometerEvents.listen((event) {
      // 간단한 헤딩 계산 (실제로는 더 복잡한 보정이 필요할 수 있음)
      double heading = atan2(event.y, event.x) * 180 / pi;
      if (heading < 0) heading += 360;
      mapState.updateDeviceHeading(heading);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('네이버 지도 방향 테스트')),
      body: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(target: myPosition, zoom: 15),
        ),
        onMapReady: (controller) async {
          _mapController = controller;
          // 사용자 위치 마커 추가
          final userMarker = await _buildUserMarker();
          _mapController?.addOverlay(userMarker);
        },
        onCameraChange: (reason, animated) {
          // 지도 회전 각도 업데이트
          _mapController?.getCameraPosition().then((pos) {
            if (mounted) { // 위젯이 아직 화면에 있는지 확인
              context.read<MapState>().updateMapBearing(pos.bearing);
            }
          });
        },
      ),
    );
  }

  Future<NMarker> _buildUserMarker() async {
    // fromWidget을 사용하여 Flutter 위젯을 마커 아이콘으로 사용
    final iconImage = await NOverlayImage.fromWidget(
      context: context,
      widget: Consumer<MapState>(
        builder: (context, mapState, child) {
          return Transform.rotate(
            angle: mapState.correctedMarkerAngleRadian,
            child: const Icon(
              Icons.navigation,
              color: Colors.blue,
              size: 50,
            ),
          );
        },
      ),
      size: const Size(50, 50),
    );

    return NMarker(
      id: 'user_location',
      position: myPosition,
      icon: iconImage,
      anchor: const NPoint(0.5, 0.5), // 아이콘의 정중앙을 기준으로 위치
    );
  }
}
