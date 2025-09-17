import 'package:flutter/material.dart';

class MapState with ChangeNotifier {
  double _deviceHeading = 0.0;
  double _mapBearing = 0.0;

  double get deviceHeading => _deviceHeading;
  double get mapBearing => _mapBearing;

  // 최종적으로 마커가 회전해야 할 각도 (라디안)
  double get correctedMarkerAngleRadian => (_deviceHeading - _mapBearing) * (3.1415926535 / 180);

  void updateDeviceHeading(double heading) {
    _deviceHeading = heading;
    notifyListeners();
  }

  void updateMapBearing(double bearing) {
    _mapBearing = bearing;
    notifyListeners();
  }
}
