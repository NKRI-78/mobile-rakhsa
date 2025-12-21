import 'package:dartz/dartz.dart';

import 'package:rakhsa/core/client/errors/failure.dart';
import 'package:rakhsa/modules/chat/data/models/detail_inbox.dart';

import 'package:rakhsa/modules/chat/domain/repository/chat_repository.dart';

class DetailInboxUseCase {
  final ChatRepository repository;

  DetailInboxUseCase(this.repository);

  Future<Either<Failure, InboxDetailModel>> execute({required int id}) {
    return repository.detailInbox(id: id);
  }
}
