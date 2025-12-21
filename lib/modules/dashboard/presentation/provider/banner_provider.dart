import 'package:flutter/material.dart';
import 'package:rakhsa/misc/client/errors/errors.dart';
import 'package:rakhsa/misc/enums/request_state.dart';
import 'package:rakhsa/repositories/banner/banner_repository.dart';
import 'package:rakhsa/repositories/banner/model/image_banner.dart';
import 'package:rakhsa/service/storage/storage.dart';

class BannerProvider extends ChangeNotifier {
  final BannerRepository _repository;

  BannerProvider(this._repository);

  final _cacheKey = 'banners_cache_key';

  var _banners = <ImageBanner>[];
  List<ImageBanner> get banners => _banners;

  var _getBannersState = RequestState.idle;
  RequestState get getBannerState => _getBannersState;
  bool get isLoading => _getBannersState == RequestState.loading;
  bool get isSuccess => _getBannersState == RequestState.success;
  bool get isError => _getBannersState == RequestState.error;

  ErrorState? _errorState;
  ErrorState? get error => _errorState;

  Future<void> getBanners({
    bool enableCache = true,
    Duration cacheAge = const Duration(minutes: 30),
  }) async {
    _getBannersState = RequestState.loading;
    notifyListeners();

    if (_banners.isNotEmpty) {
      if (enableCache && await _shouldRevalidate(cacheAge)) {
        _getBannersState = RequestState.success;
        notifyListeners();
        return;
      }
    }

    try {
      final remoteBanners = await _repository.getBanners();
      _banners = remoteBanners;
      _getBannersState = RequestState.success;
      notifyListeners();
    } on NetworkException catch (e) {
      _errorState = ErrorState(
        errorCode: e.errorCode,
        message: e.message,
        title: e.title,
      );
      _getBannersState = RequestState.error;
      notifyListeners();
    }
  }

  Future<void> _saveMils() async {
    try {
      await StorageHelper.prefs.setInt(
        _cacheKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {}
  }

  Future<void> _saveMilsOnFirstRun() async {
    if (!StorageHelper.containsKey(_cacheKey)) {
      try {
        await _saveMils();
      } catch (_) {}
    }
  }

  Future<bool> _shouldRevalidate(Duration cacheAge) async {
    try {
      await _saveMilsOnFirstRun();

      final savedMils = StorageHelper.prefs.getInt(_cacheKey);
      if (savedMils == null) return false;

      final latestSavedTime = DateTime.fromMillisecondsSinceEpoch(savedMils);
      final diff = DateTime.now().difference(latestSavedTime);

      if (diff >= cacheAge) {
        await _saveMils();
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }
}
