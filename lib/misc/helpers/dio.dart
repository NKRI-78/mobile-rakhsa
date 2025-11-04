import 'package:dio/dio.dart';

//TODO: koreksi DioHelper apakah benar-benar digunakan
class DioHelper {
  static final shared = DioHelper();

  Dio getClient() {
    return Dio();
  }
}
