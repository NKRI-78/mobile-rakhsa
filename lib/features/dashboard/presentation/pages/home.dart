import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/helpers/capitalize.dart';
import 'package:rakhsa/common/utils/asset_source.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:rakhsa/main.dart';

import 'package:rakhsa/features/dashboard/presentation/pages/widgets/ews/list.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/widgets/header/header_home.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/widgets/home_highlight_banner.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/widgets/sos/button.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/weather_notifier.dart';

import 'package:rakhsa/firebase.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';


import 'package:rakhsa/common/routes/routes_navigation.dart';
import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/storage.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';

import 'package:rakhsa/features/dashboard/presentation/provider/update_address_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/dashboard_notifier.dart';
import 'package:rakhsa/socketio.dart';

class HomePage extends StatefulWidget {
  final GlobalKey<ScaffoldState> globalKey;
  const HomePage({
    required this.globalKey,
    super.key
  });

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {

  late FirebaseProvider firebaseNotifier;
  late DashboardNotifier dashboardNotifier;
  late UpdateAddressNotifier updateAddressNotifier;
  late ProfileNotifier profileNotifier;
  late WeatherNotifier weatherNotifier;
  late SocketIoService socketIoService;
  
  Position? currentLocation;
  StreamSubscription? subscription;

  bool isResumedProcessing = false;

  List<Marker> _markers = [];
  List<Marker> get markers => [..._markers];

  List<Widget> banners = []; 

  String currentAddress = "";
  String currentCountry = "";
  String currentLat = "";
  String currentLng = "";
  String subAdministrativeArea = '';

  bool isDialogLocationShowing = false;
  bool isDialogNotificationShowing = false;
  bool isDialogMicrophoneShowing = false;
  bool isDialogCameraShowing = false;
  
  bool loadingGmaps = true;

  Future<void> getData() async {
    if(!mounted) return;
      await profileNotifier.getProfile();

    if(!mounted) return;
      await firebaseNotifier.initFcm();
    
    if(!mounted) return; 
      await getCurrentLocation();
    
    if(!mounted) return;
      await dashboardNotifier.getBanner();

    if(!mounted) return;
      socketIoService.startListenConnection();
    
    initBanners();
    setStatusBarStyle();
  }

  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      forceAndroidLocationManager: true
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    String country = placemarks[0].country ?? "-";
    String street = placemarks[0].street ?? "-";
    String administrativeArea = placemarks[0].administrativeArea ?? "-";
    String subadministrativeArea = placemarks[0].subAdministrativeArea ?? "-"; 

    String address = "$administrativeArea $subadministrativeArea\n$street, $country";

    setState(() {
      currentAddress = address;
      currentCountry = country;
      subAdministrativeArea = subadministrativeArea;

      currentLat = position.latitude.toString();
      currentLng = position.longitude.toString();

      _markers = [];
      _markers.add(
        Marker(
          markerId: const MarkerId("currentPosition"),
          position: LatLng(
            position.latitude, 
            position.longitude
          ),
          icon: BitmapDescriptor.defaultMarker,
        )
      );
      
      loadingGmaps = false;
    });

    await weatherNotifier.getForecastWeather(
      double.parse(currentLat),
      double.parse(currentLng),
    );

    String celcius = "${(weatherNotifier.weathers.first.temperature?.celsius ?? 0).round()}\u00B0C";
    String weatherDesc = "${weatherNotifier.weathers.first.weatherDescription?.toUpperCase()}";

    Future.delayed(Duration.zero, () async {
      await updateAddressNotifier.updateAddress(
        address: address, 
        state: placemarks[0].country!,
        lat: position.latitude, 
        lng: position.longitude
      );

      StorageHelper.saveUserNationality(nationality: placemarks[0].country!);

      await dashboardNotifier.getEws(
        lat: position.latitude,
        lng: position.longitude,
        state: country,
      );

      await service.configure(
        iosConfiguration: IosConfiguration(
          autoStart: true,
          onForeground: onStart,
          onBackground: onIosBackground,
        ),
        androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          isForegroundMode: true,
          foregroundServiceNotificationId: 888,
          foregroundServiceTypes: [
            AndroidForegroundType.location
          ],
          initialNotificationTitle: "$celcius $subAdministrativeArea",
          initialNotificationContent: weatherDesc,
          notificationChannelId: "notification"
        ),
      );

      startBackgroundService();

    });
  }

  void initBanners() {
    banners.clear();

    banners.add(
      WeatherContent(
        subAdministrativeArea,
        LatLng(
          double.tryParse(currentLat) ?? 0.0,
          double.tryParse(currentLng) ?? 0.0,
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () async {
      for (var banner in dashboardNotifier.banners) {
        banners.add(ImgBanner(
          banner.link,
          banner.imageUrl,
        ));
      }
      setState(() {});
    });
  }

  void setStatusBarStyle(){
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: whiteColor,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

   @override
  void initState() {
    super.initState();
    
    firebaseNotifier = context.read<FirebaseProvider>();
    profileNotifier = context.read<ProfileNotifier>();
    updateAddressNotifier = context.read<UpdateAddressNotifier>();
    dashboardNotifier = context.read<DashboardNotifier>();
    weatherNotifier = context.read<WeatherNotifier>();
    socketIoService = context.read<SocketIoService>();

    socketIoService.connect();

    Future.microtask(() => getData());
  }

  @override
  void dispose() {
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [  
          SizedBox.expand(
            child: SafeArea(
              child: RefreshIndicator.adaptive(
              onRefresh: getData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                // padding bawah untuk memberikan ruang scrolling bagian bawah
                padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeaderSection(scaffoldKey: widget.globalKey),
                      const SizedBox(height: 16),

                      Container(
                        margin: const EdgeInsets.only(top: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text("Tekan & tahan tombol ini, \njika Anda dalam keadaan darurat.",
                                  textAlign: TextAlign.center,
                                  style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
              
                      Container(
                        margin: const EdgeInsets.only(top: 45),
                        child: SosButton(
                          location: currentAddress,
                          country: currentCountry,
                          lat: currentLat,
                          lng: currentLng,
                          loadingGmaps: loadingGmaps,
                          isConnected: context.watch<SocketIoService>().isConnected
                          ? true
                          : false,
                        )
                      ),
              
                      Consumer<DashboardNotifier>(
                        builder: (BuildContext context, DashboardNotifier notifier, Widget? child) {
                          
                          if(notifier.state == ProviderState.loading) {
                            return const SizedBox(
                              height: 200.0,
                              child: Center(
                                child: SizedBox(
                                  width: 16.0,
                                  height: 16.0,
                                  child: CircularProgressIndicator()
                                )
                              ),
                            );
                          }
              
                          if(notifier.state == ProviderState.error) {
                            return SizedBox(
                              height: 200.0,
                              child: Center(
                                child: Text(notifier.message,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: ColorResources.black,
                                  ),
                                )
                              )
                            );
                          }

                          if(notifier.bannerState == BannerProviderState.loading) {
                            return const SizedBox(
                              height: 200.0,
                              child: Center(
                                child: SizedBox(
                                  width: 16.0,
                                  height: 16.0,
                                  child: CircularProgressIndicator()
                                )
                              ),
                            );
                          }

                          if(notifier.bannerState == BannerProviderState.error) {
                            return SizedBox(
                              height: 200.0,
                              child: Center(
                                child: Text(notifier.message,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: ColorResources.black,
                                  ),
                                )
                              )
                            );
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.only(top: 45.0),
                            child: (notifier.ews.isNotEmpty) 
                            ? EwsListWidget(
                                getData: getData,
                              )
                            : HomeHightlightBanner(
                                banners: banners,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                ),
              ),
            ),
          ),
        
        const _BottomFadeEffect(),
      ],
    )); 
  }
}

class ImgBanner extends StatelessWidget {
  const ImgBanner(
    this.link,
    this.img, {super.key});

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
        placeholder: (_, ___) => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class WeatherContent extends StatelessWidget {
  const WeatherContent(
    this.area,
    this.coordinate, 
    {super.key}
  );

  final String area;
  final LatLng coordinate;

  void navigateToWeatherDetail(BuildContext context){
     Navigator.pushNamed(
      context,
      RoutesNavigation.weather,
      arguments: {
        'area': area,
        'coordinate': coordinate,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
     
    return SizedBox(
      height: 190,
      width: double.infinity,
      child: Material(
        color: Colors.grey.shade800,
        child: InkWell(
          onTap: () => navigateToWeatherDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<WeatherNotifier>(
              builder: (context, notifier, child) {
                return Column(
                  children: [
                    // cuaca hari ini
                    Expanded(
                      child: _todayWeather(notifier, area),
                    ),
                
                    // divider
                    const SizedBox(height: 8),
                                            
                    // ramalan cuaca 5 hari kedepan
                    _forecastWeather(notifier),
                  ],
                );
              }
            ),
          ),
        ),
      ),
    );
  }

  Widget _todayWeather(WeatherNotifier notifier, String area){
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
                style: robotoRegular.copyWith(
                  fontSize: 11,
                  color: whiteColor,
                ),
              ),
          
              // hari ini
              Text(
                DateFormat('EEEE, dd MMM yyyy', 'id').format(today.date ?? DateTime.now()),
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
              style: robotoRegular.copyWith(
                color: whiteColor,
                fontSize: 12,
              ),
            ),

            // suhu°C
            Text(
              '${(weather.temperature?.celsius ?? 0).round()} °C',
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: robotoRegular.copyWith(
                color: whiteColor,
                fontSize: 12,
              ),
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
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.5),
              Colors.white,
            ],
          ),
        ),
      ),
    );
  }
}
