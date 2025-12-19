import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rakhsa/misc/utils/asset_source.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageBanner extends StatelessWidget {
  const ImageBanner(this.link, this.img, {super.key});

  final String link;
  final String img;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(link);
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      },
      child: CachedNetworkImage(
        imageUrl: img,
        height: 190,
        fit: BoxFit.fill,
        width: double.infinity,
        errorWidget: (_, _, _) => Image.asset(AssetSource.iconDefaultImg),
        placeholder: (_, _) =>
            const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
