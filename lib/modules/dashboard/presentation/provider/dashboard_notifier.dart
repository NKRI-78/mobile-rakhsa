import 'package:flutter/material.dart';
import 'package:rakhsa/core/enums/provider_state.dart';

import 'package:rakhsa/modules/app/provider/user_provider.dart';
import 'package:rakhsa/modules/dashboard/data/models/banner.dart';
import 'package:rakhsa/modules/dashboard/data/models/news.dart';
import 'package:rakhsa/modules/dashboard/domain/usecases/get_banner.dart';
import 'package:rakhsa/modules/dashboard/domain/usecases/get_news.dart';

class DashboardNotifier with ChangeNotifier {
  final UserProvider profileNotifier;
  final GetNewsUseCase useCase;
  final GetBannerUseCase bannerUseCase;

  DashboardNotifier({
    required this.profileNotifier,
    required this.useCase,
    required this.bannerUseCase,
  });

  List<BannerData> _banners = [];
  List<BannerData> get banners => [..._banners];

  List<NewsData> _ews = [];
  List<NewsData> get ews => [..._ews];

  List<NewsData> _news = [];
  List<NewsData> get news => [..._news];

  ProviderState _state = .loading;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;

    notifyListeners();
  }

  Future<void> getBanner() async {
    setStateProvider(.loading);

    final result = await bannerUseCase.execute();

    result.fold(
      (l) {
        _message = l.message;
        setStateProvider(.error);
      },
      (r) {
        _banners = [];
        _banners.addAll(r.data);
        setStateProvider(.loaded);

        if (news.isEmpty) {
          setStateProvider(.empty);
        }
      },
    );
  }

  Future<void> getNews({required double lat, required double lng}) async {
    setStateProvider(.loading);

    final result = await useCase.execute(lat: lat, lng: lng, state: "-");

    result.fold(
      (l) {
        _message = l.message;
        setStateProvider(.error);
      },
      (r) {
        _news = [];
        _news.addAll(r.data);
        setStateProvider(.loaded);

        if (news.isEmpty) {
          setStateProvider(.empty);
        }
      },
    );
  }

  Future<void> getEws({
    required double lat,
    required double lng,
    required String state,
  }) async {
    setStateProvider(.loading);

    final result = await useCase.execute(lat: lat, lng: lng, state: state);

    result.fold(
      (l) {
        _message = l.message;
        setStateProvider(.error);
      },
      (r) {
        _ews = [];
        _ews.addAll(r.data);
        setStateProvider(.loaded);

        if (ews.isEmpty) {
          setStateProvider(.empty);
        }
      },
    );
  }
}
