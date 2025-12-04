@echo off
REM Windows용 키스토어 자동 생성 스크립트

echo 🔐 Android 키스토어 생성 스크립트
echo ==================================
echo.

set KEYSTORE_FILE=wsumap-release-key.jks

REM 키스토어가 이미 존재하는지 확인
if exist "%KEYSTORE_FILE%" (
    echo ⚠️  키스토어 파일이 이미 존재합니다: %KEYSTORE_FILE%
    set /p overwrite="기존 키스토어를 덮어쓰시겠습니까? (y/N): "
    if /i not "%overwrite%"=="y" (
        echo ❌ 취소되었습니다.
        exit /b 1
    )
    del /f "%KEYSTORE_FILE%"
)

echo 📝 키스토어 정보를 입력하세요:
echo.

set /p NAME="이름: "
set /p OU="조직 단위 (OU): "
set /p ORG="조직 (O): "
set /p CITY="도시 (L): "
set /p STATE="시/도 (ST): "
set /p COUNTRY="국가 코드 (C, 예: KR): "

echo.
echo 🔑 키스토어 비밀번호를 입력하세요 (6자 이상):
set /p STORE_PASSWORD="비밀번호: "

if "%STORE_PASSWORD%"=="" (
    echo ❌ 비밀번호는 6자 이상이어야 합니다.
    exit /b 1
)

echo 🔑 키 비밀번호를 입력하세요 (키스토어 비밀번호와 동일하게 사용하려면 엔터):
set /p KEY_PASSWORD="비밀번호: "

if "%KEY_PASSWORD%"=="" (
    set KEY_PASSWORD=%STORE_PASSWORD%
)

REM 기본값 설정
if "%NAME%"=="" set NAME=JinYoung Jung
if "%OU%"=="" set OU=YeahJilBae
if "%ORG%"=="" set ORG=YeahJilBae
if "%CITY%"=="" set CITY=Daejeon
if "%STATE%"=="" set STATE=Daejeon
if "%COUNTRY%"=="" set COUNTRY=KR

echo.
echo 생성 중...
echo.

REM keytool 명령어 실행
keytool -genkey -v -keystore "%KEYSTORE_FILE%" ^
    -keyalg RSA -keysize 2048 -validity 10000 ^
    -alias wsumap ^
    -storepass "%STORE_PASSWORD%" ^
    -keypass "%KEY_PASSWORD%" ^
    -dname "CN=%NAME%, OU=%OU%, O=%ORG%, L=%CITY%, ST=%STATE%, C=%COUNTRY%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ 키스토어가 성공적으로 생성되었습니다!
    echo 📁 파일 위치: %CD%\%KEYSTORE_FILE%
    echo.
    
    REM key.properties 파일 생성
    (
        echo storePassword=%STORE_PASSWORD%
        echo keyPassword=%KEY_PASSWORD%
        echo keyAlias=wsumap
        echo storeFile=%KEYSTORE_FILE%
    ) > key.properties
    
    echo ✅ key.properties 파일이 생성되었습니다: key.properties
    echo.
    echo ⚠️  중요: 키스토어 파일과 key.properties 파일을 안전하게 보관하세요!
    echo ⚠️  이 파일들을 잃어버리면 Google Play Store에 업데이트를 배포할 수 없습니다!
) else (
    echo.
    echo ❌ 키스토어 생성에 실패했습니다.
    exit /b 1
)

pause

