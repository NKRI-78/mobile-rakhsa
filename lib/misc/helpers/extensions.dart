import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  void unfocus({UnfocusDisposition disposition = UnfocusDisposition.scope}) =>
      FocusScope.of(this).unfocus(disposition: disposition);
  void pop<T extends Object?>([T? result]) => Navigator.of(this).pop(result);
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get top => mediaQuery.padding.top;
}

extension NumExtension on num {
  Widget get spaceY => SizedBox(height: toDouble());
  Widget get spaceX => SizedBox(width: toDouble());
}
