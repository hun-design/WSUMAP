// lib/components/woosong_button.dart - null 허용하도록 수정
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

class _WoosongButtonState extends State<WoosongButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: isEnabled ? (_) {
            HapticFeedback.lightImpact();
            _animationController.forward();
          } : null,
          onTapUp: isEnabled ? (_) => _animationController.reverse() : null,
          onTapCancel: isEnabled ? () => _animationController.reverse() : null,
          onTap: widget.onPressed,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: widget.isOutlined
                  ? null
                  : widget.isPrimary
                      ? LinearGradient(
                          colors: isEnabled
                              ? [
                                  const Color(0xFF1E3A8A), // 우송대 진한 남색
                                  const Color(0xFF3B82F6), // 밝은 남색
                                ]
                              : [
                                  const Color(0xFFE2E8F0), // 비활성화 색상
                                  const Color(0xFFCBD5E1),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: isEnabled
                              ? [
                                  const Color(0xFF64748B),
                                  const Color(0xFF475569),
                                ]
                              : [
                                  const Color(0xFFE2E8F0),
                                  const Color(0xFFCBD5E1),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
              color: widget.isOutlined ? Colors.transparent : null,
              borderRadius: BorderRadius.circular(16),
              border: widget.isOutlined
                  ? Border.all(
                      color: isEnabled 
                          ? const Color(0xFF1E3A8A)
                          : const Color(0xFFCBD5E1),
                      width: 2,
                    )
                  : null,
              boxShadow: widget.isOutlined || !isEnabled
                  ? null
                  : [
                      BoxShadow(
                        color: const Color(0xFF1E3A8A).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Center(
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
          ),
        ),
      ),
    );
  }
}