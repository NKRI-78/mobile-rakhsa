import 'package:flutter/material.dart';
import 'package:rakhsa/core/extensions/extensions.dart';
import 'package:rakhsa/router/route_trees.dart';
import 'package:rakhsa/modules/nearme/presentation/widgets/near_me_place_tile.dart';

class InformationListPage extends StatelessWidget {
  const InformationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xffF4F4F7),
        automaticallyImplyLeading: false,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(80.0),
          child: Padding(
            padding: .fromLTRB(20, 0, 20, 10),
            child: Text(
              'Informasi apa, yang ingin anda ketahui ?',
              style: TextStyle(fontWeight: .bold, fontSize: 24),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const .all(16.0),
        children: [
          NearMePlaceTile(
            NearMePlaceType(
              "Informasi KBRI",
              "assets/images/icons/icon-office.png",
              () => InformasiKBRIRoute(info: "informasi-kbri").go(context),
            ),
          ),

          16.spaceY,

          NearMePlaceTile(
            NearMePlaceType(
              "Panduan",
              "assets/images/icons/icon-guide.png",
              () => PanduanHukumRoute().go(context),
            ),
          ),
        ],
      ),
    );
  }
}
