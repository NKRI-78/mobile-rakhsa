import 'package:flutter/material.dart';
import 'package:rakhsa/coming_soon.dart';
import 'package:rakhsa/common/utils/asset_source.dart';

import 'package:rakhsa/features/dashboard/presentation/pages/home.dart';

import 'package:rakhsa/features/event/persentation/pages/list.dart';
import 'package:rakhsa/features/information/presentation/pages/list.dart';

import 'package:rakhsa/shared/basewidgets/dashboard/bottom_navybar.dart';
import 'package:rakhsa/shared/basewidgets/drawer/drawer.dart';

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
  }

  void selectPage(int index) {
    if(index == 2) {
      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context, 
        builder: (BuildContext context) {
          return SizedBox(
            height: 140.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: ColorResources.white,
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const ComingSoonPage();
                      }));
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    
                        Image.asset(
                          width: 50.0,
                          height: 50.0,
                          AssetSource.iconFamilyCall,
                        ),
                        
                        const SizedBox(height: 5.0),
                    
                        Text("Family Call",
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: ColorResources.black
                          )
                        )
                    
                      ],
                    ),
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      drawer: const SafeArea(
        child: DrawerWidget()
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