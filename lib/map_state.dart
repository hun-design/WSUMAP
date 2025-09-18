import 'package:flutter/material.dart';
import 'dart:math';

/// 지도 상태를 관리하는 ChangeNotifier
class MapState with ChangeNotifier {
  double _deviceHeading = 0.0;
  double _mapBearing = 0.0;

  /// 디바이스 방향각 (도 단위)
  double get deviceHeading => _deviceHeading;
  
  /// 지도 베어링 (도 단위)
  double get mapBearing => _mapBearing;

  /// 마커가 회전해야 할 각도 (라디안 단위)
  double get correctedMarkerAngleRadian => 
      (_deviceHeading - _mapBearing) * (pi / 180);

  /// 디바이스 방향각 업데이트
  void updateDeviceHeading(double heading) {
    _deviceHeading = heading;
    notifyListeners();
  }

  /// 지도 베어링 업데이트
  void updateMapBearing(double bearing) {
    _mapBearing = bearing;
    notifyListeners();
  }
}
