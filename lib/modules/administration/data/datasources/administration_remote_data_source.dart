import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rakhsa/build_config.dart';

import 'package:rakhsa/misc/client/errors/exception.dart';

import 'package:rakhsa/modules/administration/data/models/continent.dart';
import 'package:rakhsa/modules/administration/data/models/country.dart';
import 'package:rakhsa/modules/administration/data/models/state.dart';

abstract class AdministrationRemoteDataSource {
  Future<ContinentModel> getContinent();
  Future<CountryModel> getCountry({required String search});
  Future<StateModel> getStates({required int continentId});
}

class AdministrationRemoteDataSourceImpl
    implements AdministrationRemoteDataSource {
  Dio client;

  AdministrationRemoteDataSourceImpl({required this.client});

  String get _baseUrl => BuildConfig.instance.apiBaseUrl ?? "";

  @override
  Future<ContinentModel> getContinent() async {
    try {
      final response = await client.post("$_baseUrl/administration/continents");
      Map<String, dynamic> data = response.data;
      ContinentModel continentModel = ContinentModel.fromJson(data);
      return continentModel;
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Future<CountryModel> getCountry({required String search}) async {
    try {
      final response = await client.post(
        "$_baseUrl/administration/countries?search=$search",
      );
      Map<String, dynamic> data = response.data;
      CountryModel countryModel = CountryModel.fromJson(data);
      return countryModel;
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Future<StateModel> getStates({required int continentId}) async {
    try {
      final response = await client.post(
        "$_baseUrl/administration/states",
        data: {"continent_id": continentId},
      );
      Map<String, dynamic> data = response.data;
      StateModel stateModel = StateModel.fromJson(data);
      return stateModel;
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }
}
