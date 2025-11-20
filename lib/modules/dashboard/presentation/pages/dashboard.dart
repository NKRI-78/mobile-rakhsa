import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as location;
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/service/device/vibration_manager.dart';
import 'package:rakhsa/modules/dashboard/presentation/provider/update_address_notifier.dart';
import 'package:rakhsa/modules/information/presentation/pages/list.dart';
import 'package:rakhsa/modules/location/provider/location_provider.dart';
import 'package:rakhsa/modules/nearme/presentation/pages/near_me_page_list_type.dart';

import 'package:rakhsa/modules/dashboard/presentation/provider/dashboard_notifier.dart';
import 'package:rakhsa/modules/app/provider/user_provider.dart';
import 'package:rakhsa/modules/dashboard/presentation/pages/home.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/misc/utils/asset_source.dart';
import 'package:rakhsa/service/location/location_service.dart';
import 'package:rakhsa/service/notification/notification_manager.dart';

import 'package:rakhsa/widgets/components/drawer/home_drawer.dart';

import 'package:rakhsa/service/storage/storage.dart';
import 'package:rakhsa/service/socket/socketio.dart';
import 'package:rakhsa/widgets/dialog/dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.fromRegister = false});

  final bool fromRegister;

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _pageNotifyController = ValueNotifier<int>(0);
  final _pageController = PageController();

  late DashboardNotifier dashboardNotifier;
  late SocketIoService socketIoService;
  late UserProvider profileNotifier;
  late LocationProvider locationProvider;
  late UpdateAddressNotifier updateAddressNotifier;

  List<Widget> banners = [];

  DateTime? lastTap;

  @override
  void initState() {
    super.initState();

    VibrationManager.instance.init();

    profileNotifier = context.read<UserProvider>();
    updateAddressNotifier = context.read<UpdateAddressNotifier>();
    dashboardNotifier = context.read<DashboardNotifier>();
    locationProvider = context.read<LocationProvider>();
    socketIoService = context.read<SocketIoService>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAndShowWelcomeDialog();
    });

    Future.delayed(Duration(seconds: 1)).then((value) {
      socketIoService.connect();
    });

    Future.microtask(() => getData());

    _sendLatestLocation();
  }

  @override
  void dispose() {
    _pageNotifyController.dispose();
    _pageController.dispose();

    super.dispose();
  }

  Future<void> getData() async {
    await StorageHelper.loadlocalSession();

    if (!mounted) return;
    await profileNotifier.getUser();

    if (!mounted) return;
    await NotificationManager().initializeFcmToken();

    if (!mounted) return;
    await getCurrentLocation();

    if (!mounted) return;
    await dashboardNotifier.getBanner();

    initBanners();
  }

  _onPageChanged(int index) {
    _pageController.jumpToPage(index);
    _pageNotifyController.value = index;
    VibrationManager.instance.vibrate(durationInMs: 40);
  }

  Future<void> getCurrentLocation() async {
    final gpsEnabled = await Geolocator.isLocationServiceEnabled();
    if (!gpsEnabled) {
      if (mounted) {
        bool? openSetting = await AppDialog.show(
          c: context,
          content: DialogContent(
            assetIcon: "assets/images/icons/current-location.png",
            title: "GPS Tidak Aktif",
            message:
                "Mohon aktifkan GPS agar aplikasi Marlinda dapat mendeteksi lokasi Anda dengan akurat dan memungkinkan Anda menggunakan layanan SOS.",
            actions: [
              DialogActionButton(
                label: "Aktifkan GPS",
                primary: true,
                onTap: () => context.pop(true),
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

    // check location permission
    LocationPermission lp = await Geolocator.checkPermission();
    if (lp == LocationPermission.denied) {
      if (mounted) {
        bool? request = await AppDialog.show(
          c: context,
          content: DialogContent(
            assetIcon: "assets/images/icons/current-location.png",
            title: "Permintaan Izin Lokasi",
            message:
                "Aplikasi memerlukan akses lokasi agar dapat mengirim SOS dengan akurat saat keadaan darurat. Mohon aktifkan izin lokasi untuk melanjutkan.",
            actions: [
              DialogActionButton(
                label: "Minta Izin",
                primary: true,
                onTap: () => context.pop(true),
              ),
            ],
          ),
        );
        if (request != null && request) {
          lp = await Geolocator.requestPermission();
        }
      }
    }

    if (lp == LocationPermission.deniedForever) {
      if (mounted) {
        bool? openSettings = await AppDialog.show(
          c: context,
          content: DialogContent(
            assetIcon: "assets/images/icons/current-location.png",
            title: "Akses Lokasi Dinonaktifkan",
            message: """
Izin lokasi saat ini ditolak secara permanen.
Untuk mengaktifkannya kembali, buka Pengaturan Sistem Aplikasi > Izin > Lokasi, lalu izinkan akses lokasi agar fitur SOS dapat berfungsi dengan benar.
""",
            actions: [
              DialogActionButton(
                label: "Buka Pengaturan",
                primary: true,
                onTap: () => context.pop(true),
              ),
            ],
          ),
        );
        if (openSettings != null && openSettings) {
          await Geolocator.openAppSettings();
        }
      }
    }

    if (lp == LocationPermission.always ||
        lp == LocationPermission.whileInUse) {
      await locationProvider.getCurrentLocation();

      final newLocation = locationProvider.location;

      if (newLocation != null) {
        final placemark = newLocation.placemark;
        final coord = newLocation.coord;

        Future.delayed(Duration.zero, () async {
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
  }

  Future<bool> _shouldSendLatestLocation({
    Duration sendInterval = const Duration(hours: 12),
  }) async {
    final prefs = StorageHelper.sharedPreferences;
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
    final shouldSend = await _shouldSendLatestLocation();
    if (shouldSend) {
      if (Platform.isAndroid) await _showLocationAlwaysDialog();
      await sendLatestLocation(
        "User open the App",
        otherSource: locationProvider.location,
      );
    }
  }

  void initBanners() {
    banners.clear();

    banners.add(WeatherContent());

    Future.delayed(const Duration(seconds: 1), () async {
      for (var banner in dashboardNotifier.banners) {
        banners.add(ImgBanner(banner.link, banner.imageUrl));
      }
      if (mounted) setState(() {});
    });
  }

  void _initAndShowWelcomeDialog() async {
    if (widget.fromRegister) {
      await Future.delayed(Duration(seconds: 2));
      if (mounted) {
        await AppDialog.show(
          c: context,
          content: DialogContent(
            assetIcon: AssetSource.iconWelcomeDialog,
            title: "Terimakasih ${StorageHelper.session?.user.name ?? "-"}",
            message: """
Karena kamu telah mengaktifkan paket roaming dan kamu sudah resmi gabung bersama Marlinda.
Stay Connected & Stay Safe dimanapun kamu berada, karena keamananmu Prioritas kami!
""",
            style: DialogStyle(assetIconSize: 175),
            actions: [
              DialogActionButton(
                label: "Oke",
                primary: true,
                onTap: () => context.pop(true),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _showLocationAlwaysDialog() async {
    final bgLocation = Permission.locationAlways;
    final hasPermission = await bgLocation.status
        .then((p) {
          return p == PermissionStatus.granted || p == PermissionStatus.limited;
        })
        .onError((e, st) => false);
    if (hasPermission) return;

    await Future.delayed(Duration(seconds: 2));
    if (mounted) {
      await AppDialog.show(
        c: context,
        canPop: false,
        content: DialogContent(
          assetIcon: "assets/images/icons/location.png",
          title: "Tingkatkan Keandalan Fitur Keselamatan",
          message: """
Dengan mengizinkan akses lokasi Selalu, aplikasi dapat lebih responsif saat Anda membutuhkan fitur SOS. Izin ini sepenuhnya opsional—namun akan sangat membantu agar sistem dapat bekerja lebih optimal.
""",
          style: DialogStyle(assetIconSize: 175),
          buildActions: (c) {
            return [
              DialogActionButton(
                label: "Aktifkan",
                primary: true,
                onTap: () async {
                  c.pop();
                  await Future.delayed(Duration(milliseconds: 300));
                  await bgLocation.request();
                },
              ),
            ];
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
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
        endDrawer: SafeArea(child: HomeDrawer()),

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
                InformationListPage(),
                NearMeListTypePage(),
              ],
            );
          },
        ),

        // BOTTOM NAV BAR
        bottomNavigationBar: SafeArea(
          bottom: Platform.isIOS ? false : true,
          child: Theme(
            data: Platform.isIOS
                ? Theme.of(context).copyWith(
                    splashFactory: InkSparkle.splashFactory,
                    splashColor: primaryColor.withValues(alpha: 0.5),
                    highlightColor: Colors.transparent,
                  )
                : Theme.of(context),
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.vertical(
                top: Radius.circular(Platform.isIOS ? 16 : 24),
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
                    selectedItemColor: whiteColor,
                    type: BottomNavigationBarType.fixed,
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
          ),
        ),
      ),
    );
  }
}
