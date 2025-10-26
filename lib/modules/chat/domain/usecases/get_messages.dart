import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/failure.dart';

import 'package:rakhsa/modules/chat/data/models/messages.dart';

import 'package:rakhsa/modules/chat/domain/repository/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  Future<Either<Failure, MessageModel>> execute({
    required String chatId,
    required String status,
  }) {
    return repository.getMessages(chatId: chatId, status: status);
  }
}
