import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/widgets/ews/list.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/widgets/ews/single.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/widgets/location/current_location.dart';
import 'package:rakhsa/features/dashboard/presentation/pages/widgets/sos/button.dart';
import 'package:rakhsa/firebase.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:rakhsa/shared/basewidgets/modal/modal.dart';

import 'package:rakhsa/common/helpers/enum.dart';
import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/auth/presentation/provider/profile_notifier.dart';

import 'package:rakhsa/features/dashboard/presentation/provider/update_address_notifier.dart';
import 'package:rakhsa/features/dashboard/presentation/provider/dashboard_notifier.dart';

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

        StorageHelper.saveUserNationality(nationality: placemarks[0].country!);

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
      await getData();
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
                        Text("Selamat Datang",
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
                    ? CurrentLocationWidget(
                        avatar: context.read<ProfileNotifier>().entity.data?.avatar.toString() ?? "",
                        loadingGmaps: loadingGmaps, 
                        markers: markers, 
                        currentAddress: currentAddress, 
                        currentLat: currentLat, 
                        currentLng: currentLng
                      )
                    : Container(
                        margin: const EdgeInsets.only(
                          top: 45.0
                        ),
                        child: notifier.ews.length == 1 
                       ? EwsSingleWidget(
                          getData: getData
                        )
                      : EwsListWidget(
                        getData: getData,
                      )
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

