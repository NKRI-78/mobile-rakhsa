import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/failure.dart';

import 'package:rakhsa/modules/chat/data/models/chats.dart';
import 'package:rakhsa/modules/chat/domain/repository/chat_repository.dart';

class GetChatsUseCase {
  final ChatRepository repository;

  GetChatsUseCase(this.repository);

  Future<Either<Failure, ChatsModel>> execute() {
    return repository.getChats();
  }
}
