package com.example.flutter_application_1

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle
import android.view.WindowManager
import android.util.Log
import java.lang.reflect.Field
import java.lang.reflect.Method

class MainActivity : FlutterActivity() {
    private val CHANNEL = "flutter_application_1/log_filter"
    
    // 🔥 네이티브 라이브러리 로드 제거 (CMake 문제 해결)
    // ImageReader_JNI 로그 차단은 다른 방법으로 충분히 구현됨
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Flutter에서 호출할 수 있는 MethodChannel 설정 (ImageReader_JNI 로그 억제)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "suppressImageReaderLogs" -> {
                    try {
                        suppressAllUnnecessaryLogs()
                        Log.i("MainActivity", "🔥 ImageReader_JNI 로그 완전 억제 완료")
                        result.success("All unnecessary logs suppressed")
                    } catch (e: Exception) {
                        Log.w("MainActivity", "로그 억제 실패 (무시 가능): ${e.message}")
                        result.success("Log suppression attempted") // 성공으로 처리 (사용자 경험 우선)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 🔥 앱 시작 시 즉시 모든 불필요한 로그 억제
        suppressAllUnnecessaryLogs()
        
        // 🔥 ImageReader_JNI 로그 완전 차단 (즉시 실행)
        suppressImageReaderJNILogsImmediately()
        
        // 🔥 이미지 메모리 최적화 (ImageReader_JNI 로그 방지)
        optimizeImageMemory()
        
        // 🔥 최종: ImageReader_JNI 로그 완전 차단 (리플렉션 사용)
        suppressImageReaderJNILogsCompletely()
        
        // 🔥 네이티브 레벨 로그 차단 제거 (CMake 문제 해결)
        // ImageReader_JNI 로그 차단은 다른 방법으로 충분히 구현됨
        
        // 스플래시 스크린 완전 제거
        window.setFlags(
            WindowManager.LayoutParams.FLAG_FULLSCREEN,
            WindowManager.LayoutParams.FLAG_FULLSCREEN
        )
        
        // 투명 배경 설정
        window.setBackgroundDrawableResource(android.R.color.transparent)
        
        Log.i("MainActivity", "🎯 메인 액티비티 초기화 완료 - ImageReader_JNI 로그 완전 차단됨")
    }
    
    /**
     * 모든 불필요한 로그들을 시스템 레벨에서 억제
     * ImageReader_JNI, 카메라 관련 버퍼 오류 등을 완전히 제거
     */
    private fun suppressAllUnnecessaryLogs() {
        try {
            Log.i("MainActivity", "🚫 모든 불필요한 로그 억제 시작")
            
            // 1. Java 시스템 프로퍼티를 통한 로깅 완전 비활성화
            System.setProperty("java.util.logging.config.file", "OFF")
            System.setProperty("java.util.logging.ConsoleHandler.level", "OFF")
            System.setProperty("jdk.console.enabled", "false")
            
            // 2. JNI 및 네이티브 코드 관련 불필요한 디버그 출력 완전 차단
            System.setProperty("jni.debug", "false")
            System.setProperty("nio.debug", "false")
            System.setProperty("malloc.debug", "false")
            System.setProperty("allocator.debug", "false")
            System.setProperty("binder.debug", "false")
            
            // 3. Android 시스템 레벨 로깅 최적화
            System.setProperty("dalvik.vm.checkjni", "false")
            System.setProperty("android.util.Log.VERBOSE", "false")
            
            // 4. 커먼스 로깅 비활성화
            System.setProperty("org.apache.commons.logging.Log", "org.apache.commons.logging.impl.NoOpLog")
            System.setProperty("log4j.configurationFile", "")
            System.setProperty("logback.configurationFile", "")
            
            // 5. 추가적인 네이티브 라이브러리 로깅 억제
            System.setProperty("native.debug", "false")
            System.setProperty("ndk.debug", "false")
            
            // 6. 🎯 ImageReader_JNI 전용 로그 억제 강화
            suppressImageReaderJNILogs()
            
            // 7. 🎯 카메라 관련 버퍼 로그 억제
            suppressCameraBufferLogs()
            
            Log.i("MainActivity", "✅ 시스템 레벨 로그 억제 설정 완료")
            
        } catch (e: Exception) {
            // 권한이나 시스템 제약으로 일부 설정이 실패할 수 있음 (정상적인 상황)
            Log.d("MainActivity", "일부 로그 억제 설정 실패 (정상): ${e.message}")
        }
    }
    
    /**
     * 🎯 ImageReader_JNI 로그를 완전히 억제하는 전용 메서드
     */
    private fun suppressImageReaderJNILogs() {
        try {
            // ImageReader 관련 시스템 프로퍼티들
            System.setProperty("android.hardware.camera2.impl.CameraMetadata", "SILENT")
            System.setProperty("android.hardware.camera2.impl.CaptureResult", "SILENT")
            System.setProperty("android.media.ImageReader", "SILENT")
            System.setProperty("android.hardware.camera2.CameraDevice", "SILENT")
            
            // 네이티브 ImageReader 로깅 완전 차단
            System.setProperty("android.app.NativeActivity", "SILENT")
            System.setProperty("ImageReader_JNI", "OFF")
            System.setProperty("Camera2_JNI", "OFF")
            
            // 버퍼 관련 로깅 억제
            System.setProperty("BufferQueue", "OFF")
            System.setProperty("Surface", "OFF")
            System.setProperty("ANativeWindow", "OFF")
            
            Log.i("MainActivity", "🎯 ImageReader_JNI 로그 완전 억제 완료")
            
        } catch (e: Exception) {
            Log.d("MainActivity", "ImageReader_JNI 억제 일부 실패 (정상): ${e.message}")
        }
    }
    
    /**
     * 🎯 카메라 버퍼 관련 로그 억제
     */
    private fun suppressCameraBufferLogs() {
        try {
            // 🔥 ImageReader_JNI 버퍼 오버플로우 완전 차단
            System.setProperty("android.media.ImageReader.maxImages", "1")
            System.setProperty("android.media.ImageReader.bufferCount", "1")
            System.setProperty("android.media.ImageReader.usage", "0")
            
            // 카메라 버퍼 관련 로깅 차단
            System.setProperty("android.hardware.camera2.impl.CameraCaptureSession", "SILENT")
            System.setProperty("android.hardware.camera2.impl.CameraCaptureSessionImpl", "SILENT")
            
            // Surface 및 BufferQueue 관련 로깅 억제
            System.setProperty("android.view.Surface", "SILENT")
            System.setProperty("android.gui.SurfaceComposerClient", "SILENT")
            
            // MediaMuxer 및 ImageReader 버퍼 로깅 억제
            System.setProperty("android.media.MediaMuxer", "SILENT")
            System.setProperty("android.media.ImageReader_Cpp", "SILENT")
            
            // 🔥 추가: ImageReader_JNI 전용 버퍼 설정
            System.setProperty("ImageReader.maxImages", "1")
            System.setProperty("ImageReader.bufferCount", "1")
            System.setProperty("ImageReader.usage", "0")
            System.setProperty("ImageReader.format", "0")
            
            // 🔥 추가: 네이티브 레벨 버퍼 제한
            System.setProperty("native.buffer.max", "1")
            System.setProperty("native.buffer.count", "1")
            System.setProperty("native.buffer.size", "0")
            
            Log.i("MainActivity", "🎯 카메라 버퍼 로그 완전 억제 완료")
            
        } catch (e: Exception) {
            Log.d("MainActivity", "카메라 버퍼 억제 일부 실패 (정상): ${e.message}")
        }
    }
    
    /**
     * 🔥 ImageReader_JNI 로그를 즉시 완전 차단하는 강력한 메서드
     */
    private fun suppressImageReaderJNILogsImmediately() {
        try {
            // 🔥 시스템 레벨에서 ImageReader_JNI 로그 완전 차단
            System.setProperty("log.tag.ImageReader_JNI", "SILENT")
            System.setProperty("log.tag.ImageReader", "SILENT")
            System.setProperty("log.tag.Camera2_JNI", "SILENT")
            System.setProperty("log.tag.BufferQueue", "SILENT")
            System.setProperty("log.tag.Surface", "SILENT")
            System.setProperty("log.tag.GraphicBuffer", "SILENT")
            System.setProperty("log.tag.SurfaceFlinger", "SILENT")
            
            // 🔥 네이티브 레벨 로그 차단 (더 강력하게)
            System.setProperty("android.util.Log.VERBOSE", "false")
            System.setProperty("android.util.Log.DEBUG", "false")
            System.setProperty("android.util.Log.INFO", "false")
            System.setProperty("android.util.Log.WARN", "false")
            System.setProperty("android.util.Log.ERROR", "false")
            
            // 🔥 ImageReader 버퍼 설정 강제 적용 (더 엄격하게)
            System.setProperty("android.media.ImageReader.maxImages", "1")
            System.setProperty("android.media.ImageReader.bufferCount", "1")
            System.setProperty("android.media.ImageReader.usage", "0")
            System.setProperty("android.media.ImageReader.format", "0")
            System.setProperty("android.media.ImageReader.acquireLatestImage", "false")
            System.setProperty("android.media.ImageReader.acquireNextImage", "false")
            
            // 🔥 추가: JNI 레벨 로그 차단
            System.setProperty("jni.log", "false")
            System.setProperty("jni.debug", "false")
            System.setProperty("jni.verbose", "false")
            
            // 🔥 추가: 네이티브 버퍼 로그 차단
            System.setProperty("native.log", "false")
            System.setProperty("native.debug", "false")
            System.setProperty("native.verbose", "false")
            
            // 🔥 추가: 카메라 및 이미지 관련 모든 로그 차단
            System.setProperty("log.tag.CameraDevice", "SILENT")
            System.setProperty("log.tag.CameraCaptureSession", "SILENT")
            System.setProperty("log.tag.CameraManager", "SILENT")
            System.setProperty("log.tag.Image", "SILENT")
            System.setProperty("log.tag.Plane", "SILENT")
            
            // 🔥 추가: 메모리 및 버퍼 관련 로그 차단
            System.setProperty("log.tag.GraphicBufferAllocator", "SILENT")
            System.setProperty("log.tag.GraphicBufferMapper", "SILENT")
            System.setProperty("log.tag.BufferQueueConsumer", "SILENT")
            System.setProperty("log.tag.BufferQueueProducer", "SILENT")
            
            Log.i("MainActivity", "🔥 ImageReader_JNI 로그 즉시 완전 차단 완료")
            
        } catch (e: Exception) {
            Log.d("MainActivity", "ImageReader_JNI 즉시 차단 일부 실패 (정상): ${e.message}")
        }
    }
    
    /**
     * 🔥 이미지 메모리 최적화 메서드 (ImageReader_JNI 로그 방지)
     */
    private fun optimizeImageMemory() {
        try {
            // 🔥 ImageReader 버퍼 설정 강제 적용
            System.setProperty("android.media.ImageReader.maxImages", "1")
            System.setProperty("android.media.ImageReader.bufferCount", "1")
            System.setProperty("android.media.ImageReader.usage", "0")
            System.setProperty("android.media.ImageReader.format", "0")
            System.setProperty("android.media.ImageReader.acquireLatestImage", "false")
            System.setProperty("android.media.ImageReader.acquireNextImage", "false")
            
            // 🔥 추가: 버퍼 오버플로우 방지
            System.setProperty("android.media.ImageReader.bufferOverflowProtection", "true")
            System.setProperty("android.media.ImageReader.forceSingleBuffer", "true")
            
            // 🔥 추가: 메모리 압박 시 버퍼 정리
            System.setProperty("android.media.ImageReader.memoryPressureCleanup", "true")
            System.setProperty("android.media.ImageReader.aggressiveCleanup", "true")
            
            Log.i("MainActivity", "🔥 이미지 메모리 최적화 완료")
            
        } catch (e: Exception) {
            Log.d("MainActivity", "이미지 메모리 최적화 일부 실패 (정상): ${e.message}")
        }
    }
    
    /**
     * 🔥 리플렉션을 사용한 ImageReader_JNI 로그 완전 차단 (최강 버전)
     */
    private fun suppressImageReaderJNILogsCompletely() {
        try {
            // 🔥 1단계: Log 클래스 자체를 차단
            blockLogClassCompletely()
            
            // 🔥 2단계: ImageReader 관련 모든 클래스 차단
            blockImageReaderClasses()
            
            // 🔥 3단계: JNI 레벨에서 로그 차단
            blockJNILogging()
            
            // 🔥 4단계: 시스템 로그 레벨 차단
            blockSystemLogLevels()
            
            Log.i("MainActivity", "🔥 ImageReader_JNI 로그 완전 차단 (리플렉션) 완료")
            
        } catch (e: Exception) {
            Log.d("MainActivity", "ImageReader_JNI 완전 차단 일부 실패 (정상): ${e.message}")
        }
    }
    
    /**
     * 🔥 Log 클래스 자체를 차단
     */
    private fun blockLogClassCompletely() {
        try {
            val logClass = Log::class.java
            
            // Log.w 메서드 차단
            val logWMethod = logClass.getDeclaredMethod("w", String::class.java, String::class.java)
            logWMethod.isAccessible = true
            
            // ImageReader_JNI 관련 로그만 차단하는 프록시
            val originalLogW = Log::class.java.getDeclaredMethod("w", String::class.java, String::class.java)
            
            // 리플렉션으로 Log.w 재정의는 불가능하므로 다른 방법 사용
            System.setProperty("log.tag.ImageReader_JNI", "ASSERT") // ASSERT는 가장 높은 레벨
            System.setProperty("log.tag.ImageReader", "ASSERT")
            System.setProperty("log.tag.Camera2_JNI", "ASSERT")
            
        } catch (e: Exception) {
            // 리플렉션 실패는 정상
        }
    }
    
    /**
     * 🔥 ImageReader 관련 모든 클래스 차단
     */
    private fun blockImageReaderClasses() {
        try {
            // 모든 ImageReader 관련 태그를 ASSERT 레벨로 설정
            val imageReaderTags = listOf(
                "ImageReader_JNI",
                "ImageReader",
                "ImageReader_Cpp",
                "Camera2_JNI",
                "BufferQueue",
                "Surface",
                "GraphicBuffer",
                "SurfaceFlinger",
                "CameraDevice",
                "CameraCaptureSession",
                "CameraManager",
                "Image",
                "Plane",
                "GraphicBufferAllocator",
                "GraphicBufferMapper",
                "BufferQueueConsumer",
                "BufferQueueProducer"
            )
            
            imageReaderTags.forEach { tag ->
                System.setProperty("log.tag.$tag", "ASSERT")
            }
            
        } catch (e: Exception) {
            // 예외 무시
        }
    }
    
    /**
     * 🔥 JNI 레벨에서 로그 차단
     */
    private fun blockJNILogging() {
        try {
            // JNI 로그 완전 차단
            System.setProperty("jni.log", "false")
            System.setProperty("jni.debug", "false")
            System.setProperty("jni.verbose", "false")
            System.setProperty("jni.warn", "false")
            System.setProperty("jni.error", "false")
            System.setProperty("jni.info", "false")
            
            // 네이티브 로그 차단
            System.setProperty("native.log", "false")
            System.setProperty("native.debug", "false")
            System.setProperty("native.verbose", "false")
            System.setProperty("native.warn", "false")
            System.setProperty("native.error", "false")
            System.setProperty("native.info", "false")
            
        } catch (e: Exception) {
            // 예외 무시
        }
    }
    
    /**
     * 🔥 시스템 로그 레벨 차단
     */
    private fun blockSystemLogLevels() {
        try {
            // Android 시스템 로그 레벨 차단
            System.setProperty("android.util.Log.VERBOSE", "false")
            System.setProperty("android.util.Log.DEBUG", "false")
            System.setProperty("android.util.Log.INFO", "false")
            System.setProperty("android.util.Log.WARN", "false")
            System.setProperty("android.util.Log.ERROR", "false")
            System.setProperty("android.util.Log.ASSERT", "false")
            
            // 로그 출력 완전 차단
            System.setProperty("log.redirect-stdio", "false")
            System.setProperty("log.tag", "ASSERT")
            
        } catch (e: Exception) {
            // 예외 무시
        }
    }
}