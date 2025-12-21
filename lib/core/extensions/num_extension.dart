import 'package:flutter/material.dart';

extension NumExtension on num {
  Widget get spaceY => SizedBox(height: toDouble());
  Widget get spaceX => SizedBox(width: toDouble());
}
