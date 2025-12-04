#!/bin/bash

# Android 앱 빌드 스크립트

set -e  # 에러 발생 시 스크립트 중단

echo "🤖 Android 앱 빌드를 시작합니다..."

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 현재 디렉토리 확인
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ pubspec.yaml 파일을 찾을 수 없습니다.${NC}"
    echo -e "${YELLOW}WSUMAP 디렉토리에서 실행해주세요.${NC}"
    exit 1
fi

# Flutter 클린 빌드
echo -e "${YELLOW}🧹 클린 빌드 중...${NC}"
flutter clean

# 의존성 설치
echo -e "${YELLOW}📦 의존성 설치 중...${NC}"
flutter pub get

# 빌드 타입 선택
echo -e "${YELLOW}빌드 타입을 선택하세요:${NC}"
echo "1) APK (테스트용)"
echo "2) App Bundle (Google Play Store용)"
read -p "선택 (1 또는 2): " build_type

case $build_type in
    1)
        echo -e "${YELLOW}📱 APK 빌드 중...${NC}"
        flutter build apk --release
        
        echo -e "${GREEN}✅ APK 빌드 완료!${NC}"
        echo -e "${YELLOW}📁 파일 위치:${NC}"
        echo "   build/app/outputs/flutter-apk/app-release.apk"
        ;;
    2)
        echo -e "${YELLOW}📦 App Bundle 빌드 중...${NC}"
        flutter build appbundle --release
        
        echo -e "${GREEN}✅ App Bundle 빌드 완료!${NC}"
        echo -e "${YELLOW}📁 파일 위치:${NC}"
        echo "   build/app/outputs/bundle/release/app-release.aab"
        echo -e "${YELLOW}📋 다음 단계:${NC}"
        echo "   1. Google Play Console에 접속"
        echo "   2. 새 버전 생성 또는 기존 버전 선택"
        echo "   3. app-release.aab 파일 업로드"
        ;;
    *)
        echo -e "${RED}❌ 잘못된 선택입니다.${NC}"
        exit 1
        ;;
esac

# 키스토어 확인
if [ -f "android/key.properties" ]; then
    echo -e "${GREEN}✅ 키스토어 설정 파일이 있습니다.${NC}"
else
    echo -e "${YELLOW}⚠️  키스토어 설정 파일이 없습니다.${NC}"
    echo -e "${YELLOW}Google Play Store 배포를 위해서는 키스토어가 필요합니다.${NC}"
    echo -e "${YELLOW}APP_DEPLOYMENT_GUIDE.md를 참고하여 키스토어를 생성하세요.${NC}"
fi

echo -e "${GREEN}✅ 빌드가 완료되었습니다!${NC}"

