import 'package:flutter/material.dart';
import 'package:rakhsa/router/route_trees.dart';

import 'package:rakhsa/misc/utils/custom_themes.dart';

import 'package:rakhsa/modules/nearme/presentation/widgets/near_me_place_tile.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';

class NearMePlacesPage extends StatelessWidget {
  const NearMePlacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final types = [
      NearMePlaceType(
        'Kantor Polisi',
        'assets/images/icons/icon-police.png',
        () => NearMeRoute(type: "police").go(context),
      ),
      NearMePlaceType(
        'Tempat Ibadah',
        'assets/images/icons/icon-pray.png',
        () => NearMeRoute(type: "mosque").go(context),
      ),
      NearMePlaceType(
        'Hotel',
        'assets/images/icons/icon-hotel.png',
        () => NearMeRoute(type: "lodging").go(context),
      ),
      NearMePlaceType(
        'Restoran',
        'assets/images/icons/icon-restaurant.png',
        () => NearMeRoute(type: "restaurant").go(context),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsetsGeometry.only(top: context.top + kToolbarHeight),
            sliver: SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Mencari lokasi terdekat dari Anda...",
                  style: robotoRegular.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.separated(
              itemCount: types.length,
              separatorBuilder: (context, i) => 16.spaceY,
              itemBuilder: (context, index) {
                final type = types[index];
                return NearMePlaceTile(type);
              },
            ),
          ),
        ],
      ),
    );
  }
}
