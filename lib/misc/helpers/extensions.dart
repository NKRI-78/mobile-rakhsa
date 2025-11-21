// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'package:rakhsa/repositories/location/model/location_data.dart';

extension ContextExtension on BuildContext {
  void unfocus({UnfocusDisposition disposition = UnfocusDisposition.scope}) =>
      FocusScope.of(this).unfocus(disposition: disposition);
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get top => mediaQuery.padding.top;
  double get bottom => mediaQuery.padding.bottom;
}

extension NumExtension on num {
  Widget get spaceY => SizedBox(height: toDouble());
  Widget get spaceX => SizedBox(width: toDouble());
}

extension DateTimeExtension on DateTime {
  String format(String pattern) => DateFormat(pattern).format(toLocal());
}

extension StringExtensions on String {
  String capitalizeEachWord() {
    return trim()
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.toUpperCase() == word) return word;
          return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
        })
        .join(' ');
  }
}

extension FileExtension on File {
  String get filename => p.basename(path);

  String get filenameWithoutExtension => p.basenameWithoutExtension(path);

  String get extension => p.extension(path);

  String get dirname => p.dirname(path);
}

extension PlacemarkExtension on Placemark {
  String getAddress([
    List<PlacemarkPart> parts = const [
      PlacemarkPart.administrativeArea,
      PlacemarkPart.subAdministrativeArea,
      PlacemarkPart.street,
      PlacemarkPart.country,
    ],
  ]) {
    final values = <String>[];

    for (final part in parts) {
      final value = part.getValue(this);

      if (value != null) {
        final trimmed = value.trim();
        if (trimmed.isNotEmpty) {
          values.add(trimmed);
        }
      }
    }

    if (values.isEmpty) return "-";

    return values.join(', ');
  }
}
