import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/chat/domain/repository/chat_repository.dart';

class InsertMessageUseCase {
  final ChatRepository repository;

  InsertMessageUseCase(this.repository);

  Future<Either<Failure, void>> execute({required String chatId, required String recipient, required String text, required DateTime createdAt}) {
    return repository.insertMessage(chatId: chatId, recipient: recipient, text: text, createdAt: createdAt);
  }
}