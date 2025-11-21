import 'dart:async';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/misc/enums/request_state.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';
import 'package:rakhsa/modules/app/provider/user_provider.dart';
import 'package:rakhsa/modules/location/provider/location_provider.dart';
import 'package:rakhsa/service/socket/socketio.dart';

import 'package:rakhsa/modules/dashboard/presentation/widgets/ews/list.dart';
import 'package:rakhsa/modules/dashboard/presentation/widgets/header/header_home.dart';
import 'package:rakhsa/modules/dashboard/presentation/widgets/home_highlight_banner.dart';
import 'package:rakhsa/modules/dashboard/presentation/widgets/sos_button.dart';

import 'package:flutter/material.dart';

import 'package:rakhsa/misc/constants/theme.dart';
import 'package:rakhsa/misc/helpers/enum.dart';
import 'package:rakhsa/misc/utils/color_resources.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

import 'package:rakhsa/modules/dashboard/presentation/provider/dashboard_notifier.dart';

class HomePage extends StatefulWidget {
  final GlobalKey<ScaffoldState> globalKey;
  final Future<void> Function() onRefresh;
  final List<Widget> banners;

  const HomePage({
    required this.globalKey,
    required this.onRefresh,
    required this.banners,
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: context.top),
        child: RefreshIndicator.adaptive(
          onRefresh: widget.onRefresh,
          color: primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderSection(scaffoldKey: widget.globalKey),

                  40.spaceY,

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "Tekan & tahan tombol ini, \njika Anda dalam keadaan darurat.",
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  45.spaceY,

                  Consumer3<UserProvider, LocationProvider, SocketIoService>(
                    builder: (_, u, l, s, _) {
                      final coord = l.location?.coord;
                      final placemark = l.location?.placemark;
                      return SosButton(
                        SosButtonParam(
                          location: placemark?.getAddress() ?? "-",
                          country: placemark?.country ?? "-",
                          lat: (coord?.lat ?? 0.0).toString(),
                          lng: (coord?.lng ?? 0.0).toString(),
                          hasSocketConnection: s.isConnected,
                          loadingGmaps: l.isGetLocationState(
                            RequestState.loading,
                          ),
                          profile: u.user,
                        ),
                      );
                    },
                  ),

                  Consumer<DashboardNotifier>(
                    builder: (context, n, child) {
                      if (n.state == ProviderState.loading) {
                        return Container(
                          margin: EdgeInsets.only(top: 46),
                          padding: EdgeInsets.all(16),
                          height: 200.0,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            spacing: 12,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.red,
                                  backgroundColor: Colors.red.shade50,
                                ),
                              ),
                              SizedBox(
                                width: double.maxFinite,
                                child: Text(
                                  "Memuat Informasi",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (n.state == ProviderState.error) {
                        return SizedBox(
                          height: 200.0,
                          child: Center(
                            child: Text(
                              n.message,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: ColorResources.black,
                              ),
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 45.0),
                        child: (n.ews.isNotEmpty)
                            ? EwsListWidget(getData: widget.onRefresh)
                            : HomeHightlightBanner(banners: widget.banners),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
