import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          onRefresh: () {
            return Future.sync(() {

            });
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.only(
                top: 16.0,
                left: 14.0,
                right: 14.0,
                bottom: 16.0
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
              
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
              
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Selamat datang",
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: ColorResources.hintColor
                            ),
                          ), 
                          Text("Reihan Agam",
                            style: robotoRegular.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: Dimensions.fontSizeLarge
                            ),
                          )
                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          
                          CachedNetworkImage(
                            imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSPnE_fy9lLMRP5DLYLnGN0LRLzZOiEpMrU4g&s",
                            imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                              return CircleAvatar(
                                backgroundImage: imageProvider,
                              );
                            },
                            placeholder: (BuildContext context, String url) {
                              return const CircleAvatar(
                                backgroundImage: AssetImage('assets/images/default.jpeg'),
                              );
                            },
                            errorWidget: (BuildContext context, String url, Object error) {
                              return const CircleAvatar(
                                backgroundImage: AssetImage('assets/images/default.jpeg'),
                              );
                            },
                          )

                        ],
                      )
              
                    ],
                  ),

                  Container(
                    margin: const EdgeInsets.only(
                      top: 30.0
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        
                        Text("Apakah Anda dalam\nkeadaan darurat ?",
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeOverLarge,
                            fontWeight: FontWeight.bold
                          ),
                        )

                      ]
                    )
                  ),

                  Container(
                    margin: const EdgeInsets.only(
                      top: 20.0
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        
                        Text("Tekan dan tahan tombol ini, maka bantuan\nakan segera hadir",
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: ColorResources.hintColor
                          ),
                        )

                      ],
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(
                      top: 80.0
                    ),
                    child: const SosButton()
                  )
              
                ],
              ),
            )
          ),
        ),
      )
    );
  }
}

class SosButton extends StatefulWidget {
  const SosButton({super.key});

  @override
  SosButtonState createState() => SosButtonState();
}

class SosButtonState extends State<SosButton> with TickerProviderStateMixin {

  late AnimationController pulseController;
  late Animation<double> pulseAnimation;

  late AnimationController timerController;

  bool isPressed = false;
  
  late int countdownTime;

  @override
  void initState() {
    super.initState();

    pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    pulseAnimation = Tween<double>(begin: 1.0, end: 2.5).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeOut),
    );

    timerController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );
  }

  void startTimer() {
    setState(() {
      isPressed = true;
      countdownTime = 60; 
    });

    timerController
      ..reset()
      ..forward().whenComplete(() {
        setState(() => isPressed = false);
        // Add action after timer completes, e.g., send SOS alert
      });

    timerController.addListener(() {
      setState(() {
        countdownTime = (60 - (timerController.value * 60)).round();
      });
    });
  }

  @override
  void dispose() {
    pulseController.dispose();
    timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (double scaleFactor in [0.8, 1.2, 1.6])
            AnimatedBuilder(
              animation: pulseAnimation,
              builder: (BuildContext context, Widget? child) {
                return Transform.scale(
                  scale: pulseAnimation.value * scaleFactor,
                  child: Container(
                    width: 60, 
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFE1717).withOpacity(0.2 / scaleFactor),
                    ),
                  ),
                );
              },
            ),
          if (isPressed)
            SizedBox(
              width: 145,
              height: 145,
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1FFE17)),
                strokeWidth: 6,
                value: 1 - timerController.value,
                backgroundColor: Colors.transparent,
              ),
            ),
          GestureDetector(
            onLongPress: () {
              if (!isPressed) startTimer();
            },
            child: AnimatedBuilder(
              animation: timerController,
              builder: (BuildContext context, Widget? child) {
                return Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFE1717),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFE1717).withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isPressed ? "$countdownTime" : "SOS",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}