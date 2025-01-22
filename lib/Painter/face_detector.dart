import 'dart:ui' as ui;

import 'package:rakhsa/ML/Recognition.dart';
import 'package:flutter/material.dart';

import 'package:camera/camera.dart';

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.absoluteImageSize, this.faces, this.camDire2);

  final Size absoluteImageSize;
  final List<Recognition> faces;
  final CameraLensDirection camDire2;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.transparent;

    for (Recognition face in faces) {
      double centerX = camDire2 == CameraLensDirection.front
      ? (absoluteImageSize.width - (face.location.left + face.location.right) / 2) * scaleX
      : ((face.location.left + face.location.right) / 2) * scaleX;

      double centerY = ((face.location.top + face.location.bottom) / 2) * scaleY;

      double radius = (face.location.width > face.location.height  ? face.location.height : face.location.width) *  scaleX / 2;

      canvas.drawCircle(Offset(centerX, centerY), radius, paint);

      TextSpan span = const TextSpan(
        style: TextStyle(color: Colors.white, fontSize: 20),
        text: "",
      );

      TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.rtl,
      );

      tp.layout();
      tp.paint(canvas, Offset(centerX - tp.width / 2, centerY - radius - 20));
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return true;
  }
}
