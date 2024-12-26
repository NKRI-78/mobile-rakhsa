import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/errors/exception.dart';
import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/features/chat/data/models/chats.dart';
import 'package:rakhsa/features/chat/data/models/messages.dart';

abstract class ChatRemoteDataSource {
  Future<ChatsModel> getChats();
  Future<MessageModel> getMessages({required String chatId, required String status});
  Future<void> insertMessage({required String chatId, required String recipient, required String text});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {

  Dio client;

  ChatRemoteDataSourceImpl({required this.client});

  @override
  Future<ChatsModel> getChats() async {
    try { 
      final response = await client.post("${RemoteDataSourceConsts.baseUrlProd}/api/v1/chat/list",
        data: {
          "user_id": StorageHelper.getUserId(),
          "is_agent": false
        }
      );
      Map<String, dynamic> data = response.data;
      ChatsModel chatsModel = ChatsModel.fromJson(data);
      return chatsModel;
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override 
  Future<MessageModel> getMessages({required String chatId, required String status}) async {
    try {
      final response = await client.post("${RemoteDataSourceConsts.baseUrlProd}/api/v1/chat/messages",
        data: {
          "sender_id": StorageHelper.getUserId(),
          "chat_id": chatId,
          "is_agent": false,
          "status": status
        }
      );
      Map<String, dynamic> data = response.data;
      MessageModel messageModel = MessageModel.fromJson(data);
      return messageModel;
    } on DioException catch(e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    } 
  }

  @override 
  Future<void> insertMessage({required String chatId, required String recipient, required String text}) async {
    try {
      await client.post("${RemoteDataSourceConsts.baseUrlProd}/api/v1/chat/insert-message",
        data: {
          "chat_id": chatId,
          "sender": StorageHelper.getUserId(),
          "recipient": recipient,
          "text": text
        }
      );
    } on DioException catch(e) {
      debugPrint(e.response.toString());
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  } 

}