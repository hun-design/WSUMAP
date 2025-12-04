# 키스토어 생성 가이드

Windows PowerShell에서 keytool 대화형 입력 문제를 해결하는 방법입니다.

## 🔧 문제 해결

Windows PowerShell에서 keytool을 실행할 때 "이(가) 맞습니까?" 질문에 답변해도 계속 다시 물어보는 문제가 발생할 수 있습니다.

## ✅ 해결 방법

### 방법 1: 배치 파일 사용 (권장)

`create-keystore.bat` 파일을 실행하세요:

```powershell
cd WSUMAP\android
.\create-keystore.bat
```

### 방법 2: 명령어에 모든 옵션 직접 입력

대화형 입력 없이 모든 정보를 명령어에 직접 입력하는 방법:

```powershell
cd WSUMAP\android

# 모든 정보를 명령어에 직접 입력
keytool -genkey -v -keystore wsumap-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias wsumap -storepass "여기에_비밀번호_입력" -keypass "여기에_키_비밀번호_입력" -dname "CN=JinYoung Jung, OU=YeahJilBae, O=YeahJilBae, L=Daejeon, ST=Daejeon, C=KR"
```

**예시** (비밀번호를 `MyPassword123`로 사용하는 경우):
```powershell
keytool -genkey -v -keystore wsumap-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias wsumap -storepass "MyPassword123" -keypass "MyPassword123" -dname "CN=JinYoung Jung, OU=YeahJilBae, O=YeahJilBae, L=Daejeon, ST=Daejeon, C=KR"
```

### 방법 3: 한 번에 실행 (PowerShell 스크립트)

PowerShell에서 다음 명령어를 실행하세요:

```powershell
cd WSUMAP\android

$storePassword = "여기에_비밀번호_입력"
$keyPassword = $storePassword  # 같은 비밀번호 사용

keytool -genkey -v -keystore wsumap-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias wsumap -storepass $storePassword -keypass $keyPassword -dname "CN=JinYoung Jung, OU=YeahJilBae, O=YeahJilBae, L=Daejeon, ST=Daejeon, C=KR"
```

## 📝 key.properties 파일 생성

키스토어 생성 후 `key.properties` 파일을 생성해야 합니다:

```powershell
cd WSUMAP\android

# key.properties 파일 생성
@"
storePassword=여기에_비밀번호_입력
keyPassword=여기에_키_비밀번호_입력
keyAlias=wsumap
storeFile=wsumap-release-key.jks
"@ | Out-File -FilePath key.properties -Encoding utf8
```

**예시** (비밀번호를 `MyPassword123`로 사용하는 경우):
```powershell
@"
storePassword=MyPassword123
keyPassword=MyPassword123
keyAlias=wsumap
storeFile=wsumap-release-key.jks
"@ | Out-File -FilePath key.properties -Encoding utf8
```

## ⚠️ 중요 사항

1. **비밀번호는 6자 이상**이어야 합니다
2. **키스토어 파일과 비밀번호를 안전하게 보관**하세요
3. **key.properties 파일도 안전하게 보관**하세요
4. 이 파일들을 잃어버리면 Google Play Store에 업데이트를 배포할 수 없습니다!

## 🔍 키스토어 확인

키스토어가 제대로 생성되었는지 확인:

```powershell
keytool -list -v -keystore wsumap-release-key.jks
```

비밀번호를 입력하면 키스토어 정보가 표시됩니다.

