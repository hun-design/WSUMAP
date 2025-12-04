plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

// 키스토어 설정 파일 읽기
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = mutableMapOf<String, String>()

// 키스토어 값을 직접 변수로 저장 (Map 조회 문제 회피)
var keyAliasValue = ""
var keyPasswordValue = ""
var storeFileName = ""
var storePasswordValue = ""

if (keystorePropertiesFile.exists()) {
    try {
        val lines = keystorePropertiesFile.readLines()
        lines.forEach { line ->
            val trimmedLine = line.trim()
            // 빈 줄이나 주석(#으로 시작) 건너뛰기
            if (trimmedLine.isNotEmpty() && !trimmedLine.startsWith("#")) {
                val parts = trimmedLine.split("=", limit = 2)
                if (parts.size == 2) {
                    // BOM 문자 제거 (UTF-8 BOM: 0xFEFF = 65279)
                    var key = parts[0].trim().replace("\uFEFF", "").trim()
                    val value = parts[1].trim()
                    if (key.isNotEmpty() && value.isNotEmpty()) {
                        keystoreProperties[key] = value
                        // 직접 변수에도 저장 (대소문자 구분 없이 매칭)
                        when (key.lowercase()) {
                            "storepassword" -> {
                                storePasswordValue = value
                                println("   ✅ storePassword 변수에 저장됨: 길이 ${value.length}")
                            }
                            "keypassword" -> {
                                keyPasswordValue = value
                                println("   ✅ keyPassword 변수에 저장됨: 길이 ${value.length}")
                            }
                            "keyalias" -> {
                                keyAliasValue = value
                                println("   ✅ keyAlias 변수에 저장됨: 길이 ${value.length}")
                            }
                            "storefile" -> {
                                storeFileName = value
                                println("   ✅ storeFile 변수에 저장됨: 길이 ${value.length}")
                            }
                            else -> {
                                println("   ⚠️ 알 수 없는 키: '$key' (길이: ${key.length})")
                            }
                        }
                        println("   ✅ 읽음: $key = ${if (key.contains("Password", ignoreCase = true)) "***" else value}")
                    }
                }
            }
        }
    } catch (e: Exception) {
        println("⚠️ 키스토어 파일 읽기 오류: ${e.message}")
    }
    
    // 디버그: 읽은 값 확인
    println("🔑 키스토어 설정 로드 완료:")
    println("   - 총 ${keystoreProperties.size}개 항목 로드됨")
    println("   - 키 목록: ${keystoreProperties.keys.joinToString(", ")}")
    
    // 모든 키-값 쌍 상세 출력
    keystoreProperties.forEach { (key, value) ->
        println("   - [$key] = \"$value\" (길이: ${value.length})")
    }
    
    println("🔑 직접 변수 값:")
    println("   - keyAliasValue: '$keyAliasValue' (길이: ${keyAliasValue.length})")
    println("   - keyPasswordValue: '${keyPasswordValue.take(3)}...' (길이: ${keyPasswordValue.length})")
    println("   - storeFileName: '$storeFileName' (길이: ${storeFileName.length})")
    println("   - storePasswordValue: '${storePasswordValue.take(3)}...' (길이: ${storePasswordValue.length})")
}

android {
    namespace = "com.woosong.wsumap"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.woosong.wsumap"  // TODO: 배포 시 고유한 패키지 이름으로 변경 (예: com.woosong.wsumap)
        minSdk = 23  // flutter_naver_map 플러그인 요구사항에 맞춰 23으로 변경
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
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

    // 키스토어 설정 - 직접 변수 사용 (Map 조회 문제 회피)
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists() && 
                keyAliasValue.isNotEmpty() && keyPasswordValue.isNotEmpty() && 
                storeFileName.isNotEmpty() && storePasswordValue.isNotEmpty()) {
                val storeFilePath = rootProject.file(storeFileName)
                if (storeFilePath.exists()) {
                    keyAlias = keyAliasValue
                    keyPassword = keyPasswordValue
                    storeFile = storeFilePath
                    storePassword = storePasswordValue
                    println("✅ Release 키스토어 설정 완료: ${storeFilePath.absolutePath}")
                } else {
                    println("⚠️ 키스토어 파일을 찾을 수 없습니다: ${storeFilePath.absolutePath}")
                }
            } else {
                println("⚠️ 키스토어 설정을 사용할 수 없습니다.")
                println("   - 파일 존재: ${keystorePropertiesFile.exists()}")
                println("   - keyAlias: ${if (keyAliasValue.isEmpty()) "비어있음" else "있음(${keyAliasValue.length}자)"}")
                println("   - keyPassword: ${if (keyPasswordValue.isEmpty()) "비어있음" else "있음(${keyPasswordValue.length}자)"}")
                println("   - storeFile: ${if (storeFileName.isEmpty()) "비어있음" else "있음(${storeFileName.length}자)"}")
                println("   - storePassword: ${if (storePasswordValue.isEmpty()) "비어있음" else "있음(${storePasswordValue.length}자)"}")
            }
        }
    }

    buildTypes {
        getByName("release") {
            // 키스토어 파일이 있으면 release 키스토어 사용, 없으면 debug 키스토어 사용
            if (keystorePropertiesFile.exists() && keystoreProperties.isNotEmpty()) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                signingConfig = signingConfigs.getByName("debug")
                println("⚠️ WARNING: key.properties 파일이 없거나 비어있습니다. debug 키스토어로 서명합니다.")
                println("⚠️ Google Play Store 배포를 위해서는 release 키스토어가 필요합니다.")
                println("⚠️ APP_DEPLOYMENT_GUIDE.md를 참고하여 키스토어를 생성하세요.")
            }
            // R8 설정 (최적화 비활성화로 강제종료 문제 해결)
            // 임시로 minifyEnabled 비활성화 - 강제종료 문제 해결 후 다시 활성화 가능
            isMinifyEnabled = false
            isShrinkResources = false  // minifyEnabled가 false일 때는 반드시 false로 설정
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            
            // 🔥 ImageReader_JNI 로그 완전 차단을 위한 추가 설정
            buildConfigField("boolean", "SUPPRESS_IMAGEREADER_LOGS", "true")
            buildConfigField("boolean", "SUPPRESS_NATIVE_LOGS", "true")
            buildConfigField("boolean", "SUPPRESS_JNI_LOGS", "true")
            
            // 🔥 로그 레벨을 ERROR로 제한 (WARN 로그 차단)
            buildConfigField("String", "LOG_LEVEL", "\"ERROR\"")
        }
        getByName("debug") {
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
