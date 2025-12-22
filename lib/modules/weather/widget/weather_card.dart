import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/core/extensions/extensions.dart';
import 'package:rakhsa/core/constants/assets.dart';
import 'package:rakhsa/modules/location/provider/location_provider.dart';
import 'package:rakhsa/modules/weather/page/weather_page.dart';
import 'package:rakhsa/modules/weather/provider/weather_notifier.dart';
import 'package:rakhsa/router/route_trees.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, p, child) {
        final plc = p.location?.placemark;
        final s1 = (plc?.subAdministrativeArea ?? "");
        final s2 = (plc?.country ?? "");
        final area = s1.isNotEmpty ? s1 : s2;

        return SizedBox(
          height: 190,
          width: double.infinity,
          child: GestureDetector(
            onTap: () => WeatherRoute(
              WeatherPageParams(
                area: area,
                lat: p.location?.coord.lat ?? 0.0,
                lng: p.location?.coord.lng ?? 0.0,
              ),
            ).go(context),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(Assets.imagesWeatherBg, fit: .cover),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const .all(16),
                    child: Consumer<WeatherNotifier>(
                      builder: (context, notifier, child) {
                        if (notifier.loading) return Container();
                        return Column(
                          children: [
                            // cuaca hari ini
                            Expanded(child: _todayWeather(notifier, area)),

                            // divider
                            const SizedBox(height: 8),

                            // ramalan cuaca 5 hari kedepan
                            _forecastWeather(notifier),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _todayWeather(WeatherNotifier notifier, String area) {
    final today = notifier.weathers.first;
    return Row(
      crossAxisAlignment: .start,
      mainAxisAlignment: .spaceBetween,
      children: [
        // suhu & icon
        Flexible(
          fit: .tight,
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              // icon cuaca
              Row(
                children: [
                  ClipRRect(
                    borderRadius: .circular(100),
                    child: Image.asset(
                      notifier.getWeatherIcon(
                        notifier.weathers.first.weatherConditionCode,
                      ),
                      height: 48,
                    ),
                  ),
                  const SizedBox(width: 8),

                  Text(
                    '${(today.temperature?.celsius ?? 0).round()} °C',
                    textAlign: .center,
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: .bold,
                    ),
                  ),
                ],
              ),

              Text(
                (today.weatherDescription ?? '').capitalizeEachWord(),
                maxLines: 1,
                textAlign: .center,
                overflow: .ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: .w500,
                ),
              ),
            ],
          ),
        ),

        // suhu & icon & wilayah
        Flexible(
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .end,
            children: [
              // title hari ini
              Text(
                'Hari ini',
                overflow: .ellipsis,
                style: TextStyle(fontSize: 11, color: Colors.white),
              ),

              // hari ini
              Text(
                (today.date ?? DateTime.now()).format("EEEE, dd MMM yyyy"),
                textAlign: .end,
                overflow: .ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: .w500,
                ),
              ),

              // area
              Text(
                area,
                textAlign: .end,
                overflow: .ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: .w300,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _forecastWeather(WeatherNotifier notifier) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: notifier.weathers.map((weather) {
        return Column(
          mainAxisAlignment: .spaceBetween,
          children: [
            // icon cuaca
            Image.asset(
              notifier.getWeatherIcon(weather.weatherConditionCode),
              height: 30,
            ),

            // hari
            Text(
              (weather.date ?? DateTime.now()).format("EE"),
              maxLines: 1,
              textAlign: .center,
              overflow: .ellipsis,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),

            // suhu°C
            Text(
              '${(weather.temperature?.celsius ?? 0).round()} °C',
              maxLines: 1,
              textAlign: .center,
              overflow: .ellipsis,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }
}
