import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';
import 'package:rakhsa/features/chat/data/models/detail_inbox.dart';

import 'package:rakhsa/features/chat/domain/repository/chat_repository.dart';

class DetailInboxUseCase {
  final ChatRepository repository;

  DetailInboxUseCase(this.repository);

  Future<Either<Failure, InboxDetailModel>> execute({required int id}) {
    return repository.detailInbox(id: id);
  }
}