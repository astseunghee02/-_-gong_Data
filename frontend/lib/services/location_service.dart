import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// 현재 위치 가져오기
  Future<Position?> getCurrentLocation() async {
    try {
      // 위치 서비스가 활성화되어 있는지 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('위치 서비스가 비활성화되어 있습니다.');
        return null;
      }

      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('위치 권한이 거부되었습니다.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('위치 권한이 영구적으로 거부되었습니다.');
        return null;
      }

      // 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // 10미터 이동 시 업데이트
        ),
      );

      print('현재 위치: 위도=${position.latitude}, 경도=${position.longitude}');
      return position;
    } catch (e) {
      print('위치 가져오기 실패: $e');
      return null;
    }
  }

  /// 위치 스트림 시작 (실시간 위치 추적)
  Stream<Position> getLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // 10미터 이동 시 업데이트
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// 두 지점 사이의 거리 계산 (미터 단위)
  double getDistanceBetween({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// 위치 권한 상태 확인
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// 위치 권한 요청
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// 위치 서비스 활성화 여부 확인
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// 앱 설정 페이지 열기
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// 앱 권한 설정 페이지 열기
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}
