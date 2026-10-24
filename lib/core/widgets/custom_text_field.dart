import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.focusNode,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.focusedBottomSpace = 0,
  });

  final String label, hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon, suffixIcon;
  final VoidCallback? onSuffixTap;
  final double focusedBottomSpace;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 6),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.onSurface.withValues(alpha: 0.8),
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: colors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              color: colors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: colors.surfaceContainer,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(
                    prefixIcon,
                    size: 20,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
            suffixIcon: suffixIcon == null
                ? null
                : CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: onSuffixTap,
                    child: Icon(
                      suffixIcon,
                      size: 20,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
          ),
        ),
        if (focusNode != null && focusedBottomSpace > 0)
          ListenableBuilder(
            listenable: focusNode!,
            builder: (context, child) =>
                SizedBox(height: focusNode!.hasFocus ? focusedBottomSpace : 0),
          ),
      ],
    );
  }
}
