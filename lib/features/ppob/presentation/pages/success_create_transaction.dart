import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/shared/basewidgets/button/custom.dart';

class SuccessCreateTransactioPage extends StatefulWidget {
  const SuccessCreateTransactioPage({super.key});

  @override
  State<SuccessCreateTransactioPage> createState() => SuccessCreateTransactioPageState();
}

class SuccessCreateTransactioPageState extends State<SuccessCreateTransactioPage> {

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
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if(!didPop) return;
      },
      child: Scaffold(
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
      
            SliverAppBar(
              title: Text("Info Transaksi",
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  fontWeight: FontWeight.bold,
                  color: ColorResources.black
                ),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
      
            SliverFillRemaining(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
      
                  const Icon(Icons.info,
                    size: 150.0,
                    color: ColorResources.blue
                  ),
      
                  const SizedBox(height: 30.0),
      
                  SizedBox(
                    width: 280.0,
                    child: Text("Silahkan periksa halaman notifikasi untuk detail info terkait pembayaran",
                      textAlign: TextAlign.center,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: ColorResources.black
                      ),
                    ),
                  ),

                  const SizedBox(height: 30.0),

                  SizedBox(
                    width: 180.0,
                    child: CustomButton(
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context, RoutesNavigation.chats, (route) => route.isFirst
                        );
                      }, 
                      isBorderRadius: true,
                      isBorder: false,
                      isBoxShadow: false,
                      fontSize: Dimensions.fontSizeSmall,
                      btnTxt: "Halaman Notifikasi"
                    ),
                  )
      
                ],
              )
            )
      
          ],
        )
      ),
    );
  }
}