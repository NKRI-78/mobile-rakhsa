import "dart:developer" as d;
import "package:flutter/foundation.dart";

void log(String message, [String? name, bool enableRelease = true]) {
  if (kDebugMode) {
    d.log(message, name: name ?? "");
  } else if (kReleaseMode && enableRelease) {
    debugPrint("$name $message");
  }
}
