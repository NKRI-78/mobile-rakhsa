import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:rakhsa/modules/information/presentation/provider/information_provider.dart';

class KbriPage extends StatefulWidget {
  final int stateId;

  const KbriPage({required this.stateId, super.key});

  @override
  State<KbriPage> createState() => KbriPageState();
}

class KbriPageState extends State<KbriPage> {
  late InformationProvider informationProvider;

  Future<void> getData() async {
    if (!mounted) return;
    informationProvider.getKBRIByCountryId(widget.stateId.toString());
  }

  @override
  void initState() {
    super.initState();

    informationProvider = context.read<InformationProvider>();

    Future.microtask(() => getData());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: RefreshIndicator.adaptive(
        onRefresh: () {
          return Future.sync(() {
            getData();
          });
        },
        child: Consumer<InformationProvider>(
          builder: (context, n, child) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverAppBar(
                  title: const SizedBox(),
                  leading: CupertinoNavigationBarBackButton(
                    color: Colors.black,
                    onPressed: context.pop,
                  ),
                ),

                if (n.isGetKbriByCountryId(.loading))
                  const SliverFillRemaining(
                    child: Center(
                      child: SizedBox(
                        width: 16.0,
                        height: 16.0,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),

                if (n.isGetKbriByCountryId(.error))
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        "KBRI not found",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                  ),

                if (n.isGetKbriByCountryId(.success))
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const .all(8.0),
                      margin: const .symmetric(horizontal: 8),
                      child: Text(
                        "Data Pencarian KBRI Negara ${n.kbriCountry?.stateName.toString()}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: .bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                if (n.isGetKbriByCountryId(.success))
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Container(
                        margin: .symmetric(horizontal: 18, vertical: 8),
                        child: CachedNetworkImage(
                          imageUrl: n.kbriCountry?.img.toString() ?? "-",
                          imageBuilder: (context, imageProvider) {
                            return Container(
                              width: double.infinity,
                              height: 200.0,
                              decoration: BoxDecoration(
                                borderRadius: .circular(10.0),
                                image: DecorationImage(
                                  fit: .fitWidth,
                                  image: imageProvider,
                                ),
                              ),
                              child: Container(
                                margin: .all(10),
                                alignment: .bottomLeft,
                                child: Text(
                                  "Kbri ${n.kbriCountry?.title.toString()}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: .bold,
                                  ),
                                ),
                              ),
                            );
                          },
                          placeholder: (context, url) {
                            return Container(
                              width: double.infinity,
                              height: 200.0,
                              decoration: BoxDecoration(
                                borderRadius: .circular(10.0),
                                image: const DecorationImage(
                                  fit: .fitWidth,
                                  image: AssetImage(
                                    'assets/images/user-placeholder.webp',
                                  ),
                                ),
                              ),
                              child: Container(
                                margin: const .all(10),
                                alignment: .bottomLeft,
                                child: Text(
                                  "Kbri ${n.kbriCountry?.title.toString()}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: .bold,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorWidget: (context, url, error) {
                            return Container(
                              width: double.infinity,
                              height: 200.0,
                              decoration: BoxDecoration(
                                borderRadius: .circular(10.0),
                                image: const DecorationImage(
                                  fit: .fitWidth,
                                  image: AssetImage(
                                    'assets/images/user-placeholder.webp',
                                  ),
                                ),
                              ),
                              child: Container(
                                margin: const .all(10),
                                alignment: .bottomLeft,
                                child: Text(
                                  "Kbri ${n.kbriCountry?.title.toString()}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: .bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      Container(
                        margin: const .all(16.0),
                        child: HtmlWidget(
                          n.kbriCountry?.description.toString() ?? "-",
                          customStylesBuilder: (el) {
                            return null;
                          },
                          customWidgetBuilder: (el) {
                            return null;
                          },
                          onTapUrl: (url) => Future.value(true),
                          renderMode: RenderMode.column,
                          textStyle: TextStyle(fontSize: 14),
                        ),
                      ),

                      Container(
                        margin: .symmetric(horizontal: 16, vertical: 4),
                        child: Text(
                          n.kbriCountry?.address.toString() ?? "-",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: .bold,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      Container(
                        width: double.infinity,
                        height: 180,
                        margin: .symmetric(horizontal: 16, vertical: 20),
                        child: GoogleMap(
                          gestureRecognizers: {}
                            ..add(
                              Factory<EagerGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                              ),
                            ),
                          myLocationEnabled: false,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              double.parse(n.kbriCountry?.lat ?? "0.0"),
                              double.parse(n.kbriCountry?.lng ?? "0.0"),
                            ),
                            zoom: 15.0,
                          ),
                          markers: <Marker>{
                            Marker(
                              markerId: MarkerId(
                                n.kbriCountry?.title.toString() ?? "-",
                              ),
                              position: LatLng(
                                double.parse(n.kbriCountry?.lat ?? "0.0"),
                                double.parse(n.kbriCountry?.lng ?? "0.0"),
                              ),
                            ),
                          },
                        ),
                      ),
                    ]),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
