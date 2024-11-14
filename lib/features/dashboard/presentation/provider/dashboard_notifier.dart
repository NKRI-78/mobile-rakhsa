import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/dashboard/data/models/news.dart';
import 'package:rakhsa/features/dashboard/domain/usecases/get_news.dart';

class DashboardNotifier with ChangeNotifier {
  final GetNewsUseCase useCase;

  DashboardNotifier({
    required this.useCase
  });  

  List<NewsData> _news = [];
  List<NewsData> get news => [..._news];

  ProviderState _state = ProviderState.loading;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;

    notifyListeners();
  }

  Future<void> getNews() async {
    final result = await useCase.execute();

    result.fold((l) {
      _message = l.message;
      setStateProvider(ProviderState.error);
    }, (r) {

      _news = [];
      _news.addAll(r.data);

      setStateProvider(ProviderState.loaded);
    });
  }

  
}