import 'package:equatable/equatable.dart';
import 'package:rakhsa/misc/client/errors/errors.dart';

class ChatId extends Equatable {
  final String id;

  const ChatId(this.id);

  @override
  List<Object?> get props => [id];

  ChatId copyWith({String? id}) {
    return ChatId(id ?? this.id);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id};
  }

  factory ChatId.fromJson(Map<String, dynamic> map) {
    try {
      return ChatId(map['id'] as String);
    } catch (e) {
      throw DataParsingException(error: e);
    }
  }

  factory ChatId.fromSingleValue(chatId) {
    try {
      return ChatId(chatId);
    } catch (e) {
      throw DataParsingException(error: e);
    }
  }
}
