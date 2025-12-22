import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  void unfocus({UnfocusDisposition disposition = UnfocusDisposition.scope}) =>
      FocusScope.of(this).unfocus(disposition: disposition);
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get top => mediaQuery.padding.top;
  double get bottom => mediaQuery.padding.bottom;
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  double getScreenHeight([double from = 1.0]) => mediaQuery.size.height * from;
}
