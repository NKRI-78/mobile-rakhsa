import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/misc/utils/asset_source.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
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
        final area = p.location?.placemark?.subAdministrativeArea ?? "-";
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
                  child: Image.asset(
                    AssetSource.bgCardWeather,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // suhu & icon
        Flexible(
          fit: FlexFit.tight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // icon cuaca
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
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
                    textAlign: TextAlign.center,
                    style: robotoRegular.copyWith(
                      fontSize: 22,
                      color: whiteColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              Text(
                (today.weatherDescription ?? '').capitalizeEachWord(),
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(
                  fontSize: 10,
                  color: whiteColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // suhu & icon & wilayah
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // title hari ini
              Text(
                'Hari ini',
                overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(fontSize: 11, color: whiteColor),
              ),

              // hari ini
              Text(
                (today.date ?? DateTime.now()).format("EEEE, dd MMM yyyy"),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(
                  fontSize: 12,
                  color: whiteColor,
                  fontWeight: FontWeight.w500,
                ),
              ),

              // area
              Text(
                area,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(
                  fontSize: 11,
                  color: whiteColor,
                  fontWeight: FontWeight.w300,
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: notifier.weathers.map((weather) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: robotoRegular.copyWith(color: whiteColor, fontSize: 12),
            ),

            // suhu°C
            Text(
              '${(weather.temperature?.celsius ?? 0).round()} °C',
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: robotoRegular.copyWith(color: whiteColor, fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }
}
