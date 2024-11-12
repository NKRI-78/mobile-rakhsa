import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/errors/exception.dart';

import 'package:rakhsa/features/chat/data/models/messages.dart';

abstract class ChatRemoteDataSource {
  Future<MessageModel> getMessages({required String chatId});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {

  Dio client;

  ChatRemoteDataSourceImpl({required this.client});

  @override 
  Future<MessageModel> getMessages({required String chatId}) async {
    try {
      final response = await client.post("${RemoteDataSourceConsts.baseUrlProd}/api/v1/chat/messages",
        data: {
          "sender_id": "64cdba1f-01ca-464d-a7d4-5c109de0a251",
          "chat_id": chatId
        }
      );
      Map<String, dynamic> data = response.data;
      debugPrint(data.toString());
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

}