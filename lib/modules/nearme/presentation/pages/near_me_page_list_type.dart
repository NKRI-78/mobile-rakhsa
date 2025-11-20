import 'package:flutter/material.dart';
import 'package:rakhsa/router/route_trees.dart';

import 'package:rakhsa/misc/utils/asset_source.dart';
import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

import 'package:rakhsa/modules/nearme/presentation/widgets/type_tile.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';

class NearMeListTypePage extends StatelessWidget {
  const NearMeListTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    final types = [
      NearMeType(
        title: 'Kantor Polisi',
        assets: AssetSource.iconKantorPolisi,
        action: () => NearMeRoute(type: "police").go(context),
      ),
      NearMeType(
        title: 'Tempat Ibadah',
        assets: AssetSource.iconTempatIbadah,
        action: () => NearMeRoute(type: "mosque").go(context),
      ),
      NearMeType(
        title: 'Hotel',
        assets: AssetSource.iconHotel,
        action: () => NearMeRoute(type: "lodging").go(context),
      ),
      NearMeType(
        title: 'Restoran',
        assets: AssetSource.iconRestoran,
        action: () => NearMeRoute(type: "restaurant").go(context),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          // title kategori
          SliverPadding(
            padding: EdgeInsetsGeometry.only(top: context.top + kToolbarHeight),
            sliver: SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: Text(
                  "Mencari lokasi terdekat dari Anda...",
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeOverLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // body lists
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.separated(
              itemCount: types.length,
              separatorBuilder: (BuildContext context, int i) =>
                  const SizedBox(height: 16),
              itemBuilder: (BuildContext context, int index) {
                final category = types[index];
                return TypeTile(category, onTap: category.action);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NearMeType {
  final String title;
  final String assets;
  final VoidCallback action;

  NearMeType({required this.title, required this.assets, required this.action});
}
