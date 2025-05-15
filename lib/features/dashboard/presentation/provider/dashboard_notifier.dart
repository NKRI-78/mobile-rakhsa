import 'package:flutter/material.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/dashboard/data/models/banner.dart';
import 'package:rakhsa/features/dashboard/data/models/news.dart';
import 'package:rakhsa/features/dashboard/domain/usecases/get_banner.dart';
import 'package:rakhsa/features/dashboard/domain/usecases/get_news.dart';

enum BannerProviderState {idle, loading, empty, loaded, error }
enum NewsProviderState { idle, loading, empty, loaded, error }

class DashboardNotifier with ChangeNotifier {
  final ProfileNotifier profileNotifier;
  final GetNewsUseCase useCase;
  final GetBannerUseCase bannerUseCase;

  DashboardNotifier({
    required this.profileNotifier,
    required this.useCase,
    required this.bannerUseCase
  });  

  bool _isLocked = false;
  bool get isLocked => _isLocked;

  List<BannerData> _banners = [];
  List<BannerData> get banners => [..._banners];

  List<NewsData> _ews = [];
  List<NewsData> get ews =>[..._ews];

  List<NewsData> _news = [];
  List<NewsData> get news => [..._news];

  BannerProviderState _bannerState = BannerProviderState.loading;
  BannerProviderState get bannerState => _bannerState;

  NewsProviderState _newsState = NewsProviderState.loading;
  NewsProviderState get newsState => _newsState;

  ProviderState _state = ProviderState.loading;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void checkIsLocked() {
    _isLocked = StorageHelper.isLocked();

    notifyListeners(); 
  }

  void setStateIsLocked({required bool val}) {
    _isLocked = val;

    notifyListeners(); 
  }

  void setStateBanner(BannerProviderState newState) {
    _bannerState = newState;

    notifyListeners();
  }

  void setStateNews(NewsProviderState newState) {
    _newsState = newState;

    notifyListeners();
  }

  void setStateProvider(ProviderState newState) {
    _state = newState;

    notifyListeners();
  }

  Future<void> getBanner() async {
    setStateBanner(BannerProviderState.loading);

    final result = await bannerUseCase.execute();

    result.fold((l) {
      _message = l.message;
      setStateBanner(BannerProviderState.error);
    }, (r) {
      _banners = [];
      _banners.addAll(r.data);
      setStateBanner(BannerProviderState.loaded);

      if(news.isEmpty) {
        setStateBanner(BannerProviderState.empty);
      }
    });
  }

  Future<void> getNews({
    required double lat,
    required double lng
  }) async {
    setStateNews(NewsProviderState.loading);

    final result = await useCase.execute(
      lat: lat,
      lng: lng,
      state: "-",
    );

    result.fold((l) {
      _message = l.message;
      setStateNews(NewsProviderState.error);
    }, (r) {
      _news = [];
      _news.addAll(r.data);
      setStateNews(NewsProviderState.loaded);

      if(news.isEmpty) {
        setStateNews(NewsProviderState.empty);
      }
    });
  }

  Future<void> getEws({
    required double lat,
    required double lng,
    required String state,
  }) async {
    setStateProvider(ProviderState.loading);

    final result = await useCase.execute(
      lat: lat,
      lng: lng,
      state: state,
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