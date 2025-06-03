import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/constants/theme.dart';

import 'package:rakhsa/firebase.dart';

import 'package:rakhsa/features/dashboard/presentation/provider/dashboard_notifier.dart';
import 'package:rakhsa/features/auth/presentation/pages/verify_login_fr.dart';
import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/home.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/main_menu_notched_bottom_navbar.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/notched_botton_navbar.dart';

import 'package:rakhsa/providers/ecommerce/ecommerce.dart';

import 'package:rakhsa/shared/basewidgets/drawer/drawer.dart';
import 'package:rakhsa/shared/basewidgets/modal/modal.dart';

import 'package:rakhsa/common/helpers/storage.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/socketio.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
 
  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}
 
class DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {

  GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

  late EcommerceProvider ecommerceProvider;
  late FirebaseProvider firebaseProvider;
  late DashboardNotifier dashboardNotifier;
  late SocketIoService socketIoService;
  late ProfileNotifier profileNotifier;

  DateTime? lastTap;
 
  // bottom nav bar properties
  final bottomomNavBarHeight = 78.0; // tinggi bottom nav bar
  final marginBottomMenuDialog = 125.0; // jarak margin dialog menu aplikasi
 
  Future<void> getData() async {
    if(!mounted) return; 
      await ecommerceProvider.checkStoreOwner();

    if (!mounted) return;
      await profileNotifier.getProfile();
 
    if (!mounted) return;
      await firebaseProvider.initFcm();

    // if(!mounted) return; 
      // dashboardNotifier.checkIsLocked();
  }
 
  final menus = [
    MainMenu(
      title: 'Pulsa & Tagihan',
      menuIcon: AssetSource.iconNavBarWallet,
      path: RoutesNavigation.ppob,
    ),
    MainMenu(
      title: 'Information',
      menuIcon: AssetSource.iconMenuInformation,
      path: RoutesNavigation.information,
    ),
    MainMenu(
      title: 'Itinerary',
      menuIcon: AssetSource.iconMenuItinerary,
      path: RoutesNavigation.itinerary,
    ),
  ];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      StorageHelper.setIsLocked(val: true);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
 
    firebaseProvider = context.read<FirebaseProvider>();
    profileNotifier = context.read<ProfileNotifier>();
    ecommerceProvider = context.read<EcommerceProvider>();  
    dashboardNotifier = context.read<DashboardNotifier>();
    socketIoService = context.read<SocketIoService>();

    Future.microtask(() => getData());
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
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
        body: context.watch<DashboardNotifier>().isLocked 
        ? const VerifyLoginFr()
        : HomePage(globalKey: globalKey),
 
        // MAIN MENU
        floatingActionButtonLocation: MainMenuNotchedBottomNavBar.position,
        floatingActionButton: context.watch<DashboardNotifier>().isLocked 
        ? const SizedBox()
        : MainMenuNotchedBottomNavBar(onTap: () {
          GeneralModal.showMainMenu(
            context,
            bottom: marginBottomMenuDialog,
            content: buildMainMenuDialog(),
          );
        }),
 
        // BOTTOM NAV BAR
        bottomNavigationBar: context.watch<DashboardNotifier>().isLocked 
          ? const SizedBox()
          : NotchedBottomNavBar(
            height: bottomomNavBarHeight,
            leftItem: IconButton(
            onPressed: () => Navigator.pushNamed(context, RoutesNavigation.nearMeTypeList),
            icon: Image.asset(
              AssetSource.iconMenuNearme,
              color: ColorResources.white
            ),
          ),
          rightItem: IconButton(
            onPressed: () {
              GeneralModal.showMainMenu(
                context,
                bottom: marginBottomMenuDialog,
                showAlignment: Alignment.bottomRight,
                content: buildDocumentDialog(),
              );
            },
            icon: Image.asset(AssetSource.iconNavBarWallet),
          ),
        )
      ),
    );
  }
 
  Widget buildDocumentDialog() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        2,
        (index) {
          bool isPassport = (index == 0);
          return InkWell(
            onTap: () {
              Navigator.pop(context);
              if(isPassport) {
                Navigator.pushNamed(context, RoutesNavigation.passportDocument);
              } else {
                Navigator.pushNamed(context, RoutesNavigation.visaDocument);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Image.asset(
                    AssetSource.iconCard,
                    width: 42,
                    height: 42,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isPassport ? 'Passport' : 'Visa',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
 
  Widget buildMainMenuDialog() {
    return SizedBox(
      width: double.maxFinite,
      height: 90.0,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        padding: EdgeInsets.zero,
        itemCount: menus.length,
        itemBuilder: (context, index) {
          final menu = menus[index];
          return InkWell(
            onTap: () {
              if (menu.title == 'PBOB') {
                Navigator.pop(context);
                return;
              }
              Navigator.pop(context);
              Navigator.pushNamed(context, menu.path);
            },
            borderRadius: BorderRadius.circular(6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  menu.menuIcon,
                  width: 32,
                  height: 32,
                  color: redColor,
                ),
                const SizedBox(height: 6),
                Text(
                  menu.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFA7A3A3),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
 
class MainMenu {
  final String title;
  final String menuIcon;
  final String path;
 
  MainMenu({
    required this.title,
    required this.menuIcon,
    required this.path,
  });
}
 