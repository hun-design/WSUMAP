// lib/components/woosong_button.dart - 네이티브 버튼처럼 즉시 반응하는 버튼
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WoosongButton extends StatefulWidget {
  final VoidCallback? onPressed; // null 허용으로 변경
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
  State<WoosongButton> createState() => _WoosongButtonState();
}

class _WoosongButtonState extends State<WoosongButton> {
  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ElevatedButton(
        onPressed: isEnabled ? () {
          // 🔥 즉시 햅틱 피드백
          HapticFeedback.lightImpact();
          // 🔥 즉시 실행
          widget.onPressed?.call();
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isOutlined
              ? Colors.transparent
              : widget.isPrimary
                  ? (isEnabled
                      ? const Color(0xFF1E3A8A)
                      : const Color(0xFFE2E8F0))
                  : (isEnabled
                      ? const Color(0xFF64748B)
                      : const Color(0xFFE2E8F0)),
          foregroundColor: widget.isOutlined
              ? (isEnabled 
                  ? const Color(0xFF1E3A8A)
                  : const Color(0xFFCBD5E1))
              : (isEnabled 
                  ? Colors.white
                  : const Color(0xFF94A3B8)),
          elevation: widget.isOutlined || !isEnabled ? 0 : 8,
          shadowColor: const Color(0xFF1E3A8A).withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: widget.isOutlined
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
            color: widget.isOutlined
                ? (isEnabled 
                    ? const Color(0xFF1E3A8A)
                    : const Color(0xFFCBD5E1))
                : (isEnabled 
                    ? Colors.white
                    : const Color(0xFF94A3B8)),
            letterSpacing: -0.2,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}