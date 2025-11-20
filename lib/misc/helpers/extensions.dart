import 'dart:io';

import 'package:flutter/material.dart';
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

extension FileExtension on File {
  String get filename => path.split('/').last;

  String get filenameWithoutExtension {
    final name = filename;
    final lastDotIndex = name.lastIndexOf('.');
    if (lastDotIndex == -1) return name;
    return name.substring(0, lastDotIndex);
  }

  String get extension {
    final name = filename;
    final lastDotIndex = name.lastIndexOf('.');
    if (lastDotIndex == -1) return '';
    return name.substring(lastDotIndex);
  }
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
