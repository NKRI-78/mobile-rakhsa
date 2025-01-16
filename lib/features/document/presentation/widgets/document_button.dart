import 'package:flutter/material.dart';
import 'package:rakhsa/common/constants/theme.dart';

class DocumentButton extends StatelessWidget {
  const DocumentButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isUpdateVisa = false,
  });

  final VoidCallback onTap;
  final String label;
  final bool isUpdateVisa;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(100);

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Material(
          color: isUpdateVisa ? redColor.withOpacity(0.15) : redColor,
          borderRadius: borderRadius,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isUpdateVisa ? redColor : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
