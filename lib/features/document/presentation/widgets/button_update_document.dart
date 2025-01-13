import 'package:flutter/material.dart';
import 'package:rakhsa/common/constants/theme.dart';

class ButtonUpdateDocument extends StatefulWidget {
  const ButtonUpdateDocument({
    super.key,
    required this.label,
    required this.onTap,
  });

  final VoidCallback onTap;
  final String label;

  @override
  State<ButtonUpdateDocument> createState() => _ButtonUpdateDocumentState();
}

class _ButtonUpdateDocumentState extends State<ButtonUpdateDocument> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Mulai animasi fade-in setelah widget dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(100);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: _opacity,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Material(
            color: redColor,
            borderRadius: borderRadius,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: borderRadius,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}