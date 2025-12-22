import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
          if (!lp.isGetLocationState(.success)) {
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

                  if (n.isGetCurrentKbri(.loading))
                    SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation(primaryColor),
                        ),
                      ),
                    ),

                  if (n.isGetCurrentKbri(.error))
                    SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation(primaryColor),
                        ),
                      ),
                    ),

                  if (n.isGetCurrentKbri(.success))
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const .symmetric(horizontal: 16),
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Card(
                          color: Colors.white,
                          surfaceTintColor: Colors.white,
                          child: Padding(
                            padding: const .all(8.0),
                            child: Column(
                              crossAxisAlignment: .start,
                              mainAxisSize: .min,
                              children: [
                                Text(
                                  n.currentKbri?.title ?? "-",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: .bold,
                                    fontSize: 16,
                                  ),
                                ),

                                Container(
                                  margin: .symmetric(vertical: 16.0),
                                  child: CachedNetworkImage(
                                    imageUrl: n.currentKbri?.img ?? "-",
                                    imageBuilder: (context, imageProvider) {
                                      return Container(
                                        width: double.infinity,
                                        height: 180.0,
                                        decoration: BoxDecoration(
                                          borderRadius: const .all(
                                            .circular(10.0),
                                          ),
                                          image: DecorationImage(
                                            fit: .cover,
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
                                          borderRadius: .all(.circular(10.0)),
                                          image: DecorationImage(
                                            fit: .cover,
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
                                          borderRadius: .all(.circular(10.0)),
                                          image: DecorationImage(
                                            fit: .cover,
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
                                  height: 180,
                                  margin: .symmetric(vertical: 16),
                                  child: Stack(
                                    children: [
                                      GoogleMap(
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
                                        alignment: .bottomRight,
                                        child: Container(
                                          margin: .only(right: 8, bottom: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: .circular(8.0),
                                          ),
                                          child: Material(
                                            borderRadius: .circular(8.0),
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
                                                padding: .all(8.0),
                                                child: Column(
                                                  crossAxisAlignment: .start,
                                                  mainAxisSize: .min,
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
                      margin: const .fromLTRB(16, 20, 16, 0),
                      child: Text(
                        "Informasi Alamat KBRI ",
                        style: TextStyle(fontSize: 24, fontWeight: .bold),
                      ),
                    ),
                  ),

                  if (n.isFetchCountry(.success))
                    SliverList.builder(
                      itemCount: n.countries.length,
                      itemBuilder: (BuildContext context, int i) {
                        return Container(
                          margin: .fromLTRB(16, 10, 16, 0),
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
                                padding: const .all(8.0),
                                child: Row(
                                  crossAxisAlignment: .center,
                                  mainAxisSize: .min,
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
                                        fontWeight: .bold,
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
                      margin: .fromLTRB(16, 16, 16, 0),
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
                            borderRadius: .all(.circular(9.0)),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: .all(.circular(9.0)),
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

                  if (n.isFetchCountry(.loading))
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
