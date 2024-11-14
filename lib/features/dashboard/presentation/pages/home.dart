import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:rakhsa/camera.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';

import 'package:rakhsa/websockets.dart';

class HomePage extends StatefulWidget {
  final GlobalKey<ScaffoldState> globalKey;
  const HomePage({
    required this.globalKey,
    super.key
  });

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {

  late WebSocketsService webSocketsService;
  late ProfileNotifier profileNotifier;

  String currentAddress = "";
  String currentCountry = "";
  String currentLat = "";
  String currentLng = "";

  bool loadingCurrentAddress = true;

  Future<void> getData() async {
    if(!mounted) return;
      profileNotifier.getProfile();
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
        },
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
      
      loadingCurrentAddress = false;
    });
  }

  @override
  void initState() {
    super.initState();

    webSocketsService = context.read<WebSocketsService>();
    profileNotifier = context.read<ProfileNotifier>();

    checkAndGetLocation();

    Future.microtask(() => getData());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Provider.of<WebSocketsService>(context);

    return Scaffold(
      body: Consumer<ProfileNotifier>(
        builder: (BuildContext context, ProfileNotifier notifier, Widget? child) {
          if(notifier.providerState == ProviderState.loading) {
            return const Center(
              child: SizedBox(
                width: 16.0,
                height: 16.0,
                child: CircularProgressIndicator()
              ),
            );
          }
           if(notifier.providerState == ProviderState.error) {
            return Center(
              child: Text(notifier.message,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: ColorResources.black
                ),
              ),
            );
          }
          return SafeArea(
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
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: ColorResources.hintColor
                                ),
                              ), 
                              Text(notifier.profileModel.data?.username ?? "-",
                                style: robotoRegular.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: Dimensions.fontSizeExtraLarge
                                ),
                              )
                            ],
                          ),

                          GestureDetector(
                            onTap: () {
                              widget.globalKey.currentState?.openDrawer();
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                
                                CachedNetworkImage(
                                  imageUrl: notifier.profileModel.data?.avatar ?? "-",
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
                            ),
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
                                fontSize: Dimensions.fontSizeSmall,
                                color: ColorResources.hintColor
                              ),
                            )

                          ],
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.only(
                          top: 55.0
                        ),
                        child: SosButton(
                          location: currentAddress,
                          country: currentCountry,
                          lat: currentLat,
                          lng: currentLng,
                        )
                      ),

                      Container(
                        margin: const EdgeInsets.only(
                          top: 45.0
                        ),
                        child: Card(
                          color: ColorResources.white,
                          surfaceTintColor: ColorResources.white,
                          elevation: 1.0,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [

                                    CachedNetworkImage(
                                      imageUrl: notifier.profileModel.data?.avatar ?? "-",
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
                                    ),

                                    const SizedBox(width: 15.0),

                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [

                                          Text("Posisi Anda saat ini",
                                            style: robotoRegular.copyWith(
                                              fontSize: Dimensions.fontSizeDefault,
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),

                                          const SizedBox(height: 4.0),
                                      
                                          Text(loadingCurrentAddress 
                                            ? "Mohon tunggu..." 
                                            : currentAddress,
                                            style: robotoRegular.copyWith(
                                              fontSize: Dimensions.fontSizeSmall,
                                              color: ColorResources.black
                                            ),
                                          )
                                      
                                        ],
                                      ),
                                    )

                                  ],
                                )

                              ],
                            ),
                          )
                        )
                      )
                  
                    ],
                  ),
                )
              ),
            ),
          );
        },
      ) 
    );
  }
}

class SosButton extends StatefulWidget {
  final String location;
  final String country;
  final String lat;
  final String lng;

  const SosButton({
    required this.location,
    required this.country,
    required this.lat, 
    required this.lng,
    super.key
  });

  @override
  SosButtonState createState() => SosButtonState();
}

class SosButtonState extends State<SosButton> with TickerProviderStateMixin {

  late AnimationController pulseController;
  late AnimationController timerController;  

  late Animation<double> pulseAnimation;

  late int countdownTime;

  bool isPressed = false;
  Timer? holdTimer;

  @override
  void initState() {
    super.initState();

    pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    pulseAnimation = Tween<double>(begin: 1.0, end: 2.5).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeOut),
    );

    timerController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );
  }

  void handleLongPressStart() {
    pulseController.forward();

    holdTimer = Timer(const Duration(milliseconds: 2000), () {
      pulseController.reverse();
      if (mounted) {
        startTimer();
      }
    });
  }

  void handleLongPressEnd() {
    if (holdTimer?.isActive ?? false) {
      holdTimer?.cancel();
      pulseController.reverse();
    } else if (!isPressed) {
      setState(() => isPressed = false);
    }
  }

  void startTimer() {
    DateTime now = DateTime.now();
    String time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    // context.read<WebSocketsService>().sos(
    //   location: widget.location,
    //   country: widget.country,
    //   lat: widget.lat,
    //   lng: widget.lng,
    //   time: time
    // );

    Navigator.push(context, 
      MaterialPageRoute(builder: (context) {
        return CameraPage(
          location: widget.location, 
          country: widget.country, 
          lat: widget.lat, 
          lng: widget.lng, 
          time: time
        ); 
      })
    ).then((_) {

      setState(() {
        isPressed = true;
        countdownTime = 60; 
      });

      timerController
      ..reset()
      ..forward().whenComplete(() {
        setState(() => isPressed = false);
        pulseController.reverse();
      });

      timerController.addListener(() {
        setState(() {
          countdownTime = (60 - (timerController.value * 60)).round();
        });
      });

    });

  }

  @override
  void dispose() {
    pulseController.dispose();
    timerController.dispose();
    
    holdTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (double scaleFactor in [0.8, 1.2, 1.4])
            AnimatedBuilder(
              animation: pulseAnimation,
              builder: (BuildContext context, Widget? child) {
                return Transform.scale(
                  scale: pulseAnimation.value * scaleFactor,
                  child: Container(
                    width: 55, 
                    height: 55,
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
            onLongPressStart: (_) => handleLongPressStart(),
            onLongPressEnd: (_) => handleLongPressEnd(),
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