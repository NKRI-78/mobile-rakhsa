import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/chat/data/models/chats.dart';
import 'package:rakhsa/features/chat/domain/repositories/chat_repository.dart';

class GetChatsUseCase {
  final ChatRepository repository;

  GetChatsUseCase(this.repository);

  Future<Either<Failure, ChatsModel>> execute() {
    return repository.getChats();
  }
}