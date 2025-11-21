import 'package:flutter/material.dart';
import 'package:rakhsa/repositories/location/model/location_data.dart';
import 'package:weather/weather.dart';

class WeatherNotifier extends ChangeNotifier {
  final _weatherFactory = WeatherFactory(
    '067cd306a519e9153f2ae44e71c8b4f3',
    language: Language.INDONESIAN,
  );

  List<Weather> _weathers = [];
  List<Weather> get weathers => _weathers;

  bool _loading = true;
  bool get loading => _loading;

  bool _error = false;
  bool get error => _error;

  Coord? _lastCoord;

  String get celcius {
    if (_weathers.isEmpty) {
      return "32\u00B0C"; // fallback
    }
    return "${(_weathers.first.temperature?.celsius ?? 0).round()}\u00B0C";
  }

  String get description {
    if (_weathers.isEmpty) {
      return "Berawan"; // fallback
    }
    return "${_weathers.first.weatherDescription?.toUpperCase()}";
  }

  void updateFromLocation(LocationData? locationData) {
    final coord = locationData?.coord;
    if (coord == null) {
      _lastCoord = null;
      _weathers = [];
      _loading = false;
      _error = false;
      notifyListeners();
      return;
    }

    if (_lastCoord != null &&
        _lastCoord!.lat == coord.lat &&
        _lastCoord!.lng == coord.lng) {
      return;
    }

    _lastCoord = coord;
    getForecastWeather(lat: coord.lat, lng: coord.lng);
  }

  Future<void> getForecastWeather({double? lat, double? lng}) async {
    final latitude = lat ?? _lastCoord?.lat;
    final longitude = lng ?? _lastCoord?.lng;

    if (latitude != null && longitude != null) {
      _loading = true;
      _error = false;
      notifyListeners();

      try {
        final weathers = await _weatherFactory.fiveDayForecastByLocation(
          latitude,
          longitude,
        );

        _weathers = _extractUniqueDailyWeathers(weathers);
        notifyListeners();
      } catch (e) {
        _loading = false;
        _error = true;
      } finally {
        _loading = false;
        _error = false;
      }
    }
  }

  List<Weather> _extractUniqueDailyWeathers(List<Weather> weathers) {
    final Map<String, Weather> uniqueWeathers = {};

    for (var weather in weathers) {
      final date = weather.date;
      if (date == null) continue;

      final dateKey = "${date.year}-${date.month}-${date.day}";

      // Simpan hanya cuaca pertama untuk setiap tanggal
      uniqueWeathers.putIfAbsent(dateKey, () => weather);

      // Jika sudah 5 tanggal unik, hentikan iterasi
      if (uniqueWeathers.length == 5) break;
    }

    return uniqueWeathers.values.toList();
  }

  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 17) {
      return 'Selamat Siang';
    } else if (hour > 18) {
      return 'Selamat Malam';
    } else {
      return 'Selamat Sore';
    }
  }

  String getWeatherIcon(int? weatherConditionCode) {
    DateTime now = DateTime.now();
    bool isNight = now.hour >= 18 || now.hour < 6;

    // Map kondisi ke ikon
    final Map<int, String> dayIcons = {
      200: 'assets/images/weather/1.png', // petir
      300: 'assets/images/weather/2.png', // gerimis
      500: 'assets/images/weather/2.png', // hujan ringan
      502: 'assets/images/weather/3.png', // hujan lebat
      800: 'assets/images/weather/11.png', // cerah
      801: 'assets/images/weather/7.png', // cerah berawan
    };

    final Map<int, String> nightIcons = {
      800: 'assets/images/weather/12.png', // cerah malam
      801: 'assets/images/weather/12.png', // cerah berawan malam
    };

    if (isNight && nightIcons.containsKey(weatherConditionCode)) {
      return nightIcons[weatherConditionCode]!;
    }
    return dayIcons[weatherConditionCode] ?? 'assets/images/weather/8.png';
  }
}
