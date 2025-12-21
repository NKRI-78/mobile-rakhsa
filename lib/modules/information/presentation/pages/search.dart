import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rakhsa/core/enums/request_state.dart';
import 'package:rakhsa/modules/information/presentation/provider/information_provider.dart';
import 'package:rakhsa/modules/location/provider/location_provider.dart';
import 'package:rakhsa/router/route_trees.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/core/constants/colors.dart';

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
      backgroundColor: Colors.grey.shade50,
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
                    backgroundColor: Colors.grey.shade50,
                    leading: CupertinoNavigationBarBackButton(
                      onPressed: context.pop,
                      color: Colors.black,
                    ),
                  ),

                  if (n.isGetCurrentKbri(RequestState.loading))
                    SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation(primaryColor),
                        ),
                      ),
                    ),

                  if (n.isGetCurrentKbri(RequestState.error))
                    SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation(primaryColor),
                        ),
                      ),
                    ),

                  if (n.isGetCurrentKbri(RequestState.success))
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.only(left: 16.0, right: 16.0),
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Card(
                          color: Colors.white,
                          surfaceTintColor: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  n.currentKbri?.title ?? "-",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
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
                                              'assets/images/placeholder.png',
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
                                              'assets/images/placeholder.png',
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
                                            color: Colors.white,
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
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  if (n.isFetchCountry(RequestState.success))
                    SliverList.builder(
                      itemCount: n.countries.length,
                      itemBuilder: (BuildContext context, int i) {
                        return Container(
                          margin: const EdgeInsets.only(
                            top: 10.0,
                            left: 16.0,
                            right: 16.0,
                          ),
                          decoration: const BoxDecoration(color: Colors.white),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                switch (widget.info) {
                                  case "informasi-kbri":
                                    KBRIDetailRoute(
                                      stateId: n.countries[i].id,
                                    ).push(context);
                                    break;
                                  case "passport-visa":
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
                                      color: Colors.black,
                                      size: 16.0,
                                    ),

                                    const SizedBox(width: 5.0),

                                    Text(
                                      n.countries[i].name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
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
                        style: TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
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
                          hintStyle: TextStyle(
                            color: Color(0xff707070),
                            fontSize: 12,
                          ),
                          hintText: "Pilih Negara yang Anda Inginkan",
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xff707070),
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (n.isFetchCountry(RequestState.loading))
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
