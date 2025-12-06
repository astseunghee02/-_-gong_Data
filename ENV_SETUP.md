# 환경 변수 설정 가이드

## 개요
이 프로젝트는 API 키와 같은 민감한 정보를 환경 변수로 관리합니다.

## 설정 방법

### 1. .env 파일 생성
프로젝트 루트에 `.env` 파일이 있어야 합니다. `.env.example` 파일을 참고하여 생성하세요.

```bash
cp .env.example .env
```

그 다음 `.env` 파일을 열어서 실제 API 키 값을 입력하세요:

```
GOOGLE_MAPS_API_KEY=your_actual_api_key_here
```

### 2. Android 설정
Android의 경우 `android/local.properties` 파일에 API 키를 추가합니다:

```properties
GOOGLE_MAPS_API_KEY=your_actual_api_key_here
```

이 파일은 자동으로 `.gitignore`에 포함되어 있습니다.

### 3. iOS 설정
iOS의 경우 `ios/Flutter/Debug.xcconfig`, `Release.xcconfig`, `Profile.xcconfig` 파일에 API 키가 설정되어 있습니다:

```
GOOGLE_MAPS_API_KEY=your_actual_api_key_here
```

## Dart 코드에서 환경 변수 사용하기

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 환경 변수 읽기
final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
```

## 주의사항

⚠️ **절대로 `.env` 파일이나 API 키를 Git에 커밋하지 마세요!**

- `.env` 파일은 `.gitignore`에 포함되어 있습니다
- `android/local.properties`도 기본적으로 `.gitignore`에 포함되어 있습니다
- `.env.example` 파일만 커밋하여 다른 개발자들이 참고할 수 있도록 합니다

## 파일 구조

```
project/
├── .env                          # 실제 환경 변수 (gitignore됨)
├── .env.example                  # 환경 변수 템플릿
├── android/
│   ├── local.properties          # Android 환경 변수 (gitignore됨)
│   └── local.properties.example  # Android 환경 변수 템플릿
└── ios/
    └── Flutter/
        ├── Debug.xcconfig        # iOS Debug 환경 변수
        ├── Release.xcconfig      # iOS Release 환경 변수
        └── Profile.xcconfig      # iOS Profile 환경 변수
```

## Google Maps API 키 발급

1. [Google Cloud Console](https://console.cloud.google.com/)에 접속
2. 새 프로젝트 생성 또는 기존 프로젝트 선택
3. "API 및 서비스" > "사용자 인증 정보"로 이동
4. "사용자 인증 정보 만들기" > "API 키" 선택
5. Maps SDK for Android 및 Maps SDK for iOS 활성화
6. API 키 제한 설정 (앱 제한 설정 권장)
