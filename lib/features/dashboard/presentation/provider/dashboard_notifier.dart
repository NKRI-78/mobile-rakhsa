import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/dashboard/data/models/news.dart';
import 'package:rakhsa/features/dashboard/domain/usecases/get_news.dart';

class DashboardNotifier with ChangeNotifier {
  final ProfileNotifier profileNotifier;
  final GetNewsUseCase useCase;

  DashboardNotifier({
    required this.profileNotifier,
    required this.useCase
  });  
  
  List<NewsData> _ews = [];
  List<NewsData> get ews =>[..._ews];

  List<NewsData> _news = [];
  List<NewsData> get news => [..._news];

  ProviderState _state = ProviderState.loading;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> getNews({
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

      _news = [];

      _news.addAll(r.data);

      if(news.isEmpty) {
        setStateProvider(ProviderState.empty);
      }

      setStateProvider(ProviderState.loaded);
    });
  }

  Future<void> getEws({
    required double lat,
    required double lng
  }) async {

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

      if(ews.isEmpty) {
        setStateProvider(ProviderState.empty);
      }

      setStateProvider(ProviderState.loaded);
    });
  }

  
}