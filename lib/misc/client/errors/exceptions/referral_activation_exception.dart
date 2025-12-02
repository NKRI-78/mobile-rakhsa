// ignore_for_file: public_member_api_docs, sort_constructors_first
class ReferralException implements Exception {
  ReferralException({
    required this.message,
    this.title,
    this.errorCode,
    this.statusCode,
    this.error,
  });

  final String message;
  final String? title;
  final String? errorCode;
  final int? statusCode;
  final Object? error;

  @override
  String toString() {
    return 'ReferralException(message: $message, title: $title, errorCode: $errorCode, statusCode: $statusCode, error: $error)';
  }
}
