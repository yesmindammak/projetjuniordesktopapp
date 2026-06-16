import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool numeric;
  final bool readOnly;
  final Function(String)? onChanged;
  final Function()? onTap;
  final IconData? suffixIcon;

  const CustomTextField(
    this.label,
    this.controller, {
    this.numeric = false,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
    this.suffixIcon,
    super.key,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() => _isFocused = hasFocus);
      },
      child: TextFormField(
        controller: widget.controller,
        readOnly: widget.readOnly,
        keyboardType: widget.numeric ? TextInputType.number : TextInputType.text,
        onChanged: widget.onChanged,
        onTap: widget.onTap,
        validator: (value) {
          if (widget.label.contains('*') && (value == null || value.isEmpty)) {
            return 'Champ obligatoire';
          }
          if (widget.numeric && value != null && value.isNotEmpty) {
            final val = double.tryParse(value.replaceAll(',', '.'));
            if (val == null) {
              return 'Nombre invalide';
            }
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: AppTextStyles.label.copyWith(
            color: _isFocused ? AppColors.primaryGreen : AppColors.textSecondary,
          ),
          filled: true,
          fillColor: _isFocused 
              ? AppColors.primaryGreen.withOpacity(0.05)
              : AppColors.background,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.border,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.primaryGreen,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: AppColors.errorRed,
              width: 1.5,
            ),
          ),
          suffixIcon: widget.suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    widget.suffixIcon,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                )
              : null,
        ),
        style: AppTextStyles.body,
      ),
    );
  }
}
