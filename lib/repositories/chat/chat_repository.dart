import 'package:rakhsa/misc/client/dio_client.dart';
import 'package:rakhsa/misc/client/errors/errors.dart';
import 'package:rakhsa/service/storage/storage.dart';

import 'model/chat.dart';
export 'model/chat.dart';

class ChatRepository {
  final DioClient _client;

  ChatRepository(this._client);

  Future<Chat> getChatInbox() async {
    try {
      final res = await _client.post(
        endpoint: "/chat/list",
        data: {"user_id": StorageHelper.session?.user.id, "is_agent": false},
      );
      return Chat.fromJson(res.data);
    } on DataParsingException catch (e) {
      throw NetworkException(message: e.message, errorCode: e.errorCode);
    }
  }

  Future<List<Message>> getMessages(String chatId, String status) async {
    try {
      final res = await _client.post(
        endpoint: "/chat/messages",
        data: {
          "sender_id": StorageHelper.session?.user.id,
          "chat_id": chatId,
          "is_agent": false,
          "status": status,
        },
      );
      return Chat.fromJson(res.data).messages;
    } on DataParsingException catch (e) {
      throw NetworkException(message: e.message, errorCode: e.errorCode);
    }
  }
}
