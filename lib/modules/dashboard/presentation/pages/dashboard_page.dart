import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:location/location.dart' as location;
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/build_config.dart';
import 'package:rakhsa/core/constants/assets.dart';
import 'package:rakhsa/core/constants/colors.dart';
import 'package:rakhsa/modules/dashboard/presentation/widgets/welcome_dialog.dart';
import 'package:rakhsa/modules/referral/provider/referral_provider.dart';
import 'package:rakhsa/modules/auth/provider/auth_provider.dart';
import 'package:rakhsa/modules/dashboard/presentation/widgets/image_banner.dart';
import 'package:rakhsa/modules/weather/widget/weather_card.dart';
import 'package:rakhsa/router/route_trees.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/update_address_notifier.dart';
import 'package:rakhsa/modules/information/presentation/pages/information_page.dart';
import 'package:rakhsa/modules/location/provider/location_provider.dart';
import 'package:rakhsa/modules/nearme/presentation/pages/near_me_places_page.dart';

import 'package:rakhsa/modules/dashboard/presentation/provider/dashboard_notifier.dart';
import 'package:rakhsa/modules/app/provider/user_provider.dart';
import 'package:rakhsa/modules/dashboard/presentation/pages/home_page.dart';
import 'package:rakhsa/core/extensions/extensions.dart';
import 'package:rakhsa/service/haptic/haptic_service.dart';
import 'package:rakhsa/service/location/location_service.dart';
import 'package:rakhsa/service/notification/notification_manager.dart';
import 'package:rakhsa/service/permission/permission_manager.dart';

import 'package:rakhsa/modules/dashboard/presentation/widgets/home_drawer.dart';

import 'package:rakhsa/service/storage/storage.dart';
import 'package:rakhsa/service/socket/socketio.dart';
import 'package:rakhsa/widgets/dialog/dialog.dart';
import 'package:rakhsa/widgets/overlays/status_bar_style.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, this.fromRegister = false});

  final bool fromRegister;

  @override
  State<DashboardPage> createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _pageNotifyController = ValueNotifier<int>(0);
  final _pageController = PageController();

  late DashboardNotifier dashboardNotifier;
  late SocketIoService socketIoService;
  late UserProvider profileNotifier;
  late LocationProvider locationProvider;
  late ReferralProvider referralProvider;
  late AuthProvider authProvider;
  late UpdateAddressNotifier updateAddressNotifier;

  bool _openedSettings = false;
  bool _hasPermissionDialogLaunchBefore = false;

  List<Widget> banners = [];

  DateTime? lastTap;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    profileNotifier = context.read<UserProvider>();
    updateAddressNotifier = context.read<UpdateAddressNotifier>();
    dashboardNotifier = context.read<DashboardNotifier>();
    locationProvider = context.read<LocationProvider>();
    socketIoService = context.read<SocketIoService>();
    authProvider = context.read<AuthProvider>();
    referralProvider = context.read<ReferralProvider>();

    Future.delayed(Duration(seconds: 1)).then((value) {
      socketIoService.connect();
    });

    Future.microtask(() => getData());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendLatestLocation();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (!_openedSettings) return;
      if (_hasPermissionDialogLaunchBefore) return;
      _openedSettings = false;
      _hasPermissionDialogLaunchBefore = true;
      await PermissionManager().requestAllPermissionsWithHandler(
        parentContext: context,
        customPermission: [Permission.location],
        onRequestPermanentlyDenied: () {
          _openedSettings = true;
          _hasPermissionDialogLaunchBefore = false;
        },
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageNotifyController.dispose();
    _pageController.dispose();

    super.dispose();
  }

  Future<void> getData() async {
    await StorageHelper.loadlocalSession();

    if (!mounted) return;
    await profileNotifier.getUser();

    if (mounted && widget.fromRegister) {
      WelcomeDialog.launch(context);
    }

    if (BuildConfig.isProd) {
      final package = await profileNotifier.getRoamingPackage();
      if (!mounted) return;
      if (!referralProvider.roamingIsActive(package)) {
        AppDialog.error(
          c: context,
          canPop: false,
          title: "Masa Paket Roaming Telah Habis",
          message:
              "Masa paket roaming Anda telah berakhir. Layanan Marlinda tidak dapat digunakan sampai Anda membeli paket roaming baru.",
          buildActions: (c) {
            return [
              DialogActionButton(
                label: "Keluar",
                primary: true,
                onTap: () async {
                  c.pop();
                  AppDialog.showLoading(context);

                  await authProvider.logout(context);

                  AppDialog.dismissLoading();

                  if (!mounted) return;
                  WelcomeRoute().go(context);
                },
              ),
            ];
          },
        );
        return;
      }
    }

    if (!mounted) return;
    await NotificationManager().initializeFcmToken();

    if (!mounted) return;
    await getCurrentLocation();

    if (!mounted) return;
    await dashboardNotifier.getBanner();

    initBanners();
  }

  void _onPageChanged(int index) {
    _pageController.jumpToPage(index);
    _pageNotifyController.value = index;
    HapticService.instance.lightImpact();
  }

  Future<void> getCurrentLocation() async {
    await PermissionManager().requestAllPermissionsWithHandler(
      parentContext: context,
      customPermission: [Permission.location],
      onRequestPermanentlyDenied: () {
        _openedSettings = true;
        _hasPermissionDialogLaunchBefore = false;
      },
    );

    final gpsEnabled = await Geolocator.isLocationServiceEnabled();
    if (!gpsEnabled) {
      if (mounted) {
        bool? openSetting = await AppDialog.show(
          c: context,
          content: DialogContent(
            assetIcon: Assets.imagesDialogLocation,
            title: "GPS Tidak Aktif",
            message:
                "Mohon aktifkan GPS agar aplikasi Marlinda dapat mendeteksi lokasi Anda dengan akurat dan memungkinkan Anda menggunakan layanan SOS.",
            buildActions: (dc) => [
              DialogActionButton(
                label: "Aktifkan GPS",
                primary: true,
                onTap: () => dc.pop(true),
              ),
            ],
          ),
        );
        if (openSetting != null && openSetting) {
          await location.Location().requestService();
        }
      }
      return;
    }

    await locationProvider.getCurrentLocation();

    final newLocation = locationProvider.location;

    if (newLocation != null) {
      final placemark = newLocation.placemark;
      final coord = newLocation.coord;

      Future.delayed(.zero, () async {
        await updateAddressNotifier.updateAddress(
          address: placemark?.getAddress() ?? "-",
          state: placemark?.country ?? "-",
          lat: coord.lat,
          lng: coord.lng,
        );

        StorageHelper.saveUserNationality(
          nationality: placemark?.country ?? "-",
        );

        await dashboardNotifier.getEws(
          lat: coord.lat,
          lng: coord.lng,
          state: placemark?.country ?? "-",
        );
      });
    }
  }

  Future<bool> _shouldSendLatestLocation({
    Duration sendInterval = const Duration(hours: 20),
  }) async {
    final prefs = StorageHelper.prefs;
    final key = "dashboard_latest_location_cache_key";

    final savedMils = prefs.getInt(key);

    try {
      if (savedMils == null) {
        await prefs.setInt(key, DateTime.now().millisecondsSinceEpoch);
        return true;
      }

      // bandingkan waktu
      final latestSavedTime = DateTime.fromMillisecondsSinceEpoch(savedMils);
      final diff = DateTime.now().difference(latestSavedTime);

      // kalau udah waktunya
      if (diff >= sendInterval) {
        await prefs.setInt(key, DateTime.now().millisecondsSinceEpoch);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  void _sendLatestLocation() async {
    if (widget.fromRegister) return;
    if (await _shouldSendLatestLocation()) {
      await sendLatestLocation(
        "User open the App",
        otherSource: locationProvider.location,
      );
    }
  }

  void initBanners() {
    banners.clear();

    if (locationProvider.isGetLocationState(.success)) {
      banners.add(WeatherCard());
    }

    Future.delayed(const Duration(seconds: 1), () async {
      for (var banner in dashboardNotifier.banners) {
        banners.add(ImageBanner(banner.link, banner.imageUrl));
      }
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return StatusBarStyle.dark(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;

          if (lastTap == null) {
            lastTap = DateTime.now();
            AppDialog.showToast("Tekan sekali lagi untuk keluar");
          } else {
            if (DateTime.now().difference(lastTap!) < Duration(seconds: 2)) {
              SystemNavigator.pop();
            } else {
              lastTap = DateTime.now();
              AppDialog.showToast("Tekan sekali lagi untuk keluar");
            }
          }
        },
        child: Scaffold(
          key: _scaffoldKey,

          // PROFIlE DRAWER
          endDrawer: HomeDrawer(context),

          // HOME PAGE
          body: ValueListenableBuilder(
            valueListenable: _pageNotifyController,
            builder: (context, currentPageIndex, child) {
              return PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  HomePage(
                    globalKey: _scaffoldKey,
                    onRefresh: () => getData(),
                    banners: banners,
                  ),
                  InformationPage(),
                  NearMePlacesPage(),
                ],
              );
            },
          ),

          // BOTTOM NAV BAR
          bottomNavigationBar: SafeArea(
            bottom: Platform.isAndroid,
            child: Theme(
              data: Platform.isIOS
                  ? context.theme.copyWith(
                      splashFactory: InkSparkle.splashFactory,
                      splashColor: primaryColor.withValues(alpha: 0.5),
                      highlightColor: Colors.transparent,
                    )
                  : context.theme,
              child: ClipRRect(
                borderRadius: .vertical(
                  top: .circular(Platform.isIOS ? 16 : 24),
                ),
                child: ValueListenableBuilder(
                  valueListenable: _pageNotifyController,
                  builder: (context, currentPage, child) {
                    return BottomNavigationBar(
                      currentIndex: currentPage,
                      onTap: _onPageChanged,
                      selectedFontSize: 14,
                      unselectedFontSize: 14,
                      backgroundColor: primaryColor,
                      selectedItemColor: Colors.white,
                      type: .fixed,
                      unselectedItemColor: Colors.white.withValues(alpha: 0.7),
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
            ),
          ),
        ),
      ),
    );
  }
}
