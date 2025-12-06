import "dart:developer" as d;
import "dart:io" show Platform;
import "package:flutter/foundation.dart";

void log(String message, {String? label, bool enableRelease = true}) {
  if (kDebugMode) {
    if (Platform.isIOS) {
      debugPrint("${label ?? ""} $message");
    } else {
      d.log(message, name: label ?? "");
    }
  } else if (kReleaseMode && enableRelease) {
    debugPrint("${label ?? ""} $message");
  }
}
