import 'package:dartz/dartz.dart';

import 'package:rakhsa/misc/client/errors/exception.dart';
import 'package:rakhsa/misc/client/errors/failure.dart';

import 'package:rakhsa/modules/chat/data/datasources/chat_remote_data_source.dart';

import 'package:rakhsa/modules/chat/data/models/chats.dart';
import 'package:rakhsa/modules/chat/data/models/detail_inbox.dart';
import 'package:rakhsa/modules/chat/data/models/inbox.dart';
import 'package:rakhsa/modules/chat/data/models/messages.dart';

import 'package:rakhsa/modules/chat/domain/repository/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ChatsModel>> getChats() async {
    try {
      var result = await remoteDataSource.getChats();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageModel>> getMessages({
    required String chatId,
    required String status,
  }) async {
    try {
      var result = await remoteDataSource.getMessages(
        chatId: chatId,
        status: status,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> insertMessage({
    required String chatId,
    required String recipient,
    required String text,
    required DateTime createdAt,
  }) async {
    try {
      var result = await remoteDataSource.insertMessage(
        chatId: chatId,
        recipient: recipient,
        text: text,
        createdAt: createdAt,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InboxModel>> getInbox() async {
    try {
      var result = await remoteDataSource.getInbox();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InboxDetailModel>> detailInbox({
    required int id,
  }) async {
    try {
      var result = await remoteDataSource.detailInbox(id: id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
