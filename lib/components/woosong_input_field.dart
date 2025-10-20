// lib/components/woosong_input_field.dart - 개선된 버전
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 우송대학교 테마 입력 필드 컴포넌트
class WoosongInputField extends StatefulWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final String? hint;
  final TextInputType? keyboardType;
  final bool enabled;
  final Function(String)? onSubmitted;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;

  const WoosongInputField({
    super.key,
    required this.icon,
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.hint,
    this.keyboardType,
    this.enabled = true,
    this.onSubmitted,
    this.maxLines = 1,
    this.inputFormatters,
  });

  @override
  State<WoosongInputField> createState() => _WoosongInputFieldState();
}

class _WoosongInputFieldState extends State<WoosongInputField> {
  bool isFocused = false;
  late bool isObscured;

  @override
  void initState() {
    super.initState();
    isObscured = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(),
          const SizedBox(height: 8),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildLabel() {
    return Text(
      widget.label,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: widget.enabled 
            ? const Color(0xFF1E3A8A)
            : const Color(0xFF94A3B8),
      ),
    );
  }

  Widget _buildInputField() {
    return Focus(
      onFocusChange: (focus) => setState(() => isFocused = focus),
      child: Container(
        decoration: _buildDecoration(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField()),
              if (widget.isPassword) _buildPasswordToggle(),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      color: widget.enabled ? Colors.white : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: _getBorderColor(),
        width: isFocused && widget.enabled ? 2 : 1,
      ),
      boxShadow: _getBoxShadow(),
    );
  }

  Color _getBorderColor() {
    if (!widget.enabled) return const Color(0xFFE2E8F0);
    return isFocused ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0);
  }

  List<BoxShadow> _getBoxShadow() {
    if (isFocused && widget.enabled) {
      return [
        BoxShadow(
          color: const Color(0xFF3B82F6).withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }
    return [];
  }

  Widget _buildIcon() {
    return Icon(
      widget.icon,
      color: _getIconColor(),
      size: 22,
    );
  }

  Color _getIconColor() {
    if (!widget.enabled) return const Color(0xFF94A3B8);
    return isFocused ? const Color(0xFF3B82F6) : const Color(0xFF64748B);
  }

  Widget _buildTextField() {
    return TextField(
      controller: widget.controller,
      obscureText: isObscured,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      onSubmitted: widget.onSubmitted,
      inputFormatters: widget.inputFormatters,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: widget.enabled 
            ? const Color(0xFF1E293B)
            : const Color(0xFF94A3B8),
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: widget.hint ?? widget.label,
        hintStyle: TextStyle(
          color: widget.enabled 
              ? const Color(0xFF94A3B8)
              : const Color(0xFFCBD5E1),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildPasswordToggle() {
    return GestureDetector(
      onTap: widget.enabled 
          ? () => setState(() => isObscured = !isObscured)
          : null,
      child: Icon(
        isObscured ? Icons.visibility_off : Icons.visibility,
        color: widget.enabled 
            ? const Color(0xFF64748B)
            : const Color(0xFF94A3B8),
        size: 20,
      ),
    );
  }
}