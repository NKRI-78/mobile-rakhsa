import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/pages/chat/data/models/messages.dart';

abstract class ChatRepository {
  Future<Either<Failure, MessageModel>> getMessages({required String chatId});
}