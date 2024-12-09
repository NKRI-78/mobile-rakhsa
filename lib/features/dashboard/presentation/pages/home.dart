import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/update_address_notifier.dart';

import 'package:uuid/uuid.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:rakhsa/camera.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/auth/presentation/pages/login.dart';
import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';
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

class HomePageState extends State<HomePage> {

  List<Marker> _markers = [];
  List<Marker> get markers => [..._markers];

  late DashboardNotifier dashboardNotifier;
  late UpdateAddressNotifier updateAddressNotifier;
  late ProfileNotifier profileNotifier;

  String currentAddress = "";
  String currentCountry = "";
  String currentLat = "";
  String currentLng = "";

  bool loadingGmaps = true;

  Future<void> getData() async {
    if(!mounted) return;
      profileNotifier.getProfile();
    if(!mounted) return;
      getCurrentLocation();
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
          }
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
      
      if(!mounted) return;
        dashboardNotifier.getNews(
          type: "ews",
          lat: position.latitude,
          lng: position.longitude
        );
    });
  }

  @override
  void initState() {
    super.initState();

    profileNotifier = context.read<ProfileNotifier>();
    updateAddressNotifier = context.read<UpdateAddressNotifier>();
    dashboardNotifier = context.read<DashboardNotifier>();

    Future.microtask(() => getData());

    checkAndGetLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Provider.of<WebSocketsService>(context);

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
          child: Container(
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
                        Text(context.read<ProfileNotifier>().entity.data?.username ?? "-",
                          style: robotoRegular.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: Dimensions.fontSizeExtraLarge
                          ),
                        )
                      ],
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
                            imageUrl: context.read<ProfileNotifier>().entity.data?.avatar ?? "-",
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
                  margin: const EdgeInsets.symmetric(
                    vertical: 16.0
                  ),
                  child: SosButton(
                    location: currentAddress,
                    country: currentCountry,
                    lat: currentLat,
                    lng: currentLng,
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
                    
                    return CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        viewportFraction: 1.0,
                        height: 280.0 
                      ),
                      items: notifier.news.map((item) {
                        if(item.id == 0) {
                          return Card(
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
                          );
                        }
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, 
                              MaterialPageRoute(
                              builder: (context) {
                                return NewsDetailPage(
                                  title: item.title.toString(), 
                                  img: item.img.toString(), 
                                  desc: item.desc.toString(),
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
                                      fit: BoxFit.fitHeight,
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
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Flexible(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        item.title.toString(),
                                                        style: robotoRegular.copyWith(
                                                          color: ColorResources.white,
                                                          fontSize: Dimensions.fontSizeDefault,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4.0),
                                                      Text(
                                                        item.desc.toString(),
                                                        maxLines: 4,
                                                        style: robotoRegular.copyWith(
                                                          overflow: TextOverflow.ellipsis,
                                                          color: ColorResources.white,
                                                          fontSize: Dimensions.fontSizeSmall,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4.0),
                                                       Text("Baca selengkapnya",
                                                        style: robotoRegular.copyWith(
                                                          color: ColorResources.white,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: Dimensions.fontSizeDefault,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
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
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Flexible(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        item.title.toString(),
                                                        style: robotoRegular.copyWith(
                                                          color: ColorResources.white,
                                                          fontSize: Dimensions.fontSizeDefault,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4.0),
                                                      Text(
                                                        item.desc.toString(),
                                                        style: robotoRegular.copyWith(
                                                          color: ColorResources.white,
                                                          fontSize: Dimensions.fontSizeSmall,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
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
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Flexible(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        item.title.toString(),
                                                        style: robotoRegular.copyWith(
                                                          color: ColorResources.white,
                                                          fontSize: Dimensions.fontSizeDefault,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4.0),
                                                      Text(
                                                        item.desc.toString(),
                                                        style: robotoRegular.copyWith(
                                                          color: ColorResources.white,
                                                          fontSize: Dimensions.fontSizeSmall,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
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

  late SosNotifier sosNotifier;

  Timer? holdTimer;

  void handleLongPressStart() {
    if(StorageHelper.getUserId() == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const LoginPage();
      }));
    } else {
      sosNotifier.pulseController!.forward();

      holdTimer = Timer(const Duration(milliseconds: 2000), () {
        sosNotifier.pulseController!.reverse();
        if (mounted) {
          startTimer();
        }
      });
    }
  }

  void handleLongPressEnd() {
    if(StorageHelper.getUserId() == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {  
        return const LoginPage();
      }));
    } else {
      if (holdTimer?.isActive ?? false) {
        holdTimer?.cancel();
        sosNotifier.pulseController!.reverse();
      } else if (!sosNotifier.isPressed) {
        setState(() => sosNotifier.isPressed = false);
      }
    }
  }

  void startTimer() {
    DateTime now = DateTime.now();
    String time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    String sosId = const Uuid().v4();

    Navigator.push(context, 
      MaterialPageRoute(builder: (context) {
        return CameraPage(
          sosId: sosId,
          location: widget.location, 
          country: widget.country, 
          lat: widget.lat, 
          lng: widget.lng, 
          time: time
        ); 
      })
    ).then((value) {

      if(value != null) {
        setState(() {
          sosNotifier.isPressed = true;
          sosNotifier.countdownTime = 60; 
        });

        sosNotifier.timerController!
        ..reset()
        ..forward().whenComplete(() {
          setState(() => sosNotifier.isPressed = false);
          
          sosNotifier.expireSos(sosId: sosId);
          sosNotifier.pulseController!.reverse();
        });

        sosNotifier.timerController!.addListener(() {
          setState(() {
            sosNotifier.countdownTime = (60 - (sosNotifier.timerController!.value * 60)).round();
          });
        });
      }

    });

  }

  @override
  void initState() {
    super.initState();

    sosNotifier = context.read<SosNotifier>();

    sosNotifier.initializePulse(this);

    sosNotifier.pulseAnimation = Tween<double>(begin: 1.0, end: 2.5).animate(
      CurvedAnimation(parent: sosNotifier.pulseController!, curve: Curves.easeOut),
    );

    sosNotifier.initializeTimer(this);
  }

  @override
  void dispose() {
    sosNotifier.pulseController?.dispose();
    sosNotifier.timerController?.dispose();
    
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
              animation: sosNotifier.pulseAnimation,
              builder: (BuildContext context, Widget? child) {
                return Transform.scale(
                  scale: sosNotifier.pulseAnimation.value * scaleFactor,
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
          if (sosNotifier.isPressed)
            SizedBox(
              width: 145,
              height: 145,
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1FFE17)),
                strokeWidth: 6,
                value: 1 - sosNotifier.timerController!.value,
                backgroundColor: Colors.transparent,
              ),
            ),
          GestureDetector(
            onLongPressStart: (_) => handleLongPressStart(),
            onLongPressEnd: (_) => handleLongPressEnd(),
            child: AnimatedBuilder(
              animation: sosNotifier.timerController!,
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
                    sosNotifier.isPressed ? "${sosNotifier.countdownTime}" : "SOS",
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