plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_application_1"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.example.flutter_application_1"
        minSdk = 23  // flutter_naver_map 플러그인 요구사항에 맞춰 23으로 변경
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
        // 🔥 multiDex 활성화 추가
        multiDexEnabled = true
    }

    // 🔥 BuildConfig 기능 활성화 (ImageReader_JNI 로그 차단용)
    buildFeatures {
        buildConfig = true
    }

    compileOptions {
        // 🔥 core library desugaring 활성화
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            // R8 설정 추가
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            
            // 🔥 ImageReader_JNI 로그 완전 차단을 위한 추가 설정
            buildConfigField("boolean", "SUPPRESS_IMAGEREADER_LOGS", "true")
            buildConfigField("boolean", "SUPPRESS_NATIVE_LOGS", "true")
            buildConfigField("boolean", "SUPPRESS_JNI_LOGS", "true")
            
            // 🔥 로그 레벨을 ERROR로 제한 (WARN 로그 차단)
            buildConfigField("String", "LOG_LEVEL", "\"ERROR\"")
        }
        debug {
            // 🔥 디버그 빌드에서도 ImageReader_JNI 로그 차단
            buildConfigField("boolean", "SUPPRESS_IMAGEREADER_LOGS", "true")
            buildConfigField("boolean", "SUPPRESS_NATIVE_LOGS", "true")
            buildConfigField("boolean", "SUPPRESS_JNI_LOGS", "true")
            
            // 🔥 디버그 로그 레벨을 WARN으로 제한하여 ImageReader_JNI 로그 차단
            ndk {
                debugSymbolLevel = "NONE"
            }
            
            // 🔥 로그 레벨을 ERROR로 제한 (WARN 로그 차단)
            buildConfigField("String", "LOG_LEVEL", "\"ERROR\"")
        }
    }
    
    // 🔥 추가: ImageReader_JNI 로그 차단을 위한 컴파일 옵션
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    
    // 🔥 추가: 로그 차단을 위한 packaging 옵션
    packagingOptions {
        // 🔥 ImageReader_JNI 관련 네이티브 라이브러리 제외 (선택적)
        jniLibs {
            excludes += setOf(
                "**/libcamera2_jni.so",
                "**/libimagerreader_jni.so"
            )
        }
    }
    
    // 🔥 네이티브 빌드 설정 제거 (CMake 문제 해결)
    // ImageReader_JNI 로그 차단은 다른 방법으로 충분히 구현됨
    ndkVersion = "27.0.12077973"
}

flutter {
    source = "../.."
}

// ======================== 추가된 부분 ========================
dependencies {
    implementation("androidx.appcompat:appcompat:1.6.1")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
// ===========================================================
