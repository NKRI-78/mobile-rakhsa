import 'package:flutter/material.dart';
import 'package:rakhsa/common/constants/theme.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/dashboard.dart';
import 'package:rakhsa/shared/basewidgets/button/custom.dart';

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(
            top: 16.0, 
            left: 20.0,
            right: 20.0,
            bottom: 16.0
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [

                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage('assets/images/login-ornament.png')
                    )
                  ),
                ),

                Container(
                  width: 250.0,
                  height: 250.0,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage('assets/images/coming-soon.png')
                    )
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(
                    top: 20.0,
                    bottom: 20.0
                  ),
                  child: Text("Mohon maaf, untuk saat ini\nfitur masih di rancang oleh tim ahli kami \nagar lebih sempurna",
                    textAlign: TextAlign.center,
                    style: robotoRegular.copyWith(
                      color: ColorResources.white,
                      fontSize: Dimensions.fontSizeDefault
                    ),
                  ),
                ),

                CustomButton(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return const DashboardScreen();
                    }));
                  },
                  width: 200.0,
                  isBorder: false,
                  isBorderRadius: true,
                  isBoxShadow: false,
                  btnTxt: "Home",
                  loadingColor: primaryColor,
                  btnColor: ColorResources.white,
                  btnTextColor: primaryColor,
                ),

              ]
          
            )
          ),
        ),
      )
    );
  }
}