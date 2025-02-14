import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/ppob/presentation/pages/detail_paketdata.dart';
import 'package:rakhsa/features/ppob/presentation/pages/detail_pulsa.dart';
import 'package:rakhsa/features/ppob/presentation/pages/detail_tokenlistrik.dart';

import 'package:rakhsa/shared/basewidgets/button/bounce.dart';

class PPOBPage extends StatefulWidget {
  static const route = '/ppob';

  const PPOBPage({super.key});

  @override
  State<PPOBPage> createState() => PPOBPageState();
}

class PPOBPageState extends State<PPOBPage> {

  List<Map<String, dynamic>> categories = [
    {
      "id": 1,
      "name": "Pulsa",
      "link": "pulsapaketdata",
      "image": "assets/image/ppob/ic-pulsa.png",
    },
    {
      "id": 2,
      "name": "Paket Data",
      "image": "assets/image/ppob/ic-paketdata.png",
      "link": "paketdata"
    },
    {
      "id": 3,
      "name": "Listrik",
      "image": "assets/image/ppob/ic-listrik.png",
      "link": "tokenlistrik"
    },
  ];

  void onChangeCategories(int i) {
    switch (categories[i]["link"]) {
      case "pulsapaketdata":
        Navigator.push(context, 
          MaterialPageRoute(builder: (context) {
            return PPOBDetailPulsaPage(
              title: categories[i]["name"],
              type: "Pulsa / Paket Data",
            );
          })
        );
      break;
      case "Paket Data":
        Navigator.pushNamed(context, 
          PPOBDetailPaketDataPage.route,
          arguments: {
            "title": categories[i]["name"]
          }  
        );
      break;
      case "Token Listrik":
        Navigator.pushNamed(context, 
          PPOBDetailTokenListrikPage.route,
          arguments: {
            "title": categories[i]["name"]
          }
        );
      break;
      default:
    }
  }

  @override 
  void initState() {
    super.initState();
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Pulsa & Tagihan",
          style: robotoRegular.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: Dimensions.fontSizeDefault,
            color: primaryColor
          ),
        ),
        elevation: 1.0,
        shadowColor: ColorResources.black,
        leading: CupertinoNavigationBarBackButton(
          color: ColorResources.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only( 
          top: 15.0,
          left: 15.0, 
          right: 15.0
        ),
        child: GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8.0),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 15.0,
            crossAxisSpacing: 15.0
          ),
          itemCount: categories.length,
          itemBuilder: (BuildContext context, int i) {
            return Bouncing(
              onPress: () {
                onChangeCategories(i);
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  
                  Align(
                    alignment:Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        boxShadow: kElevationToShadow[1],
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(categories[i]["name"],
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              fontWeight: FontWeight.w600,
                              color: ColorResources.white
                            ),
                          ),
                        ],
                      ) 
                    ),
                  ),
                          
                  // Positioned(
                  //   top: 0.0,
                  //   left: 0.0,
                  //   right: 0.0,
                  //   child:Image.asset(
                  //     categories[i]["image"],
                  //     width: 80.0,
                  //     height: 80.0,
                  //   ),
                  // ),
                          
                ],
              ),
            );
          
          }
        ),
      ),
    );
  }
  
}