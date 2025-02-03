import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/widgets/ews/list.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/widgets/ews/single.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/widgets/location/current_location.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/widgets/sos/button.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/weather_notifier.dart';
import 'package:rakhsa/firebase.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:rakhsa/main.dart';

import 'package:rakhsa/shared/basewidgets/modal/modal.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';

import 'package:rakhsa/features/dashboard/presentation/provider/update_address_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/dashboard_notifier.dart';

import 'package:rakhsa/websockets.dart';

class HomePage extends StatefulWidget {
  final GlobalKey<ScaffoldState> globalKey;
  const HomePage({
    required this.globalKey,
    super.key
  });

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with WidgetsBindingObserver {

  late FirebaseProvider firebaseProvider;
  late DashboardNotifier dashboardNotifier;
  late UpdateAddressNotifier updateAddressNotifier;
  late ProfileNotifier profileNotifier;
  late WeatherNotifier weatherNotifier;
  late WebSocketsService webSocketsService;
  
  Position? currentLocation;
  StreamSubscription? subscription;

  bool isResumedProcessing = false;

  List<Marker> _markers = [];
  List<Marker> get markers => [..._markers];

  String currentAddress = "";
  String currentCountry = "";
  String currentLat = "";
  String currentLng = "";
  String subAdministrativeArea = '';

  bool isDialogLocationShowing = false;
  bool isDialogNotificationShowing = false;
  
  bool loadingGmaps = true;

  Future<void> getData() async {
    if(!mounted) return;
      await profileNotifier.getProfile();

    if(!mounted) return;
      await firebaseProvider.initFcm();

    if(!mounted) return;
      await requestNotificationPermission();

     if(!mounted) return;
      await requestLocationPermission();
  }

  Future<void> requestNotificationPermission() async {
    await Permission.notification.request();
  }

  Future<void> requestLocationPermission() async {
    await Permission.location.request();

    await getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      
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

      await weatherNotifier.getCurrentWeather(
        double.parse(currentLat),
        double.parse(currentLng),
      );

      String celcius = "${(weatherNotifier.weather?.temperature?.celsius ?? 0).round()}\u00B0C";
      String weatherDesc = "${weatherNotifier.weather?.weatherDescription?.toUpperCase()}";

      Future.delayed(Duration.zero, () async {
        await updateAddressNotifier.updateAddress(
          address: address, 
          lat: position.latitude, 
          lng: position.longitude
        );

        StorageHelper.saveUserNationality(nationality: placemarks[0].country!);

        await dashboardNotifier.getEws(
          lat: position.latitude,
          lng: position.longitude
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
            foregroundServiceNotificationId: notificationId,
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
    } catch(e) {

      checkLocationPermission();

    }
  }

  Future<void> checkNotificationPermission() async {
    bool isNotificationDenied = await Permission.notification.isDenied;

    if(isNotificationDenied) {
      if (!isDialogNotificationShowing) {
        setState(() => isDialogNotificationShowing = true);
        await GeneralModal.dialogRequestPermission(
          msg: "Izin Notifikasi Dibutuhkan",
          type: "notification"
        );
        Future.delayed(const Duration(seconds: 2),() {
          setState(() => isDialogNotificationShowing = false);
        });

        return;
      }
    }
  }

  Future<void> checkLocationPermission() async {
    bool isLocationDenied = await Permission.location.isDenied || await Permission.location.isPermanentlyDenied;

    bool isGpsEnabled = await Geolocator.isLocationServiceEnabled();

    if(!isGpsEnabled) {
      if (!isDialogLocationShowing) {
        setState(() => isDialogLocationShowing = true);
        await GeneralModal.dialogRequestPermission(
          msg: "Perizinan akses lokasi dibutuhkan, silahkan aktifkan terlebih dahulu",
          type: "location-gps"
        );

        Future.delayed(const Duration(seconds: 2),() {
          setState(() => isDialogLocationShowing = false);
        });
      }
    } else {
      await checkNotificationPermission();
    }

    if(isLocationDenied) {
      if (!isDialogLocationShowing) {
        setState(() => isDialogLocationShowing = true);
        await GeneralModal.dialogRequestPermission(
          msg: "Perizinan akses lokasi dibutuhkan, silahkan aktifkan terlebih dahulu",
          type: "location-app"
        );

        Future.delayed(const Duration(seconds: 2),() {
          setState(() => isDialogLocationShowing = false);
        });
      }
    } else {
      await checkNotificationPermission();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && !isResumedProcessing) {
      debugPrint("=== APP RESUME ===");

      isResumedProcessing = true;

      await Future.delayed(const Duration(milliseconds: 500)); 
    
      await getData();

      isResumedProcessing = false;
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    
    firebaseProvider = context.read<FirebaseProvider>();
    profileNotifier = context.read<ProfileNotifier>();
    updateAddressNotifier = context.read<UpdateAddressNotifier>();
    dashboardNotifier = context.read<DashboardNotifier>();
    weatherNotifier = context.read<WeatherNotifier>();
    webSocketsService = context.read<WebSocketsService>();

    Future.microtask(() => getData());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Provider.of<WebSocketsService>(context);

    return Scaffold(
      body: Stack(
          children: [  
            SizedBox.expand(
              child: SafeArea(
                child: RefreshIndicator.adaptive(
                onRefresh: () {
                  return Future.sync(() {
                    getData();
                  });
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.only(
                      top: 16.0,
                      left: 14.0,
                      right: 14.0,
                      bottom: 16.0
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StorageHelper.getUserId() == null
                        ? const SizedBox()
                        : context.watch<ProfileNotifier>().state == ProviderState.error 
                        ? const SizedBox()
                        : context.watch<ProfileNotifier>().state == ProviderState.loading 
                        ? const SizedBox()
                        : _HeaderSection(scaffoldKey: widget.globalKey, profileNotifier: profileNotifier),
                        const SizedBox(height: 16),
                
                         _WelcomeAndWeatherSection(
                          loadingLocation: loadingGmaps,
                          coordinate: LatLng(
                            double.tryParse(currentLat) ?? 0.0,
                            double.tryParse(currentLng) ?? 0.0,
                          ),
                          area: subAdministrativeArea,
                        ),

                        Container(
                          margin: const EdgeInsets.only(top: 30.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  "Tekan & tahan tombol ini, \njika Anda dalam keadaan darurat.",
                                  textAlign: TextAlign.center,
                                  style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        ),
                
                        Container(
                          margin: const EdgeInsets.only(
                            top: 40.0
                          ),
                          child: SosButton(
                            location: currentAddress,
                            country: currentCountry,
                            lat: currentLat,
                            lng: currentLng,
                            loadingGmaps: loadingGmaps,
                            isConnected: context.watch<WebSocketsService>().isConnected ? true : false,
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
                                      color: ColorResources.black
                                    ),
                                  )
                                )
                              );
                            }
                            
                            return notifier.ews.isEmpty 
                            ? CurrentLocationWidget(
                                avatar: context.read<ProfileNotifier>().entity.data?.avatar.toString() ?? "",
                                loadingGmaps: loadingGmaps, 
                                markers: markers, 
                                currentAddress: currentAddress, 
                                currentLat: currentLat, 
                                currentLng: currentLng
                              )
                            : Container(
                                margin: const EdgeInsets.only(
                                  top: 45.0
                                ),
                                child: notifier.ews.length == 1 
                                ? EwsSingleWidget(
                                  getData: getData
                                )
                              : EwsListWidget(
                                getData: getData,
                              )
                            );
                          }
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
      )
    ); 
  }
}



class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.scaffoldKey,
    required this.profileNotifier,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;
  final ProfileNotifier profileNotifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: GestureDetector(
            onTap: () => scaffoldKey.currentState?.openEndDrawer(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CachedNetworkImage(
                  imageUrl: profileNotifier.entity.data?.avatar ?? "-",
                  imageBuilder: (BuildContext context,
                      ImageProvider<Object> imageProvider) {
                    return CircleAvatar(
                      backgroundImage: imageProvider,
                    );
                  },
                  placeholder: (BuildContext context, String url) {
                    return const CircleAvatar(
                      backgroundImage: AssetImage('assets/images/default.jpeg'),
                    );
                  },
                  errorWidget:
                      (BuildContext context, String url, Object error) {
                    return const CircleAvatar(
                      backgroundImage: AssetImage('assets/images/default.jpeg'),
                    );
                  },
                )
              ],
            ),
          ),
        ),
        Container(
          width: 14.0,
          height: 14.0,
          decoration: BoxDecoration(
            color: context.watch<WebSocketsService>().connectionIndicator ==
                ConnectionIndicator.green
                ? ColorResources.green
                : context.watch<WebSocketsService>().connectionIndicator ==
                    ConnectionIndicator.yellow
                    ? ColorResources.yellow
                    : context.watch<WebSocketsService>().connectionIndicator ==
                            ConnectionIndicator.red
                        ? ColorResources.error
                        : ColorResources.transparent,
            shape: BoxShape.circle,
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, RoutesNavigation.chats);
          },
          icon: const Icon(Icons.notifications)
        )
      ],
    );
  }
}

class _WelcomeAndWeatherSection extends StatelessWidget {
  const _WelcomeAndWeatherSection({
    required this.area,
    required this.coordinate,
    required this.loadingLocation,
  });

  final String? area;
  final LatLng coordinate;
  final bool loadingLocation;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Selamat Datang",
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: ColorResources.hintColor
                ),
              ),
              Consumer<ProfileNotifier>(
                builder: (context, provider, child) {
                  return SizedBox(
                    width: 150.0,
                    child: Text(
                      provider.entity.data?.username ?? "-",
                      overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: Dimensions.fontSizeLarge
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        InkWell(
          onTap: loadingLocation
          ? null
          : () => Navigator.pushNamed(
            context,
            RoutesNavigation.weather,
            arguments: {
              'area': area,
              'coordinate': coordinate,
            },
          ),
          borderRadius: BorderRadius.circular(8),
          child: Consumer<WeatherNotifier>(
            builder: (context, provider, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // cloud asset
                      Image.asset(
                        provider.getWeatherIcon(
                            provider.weather?.weatherConditionCode ?? 300),
                        width: 32,
                        height: 32,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(provider.weather?.temperature?.celsius ?? 0).round()}\u00B0C',
                        style: robotoRegular.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                  Text(
                    (provider.loading && loadingLocation)
                        ? 'Memuat'
                        : area ?? 'Memuat Alamat',
                    style: robotoRegular.copyWith(
                      fontSize: 10,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
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
