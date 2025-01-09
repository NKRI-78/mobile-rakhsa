// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => DashboardScreenState();
// }

// class DashboardScreenState extends State<DashboardScreen> {

//   late FirebaseProvider firebaseProvider;
//   late ProfileNotifier profileNotifier;

//   DateTime? lastTap;
  
//   static GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();
  
//   int selectedPageIndex = 0;

//   Future<void> getData() async {
//     if(!mounted) return;
//       await profileNotifier.getProfile();

//     if(!mounted) return;
//       await firebaseProvider.initFcm();
//   }

//   List<Map<String, dynamic>> pages = [
//     {
//       'page': HomePage(globalKey: globalKey),
//       'title': 'Home',
//     },
//     {
//       'page': const InformationListPage(),
//       'title': 'Info',
//     },
//     {
//       'page': const SizedBox(),
//       'title': 'Call',
//     },
//     {
//       'page': const EventListPage(),
//       'title': 'Event',
//     },
//   ];
  
//   void selectPage(int index) {
//     if(index == 2) {
//       showModalBottomSheet(
//         backgroundColor: Colors.transparent,
//         context: context, 
//         builder: (BuildContext context) {
//           return SizedBox(
//             width: 180.0,
//             height: 180.0,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [

//                 Container(
//                   padding: const EdgeInsets.all(8.0),
//                   decoration: BoxDecoration(
//                     color: ColorResources.white,
//                     borderRadius: BorderRadius.circular(10.0)
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.max,
//                     children: [
                  
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.push(context, MaterialPageRoute(builder: (context) {
//                             return const NewsListPage();
//                           }));
//                         },
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
                        
//                             Image.asset(
//                               width: 50.0,
//                               height: 50.0,
//                               AssetSource.iconInfo,
//                             ),
                            
//                             const SizedBox(height: 5.0),
                        
//                             Text("News",
//                               style: robotoRegular.copyWith(
//                                 fontSize: Dimensions.fontSizeSmall,
//                                 color: ColorResources.black
//                               )
//                             )
                        
//                           ],
//                         ),
//                       ),
                  
//                     ],
//                   ) 
//                 ),
                
//               ],
//             ),
//           );  
//         },
//       );
//     } else {
//       setState(() => selectedPageIndex = index);
//     }
//   }

//   @override 
//   void initState() {
//     super.initState();
        
//     firebaseProvider = context.read<FirebaseProvider>();
//     profileNotifier = context.read<ProfileNotifier>();

//     Future.microtask(() => getData());
//   }

//   @override 
//   void dispose() {

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvoked: (bool didPop) {
//         if(lastTap == null) {
//           lastTap = DateTime.now();
//           ShowSnackbar.snackbarDefault('Tekan sekali lagi untuk keluar');
//         } else {
//           if (DateTime.now().difference(lastTap!) < const Duration(seconds: 2)) {
//             SystemNavigator.pop();
//           } else {
//             lastTap = DateTime.now();
//             ShowSnackbar.snackbarDefault('Tekan sekali lagi untuk keluar');
//           }
//         }
//       },
//       child: Scaffold(
//         key: globalKey,
//         endDrawer: SafeArea(
//           child: DrawerWidget(globalKey: globalKey)
//         ),
//         body: pages[selectedPageIndex]['page'],
//         bottomNavigationBar: BottomNavyBar(
//           selectedIndex: selectedPageIndex,
//           showElevation: false, 
//           onItemSelected: (int index) => selectPage(index),
//           items: [
//             BottomNavyBarItem(
//               icon: const Icon(
//                 Icons.home,
//                 size: 20.0,
//               ),
//               title: Text('Home',
//                 style: robotoRegular.copyWith(
//                   fontSize: Dimensions.fontSizeSmall,
//                   color: ColorResources.white
//                 ),
//               ),
//               activeColor: const Color(0xFFFE1717),
//             ),
//             BottomNavyBarItem(
//               icon: const Icon(
//                 Icons.info,
//                 size: 20.0,
//               ),
//               title: Text('Info',
//                 style: robotoRegular.copyWith(
//                   fontSize: Dimensions.fontSizeDefault,
//                   color: ColorResources.white
//                 ),
//               ),
//               activeColor: const Color(0xFFFE1717)
//             ),
//             BottomNavyBarItem(
//               icon: const Icon(
//                 Icons.call,
//                 size: 20.0,
//               ),
//               title: Text('Call',
//                 style: robotoRegular.copyWith(
//                   fontSize: Dimensions.fontSizeDefault,
//                   color: ColorResources.white
//                 ),
//               ),
//               activeColor: const Color(0xFFFE1717),
//             ),
//             BottomNavyBarItem(
//               icon: const Icon(
//                 Icons.event,
//                 size: 20.0,
//               ),
//               title: Text('Event',
//                 style: robotoRegular.copyWith(
//                   fontSize: Dimensions.fontSizeDefault,
//                   color: ColorResources.white
//                 ),
//               ),
//               activeColor: const Color(0xFFFE1717),
//             ),
//           ],
//         ),
//       ),
//     ); 
//   }

// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';

import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/home.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/main_menu_notched_bottom_navbar.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/notched_botton_navbar.dart';

import 'package:rakhsa/firebase.dart';

import 'package:rakhsa/shared/basewidgets/drawer/drawer.dart';

import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/shared/basewidgets/modal/modal.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
 
  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}
 
class DashboardScreenState extends State<DashboardScreen> {
  late FirebaseProvider firebaseProvider;
  late ProfileNotifier profileNotifier;
 
  static final globalKey = GlobalKey<ScaffoldState>();
 
  DateTime? lastTap;
 
  // bottom nav bar properties
  final botomNavBarHeight = 78.0; // tinggi bottom nav bar
  final marginBottomMenuDialog = 125.0; // jarak margin dialog menu aplikasi
 
  Future<void> getData() async {
    if (!mounted) return;
    await profileNotifier.getProfile();
 
    if (!mounted) return;
    await firebaseProvider.initFcm();
  }
 
  final menus = [
    MainMenu(
      title: 'Raksha Mart',
      menuIcon: AssetSource.iconMenuMart,
      path: RoutesNavigation.mart,
    ),
    MainMenu(
      title: 'Near Me',
      menuIcon: AssetSource.iconMenuNearme,
      path: RoutesNavigation.nearMe,
    ),
    MainMenu(
      title: 'Information',
      menuIcon: AssetSource.iconMenuInformation,
      path: RoutesNavigation.information,
    ),
    MainMenu(
      title: 'News',
      menuIcon: AssetSource.iconMenuNews,
      path: RoutesNavigation.news,
    ),
    MainMenu(
      title: 'Itinerary',
      menuIcon: AssetSource.iconMenuItinerary,
      path: RoutesNavigation.itinerary,
    ),
  ];
 
  @override
  void initState() {
    super.initState();
 
    firebaseProvider = context.read<FirebaseProvider>();
    profileNotifier = context.read<ProfileNotifier>();
 
    Future.microtask(() => getData());
  }
 
  @override
  Widget build(BuildContext context) {
    return _PopScopeWrapper(
      child: Scaffold(
        key: globalKey,
 
        // PROFIlE DRAWER
        endDrawer: SafeArea(child: DrawerWidget(globalKey: globalKey)),
 
        // HOME PAGE
        body: HomePage(globalKey: globalKey),
 
        // MAIN MENU
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: MainMenuNotchedBottomNavBar(onTap: () {
          GeneralModal.showMainMenu(
            context,
            bottom: marginBottomMenuDialog,
            content: _buildMainMenuDialog(),
          );
        }),
 
        // BOTTOM NAV BAR
        bottomNavigationBar: NotchedBottomNavBar(
          navBarHeight: botomNavBarHeight,
          menus: [
            IconButton(
              onPressed: null,
              icon: Image.asset(AssetSource.iconNavBarHome),
            ),
            IconButton(
              onPressed: () {
                GeneralModal.showMainMenu(
                  context,
                  bottom: marginBottomMenuDialog,
                  showAlignment: Alignment.bottomRight,
                  content: _buildDocumentDialog(),
                );
              },
              icon: Image.asset(AssetSource.iconNavBarWallet),
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _buildDocumentDialog() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        2,
        (index) {
          bool isPassport = (index == 0);
          return InkWell(
            onTap: () {},
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
 
  Widget _buildMainMenuDialog() {
    return SizedBox(
      width: double.maxFinite,
      height: 200,
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
            onTap: () => Navigator.pushNamed(context, menu.path),
            borderRadius: BorderRadius.circular(6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  menu.menuIcon,
                  width: 32,
                  height: 32,
                ),
                const SizedBox(height: 6),
                Text(
                  menu.title,
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
 
// ignore: must_be_immutable
class _PopScopeWrapper extends StatelessWidget {
  _PopScopeWrapper({required this.child});
 
  final Widget child;
 
  DateTime? _lastTap;
 
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (_lastTap == null) {
          _lastTap = DateTime.now();
          ShowSnackbar.snackbarDefault('Tekan sekali lagi untuk keluar');
        } else {
          if (DateTime.now().difference(_lastTap!) <
              const Duration(seconds: 2)) {
            SystemNavigator.pop();
          } else {
            _lastTap = DateTime.now();
            ShowSnackbar.snackbarDefault('Tekan sekali lagi untuk keluar');
          }
        }
      },
      child: child,
    );
  }
}