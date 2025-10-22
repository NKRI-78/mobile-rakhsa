import 'package:equatable/equatable.dart';

// {
//     "status": 200,
//     "error": false,
//     "message": "Successfully",
//     "total": 0, //! pagination
//     "per_page": 0, //! pagination
//     "prev_page": 1, //! pagination
//     "next_page": 2, //! pagination
//     "current_page": 1, //! pagination
//     "next_url": "http://localhost:6363?page=2", //! pagination
//     "prev_url": "http://localhost:6363?page=1", //! pagination
//     "data": [] T
// }

class ResponseDto<T> extends Equatable {
  final int status;
  final bool error;
  final String message;
  final int? total;
  final int? perPage;
  final int? prevPage;
  final int? nextPage;
  final int? currentPage;
  final String? nextUrl;
  final String? prevUrl;
  final T? data;

  const ResponseDto({
    required this.status,
    required this.error,
    required this.message,
    this.total,
    this.perPage,
    this.prevPage,
    this.nextPage,
    this.currentPage,
    this.nextUrl,
    this.prevUrl,
    this.data,
  });

  @override
  List<Object?> get props {
    return [
      status,
      error,
      message,
      total,
      perPage,
      prevPage,
      nextPage,
      currentPage,
      nextUrl,
      prevUrl,
      data,
    ];
  }

  factory ResponseDto.fromJson(Map<String, dynamic> map) {
    return ResponseDto<T>(
      status: map['status'],
      error: map['error'],
      message: map['message'],
      total: map['total'],
      perPage: map['per_page'],
      prevPage: map['prev_page'],
      nextPage: map['next_page'],
      currentPage: map['current_page'],
      nextUrl: map['next_url'],
      prevUrl: map['prev_url'],
      data: map['data'],
    );
  }
}
