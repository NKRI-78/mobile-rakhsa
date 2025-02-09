
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';
import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/weather_notifier.dart';

class HomeHightlightBanner extends StatelessWidget {
  const HomeHightlightBanner({
    super.key,
    required this.loadingGMaps, 
    required this.area,
    required this.coordinate,
  });

  final String area;
  final bool loadingGMaps;
  final LatLng coordinate;

  @override
  Widget build(BuildContext context) {
    final banners = [
      _WeatherContent(area, loadingGMaps, coordinate),
      const _ImgBanner(AssetSource.homeBanner),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 190,
          autoPlay: true,
          pageSnapping: true,
          viewportFraction: 1,
          autoPlayInterval: const Duration(seconds: 9),
          scrollPhysics: const BouncingScrollPhysics(),
        ),
        items: banners,
      ),
    );
  }
}

class _ImgBanner extends StatelessWidget {
  const _ImgBanner(this.img);

  final String img;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      img,
      fit: BoxFit.cover,
    );
  }
}

class _WeatherContent extends StatelessWidget {
  const _WeatherContent(
    this.area,
    this.loadingGMaps,
    this.coordinate,
  );

  final String area;
  final bool loadingGMaps;
  final LatLng coordinate;

  @override
  Widget build(BuildContext context) {
     
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.grey.shade200,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              RoutesNavigation.weather,
              arguments: {
                'area': area,
                'coordinate': coordinate,
              },
            );
          },
          child: Consumer<WeatherNotifier>(
            builder: (context, notifier, child) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // icon
                    Flexible(
                      flex: 2,
                      child: Image.asset(notifier.getWeatherIcon()),
                    ),
                    const SizedBox(width: 16),
                                            
                    // weather data
                    Flexible(
                      flex: 3,
                      fit: FlexFit.tight,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hari ini',
                            style: robotoRegular.copyWith(),
                          ),
                                      
                          // celcius
                          Text(
                            '${(notifier.weather?.temperature?.celsius ?? 0).round()}\u00B0C',
                            style: robotoRegular.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                            
                          // deskripsi cuaca
                          Text(
                            (notifier.weather?.weatherDescription ?? '').toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.clip,
                            style: robotoRegular.copyWith(
                              fontSize: 12,
                            ),
                          ),
                            
                          // kota
                          Text(
                            (notifier.loading && loadingGMaps)
                                ? 'Memuat'
                                : area,
                            maxLines: 2,
                            overflow: TextOverflow.clip,
                            style: robotoRegular.copyWith(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}