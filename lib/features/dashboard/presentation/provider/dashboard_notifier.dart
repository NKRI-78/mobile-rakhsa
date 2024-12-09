import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/storage.dart';
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
    required String type, 
    required double lat,
    required double lng
  }) async {

    debugPrint("=== KESINI ===");
    
    final result = await useCase.execute(
      type: type,
      lat: lat,
      lng: lng
    );

    result.fold((l) {
      _message = l.message;
      setStateProvider(ProviderState.error);
    }, (r) {

      _news = [];

      if(StorageHelper.getUserId() != null) {
        _news.insert(0, NewsData(
          id: 0, 
          title: "", 
          img: "", 
          desc: "", 
          type: "",
          createdAt: ""
        ));
      }

      _news.addAll(r.data);

      if(news.length == 1) {
        setStateProvider(ProviderState.empty);
      }

      setStateProvider(ProviderState.loaded);
    });
  }

  
}