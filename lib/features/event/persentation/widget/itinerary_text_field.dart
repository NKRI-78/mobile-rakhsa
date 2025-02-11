
import 'package:flutter/material.dart';
import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';

class ItineraryTextField extends StatelessWidget {
  const ItineraryTextField({
    super.key, 
    required this.controller,
    required this.title,
    required this.hint,
    this.maxLines = 1,
    this.textInputAction,
    this.onSubmitted,
    this.keyboardType,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String title;
  final String hint;
  final bool autofocus;
  final int maxLines;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: robotoRegular.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          cursorColor: redColor,
          autofocus: autofocus,
          maxLines: maxLines,
          focusNode: focusNode,
          keyboardType: keyboardType,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: redColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: redColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}