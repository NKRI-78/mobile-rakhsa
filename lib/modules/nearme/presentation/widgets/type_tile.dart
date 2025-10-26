import 'package:flutter/material.dart';

import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

import 'package:rakhsa/modules/nearme/presentation/pages/near_me_page_list_type.dart';

class TypeTile extends StatelessWidget {
  const TypeTile(this.type, {super.key, required this.onTap});

  final NearMeType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // icon asset
              _buildIconAsset(),
              const SizedBox(width: 16),

              // title
              _buildTitle(),

              // arrow icon
              const Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Flexible(
      fit: FlexFit.tight,
      child: Text(
        type.title,
        style: robotoRegular.copyWith(
          fontSize: Dimensions.fontSizeLarge,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildIconAsset() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFCD302E), Color(0xFFF46F6C)],
        ),
      ),
      child: Image.asset(
        type.assets,
        width: Dimensions.iconSizeExtraLarge,
        height: Dimensions.iconSizeExtraLarge,
      ),
    );
  }
}
