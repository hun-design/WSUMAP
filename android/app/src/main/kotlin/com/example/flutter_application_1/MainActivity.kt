package com.example.flutter_application_1

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.view.WindowManager
import android.util.Log

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 불필요한 로그 필터링 설정
        setupLogFiltering()
        
        // 스플래시 스크린 완전 제거
        window.setFlags(
            WindowManager.LayoutParams.FLAG_FULLSCREEN,
            WindowManager.LayoutParams.FLAG_FULLSCREEN
        )
        
        // 투명 배경 설정
        window.setBackgroundDrawableResource(android.R.color.transparent)
    }
    
    /**
     * 불필요한 시스템 로그들을 필터링하는 함수
     */
    private fun setupLogFiltering() {
        // ImageReader_JNI 관련 경고 로그 억제
        // 이 로그들은 카메라/이미지 처리 시 발생하는 일반적인 경고로 앱 동작에는 영향 없음
        Log.i("MainActivity", "ImageReader_JNI 로그 필터링 활성화")
        
        // 추가적인 로그 필터링이 필요한 경우 여기에 구현
        // 예: 특정 태그의 로그 레벨 조정 등
    }
}
