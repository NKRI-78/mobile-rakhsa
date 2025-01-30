import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/dashboard/data/models/news.dart';
import 'package:rakhsa/features/dashboard/domain/usecases/get_news.dart';

enum ProviderState { idle, loading, empty, loaded, error }

class DashboardNotifier with ChangeNotifier {
  final ProfileNotifier profileNotifier;
  final GetNewsUseCase useCase;

  DashboardNotifier({
    required this.profileNotifier,
    required this.useCase
  });  

  bool _newsLoading = false;
  bool get newsLoading => _newsLoading;
  
  List<NewsData> _ews = [];
  List<NewsData> get ews =>[..._ews];

  List<NewsData> _news = [];
  List<NewsData> get news => [..._news];

  ProviderState _state = ProviderState.loading;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateNewsLoading(bool val) {
    _newsLoading = val;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  void setStateProvider(ProviderState newState) {
    _state = newState;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> getNews({
    required double lat,
    required double lng
  }) async {
    setStateNewsLoading(true);

    final result = await useCase.execute(
      type: "news",
      lat: lat,
      lng: lng
    );

    result.fold((l) {
      _message = l.message;
      setStateNewsLoading(false);
    }, (r) {

      _news = [];
      _news.addAll(r.data);
      setStateNewsLoading(false);

      if(news.isEmpty) {
        setStateProvider(ProviderState.empty);
      }
    });
  }

  Future<void> getEws({
    required double lat,
    required double lng
  }) async {
    setStateProvider(ProviderState.loading);

    final result = await useCase.execute(
      type: "ews",
      lat: lat,
      lng: lng
    );

    result.fold((l) {
      _message = l.message;
      setStateProvider(ProviderState.error);
    }, (r) {

      _ews = [];
      _ews.addAll(r.data);
      setStateProvider(ProviderState.loaded);

      if(ews.isEmpty) {
        setStateProvider(ProviderState.empty);
      }
    });
  }

  
}