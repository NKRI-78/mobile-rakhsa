import 'package:rakhsa/core/client/dio_client.dart';
import 'package:rakhsa/core/client/errors/errors.dart';
import 'package:rakhsa/repositories/location/model/location_data.dart';

import 'model/news.dart';

class EwsRepository {
  final DioClient _client;

  EwsRepository(this._client);

  Future<List<News>> getNews(Coord coord, String country) async {
    try {
      final res = await _client.post(
        endpoint: "/news/list-v2",
        data: {
          "lat": coord.lat.toString(),
          "lng": coord.lng.toString(),
          "state": country,
        },
      );

      if (res.data is! List) return <News>[];

      return (res.data as List).map((e) => News.fromJson(e)).toList();
    } on DataParsingException catch (e) {
      throw NetworkException(
        title: e.title,
        message: e.message,
        errorCode: e.errorCode,
      );
    }
  }

  Future<News> getNewsDetail(int id) async {
    try {
      final res = await _client.get(endpoint: "/news/$id");
      return News.fromJson(res.data);
    } on DataParsingException catch (e) {
      throw NetworkException(
        title: e.title,
        message: e.message,
        errorCode: e.errorCode,
      );
    }
  }
}
