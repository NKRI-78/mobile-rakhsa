import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/exception.dart';
import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/chat/data/datasources/chat_remote_data_source.dart';

import 'package:rakhsa/features/chat/data/models/chats.dart';
import 'package:rakhsa/features/chat/data/models/messages.dart';

import 'package:rakhsa/features/chat/domain/repository/chat_repository.dart';

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
  Future<Either<Failure, MessageModel>> getMessages({required String chatId}) async {
    try {
      var result = await remoteDataSource.getMessages(chatId: chatId);
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

}