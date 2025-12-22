import 'package:flutter/material.dart';
import 'package:rakhsa/core/extensions/extensions.dart';
import 'package:rakhsa/router/route_trees.dart';
import 'package:rakhsa/modules/nearme/presentation/widgets/near_me_place_tile.dart';

class InformationPage extends StatelessWidget {
  const InformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F4F7),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: .only(top: context.top + kToolbarHeight),
            sliver: SliverToBoxAdapter(
              child: Container(
                margin: .symmetric(horizontal: 16),
                child: Text(
                  "Informasi apa, yang ingin anda ketahui ?",
                  style: TextStyle(fontSize: 24, fontWeight: .bold),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: .all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                NearMePlaceTile(
                  NearMePlaceType(
                    "Informasi KBRI",
                    "assets/images/icons/icon-office.png",
                    () => CurrentKBRIRoute().go(context),
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
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
