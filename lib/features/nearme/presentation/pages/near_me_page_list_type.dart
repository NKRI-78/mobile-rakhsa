import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rakhsa/common/routes/routes_navigation.dart';

import 'package:rakhsa/common/utils/asset_source.dart';
import 'package:rakhsa/common/utils/color_resources.dart';
import 'package:rakhsa/common/utils/custom_themes.dart';
import 'package:rakhsa/common/utils/dimensions.dart';

import 'package:rakhsa/features/nearme/presentation/widgets/type_tile.dart';

class NearMeListTypePage extends StatelessWidget {
  const NearMeListTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    final types = [
      NearMeType(
        title: 'Tempat Ibadah',
        assets: AssetSource.iconTempatIbadah,
        action: () => Navigator.pushNamed(
          context,
          RoutesNavigation.nearMe,
          arguments:  "mosque"
        ),
      ),
      NearMeType(
        title: 'Hotel',
        assets: AssetSource.iconHotel,
        action: () => Navigator.pushNamed(
          context,
          RoutesNavigation.nearMe,
          arguments:  "lodging"
        ),
      ),
      NearMeType(
        title: 'Kantor Polisi',
        assets: AssetSource.iconKantorPolisi,
        action: () => Navigator.pushNamed(
          context,
          RoutesNavigation.nearMe,
          arguments:  "police"
        ),
      ),
      NearMeType(
        title: 'Restoran',
        assets: AssetSource.iconRestoran,
        action: () => Navigator.pushNamed(
          context,
          RoutesNavigation.nearMe,
          arguments:  "restaurant"
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          // app bar
          SliverAppBar(
            backgroundColor: ColorResources.backgroundColor,
            leading: CupertinoNavigationBarBackButton(
              onPressed: () => Navigator.of(context).pop(),
              color: ColorResources.black,
            ),
          ),

          // title kategori
          SliverToBoxAdapter(
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

          // body lists
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.separated(
              itemCount: types.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final category = types[index];
                return TypeTile(category, onTap: category.action);
              },
            ),
          )
        ],
      ),
    );
  }
}

class NearMeType {
  final String title;
  final String assets;
  final VoidCallback action;

  NearMeType({
    required this.title,
    required this.assets,
    required this.action,
  });
}