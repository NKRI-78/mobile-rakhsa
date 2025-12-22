import 'package:dartz/dartz.dart';

import 'package:rakhsa/core/client/errors/failure.dart';

import 'package:rakhsa/modules/chat/data/models/chats.dart';
import 'package:rakhsa/modules/chat/data/models/messages.dart';

abstract class ChatRepository {
  Future<Either<Failure, ChatsModel>> getChats();
  Future<Either<Failure, MessageModel>> getMessages({
    required String chatId,
    required String status,
  });
}
