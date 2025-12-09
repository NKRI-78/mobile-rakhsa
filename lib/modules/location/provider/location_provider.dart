import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rakhsa/build_config.dart';
import 'package:rakhsa/misc/client/errors/errors.dart';
import 'package:rakhsa/misc/enums/request_state.dart';
import 'package:rakhsa/service/storage/storage.dart';
import 'package:rakhsa/misc/utils/logger.dart';

import 'package:rakhsa/repositories/location/model/location_data.dart';
export 'package:rakhsa/repositories/location/model/location_data.dart';

class LocationProvider extends ChangeNotifier {
  final List<String> allowedCountries;

  LocationProvider({this.allowedCountries = const <String>["SG"]});

  LocationData? _locationData;
  LocationData? get location => _locationData;

  String? get iSOCountryCode => _locationData?.placemark?.isoCountryCode;

  bool get isCountryAllowed {
    if (iSOCountryCode == null) return false;
    return allowedCountries.contains(iSOCountryCode);
  }

  RequestState _getLocationState = RequestState.idle;
  bool isGetLocationState(RequestState state) => _getLocationState == state;

  bool _isLocationCacheActive = false;
  bool get isLocationCacheActive => _isLocationCacheActive;

  String? _errMessage;
  String? get errGetCurrentLocation => _errMessage;

  final prefs = StorageHelper.sharedPreferences;
  final _revalidateCacheKey = "location_revalidate_cache_key";

  LocationSettings getLocationSettings({
    LocationAccuracy accuracy = LocationAccuracy.best,
    Duration timeLimit = const Duration(seconds: 10),
  }) {
    if (Platform.isIOS) {
      return AppleSettings(accuracy: accuracy, timeLimit: timeLimit);
    } else {
      return AndroidSettings(accuracy: accuracy, timeLimit: timeLimit);
    }
  }

  Future<LocationData?> getCurrentLocation({
    bool enableCache = true,
    Duration? cacheAge,
  }) async {
    final defCacheAge =
        cacheAge ?? Duration(minutes: BuildConfig.isProd ? 30 : 1);

    final activeDuration = _checkCacheAgeIsActive(defCacheAge);
    _isLocationCacheActive = activeDuration;
    notifyListeners();

    log(
      "loading getCurrentLocation... | enableCache? $enableCache",
      label: "LOCATION_PROVIDER",
    );
    _getLocationState = RequestState.loading;
    notifyListeners();

    if (enableCache && _locationData != null) {
      // dibaca sayy 😗
      // init last update revalidate date time
      // pas aplikasi pertama kali dibuka
      if (!prefs.containsKey(_revalidateCacheKey)) {
        await _initCacheTimeOnFirstRun();
      }

      final needRefresh = await _shouldRevalidateLocationCache(defCacheAge);
      log(
        "enableCache && hasLocationData? ${enableCache && _locationData != null} | needRefresh? $needRefresh",
        label: "LOCATION_PROVIDER",
      );
      if (!needRefresh) {
        _getLocationState = RequestState.success;
        notifyListeners();
        log(
          "location data dari cache = ${_locationData?.toString() ?? "-"}",
          label: "LOCATION_PROVIDER",
        );
        return _locationData;
      }
    }

    try {
      final isGPSEnabled = await Geolocator.isLocationServiceEnabled();
      log("hasGPS? $isGPSEnabled", label: "LOCATION_PROVIDER");
      if (!isGPSEnabled) {
        throw LocationException(LocationError.gpsDisabled);
      }

      final hasPermission = await Geolocator.checkPermission()
          .then((p) {
            return p == LocationPermission.always ||
                p == LocationPermission.whileInUse;
          })
          .onError((e, st) => false);
      log("hasPermission? $hasPermission", label: "LOCATION_PROVIDER");
      if (!hasPermission) {
        throw LocationException(LocationError.deniedPermission);
      }

      final newLocation =
          await Geolocator.getCurrentPosition(
            locationSettings: getLocationSettings(),
          ).then((p) {
            return LocationData(coord: Coord(p.latitude, p.longitude));
          });
      log(
        "newLocation = ${newLocation.coord.toString()}",
        label: "LOCATION_PROVIDER",
      );
      final newPlacemark =
          await placemarkFromCoordinates(
            newLocation.coord.lat,
            newLocation.coord.lng,
          ).then((placemarks) {
            if (placemarks.isEmpty) return null;
            return placemarks[0];
          });
      log(
        "newPlacemark = ${newPlacemark?.toString() ?? "-"}",
        label: "LOCATION_PROVIDER",
      );

      // set state
      _locationData = newLocation.copyWith(placemark: newPlacemark);
      _getLocationState = RequestState.success;
      notifyListeners();
      log(
        "newLocation data = ${_locationData?.toString() ?? "-"}",
        label: "LOCATION_PROVIDER",
      );

      return newLocation;
    } on LocationException catch (e) {
      _errMessage = e.error.getMessage();
      _getLocationState = RequestState.error;
      notifyListeners();
      log("error LocationException = $_errMessage", label: "LOCATION_PROVIDER");
      return null;
    } catch (e) {
      final msg = "Terjadi kesahalan yang tidak diketahui, ${e.toString()}";
      _errMessage = msg;
      _getLocationState = RequestState.error;
      notifyListeners();
      log("error UnhandledException = $msg", label: "LOCATION_PROVIDER");
      return null;
    }
  }

  Future<void> _initCacheTimeOnFirstRun() async {
    await prefs.setInt(
      _revalidateCacheKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  bool _checkCacheAgeIsActive(Duration cacheAge) {
    return cacheAge == Duration.zero;
  }

  Future<bool> _shouldRevalidateLocationCache(Duration maxAge) async {
    final lastUpdatedMs = prefs.getInt(_revalidateCacheKey);

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    if (lastUpdatedMs == null) {
      await prefs.setInt(_revalidateCacheKey, nowMs);
      return true;
    }

    final lastUpdated = DateTime.fromMillisecondsSinceEpoch(lastUpdatedMs);
    final diff = DateTime.now().difference(lastUpdated);

    final shouldRevalidate = diff > maxAge;

    if (shouldRevalidate) {
      await prefs.setInt(_revalidateCacheKey, nowMs);
    }

    return shouldRevalidate;
  }
}
