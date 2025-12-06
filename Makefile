.PHONY: help run-flutter run-backend run-all clean-flutter install-flutter

help:
	@echo "📱 Gong Data 프로젝트 명령어"
	@echo ""
	@echo "Flutter 명령어:"
	@echo "  make run-flutter        - Flutter 앱 실행"
	@echo "  make clean-flutter      - Flutter 클린 빌드"
	@echo "  make install-flutter    - Flutter 의존성 설치"
	@echo ""
	@echo "Backend 명령어:"
	@echo "  make run-backend        - FastAPI 서버 실행"
	@echo ""
	@echo "통합 명령어:"
	@echo "  make run-all           - Flutter + Backend 동시 실행"

run-flutter:
	@echo "🚀 Flutter 앱 실행 중..."
	cd frontend && flutter run

run-backend:
	@echo "🚀 Backend API 서버 실행 중..."
	cd ha_recommend && python3 -m uvicorn main:app --reload

run-all:
	@echo "🚀 Flutter + Backend 동시 실행..."
	@make -j2 run-flutter run-backend

clean-flutter:
	@echo "🧹 Flutter 클린 빌드..."
	cd frontend && flutter clean && flutter pub get

install-flutter:
	@echo "📦 Flutter 의존성 설치..."
	cd frontend && flutter pub get
	cd frontend/ios && pod install

# macOS용 실행
run-macos:
	@echo "🖥️  macOS 데스크톱 앱 실행..."
	cd frontend && flutter run -d macos

# Chrome용 실행
run-chrome:
	@echo "🌐 Chrome 웹앱 실행..."
	cd frontend && flutter run -d chrome

# iOS 시뮬레이터 실행
run-ios:
	@echo "📱 iOS 시뮬레이터 실행..."
	open -a Simulator
	@sleep 3
	cd frontend && flutter run

# Flutter devices 확인
devices:
	cd frontend && flutter devices
