# 센서 기능 사용 가이드

이 프로젝트에는 만보기(Pedometer)와 GPS 위치 기능이 통합되어 있습니다.

## 구현된 기능

### 1. 만보기 (Pedometer)
- ✅ 실시간 걸음 수 측정
- ✅ 만보 달성률 계산
- ✅ 걷기 상태 감지 (walking/stopped)
- ✅ 백그라운드 추적 지원

### 2. GPS 위치 (Location)
- ✅ 현재 위도/경도 가져오기
- ✅ 실시간 위치 스트림
- ✅ 두 지점 간 거리 계산
- ✅ 위치 권한 관리

## 파일 구조

```
lib/
├── services/
│   ├── pedometer_service.dart      # 만보기 서비스
│   └── location_service.dart       # GPS 위치 서비스
└── Screens/
    └── Home/
        ├── home_screen.dart        # 기존 홈 화면
        └── home_screen_with_sensors.dart  # 센서 통합 홈 화면 ⭐
```

## 사용 방법

### 옵션 1: 기존 홈 화면 교체

`lib/main.dart` 파일을 수정하세요:

```dart
import 'Screens/Home/home_screen_with_sensors.dart';  // 새로 추가

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreenWithSensors(),  // 변경
      },
    );
  }
}
```

### 옵션 2: 개별 사용

#### 만보기만 사용

```dart
import 'package:flutter/material.dart';
import 'services/pedometer_service.dart';

class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final PedometerService _pedometerService = PedometerService();
  int _steps = 0;

  @override
  void initState() {
    super.initState();
    _initPedometer();
  }

  Future<void> _initPedometer() async {
    final success = await _pedometerService.startTracking();
    if (success) {
      _pedometerService.stepsStream.listen((steps) {
        setState(() {
          _steps = steps;
        });
      });
    }
  }

  @override
  void dispose() {
    _pedometerService.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('걸음 수: $_steps');
  }
}
```

#### GPS만 사용

```dart
import 'package:flutter/material.dart';
import 'services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final LocationService _locationService = LocationService();
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('위도: ${_latitude ?? "로딩 중..."}'),
        Text('경도: ${_longitude ?? "로딩 중..."}'),
        ElevatedButton(
          onPressed: _getLocation,
          child: Text('위치 새로고침'),
        ),
      ],
    );
  }
}
```

## API 레퍼런스

### PedometerService

```dart
// 싱글톤 인스턴스
final pedometerService = PedometerService();

// 만보기 시작 (권한 요청 포함)
Future<bool> success = await pedometerService.startTracking();

// 걸음 수 스트림
Stream<int> stepsStream = pedometerService.stepsStream;

// 현재 걸음 수
int currentSteps = pedometerService.currentSteps;

// 현재 상태 (walking/stopped)
String status = pedometerService.pedestrianStatus;

// 만보기 중지
pedometerService.stopTracking();
```

### LocationService

```dart
// 싱글톤 인스턴스
final locationService = LocationService();

// 현재 위치 가져오기
Position? position = await locationService.getCurrentLocation();
if (position != null) {
  print('위도: ${position.latitude}');
  print('경도: ${position.longitude}');
}

// 실시간 위치 스트림
Stream<Position> locationStream = locationService.getLocationStream();

// 거리 계산 (미터 단위)
double distance = locationService.getDistanceBetween(
  startLatitude: 37.5665,
  startLongitude: 126.9780,
  endLatitude: 37.5662,
  endLongitude: 126.9782,
);

// 위치 권한 확인
LocationPermission permission = await locationService.checkPermission();

// 위치 권한 요청
LocationPermission permission = await locationService.requestPermission();

// 설정 페이지 열기
await locationService.openLocationSettings();
await locationService.openAppSettings();
```

## 권한 설정

### iOS (이미 설정됨 ✅)

`ios/Runner/Info.plist`:
- NSLocationWhenInUseUsageDescription
- NSLocationAlwaysAndWhenInUseUsageDescription
- NSMotionUsageDescription
- UIBackgroundModes (location, processing)

### Android (이미 설정됨 ✅)

`android/app/src/main/AndroidManifest.xml`:
- ACCESS_FINE_LOCATION
- ACCESS_COARSE_LOCATION
- ACTIVITY_RECOGNITION
- FOREGROUND_SERVICE
- ACCESS_BACKGROUND_LOCATION

## 테스트 방법

### 실제 기기에서 테스트 (권장)

만보기와 GPS는 시뮬레이터에서 제대로 작동하지 않을 수 있습니다. 실제 기기에서 테스트하세요:

```bash
# iOS
flutter run -d [실제 기기 ID]

# Android
flutter run -d [실제 기기 ID]
```

### 시뮬레이터 GPS 테스트

iOS 시뮬레이터에서는 GPS를 시뮬레이션할 수 있습니다:
1. 시뮬레이터 실행
2. Features > Location > Custom Location
3. 위도/경도 입력

## 트러블슈팅

### 걸음 수가 0으로 표시될 때

1. **실제 기기 사용**: 시뮬레이터는 만보기를 지원하지 않습니다
2. **권한 확인**: 설정 > 앱 > 권한에서 "신체 활동" 권한 확인
3. **디바이스 흔들기**: 실제로 걸어보거나 기기를 흔들어보세요

### 위치를 가져올 수 없을 때

1. **위치 서비스 활성화**: 설정 > 위치에서 GPS 켜기
2. **권한 확인**: 설정 > 앱 > 권한에서 "위치" 권한 확인
3. **실외에서 테스트**: GPS는 실내에서 정확도가 떨어집니다

### 권한이 거부되었을 때

```dart
// 앱 설정 페이지 열기
await locationService.openAppSettings();
```

## 메뉴바 애니메이션 개선

메뉴바 전환 시 자연스러운 페이드 애니메이션이 적용되었습니다:
- `Navigator.push` → `Navigator.pushReplacement` 변경
- `PageRouteBuilder`로 커스텀 전환 애니메이션 구현
- 200ms 페이드 인/아웃 효과

## 주의사항

⚠️ **개인정보 보호**
- 위치 정보는 민감한 개인정보입니다
- 수집된 데이터를 외부로 전송할 때는 사용자 동의 필요
- GDPR, 개인정보보호법 준수

⚠️ **배터리 소모**
- 백그라운드에서 계속 위치를 추적하면 배터리 소모가 큽니다
- 필요할 때만 위치 추적 활성화
- `distanceFilter` 설정으로 업데이트 빈도 조절

⚠️ **에러 핸들링**
- 권한 거부, 센서 미지원 등의 경우 적절한 UI 표시
- try-catch로 예외 처리

## 다음 단계

- [ ] 걸음 수 로컬 저장 (SharedPreferences)
- [ ] 일별 걸음 수 통계
- [ ] 걸음 수 목표 설정
- [ ] 위치 기반 체육시설 검색
- [ ] 운동 경로 추적 및 저장
