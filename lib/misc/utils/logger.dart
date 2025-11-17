import "dart:developer" as d;
import "package:flutter/foundation.dart";

void log(String message, {String? label, bool enableRelease = true}) {
  if (kDebugMode) {
    d.log(message, name: label ?? "");
  } else if (kReleaseMode && enableRelease) {
    debugPrint("${label ?? ""} $message");
  }
}
