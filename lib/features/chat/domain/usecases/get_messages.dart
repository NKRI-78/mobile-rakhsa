import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/chat/data/models/messages.dart';

import 'package:rakhsa/features/chat/domain/repository/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  Future<Either<Failure, MessageModel>> execute({required String chatId}) {
    return repository.getMessages(chatId: chatId);
  }
}