import 'package:flutter/material.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/global.dart';

class ShowSnackbar {
  ShowSnackbar._();

  static snackbarOk(String content) {
    ScaffoldMessenger.of(navigatorKey.currentState!.context).clearSnackBars();
    ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
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
            ScaffoldMessenger.of(navigatorKey.currentState!.context).hideCurrentSnackBar();
          }
        ),
      )
    );
  }

  static snackbarDefault(String content) {
    ScaffoldMessenger.of(navigatorKey.currentState!.context).clearSnackBars();
    ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
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
            ScaffoldMessenger.of(navigatorKey.currentState!.context).hideCurrentSnackBar();
          }
        ),
      )
    );
  }

  static snackbarErr(String content) {
    ScaffoldMessenger.of(navigatorKey.currentState!.context).clearSnackBars();
    ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
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
            ScaffoldMessenger.of(navigatorKey.currentState!.context).hideCurrentSnackBar();
          }
        ),
      )
    );
  }

}