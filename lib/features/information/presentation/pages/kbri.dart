import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';
import 'package:rakhsa/features/information/presentation/provider/kbri_notifier.dart';

class KbriPage extends StatefulWidget {
  final int stateId;

  const KbriPage({
    required this.stateId,
    super.key
  });

  @override
  State<KbriPage> createState() => KbriPageState();
}

class KbriPageState extends State<KbriPage> {

  late KbriNotifier kbriNotifier;

  Future<void> getData() async {
    if(!mounted) return;
      kbriNotifier.infoKbri(stateId: widget.stateId.toString());
  }

  @override
  void initState() {
    super.initState();

    kbriNotifier = context.read<KbriNotifier>();

    Future.microtask(() => getData());
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResources.backgroundColor,
      body: RefreshIndicator.adaptive(
        onRefresh: () {
          return Future.sync(() {
            getData();
          });
        },
        child: Consumer<KbriNotifier>(
          builder: (BuildContext context, KbriNotifier notifier, Widget? child) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
          
                SliverAppBar(
                  title: const SizedBox(),
                  leading: CupertinoNavigationBarBackButton(
                    color: ColorResources.black,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                if(notifier.state == ProviderState.loading)
                  const SliverFillRemaining(
                    child: Center(
                      child: SizedBox(
                        width: 16.0,
                        height: 16.0,
                        child: CircularProgressIndicator()
                      )
                    ),
                  ),

                if(notifier.state == ProviderState.error) 
                  SliverFillRemaining(
                    child: Center(
                      child: Text("Kbri not found",
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: ColorResources.black
                        ),
                      )
                    )
                  ),

                if(notifier.state == ProviderState.loaded)
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.only(
                        left: 8.0,
                        right: 8.0
                      ),
                      child: Text("Data Pencarian KBRI Negara ${notifier.entity.data?.stateName.toString()}",
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeOverLarge,
                          fontWeight: FontWeight.bold,
                          color: ColorResources.black
                        ),
                      ),
                    ),
                  ),
                
                if(notifier.state == ProviderState.loaded)
                  SliverList(
                    delegate: SliverChildListDelegate([
              
                      Container(
                        margin: const EdgeInsets.only(
                          top: 8.0,
                          left: 18.0,
                          right: 18.0,
                          bottom: 8.0
                        ),
                        child: CachedNetworkImage(
                          imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTsytTHnlOL92L-kaA13EY5Q_W2QABiTZSy_w&s",
                          imageBuilder: (BuildContext context, ImageProvider<Object>  imageProvider) {
                            return Container(
                              width: double.infinity,
                              height: 200.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                image: DecorationImage(
                                  fit: BoxFit.fitWidth,
                                  image: imageProvider
                                )
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(
                                  top: 10.0,
                                  bottom: 10.0,
                                  left: 10.0,
                                  right: 10.0
                                ),
                                alignment: Alignment.bottomLeft,
                                child: Text("Kbri Tokyo",
                                  style: robotoRegular.copyWith(
                                    color: ColorResources.white,
                                    fontSize: Dimensions.fontSizeOverLarge,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              )
                            );
                          },
                          placeholder: (BuildContext context, String url) {
                            return Container(
                              width: double.infinity,
                              height: 200.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                image: const DecorationImage(
                                  fit: BoxFit.fitWidth,
                                  image: AssetImage('assets/images/default.jpeg')
                                )
                              ),
                            );
                          },
                          errorWidget: (BuildContext context, String url, Object error) {
                            return Container(
                              width: double.infinity,
                              height: 200.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                image: const DecorationImage(
                                  fit: BoxFit.fitWidth,
                                  image: AssetImage('assets/images/default.jpeg')
                                )
                              ),
                            );
                          },
                        ),
                      ),
              
                      Container(
                        margin: const EdgeInsets.all(16.0),
                        child: HtmlWidget(
                        '''
                          <p>
                            Kedutaan Besar Republik Indonesia di Tokyo (KBRI Tokyo) adalah misi diplomatik Republik Indonesia untuk Jepang dan merangkap sebagai perwakilan Indonesia untuk Federasi Mikronesia.ng adalah sebuah konsulat jenderal di Osaka.[3] Terdapat juga dua Konsul Kehormatan di Fukuoka dan Sapporo.[4]
                          </p>
                        ''',
                          customStylesBuilder: (element) {
                            return null;
                          },
                          customWidgetBuilder: (element) {
                            return null;
                          },
                          onTapUrl: (url) => Future.value(true),
                          renderMode: RenderMode.column,
                          textStyle: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault
                          ),
                        ),
                      ),
              
                      Container(
                        margin: const EdgeInsets.only(
                          top: 4.0,
                          left: 16.0,
                          right: 16.0,
                          bottom: 4.0
                        ),
                        child: Text("Alamat : 5-2-9 Higashigotanda, Shinagawa Ward, Tokyo 141-00022",
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            fontWeight: FontWeight.bold,
                            color: ColorResources.black
                          ),
                        ),
                      ),
              
                      Container(
                        width: double.infinity,
                        height: 180.0,
                        margin: const EdgeInsets.only(
                          top: 20.0,
                          left: 16.0, 
                          right: 16.0,
                          bottom: 20.0,
                        ),
                        child: GoogleMap(
                          mapType: MapType.normal,
                          gestureRecognizers: {}..add(Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer())),
                          myLocationEnabled: false,
                          initialCameraPosition: const CameraPosition(
                          target: LatLng(
                            35.63132155675379, 
                            139.72159131168362
                          ),
                          zoom: 15.0,
                        ),
                        // markers: Set.from([]),
                        ),
                      ),
              
                    ])
                  )
            
                ],
              );

          },
        )
        
      ),
    );
  }
}