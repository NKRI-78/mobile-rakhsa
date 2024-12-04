import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:provider/provider.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/update_address_notifier.dart';
import 'package:rakhsa/features/news/persentation/pages/list.dart';

import 'package:rakhsa/websockets.dart';

import 'package:rakhsa/features/dashboard/presentation/pages/home.dart';

import 'package:rakhsa/features/event/persentation/pages/list.dart';
import 'package:rakhsa/features/information/presentation/pages/list.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/dashboard_notifier.dart';
import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';

import 'package:rakhsa/shared/basewidgets/dashboard/bottom_navybar.dart';
import 'package:rakhsa/shared/basewidgets/drawer/drawer.dart';

import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {

  static GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();
  
  List<Marker> _markers = [];
  List<Marker> get markers => [..._markers];

  String currentAddress = "";
  String currentCountry = "";
  String currentLat = "";
  String currentLng = "";
  
  bool loadingCurrentAddress = true;

  late DashboardNotifier dashboardNotifier;
  late UpdateAddressNotifier updateAddressNotifier;
  late ProfileNotifier profileNotifier;

  Future<void> getData() async {
    if(!mounted) return;
      profileNotifier.getProfile();
  } 

  List<Map<String, dynamic>> pages = [
    {
      'page': HomePage(globalKey: globalKey),
      'title': 'Home',
    },
    {
      'page': const InformationListPage(),
      'title': 'Info',
    },
    {
      'page': const SizedBox(),
      'title': 'Call',
    },
    {
      'page': const EventListPage(),
      'title': 'Event',
    },
  ];

  int selectedPageIndex = 0;

  @override 
  void initState() {
    super.initState();

    dashboardNotifier = context.read<DashboardNotifier>();
    updateAddressNotifier = context.read<UpdateAddressNotifier>();
    profileNotifier = context.read<ProfileNotifier>();

    Future.microtask(() => getData());
  }

  void selectPage(int index) {
    if(index == 2) {
      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context, 
        builder: (BuildContext context) {
          return SizedBox(
            width: 180.0,
            height: 180.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [

                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: ColorResources.white,
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                  
                      // Column(
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   mainAxisSize: MainAxisSize.min,
                      //   children: [
                      
                      //     Image.asset(
                      //       width: 50.0,
                      //       height: 50.0,
                      //       AssetSource.iconFamilyCall,
                      //     ),
                          
                      //     const SizedBox(height: 5.0),
                      
                      //     Text("Family Call",
                      //       style: robotoRegular.copyWith(
                      //         fontSize: Dimensions.fontSizeSmall,
                      //         color: ColorResources.black
                      //       )
                      //     )
                      
                      //   ],
                      // ),
                  
                      // const SizedBox(width: 20.0),
                  
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return const NewsListPage();
                          }));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                        
                            Image.asset(
                              width: 50.0,
                              height: 50.0,
                              AssetSource.iconInfo,
                            ),
                            
                            const SizedBox(height: 5.0),
                        
                            Text("News",
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: ColorResources.black
                              )
                            )
                        
                          ],
                        ),
                      ),
                  
                    ],
                  ) 
                ),
                
              ],
            ),
          );  
        },
      );
    } else {
      setState(() => selectedPageIndex = index);
    }
  }

  Future<void> checkAndGetLocation() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isLocationServiceEnabled) {
      if(mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,  
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Location Services Disabled'),
              content: const Text('Please enable location services to continue.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();  
                    Geolocator.openLocationSettings();  
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            );
          }
        );
      }
    } else {
      getCurrentLocation();
    }
  }

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Future.delayed(const Duration(seconds: 1), () {
          checkAndGetLocation();
        });
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
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
      
      loadingCurrentAddress = false;
    });

    Future.delayed(Duration.zero, () async {
      await updateAddressNotifier.updateAddress(
        address: address, 
        lat: position.latitude, 
        lng: position.longitude
      );
      
      if(!mounted) return;
        dashboardNotifier.getNews(
          type: "ews",
          lat: position.latitude,
          lng: position.longitude
        );
    });
  }

  
  @override
  Widget build(BuildContext context) {

    Provider.of<WebSocketsService>(context);

    return Scaffold(
      key: globalKey,
      endDrawer: SafeArea(
        child: DrawerWidget(globalKey: globalKey)
      ),
      body: pages[selectedPageIndex]['page'],
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: selectedPageIndex,
        showElevation: false, 
        onItemSelected: (int index) => selectPage(index),
        items: [
          BottomNavyBarItem(
            icon: const Icon(
              Icons.home,
              size: 20.0,
            ),
            title: Text('Home',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: ColorResources.white
              ),
            ),
            activeColor: const Color(0xFFFE1717),
          ),
          BottomNavyBarItem(
            icon: const Icon(
              Icons.info,
              size: 20.0,
            ),
            title: Text('Info',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: ColorResources.white
              ),
            ),
            activeColor: const Color(0xFFFE1717)
          ),
          BottomNavyBarItem(
            icon: const Icon(
              Icons.call,
              size: 20.0,
            ),
            title: Text('Call',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: ColorResources.white
              ),
            ),
            activeColor: const Color(0xFFFE1717),
          ),
          BottomNavyBarItem(
            icon: const Icon(
              Icons.event,
              size: 20.0,
            ),
            title: Text('Event',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: ColorResources.white
              ),
            ),
            activeColor: const Color(0xFFFE1717),
          ),
        ],
      ),
    ); 
  }

}