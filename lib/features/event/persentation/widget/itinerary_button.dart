import 'package:flutter/material.dart';
import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';

class ItineraryButton extends StatelessWidget {
  const ItineraryButton({
    super.key, 
    required this.label, 
    required this.action,
    this.expand = true,
  });

  final VoidCallback? action;
  final String label;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expand ? double.infinity : null,
      child: ElevatedButton(
        onPressed: action,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: primaryColor,
          foregroundColor: whiteColor,
          padding: const EdgeInsets.all(16),
          textStyle: robotoRegular.copyWith(
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}