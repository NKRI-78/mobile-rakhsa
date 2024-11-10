import 'package:flutter/material.dart';
import 'package:rakhsa/features/pages/dashboard/presentation/pages/home.dart';

import 'package:rakhsa/shared/basewidgets/dashboard/bottom_navybar.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {

  List<Map<String, dynamic>> pages = [
    {
      'page': const HomePage(),
      'title': 'Home',
    },
    {
      'page': const SizedBox(),
      'title': 'Profile',
    },
    {
      'page': const SizedBox(),
      'title': 'Profile',
    },
    {
      'page': const SizedBox(),
      'title': 'Profile',
    },
  ];

  int selectedPageIndex = 0;

  @override 
  void initState() {
    super.initState();
  }

  void selectPage(int index) {
    setState(() {
      selectedPageIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedPageIndex]['page'],
      bottomNavigationBar: BottomNavyBar( 
        selectedIndex: selectedPageIndex,
        showElevation: false, 
        onItemSelected: (int index) => setState(() {
          selectedPageIndex = index;
        }),
        items: [
          BottomNavyBarItem(
          icon: const Icon(
            Icons.fastfood,
            size: 20.0,
          ),
          title: Text('Categories',
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: ColorResources.black
            ),
          ),
          activeColor: Colors.red.shade700,
          ),
          BottomNavyBarItem(
            icon: const Icon(
              Icons.star,
              size: 20.0,
            ),
            title: Text('Favorites',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: ColorResources.black
              ),
            ),
            activeColor: Colors.yellow.shade700
          ),
          BottomNavyBarItem(
            icon: const Icon(
              Icons.account_circle,
              size: 20.0,
            ),
            title: Text('Profile',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: ColorResources.black
              ),
            ),
            activeColor: Colors.blue.shade700,
          ),
          BottomNavyBarItem(
            icon: const Icon(
              Icons.account_circle,
              size: 20.0,
            ),
            title: Text('Profile',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: ColorResources.black
              ),
            ),
            activeColor: Colors.blue.shade700,
          ),
        ],
      ),
    ); 
  }

}