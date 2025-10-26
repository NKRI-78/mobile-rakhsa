
import 'package:flutter/material.dart';
import 'package:weather/weather.dart';

class WeatherNotifier extends ChangeNotifier {

  final WeatherFactory _weatherFactory;

  WeatherNotifier({required WeatherFactory weather}) : _weatherFactory = weather;

  List<Weather> _weathers = [];
  List<Weather> get weathers => _weathers;

  bool _loading = true;
  bool get loading => _loading;

  bool _error = false;
  bool get error => _error;

  Future<void> getForecastWeather(double lat, double long) async {
    _loading = true;
    _error = false;
    notifyListeners();
    try {
      final weathers = await _weatherFactory.fiveDayForecastByLocation(lat, long);

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
