import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/helpers/device.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/widgets/sos/button.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/update_address_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/weather_notifier.dart';
import 'package:rakhsa/features/information/presentation/pages/list.dart';
import 'package:rakhsa/features/nearme/presentation/pages/near_me_page_list_type.dart';

import 'package:rakhsa/firebase.dart';

import 'package:rakhsa/features/dashboard/presentation/provider/dashboard_notifier.dart';
import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/home.dart';
import 'package:rakhsa/main.dart';

import 'package:rakhsa/shared/basewidgets/drawer/drawer.dart';

import 'package:rakhsa/common/helpers/storage.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/socketio.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  final globalKey = GlobalKey<ScaffoldState>();

  final _pageNotifyController = ValueNotifier<int>(0);
  final _pageController = PageController();

  late FirebaseProvider firebaseProvider;
  late DashboardNotifier dashboardNotifier;
  late SocketIoService socketIoService;
  late ProfileNotifier profileNotifier;
  late WeatherNotifier weatherNotifier;
  late UpdateAddressNotifier updateAddressNotifier;

  Position? currentLocation;
  StreamSubscription? subscription;

  bool isResumedProcessing = false;

  List<Marker> _markers = [];
  List<Marker> get markers => [..._markers];

  bool loadingGmaps = true;

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

  DateTime? lastTap;

  bool _newAndroidVersion = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      StorageHelper.setIsLocked(val: true);
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
    socketIoService = context.read<SocketIoService>();

    Future.delayed(Duration(seconds: 2)).then((value) {
      socketIoService.connect();
    });

    Future.microtask(() => getData());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageNotifyController.dispose();
    _pageController.dispose();

    super.dispose();
  }

  Future<void> getData() async {
    if (!mounted) return;
    await profileNotifier.getProfile();

    if (!mounted) return;
    await firebaseProvider.initFcm();

    final androidVersion = await getAndroidVersion();
    _newAndroidVersion = androidVersion >= 35;
    log('Androidversion = $androidVersion');
    log("_newAndroidVersion? $_newAndroidVersion");

    if (!mounted) return;
    await getCurrentLocation();

    if (!mounted) return;
    await dashboardNotifier.getBanner();

    if (!mounted) return;
    socketIoService.startListenConnection();

    initBanners();
    setStatusBarStyle();
  }

  _onPageChanged(int index) {
    _pageController.jumpToPage(index);
    _pageNotifyController.value = index;
  }

  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.best,
        forceLocationManager: true,
      ),
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    String country = placemarks[0].country ?? "-";
    String street = placemarks[0].street ?? "-";
    String administrativeArea = placemarks[0].administrativeArea ?? "-";
    String subadministrativeArea = placemarks[0].subAdministrativeArea ?? "-";

    String address =
        "$administrativeArea $subadministrativeArea\n$street, $country";

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
          position: LatLng(position.latitude, position.longitude),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );

      loadingGmaps = false;
    });

    await weatherNotifier.getForecastWeather(
      double.parse(currentLat),
      double.parse(currentLng),
    );

    String celcius =
        "${(weatherNotifier.weathers.first.temperature?.celsius ?? 0).round()}\u00B0C";
    String weatherDesc =
        "${weatherNotifier.weathers.first.weatherDescription?.toUpperCase()}";

    Future.delayed(Duration.zero, () async {
      await updateAddressNotifier.updateAddress(
        address: address,
        state: placemarks[0].country!,
        lat: position.latitude,
        lng: position.longitude,
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
          foregroundServiceTypes: [AndroidForegroundType.location],
          initialNotificationTitle: "$celcius $subAdministrativeArea",
          initialNotificationContent: weatherDesc,
          notificationChannelId: "notification",
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
        banners.add(ImgBanner(banner.link, banner.imageUrl));
      }
      setState(() {});
    });
  }

  void setStatusBarStyle() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: whiteColor,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (lastTap == null) {
          lastTap = DateTime.now();
          ShowSnackbar.snackbarDefault('Tekan sekali lagi untuk keluar');
        } else {
          if (DateTime.now().difference(lastTap!) <
              const Duration(seconds: 2)) {
            SystemNavigator.pop();
          } else {
            lastTap = DateTime.now();
            ShowSnackbar.snackbarDefault('Tekan sekali lagi untuk keluar');
          }
        }
      },
      child: Scaffold(
        key: globalKey,

        // PROFIlE DRAWER
        endDrawer: SafeArea(child: DrawerWidget(globalKey: globalKey)),

        // HOME PAGE
        body: ValueListenableBuilder(
          valueListenable: _pageNotifyController,
          builder: (context, currentPageIndex, child) {
            return PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                HomePage(
                  globalKey: globalKey,
                  onRefresh: () => getData(),
                  banners: banners,
                  sosButtonParam: SosButtonParam(
                    location: currentAddress,
                    country: currentCountry,
                    lat: currentLat,
                    lng: currentLng,
                    profile: profileNotifier.entity.data,
                    loadingGmaps: loadingGmaps,
                    isConnected: context.watch<SocketIoService>().isConnected
                        ? true
                        : false,
                  ),
                ),
                InformationListPage(),
                NearMeListTypePage(),
              ],
            );
          },
        ),

        // BOTTOM NAV BAR
        bottomNavigationBar: ValueListenableBuilder(
          valueListenable: _pageNotifyController,
          builder: (context, currentPage, child) {
            return BottomNavigationBar(
              currentIndex: currentPage,
              onTap: _onPageChanged,
              selectedFontSize: 14,
              unselectedFontSize: 14,
              backgroundColor: primaryColor,
              selectedItemColor: whiteColor,
              unselectedItemColor: whiteColor.withValues(alpha: 0.7),
              items: [
                BottomNavigationBarItem(
                  icon: Icon(IconsaxPlusLinear.home_1),
                  activeIcon: Icon(IconsaxPlusBold.home_1),
                  label: "Home",
                  tooltip: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(IconsaxPlusLinear.document),
                  activeIcon: Icon(IconsaxPlusBold.document),
                  label: "Information",
                  tooltip: "Information",
                ),
                BottomNavigationBarItem(
                  icon: Icon(IconsaxPlusLinear.location),
                  activeIcon: Icon(IconsaxPlusBold.location),
                  label: "Near Me",
                  tooltip: "Near Me",
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
