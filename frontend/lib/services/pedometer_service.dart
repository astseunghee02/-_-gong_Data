import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class PedometerService {
  static final PedometerService _instance = PedometerService._internal();
  factory PedometerService() => _instance;
  PedometerService._internal();

  StreamSubscription<StepCount>? _stepCountStream;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusStream;

  int _currentSteps = 0;
  String _pedestrianStatus = 'stopped';

  // 걸음 수 변경을 알리는 스트림
  final _stepsController = StreamController<int>.broadcast();
  Stream<int> get stepsStream => _stepsController.stream;

  // 현재 걸음 수
  int get currentSteps => _currentSteps;

  // 현재 상태 (walking/stopped)
  String get pedestrianStatus => _pedestrianStatus;

  /// 만보기 시작
  Future<bool> startTracking() async {
    // 권한 요청
    final status = await _requestPermission();
    if (!status) {
      print('만보기 권한이 거부되었습니다.');
      return false;
    }

    try {
      // 걸음 수 스트림 시작
      _stepCountStream = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
      );

      // 걷기 상태 스트림 시작
      _pedestrianStatusStream = Pedometer.pedestrianStatusStream.listen(
        _onPedestrianStatusChanged,
        onError: _onPedestrianStatusError,
      );

      print('만보기 추적 시작');
      return true;
    } catch (e) {
      print('만보기 시작 실패: $e');
      return false;
    }
  }

  /// 만보기 중지
  void stopTracking() {
    _stepCountStream?.cancel();
    _pedestrianStatusStream?.cancel();
    print('만보기 추적 중지');
  }

  /// 걸음 수 업데이트 콜백
  void _onStepCount(StepCount event) {
    _currentSteps = event.steps;
    _stepsController.add(_currentSteps);
    print('걸음 수: $_currentSteps');
  }

  /// 걸음 수 에러 콜백
  void _onStepCountError(error) {
    print('걸음 수 에러: $error');
  }

  /// 걷기 상태 변경 콜백
  void _onPedestrianStatusChanged(PedestrianStatus event) {
    _pedestrianStatus = event.status;
    print('걷기 상태: $_pedestrianStatus');
  }

  /// 걷기 상태 에러 콜백
  void _onPedestrianStatusError(error) {
    print('걷기 상태 에러: $error');
  }

  /// 권한 요청
  Future<bool> _requestPermission() async {
    // Android 10 (API 29) 이상에서는 ACTIVITY_RECOGNITION 권한 필요
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  /// 리소스 정리
  void dispose() {
    stopTracking();
    _stepsController.close();
  }
}
