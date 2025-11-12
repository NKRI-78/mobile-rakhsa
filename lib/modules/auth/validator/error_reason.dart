class ErrorReason {
  final String title;
  final String message;

  ErrorReason({this.title = "", this.message = ""});

  ErrorReason copyWith({String? title, String? message}) {
    return ErrorReason(
      title: title ?? this.title,
      message: message ?? this.message,
    );
  }

  @override
  bool operator ==(covariant ErrorReason other) {
    if (identical(this, other)) return true;

    return other.title == title && other.message == message;
  }

  @override
  int get hashCode => title.hashCode ^ message.hashCode;
}
