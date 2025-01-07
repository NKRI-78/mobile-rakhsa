import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:flutter_html/flutter_html.dart' as fh;

import 'package:permission_handler/permission_handler.dart';
import 'package:rakhsa/firebase.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:rakhsa/camera.dart';

import 'package:rakhsa/shared/basewidgets/modal/modal.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/auth/presentation/pages/login.dart';
import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';

import 'package:rakhsa/features/dashboard/presentation/provider/update_address_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/dashboard_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/expire_sos_notifier.dart';

import 'package:rakhsa/features/news/persentation/pages/detail.dart';

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

class HomePageState extends State<HomePage> with WidgetsBindingObserver {

  late FirebaseProvider firebaseProvider;
  late DashboardNotifier dashboardNotifier;
  late UpdateAddressNotifier updateAddressNotifier;
  late ProfileNotifier profileNotifier;

  bool isResumedProcessing = false;

  List<Marker> _markers = [];
  List<Marker> get markers => [..._markers];

  String currentAddress = "";
  String currentCountry = "";
  String currentLat = "";
  String currentLng = "";

  bool isDialogLocationShowing = false;
  bool isDialogNotificationShowing = false;
  
  bool loadingGmaps = true;

  Future<void> getData() async {
    if(!mounted) return;
      await profileNotifier.getProfile();

    if(!mounted) return;
      await firebaseProvider.initFcm();

    if(!mounted) return;
      getCurrentLocation();

    if(!mounted) return;
      checkNotificationPermission();
  }

  Future<void> getCurrentLocation() async {
    try {
      
      await Geolocator.requestPermission();

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

        _markers = [];
        _markers.add(
          Marker(
            markerId: const MarkerId("currentPosition"),
            position: LatLng(
              position.latitude, 
              position.longitude
            ),
            icon: BitmapDescriptor.defaultMarker,
          )
        );
        
        loadingGmaps = false;
      });

      Future.delayed(Duration.zero, () async {
        await updateAddressNotifier.updateAddress(
          address: address, 
          lat: position.latitude, 
          lng: position.longitude
        );

        await dashboardNotifier.getEws(
          lat: position.latitude,
          lng: position.longitude
        );
      });
    } catch(e) {

      checkLocationPermission();

    }
  }

  Future<void> checkNotificationPermission() async {
    bool notificationReq = await Permission.notification.isDenied;
    if(notificationReq) {
      if (!isDialogNotificationShowing) {
        setState(() => isDialogNotificationShowing = true);
        await GeneralModal.dialogRequestPermission(
          msg: "Perizinan akses notifikasi dibutuhkan, silahkan aktifkan terlebih dahulu",
          type: "notification"
        );

        Future.delayed(const Duration(seconds: 2),() {
          setState(() => isDialogNotificationShowing = false);
        });
      }
    }
  }

  Future<void> checkLocationPermission() async {
    var locationReq = await Permission.location.isDenied || await Permission.location.isPermanentlyDenied;

    if(locationReq) {
      if (!isDialogLocationShowing) {
        setState(() => isDialogLocationShowing = true);
        await GeneralModal.dialogRequestPermission(
          msg: "Perizinan akses lokasi dibutuhkan, silahkan aktifkan terlebih dahulu",
          type: "notification"
        );

        Future.delayed(const Duration(seconds: 2),() {
          setState(() => isDialogLocationShowing = false);
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && !isResumedProcessing) {
      debugPrint("=== APP RESUME ===");
      
      isResumedProcessing = true;

      await Future.delayed(const Duration(milliseconds: 500)); 
      await checkNotificationPermission();
      await getCurrentLocation();

      isResumedProcessing = false;
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    
    firebaseProvider = context.read<FirebaseProvider>();
    profileNotifier = context.read<ProfileNotifier>();
    updateAddressNotifier = context.read<UpdateAddressNotifier>();
    dashboardNotifier = context.read<DashboardNotifier>();

    Future.microtask(() => getData());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator.adaptive(
        onRefresh: () {
          return Future.sync(() {
            getData();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child:  Container(
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

                StorageHelper.getUserId() == null
                ? const SizedBox()
                : context.watch<ProfileNotifier>().state == ProviderState.error 
                ? const SizedBox()
                : context.watch<ProfileNotifier>().state == ProviderState.loading 
                ? const SizedBox()
                : Row(
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
                        Text(profileNotifier.entity.data?.username ?? "-",
                          style: robotoRegular.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: Dimensions.fontSizeExtraLarge
                          ),
                        )
                      ],
                    ),

                    Container(
                      width: 12.0,
                      height: 12.0,
                      decoration: BoxDecoration(
                        color: context.watch<WebSocketsService>().connectionIndicator == ConnectionIndicator.green 
                        ? ColorResources.green 
                        : context.watch<WebSocketsService>().connectionIndicator == ConnectionIndicator.yellow 
                        ? ColorResources.yellow 
                        : context.watch<WebSocketsService>().connectionIndicator == ConnectionIndicator.red 
                        ? ColorResources.error 
                        : ColorResources.transparent,
                        shape: BoxShape.circle,
                      ),                      
                    ),

                    GestureDetector(
                      onTap: () {
                        widget.globalKey.currentState?.openEndDrawer();
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          
                          CachedNetworkImage(
                            imageUrl: profileNotifier.entity.data?.avatar ?? "-",
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
                    top: 40.0
                  ),
                  child: SosButton(
                    location: currentAddress,
                    country: currentCountry,
                    lat: currentLat,
                    lng: currentLng,
                    isConnected: context.watch<WebSocketsService>().isConnected ? true : false,
                  )
                ),

                Consumer<DashboardNotifier>(
                  builder: (BuildContext context, DashboardNotifier notifier, Widget? child) {
                    
                    if(notifier.state == ProviderState.loading) {
                      return const SizedBox(
                        height: 200.0,
                        child: Center(
                          child: SizedBox(
                            width: 16.0,
                            height: 16.0,
                            child: CircularProgressIndicator()
                          )
                        ),
                      );
                    }

                    if(notifier.state == ProviderState.error) {
                      return SizedBox(
                        height: 200.0,
                        child: Center(
                          child: Text(notifier.message,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: ColorResources.black
                            ),
                          )
                        )
                      );
                    }
                    
                    return notifier.ews.isEmpty 
                    ? Container(
                        margin: const EdgeInsets.only(
                          top: 30.0
                        ),
                        child: Card(
                          color: ColorResources.white,
                          surfaceTintColor: ColorResources.white,
                          elevation: 1.0,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                                        
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                        
                                      context.watch<ProfileNotifier>().state == ProviderState.error 
                                      ? const SizedBox()
                                      : context.watch<ProfileNotifier>().state == ProviderState.loading 
                                      ? const SizedBox() 
                                      : CachedNetworkImage(
                                          imageUrl: profileNotifier.entity.data!.avatar.toString(),
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
                                        
                                            Text(loadingGmaps 
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
                                  ),
                              
                                  Container(
                                    width: double.infinity,
                                    height: 120.0,
                                    margin: const EdgeInsets.only(
                                      top: 16.0,
                                      left: 16.0, 
                                      right: 16.0
                                    ),
                                    child: loadingGmaps 
                                    ? const SizedBox() 
                                    : GoogleMap(
                                        mapType: MapType.normal,
                                        gestureRecognizers: {}..add(Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer())),
                                        myLocationEnabled: false,
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(
                                            double.parse(currentLat), 
                                            double.parse(currentLng)
                                          ),
                                          zoom: 12.0,
                                        ),
                                        markers: Set.from(markers),
                                      ),
                                    )
                                                        
                                ],
                              ),
                            ),
                          )
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.only(
                          top: 45.0
                        ),
                        child: CarouselSlider(
                          options: CarouselOptions(
                            autoPlayInterval: const Duration(seconds: 5),
                            autoPlay: true,
                            viewportFraction: 1.0,
                            height: 200.0 
                          ),
                          items: notifier.ews.map((item) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return NewsDetailPage(
                                    title: item.title.toString(), 
                                    img: item.img.toString(), 
                                    desc: item.desc.toString(),
                                    location: item.desc.toString(),
                                    type: item.type.toString(),
                                  );
                                },
                              )).then((value) {
                                if(value != null) {
                                  getData();
                                }
                              });
                            },
                            child: Card(
                              color: ColorResources.redHealth,
                              surfaceTintColor: ColorResources.redHealth,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              ),
                              elevation: 1.0,
                              child: CachedNetworkImage(
                                imageUrl: item.img.toString(),
                                imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: imageProvider,
                                      ),
                                    ),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                item.location.toString(),
                                                maxLines: 1,
                                                style: robotoRegular.copyWith(
                                                  color: ColorResources.white,
                                                  fontSize: Dimensions.fontSizeDefault,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                item.createdAt.toString(),
                                                style: robotoRegular.copyWith(
                                                  color: ColorResources.white,
                                                  fontSize: Dimensions.fontSizeDefault,
                                                ),
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                item.title.toString(),
                                                style: robotoRegular.copyWith(
                                                  color: ColorResources.white,
                                                  fontSize: Dimensions.fontSizeDefault,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              fh.Html(
                                                data: item.desc.toString(),
                                                shrinkWrap: true,
                                                style: {
                                                  'body': fh.Style(
                                                    maxLines: 2,
                                                    margin: fh.Margins.zero,
                                                    textOverflow: TextOverflow.ellipsis,
                                                    color: ColorResources.white,
                                                    fontSize: fh.FontSize(Dimensions.fontSizeSmall),
                                                  ),
                                                  'p': fh.Style(
                                                    maxLines: 2,
                                                    textOverflow: TextOverflow.ellipsis,
                                                    margin: fh.Margins.zero,
                                                    color: ColorResources.white,
                                                    fontSize: fh.FontSize(Dimensions.fontSizeSmall),
                                                  ),
                                                  'span': fh.Style(
                                                    maxLines: 2,
                                                    textOverflow: TextOverflow.ellipsis,
                                                    margin: fh.Margins.zero,
                                                    color: ColorResources.white,
                                                    fontSize: fh.FontSize(Dimensions.fontSizeSmall),
                                                  ),
                                                  'div': fh.Style(
                                                    maxLines: 2,
                                                    textOverflow: TextOverflow.ellipsis,
                                                    margin: fh.Margins.zero,
                                                    color: ColorResources.white,
                                                    fontSize: fh.FontSize(Dimensions.fontSizeSmall),
                                                  )
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                placeholder: (BuildContext context, String url) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      image: const DecorationImage(
                                        fit: BoxFit.fitWidth,
                                        image: AssetImage('assets/images/default.jpeg'),
                                      ),
                                    ),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                errorWidget: (BuildContext context, String url, Object error) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      image: const DecorationImage(
                                        fit: BoxFit.fitWidth,
                                        image: AssetImage('assets/images/default.jpeg'),
                                      ),
                                    ),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }
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
  final String location;
  final String country;
  final String lat;
  final String lng;
  final bool isConnected;

  const SosButton({
    required this.location,
    required this.country,
    required this.lat, 
    required this.lng,
    required this.isConnected,
    super.key
  });

  @override
  SosButtonState createState() => SosButtonState();
}

class SosButtonState extends State<SosButton> with TickerProviderStateMixin {

  late SosNotifier sosNotifier;
  late ProfileNotifier profileNotifier;

  Future<void> handleLongPressStart() async {
    if(profileNotifier.entity.data!.sos.running) {
      GeneralModal.infoEndSos(
        sosId: profileNotifier.entity.data!.sos.id,
        chatId: profileNotifier.entity.data!.sos.chatId,
        recipientId: profileNotifier.entity.data!.sos.recipientId,
        msg: "Apakah kasus Anda sebelumnya telah ditangani ?",
      );
    } else {
      if(StorageHelper.getUserId() == null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const LoginPage();
        }));
      } else {
        sosNotifier.pulseController!.forward();
        sosNotifier.holdTimer = Timer(const Duration(milliseconds: 2000), () {
          startTimer();
        });
      }
    }
  }

  Future<void> startTimer() async {
    if(mounted) {
      Navigator.push(context, 
        MaterialPageRoute(builder: (context) {
          return CameraPage(
            location: widget.location, 
            country: widget.country, 
            lat: widget.lat, 
            lng: widget.lng, 
          ); 
        })
      ).then((value) {
        if(value != null) {
          sosNotifier.startTimer();
        } else {
          sosNotifier.resetAnimation();
        }
      });
    }

  }

  @override
  void initState() {
    super.initState();

    sosNotifier = context.read<SosNotifier>();
    profileNotifier = context.read<ProfileNotifier>();
    
    sosNotifier.initializeTimer(this);
  
    sosNotifier.initializePulse(this);

    if (sosNotifier.isPressed) {
      sosNotifier.resumeTimer();
    }
  }

  @override
  void dispose() {
    sosNotifier.pulseController?.dispose();
    sosNotifier.timerController?.dispose();
    
    sosNotifier.holdTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SosNotifier>(
      builder: (BuildContext context, SosNotifier notifier, Widget? child) {
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (double scaleFactor in [0.8, 1.2, 1.4])
                AnimatedBuilder(
                  animation: notifier.pulseAnimation,
                  builder: (BuildContext context, Widget? child) {
                    return Transform.scale(
                      scale: notifier.pulseAnimation.value * scaleFactor,
                      child: Container(
                        width: 70, 
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:const Color(0xFFFE1717).withOpacity(0.2 / scaleFactor)  ,
                        ),
                      ),
                    );
                  },
                ),
              if (notifier.isPressed)
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1FFE17)),
                    strokeWidth: 6,
                    value: 1 - notifier.timerController!.value,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              GestureDetector(
                onLongPressStart: (_) async => widget.isConnected ? notifier.isTimerRunning ? () {} : await handleLongPressStart() : () {},
                child: AnimatedBuilder(
                  animation: notifier.timerController!,
                  builder: (BuildContext context, Widget? child) {
                    return Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isConnected
                          ? const Color(0xFFFE1717)
                          : const Color(0xFF7A7A7A),
                        boxShadow: [
                          BoxShadow(
                            color: widget.isConnected 
                            ? const Color(0xFFFE1717).withOpacity(0.5) 
                            : const Color(0xFF7A7A7A).withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        sosNotifier.isPressed ? "${notifier.countdownTime}" : "SOS",
                        style: robotoRegular.copyWith(
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
      },
    );
  }
}