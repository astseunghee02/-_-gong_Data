# 공공체육 앱 (Gong_data)

공공체육시설 정보와 운동 데이터를 기반으로 사용자의 운동을 재미있게 관리하는 Flutter 모바일 애플리케이션입니다.

## 프로젝트 개요

이 앱은 사용자의 운동을 게임화(Gamification)하여 지속적인 운동 습관을 만들도록 돕습니다. 만보기, GPS 위치 추적, 공공체육시설 정보를 활용하여 매일 운동 미션을 제공하고, 운동을 완료할 때마다 캐릭터가 성장하는 재미를 제공합니다.

## 주요 기능

### 1. 게임화 시스템
- 운동 캐릭터 '포리(Pori)' 육성
- 레벨 시스템 및 캐릭터 성장
- 상체/하체/코어 3가지 능력치 추적
- 운동 완료 시 포인트 적립 및 레벨업

### 2. 센서 통합
- 실시간 만보기 (Pedometer)
  - 실시간 걸음 수 측정
  - 만보 달성률 계산
  - 걷기 상태 감지 (walking/stopped)
  - 백그라운드 추적 지원
- GPS 위치 추적
  - 현재 위도/경도 가져오기
  - 실시간 위치 스트림
  - 두 지점 간 거리 계산
  - 위치 권한 관리

### 3. 지도 및 시설 정보
- Google Maps 통합
- 공공체육시설 위치 표시
- 위치 기반 운동 루트 추천

### 4. 사용자 인터페이스
- 온보딩 화면 (스와이프 방식)
- 로그인 및 회원가입
- 홈 화면 (날씨 정보, 캐릭터 상태)
- 미션 화면
- 통계 화면
- 설정 화면
- 커스텀 하단 네비게이션 바

## 기술 스택

### Framework & Language
- Flutter (Dart 3.10.0-290.4.beta)

### 주요 패키지
- `google_maps_flutter: ^2.14.0` - 지도 기능
- `pedometer: ^4.0.1` - 만보기
- `geolocator: ^13.0.2` - GPS 위치 추적
- `permission_handler: ^11.3.1` - 권한 관리
- `flutter_dotenv: ^5.2.1` - 환경 변수 관리
- `flutter_svg: ^2.2.3` - SVG 이미지
- `intl: ^0.20.2` - 국제화 및 날짜 포맷팅
- `cupertino_icons: ^1.0.8` - iOS 스타일 아이콘

## 프로젝트 구조

```
lib/
├── main.dart                          # 앱 진입점
├── Screens/                           # 화면 모음
│   ├── OnBoarding/
│   │   └── onboarding_screen.dart     # 온보딩 화면
│   ├── Login/
│   │   ├── login_screen.dart          # 로그인 화면
│   │   ├── signup_profile_shell.dart  # 회원가입 쉘
│   │   ├── signup_profile_step.dart   # 회원가입 단계
│   │   └── signup_profile_step_1.dart # 회원가입 1단계
│   ├── Home/
│   │   ├── home_screen.dart           # 기본 홈 화면
│   │   └── home_screen_with_sensors.dart # 센서 통합 홈 화면
│   ├── Map/
│   │   └── map_screen.dart            # 지도 화면
│   ├── Mission/
│   │   └── Mission_screen.dart        # 미션 화면
│   ├── UserStatics/
│   │   └── StatusScreen.dart          # 통계 화면
│   └── Setting/
│       └── Setting_screen.dart        # 설정 화면
├── services/                          # 서비스 모음
│   ├── pedometer_service.dart         # 만보기 서비스
│   └── location_service.dart          # GPS 위치 서비스
└── widgets/                           # 재사용 가능한 위젯
    ├── custom_bottom_nav_bar.dart     # 커스텀 하단 네비게이션
    ├── app_bottom_nav_items.dart      # 네비게이션 아이템
    └── community_sections.dart        # 커뮤니티 섹션

assets/
├── icons/                             # 아이콘 이미지
├── images/                            # 일반 이미지
│   ├── Lv01_pori.png                 # 레벨 1 포리 이미지
│   └── pori-user.png                 # 사용자 포리 이미지
└── map_style.json                    # 구글 맵 스타일
```

## 시작하기

### 사전 요구사항

- Flutter SDK (^3.10.0-290.4.beta)
- Dart SDK
- Android Studio / Xcode (플랫폼별)
- Google Maps API Key

### 설치 및 실행

1. 저장소 클론
```bash
git clone <repository-url>
cd Gong_data
```

2. 의존성 설치
```bash
flutter pub get
```

3. 환경 변수 설정
```bash
# .env 파일 생성
cp .env.example .env

# .env 파일을 열고 Google Maps API 키 입력
GOOGLE_MAPS_API_KEY=your_actual_api_key_here
```

상세한 환경 변수 설정 방법은 [ENV_SETUP.md](ENV_SETUP.md)를 참조하세요.

4. 플랫폼별 추가 설정

**Android**
```bash
# android/local.properties 파일에 API 키 추가
GOOGLE_MAPS_API_KEY=your_actual_api_key_here
```

**iOS**
```bash
# ios/Flutter/Debug.xcconfig, Release.xcconfig, Profile.xcconfig 파일에 이미 설정됨
# 필요시 API 키 업데이트
```

5. 앱 실행
```bash
# 개발 모드 실행
flutter run

# 특정 디바이스 지정
flutter run -d <device-id>

# 디바이스 목록 확인
flutter devices
```

## Google Maps API 키 발급

1. [Google Cloud Console](https://console.cloud.google.com/) 접속
2. 새 프로젝트 생성 또는 기존 프로젝트 선택
3. "API 및 서비스" > "사용자 인증 정보"로 이동
4. "사용자 인증 정보 만들기" > "API 키" 선택
5. Maps SDK for Android 및 Maps SDK for iOS 활성화
6. API 키 제한 설정 (앱 제한 설정 권장)

## 센서 기능 사용

이 앱은 만보기와 GPS 위치 추적 기능을 제공합니다. 상세한 사용 방법은 [SENSORS_GUIDE.md](SENSORS_GUIDE.md)를 참조하세요.

### 빠른 시작

```dart
import 'services/pedometer_service.dart';
import 'services/location_service.dart';

// 만보기 사용
final pedometerService = PedometerService();
await pedometerService.startTracking();
pedometerService.stepsStream.listen((steps) {
  print('걸음 수: $steps');
});

// GPS 위치 사용
final locationService = LocationService();
final position = await locationService.getCurrentLocation();
print('위도: ${position?.latitude}, 경도: ${position?.longitude}');
```

## 권한 설정

앱이 정상적으로 작동하려면 다음 권한이 필요합니다:

### iOS
- 위치 권한 (NSLocationWhenInUseUsageDescription)
- 백그라운드 위치 (NSLocationAlwaysAndWhenInUseUsageDescription)
- 모션 및 활동 (NSMotionUsageDescription)
- 백그라운드 모드 (location, processing)

### Android
- ACCESS_FINE_LOCATION
- ACCESS_COARSE_LOCATION
- ACTIVITY_RECOGNITION
- FOREGROUND_SERVICE
- ACCESS_BACKGROUND_LOCATION

모든 권한은 이미 `AndroidManifest.xml` 및 `Info.plist`에 설정되어 있습니다.

## 빌드

### Android APK 빌드
```bash
flutter build apk --release
```

### iOS IPA 빌드
```bash
flutter build ios --release
```

## 테스트

### 센서 기능 테스트
센서 기능(만보기, GPS)은 실제 기기에서 테스트하는 것을 권장합니다.

```bash
# 실제 기기에서 실행
flutter run -d <device-id>
```

iOS 시뮬레이터에서 GPS를 테스트하려면:
1. 시뮬레이터 실행
2. Features > Location > Custom Location
3. 위도/경도 입력

### 단위 테스트
```bash
flutter test
```

## 트러블슈팅

### 걸음 수가 0으로 표시될 때
- 실제 기기를 사용하세요 (시뮬레이터는 만보기를 지원하지 않음)
- 설정 > 앱 > 권한에서 "신체 활동" 권한 확인
- 실제로 걸어보거나 기기를 흔들어보세요

### 위치를 가져올 수 없을 때
- 설정 > 위치에서 GPS 활성화
- 설정 > 앱 > 권한에서 "위치" 권한 확인
- 실외에서 테스트 (GPS는 실내에서 정확도가 떨어짐)

### API 키 오류
- `.env` 파일이 프로젝트 루트에 있는지 확인
- API 키가 올바르게 입력되었는지 확인
- Google Cloud Console에서 Maps SDK가 활성화되었는지 확인

## 화면 플로우

```
[온보딩] → [로그인] → [홈]
                        ├── [지도]
                        ├── [미션]
                        ├── [통계]
                        └── [설정]
```

## 캐릭터 시스템

사용자는 '포리(Pori)'라는 캐릭터를 키우게 됩니다:
- 초기 레벨: Lv.1
- 운동 완료 시 경험치 획득
- 레벨업 시 캐릭터 이미지 변경
- 3가지 능력치: 상체, 하체, 코어

## 날씨 정보

홈 화면에는 날씨 정보가 표시됩니다:
- 현재 온도
- 날씨 상태 (맑음, 흐림, 비)
- 한글 날짜 표시 (예: 2025년 12월 6일 (금))

## 보안 및 개인정보

- `.env` 파일은 `.gitignore`에 포함되어 Git에 커밋되지 않습니다
- API 키는 환경 변수로 관리됩니다
- 위치 정보는 사용자 동의 후에만 수집됩니다
- GDPR 및 개인정보보호법 준수 필요

## 향후 개발 계획

- [ ] 걸음 수 로컬 저장 (SharedPreferences)
- [ ] 일별 걸음 수 통계
- [ ] 걸음 수 목표 설정
- [ ] 위치 기반 체육시설 검색
- [ ] 운동 경로 추적 및 저장
- [ ] 커뮤니티 기능
- [ ] 실시간 날씨 API 통합
- [ ] 푸시 알림 (운동 리마인더)
- [ ] 소셜 로그인 (Google, Apple)

## 기여하기

프로젝트에 기여하고 싶으시다면:
1. 이 저장소를 포크하세요
2. 새로운 브랜치를 생성하세요 (`git checkout -b feature/amazing-feature`)
3. 변경사항을 커밋하세요 (`git commit -m 'Add some amazing feature'`)
4. 브랜치에 푸시하세요 (`git push origin feature/amazing-feature`)
5. Pull Request를 생성하세요

## 라이선스

이 프로젝트는 비공개 프로젝트입니다 (`publish_to: 'none'`).

## 연락처

프로젝트 관련 문의사항이 있으시면 이슈를 등록해주세요.

## 참고 자료

- [Flutter 공식 문서](https://docs.flutter.dev/)
- [Google Maps Flutter 플러그인](https://pub.dev/packages/google_maps_flutter)
- [Pedometer 플러그인](https://pub.dev/packages/pedometer)
- [Geolocator 플러그인](https://pub.dev/packages/geolocator)
- [환경 변수 설정 가이드](ENV_SETUP.md)
- [센서 기능 사용 가이드](SENSORS_GUIDE.md)
