import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:rakhsa/misc/constants/remote_data_source_consts.dart';
import 'package:rakhsa/misc/client/errors/exception.dart';
import 'package:rakhsa/misc/helpers/storage.dart';

import 'package:rakhsa/modules/chat/data/models/chats.dart';
import 'package:rakhsa/modules/chat/data/models/detail_inbox.dart';
import 'package:rakhsa/modules/chat/data/models/inbox.dart';
import 'package:rakhsa/modules/chat/data/models/messages.dart';

abstract class ChatRemoteDataSource {
  Future<InboxModel> getInbox();
  Future<InboxDetailModel> detailInbox({required int id});
  Future<ChatsModel> getChats();
  Future<MessageModel> getMessages({
    required String chatId,
    required String status,
  });
  Future<void> insertMessage({
    required String chatId,
    required String recipient,
    required String text,
    required DateTime createdAt,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  Dio client;

  ChatRemoteDataSourceImpl({required this.client});

  @override
  Future<InboxModel> getInbox() async {
    try {
      final session = await StorageHelper.getUserSession();
      final response = await client.post(
        "https://api-ppob.langitdigital78.com/api/v1/inbox",
        data: {"user_id": session?.user.id},
      );
      Map<String, dynamic> data = response.data;
      InboxModel inboxModel = InboxModel.fromJson(data);
      return inboxModel;
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Future<InboxDetailModel> detailInbox({required int id}) async {
    try {
      final response = await client.post(
        "https://api-ppob.langitdigital78.com/api/v1/inbox/detail",
        data: {"id": id},
      );
      Map<String, dynamic> data = response.data;
      InboxDetailModel inboxDetailModel = InboxDetailModel.fromJson(data);
      return inboxDetailModel;
    } on DioException catch (e) {
      debugPrint(e.response.toString());
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Future<ChatsModel> getChats() async {
    try {
      final session = await StorageHelper.getUserSession();
      final response = await client.post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/chat/list",
        data: {"user_id": session?.user.id, "is_agent": false},
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
    try {
      final session = await StorageHelper.getUserSession();
      final response = await client.post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/chat/messages",
        data: {
          "sender_id": session?.user.id,
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

  @override
  Future<void> insertMessage({
    required String chatId,
    required String recipient,
    required String text,
    required DateTime createdAt,
  }) async {
    try {
      final session = await StorageHelper.getUserSession();
      await client.post(
        "${RemoteDataSourceConsts.baseUrlProd}/api/v1/chat/insert-message",
        data: {
          "chat_id": chatId,
          "sender": session?.user.id,
          "recipient": recipient,
          "created_at": createdAt.toLocal().toIso8601String(),
          "text": text,
        },
      );
    } on DioException catch (e) {
      debugPrint(e.response.toString());
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }
}
