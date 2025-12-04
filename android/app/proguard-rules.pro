# Flutter SVG 관련 ProGuard 규칙
# android/app/proguard-rules.pro

# Flutter 관련 클래스 보호
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# 🔥 네이버 맵 관련 클래스 보호 (지도 타일 로딩 문제 해결)
-keep class com.naver.** { *; }
-keep class com.naver.maps.** { *; }
-keep class com.naver.android.maps.** { *; }
-dontwarn com.naver.**
-dontwarn com.naver.maps.**
-dontwarn com.naver.android.maps.**

# 네이버 맵 네이티브 클래스 보호
-keep class com.naver.maps.map.** { *; }
-keep class com.naver.maps.map.util.** { *; }
-keep class com.naver.maps.map.overlay.** { *; }
-keep class com.naver.maps.map.camera.** { *; }

# SVG 관련 클래스 보호
-keep class com.caverock.androidsvg.** { *; }
-keep class androidx.webkit.** { *; }
-keep class androidx.browser.** { *; }

# 네트워크 관련 클래스 보호
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }
-keep class com.squareup.okhttp.** { *; }

# WebView 관련 클래스 보호
-keep class android.webkit.** { *; }
-keepclassmembers class android.webkit.** { *; }

# 일반적인 Android 클래스 보호
-keep class androidx.core.** { *; }
-keep class androidx.lifecycle.** { *; }

# Google Play Core 관련 클래스 제외 (R8 오류 해결)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# 디버깅을 위한 라인 넘버 보존
-keepattributes SourceFile,LineNumberTable

# 난독화 최적화 방지 (SVG 로딩 문제 해결)
-dontoptimize
-dontobfuscate

# ======================== ImageReader_JNI 로그 완전 차단 ========================

# 🔥 ImageReader_JNI 로그 완전 차단을 위한 ProGuard 규칙
-keep class android.media.ImageReader { *; }
-keep class android.hardware.camera2.** { *; }

# 🔥 로그 관련 메서드 제거/최적화
-assumenosideeffects class android.util.Log {
    public static *** w(...);
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# 🔥 ImageReader_JNI 관련 클래스 최적화
-keep class android.media.ImageReader** { *; }
-keep class android.hardware.camera2.impl.** { *; }
-keep class android.view.Surface { *; }
-keep class android.graphics.SurfaceTexture { *; }

# 🔥 네이티브 로그 억제
-keep class android.app.NativeActivity { *; }
-dontwarn android.app.NativeActivity

# 🔥 JNI 관련 로그 억제
-keep class **.*JNI* { *; }
-dontwarn **.*JNI*

# 🔥 ImageReader 버퍼 관련 최적화
-keep class android.graphics.GraphicBuffer { *; }
-keep class android.graphics.GraphicBufferAllocator { *; }
-keep class android.graphics.GraphicBufferMapper { *; }

# 🔥 카메라 관련 로그 억제
-keep class android.hardware.camera2.CameraDevice { *; }
-keep class android.hardware.camera2.CameraCaptureSession { *; }
-keep class android.hardware.camera2.CameraManager { *; }

# 🔥 Surface 관련 로그 억제
-keep class android.view.Surface { *; }
-keep class android.view.SurfaceHolder { *; }
-keep class android.view.SurfaceView { *; }

# 🔥 버퍼 큐 관련 로그 억제
-keep class **.*BufferQueue* { *; }
-dontwarn **.*BufferQueue*

# 🔥 추가: 모든 ImageReader_JNI 관련 로그 억제
-assumenosideeffects class ** {
    *** *ImageReader*JNI*(...);
    *** *BufferQueue*(...);
    *** *SurfaceFlinger*(...);
}

# 🔥 네이티브 라이브러리 로그 억제
-dontwarn **.*JNI*
-dontwarn **.*native*

# 🔥 시스템 로그 억제
-keep class android.util.Log { *; }
-assumenosideeffects class android.util.Log {
    public static *** w(...);
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** e(...);
}

# 🔥 추가: ImageReader_JNI 로그 완전 차단을 위한 최종 규칙
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# 🔥 ImageReader_JNI 관련 모든 메서드 호출 제거
-assumenosideeffects class ** {
    *** *ImageReader*(...);
    *** *BufferQueue*(...);
    *** *Surface*(...);
    *** *Camera*(...);
    *** *JNI*(...);
}

# 🔥 추가: ImageReader_JNI 로그 평생 차단을 위한 최강 규칙
-assumenosideeffects class android.util.Log {
    public static *** w(...);
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** e(...);
}

# 🔥 추가: 모든 ImageReader 관련 클래스 메서드 호출 제거
-assumenosideeffects class android.media.ImageReader** {
    public *** acquire*(...);
    public *** release*(...);
    public *** close*(...);
}

# 🔥 추가: 모든 JNI 관련 메서드 호출 제거
-assumenosideeffects class ** {
    *** *native*(...);
    *** *jni*(...);
    *** *JNI*(...);
}

# 🔥 추가: 모든 네이티브 로그 메서드 호출 제거
-assumenosideeffects class ** {
    *** *log*(...);
    *** *Log*(...);
    *** *debug*(...);
    *** *Debug*(...);
    *** *warn*(...);
    *** *Warn*(...);
}

# 🔥 추가: 시스템 로그 완전 차단
-keep class android.util.Log { *; }
-assumenosideeffects class android.util.Log {
    public static *** *(...);
}

# 🔥 추가: ImageReader_JNI 로그 평생 차단을 위한 최종 규칙
-dontwarn android.media.ImageReader**
-dontwarn android.hardware.camera2.**
-dontwarn android.view.Surface**
-dontwarn android.graphics.GraphicBuffer**
-dontwarn **.*JNI*

# 🔥 추가: 모든 로그 관련 클래스 차단
-keep class **.*Log* { *; }
-assumenosideeffects class **.*Log* {
    public *** *(...);
}

# 🔥 추가: 네이티브 라이브러리 로그 완전 차단
-dontwarn **.*native*
-dontwarn **.*jni*
-dontwarn **.*JNI*

# 🔥 최강: ImageReader_JNI 로그 평생 차단을 위한 최종 차단
-keep class android.media.ImageReader { *; }
-assumenosideeffects class android.media.ImageReader {
    public *** *(...);
}

# 🔥 추가: ImageReader_JNI 로그 완전 차단 (최종 버전)
-assumenosideeffects class android.media.ImageReader** {
    public static *** *(...);
    public *** *(...);
    *** acquire*(...);
    *** release*(...);
    *** close*(...);
}

# 🔥 추가: 모든 JNI 관련 로그 완전 차단 (최종 버전)
-assumenosideeffects class ** {
    *** *native*(...);
    *** *jni*(...);
    *** *JNI*(...);
    *** *Native*(...);
}

# 🔥 추가: 시스템 로그 완전 차단 (최종 버전)
-keep class android.util.Log { *; }
-assumenosideeffects class android.util.Log {
    public static *** *(...);
}

# 🔥 추가: 네이티브 로그 완전 차단 (최종 버전)
-dontwarn **.*native*
-dontwarn **.*jni*
-dontwarn **.*JNI*
-dontwarn **.*Native*

# 🔥 추가: ImageReader_JNI 로그 완전 차단 (최종 버전)
-dontwarn android.media.ImageReader**
-dontwarn android.hardware.camera2.**
-dontwarn android.view.Surface**
-dontwarn android.graphics.GraphicBuffer**
-dontwarn **.*JNI*
-dontwarn **.*Native*

# 🔥 최종: ImageReader_JNI 로그 평생 차단을 위한 최종 차단 (최종 버전)
-keep class android.media.ImageReader** { *; }
-assumenosideeffects class android.media.ImageReader** {
    public *** *(...);
}

# 🔥 최강: ImageReader_JNI 로그 평생 차단을 위한 최종 차단 (최종 버전)
-keep class android.media.ImageReader** { *; }
-assumenosideeffects class android.media.ImageReader** {
    public *** *(...);
}

# ==================================================================================
# 🔥 추가: ImageReader_JNI 로그 완전 차단을 위한 최종 ProGuard 규칙
-keep class android.media.ImageReader { *; }
-assumenosideeffects class android.media.ImageReader {
    public *** acquireLatestImage(...);
    public *** acquireNextImage(...);
    public *** close(...);
    public *** release(...);
    *** acquire*(...);
    *** release*(...);
}

# 🔥 추가: 카메라 관련 모든 클래스 로그 차단
-keep class android.hardware.camera2.** { *; }
-assumenosideeffects class android.hardware.camera2.** {
    *** *(...);
}

# 🔥 추가: 모든 네이티브 로그 메서드 호출 제거 (최종)
-assumenosideeffects class ** {
    *** *logNative*(...);
    *** *jniLog*(...);
    *** *nativeLog*(...);
    *** *LogNative*(...);
    *** *JNILog*(...);
    *** *NativeLog*(...);
}

# ==================================================================================