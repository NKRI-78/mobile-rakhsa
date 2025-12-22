import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rakhsa/build_config.dart';

import 'package:rakhsa/core/client/errors/exception.dart';
import 'package:rakhsa/service/storage/storage.dart';

import 'package:rakhsa/modules/chat/data/models/chats.dart';
import 'package:rakhsa/modules/chat/data/models/messages.dart';

abstract class ChatRemoteDataSource {
  Future<ChatsModel> getChats();
  Future<MessageModel> getMessages({
    required String chatId,
    required String status,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  Dio client;

  ChatRemoteDataSourceImpl({required this.client});

  String get _baseUrl => BuildConfig.instance.apiBaseUrl ?? "";

  @override
  Future<ChatsModel> getChats() async {
    final token = StorageHelper.session?.token;
    try {
      final response = await client.post(
        "$_baseUrl/chat/list",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {"user_id": StorageHelper.session?.user.id, "is_agent": false},
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
  Future<MessageModel> getMessages({
    required String chatId,
    required String status,
  }) async {
    final token = StorageHelper.session?.token;
    try {
      final response = await client.post(
        "$_baseUrl/chat/messages",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {
          "sender_id": StorageHelper.session?.user.id,
          "chat_id": chatId,
          "is_agent": false,
          "status": status,
        },
      );
      Map<String, dynamic> data = response.data;
      MessageModel messageModel = MessageModel.fromJson(data);
      return messageModel;
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }
}
