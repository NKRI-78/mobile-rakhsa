import 'package:flutter/material.dart';

import 'package:rakhsa/core/enums/provider_state.dart';

import 'package:rakhsa/modules/dashboard/data/models/news_detail.dart';
import 'package:rakhsa/modules/dashboard/domain/usecases/detail_news.dart';

class DetailNewsNotifier with ChangeNotifier {
  final DetailNewsUseCase useCase;

  DetailNewsNotifier({required this.useCase});

  NewsDetailData _entity = NewsDetailData();
  NewsDetailData get entity => _entity;

  ProviderState _state = .loading;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;

    notifyListeners();
  }

  Future<void> detailNews({required int id}) async {
    setStateProvider(.loading);

    final result = await useCase.execute(id: id);

    result.fold(
      (l) {
        _message = l.message;
        setStateProvider(.error);
      },
      (r) {
        _entity = r.data;
        setStateProvider(.loaded);
      },
    );
  }
}
