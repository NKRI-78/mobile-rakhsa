import 'dart:convert';

import 'package:rakhsa/misc/utils/logger.dart';
import 'package:rakhsa/modules/chat/presentation/pages/chat_room_page.dart';

class RouteParamDecoder extends Codec<Object?, Object?> {
  const RouteParamDecoder();

  @override
  Converter<Object?, Object?> get decoder => const _ExtraDecoder();

  @override
  Converter<Object?, Object?> get encoder => const _ExtraEncoder();
}

class _ExtraDecoder extends Converter<Object?, Object?> {
  const _ExtraDecoder();

  @override
  Object? convert(Object? input) {
    if (input == null) return null;
    if (input is String) {
      try {
        final decoded = jsonDecode(input);
        if (decoded is Map<String, dynamic> &&
            decoded['type'] == 'ChatRoomParams') {
          return ChatRoomParams.fromMap(decoded);
        }
      } catch (e) {
        log("error decode router data = ${e.toString()}", label: "APP_ROUTER");
      }
    }
    return input;
  }
}

class _ExtraEncoder extends Converter<Object?, Object?> {
  const _ExtraEncoder();

  @override
  Object? convert(Object? input) {
    if (input == null) return null;
    if (input is ChatRoomParams) {
      return jsonEncode(input.toMap());
    }
    return input;
  }
}
