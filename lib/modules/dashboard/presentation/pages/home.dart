import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/misc/helpers/capitalize.dart';
import 'package:rakhsa/misc/utils/asset_source.dart';
import 'package:rakhsa/modules/profile/provider/profile_notifier.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:rakhsa/modules/dashboard/presentation/pages/widgets/ews/list.dart';
import 'package:rakhsa/modules/dashboard/presentation/pages/widgets/header/header_home.dart';
import 'package:rakhsa/modules/dashboard/presentation/pages/widgets/home_highlight_banner.dart';
import 'package:rakhsa/modules/dashboard/presentation/pages/widgets/sos/button.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/weather_notifier.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/material.dart';

import 'package:rakhsa/routes/routes_navigation.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/helpers/enum.dart';
import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

import 'package:rakhsa/modules/dashboard/presentation/provider/dashboard_notifier.dart';

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> globalKey;
  final Future<void> Function() onRefresh;
  final List<Widget> banners;
  final SosButtonParam sosButtonParam;

  const HomePage({
    required this.globalKey,
    required this.onRefresh,
    required this.banners,
    required this.sosButtonParam,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: SafeArea(
              child: RefreshIndicator.adaptive(
                onRefresh: onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  // padding bawah untuk memberikan ruang scrolling bagian bawah
                  padding: const EdgeInsets.only(
                    bottom: kBottomNavigationBarHeight,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HeaderSection(scaffoldKey: globalKey),
                        const SizedBox(height: 16),

                        Container(
                          margin: const EdgeInsets.only(top: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  "Tekan & tahan tombol ini, \njika Anda dalam keadaan darurat.",
                                  textAlign: TextAlign.center,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          margin: const EdgeInsets.only(top: 45),
                          child: Consumer<ProfileNotifier>(
                            builder: (context, data, child) {
                              return SosButton(
                                SosButtonParam(
                                  location: sosButtonParam.location,
                                  country: sosButtonParam.country,
                                  lat: sosButtonParam.lat,
                                  lng: sosButtonParam.lng,
                                  isConnected: sosButtonParam.isConnected,
                                  loadingGmaps: sosButtonParam.loadingGmaps,
                                  profile: data.entity.data,
                                ),
                              );
                            },
                          ),
                        ),

                        Consumer<DashboardNotifier>(
                          builder: (context, notifier, child) {
                            if (notifier.state == ProviderState.loading ||
                                notifier.bannerState ==
                                    BannerProviderState.loading) {
                              return Container(
                                margin: EdgeInsets.only(top: 32),
                                padding: EdgeInsets.all(16),
                                height: 200.0,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  spacing: 12,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.red,
                                        backgroundColor: Colors.red.shade50,
                                      ),
                                    ),
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: Text(
                                        "Memuat Informasi",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (notifier.state == ProviderState.error) {
                              return SizedBox(
                                height: 200.0,
                                child: Center(
                                  child: Text(
                                    notifier.message,
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: ColorResources.black,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 45.0),
                              child: (notifier.ews.isNotEmpty)
                                  ? EwsListWidget(
                                      getData: () {
                                        onRefresh();
                                      },
                                    )
                                  : HomeHightlightBanner(banners: banners),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const _BottomFadeEffect(),
        ],
      ),
    );
  }
}

class ImgBanner extends StatelessWidget {
  const ImgBanner(this.link, this.img, {super.key});

  final String link;
  final String img;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await launchUrl(Uri.parse(link));
      },
      child: CachedNetworkImage(
        imageUrl: img,
        errorWidget: (_, __, ___) => Image.asset(AssetSource.iconDefaultImg),
        placeholder: (_, ___) =>
            const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class WeatherContent extends StatelessWidget {
  const WeatherContent(this.area, this.coordinate, {super.key});

  final String area;
  final LatLng coordinate;

  void navigateToWeatherDetail(BuildContext context) {
    Navigator.pushNamed(
      context,
      RoutesNavigation.weather,
      arguments: {'area': area, 'coordinate': coordinate},
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AssetSource.bgCardWeather, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTap: () => navigateToWeatherDetail(context),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Consumer<WeatherNotifier>(
                  builder: (context, notifier, child) {
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
          ),
        ],
      ),
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
                DateFormat(
                  'EEEE, dd MMM yyyy',
                  'id',
                ).format(today.date ?? DateTime.now()),
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
              DateFormat('EE', 'id').format(weather.date ?? DateTime.now()),
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

class _BottomFadeEffect extends StatelessWidget {
  const _BottomFadeEffect();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.5),
              Colors.white,
            ],
          ),
        ),
      ),
    );
  }
}
