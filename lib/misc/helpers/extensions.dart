import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension ContextExtension on BuildContext {
  void unfocus({UnfocusDisposition disposition = UnfocusDisposition.scope}) =>
      FocusScope.of(this).unfocus(disposition: disposition);
  void pop<T extends Object?>([T? result]) => Navigator.of(this).pop(result);
  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String newRouteName,
    bool Function(Route<dynamic> route) predicate, {
    Object? arguments,
  }) => Navigator.of(this).pushNamedAndRemoveUntil(newRouteName, predicate);
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get top => mediaQuery.padding.top;
}

extension NumExtension on num {
  Widget get spaceY => SizedBox(height: toDouble());
  Widget get spaceX => SizedBox(width: toDouble());
}

extension DateTimeExtension on DateTime {
  String format(String pattern) => DateFormat(pattern, "id").format(toLocal());
}
