import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:provider/provider.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/snackbar.dart';
import 'package:rakhsa/common/helpers/storage.dart';
import 'package:rakhsa/common/routes/routes_navigation.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/auth/presentation/pages/login.dart';
import 'package:rakhsa/features/chat/presentation/pages/chat.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/dashboard.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/expire_sos_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/sos_rating_notifier.dart';
import 'package:rakhsa/features/event/persentation/provider/delete_event_notifier.dart';

import 'package:rakhsa/global.dart';
import 'package:rakhsa/shared/basewidgets/button/custom.dart';
import 'package:rakhsa/websockets.dart';

class GeneralModal {

  static Future<void> showLoadingOverLay({String? status}) async {
    await EasyLoading.show(status: status);
  }

  static Future<void> hideLoadingOverLay({String? status}) async {
    await EasyLoading.dismiss();
  }

  static void showMainMenu(
    BuildContext context, {
    required Widget content,
    required double bottom,
    Alignment showAlignment = Alignment.bottomCenter,
  }) async {
    await showGeneralDialog(
      context: context,
      barrierLabel: '',
      barrierDismissible: true,
      barrierColor: Colors.black38,
      transitionBuilder: (context, a1, a2, child) => ScaleTransition(
        scale: a1,
        alignment: showAlignment,
        child: child,
      ),
      pageBuilder: (context, a1, a2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
          child: Padding(
            padding: EdgeInsets.only(bottom: bottom),
            child: AlertDialog(
              elevation: 3,
              alignment: Alignment.bottomCenter,
              contentPadding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: content,
            ),
          ),
        );
      },
    );
  }

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

  static Future<void> infoEndSos({
    required String sosId,
    required String chatId, 
    required String recipientId,
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
                    height: 300.0,
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                            
                                Text(msg, 
                                  textAlign: TextAlign.center,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Colors.black
                                  ),
                                )
                            
                              ],
                            ),
                          )
                        ),

                        Positioned(
                          top: 50.0,
                          left: 0.0, 
                          right: 0.0,
                          child: Align(
                            child: Image.asset('assets/images/ic-alert.png',
                              width: 130.0,
                              height: 130.0,
                            ),
                          )
                        ),
          
                        Positioned(
                          bottom: 20.0,
                          left: 20.0,
                          right: 20.0,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [

                              Expanded(
                                child: CustomButton(
                                  isBorder: false,
                                  btnColor: ColorResources.white,
                                  btnTextColor: ColorResources.black,
                                  fontSize: Dimensions.fontSizeSmall,
                                  isBorderRadius: false,
                                  borderRadiusGeometry: const BorderRadius.only(bottomLeft: Radius.circular(25.0)),
                                  height: 35.0,
                                  onTap: () {
                                    Navigator.pop(context);

                                    Future.delayed(const Duration(seconds: 1), () {
                                      Navigator.push(navigatorKey.currentContext!, 
                                        MaterialPageRoute(builder: (BuildContext context) {
                                          return ChatPage(
                                            sosId: sosId, 
                                            chatId: chatId, 
                                            status: "NONE", 
                                            recipientId: recipientId, 
                                            autoGreetings: false
                                          ); 
                                        })
                                      );
                                    });
                                  },
                                  btnTxt: "Belum",
                                ),
                              ),

                              Expanded(
                                child: CustomButton(
                                  isBorder: false,
                                  btnColor: const Color(0xFFC90900),
                                  btnTextColor: ColorResources.white,
                                  fontSize: Dimensions.fontSizeSmall,
                                  isBorderRadius: false,
                                  borderRadiusGeometry: const BorderRadius.only(bottomRight: Radius.circular(25.0)),
                                  height: 35.0,
                                  onTap: () async {
                                    await ratingSos(sosId: sosId, isHome: true).then((_) {
                                      Navigator.pop(context);
                                    });
                                  },
                                  btnTxt: "Sudah",
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
          ),
        );
      },
    );
  }

  // static Future<void> infoResolvedSos({
  //   required String msg,
  // }) {
  //   return showDialog(
  //     context: navigatorKey.currentContext!,
  //     builder: (context) {
  //       return PopScope(
  //         canPop: false,
  //         child: Scaffold(
  //           backgroundColor: Colors.transparent,
  //           body: Center(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
                  
  //                 SizedBox(
  //                   width: 300.0,
  //                   height: 330.0,
  //                   child: Stack(
  //                     clipBehavior: Clip.none,
  //                     children: [
          
  //                       Positioned(
  //                         left: 20.0,
  //                         right: 20.0,
  //                         bottom: 20.0,
  //                         child: Container(
  //                           height: 200.0,
  //                           padding: const EdgeInsets.all(12.0),
  //                           decoration: BoxDecoration(
  //                             borderRadius: BorderRadius.circular(25.0),
  //                             color: Colors.white
  //                           ),
  //                           child: Column(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             mainAxisSize: MainAxisSize.min,
  //                             children: [
                            
  //                               Text(msg, 
  //                                 textAlign: TextAlign.center,
  //                                 style: robotoRegular.copyWith(
  //                                   fontSize: Dimensions.fontSizeDefault,
  //                                   fontWeight: FontWeight.w600,
  //                                   color: Colors.black
  //                                 ),
  //                               )
                            
  //                             ],
  //                           ),
  //                         )
  //                       ),
          
  //                       Positioned(
  //                         bottom: 0.0,
  //                         left: 80.0,
  //                         right: 80.0,
  //                         child: CustomButton(
  //                           isBorder: false,
  //                           btnTextColor: Colors.white,
  //                           btnColor: const Color(0xFFC82927),
  //                           fontSize: Dimensions.fontSizeDefault,
  //                           sizeBorderRadius: 20.0,
  //                           isBorderRadius: true,
  //                           height: 40.0,
  //                           onTap: () {
  //                             Navigator.pushAndRemoveUntil(navigatorKey.currentContext!, 
  //                             MaterialPageRoute(builder: (context) => const DashboardScreen()), (route) => false);
  //                           },
  //                           btnTxt: "Ok",
  //                         )
  //                       ),
                        
  //                     ],  
  //                   )
                    
  //                 ) 
  //               ] 
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

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
                          child: CustomButton(
                            isBorder: false,
                            btnTextColor: Colors.white,
                            fontSize: Dimensions.fontSizeDefault,
                            sizeBorderRadius: 20.0,
                            isBorderRadius: true,
                            height: 40.0,
                            onTap: () {
                              Navigator.pushAndRemoveUntil(navigatorKey.currentContext!, 
                              MaterialPageRoute(builder: (context) => const DashboardScreen()), (route) => false);
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
                          child: CustomButton(
                            isBorder: false,
                            btnTextColor: Colors.white,
                            fontSize: Dimensions.fontSizeDefault,
                            sizeBorderRadius: 20.0,
                            isBorderRadius: true,
                            height: 40.0,
                            onTap: () async {

                              await AppSettings.openAppSettings(type: AppSettingsType.notification);

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
    required String sosId,
    required bool isHome
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              RichText(
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
                                itemSize: 25.0,
                                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                itemBuilder: (BuildContext context, int i) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (double selectedRating) {
                                  context.read<SosRatingNotifier>().onChangeRating(selectedRating: selectedRating);

                                  context.read<SosRatingNotifier>().sosRating(sosId: sosId);

                                  context.read<WebSocketsService>().userResolvedSos(sosId: sosId);

                                  Navigator.pop(context);

                                  if(!isHome) {
                                    Navigator.pushNamed(context, RoutesNavigation.dashboard);
                                  }
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

  // static Future<void> feedbackSos(double rating) {
  //   return showDialog(
  //   context: navigatorKey.currentContext!,
  //   builder: (context) {
  //     return Scaffold(
  //       backgroundColor: Colors.transparent,
  //       body: Center(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
              
  //             SizedBox(
  //               width: 350.0,
  //               height: 380.0,
  //               child: Stack(
  //                 clipBehavior: Clip.none,
  //                 children: [

  //                   Positioned(
  //                     left: 20.0,
  //                     right: 20.0,
  //                     bottom: 20.0,
  //                     child: Container(
  //                       height: 150.0,
  //                       padding: const EdgeInsets.all(12.0),
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(25.0),
  //                         color: Colors.white
  //                       ),
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         mainAxisSize: MainAxisSize.min,
  //                         children: [
                      
  //                           Text("Terimakasih, Atas feedback dari Anda",
  //                             textAlign: TextAlign.center,
  //                             style: robotoRegular.copyWith(
  //                               fontSize: Dimensions.fontSizeLarge,
  //                               fontWeight: FontWeight.bold,
  //                               color: ColorResources.black
  //                             ),
  //                           ),
                      
  //                           const SizedBox(height: 15.0),
                            
  //                           RatingBar.builder(
  //                             initialRating: rating,
  //                             minRating: 1,
  //                             direction: Axis.horizontal,
  //                             allowHalfRating: true,
  //                             ignoreGestures: true,
  //                             itemCount: 5,
  //                             itemSize: 25.0,
  //                             itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
  //                             itemBuilder: (BuildContext context, int i) => const Icon(
  //                               Icons.star,
  //                               color: Colors.amber,
  //                             ),
  //                             onRatingUpdate: (double selectedRating) {},
  //                           ),
                      
  //                         ],
  //                       )
  //                     )
  //                   ),
                    
  //                 ],  
  //               )
                
  //             ) 
  //           ] 
  //         ),
  //       ),
  //     );
  //   });
  // }
  
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

                                  context.read<SosNotifier>().stopTimer();

                                  StorageHelper.clear();
                                  StorageHelper.removeToken();

                                  globalKey.currentState?.closeDrawer();

                                  Navigator.pushAndRemoveUntil(
                                    context, MaterialPageRoute(builder: (BuildContext context) {
                                      return const LoginPage();
                                    }), (route) {
                                      return false;
                                    },
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