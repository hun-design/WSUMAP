# FolloWoosong Campus Navigator (따라우송 캠퍼스 네비게이터)

우송대학교를 위한 스마트 캠퍼스 네비게이션 앱입니다. 학생, 교수, 방문자들이 캠퍼스를 쉽게 탐색할 수 있도록 도와줍니다.

## 주요 기능

### 🗺️ 통합 지도 시스템
- **Naver Map 기반 실외 네비게이션**: 건물 간 최적 경로 안내
- **실내 지도**: 건물 내부 층별 상세 지도 및 길찾기
- **통합 네비게이션**: 실내외 연계 경로 안내

### 👥 소셜 기능
- **실시간 친구 위치 공유**: WebSocket 기반 실시간 위치 추적
- **친구 관리**: 친구 추가, 위치 공유 설정
- **그룹 네비게이션**: 친구와 함께하는 길찾기

### 📅 시간표 관리
- **Excel 파일 업로드**: 우송대 시간표 시스템 연동
- **자동 경로 안내**: 다음 수업까지의 최적 경로 제공
- **수업 알림**: 수업 시간 기반 스마트 알림

### 🏢 건물 및 시설 정보
- **상세 건물 정보**: 각 건물의 시설, 층별 안내
- **실시간 운영 상태**: 시설 운영 시간 및 상태 표시
- **카테고리별 검색**: 편의시설, 강의실, 연구실 등 카테고리별 검색

### 🌐 다국어 지원
- **6개 언어 지원**: 한국어, English, 日本語, 中文, Español, Русский
- **언어유희 번역**: "따라우송" → "FolloWoosong" 등 창의적 번역

## 기술 스택

### Frontend
- **Flutter 3.8.1+**: 크로스플랫폼 모바일 앱 개발
- **Provider**: 상태 관리
- **flutter_naver_map**: 네이버 지도 통합

### Backend & Services
- **WebSocket**: 실시간 통신
- **REST API**: 서버 통신
- **SharedPreferences**: 로컬 데이터 저장

### 주요 라이브러리
```yaml
dependencies:
  flutter_naver_map: ^1.2.4
  location: ^6.0.2
  provider: ^6.1.2
  shared_preferences: ^2.2.3
  connectivity_plus: ^6.0.3
  web_socket_channel: ^2.4.5
  http: ^1.2.1
  excel: ^4.0.6
  image_picker: ^1.1.2
```

## 아키텍처

### 📁 프로젝트 구조
```
lib/
├── auth/              # 인증 관련
├── controllers/       # 비즈니스 로직 컨트롤러
├── core/             # 핵심 유틸리티 (새로 추가)
│   ├── base_controller.dart
│   ├── error_handler.dart
│   └── result.dart
├── services/         # API 및 비즈니스 서비스
├── models/           # 데이터 모델
├── map/              # 지도 관련 기능
├── widgets/          # 공통 UI 컴포넌트 (새로 추가)
├── utils/            # 유틸리티 함수 (새로 추가)
└── generated/        # 자동 생성 파일
```

### 🏗️ 아키텍처 패턴
- **Provider Pattern**: 상태 관리
- **Repository Pattern**: 데이터 계층 추상화
- **Service Layer**: 비즈니스 로직 분리
- **Error Handling**: 통합 에러 처리 시스템

## 최근 개선사항 (2024.09.19)

### 🚀 성능 최적화
- **병렬 초기화**: 앱 시작 시 병렬 처리로 로딩 시간 단축
- **Debouncing**: UI 업데이트 최적화로 60fps 유지
- **메모리 관리**: 효율적인 리소스 관리 및 자동 정리
- **배치 처리**: 네트워크 요청 및 UI 업데이트 배치화

### 🛠️ 코드 품질 개선
- **BaseController**: 모든 컨트롤러의 기본 클래스로 중복 코드 제거
- **ErrorHandler**: 통합 에러 처리 시스템 구축
- **PerformanceUtils**: 성능 모니터링 및 최적화 도구
- **CommonWidgets**: 재사용 가능한 UI 컴포넌트 라이브러리

### 🐛 안정성 향상
- **Null Safety**: 완전한 null safety 적용
- **예외 처리**: 견고한 예외 처리 메커니즘
- **메모리 누수 방지**: 적절한 리소스 해제
- **네트워크 복구**: 자동 재연결 및 재시도 로직

### 🌍 국제화 개선
- **언어유희 번역**: 창의적이고 현지화된 번역
- **번역 품질**: 모든 언어의 번역 품질 향상

## 설치 및 실행

### 요구사항
- Flutter SDK 3.8.1 이상
- Dart SDK 3.0.0 이상
- Android Studio / VS Code
- Android SDK (Android 개발 시)
- Xcode (iOS 개발 시)

### 설치 방법
1. **프로젝트 클론**
   ```bash
   git clone https://github.com/WSU-YJB/WSUMAP.git
   cd WSUMAP
   ```

2. **의존성 설치**
   ```bash
   flutter pub get
   ```

3. **네이버 지도 API 키 설정**
   - 네이버 클라우드 플랫폼에서 API 키 발급
   - `lib/main.dart`에서 clientId 설정

4. **앱 실행**
   ```bash
   flutter run
   ```

### 빌드
```bash
# Android APK 빌드
flutter build apk --release

# iOS 빌드
flutter build ios --release
```

## 개발팀

**Team WSU-YJB**
- 정진영 (Jung Jin-young)
- 박철현 (Park Cheol-hyun) 
- 조현준 (Cho Hyun-jun)
- 최성열 (Choi Seong-yeol)
- 한승헌 (Han Seung-heon)
- 이예은 (Lee Ye-eun)

**연락처**: wsumap41@gmail.com  
**GitHub**: [github.com/WSU-YJB/WSUMAP](https://github.com/WSU-YJB/WSUMAP)

## 라이선스

이 프로젝트는 우송대학교의 교육 목적으로 개발되었습니다.

---

*Woosong University Smart Campus Navigator - Making campus navigation intelligent and accessible.*
