import 'package:equatable/equatable.dart';

enum ErrorSource { network, referral, unknown }

class ErrorState extends Equatable {
  final String? title;
  final String? message;
  final String? errorCode;
  final ErrorSource source;

  const ErrorState({
    this.title,
    this.message,
    this.errorCode,
    this.source = ErrorSource.unknown,
  });

  @override
  List<Object?> get props => [title, message, errorCode, source];

  ErrorState copyWith({
    String? title,
    String? message,
    String? errorCode,
    ErrorSource? source,
  }) {
    return ErrorState(
      title: title ?? this.title,
      message: message ?? this.message,
      errorCode: errorCode ?? this.errorCode,
      source: source ?? this.source,
    );
  }
}
