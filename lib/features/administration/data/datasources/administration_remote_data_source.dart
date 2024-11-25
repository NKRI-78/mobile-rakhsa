import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/errors/exception.dart';

import 'package:rakhsa/features/administration/data/models/continent.dart';
import 'package:rakhsa/features/administration/data/models/country.dart';
import 'package:rakhsa/features/administration/data/models/state.dart';

abstract class AdministrationRemoteDataSource {
  Future<ContinentModel> getContinent();
  Future<CountryModel> getCountry();
  Future<StateModel> getStates({required int continentId});
}

class AdministrationRemoteDataSourceImpl implements AdministrationRemoteDataSource {

  Dio client;

  AdministrationRemoteDataSourceImpl({required this.client});

  @override
  Future<ContinentModel> getContinent() async {
    try {
      final response = await client.post("${RemoteDataSourceConsts.baseUrlProd}/api/v1/administration/continents");
      Map<String, dynamic> data = response.data;
      ContinentModel continentModel = ContinentModel.fromJson(data);
      return continentModel;
    } on DioException catch(e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    } 
  }

  @override 
  Future<CountryModel> getCountry() async {
    try {
      final response = await client.post("${RemoteDataSourceConsts.baseUrlProd}/api/v1/administration/countries");
      Map<String, dynamic> data = response.data;
      CountryModel countryModel = CountryModel.fromJson(data);
      return countryModel;
    } on DioException catch(e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    } 
  }

  @override
  Future<StateModel> getStates({
    required int continentId
  }) async {
    try {
      final response = await client.post("${RemoteDataSourceConsts.baseUrlProd}/api/v1/administration/states",
        data: {
          "continent_id": continentId
        }
      );
      Map<String, dynamic> data = response.data;
      StateModel stateModel = StateModel.fromJson(data);
      return stateModel;
    } on DioException catch(e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    } 
  }

}