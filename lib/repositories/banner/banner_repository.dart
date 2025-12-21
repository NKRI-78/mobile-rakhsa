import 'package:rakhsa/core/client/dio_client.dart';
import 'package:rakhsa/core/client/errors/exceptions/exceptions.dart';

import 'model/image_banner.dart';

class BannerRepository {
  final DioClient _client;

  BannerRepository(this._client);

  Future<List<ImageBanner>> getBanners() async {
    try {
      final res = await _client.get(endpoint: '/banner');

      if (res.data is! List) return [];

      return (res.data as List).map((e) => ImageBanner.fromJson(e)).toList();
    } on DataParsingException catch (e) {
      throw NetworkException(
        title: e.title,
        errorCode: e.errorCode,
        message: e.message,
      );
    }
  }
}
