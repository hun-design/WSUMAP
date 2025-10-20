// lib/components/woosong_button.dart - 네이티브 버튼처럼 즉시 반응하는 버튼
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 우송대학교 테마 버튼 컴포넌트
class WoosongButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isPrimary;
  final bool isOutlined;

  const WoosongButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isPrimary = true,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ElevatedButton(
        onPressed: isEnabled ? () {
          HapticFeedback.lightImpact();
          onPressed?.call();
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(isEnabled),
          foregroundColor: _getForegroundColor(isEnabled),
          elevation: isOutlined || !isEnabled ? 0 : 8,
          shadowColor: const Color(0xFF1E3A8A).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isOutlined
                ? BorderSide(
                    color: isEnabled 
                        ? const Color(0xFF1E3A8A)
                        : const Color(0xFFCBD5E1),
                    width: 2,
                  )
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 56),
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _getForegroundColor(isEnabled),
            letterSpacing: -0.2,
          ),
          child: child,
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isEnabled) {
    if (isOutlined) return Colors.transparent;
    if (!isEnabled) return const Color(0xFFE2E8F0);
    return isPrimary ? const Color(0xFF1E3A8A) : const Color(0xFF64748B);
  }

  Color _getForegroundColor(bool isEnabled) {
    if (isOutlined) {
      return isEnabled ? const Color(0xFF1E3A8A) : const Color(0xFFCBD5E1);
    }
    return isEnabled ? Colors.white : const Color(0xFF94A3B8);
  }
}