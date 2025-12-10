import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart' as fh;
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:provider/provider.dart';
import 'package:rakhsa/misc/helpers/extensions.dart';

import 'package:rakhsa/misc/utils/custom_themes.dart';
import 'package:rakhsa/misc/utils/dimensions.dart';

import 'package:rakhsa/modules/dashboard/presentation/provider/dashboard_notifier.dart';
import 'package:rakhsa/modules/news/persentation/pages/detail.dart';
import 'package:rakhsa/router/route_trees.dart';
import 'package:shimmer/shimmer.dart';

class EwsListWidget extends StatelessWidget {
  final Function getData;

  const EwsListWidget({required this.getData, super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Consumer<DashboardNotifier>(
        builder: (context, n, child) {
          return CarouselSlider(
            options: CarouselOptions(
              height: 200.0,
              autoPlay: true,
              viewportFraction: 1.0,
              autoPlayInterval: const Duration(seconds: 5),
              enableInfiniteScroll: (n.ews.length == 1) ? false : true,
            ),
            items: n.ews.map((item) {
              return GestureDetector(
                onTap: () {
                  NewsDetailRoute(
                    NewsDetailPageParams(id: item.id, type: item.type),
                  ).go(context);
                },
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: item.img,
                        fit: BoxFit.cover,
                        width: double.maxFinite,
                        height: 200.0,
                        placeholder: (context, url) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade200,
                            child: Container(color: Colors.grey.shade300),
                          );
                        },
                        errorWidget: (context, url, error) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade200,
                            child: Container(color: Colors.grey.shade300),
                          );
                        },
                      ),
                    ),

                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black26, Colors.black87],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        spacing: 2,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Info kejadian disekitar Anda",
                            style: robotoRegular.copyWith(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            item.createdAt,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),

                          4.spaceY,

                          if (item.location != "-")
                            Row(
                              spacing: 4,
                              children: [
                                Icon(
                                  IconsaxPlusBold.location,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                Expanded(
                                  child: Text(
                                    item.location,
                                    overflow: TextOverflow.ellipsis,
                                    style: robotoRegular.copyWith(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          4.spaceY,

                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(
                            height: 30,
                            child: OverflowBox(
                              maxHeight: 30,
                              alignment: Alignment.topLeft,
                              child: fh.Html(
                                data: item.desc,
                                shrinkWrap: true,

                                style: {
                                  'body': fh.Style(
                                    margin: fh.Margins.zero,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: fh.FontSize(12),
                                    display: fh.Display.inline,
                                    textOverflow: TextOverflow.ellipsis,
                                  ),
                                  'p': fh.Style(
                                    margin: fh.Margins.zero,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: fh.FontSize(12),
                                    display: fh.Display.inline,
                                    fontWeight: FontWeight.normal,
                                    textOverflow: TextOverflow.ellipsis,
                                  ),
                                  'span': fh.Style(
                                    margin: fh.Margins.zero,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: fh.FontSize(12),
                                    display: fh.Display.inline,
                                  ),
                                  'div': fh.Style(
                                    margin: fh.Margins.zero,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: fh.FontSize(12),
                                    display: fh.Display.inline,
                                  ),
                                  'strong': fh.Style(
                                    fontWeight: FontWeight.normal,
                                  ),
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
