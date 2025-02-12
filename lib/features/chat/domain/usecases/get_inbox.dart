import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/chat/data/models/inbox.dart';
import 'package:rakhsa/features/chat/domain/repository/chat_repository.dart';

class GetInboxUseCase {
  final ChatRepository repository;

  GetInboxUseCase(this.repository);

  Future<Either<Failure, InboxModel>> execute() {
    return repository.getInbox();
  }
}