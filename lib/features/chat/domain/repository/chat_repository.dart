import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/chat/data/models/chats.dart';
import 'package:rakhsa/features/chat/data/models/detail_inbox.dart';
import 'package:rakhsa/features/chat/data/models/inbox.dart';
import 'package:rakhsa/features/chat/data/models/messages.dart';

abstract class ChatRepository {
  Future<Either<Failure, InboxModel>> getInbox();
  Future<Either<Failure, InboxDetailModel> >detailInbox({required int id});
  Future<Either<Failure, ChatsModel>> getChats();
  Future<Either<Failure, MessageModel>> getMessages({required String chatId, required String status});
  Future<Either<Failure, void>> insertMessage({required String chatId, required String recipient, required String text, required DateTime createdAt});
}