import 'package:flutter/material.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';

import 'package:rakhsa/features/ppob/presentation/pages/detail_paketdata_page.dart';
import 'package:rakhsa/features/ppob/presentation/pages/detail_pulsa_page.dart';
import 'package:rakhsa/features/ppob/presentation/pages/detail_tokenlistrik_page.dart';

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
      "image": "assets/image/icons/ic-pulsa.png",
    },
    {
      "id": 2,
      "name": "Paket Data",
      "image": "assets/image/icons/ic-paketdata.png",
    },
    {
      "id": 3,
      "name": "Token Listrik",
      "image": "assets/image/icons/ic-listrik.png",
    },
  ];

  void onChangeCategories(int i) {
    switch (categories[i]["name"]) {
      case "Pulsa":
        Navigator.pushNamed(context, 
          PPOBDetailPulsaPage.route,
          arguments: {
            "title": categories[i]["name"]
          }  
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
    return buildUI();
  }

  Widget buildUI() {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
           
          ];
        },
        body: Container(
          margin: const EdgeInsets.only( 
            top: 20.0,
            bottom: 20.0,
            left: 15.0, 
            right: 15.0
          ),
          child: GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8.0),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 4.0 / 3.5,
              crossAxisSpacing: 50.0,
              mainAxisSpacing: 50.0,
            ),
            itemCount: categories.length,
            itemBuilder: (BuildContext context, int i) {
              return Bouncing(
                onPress: () {
                  onChangeCategories(i);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      
                      Align(
                        alignment:Alignment.bottomCenter,
                        child: Container(
                          height: 75.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xffF1F1F1),
                            boxShadow: kElevationToShadow[1],
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(top: 30.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(categories[i]["name"],
                                  style: robotoRegular.copyWith(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ) 
                        ),
                      ),
              
                      Positioned(
                        top: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child:Image.asset(
                          categories[i]["image"],
                          width: 80.0,
                          height: 80.0,
                        ),
                      ),
              
                    ],
                  ),
                ),
              );
            
            }
          ),
        ),
        
      )
    );
  }
  
}