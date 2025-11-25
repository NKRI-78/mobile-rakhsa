import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rakhsa/misc/enums/request_state.dart';
import 'package:rakhsa/modules/information/presentation/provider/information_provider.dart';
import 'package:rakhsa/modules/location/provider/location_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/misc/constants/theme.dart';

import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

import 'package:rakhsa/modules/information/presentation/pages/kbri.dart';
import 'package:rakhsa/modules/information/presentation/pages/passport_visa/index.dart';

class SearchPage extends StatefulWidget {
  final String info;

  const SearchPage({required this.info, super.key});

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  Timer? _queryDebouncer;

  late InformationProvider informationProvider;

  final _searchCountryController = TextEditingController();

  Future<void> getData() async {
    await informationProvider.getCurrentKBRI(
      context.read<LocationProvider>().location?.placemark?.country ?? "-",
    );
  }

  @override
  void initState() {
    super.initState();

    informationProvider = context.read<InformationProvider>()..clearCountry();

    Future.microtask(() => getData());
  }

  @override
  void dispose() {
    _queryDebouncer?.cancel();
    _searchCountryController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResources.backgroundColor,
      body: Consumer<LocationProvider>(
        builder: (context, lp, child) {
          if (!lp.isGetLocationState(RequestState.success)) {
            return Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }
          return Consumer<InformationProvider>(
            builder: (context, n, child) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverAppBar(
                    backgroundColor: ColorResources.backgroundColor,
                    leading: CupertinoNavigationBarBackButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: ColorResources.black,
                    ),
                  ),

                  if (n.isGetCurrentKbriState(RequestState.loading))
                    SliverFillRemaining(
                      child: Center(
                        child: SpinKitChasingDots(color: primaryColor),
                      ),
                    ),

                  if (n.isGetCurrentKbriState(RequestState.error))
                    SliverFillRemaining(
                      child: Center(
                        child: SpinKitChasingDots(color: primaryColor),
                      ),
                    ),

                  if (n.isGetCurrentKbriState(RequestState.success))
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.only(left: 16.0, right: 16.0),
                        decoration: const BoxDecoration(
                          color: ColorResources.white,
                        ),
                        child: Card(
                          color: ColorResources.white,
                          surfaceTintColor: ColorResources.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  n.currentKbri?.title ?? "-",
                                  style: robotoRegular.copyWith(
                                    color: ColorResources.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: Dimensions.fontSizeLarge,
                                  ),
                                ),

                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: n.currentKbri?.img ?? "-",
                                    imageBuilder: (context, imageProvider) {
                                      return Container(
                                        width: double.infinity,
                                        height: 180.0,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: imageProvider,
                                          ),
                                        ),
                                      );
                                    },
                                    placeholder: (context, url) {
                                      return Container(
                                        width: double.infinity,
                                        height: 180.0,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: AssetImage(
                                              'assets/images/default_image.png',
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    errorWidget: (context, url, error) {
                                      return Container(
                                        width: double.infinity,
                                        height: 180.0,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: AssetImage(
                                              'assets/images/default_image.png',
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 8.0),

                                Container(
                                  width: double.infinity,
                                  height: 180.0,
                                  margin: const EdgeInsets.only(
                                    top: 16.0,
                                    bottom: 16.0,
                                  ),
                                  child: Stack(
                                    children: [
                                      GoogleMap(
                                        mapType: MapType.normal,
                                        myLocationEnabled: false,
                                        zoomControlsEnabled: false,
                                        zoomGesturesEnabled: false,
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(
                                            double.parse(
                                              n.currentKbri?.lat ?? "0.0",
                                            ),
                                            double.parse(
                                              n.currentKbri?.lng ?? "0.0",
                                            ),
                                          ),
                                          zoom: 15.0,
                                        ),
                                        markers: <Marker>{
                                          Marker(
                                            markerId: MarkerId(
                                              n.currentKbri?.title ?? "-",
                                            ),
                                            position: LatLng(
                                              double.parse(
                                                n.currentKbri?.lat ?? "0.0",
                                              ),
                                              double.parse(
                                                n.currentKbri?.lng ?? "0.0",
                                              ),
                                            ),
                                          ),
                                        },
                                      ),

                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            right: 8.0,
                                            bottom: 8.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: ColorResources.white,
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                          ),
                                          child: Material(
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                            child: InkWell(
                                              onTap: () async {
                                                final String googleMapsUrl =
                                                    'https://www.google.com/maps/search/?api=1&query=${n.currentKbri?.lat ?? "0.0"},${n.currentKbri?.lng ?? "0.0"}';
                                                final Uri uri = Uri.parse(
                                                  googleMapsUrl,
                                                );

                                                if (await canLaunchUrl(
                                                  Uri.parse(uri.toString()),
                                                )) {
                                                  await launchUrl(
                                                    Uri.parse(uri.toString()),
                                                  );
                                                } else {
                                                  throw 'Could not open maps';
                                                }
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.directions,
                                                      color: Colors.blue,
                                                      size: 26.0,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.only(
                        top: 20.0,
                        left: 16.0,
                        right: 16.0,
                      ),
                      child: Text(
                        "Informasi Alamat KBRI ",
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeOverLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  if (n.isFetchCountryState(RequestState.success))
                    SliverList.builder(
                      itemCount: n.countries.length,
                      itemBuilder: (BuildContext context, int i) {
                        return Container(
                          margin: const EdgeInsets.only(
                            top: 10.0,
                            left: 16.0,
                            right: 16.0,
                          ),
                          decoration: const BoxDecoration(
                            color: ColorResources.white,
                          ),
                          child: Material(
                            color: ColorResources.transparent,
                            child: InkWell(
                              onTap: () {
                                switch (widget.info) {
                                  case "informasi-kbri":
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return KbriPage(
                                            stateId: n.countries[i].id,
                                          );
                                        },
                                      ),
                                    );
                                    break;
                                  case "passport-visa":
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return PassportVisaIndexPage(
                                            stateId: n.countries[i].id,
                                          );
                                        },
                                      ),
                                    );
                                    break;
                                  case "panduan-hukum":
                                    break;
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.flag,
                                      color: ColorResources.black,
                                      size: 16.0,
                                    ),

                                    const SizedBox(width: 5.0),

                                    Text(
                                      n.countries[i].name,
                                      style: robotoRegular.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: ColorResources.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.only(
                        top: 16.0,
                        left: 16.0,
                        right: 16.0,
                      ),
                      child: TextField(
                        controller: _searchCountryController,
                        onChanged: (String query) async {
                          if (_queryDebouncer?.isActive ?? false) {
                            _queryDebouncer?.cancel();
                          }
                          _queryDebouncer = Timer(
                            const Duration(milliseconds: 500),
                            () {
                              informationProvider.fetchCountry(query);
                            },
                          );
                        },
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: ColorResources.white,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(
                              Radius.circular(9.0),
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(
                              Radius.circular(9.0),
                            ),
                          ),
                          hintStyle: robotoRegular.copyWith(
                            color: ColorResources.grey,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                          hintText: "Pilih Negara yang Anda Inginkan",
                          prefixIcon: const Icon(
                            Icons.search,
                            color: ColorResources.grey,
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (n.isFetchCountryState(RequestState.loading))
                    const SliverFillRemaining(
                      child: Center(
                        child: SizedBox(
                          width: 16.0,
                          height: 16.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                              Color(0xFFFE1717),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
