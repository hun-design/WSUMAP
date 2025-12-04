#!/bin/bash

# 키스토어 자동 생성 스크립트 (비밀번호 직접 입력)

echo "🔐 Android 키스토어 생성 스크립트"
echo "=================================="
echo ""

# 키스토어 파일 경로
KEYSTORE_FILE="wsumap-release-key.jks"
KEYSTORE_PATH="$(pwd)/$KEYSTORE_FILE"

# 키스토어가 이미 존재하는지 확인
if [ -f "$KEYSTORE_FILE" ]; then
    echo "⚠️  키스토어 파일이 이미 존재합니다: $KEYSTORE_FILE"
    read -p "기존 키스토어를 덮어쓰시겠습니까? (y/N): " overwrite
    if [[ ! $overwrite =~ ^[Yy]$ ]]; then
        echo "❌ 취소되었습니다."
        exit 1
    fi
    rm -f "$KEYSTORE_FILE"
fi

echo "📝 키스토어 정보를 입력하세요:"
echo ""

# 정보 입력
read -p "이름: " NAME
read -p "조직 단위 (OU): " OU
read -p "조직 (O): " ORG
read -p "도시 (L): " CITY
read -p "시/도 (ST): " STATE
read -p "국가 코드 (C, 예: KR): " COUNTRY

echo ""
echo "🔑 키스토어 비밀번호를 입력하세요 (6자 이상):"
read -s STORE_PASSWORD
echo ""

if [ ${#STORE_PASSWORD} -lt 6 ]; then
    echo "❌ 비밀번호는 6자 이상이어야 합니다."
    exit 1
fi

echo "🔑 키 비밀번호를 입력하세요 (키스토어 비밀번호와 동일하게 사용하려면 엔터):"
read -s KEY_PASSWORD
echo ""

if [ -z "$KEY_PASSWORD" ]; then
    KEY_PASSWORD="$STORE_PASSWORD"
fi

# 기본값 설정
NAME=${NAME:-"JinYoung Jung"}
OU=${OU:-"YeahJilBae"}
ORG=${ORG:-"YeahJilBae"}
CITY=${CITY:-"Daejeon"}
STATE=${STATE:-"Daejeon"}
COUNTRY=${COUNTRY:-"KR"}

echo ""
echo "생성 중..."
echo ""

# keytool 명령어 실행 (자동 답변)
keytool -genkey -v -keystore "$KEYSTORE_FILE" \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -alias wsumap \
    -storepass "$STORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "CN=$NAME, OU=$OU, O=$ORG, L=$CITY, ST=$STATE, C=$COUNTRY" <<EOF
y
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 키스토어가 성공적으로 생성되었습니다!"
    echo "📁 파일 위치: $KEYSTORE_PATH"
    echo ""
    
    # key.properties 파일 생성
    KEY_PROPERTIES="key.properties"
    cat > "$KEY_PROPERTIES" <<EOF
storePassword=$STORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=wsumap
storeFile=$KEYSTORE_FILE
EOF
    
    echo "✅ key.properties 파일이 생성되었습니다: $KEY_PROPERTIES"
    echo ""
    echo "⚠️  중요: 키스토어 파일과 key.properties 파일을 안전하게 보관하세요!"
    echo "⚠️  이 파일들을 잃어버리면 Google Play Store에 업데이트를 배포할 수 없습니다!"
else
    echo ""
    echo "❌ 키스토어 생성에 실패했습니다."
    exit 1
fi

