import 'package:flutter/material.dart';
import 'package:weather/weather.dart';

class WeatherNotifier extends ChangeNotifier {
  final _apiKey = '067cd306a519e9153f2ae44e71c8b4f3';

  Weather? _weather;
  Weather? get weather => _weather;

  bool _loading = true;
  bool get loading => _loading;

  bool _error = false;
  bool get error => _error;

  Future<Weather> getCurrentWeather(double lat, double long) async {
    _loading = true;
    _error = false;
    notifyListeners();
    try {
      final wf = WeatherFactory(_apiKey, language: Language.INDONESIAN);

      final weather = await wf.currentWeatherByLocation(lat, long);

      _weather = weather;
      notifyListeners();

      return weather;
    } catch (e) {
      _loading = false;
      _error = true;
      notifyListeners();
      debugPrint(e.toString());
      throw Exception(e.toString());
    } finally {
      _loading = false;
      _error = false;
      notifyListeners();
    }
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

  String getWeatherIcon(int code) {
    switch (code) {
      case > 200 && < 300:
        return 'assets/images/weather/1.png';

      case > 300 && < 400:
        return 'assets/images/weather/2.png';

      case > 500 && < 600:
        return 'assets/images/weather/3.png';

      case > 600 && < 700:
        return 'assets/images/weather/4.png';

      case > 700 && < 800:
        return 'assets/images/weather/5.png';

      case == 800:
        return 'assets/images/weather/6.png';

      case > 800 && <= 804:
        return 'assets/images/weather/7.png';

      default:
        return 'assets/images/weather/7.png';
    }
  }
}
