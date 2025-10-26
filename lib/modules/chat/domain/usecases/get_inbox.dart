import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/failure.dart';

import 'package:rakhsa/modules/chat/data/models/inbox.dart';
import 'package:rakhsa/modules/chat/domain/repository/chat_repository.dart';

class GetInboxUseCase {
  final ChatRepository repository;

  GetInboxUseCase(this.repository);

  Future<Either<Failure, InboxModel>> execute() {
    return repository.getInbox();
  }
}
