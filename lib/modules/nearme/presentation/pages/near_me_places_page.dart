import 'package:flutter/material.dart';
import 'package:rakhsa/core/constants/assets.dart';
import 'package:rakhsa/router/route_trees.dart';

import 'package:rakhsa/modules/nearme/presentation/widgets/near_me_place_tile.dart';
import 'package:rakhsa/core/extensions/extensions.dart';

class NearMePlacesPage extends StatelessWidget {
  const NearMePlacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final types = [
      NearMePlaceType(
        'Kantor Polisi',
        Assets.imagesNearmePolice,
        () => NearMeRoute(type: "police").go(context),
      ),
      NearMePlaceType(
        'Tempat Ibadah',
        Assets.imagesNearmePray,
        () => NearMeRoute(type: "mosque").go(context),
      ),
      NearMePlaceType(
        'Hotel',
        Assets.imagesNearmeLodging,
        () => NearMeRoute(type: "lodging").go(context),
      ),
      NearMePlaceType(
        'Restoran',
        Assets.imagesNearmeRestaurant,
        () => NearMeRoute(type: "restaurant").go(context),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: .only(top: context.top + kToolbarHeight),
            sliver: SliverToBoxAdapter(
              child: Container(
                margin: .symmetric(horizontal: 16),
                child: Text(
                  "Mencari lokasi terdekat dari Anda...",
                  style: TextStyle(fontSize: 24, fontWeight: .bold),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const .all(16),
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
