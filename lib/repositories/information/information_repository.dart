import 'package:rakhsa/core/client/dio_client.dart';
import 'package:rakhsa/core/client/errors/errors.dart';
import 'package:rakhsa/repositories/information/model/geo_node.dart';

import 'model/kbri.dart';

class InformationRepository {
  final DioClient _client;

  InformationRepository({required DioClient client}) : _client = client;

  Future<List<GeoNode>> getCountries(String q) async {
    try {
      final res = await _client.post(
        endpoint: "/administration/countries?search=$q",
      );

      final data = res.data;
      if (data is! List) return <GeoNode>[];

      return data.map((e) => GeoNode.fromJson(e)).toList();
    } on DataParsingException catch (e) {
      throw NetworkException(message: e.message, errorCode: e.errorCode);
    }
  }

  Future<KBRI> getKBRIByCurrentCountry(String country) async {
    final countryQuery = country.toLowerCase() == "japan" ? "Jepang" : country;
    try {
      final res = await _client.get(
        endpoint: "/information/info-kbri-state-name/$countryQuery",
      );

      return KBRI.fromJson(res.data);
    } on DataParsingException catch (e) {
      throw NetworkException(message: e.message, errorCode: e.errorCode);
    }
  }

  Future<KBRI> getKBRIByCountryId(String id) async {
    try {
      final res = await _client.get(
        endpoint: "/information/info-kbri-state/$id",
      );

      return KBRI.fromJson(res.data);
    } on DataParsingException catch (e) {
      throw NetworkException(message: e.message, errorCode: e.errorCode);
    }
  }
}
