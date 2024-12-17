import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:provider/provider.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/auth/presentation/pages/login.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/sos_rating_notifier.dart';
import 'package:rakhsa/features/event/persentation/provider/delete_event_notifier.dart';

import 'package:rakhsa/global.dart';
import 'package:rakhsa/shared/basewidgets/button/custom.dart';
import 'package:rakhsa/websockets.dart';

class GeneralModal {

  static Future<void> info({
    required String msg,
  }) {
    return showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  SizedBox(
                    width: 300.0,
                    height: 330.0,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
          
                        Positioned(
                          left: 20.0,
                          right: 20.0,
                          bottom: 20.0,
                          child: Container(
                            height: 200.0,
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: Colors.white
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                            
                                Text(msg, 
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black
                                  ),
                                )
                            
                              ],
                            ),
                          )
                        ),
          
                        Positioned(
                          bottom: 0.0,
                          left: 80.0,
                          right: 80.0,
                          child: CustomButton(
                            isBorder: false,
                            btnTextColor: Colors.white,
                            fontSize: Dimensions.fontSizeDefault,
                            sizeBorderRadius: 20.0,
                            isBorderRadius: true,
                            height: 40.0,
                            onTap: () async {

                              Future.delayed(Duration.zero, () {
                                Navigator.pop(context);
                              });

                            },
                            btnTxt: "Ok",
                          )
                        ),
                        
                      ],  
                    )
                    
                  ) 
                ] 
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> infoResolvedSos({
    required String msg,
  }) {
    return showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  SizedBox(
                    width: 300.0,
                    height: 330.0,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
          
                        Positioned(
                          left: 20.0,
                          right: 20.0,
                          bottom: 20.0,
                          child: Container(
                            height: 200.0,
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: Colors.white
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                            
                                Text(msg, 
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black
                                  ),
                                )
                            
                              ],
                            ),
                          )
                        ),
          
                        Positioned(
                          bottom: 0.0,
                          left: 80.0,
                          right: 80.0,
                          child: CustomButton(
                            isBorder: false,
                            btnTextColor: Colors.white,
                            fontSize: Dimensions.fontSizeDefault,
                            sizeBorderRadius: 20.0,
                            isBorderRadius: true,
                            height: 40.0,
                            onTap: () async {
                              Navigator.pop(context);
                            },
                            btnTxt: "Ok",
                          )
                        ),
                        
                      ],  
                    )
                    
                  ) 
                ] 
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> infoClosedSos({
    required String msg,
  }) {
    return showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  SizedBox(
                    width: 300.0,
                    height: 330.0,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
          
                        Positioned(
                          left: 20.0,
                          right: 20.0,
                          bottom: 20.0,
                          child: Container(
                            height: 200.0,
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: Colors.white
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                            
                                Text(msg, 
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black
                                  ),
                                )
                            
                              ],
                            ),
                          )
                        ),
          
                        Positioned(
                          bottom: 0.0,
                          left: 80.0,
                          right: 80.0,
                          child: CustomButton(
                            isBorder: false,
                            btnTextColor: Colors.white,
                            fontSize: Dimensions.fontSizeDefault,
                            sizeBorderRadius: 20.0,
                            isBorderRadius: true,
                            height: 40.0,
                            onTap: () {
                              Future.delayed(Duration.zero, () {
                                Navigator.pop(context);
                              });
                            },
                            btnTxt: "Ok",
                          )
                        ),
                        
                      ],  
                    )
                    
                  ) 
                ] 
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> dialogRequestPermission({
    required String msg,
    required String type
  }) {
    return showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  SizedBox(
                    width: 300.0,
                    height: 330.0,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
          
                        Positioned(
                          left: 20.0,
                          right: 20.0,
                          bottom: 20.0,
                          child: Container(
                            height: 200.0,
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: Colors.white
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                            
                                Text(msg, 
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black
                                  ),
                                )
                            
                              ],
                            ),
                          )
                        ),
          
                        Positioned(
                          bottom: 0.0,
                          left: 80.0,
                          right: 80.0,
                          child: CustomButton(
                            isBorder: false,
                            btnTextColor: Colors.white,
                            fontSize: Dimensions.fontSizeDefault,
                            sizeBorderRadius: 20.0,
                            isBorderRadius: true,
                            height: 40.0,
                            onTap: () async {

                              await openAppSettings();

                              Future.delayed(Duration.zero, () {
                                Navigator.pop(context);
                              });

                            },
                            btnTxt: "Aktifkan",
                          )
                        ),
                        
                      ],  
                    )
                    
                  ) 
                ] 
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> deleteEvent({
    required int id,
    required Function getData
  }) {
     return showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                SizedBox(
                  width: 300.0,
                  height: 380.0,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [

                      Positioned(
                        left: 20.0,
                        right: 20.0,
                        bottom: 20.0,
                        child: Container(
                          height: 200.0,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            color: Colors.white
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          
                              Text("Apakah kamu yakin ingin hapus ?", 
                                textAlign: TextAlign.center,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black
                                ),
                              )
                          
                            ],
                          ),
                        )
                      ),

                      Positioned(
                        bottom: 0.0,
                        left: 80.0,
                        right: 80.0,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [

                            Expanded(
                              child: Consumer<DeleteEventNotifier>(
                                builder: (BuildContext context, DeleteEventNotifier notifier, Widget? child) {
                                  return CustomButton(
                                    isBorder: false,
                                    btnColor: ColorResources.error,
                                    btnTextColor: ColorResources.white,
                                    sizeBorderRadius: 20.0,
                                    fontSize: Dimensions.fontSizeSmall,
                                    isBorderRadius: true,
                                    height: 40.0,
                                    isLoading: notifier.state == ProviderState.loading ? true : false,
                                    onTap: () async {
                                      await notifier.delete(id: id);

                                      if(notifier.message != "") {
                                        ShowSnackbar.snackbarErr(notifier.message);
                                        return;
                                      }

                                      Future.delayed(Duration.zero, () {
                                        Navigator.pop(context, "refetch");
                                      });
                                    },
                                    btnTxt: "Ya",
                                  );
                                },
                              )
                            )
                          ],
                        )
                      ),
                      
                    ],  
                  )
                  
                ) 
              ] 
            ),
          ),
        );
    }).then((val) {
      if(val != "") {
        getData();
      }
    });
  }

  static Future<void> ratingSos({
    required String sosId
  }) {
     return showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                SizedBox(
                  width: 320.0,
                  height: 380.0,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [

                      Positioned(
                        left: 20.0,
                        right: 20.0,
                        bottom: 20.0,
                        child: Container(
                          height: 150.0,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            color: Colors.white
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              context.watch<SosRatingNotifier>().state == ProviderState.loading 
                              ? Text("Terimakasih, Atas feedback dari anda",
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: ColorResources.black
                                  ),
                                ) 
                              : RichText(
                                  text: TextSpan(
                                    text: "Di ",
                                    style: robotoRegular.copyWith(
                                      color: ColorResources.black, 
                                      fontSize: Dimensions.fontSizeDefault
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "Raksha",
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFC82927),
                                        ),
                                      ),
                                      TextSpan(
                                        text: ",\nkami sangat menghargai kesetiaan\ndan dukungan Anda sebagai pengguna\nkami yang terhormat",
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: ColorResources.black
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                              const SizedBox(height: 15.0),
      
                              RatingBar.builder(
                                initialRating: 0,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 20.0,
                                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                itemBuilder: (BuildContext context, int i) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (double selectedRating) {
                                  context.read<SosRatingNotifier>().onChangeRating(selectedRating: selectedRating);

                                  Future.delayed(Duration.zero, () {
                                    context.read<SosRatingNotifier>().sosRating(sosId: sosId);
                                    Navigator.pop(context);
                                    Navigator.pop(context, "refetch");
                                  });

                                  context.read<WebSocketsService>().userResolvedSos(sosId: sosId);
                                },
                              ),

                            ],
                          )
                        )
                      ),
                      
                    ],  
                  )
                  
                ) 
              ] 
            ),
          ),
        );
    });
  }
  
  static Future<void> logout({required GlobalKey<ScaffoldState> globalKey}) {
    return showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                SizedBox(
                  width: 300.0,
                  height: 380.0,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [

                      Positioned(
                        left: 20.0,
                        right: 20.0,
                        bottom: 20.0,
                        child: Container(
                          height: 200.0,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            color: Colors.white
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          
                              Text("Apakah kamu yakin ingin keluar ?", 
                                textAlign: TextAlign.center,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black
                                ),
                              )
                          
                            ],
                          ),
                        )
                      ),

                      Positioned(
                        top: 80.0,
                        left: 0.0, 
                        right: 0.0,
                        child: Align(
                          child: Image.asset('assets/images/logout-icon.png',
                            width: 130.0,
                            height: 130.0,
                          ),
                        )
                      ),

                      Positioned(
                        bottom: 50.0,
                        left: 80.0,
                        right: 80.0,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [

                            Expanded(
                              child: CustomButton(
                                isBorder: false,
                                btnColor: const Color(0xFF17B5FE),
                                btnTextColor: ColorResources.white,
                                sizeBorderRadius: 8.0,
                                fontSize: Dimensions.fontSizeSmall,
                                isBorderRadius: true,
                                height: 30.0,
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                btnTxt: "Batal",
                              ),
                            ),

                            const SizedBox(width: 10.0),

                            Expanded(
                              child: CustomButton(
                                isBorder: false,
                                btnColor: ColorResources.error,
                                btnTextColor: ColorResources.white,
                                sizeBorderRadius: 8.0,
                                fontSize: Dimensions.fontSizeSmall,
                                isBorderRadius: true,
                                height: 30.0,
                                onTap: () {
                                  context.read<WebSocketsService>().leave();

                                  StorageHelper.clear();
                                  StorageHelper.removeToken();

                                  globalKey.currentState?.closeDrawer();

                                  Navigator.pushReplacement(
                                    context, MaterialPageRoute(builder: (BuildContext context) {
                                      return const LoginPage();
                                    })
                                  );
                                },
                                btnTxt: "Ya",
                              ),
                            )
                          ],
                        )
                      ),
                      
                    ],  
                  )
                  
                ) 
              ] 
            ),
          ),
        );
      },
    ); 
  } 

}