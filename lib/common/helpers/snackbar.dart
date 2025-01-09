import 'package:flutter/material.dart';

import 'package:rakhsa/global.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

class ShowSnackbar {
  ShowSnackbar._();

  static snackbarOk(String content) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,  
        backgroundColor: Colors.green,
        content: Text(
          content.contains('SocketException') ? "Koneksi internet anda tidak stabil. Pastikan anda terhubung ke internet." : content,
          style: robotoRegular.copyWith(
            color: ColorResources.white,
            fontSize: Dimensions.fontSizeSmall
          ),
        ),
        action: SnackBarAction(
          label: "",
          onPressed: () {
            ScaffoldMessenger.of(navigatorKey.currentContext!).hideCurrentSnackBar();
          }
        ),
      )
    );
  }

  static snackbarDefault(String content) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,  
        backgroundColor: const Color(0xFF303030),
        content: Text(
          content.contains('SocketException') ? "Koneksi internet anda tidak stabil. Pastikan anda terhubung ke internet." : content,
          style: robotoRegular.copyWith(
            color: ColorResources.white,
            fontSize: Dimensions.fontSizeSmall
          ),
        ),
        action: SnackBarAction(
          label: "",
          onPressed: () {
            ScaffoldMessenger.of(navigatorKey.currentContext!).hideCurrentSnackBar();
          }
        ),
      )
    );
  }

  static snackbarErr(String content) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,  
        backgroundColor: Colors.red,
        content: Text(
          content.contains('SocketException') ? "Koneksi internet anda tidak stabil. Pastikan anda terhubung ke internet." : content,
          style: robotoRegular.copyWith(
            color: ColorResources.white,
            fontSize: Dimensions.fontSizeSmall
          ),
        ),
        action: SnackBarAction(
          label: "",
          onPressed: () {
            ScaffoldMessenger.of(navigatorKey.currentContext!).hideCurrentSnackBar();
          }
        ),
      )
    );
  }

}