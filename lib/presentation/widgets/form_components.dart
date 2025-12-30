import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Form field with label matching Figma design
class FormFieldWithLabel extends StatelessWidget {
  final String label;
  final Widget child;
  final bool required;

  const FormFieldWithLabel({
    super.key,
    required this.label,
    required this.child,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFE2E8F0)
                    : AppColors.textPrimary,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: AppColors.danger, fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/// Styled text field matching Figma design
class StyledTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final int? maxLines;
  final bool enabled;

  const StyledTextField({
    super.key,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF64748B)
              : AppColors.textMuted,
          fontSize: 14,
        ),
        filled: true,
        fillColor: enabled
            ? (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E293B)
                  : AppColors.bgLight)
            : (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF0F172A)
                  : AppColors.borderLight),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF334155)
                : AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF334155)
                : AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFFE2E8F0)
            : AppColors.textPrimary,
        fontSize: 14,
      ),
    );
  }
}

/// Styled dropdown matching Figma design
class StyledDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? hintText;
  final String? Function(T?)? validator;

  const StyledDropdown({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.hintText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF64748B)
              : AppColors.textMuted,
          fontSize: 14,
        ),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : AppColors.bgLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF334155)
                : AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF334155)
                : AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFFE2E8F0)
            : AppColors.textPrimary,
        fontSize: 14,
      ),
      dropdownColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E293B)
          : Colors.white,
    );
  }
}
