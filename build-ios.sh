#!/bin/bash

# iOS 앱 빌드 스크립트

set -e  # 에러 발생 시 스크립트 중단

echo "🍎 iOS 앱 빌드를 시작합니다..."

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# macOS 확인
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ iOS 빌드는 macOS에서만 가능합니다.${NC}"
    exit 1
fi

# 현재 디렉토리 확인
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ pubspec.yaml 파일을 찾을 수 없습니다.${NC}"
    echo -e "${YELLOW}WSUMAP 디렉토리에서 실행해주세요.${NC}"
    exit 1
fi

# Xcode 설치 확인
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Xcode가 설치되어 있지 않습니다.${NC}"
    echo -e "${YELLOW}Xcode를 설치하고 실행해주세요.${NC}"
    exit 1
fi

# Flutter 클린 빌드
echo -e "${YELLOW}🧹 클린 빌드 중...${NC}"
flutter clean

# 의존성 설치
echo -e "${YELLOW}📦 의존성 설치 중...${NC}"
flutter pub get

# iOS 의존성 설치
echo -e "${YELLOW}📦 iOS CocoaPods 의존성 설치 중...${NC}"
cd ios
pod install
cd ..

# 릴리스 빌드
echo -e "${YELLOW}🏗️  iOS 릴리스 빌드 중...${NC}"
flutter build ios --release

echo -e "${GREEN}✅ iOS 빌드 완료!${NC}"
echo -e "${YELLOW}📋 다음 단계:${NC}"
echo "   1. Xcode에서 ios/Runner.xcworkspace 열기"
echo "   2. 상단에서 'Any iOS Device (arm64)' 선택"
echo "   3. Product > Archive 메뉴 선택"
echo "   4. Archive 생성 완료 후 'Distribute App' 클릭"
echo "   5. App Store Connect 선택 후 업로드"

echo -e "${GREEN}✅ 빌드가 완료되었습니다!${NC}"

