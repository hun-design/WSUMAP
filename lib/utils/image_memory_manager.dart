// lib/utils/image_memory_manager.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/painting.dart';

/// 🔥 ImageReader_JNI 로그 방지를 위한 이미지 메모리 관리 클래스
class ImageMemoryManager {
  static final ImageMemoryManager _instance = ImageMemoryManager._internal();
  factory ImageMemoryManager() => _instance;
  ImageMemoryManager._internal();

  // 🔥 이미지 캐시 최적화 설정
  static const int _maxCacheSize = 50 * 1024 * 1024; // 50MB
  static const int _maxCacheObjects = 100;
  
  /// 🔥 이미지 메모리 최적화 초기화
  static Future<void> initializeImageOptimization() async {
    try {
      if (Platform.isAndroid) {
        // 🔥 Android 전용 이미지 메모리 최적화
        await _optimizeAndroidImageMemory();
      }
      
      if (kDebugMode) {
        debugPrint('🖼️ 이미지 메모리 최적화 초기화 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ 이미지 메모리 최적화 초기화 실패: $e');
      }
    }
  }
  
  /// 🔥 Android 이미지 메모리 최적화
  static Future<void> _optimizeAndroidImageMemory() async {
    try {
      const platform = MethodChannel('com.example.flutter_application_1/image_memory');
      
      await platform.invokeMethod('optimizeImageMemory', {
        'maxCacheSize': _maxCacheSize,
        'maxCacheObjects': _maxCacheObjects,
        'enableBufferOptimization': true,
        'suppressImageReaderLogs': true,
      });
      
      if (kDebugMode) {
        debugPrint('🔥 Android 이미지 메모리 최적화 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Android 이미지 메모리 최적화 실패: $e');
      }
    }
  }
  
  /// 🔥 이미지 캐시 정리
  static void clearImageCache() {
    try {
      // Flutter 이미지 캐시 정리
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      
      if (kDebugMode) {
        debugPrint('🧹 이미지 캐시 정리 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ 이미지 캐시 정리 실패: $e');
      }
    }
  }
  
  /// 🔥 메모리 압박 시 이미지 캐시 정리
  static void onMemoryPressure() {
    try {
      // 메모리 압박 시 캐시 크기 감소
      PaintingBinding.instance.imageCache.maximumSize = 50;
      PaintingBinding.instance.imageCache.maximumSizeBytes = 25 * 1024 * 1024; // 25MB
      
      // 기존 캐시 정리
      clearImageCache();
      
      if (kDebugMode) {
        debugPrint('🚨 메모리 압박으로 인한 이미지 캐시 정리');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ 메모리 압박 처리 실패: $e');
      }
    }
  }
  
  /// 🔥 이미지 로딩 최적화 설정
  static Map<String, dynamic> getOptimizedImageSettings({
    int? width,
    int? height,
  }) {
    return {
      'cacheWidth': width ?? 400,
      'cacheHeight': height ?? 300,
      'filterQuality': FilterQuality.low,
      'isAntiAlias': false,
      'headers': {
        'Cache-Control': 'max-age=3600',
      },
    };
  }
}
