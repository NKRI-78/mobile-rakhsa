import 'package:flutter/foundation.dart';
import 'package:rakhsa/core/client/errors/errors.dart';
import 'package:rakhsa/core/enums/request_state.dart';
import 'package:rakhsa/repositories/ews/ews_repository.dart';
import 'package:rakhsa/repositories/ews/model/news.dart';
import 'package:rakhsa/repositories/location/model/location_data.dart';

class EwsProvider extends ChangeNotifier {
  final EwsRepository _repository;

  EwsProvider(this._repository);

  var _getNewsState = RequestState.idle;
  bool isGetNewsState(RequestState state) => state == _getNewsState;

  var _getNewsDetailState = RequestState.idle;
  bool isGetNewsDetailState(RequestState state) => state == _getNewsDetailState;

  var _news = <News>[];
  List<News> get news => _news;

  News? _newsDetail;
  News? get newsDeatil => _newsDetail;

  ErrorState? _error;
  ErrorState? get error => _error;

  Future<void> getNews(Coord coord, String country) async {
    _getNewsState = .loading;
    notifyListeners();

    try {
      final remoteNews = await _repository.getNews(coord, country);
      _news = remoteNews;
      _getNewsState = .success;
    } on NetworkException catch (e) {
      _error = _error?.copyWith(
        title: e.title,
        message: e.message,
        errorCode: e.errorCode,
      );
      _getNewsState = .error;
      notifyListeners();
    }
  }

  Future<void> getNewsDetail(int id) async {
    _getNewsDetailState = .loading;
    notifyListeners();

    try {
      final remoteNewsDetail = await _repository.getNewsDetail(id);
      _newsDetail = remoteNewsDetail;
      _getNewsDetailState = .success;
    } on NetworkException catch (e) {
      _error = _error?.copyWith(
        title: e.title,
        message: e.message,
        errorCode: e.errorCode,
      );
      _getNewsDetailState = .error;
      notifyListeners();
    }
  }
}
